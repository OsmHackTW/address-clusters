This is a work in progress.

Currently address importing, clustering and PMTiles generation are done,
adding Tileserver GL for rendering for map editors is work in progress.

### Produce PMTiles

Docker (with Docker Compose) is required.

First, get `taiwan-latest.osm.pbf` from Geofabrik Download Server, put it in the `source/`.
To use another file name, set `PBF`, e.g. `PBF=taiwan-261022.osm.pbf docker compose run importer`.

Then run the `importer` to import address into PostgreSQL and process the cluster,
and the `converter` to use GDAL to generate PMTiles:
```sh
docker compose run importer
docker compose run converter
```

As of October 2026 (`taiwan-261022.osm.pbf`), the `importer` took about 140 seconds and `converter` took about 95 seconds
in my Ryzen 5 5600G machine running WSL 2.
The `addresses` table will have 9,711,502 entries, generating 202,861 address clusters;
the PMTiles generated is sized 38MB.
