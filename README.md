# Wormhole Systems - Docker Setup

A portable Docker setup for the Wormhole Systems application with configurable domains, ports, and automatic SSL certificate management.

## Quick Start

```bash
# 1. Copy environment template
cp .env.example .env

# 2. Edit configuration (set your domains)
nano .env

# 3. Run setup
./scripts/setup.sh

# 4. Build application image
docker-compose build application

# 5. Start services
docker-compose up -d --build
```

Your application will be available at:
- **Main app**: `https://your-domain.com`
- **WebSocket**: `wss://ws.your-domain.com`
- **Traefik Dashboard**: `http://localhost:8080`

## Configuration

### Environment Variables

Edit `.env` file with your settings:

```bash
# Domains
APP_DOMAIN=your-domain.com
WS_DOMAIN=ws.your-domain.com

# Ports (usually keep defaults)
HTTP_PORT=80
HTTPS_PORT=443
TRAEFIK_DASHBOARD_PORT=8080
```

### Certificate Modes

#### Development (Default)
```bash
CERT_MODE=manual
```
- Uses mkcert or self-signed certificates
- Perfect for localhost development
- Certificates generated automatically

#### Production
```bash
CERT_MODE=acme
ACME_EMAIL=admin@your-domain.com
ACME_CHALLENGE=http
```
- Automatic Let's Encrypt certificates
- Auto-renewal included
- No manual certificate management

## Services

- **application**: PHP-FPM application container
- **server**: Nginx web server
- **mysql**: MySQL database
- **redis**: Redis cache
- **reverb**: Laravel WebSocket server
- **traefik**: Reverse proxy with SSL termination
- **queue**: Laravel queue worker
- **scheduler**: Laravel task scheduler

## Development

### Local Development
```bash
# Use localhost domains
APP_DOMAIN=localhost
WS_DOMAIN=ws.localhost
CERT_MODE=manual

# Install mkcert for trusted certificates (optional)
brew install mkcert  # macOS
mkcert -install
```

### Artisan Commands
```bash
# Run artisan commands
docker-compose exec artisan migrate
docker-compose exec artisan queue:work
```

### NPM Commands
```bash
# Install dependencies
docker-compose run --rm npm install

# Build assets
docker-compose run --rm npm run build

# Watch for changes
docker-compose run --rm npm run dev
```

## Production Deployment

### 1. Server Setup
- Ensure ports 80 and 443 are open
- Point your domains to the server IP
- Install Docker and Docker Compose

### 2. Configuration
```bash
# Production settings
CERT_MODE=acme
APP_DOMAIN=your-domain.com
WS_DOMAIN=ws.your-domain.com
ACME_EMAIL=admin@your-domain.com

# Security settings
TRAEFIK_API_INSECURE=false
RESTART_POLICY=unless-stopped
```

### 3. Deploy
```bash
./scripts/setup.sh
docker-compose build application
docker-compose up -d
```

## SSL Certificates

### Automatic (Recommended)
- **ACME Mode**: Traefik automatically manages Let's Encrypt certificates
- **Auto-renewal**: Certificates renew automatically before expiration
- **HTTP Challenge**: Works out of the box (domains must point to server)
- **DNS Challenge**: Supports wildcards (requires DNS provider setup)

### Manual
- **Development**: mkcert creates trusted local certificates
- **Custom**: Place your certificates in `certs/` directory

## Troubleshooting

### Certificate Issues
```bash
# Check certificate status
docker-compose logs traefik

# Regenerate development certificates
./scripts/generate-dev-certificates.sh

# Check ACME configuration
cat traefik/acme.yml
```

### Service Issues
```bash
# Check all services
docker-compose ps

# View logs
docker-compose logs [service-name]

# Restart services
docker-compose restart

# Rebuild and restart (after code changes)
docker-compose up -d --build
```

### Domain Resolution
For local development, add to `/etc/hosts`:
```
127.0.0.1 localhost
127.0.0.1 ws.localhost
```

## Scripts

- **`scripts/setup.sh`**: Main setup script
- **`scripts/generate-dev-certificates.sh`**: Development certificates
- **`scripts/generate-acme-config.sh`**: ACME configuration
- **`scripts/generate-nginx-config.sh`**: Nginx configuration

## Environment Variables Reference

| Variable | Default | Description |
|----------|---------|-------------|
| `APP_DOMAIN` | `localhost` | Main application domain |
| `WS_DOMAIN` | `ws.localhost` | WebSocket domain |
| `CERT_MODE` | `manual` | Certificate mode (`manual` or `acme`) |
| `ACME_EMAIL` | - | Email for Let's Encrypt (required for ACME) |
| `ACME_CHALLENGE` | `http` | ACME challenge type (`http` or `dns`) |
| `HTTP_PORT` | `80` | HTTP port |
| `HTTPS_PORT` | `443` | HTTPS port |
| `TRAEFIK_DASHBOARD_PORT` | `8080` | Traefik dashboard port |
| `RESTART_POLICY` | `always` | Docker restart policy |

## License

This project is licensed under the MIT License.
