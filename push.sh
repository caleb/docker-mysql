#!/usr/bin/env bash

cd 5.5
./push.sh
cd ..

cd 5.6
./push.sh
cd ..

cd 5.7
./push.sh
cd ..
docker push caleb/mysql:latest

cd toolbox
./push.sh
cd ..
docker push caleb/mysql:latest-toolbox
