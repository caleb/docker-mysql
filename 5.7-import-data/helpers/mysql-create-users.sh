#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Add users specified in the environment
#
for user_var in ${!MYSQL_USER_*}; do
  user=${!user_var}
  username="${user%%:*}"
  password="${user#*:}"

  echo "Adding user ${username}..."

  if [ "$username" -a "$password" ]; then
		echo "CREATE USER '$username'@'%' IDENTIFIED BY '$password' ;" >> "$tempSqlFile"
	fi
done
