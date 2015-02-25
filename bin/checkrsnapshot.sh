#!/bin/sh

readonly save_stdout=7
eval "exec $save_stdout>&1"

exec /usr/local/sbin/write-plugin-cache \
  /usr/local/lib/nagios/plugins/check_rsnapshot "$@"

