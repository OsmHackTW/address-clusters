#!/bin/bash
set -e

echo "Running ogr2ogr to generate PMTiles..."
rm -f /source/cluster.pmtiles
ogr2ogr -dsco MINZOOM=10 -dsco MAXZOOM=15 -F "PMTiles" /source/cluster.pmtiles $POSTGRES_URL "address_clusters"
