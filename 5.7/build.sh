#!/usr/bin/env bash

docker build -t docker.rodeopartners.com/mysql:5.7 .
docker tag docker.rodeopartners.com/mysql:5.7 docker.rodeopartners.com/mysql:latest
