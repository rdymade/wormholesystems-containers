FROM composer:latest AS composer

FROM php:8.4-fpm-alpine

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apk add \
    --update \
    --no-cache \
    bash \
    git \
    curl \
    rsync \
    nodejs \
    npm \
    libzip-dev \
    zip \
    unzip \
    oniguruma-dev \
    autoconf \
    gcc \
    g++ \
    make \
    libxml2-dev \
    libcurl \
    curl-dev \
    icu-dev \
    icu-libs \
    linux-headers \
    musl-dev

# Install core extensions first
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mbstring \
    zip \
    bcmath \
    xml \
    curl \
    intl \
    pcntl \
    sockets

COPY wormhole-systems /var/www/html
WORKDIR /var/www/html

RUN composer install --no-interaction --prefer-dist --optimize-autoloader

RUN php artisan wayfinder:generate

RUN npm install
RUN npm run build 

RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

