#!/bin/bash

# =============================================================================
# ACME CONFIGURATION GENERATOR
# =============================================================================
# This script generates the Traefik ACME configuration from environment variables
# =============================================================================

set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default values
ACME_EMAIL=${ACME_EMAIL:-"admin@localhost"}
ACME_CA_SERVER=${ACME_CA_SERVER:-"https://acme-v02.api.letsencrypt.org/directory"}
ACME_CHALLENGE=${ACME_CHALLENGE:-"http"}
ACME_DNS_PROVIDER=${ACME_DNS_PROVIDER:-"your-dns-provider"}

# Create traefik directory if it doesn't exist
mkdir -p traefik

# Start with the base template
sed -e "s|{{ACME_EMAIL}}|${ACME_EMAIL}|g" \
    -e "s|{{ACME_CA_SERVER}}|${ACME_CA_SERVER}|g" \
    traefik/acme.yml.template > traefik/acme.yml

# Add challenge configuration based on type
if [ "$ACME_CHALLENGE" = "http" ]; then
    cat >> traefik/acme.yml << EOF
      httpChallenge:
        entryPoint: web
EOF
elif [ "$ACME_CHALLENGE" = "dns" ]; then
    cat >> traefik/acme.yml << EOF
      dnsChallenge:
        provider: ${ACME_DNS_PROVIDER}
        delayBeforeCheck: 30
        resolvers:
          - "1.1.1.1:53"
          - "8.8.8.8:53"
EOF
else
    echo "❌ Invalid ACME_CHALLENGE type: ${ACME_CHALLENGE}. Must be 'http' or 'dns'"
    exit 1
fi

echo "✅ Generated traefik/acme.yml with ACME configuration:"
echo "   Email: ${ACME_EMAIL}"
echo "   CA Server: ${ACME_CA_SERVER}"
echo "   Challenge: ${ACME_CHALLENGE}"
if [ "$ACME_CHALLENGE" = "dns" ]; then
    echo "   DNS Provider: ${ACME_DNS_PROVIDER}"
fi
