DROP MATERIALIZED VIEW IF EXISTS address_clusters;
CREATE MATERIALIZED VIEW address_clusters AS WITH addrs_with_cid AS (
    SELECT city,
        street,
        place,
        concat(city, street, place) AS cp,
        geom,
        ST_ClusterDBSCAN(geom, eps => 200, minpoints => 2) over (PARTITION BY concat(city, street, place)) AS cid
    from addresses
)
SELECT ANY_VALUE(city) AS city,
    concat(ANY_VALUE(street), ANY_VALUE(place)) AS label,
    ST_Buffer(ST_ConvexHull(ST_Collect(geom)), 3) AS geom
FROM addrs_with_cid
WHERE cp > ''
    and cid is not null
GROUP BY cp,
    cid;