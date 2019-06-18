FROM php:7.1-apache

# Setup environment for WordPress and Tools (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
                # Install ssmtp
                ssmtp \
                # Install unzip
                unzip \
	; \
	\
	docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr; \
	docker-php-ext-install \
		bcmath \
		exif \
		gd \
		mysqli \
		opcache \
		zip \
                # Install PDO
                pdo pdo_mysql \
	; \
	pecl install imagick-3.4.4; \
	docker-php-ext-enable imagick; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark; \
	ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
		| awk '/=>/ { print $3 }' \
		| sort -u \
		| xargs -r dpkg-query -S \
		| cut -d: -f1 \
		| sort -u \
		| xargs -rt apt-mark manual; \
	\
#	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/* ; \
        # Enable mod rewrite and expires apache modules
        a2enmod rewrite expires

# Install memcache            
RUN apt-get update && apt-get install -y libz-dev libmemcached-dev && rm -rf /var/lib/apt/lists/* \
    && curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz ;

# Install and configure modsecurity
RUN apt-get update && apt-get install -y libapache2-modsecurity && rm -rf /var/lib/apt/lists/* \
    && a2enmod security2 \
    && cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecRuleEngine DetectionOnly|SecRuleEngine On|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecResponseBodyAccess On|SecResponseBodyAccess Off|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecStatusEngine On|SecStatusEngine Off|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecRequestBodyLimit 13107200|SecRequestBodyLimit 67108864|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecRequestBodyNoFilesLimit 13107200|SecRequestBodyNoFilesLimit 67108864|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecRequestBodyInMemoryLimit 13107200|SecRequestBodyInMemoryLimit 67108864|g"  /etc/modsecurity/modsecurity.conf


# Setup php.ini settings
COPY ini/*.ini /usr/local/etc/php/conf.d/

# Copy additional apache2 config files
COPY apache-conf/* /etc/apache2/mods-available/

# Install wordpress
RUN set -ex; \
	curl -s -o wordpress.tar.gz -fSL "https://en-gb.wordpress.org/wordpress-5.2.1-en_GB.tar.gz"; \
	echo "02e382ac8bad4ebb18a2c6c7fe94453aeddfc18d *wordpress.tar.gz" | sha1sum -c -; \
	tar -xzf wordpress.tar.gz -C /usr/src/; \
        mv /usr/src/wordpress/* /var/www/html/ ; \
	rm wordpress.tar.gz; \
        rm wp-config-sample.php

# Add htaccess and config
COPY .htaccess wp-config.php ./

# Copy scripts
COPY scripts/* /usr/local/bin/

# Setup file permissions
RUN mkdir /var/www/html/settings ; \
    mkdir /var/www/html/wp-content/uploads ; \
    echo "Deny from all" > /var/www/html/settings/.htaccess ; \
    echo "Deny from all" > /var/www/html/wp-content/uploads/.htaccess ; \
    chown -R www-data:www-data /var/www/html ; \
    find /var/www/html -type d -exec chmod 750 {} \; ; \
    find /var/www/html -type f -exec chmod 640 {} \;

# Define volumes for persistent data
VOLUME /var/www/html/wp-content
VOLUME /var/www/html/settings

ENTRYPOINT ["docker-entrypoint"]
CMD ["apache2-foreground"]
