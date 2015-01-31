#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Creates the databases and grants permissions
#
for database_var in ${!MYSQL_DATABASE_*}; do
  database="${!database_var}"

  if [ -n "${database}" ]; then
    database_name="${database%%:*}"
    database_owner="${database#*:}"

    # if an owner isn't specified use MYSQL_USER
    if [ ${#database_owner} -eq ${#database} ]; then
      database_owner=${MYSQL_USER}
    fi

    echo "Creating database \"${database_name}\" owned by \"${database_owner:-root}\"..." >&2

    if [ "$database_name" ]; then
      echo "CREATE DATABASE IF NOT EXISTS \`$database_name\` ;" >> "$tempSqlFile"

	    if [ "$database_owner" ]; then
		    echo "GRANT ALL ON \`$database_name\`.* TO '$database_owner'@'%' ;" >> "$tempSqlFile"
	    fi
    fi
  fi
done

echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"
