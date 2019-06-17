# Custom WordPress Docker Image

Tailored docker image for running wordpress.

Comes with security steps built in.

## Environment Variables

### Mountable Environment Variables
This image supports the ability to load environment variables at startup from a predefined locations.

This allows loading shared/common settings from the host machine by mounting an external .env file to the required path `/var/common/.env`.

These are loaded in the entrypoint script at machine startup.

### Email Settings
- EMAIL_SMTP_HOST - Remote SMTP Server host name
- EMAIL_SMTP_PORT - Remote SMTP Port
- EMAIL_AUTH_USER - Remote SMTP Username
- EMAIL_AUTH_PASS - Remote SMTP User Password
- EMAIL_HOST - The host of the email

For my purposes TLS is on and not configurable out the box.

### Web Server
- VIRTUAL_HOST - The server host name (used for ServerName)


## Notes
### Sendmail

As this container was originally created to help support sending emails it includes a bash script `test-sendmail <email-address>`
 which will send a test email both via PHP but also sendmail directly (over bash CLI).

```bash
docker exec -it <container> test-sendmail me@mail.com
```
