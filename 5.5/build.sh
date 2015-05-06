#!/usr/bin/env bash

NO_CACHE="${1:-false}"

docker build --no-cache=$NO_CACHE -t docker.rodeopartners.com/mysql:5.5 .
