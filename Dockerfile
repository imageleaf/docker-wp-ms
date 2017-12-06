FROM wordpress:cli-php7.1

RUN apk add --update --no-cache zlib-dev \
    docker-php-ext-install zip pdo pdo_mysql
