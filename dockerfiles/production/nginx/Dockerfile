# Stage 1: Build the Laravel application
FROM php:8.4-fpm AS laravel-builder

# Install system dependencies and PHP extensions for Laravel with MySQL support.
RUN apt-get update && apt-get install -y --no-install-recommends \
    autoconf \
    curl \
    unzip \
    libpq-dev \
    libonig-dev \
    libssl-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    libzip-dev \
    supervisor \
    nodejs \
    npm \
    && docker-php-ext-install -j$(nproc) \
    pcntl \
    pdo \
    pdo_mysql \
    sockets \
    zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory inside the container
WORKDIR /var/www/html

# Copy the entire Laravel application code into the container
COPY ./wormhole-systems /var/www/html

# Install Composer and dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install

# Generate application routes
RUN php artisan wayfinder:generate

# Install Node.js dependencies and build assets
RUN npm install && npm run build

# Stage 2: Nginx
FROM nginx:alpine

# Copy public files from the Laravel builder stage
COPY --from=laravel-builder /var/www/html/public /var/www/html/public

# Set working dir to the public folder
WORKDIR /var/www/html/public

# Expose port and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
