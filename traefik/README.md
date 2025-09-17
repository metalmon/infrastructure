# Universal Traefik Reverse Proxy

Universal Traefik reverse proxy with automatic SSL certificates from Let's Encrypt for any application.

## 🚀 Quick Start

### 1. Installation

```bash
# Clone the repository
git clone <repository-url>
cd traefik

# Install Traefik
make install
```

### 2. Configuration

Edit the `env.traefik` file:

```bash
DOMAIN=your-domain.com
ACME_EMAIL=admin@your-domain.com
TRAEFIK_NETWORK=traefik
```

**Important**: Do not add comments or spaces around the `=` sign in the env file.

### 3. Start

```bash
# Start Traefik
make start

# Check status
make status
```

## 📋 Available Commands

```bash
make start      # Start Traefik
make stop       # Stop Traefik
make restart    # Restart Traefik
make logs       # Show logs
make status     # Show status
make clean      # Clean up data
make network    # Create network
make install    # Initial installation
```

## 🌐 Service Access

### Traefik Dashboard
- **URL**: `http://localhost:8080`
- **Description**: Web interface for monitoring Traefik

### API
- **URL**: `http://localhost:8080/api/rawdata`
- **Description**: JSON API for getting route information

## 🔧 Configuration

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN` | Your domain | `example.com` |
| `ACME_EMAIL` | Email for Let's Encrypt | `admin@example.com` |
| `TRAEFIK_NETWORK` | Docker network name | `traefik` |

### Configuration Files

- `docker-compose.yml` - Main Docker Compose configuration
- `traefik.yml` - Traefik configuration
- `env.traefik` - Environment variables
- `letsencrypt/` - SSL certificates folder

## 🔐 SSL Certificates

Traefik automatically obtains SSL certificates from Let's Encrypt for all domains.

### Supported Domains

- `traefik.your-domain.com` - Traefik Dashboard
- `your-app.your-domain.com` - Your application
- `metrics.your-domain.com` - Metrics (if configured)

## 🌍 Network

Traefik creates a `traefik` network that all services should connect to.

### Connecting a Service to the Network

```yaml
# In your service's docker-compose.yml
networks:
  - traefik

networks:
  traefik:
    external: true
```

## 📊 Monitoring

### Logs

```bash
# Show logs
make logs

# Real-time logs
docker-compose logs -f traefik
```

### Metrics

Traefik provides Prometheus metrics on port 8080.

## 🚨 Troubleshooting

### Issue: SSL Not Working

**Solution:**
1. Check that the domain points to your server
2. Ensure ports 80 and 443 are open
3. Check logs: `make logs`

### Issue: Network Not Created

**Solution:**
```bash
# Create network manually
docker network create traefik
```

### Issue: Dashboard Not Working

**Solution:**
1. Check that port 8080 is open
2. Ensure Traefik is running: `make status`
3. Check logs: `make logs`

## 🔄 Updates

```bash
# Stop Traefik
make stop

# Update image
docker-compose pull

# Start again
make start
```

## 📁 File Structure

```
traefik/
├── docker-compose.yml    # Docker Compose configuration
├── traefik.yml          # Traefik configuration
├── env.traefik          # Environment variables
├── Makefile             # Management commands
├── README.md            # Documentation
└── letsencrypt/         # SSL certificates (created automatically)
```

## 🎯 Application Integration

To integrate with any application, add to your application's `docker-compose.yml`:

```yaml
services:
  your-app:
    # ... your app configuration
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.yourapp.rule=Host(`yourapp.${DOMAIN}`)"
      - "traefik.http.routers.yourapp.entrypoints=websecure"
      - "traefik.http.routers.yourapp.tls.certresolver=letsencrypt"
      - "traefik.http.services.yourapp.loadbalancer.server.port=8080"
```

### Path-based Routing

For path-based routing (e.g., `domain.com/app`):

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.yourapp.rule=Host(`${DOMAIN}`) && PathPrefix(`/app`)"
  - "traefik.http.routers.yourapp.entrypoints=websecure"
  - "traefik.http.routers.yourapp.tls.certresolver=letsencrypt"
  - "traefik.http.services.yourapp.loadbalancer.server.port=8080"
```

## 🔒 Security

### Basic Authentication

To add basic authentication to your services:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.yourapp.rule=Host(`${DOMAIN}`) && PathPrefix(`/app`)"
  - "traefik.http.routers.yourapp.entrypoints=websecure"
  - "traefik.http.routers.yourapp.tls.certresolver=letsencrypt"
  - "traefik.http.middlewares.yourapp-auth.basicauth.users=${AUTH_HASH}"
  - "traefik.http.routers.yourapp.middlewares=yourapp-auth"
  - "traefik.http.services.yourapp.loadbalancer.server.port=8080"
```

Generate auth hash:
```bash
echo $(htpasswd -nbB admin yourpassword)
```

## 📞 Support

If you encounter problems:

1. Check logs: `make logs`
2. Check status: `make status`
3. Check configuration in `env.traefik`
4. Ensure domain points to server
