FROM wordpress:php5.6-fpm

MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

RUN apt-get update -q \
    && apt-get install -y -q zlib1g-dev \
    docker-php-ext-install zip pdo pdo_mysql
