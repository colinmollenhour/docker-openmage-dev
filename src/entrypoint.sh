<?php echo "#!/bin/bash\n" ?>

[ "$DEBUG" = "true" ] && set -x

<?php if (!empty($include_cron)): ?>
if [ "$ENABLE_CRON" == "true" ]; then
  # Get rsyslog running for cron output
  CRON_LOG=/var/log/cron.log
  touch $CRON_LOG
  echo "cron.* $CRON_LOG" > /etc/rsyslog.d/cron.conf
  service rsyslog start
fi
<?php endif; ?>

# Configure Sendmail if required
if [ "$ENABLE_SENDMAIL" == "true" ]; then
    /etc/init.d/sendmail start
fi

# Configure Xdebug
if [ "$XDEBUG_CONFIG" ]; then
    echo "" > /usr/local/etc/php/conf.d/zz-xdebug.ini
    for config in $XDEBUG_CONFIG; do
        echo "xdebug.$config" >> /usr/local/etc/php/conf.d/zz-xdebug.ini
    done
fi

# Configure PHP-FPM using environment variables
if test -f /usr/local/etc/php-fpm.d/www.conf.template && ! test -f /usr/local/etc/php-fpm.d/www.conf; then
    PM_MAX_CHILDREN=${PM_MAX_CHILDREN:-5} \
    PM_START_SERVERS=${PM_START_SERVERS:-2} \
    PM_MIN_SPARE_SERVERS=${PM_MIN_SPARE_SERVERS:-1} \
    PM_MAX_SPARE_SERVERS=${PM_MAX_SPARE_SERVERS:-3} \
    envsubst < /usr/local/etc/php-fpm.d/www.conf.template > /usr/local/etc/php-fpm.d/www.conf
fi

# Execute the supplied command
exec "$@"
