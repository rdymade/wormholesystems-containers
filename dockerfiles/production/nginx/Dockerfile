# docker/nginx/Dockerfile
# Stage 1: Build assets
FROM node:20-alpine AS builder

# Install Node.js and build tools
RUN apk add --no-cache \
    nginx \
    php84 \
    php84-fpm \
    php84-pdo_mysql \
    php84-mysqli \
    php84-json \
    php84-dom \
    php84-zip \
    php84-xml \
    php84-ctype \
    php84-curl \
    php84-mbstring \
    php84-openssl \
    php84-tokenizer \
    php84-session \
    php84-phar \
    php84-fileinfo \
    php84-iconv \
    php84-gd \
    php84-intl

RUN ln -sf /usr/bin/php84 /usr/bin/php

# Set working directory
WORKDIR /var/www/html

# Copy Laravel application code
COPY ./wormhole-systems /var/www/html

# Install Node.js dependencies and build assets
#RUN npm install && npm run build

# Stage 2: Nginx production image
FROM nginx:alpine

# Copy custom Nginx configuration
# -----------------------------------------------------------
# Replace the default Nginx configuration with our custom one
# that is optimized for serving a Laravel application.
# -----------------------------------------------------------
COPY ./dockerfiles/production/nginx/nginx.conf /etc/nginx/nginx.conf

# Copy Laravel's public assets from the builder stage
# -----------------------------------------------------------
# We only need the 'public' directory from our Laravel app.
# -----------------------------------------------------------
COPY --from=builder /var/www/html/public /var/www/html/public

# Set the working directory to the public folder
WORKDIR /var/www/html/public

# Expose port 80 and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
