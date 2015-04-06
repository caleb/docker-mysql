#!/usr/bin/env bash

cd 5.7
./push.sh
cd ..
docker push docker.rodeopartners.com/mysql:latest

cd 5.7-toolbox
./push.sh
cd ..
docker push docker.rodeopartners.com/mysql:latest-toolbox
