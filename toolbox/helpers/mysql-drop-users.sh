#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Creates the databases and grants permissions
#
for user_var in ${!MYSQL_USER_*}; do
  user="${!user_var}"

  if [ -n "${user}" ]; then
    username="${user%%:*}"

    if [ "$username" ]; then
      count=$(mysql -s -e "SELECT COUNT(*) FROM mysql.user WHERE User='${username}';" --skip-column-names 2> /dev/null)

      # If the user exists, then drop them
      if [ $count -gt 0 ]; then
        echo "Dropping user \"${username}\"..." >&2

        echo "GRANT USAGE ON *.* TO \`$username\` ;" >> "$tempSqlFile"
        echo "DROP USER \`$username\` ;" >> "$tempSqlFile"
      fi
    fi
  fi
done
