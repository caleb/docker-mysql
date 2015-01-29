; This file was initially adapated from the output of: (on PHP 5.6)
;   grep -vE '^;|^ *$' /usr/local/etc/php-fpm.conf.default

[global]

error_log = /proc/self/fd/2
daemonize = no

[www]

; if we send this to /proc/self/fd/1, it never appears
access.log = /proc/self/fd/2

user = {{PHP_FPM_USERNAME}}
group = {{PHP_FPM_GROUPNAME}}

listen = [::]:{{PHP_FPM_PORT}}

pm = dynamic
pm.max_children = {{PHP_FPM_MAX_CHILDREN}}
pm.start_servers = {{PHP_FPM_START_SERVERS}}
pm.min_spare_servers = {{PHP_FPM_MIN_SPARE_SERVERS}}
pm.max_spare_servers = {{PHP_FPM_MAX_SPARE_SERVERS}}
