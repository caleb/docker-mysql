#!/usr/bin/env bash

tempSqlFile="${1}"

#
# Run the import commands from the environment
#
for import_var in ${!MYSQL_IMPORT_*}; do
  import="${!import_var}"
  file="${import%%:*}"
  database="${import#*:}"

  if [ "${#file}" -eq "${#import}" ]; then
    database="${MYSQL_DATABASE}"
  fi

  if [ -f "${file}" -a "${database}" ]; then
    echo "Importing file \"${file}\" into database \"${database}\"..."

    echo "USE ${database};" >> "$tempSqlFile"
    cat "${file}" >> "$tempSqlFile"
  fi
done
