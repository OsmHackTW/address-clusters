#!/bin/bash

if [ ! -f "/source/taiwan-latest.osm.pbf" ]; then
  echo "ERROR: taiwan-latest.osm.pbf not found"
  echo "Please download it from Geofabrik and put it in source/."
  exit 1
fi

echo "Running osm2pgsql..."
osm2pgsql -d postgresql://addr:addr@postgis:5432/addr -O flex -S addresses.lua /source/taiwan-latest.osm.pbf