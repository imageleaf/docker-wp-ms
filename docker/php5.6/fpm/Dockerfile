FROM wordpress:php5.6-fpm

MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

RUN apt-get update -q \
    && apt-get install -y -q zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-install zip pdo pdo_mysql

# Set some php preferences
RUN { \
        echo 'upload_max_filesize = 64M'; \
    } > /usr/local/etc/php/conf.d/wordpress-prefs.ini
