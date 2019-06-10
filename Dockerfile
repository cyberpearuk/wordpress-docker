FROM wordpress:5-php7.1-apache

# Add ssmtp
RUN apt-get update \
 && apt-get install -y \
    ssmtp \
    unzip \
    libz-dev libmemcached-dev  \
 && rm -rf /var/lib/apt/lists/*

# Add pdo
RUN docker-php-ext-install pdo pdo_mysql

RUN pecl install memcached \
 && echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini

ADD test-sendmail.sh /usr/local/bin/test-sendmail
ADD docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper

ENTRYPOINT ["docker-entrypoint-wrapper"]
CMD ["apache2-foreground"]
