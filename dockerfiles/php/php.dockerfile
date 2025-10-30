FROM php:8.4-fpm-alpine

WORKDIR /var/www/html

COPY wormhole-systems .
#COPY dockerfiles/php/php.ini /usr/local/etc/php/conf.d/custom.ini

RUN apk add --no-cache \
    supervisor \
    # Needed for the sockets extension \
    linux-headers \
    # Needed to build the Redis extension \
    autoconf \
    build-base \
    # Other dependencies \
    libzip-dev \
    nodejs \
    npm

RUN docker-php-ext-install \
    pcntl \
    pdo  \
    pdo_mysql \
    sockets \
    zip

RUN pecl install redis && docker-php-ext-enable redis

RUN chown -R www-data:www-data /var/www/html
