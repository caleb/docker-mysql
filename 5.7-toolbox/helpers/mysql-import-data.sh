#!/usr/bin/env bash

tempSqlFile="${1}"

for import_var in ${!MYSQL_IMPORT_*}; do
  import="${!import_var}"

  if [ -n "${import}" ]; then
    file="${import%%:*}"
    database="${import#*:}"

    if [ "${#file}" -eq "${#import}" ]; then
      database="${MYSQL_DATABASE}"
    fi

    if [ "${file}" = "-" ]; then
      echo "Importing stdin into \"${database}\"" >&2

      echo "USE \`${database}\`;" >> "$tempSqlFile"
      cat >> "$tempSqlFile"
    elif [ -f "${file}" -a "${database}" ]; then
      echo "Importing \"${file}\" into \"${database}\"..." >&2

      echo "USE \`${database}\`;" >> "$tempSqlFile"
      cat "${file}" >> "$tempSqlFile"
    fi
  fi
done
