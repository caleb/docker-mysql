#!/usr/bin/env bash
shopt -s globstar

if [ ! "${MYSQL_ADDR}" ]; then
  echo "You must link your mysql container to this container as \"mysql\""
  exit 1
fi

# wait for mysql server to start (max 30 seconds)
timeout=30
echo -n "Waiting for database server to accept connections"
while ! mysqladmin -uroot -p"${MYSQL_ENV_MYSQL_ROOT_PASSWORD}" -hmysql status >/dev/null 2>&1
do
  timeout=$(($timeout - 1))
  if [ $timeout -eq 0 ]; then
    echo -e "\nCould not connect to database server. Aborting..."
    exit 1
  fi
  echo -n "."
  sleep 1
done

case "${1}" in
  #
  initialize)
    number_of_tables=$(mysql -s -N -uroot -pmozart -e "SELECT COUNT(DISTINCT \`table_name\`) FROM \`information_schema\`.\`columns\` WHERE \`table_schema\` = '#{database}'")
    ;;

  import)
    echo 'hi'
    ;;

  *)
    exec "$@"
    ;;
esac






# TODO read this from the MySQL config?
DATADIR='/var/lib/mysql'

if [ "${1:0:1}" = '-' ]; then
	set -- mysqld "$@"
fi

#
# Initialize mysql if it hasn't already been initialized and our command is mysqld
# This is taken from mysql:5.7 (https://github.com/docker-library/mysql/blob/master/5.7/docker-entrypoint.sh)
#
if [ ! -d "$DATADIR/mysql" -a "${1%_safe}" = 'mysqld' ]; then
	if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
		echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
		echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
		exit 1
	fi

	echo 'Running mysql_install_db ...'
	mysql_install_db --datadir="$DATADIR" --mysqld-file="$(which mysqld)"
	echo 'Finished mysql_install_db'

	# These statements _must_ be on individual lines, and _must_ end with
	# semicolons (no line breaks or comments are permitted).
	# TODO proper SQL escaping on ALL the things D:

	tempSqlFile='/tmp/mysql-first-time.sql'
	cat > "$tempSqlFile" <<-EOSQL
		DELETE FROM mysql.user ;
		CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
		GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
		DROP DATABASE IF EXISTS test ;
	EOSQL

	if [ "$MYSQL_DATABASE" ]; then
    export MYSQL_DATABASE_DEFAULT="${MYSQL_DATABASE}"
	fi

	if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
    export MYSQL_USER_DEFAULT="${MYSQL_USER}:${MYSQL_PASSWORD}"
  fi

  if [ "$MYSQL_IMPORT" -a "$MYSQL_DATABASE" ]; then
    export MYSQL_IMPORT_DEFAULT="${MYSQL_IMPORT}"
  fi

  /helpers/mysql-create-users.sh      "$tempSqlFile"
  /helpers/mysql-create-databases.sh  "$tempSqlFile"
  /helpers/mysql-import-data.sh       "$tempSqlFile"

  set -- "$@" --init-file="$tempSqlFile"
fi

# Fill out the templates
# for f in /usr/local/etc/**/*.mo; do
#   /usr/local/bin/mo "${f}" > "${f%.mo}"
#   rm "${f}"
# done

chown -R mysql:mysql "$DATADIR"
exec "$@"
