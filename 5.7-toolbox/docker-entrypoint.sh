#!/usr/bin/env bash
shopt -s globstar

# Find the mysql container
MYSQL_CONTAINER_NAME=$(perl -e 'foreach (sort keys %ENV) { print $1 if $_ =~ /(.*)_ENV_MYSQL_ROOT_PASSWORD/; }' 2>/dev/null)
MYSQL_HOST_NAME=${MYSQL_CONTAINER_NAME,,}
MYSQL_ROOT_PASSWORD_VAR="${MYSQL_CONTAINER_NAME}_ENV_MYSQL_ROOT_PASSWORD"
MYSQL_ROOT_PASSWORD="${!MYSQL_ROOT_PASSWORD_VAR}"

if [ ! "${MYSQL_HOST_NAME}" ]; then
  echo "You must link your mysql container to this container." >&2
  exit 1
fi

# Log in to mysql
cat > ~/.my.cnf <<EOF
[client]
host=${MYSQL_HOST_NAME}
user=root
password="${MYSQL_ROOT_PASSWORD}"
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

  echo -n "." >&2
  sleep 1
done

#
# Set up some common environment variables
#
[ "${MYSQL_DATABASE}" ] && export MYSQL_DATABASE_DEFAULT="${MYSQL_DATABASE}"
[ "${MYSQL_USER}" ] && export MYSQL_USER_DEFAULT="${MYSQL_USER}"
[ "${MYSQL_IMPORT}" ] && export MYSQL_IMPORT_DEFAULT="${MYSQL_IMPORT}"

case "${1}" in
  # Initializes a database by creating users and databases
  initialize)
    sqlFile=/tmp/initialize.sql

    # Remove user declarations that already exist
    for user_var in ${!MYSQL_USER_*}; do
      user="${!user_var}"
      username="${user%%:*}"

      count=$(mysql -s -e "SELECT COUNT(*) FROM mysql.user WHERE User='${username}';" --skip-column-names 2> /dev/null)

      if [ $count -gt 0 ]; then
        echo "User \"${username}\" already exists..." >&2
        unset "${user_var}"
      fi
    done

    # Remove database declarations of databases that already exist
    for database_var in ${!MYSQL_DATABASE_*}; do
      database="${!database_var}"
      database_name="${database%%:*}"
      database_user="${database#*:}"

      if [ "${#database_user}" -eq "${#database}" ]; then
        database_user="${MYSQL_USER:-root}"
      fi

      if mysqlshow "${database_name}" > /dev/null 2>&1; then
        echo "Skipping initialization for database \"${database_name}\", database already exists" >&2
        unset "${database_var}"

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
    sqlFile=/tmp/reinitialize.sql

    # Build our commands to initialize this database cluster
    /helpers/mysql-drop-users.sh "${sqlFile}"
    /helpers/mysql-drop-databases.sh "${sqlFile}"
    /helpers/mysql-create-users.sh "${sqlFile}"
    /helpers/mysql-create-databases.sh "${sqlFile}"
    /helpers/mysql-import-data.sh "${sqlFile}"

    # Run the sql file
    mysql -s < "${sqlFile}"
    ;;

  run)
    sqlFile=/tmp/run.sql
    /helpers/mysql-run.sh "${sqlFile}" "${2}"

    mysql -s < "${sqlFile}"
    ;;

  dump)
    /helpers/mysql-dump.sh "${2}"

    ;;
  *)
    exec "$@"
    ;;
esac
