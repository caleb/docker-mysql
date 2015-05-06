#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Add/reconfigures users specified in the environment
#
for user_var in ${!MYSQL_USER_*}; do
  user=${!user_var}

  if [ -n "${user}" ]; then
    username="${user%%:*}"
    password="${user#*:}"

    if [ "$username" -a "$password" ]; then
      count=$(mysql -s -e "SELECT COUNT(*) FROM mysql.user WHERE User='${username}';" --skip-column-names 2> /dev/null)

      if [ $count -gt 0 ]; then
        # If the user already exists, update their password
        echo "Updating user ${username}..." >&2
		    echo "ALTER USER '$username'@'%' IDENTIFIED BY '$password' ;" >> "$tempSqlFile"
      else
        # If the user doesn't exist, create them
        echo "Adding user ${username}..." >&2
		    echo "CREATE USER '$username'@'%' IDENTIFIED BY '$password' ;" >> "$tempSqlFile"
      fi
	  fi
  fi
done
