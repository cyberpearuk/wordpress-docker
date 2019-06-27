FROM cyberpearuk/wordpress-docker:2

RUN apt-get update && apt-get install -y --no-install-recommends \
        nano \
    && rm -rf /var/lib/apt/lists/*

# Xdebug
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug \
    && touch /var/log/xdebug.log && chmod 777 /var/log/xdebug.log \
    && mkdir /var/log/xdebug-profiler && chmod 777 /var/log/xdebug-profiler

# Setup php.ini settings
COPY *.ini /usr/local/etc/php/conf.d/