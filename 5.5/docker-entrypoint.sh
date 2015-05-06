#!/usr/bin/env bash

# For now just run the command passed to our setup. In the future we might allow
# configuration of mysql through environment variables
exec /base-entrypoint.sh "${@}"
