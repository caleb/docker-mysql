#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Creates the databases and grants permissions
#
for database_var in ${!MYSQL_DATABASE_*}; do
  database="${!database_var}"

  if [ -n "${database}" ]; then
    database_name="${database%%:*}"

    # escape the wildcard characters in the database name
    database_name_escaped=${database_name//_/\\_};
    database_name_escaped=${database_name_escaped//*/\\*};
    database_name_escaped=${database_name_escaped//%/\\%};
    database_name_escaped=${database_name_escaped//?/\\?};

    if mysqlshow "${database_name_escaped}" > /dev/null 2>&1; then
      echo "Dropping database \"${database_name}\"..." >&2

      if [ "$database_name" ]; then
        echo "DROP DATABASE IF EXISTS \`$database_name\` ;" >> "$tempSqlFile"
      fi
    fi
  fi
done
