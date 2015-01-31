#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Creates the databases and grants permissions
#
for database_var in ${!MYSQL_DATABASE_*}; do
  database="${!database_var}"

  if [ -n "${database}" ]; then
    database_name="${database%%:*}"

    if mysqlshow "${database_name}" > /dev/null 2>&1; then
      echo "Dropping database \"${database_name}\"..." >&2

      if [ "$database_name" ]; then
        echo "DROP DATABASE \`$database_name\` ;" >> "$tempSqlFile"
      fi
    fi
  fi
done
