#!/bin/bash

until psql $POSTGRES_URL -c "select 1" > /dev/null 2>&1; do
  echo "Wait until Postgres is ready..."
  sleep 5
done

echo "Running ogr2ogr to generate PMTiles..."
ogr2ogr -dsco MINZOOM=10 -dsco MAXZOOM=15 -F "PMTiles" /source/cluster.pmtiles $POSTGRES_URL "address_clusters"