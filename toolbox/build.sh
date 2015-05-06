#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/mysql:5.5-toolbox -f Dockerfile-5.5 .
docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/mysql:5.6-toolbox -f Dockerfile-5.6 .
docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/mysql:5.7-toolbox -f Dockerfile-5.7 .
