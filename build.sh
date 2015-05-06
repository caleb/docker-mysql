#!/usr/bin/env bash

NO_CACHE="${1:-false}"

echo "Building mysql:5.5"
cd 5.5
./build.sh $NO_CACHE
cd ..

echo "Building mysql:5.6"
cd 5.6
./build.sh $NO_CACHE
cd ..

echo "Building mysql:5.7"
cd 5.7
./build.sh $NO_CACHE
cd ..
docker tag -f docker.rodeopartners.com/mysql:5.7 docker.rodeopartners.com/mysql:latest

echo "Building mysql:toolbox"
cd toolbox
./build.sh $NO_CACHE
cd ..
docker tag -f docker.rodeopartners.com/mysql:5.7-toolbox docker.rodeopartners.com/mysql:latest-toolbox
docker tag -f docker.rodeopartners.com/mysql:5.7-toolbox docker.rodeopartners.com/mysql:toolbox
