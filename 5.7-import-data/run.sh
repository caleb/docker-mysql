#!/usr/bin/env bash

pwd="$(pwd)"

docker build -t mysql-test .
# docker run -it --rm -e MYSQL_ROOT_PASSWORD=mozart \
#                     -e MYSQL_USER=bwah \
#                     -e MYSQL_PASSWORD=bwah \
#                     -e MYSQL_DATABASE=bwah \
#                     -e MYSQL_USER_1=wordpress:09FAA748-8B83-4110-AEC1-E3193DEE9E2E \
#                     -e MYSQL_USER_2=wordpress2:09FAA748-8B83-4110-AEC1-E3193DEE9E2E \
#                     -e MYSQL_DATABASE_1=wordpress:wordpress \
#                     -e MYSQL_DATABASE_2=wordpress2:wordpress2 \
#                     -e MYSQL_DATABASE_3=no_owner \
#                     -e MYSQL_IMPORT_1=/srv/fresh.sql:wordpress \
#                     -v "${pwd}/test.sql":/srv/fresh.sql \
#                     mysql-test

docker run -it --rm -e MYSQL_ROOT_PASSWORD=mozart \
                    -e MYSQL_USER=bwah \
                    -e MYSQL_PASSWORD=bwah \
                    -e MYSQL_DATABASE=bwah \
                    -e MYSQL_DATABASE_1=wordpress \
                    -e MYSQL_DATABASE_2=wordpress2 \
                    -e MYSQL_DATABASE_3=no_owner \
                    -e MYSQL_IMPORT_1=/srv/fresh.sql \
                    -v "${pwd}/test.sql":/srv/fresh.sql \
                    mysql-test
