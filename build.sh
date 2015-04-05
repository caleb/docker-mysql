#!/usr/bin/env bash

echo "Building mysql:5.7"
cd 5.7
./build.sh
cd ..

echo "Building mysql:5.7-toolbox"
cd 5.7-toolbox
./build.sh
cd ..
