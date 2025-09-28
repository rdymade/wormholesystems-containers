#!/bin/bash

# =============================================================================
# WORMHOLE SYSTEMS - DOCKER SETUP SCRIPT
# =============================================================================
# This script sets up the Docker environment with configurable variables
# =============================================================================

set -e

echo "🚀 Setting up Wormhole Systems Docker Environment..."
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "⚠️  No .env file found. Creating from template..."
    cp .env.example .env
    echo "✅ Created .env file from template"
    echo "📝 Please edit .env file with your configuration before continuing"
    echo ""
    echo "Key variables to configure:"
    echo "  - APP_DOMAIN: Your main application domain (e.g., wormhole.systems)"
    echo "  - WS_DOMAIN: Your WebSocket domain (e.g., ws.wormhole.systems)"
    echo "  - CERT_MODE: 'manual' for development, 'acme' for production"
    echo "  - ACME_EMAIL: Your email for Let's Encrypt (if using ACME mode)"
    echo ""
    read -p "Press Enter after editing .env file to continue..."
fi

# Load environment variables
echo "📋 Loading environment variables..."
export $(cat .env | grep -v '^#' | xargs)

# Set default certificate mode
CERT_MODE=${CERT_MODE:-"manual"}

# Handle certificate configuration based on mode
if [ "$CERT_MODE" = "acme" ]; then
    echo "🔐 Configuring ACME/Let's Encrypt certificates..."
    
    # Validate ACME configuration
    if [ -z "$ACME_EMAIL" ] || [ "$ACME_EMAIL" = "your-email@example.com" ]; then
        echo "❌ Please set ACME_EMAIL in .env file for Let's Encrypt certificates"
        exit 1
    fi
    
    # Generate ACME configuration
    ./scripts/generate-acme-config.sh
    
    echo "✅ ACME configuration ready"
    echo "⚠️  Certificates will be generated automatically when Traefik starts"
    echo "⚠️  Make sure your domains point to this server for HTTP challenge to work"
else
    echo "🔐 Generating development certificates..."
    
    # Generate SSL certificates for development
    ./scripts/generate-dev-certificates.sh
fi

# Generate configuration files
echo "🔧 Generating configuration files..."

# Generate nginx configuration
./scripts/generate-nginx-config.sh

echo ""
echo "✅ Setup completed successfully!"
echo ""
echo "🐳 Next steps:"
echo "   1. Build the application image:"
echo "      docker-compose build application"
echo ""
echo "   2. Start all services:"
echo "      docker-compose up -d --build"
echo ""
echo "   3. Download EVE SDE (Static Data Export):"
echo "      docker-compose run --rm artisan sde:download"
echo ""
echo "   4. Prepare EVE SDE data:"
echo "      docker-compose run --rm artisan sde:prepare"
echo ""
echo "   5. Run database migrations and seeders:"
echo "      docker-compose run --rm artisan migrate --seed"
echo ""
echo "🌐 Your application will be available at:"
echo "   Main app: https://${APP_DOMAIN:-localhost}"
echo "   WebSocket: wss://${WS_DOMAIN:-ws.localhost}"
echo "   Traefik Dashboard: http://localhost:${TRAEFIK_DASHBOARD_PORT:-8080}"
echo ""
echo "💡 Example production domains:"
echo "   Main app: https://wormhole.systems"
echo "   WebSocket: wss://ws.wormhole.systems"
echo ""
