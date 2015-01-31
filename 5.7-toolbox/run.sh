#!/usr/bin/env bash

pwd="$(pwd)"

docker build -t mysql-toolbox .
docker run --rm -i -e MYSQL_USER=bwah \
       -e MYSQL_PASSWORD=bwah \
       -e MYSQL_DATABASE=bwah \
       -e MYSQL_USER_1=wordpress:mozart \
       -e MYSQL_USER_2=wordpress2:09FAA748-8B83-4110-AEC1-E3193DEE9E2E \
       -e MYSQL_DATABASE_1=wordpress:wordpress \
       -e MYSQL_DATABASE_2=wordpress2:wordpress2 \
       -e MYSQL_DATABASE_3=no_owner \
       -e MYSQL_DATABASE_4=another \
       -e MYSQL_IMPORT_1=/srv/fresh.sql:wordpress \
       -e MYSQL_IMPORT_2=-:wordpress2 \
       -v "${pwd}/test.sql":/srv/fresh.sql \
       --link mysql-test:mysql \
       mysql-toolbox reinitialize < test.sql

docker run --rm -i -e MYSQL_DATABASE=no_owner --link mysql-test:mysql mysql-toolbox run < test.sql
docker run --rm -i -e MYSQL_DATABASE=another --link mysql-test:mysql -v ${pwd}/test.sql:/test.sql mysql-toolbox run /test.sql

rm -rf dumps
mkdir -p dumps

docker run --rm -i -e MYSQL_DATABASE=another --link mysql-test:mysql -v ${pwd}/dumps:/srv mysql-toolbox dump /srv/test-from-dump.sql
docker run --rm -i -e MYSQL_DATABASE=another --link mysql-test:mysql mysql-toolbox dump > dumps/test-from-dump-stdout.sql
docker run --rm -i --link mysql-test:mysql -v ${pwd}/dumps:/srv mysql-toolbox dump /srv/test-from-dump-all-databases.sql
docker run --rm -i --link mysql-test:mysql mysql-toolbox dump > dumps/test-from-dump-all-databases-stdout.sql

docker run --rm -i -e MYSQL_DATABASE=bwah \
       -e MYSQL_DATABASE_1=wordpress:wordpress \
       -e MYSQL_DATABASE_2=wordpress2:wordpress2 \
       -e MYSQL_DATABASE_3=no_owner \
       -e MYSQL_DATABASE_4=another \
       -v "${pwd}/dumps":/srv \
       --link mysql-test:mysql \
       mysql-toolbox dump /srv

docker run --rm -i -e MYSQL_DATABASE=bwah \
       -e MYSQL_DATABASE_1=wordpress:wordpress \
       -e MYSQL_DATABASE_2=wordpress2:wordpress2 \
       -e MYSQL_DATABASE_3=no_owner \
       -e MYSQL_DATABASE_4=another \
       -v "${pwd}/dumps":/srv \
       --link mysql-test:mysql \
       mysql-toolbox dump > dumps/multiple-dbs-one-file.sql
