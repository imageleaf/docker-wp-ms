# Wordpress MultiSite Docker

Using this you can deploy wordpress multisite with docker

## Using the cron image

Add `WORDPRESS_CONFIG_EXTRA="define('DISABLE_WP_CRON', true);"` to the environment of the php-fpm container.
