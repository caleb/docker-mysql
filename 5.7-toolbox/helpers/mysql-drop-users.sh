#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Creates the databases and grants permissions
#
for user_var in ${!MYSQL_USER_*}; do
  user="${!user_var}"

  if [ -n "${user}" ]; then
    user_name="${user%%:*}"

    echo "Dropping user \"${user_name}\"..." >&2

    if [ "$user_name" ]; then
      echo "GRANT USAGE ON *.* TO \`$user_name\` ;" >> "$tempSqlFile"
      echo "DROP USER \`$user_name\` ;" >> "$tempSqlFile"
    fi
  fi
done
