#!/usr/bin/env bash
shopt -s globstar

. /helpers/links.sh

function initialize() {
  require_mysql=${1:-true}

  read-link MYSQL mysql 3306 tcp $require_mysql

  # If we found the container, write our credentials to the ~/.my.cnf file and wait to connect
  if [ -n "${MYSQL_ADDR}" ] && [ -n "${MYSQL_ENV_MYSQL_ROOT_PASSWORD}" ]; then
    # Log in to mysql
    cat > ~/.my.cnf <<EOF
[client]
host=${MYSQL_ADDR}
user=root
password="${MYSQL_ENV_MYSQL_ROOT_PASSWORD}"
EOF

    # wait for mysql server to start (max 30 seconds)
    timeout=30
    while ! mysqladmin status >/dev/null 2>&1
    do
      timeout=$(($timeout - 1))
      if [ $timeout -eq 0 ]; then
        echo -e "\nCould not connect to database server. Aborting..." >&2
        exit 1
      fi

      if [ $timeout -eq 25 ]; then
        echo "Waiting for database server to accept connections..." >&2
      fi

      if [ $timeout -lt 25 ]; then
        echo -n "." >&2
      fi

      sleep 1
    done
  fi
  #
  # Set up some common environment variables
  #
  [ "${MYSQL_DATABASE}" ] && export MYSQL_DATABASE__DEFAULT__="${MYSQL_DATABASE}"
  [ "${MYSQL_USER}" ]     && export MYSQL_USER__DEFAULT__="${MYSQL_USER}"
  [ "${MYSQL_IMPORT}" ]   && export MYSQL_IMPORT__DEFAULT__="${MYSQL_IMPORT}"
}

case "${1}" in
  # Initializes a database by creating users and databases
  initialize)
    initialize

    sqlFile=/tmp/initialize.sql

    # Flush before initializing
    echo 'FLUSH PRIVILEGES;' > "$sqlFile"

    # Remove database declarations of databases that already exist
    for database_var in ${!MYSQL_DATABASE_*}; do
      database="${!database_var}"
      database_name="${database%%:*}"

      # escape the wildcard characters in the database name
      database_name_escaped=${database_name//_/\\_};
      database_name_escaped=${database_name_escaped//\*/\\*};
      database_name_escaped=${database_name_escaped//%/\\%};
      database_name_escaped=${database_name_escaped//\?/\\?};

      if mysqlshow "${database_name_escaped}" > /dev/null 2>&1; then
        # Remove imports for databases that already exist
        for import_var in ${!MYSQL_IMPORT_*}; do
          import="${!import_var}"
          file="${import%%:*}"
          import_database="${import#*:}"

          if [ "${#import_database}" -eq "${#import}" ]; then
            if [ "${MYSQL_DATABASE}" ]; then
              import_database="${MYSQL_DATABASE}"
            else
              echo "You specified an import (${file}) without a database and didn't specify a default database in MYSQL_DATABASE" >&2
              exit 1
            fi
          fi

          if [ "${import_database}" = "${database_name}" ]; then
            echo "Skipping initialization for database \"${database_name}\", database already exists" >&2
            unset "${import_var}"
          fi
        done
      fi
    done

    # Build our commands to initialize this database cluster
    /helpers/mysql-create-users.sh "${sqlFile}"
    /helpers/mysql-create-databases.sh "${sqlFile}"
    /helpers/mysql-import-data.sh "${sqlFile}"

    # Run the sql file
    mysql -s < "${sqlFile}"
    ;;

  reinitialize)
    initialize

    sqlFile=/tmp/reinitialize.sql

    # Drop existing databases/users
    echo 'FLUSH PRIVILEGES;' > "$sqlFile"
    /helpers/mysql-drop-users.sh "${sqlFile}"
    /helpers/mysql-drop-databases.sh "${sqlFile}"
    # Run the deletions
    mysql -s < "${sqlFile}"

    # Create and import users/databases/data
    echo 'FLUSH PRIVILEGES;' > "$sqlFile"
    /helpers/mysql-create-users.sh "${sqlFile}"
    /helpers/mysql-create-databases.sh "${sqlFile}"
    /helpers/mysql-import-data.sh "${sqlFile}"
    # Run the sql file
    mysql -s < "${sqlFile}"
    ;;

  run)
    initialize

    /helpers/mysql-run.sh "${2}"
    ;;

  dump)
    initialize

    /helpers/mysql-dump.sh "${2}"

    ;;
  *)
    # Don't require a mysql link when running arbitrary commands
    initialize false

    exec "$@"
    ;;
           esac
