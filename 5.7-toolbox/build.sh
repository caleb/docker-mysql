#!/usr/bin/env bash

docker build -t docker.rodeopartners.com/mysql:5.7-toolbox .
docker tag docker.rodeopartners.com/mysql:5.7-toolbox docker.rodeopartners.com/mysql:latest-toolbox
