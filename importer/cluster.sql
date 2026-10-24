-- Distances are in EPSG:3857 units, which are ~1/cos(lat) longer than
-- ground meters: 200m is 218 units at 23.7°N, the center of Taiwan.
\set eps 218
-- Clusters longer than 1.5km are split into ~1km pieces with k-means.
\set max_span 1638
\set piece 1092

SET work_mem = '256MB';

-- Fold spelling variants (台/臺, 温/溫, full-width digits...) for grouping keys.
CREATE OR REPLACE FUNCTION addr_norm(s text) RETURNS text
LANGUAGE sql IMMUTABLE PARALLEL SAFE RETURN translate(
    s,
    '台温舘峯巿０１２３４５６７８９',
    '臺溫館峰市0123456789'
);

DROP MATERIALIZED VIEW IF EXISTS address_clusters;
CREATE MATERIALIZED VIEW address_clusters AS WITH addrs AS (
    SELECT DISTINCT addr_norm(city) AS city,
        district,
        -- addr:place is often a community name when addr:street is also set
        coalesce(nullif(street, ''), nullif(place, '')) AS name,
        addr_norm(coalesce(nullif(street, ''), nullif(place, ''))) AS key,
        housenumber,
        geom
    FROM addresses
),
positions AS (
    -- Floors and units of a building are separate nodes on the same position,
    -- so collapsing positions keeps them from inflating counts.
    SELECT city,
        district,
        key,
        min(name) AS name,
        count(*) AS addrs,
        bool_and(dup) AS dup,
        geom
    FROM (
            -- An address appearing on more than one position is a duplicate somewhere
            SELECT *,
                count(*) OVER (PARTITION BY city, district, key, housenumber) > 1 AS dup
            FROM addrs
            WHERE key > ''
        ) a
    GROUP BY city,
        district,
        key,
        geom
),
clustered AS (
    -- Lone positions become their own cluster, unless the same address
    -- is also somewhere else, which makes this position a likely stray.
    SELECT *,
        coalesce(cid, -row_number() OVER ()) AS c
    FROM (
            SELECT *,
                ST_ClusterDBSCAN(geom, eps => :eps, minpoints => 2) OVER (PARTITION BY city, district, key) AS cid
            FROM positions
        ) d
    WHERE cid IS NOT NULL
        OR NOT dup
),
spans AS (
    SELECT *,
        ST_Extent(geom) OVER (PARTITION BY city, district, key, c) AS box
    FROM clustered
),
pieces AS (
    -- Chained clusters along long roads are split into pieces
    SELECT *,
        ST_ClusterKMeans(
            geom,
            CASE
                WHEN span > :max_span THEN ceil(span / :piece)::int
                ELSE 1
            END
        ) OVER (PARTITION BY city, district, key, c) AS piece
    FROM (
            SELECT *,
                sqrt(
                    (ST_XMax(box) - ST_XMin(box)) ^ 2 + (ST_YMax(box) - ST_YMin(box)) ^ 2
                ) AS span
            FROM spans
        ) s
)
SELECT ANY_VALUE(city) AS city,
    ANY_VALUE(district) AS district,
    mode() WITHIN GROUP (ORDER BY name) AS label,
    -- Hug the positions instead of covering whole neighborhoods
    ST_SimplifyPreserveTopology(
        ST_ConcaveHull(ST_ReducePrecision(ST_Collect(geom), 1), 0.3),
        5
    ) AS geom,
    COUNT(*) AS cnt,
    SUM(addrs) AS addrs
FROM pieces
GROUP BY city,
    district,
    key,
    c,
    piece;
