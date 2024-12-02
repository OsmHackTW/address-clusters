#!/bin/bash

if [ ! -f "/source/taiwan-latest.osm.pbf" ]; then
  echo "ERROR: taiwan-latest.osm.pbf not found"
  echo "Please download it from Geofabrik and put it in source/."
  exit 1
fi

until psql $POSTGRES_URL -c "select 1" > /dev/null 2>&1; do
  echo "Wait until Postgres is ready..."
  sleep 5
done

echo "Running osm2pgsql..."
osm2pgsql -d $POSTGRES_URL -O flex -S addresses.lua /source/taiwan-latest.osm.pbf

echo "Generating Clusters..."
psql $POSTGRES_URL -f cluster.sql