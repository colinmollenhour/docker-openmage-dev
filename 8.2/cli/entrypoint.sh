#!/bin/bash
set -e

[ "$DEBUG" = "true" ] && set -x

if [ "$ENABLE_CRON" == "true" ]; then
  # Get rsyslog running for cron output
  CRON_LOG=/var/log/cron.log
  touch $CRON_LOG
  echo "cron.* $CRON_LOG" > /etc/rsyslog.d/cron.conf
  service rsyslog start
fi

# Configure Xdebug
if [ "$XDEBUG_CONFIG" ]; then
    echo "" > /usr/local/etc/php/conf.d/zz-xdebug.ini
    for config in $XDEBUG_CONFIG; do
        echo "xdebug.$config" >> /usr/local/etc/php/conf.d/zz-xdebug.ini
    done
fi


# Execute the supplied command
exec "$@"
