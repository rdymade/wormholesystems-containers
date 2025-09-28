#!/bin/bash

# =============================================================================
# NGINX CONFIGURATION GENERATOR
# =============================================================================
# This script generates the nginx configuration from environment variables
# =============================================================================

set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default values
APP_DOMAIN=${APP_DOMAIN:-"localhost"}

# Create dockerfiles/server directory if it doesn't exist
mkdir -p dockerfiles/server

# Generate nginx.conf from template
sed -e "s|{{APP_DOMAIN}}|${APP_DOMAIN}|g" \
    dockerfiles/server/nginx.conf.template > dockerfiles/server/nginx.conf

echo "✅ Generated dockerfiles/server/nginx.conf with domain: ${APP_DOMAIN}"
