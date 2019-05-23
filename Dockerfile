FROM wordpress:5-php7.1-apache

# Add ssmtp
RUN apt-get update \
 && apt-get install -y ssmtp unzip \
 && rm -rf /var/lib/apt/lists/*


ADD docker-entrypoint-wrapper.sh /usr/local/bin/docker-entrypoint-wrapper
ADD test-sendmail.sh /usr/local/bin/test-sendmail


RUN chmod +x /usr/local/bin/docker-entrypoint-wrapper \
 && chmod +x /usr/local/bin/test-sendmail


ENTRYPOINT ["docker-entrypoint-wrapper"]
CMD ["apache2-foreground"]
