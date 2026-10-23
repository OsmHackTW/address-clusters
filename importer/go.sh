#!/bin/bash
set -e

if [ ! -f "/source/$PBF" ]; then
  echo "ERROR: $PBF not found"
  echo "Please download it from Geofabrik and put it in source/."
  exit 1
fi

echo "Running osm2pgsql on $PBF..."
osm2pgsql -d $POSTGRES_URL -O flex -S addresses.lua "/source/$PBF"

echo "Generating Clusters..."
psql $POSTGRES_URL -v ON_ERROR_STOP=1 -f cluster.sql
