FROM wordpress:php7.2-fpm-alpine

MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

RUN apk add --update --no-cache zlib-dev \
    && docker-php-ext-install zip pdo pdo_mysql

# Set some php preferences
RUN { \
        echo 'upload_max_filesize = 64M'; \
    } > /usr/local/etc/php/conf.d/wordpress-prefs.ini
