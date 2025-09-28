#!/bin/bash

# =============================================================================
# DEVELOPMENT CERTIFICATE GENERATOR
# =============================================================================
# Simple script to generate SSL certificates for local development
# =============================================================================

set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set default values
APP_DOMAIN=${APP_DOMAIN:-"localhost"}
WS_DOMAIN=${WS_DOMAIN:-"ws.localhost"}
SSL_CERT_FILE=${SSL_CERT_FILE:-"traefik/localhost+1.pem"}
SSL_KEY_FILE=${SSL_KEY_FILE:-"traefik/localhost+1-key.pem"}

# Extract directory
CERT_DIR=$(dirname "certs/${SSL_CERT_FILE}")

echo "🔐 Generating development SSL certificates..."
echo "   Domains: ${APP_DOMAIN}, ${WS_DOMAIN}"
echo "   Output: certs/${SSL_CERT_FILE}"

# Create certificate directory
mkdir -p "${CERT_DIR}"

# Check if certificates already exist
if [ -f "certs/${SSL_CERT_FILE}" ] && [ -f "certs/${SSL_KEY_FILE}" ]; then
    echo "⚠️  Certificates already exist. Regenerate? (y/N)"
    read -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "✅ Using existing certificates"
        exit 0
    fi
fi

# Try mkcert first (better for development)
if command -v mkcert >/dev/null 2>&1; then
    echo "🔧 Using mkcert..."
    
    # Install CA if needed
    if ! mkcert -CAROOT >/dev/null 2>&1; then
        echo "📦 Installing mkcert CA..."
        mkcert -install
    fi
    
    # Generate certificates
    mkcert -cert-file "certs/${SSL_CERT_FILE}" \
           -key-file "certs/${SSL_KEY_FILE}" \
           "${APP_DOMAIN}" "${WS_DOMAIN}"
    
    echo "✅ Development certificates generated with mkcert!"
    echo "   Certificates are automatically trusted by your browser"
    
else
    echo "🔧 Using OpenSSL (self-signed)..."
    echo "💡 For better development experience, install mkcert:"
    echo "   macOS: brew install mkcert"
    echo "   Linux: https://github.com/FiloSottile/mkcert#installation"
    echo ""
    
    # Create OpenSSL config
    cat > "${CERT_DIR}/openssl.conf" << EOF
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
req_extensions = v3_req

[dn]
CN=${APP_DOMAIN}

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${APP_DOMAIN}
DNS.2 = ${WS_DOMAIN}
EOF

    # Generate certificate
    openssl req -new -x509 -days 365 -nodes \
                -keyout "certs/${SSL_KEY_FILE}" \
                -out "certs/${SSL_CERT_FILE}" \
                -config "${CERT_DIR}/openssl.conf" \
                -extensions v3_req
    
    # Clean up
    rm "${CERT_DIR}/openssl.conf"
    
    echo "✅ Self-signed certificates generated!"
    echo "⚠️  You'll need to manually trust these in your browser"
fi

echo ""
echo "📁 Certificate files:"
echo "   Certificate: certs/${SSL_CERT_FILE}"
echo "   Private Key: certs/${SSL_KEY_FILE}"
