FROM <?php printf("php:%s-%s", $version, $flavour) ?>

ENV PHP_EXT_APCU_VERSION="<?php echo $php_ext_acpu_version ?>"
ENV PHP_EXT_REDIS_VERSION="<?php echo $php_ext_redis_version ?>"
ENV PHP_EXT_XDEBUG_VERSION="<?php echo $php_ext_xdebug_version ?>"

<?php $buildPackages = ['libpng-dev', 'libfreetype6-dev', 'libjpeg62-turbo-dev', 'libxml2-dev', 'libxslt1-dev', 'sendmail-bin', 'sendmail', 'libicu-dev', 'libssl-dev'] ?>
<?php $installLibZip = version_compare($version, '7.3', '>=') ?>
<?php $installOniguruma = version_compare($version, '7.4', '>=') ?>
<?php $gdNeedsDirs = version_compare($version, '7.4', '<') ?>
<?php if ($installLibZip): $buildPackages[] = 'libzip-dev'; endif ?>
<?php if ($installOniguruma): $buildPackages[] = 'libonig-dev'; endif ?>

RUN build_packages="<?php echo implode(' ', $buildPackages) ?>" \
    && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y $build_packages \
    && yes "" | pecl install apcu-$PHP_EXT_APCU_VERSION && docker-php-ext-enable apcu \
    && docker-php-ext-install ftp \
    && docker-php-ext-configure gd <?php if ($gdNeedsDirs): ?>--with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/<?php else: ?>--with-freetype --with-jpeg<?php endif; ?> \
    && docker-php-ext-install gd \
    && docker-php-ext-install mbstring \
    && echo "no" | pecl -q install redis-$PHP_EXT_REDIS_VERSION && docker-php-ext-enable redis \
    && docker-php-ext-install pcntl \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-install soap \
    && yes | pecl -q install xdebug-$PHP_EXT_XDEBUG_VERSION && docker-php-ext-enable xdebug \
    && docker-php-ext-install xsl \
    && docker-php-ext-install zip \
    && docker-php-ext-install intl \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY php.ini /usr/local/etc/php/conf.d/zz-magento.ini

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
