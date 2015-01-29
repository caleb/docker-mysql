#!/usr/bin/env bash
set -e
shopt -s globstar

export PHP_FPM_USERNAME
export PHP_FPM_GROUPNAME
export PHP_FPM_PORT
export PHP_FPM_MAX_CHILDREN
export PHP_FPM_START_SERVERS
export PHP_FPM_MIN_SPARE_SERVERS
export PHP_FPM_MAX_SPARE_SERVERS

: ${PHP_FPM_UID:=1000}
: ${PHP_FPM_GID:=1000}
: ${PHP_FPM_USERNAME:=php-fpm}
: ${PHP_FPM_GROUPNAME:=php-fpm}
: ${PHP_FPM_PORT:=9000}
: ${PHP_FPM_MAX_CHILDREN:=5}
: ${PHP_FPM_START_SERVERS=2}
: ${PHP_FPM_MIN_SPARE_SERVERS:=1}
: ${PHP_FPM_MAX_SPARE_SERVERS=3}

groupadd -g $PHP_FPM_GID $PHP_FPM_GROUPNAME
useradd -u $PHP_FPM_UID -g $PHP_FPM_GROUPNAME $PHP_FPM_USERNAME

# Fill out the templates
for f in /usr/local/etc/**/*.mo; do
  /usr/local/bin/mo "${f}" > "${f%.mo}"
  rm "${f}"
done

exec "$@"
