#!/usr/bin/env bash

output="${1}"

databases=()

for database_var in ${!MYSQL_DATABASE_*}; do
  database="${!database_var}"

  if [ -n "${database}" ]; then
    database_name="${database%%:*}"

    if [ "$database_name" ]; then
      databases+=("${database_name}")
    fi
  fi
done

if [ ${#databases} -eq 0 ]; then
  # read the databases from mysql since the user didn't specify any
  out=$(mysql -s --skip-column-names -e 'show databases;' 2> /dev/null)
  for database in $out; do
    if [ "${database}" != "mysql" ] \
         && [ "${database}" != "performance_schema" ]  \
         && [ "${database}" != "information_schema" ]; then
      databases+=($database)
    fi
  done
fi

if [ ${#databases} -gt 0 ]; then
  if [ ! -d "${output}" ] || [ "$output" = "-" ] || [ -z "$output" ]; then
    echo "Dumping databases ${databases[@]}..." >&2

    if [ "${output}" = "-" ] || [ -z "$output" ]; then
      mysqldump --databases "${databases[@]}"
    else
      mysqldump --databases "${databases[@]}" > "${output}"
    fi
  else
    # We are dumping to a directory, make one file for each database
    for database in "${databases[@]}"; do
      echo "Dumping database \"${database}\"..." >&2

      if [ "$database" ]; then
        dest="${output}/${database}.sql"

        mysqldump "${database}" >> "${dest}"
      fi
    done
  fi
else
  # we are dumping all the databases
  if [ "$outout" = "-" ] || [ -z "$output" ]; then
    mysqldump --all-databases
  else
    mysqldump --all-databases > "${output}"
  fi
fi
