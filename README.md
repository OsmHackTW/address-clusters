This is a work in progress.

Currently address import to PostGIS is done, clustering and tile generation are not done yet.

### Import Taiwan Addresses

Docker (with Docker Compose) is required.

First, get `taiwan-latest.osm.pbf` from Geofabrik Download Server, put it in the `source/`. Then run the following command to import them to PostGIS:

```sh
docker compose run worker /work/import.sh
```

As of December 2024, it took about a minute in my i7-12700K machine running WSL 2.