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
docker tag -f caleb/mysql:5.7 caleb/mysql:latest

echo "Building mysql:toolbox"
cd toolbox
./build.sh $NO_CACHE
cd ..
docker tag -f caleb/mysql:5.7-toolbox caleb/mysql:latest-toolbox
docker tag -f caleb/mysql:5.7-toolbox caleb/mysql:toolbox
