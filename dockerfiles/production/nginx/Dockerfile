FROM nginx:alpine

# Copy public files from the previous build stage
COPY --from=wormhole-systems:latest /var/www/html/public /var/www/html/public

# Set working dir to the public folder
WORKDIR /var/www/html/public

# Expose port and start Nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
