#!/usr/bin/env bash
set -euo pipefail

echo "Setting up"
echo ""

# Load shared environment variables
if test -f "/var/common/.env"; then
     while IFS="=" read PROP VAL; do
         # Check if environment variable doesn't exist before setting (prevent overwriting)
         test ! -z $(printenv $PROP) || export $PROP=$VAL
     done <<< $(grep -v '^$\|^\s*\#' /var/common/.env)
fi

## SETUP MAIL ##
echo "[mail function]
sendmail_path=/usr/sbin/ssmtp -t -i
" >> /usr/local/etc/php/conf.d/sendmail.ini

echo "
mailhub=$EMAIL_SMTP_HOST:$EMAIL_SMTP_PORT
rewriteDomain=$EMAIL_HOST
AuthUser=$EMAIL_AUTH_USER
AuthPass=$EMAIL_AUTH_PASS
AuthMethod=LOGIN
UseTLS=YES
UseSTARTTLS=YES
FromLineOverride=YES
" > /etc/ssmtp/ssmtp.conf

echo "root:$EMAIL_AUTH_USER:$EMAIL_SMTP_HOST:$EMAIL_SMTP_PORT" > /etc/ssmtp/revaliases

# Clear $EMAIL_AUTH_PASS to prevent leaking to applications
export EMAIL_AUTH_PASS=""

# Set ServerName - Prevents warnings
IFS=',' read -r FIRSTHOST OTHER_HOSTS <<< "$VIRTUAL_HOST"
echo "ServerName $FIRSTHOST" >> /etc/apache2/apache2.conf

# Execute original entrypoint from core wordpress docker image
exec docker-entrypoint.sh "$@"
