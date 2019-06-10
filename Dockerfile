FROM wordpress:5-php7.1-apache

# Add ssmtp
RUN apt-get update \
 && apt-get install -y \
    ssmtp \
    unzip \
 && rm -rf /var/lib/apt/lists/*

# Add pdo
RUN docker-php-ext-install pdo pdo_mysql

# Install memcach
RUN apt-get update \
 && apt-get install -y \
    libz-dev libmemcached-dev  \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

ADD test-sendmail.sh /usr/local/bin/test-sendmail
ADD docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper

ENTRYPOINT ["docker-entrypoint-wrapper"]
CMD ["apache2-foreground"]
