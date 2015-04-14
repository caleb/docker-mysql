#!/usr/bin/env bash

NO_CACHE="${1:-false}"

echo "Building mysql:5.7"
cd 5.7
./build.sh $NO_CACHE
cd ..
docker tag -f docker.rodeopartners.com/mysql:5.7 docker.rodeopartners.com/mysql:latest

echo "Building mysql:5.7-toolbox"
cd 5.7-toolbox
./build.sh $NO_CACHE
cd ..
docker tag -f docker.rodeopartners.com/mysql:5.7-toolbox docker.rodeopartners.com/mysql:latest-toolbox
