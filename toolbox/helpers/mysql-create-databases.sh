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
      database_owner="${MYSQL_USER%%:*}"
    fi


    if [ "$database_name" ]; then
      # escape the wildcard characters in the database name
      database_name_escaped=${database_name//_/\\_};
      database_name_escaped=${database_name_escaped//\*/\\*};
      database_name_escaped=${database_name_escaped//%/\\%};
      database_name_escaped=${database_name_escaped//\?/\\?};

      if mysqlshow "${database_name_escaped}" > /dev/null 2>&1; then
        # If the database already exists, update the permissions on it to match the newest configuration
        echo "Updating database \"${database_name}\" to owned by \"${database_owner:-root}\"..." >&2

        # Revoke all permissions to the database to set them later... does this revoke the root user's
        # permissions? We need to test this before using it.
		    # echo "REVOKE ALL PRIVILEGES ON \`$database_name\`.* FROM '%'@'%' ;" >> "$tempSqlFile"
      else
        echo "Creating database \"${database_name}\" owned by \"${database_owner:-root}\"..." >&2

        # If the database doesn't already exist, create it
        echo "CREATE DATABASE IF NOT EXISTS \`$database_name\` ;" >> "$tempSqlFile"
      fi

	    if [ "$database_owner" ]; then
		    echo "GRANT ALL ON \`$database_name\`.* TO '$database_owner'@'%' ;" >> "$tempSqlFile"
	    fi
    fi
  fi
done

echo 'FLUSH PRIVILEGES ;' >> "$tempSqlFile"
