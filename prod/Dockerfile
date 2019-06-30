FROM php:7.1-apache

# Install and configure modsecurity
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends libapache2-modsecurity git \
    && git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs \
    && cp /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf \
    && apt-get purge -y git && apt-get -y autoremove  \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod security2 \
    && cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecRuleEngine DetectionOnly|SecRuleEngine On|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecResponseBodyAccess On|SecResponseBodyAccess Off|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecStatusEngine On|SecStatusEngine Off|g"  /etc/modsecurity/modsecurity.conf \
    # Set memory limit to ~64MB
    && sed -i "s|SecRequestBodyLimit 13107200|SecRequestBodyLimit 67108864|g"  /etc/modsecurity/modsecurity.conf \
    # Fix for "ModSecurity: Request body no files data length is larger than the configured limit"
    && sed -i "s|SecRequestBodyNoFilesLimit 131072|SecRequestBodyNoFilesLimit 524288|g"  /etc/modsecurity/modsecurity.conf \
    && sed -i "s|SecRequestBodyInMemoryLimit 13107200|SecRequestBodyInMemoryLimit 524288|g"  /etc/modsecurity/modsecurity.conf \
    ## Fix "Execution error - PCRE limits exceeded" by increasing to 5MB - however this can make it easier to DDOS
    && echo "SecPcreMatchLimit 5242880" >> /etc/modsecurity/modsecurity.conf \
    && echo "SecPcreMatchLimitRecursion 5242880" >> /etc/modsecurity/modsecurity.conf

# Setup environment for WordPress and Tools (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN apt-get update && apt-get install -y --no-install-recommends \
        libjpeg-dev \
        libmagickwand-dev \
        libpng-dev \
        # Install ssmtp
        ssmtp \
        # Install unzip
        unzip \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install \
		bcmath \
		exif \
		gd \
		mysqli \
		opcache \
		zip \
                # Install PDO
                pdo pdo_mysql \
    && pecl install imagick-3.4.4  \
    && docker-php-ext-enable imagick \
    && a2enmod rewrite expires       

# Setup php.ini settings
COPY ini/*.ini /usr/local/etc/php/conf.d/

# Copy additional apache2 config files
COPY apache-conf/* /etc/apache2/mods-available/

# Install wordpress
RUN set -ex; \
	curl -s -o wordpress.tar.gz -fSL "https://en-gb.wordpress.org/wordpress-5.2.2-en_GB.tar.gz"; \
	echo "1f3af9172a9f2b89df784d547b215ea3a067f45e *wordpress.tar.gz" | sha1sum -c -; \
	tar -xzf wordpress.tar.gz -C /usr/src/; \
        mv /usr/src/wordpress/* /var/www/html/ ; \
	rm wordpress.tar.gz; \
        rm wp-config-sample.php

# Install tools
RUN curl -sS https://getcomposer.org/installer | php \
  && chmod +x composer.phar \
  && php composer.phar global require cyberpearuk/wp-db-tools:1.3.0 \
  # Remove composer now, we shouldn't need it after this
  && rm composer.phar
ENV PATH="/root/.composer/vendor/bin:${PATH}"

# Add htaccess and config
COPY .htaccess wp-config.php ./

# Copy scripts
COPY scripts/* /usr/local/bin/

# Setup file permissions
RUN mkdir /var/www/html/settings ; \
    mkdir /var/www/html/wp-content/uploads ; \
    echo "Deny from all" > /var/www/html/settings/.htaccess ; \
    chown -R www-data:www-data /var/www/html ; \
    find /var/www/html -type d -exec chmod 750 {} \; ; \
    find /var/www/html -type f -exec chmod 640 {} \;

# Define volumes for persistent data
VOLUME /var/www/html/wp-content
VOLUME /var/www/html/settings

ENTRYPOINT ["docker-entrypoint"]
CMD ["apache2-foreground"]
