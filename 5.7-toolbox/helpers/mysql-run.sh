#!/usr/bin/env bash

tempSqlFile="${1}"
input="${2}"

if [ "$input" = "" ]; then
  input="-"
fi

if [ ! "${MYSQL_DATABASE}" ]; then
  echo "When running SQL you must specify the database to run against in MYSQL_DATABASE" >&2
  exit 1
fi

echo "USE ${MYSQL_DATABASE};" >> "${tempSqlFile}"
cat "${input}" >> "${tempSqlFile}"
