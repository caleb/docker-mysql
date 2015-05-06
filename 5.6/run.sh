#!/usr/bin/env bash

docker build -t mysql-test .

docker run -it --rm -e MYSQL_ROOT_PASSWORD=mozart \
                    mysql-test
