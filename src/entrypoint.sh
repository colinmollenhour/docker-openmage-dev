<?php echo "#!/bin/bash\n" ?>
set -e

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

# Configure Xdebug
if [ "$XDEBUG_CONFIG" ]; then
    echo "" > /usr/local/etc/php/conf.d/zz-xdebug.ini
    for config in $XDEBUG_CONFIG; do
        echo "xdebug.$config" >> /usr/local/etc/php/conf.d/zz-xdebug.ini
    done
fi

<?php if ($flavour === 'fpm'): ?>
# Configure PHP-FPM using environment variables
if test -f /usr/local/etc/php-fpm.d/www.conf.template && ! test -f /usr/local/etc/php-fpm.d/www.conf; then
    export PM_MAX_CHILDREN=${PM_MAX_CHILDREN:-5}
    export PM_START_SERVERS=${PM_START_SERVERS:-2}
    export PM_MIN_SPARE_SERVERS=${PM_MIN_SPARE_SERVERS:-1}
    export PM_MAX_SPARE_SERVERS=${PM_MAX_SPARE_SERVERS:-3}
    while read -r line; do eval echo \"$line\"; done < /usr/local/etc/php-fpm.d/www.conf.template > /usr/local/etc/php-fpm.d/www.conf
fi
<?php elseif ($flavour === 'frankenphp'): ?>
# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
        set -- frankenphp run "$@"
fi
<?php endif ?>

# Execute the supplied command
exec "$@"
