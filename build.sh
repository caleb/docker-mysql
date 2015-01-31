#!/usr/bin/env bash

echo "Building mysql:5.7"
docker build -t docker.rodeopartners.com/mysql:5.7 5.7

echo "Building mysql:5.7-toolbox"
docker build -t docker.rodeopartners.com/mysql:5.7-toolbox 5.7-toolbox
