# Wormhole Systems - Production Docker Setup

Production-ready Docker setup for Wormhole Systems with automatic SSL certificates and secure defaults.

## Setup Steps

### Step 1: Configure Docker Environment

First, we need to tell Docker about your domain names and SSL certificate email.

**Create the main configuration file:**

1. Copy the template file:
   ```bash
   cp .env.example .env
   ```

2. Open the file for editing:
   ```bash
   nano .env
   ```

3. Update the file with your actual values:
   ```bash
   # Your main domain (replace with your actual domain)
   APP_DOMAIN=wormhole.systems
   
   # Your WebSocket subdomain (usually ws.yourdomain)
   WS_DOMAIN=ws.wormhole.systems
   
   # Your email for SSL certificate notifications
   ACME_EMAIL=admin@wormhole.systems
   ```

### Step 2: Configure MySQL Database

Now we need to set up the database credentials that MySQL will use when it starts up.

**Create the MySQL configuration file:**

1. Copy the template file:
   ```bash
   cp dockerfiles/mysql/.env.example dockerfiles/mysql/.env
   ```

2. Open the file for editing:
   ```bash
   nano dockerfiles/mysql/.env
   ```

3. Set your database credentials (choose strong passwords):
   ```bash
   # Database name for the application
   MYSQL_DATABASE=wormholesystems
   
   # Database user for the application
   MYSQL_USER=wormholesystems
   
   # Password for the application user (make this secure!)
   MYSQL_PASSWORD=MySecurePassword123!
   
   # Root password for MySQL admin access (make this very secure!)
   MYSQL_ROOT_PASSWORD=MySuperSecureRootPassword456!
   ```

**Important:** Remember these exact credentials - you'll need to use them again in Step 3!

### Step 3: Configure Laravel Application

Now we configure the Laravel application itself. This is where we tell Laravel how to connect to the database and external services.

**Create the Laravel configuration file:**

1. Copy the template file:
   ```bash
   cp wormhole-systems/.env.example wormhole-systems/.env
   ```

2. Open the file for editing:
   ```bash
   nano wormhole-systems/.env
   ```

3. Configure the application settings (**Critical:** Database credentials must match Step 2 exactly!):

```bash
# Application URL (use your domain from Step 1)
APP_URL=https://wormhole.systems

# Database connection - MUST MATCH dockerfiles/mysql/.env exactly!
DB_DATABASE=wormholesystems
DB_USERNAME=wormholesystems
DB_PASSWORD=MySecurePassword123!

# WebSocket server (use your WebSocket domain from Step 1)
VITE_REVERB_HOST="ws.wormhole.systems"

# EVE Online API credentials (get these from https://developers.eveonline.com/)
# Create a new application and copy the Client ID and Secret here
EVE_CLIENT_ID=your_eve_client_id_here
EVE_CLIENT_SECRET=your_eve_client_secret_here

# WebSocket server credentials (ALL must be random for security)
# Generate each value separately:
REVERB_APP_ID=YourRandomAppId32CharactersLongHere==
REVERB_APP_KEY=YourRandomKey32CharactersLongHere==
REVERB_APP_SECRET=YourRandomSecret32CharactersLongHere==
```

**Generate random Reverb values:**
```bash
openssl rand -base64 32      # For REVERB_APP_ID
openssl rand -base64 32      # For REVERB_APP_KEY
openssl rand -base64 32      # For REVERB_APP_SECRET
```

**Critical:** The database settings (DB_DATABASE, DB_USERNAME, DB_PASSWORD) must be identical to what you set in Step 2!

### Step 4: Build and Start Services

Now we'll build the application image first, then start all services. This will take a few minutes the first time.

First, build just the application image:
```bash
docker-compose build application
```

Then start all services:
```bash
docker-compose up -d --build
```

**Wait for:** All containers to start (you can check with `docker-compose ps`)

### Step 5: Install Dependencies and Build Assets

Now we need to install all dependencies and build the frontend assets.

Install Composer dependencies (PHP packages):
```bash
docker-compose run --rm composer install
```

Generate application routes:
```bash
docker-compose run --rm artisan wayfinder:generate
```

Install NPM dependencies (JavaScript packages):
```bash
docker-compose run --rm npm install
```

Build frontend assets:
```bash
docker-compose run --rm npm run build
```

### Step 6: Initialize Application

Now we need to download EVE Online data and set up the application database.

Download and prepare EVE Online static data (this takes a while):
```bash
# Download EVE SDE data (Static Data Export) - about 500MB
docker-compose run --rm artisan sde:download

# Process and import the data into the database - takes 10-15 minutes
docker-compose run --rm artisan sde:prepare
```

Generate the Laravel application key and set up the database:
```bash
# Generate a unique encryption key for Laravel
docker-compose run --rm artisan key:generate

# Create database tables and add sample data
docker-compose run --rm artisan migrate --seed
```

### Step 7: Access Your Application

🎉 **Your application is now ready!**

Access your Wormhole Systems application at:
- **Main application**: `https://wormhole.systems` (or your domain)
- **WebSocket server**: `wss://ws.wormhole.systems` (handles real-time updates)

**First login:** Use EVE Online SSO to log in with your EVE character.

## ⚠️ **Critical: Database Credentials Must Match**

The database settings must be **identical** in these two files:
- **File:** `dockerfiles/mysql/.env` → MySQL container configuration  
- **File:** `wormhole-systems/.env` → Laravel database connection

**Mismatched credentials will prevent the application from connecting to the database.**

## Services

- **application**: PHP-FPM application container
- **server**: Nginx web server
- **mysql**: MySQL database
- **redis**: Redis cache
- **reverb**: Laravel WebSocket server
- **traefik**: Reverse proxy with automatic SSL
- **queue**: Laravel queue worker
- **scheduler**: Laravel task scheduler

## SSL Certificates

SSL certificates are handled automatically by Traefik:
- Automatic Let's Encrypt certificates
- Auto-renewal before expiration
- No manual setup required

## Server Requirements

- Docker and Docker Compose installed
- Ports 80 and 443 open to the internet
- Domain names pointing to your server IP
- At least 8GB RAM required

## Commands

### Artisan Commands
```bash
docker-compose run --rm artisan migrate
docker-compose run --rm artisan queue:work
docker-compose run --rm artisan tinker
```

### NPM Commands
```bash
docker-compose run --rm npm install
docker-compose run --rm npm run build
docker-compose run --rm npm run dev
```

### Service Management
```bash
# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Update and rebuild
docker-compose down
docker-compose up -d --build
```

## Troubleshooting

### Check SSL Certificates
```bash
# View Traefik logs for certificate issues
docker-compose logs traefik

# Check certificate storage
docker volume inspect traefik-acme
```

### Service Issues
```bash
# Check all services
docker-compose ps

# View specific service logs
docker-compose logs [service-name]

# Restart all services
docker-compose restart
```

### Database Issues
```bash
# Access MySQL directly
docker-compose exec mysql mysql -u root -p

# Reset database
docker-compose run --rm artisan migrate:fresh --seed
```

## Security Features

- Traefik dashboard restricted to localhost only
- SSL verification enabled
- Automatic HTTPS redirects
- Secure restart policies
- No development tools in production

## License

This project is licensed under the MIT License.