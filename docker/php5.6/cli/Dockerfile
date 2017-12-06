FROM wordpress:cli-php5.6

MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

USER root

RUN apk add --update --no-cache zlib-dev \
    && docker-php-ext-install zip pdo pdo_mysql

USER www-data
