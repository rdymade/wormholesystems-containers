FROM application

# copy composer binary from the official composer image
COPY --link --chown=${WWWUSER}:${WWWUSER} --from=composer:latest /usr/bin/composer /usr/bin/composer

# set working directory
WORKDIR /var/www/html

ENTRYPOINT ["composer"]