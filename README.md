This is a work in progress.

Currently address importing, clustering and PMTiles generation are done,
adding Tileserver GL for rendering for map editors is work in progress.

### Produce PMTiles

Docker (with Docker Compose) is required.

First, get `taiwan-latest.osm.pbf` from Geofabrik Download Server, put it in the `source/`.

Then run the `importer` to import address into PostgreSQL and process the cluster,
and the `converter` to use GDAL to generate PMTiles:
```sh
docker compose run importer
docker compose run converter
```

As of December 2024, the `importer` took about 100 seconds and `converter` took about 1 minute
in my i7-12700K machine running WSL 2.
The `addresses` table will have 9,067,781 entries, generating 182,953 address clusters;
the PMTiles generated is sized 61MB.
