FROM cyberpearuk/wordpress-docker:2

RUN pecl install xdebug \
    && docker-php-ext-enable xdebug
RUN touch /var/log/xdebug.log && chmod 777 /var/log/xdebug.log
RUN mkdir /var/log/xdebug-profiler && chmod 777 /var/log/xdebug-profiler

# Setup php.ini settings
COPY *.ini /usr/local/etc/php/conf.d/