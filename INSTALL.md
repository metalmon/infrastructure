# 🚀 Installation Guide

Complete installation guide for the Universal Infrastructure Stack.

## 📋 Prerequisites

- **Server**: Ubuntu 20.04+ or Debian 11+ (VPS or dedicated server)
- **Domain**: A domain name pointing to your server
- **SSH Access**: Root or sudo access to the server
- **Docker**: Docker and Docker Compose installed

## 🔧 Quick Installation

### 1. Clone the Repository

```bash
# Clone the repository
git clone https://github.com/metalmon/infrastructure.git
cd infrastructure

# Make scripts executable
chmod +x *.sh
chmod +x traefik/*.sh
chmod +x monitoring/*.sh
```

### 2. Setup Security (Recommended)

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy SSH key to server
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server-ip

# Run automated security setup
./setup-security.sh [ssh_port] [ssh_user]

# Example:
./setup-security.sh 2222 myuser
```

### 3. Configure Domain

```bash
# Edit Traefik configuration
nano traefik/env.traefik

# Set your domain and email
DOMAIN=yourdomain.com
ACME_EMAIL=admin@yourdomain.com
TRAEFIK_NETWORK=traefik
```

### 4. Start Infrastructure

```bash
# Start Traefik
cd traefik
make install
make start

# Start Monitoring
cd ../monitoring
make install
./generate-auth.sh  # Generate passwords
nano env.monitoring  # Configure passwords
make start

# Or start everything at once
cd ..
./manage.sh install all
./manage.sh start all
```

## 🌐 DNS Configuration

### Single A-Record Setup

Add one A-record in your DNS panel:

```
yourdomain.com    A    YOUR_SERVER_IP
```

### Verify DNS

```bash
# Check DNS resolution
nslookup yourdomain.com

# Test from server
curl -I http://yourdomain.com
```

## 🔒 Security Setup

### Automated Security Setup

```bash
# Run the security setup script
./setup-security.sh

# Check security status
./security-check.sh
```

### Manual Security Setup

Follow the detailed guide in [SECURITY.md](SECURITY.md).

## 📊 Access Your Services

After installation, access your services:

- **Traefik Dashboard**: `https://yourdomain.com/traefik`
- **Prometheus**: `https://yourdomain.com/prometheus`
- **Grafana**: `https://yourdomain.com/grafana`
- **Node Exporter**: `https://yourdomain.com/node-exporter`
- **cAdvisor**: `https://yourdomain.com/cadvisor`

## 🔧 Management

### Using the Management Script

```bash
# Start all services
./manage.sh start all

# Check status
./manage.sh status all

# View logs
./manage.sh logs all

# Security check
./manage.sh security
```

### Individual Service Management

```bash
# Traefik
cd traefik
make start
make stop
make restart
make logs
make status

# Monitoring
cd monitoring
make start
make stop
make restart
make logs
make status
```

## 🛠️ Adding Your Application

### 1. Create Application Docker Compose

```yaml
# your-app/docker-compose.yml
version: '3.8'

services:
  your-app:
    image: your-app:latest
    restart: unless-stopped
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.yourapp.rule=Host(`${DOMAIN}`) && PathPrefix(`/yourapp`)"
      - "traefik.http.routers.yourapp.entrypoints=websecure"
      - "traefik.http.routers.yourapp.tls.certresolver=letsencrypt"
      - "traefik.http.services.yourapp.loadbalancer.server.port=8080"

networks:
  traefik:
    external: true
```

### 2. Add to Monitoring

```yaml
# Add to monitoring/prometheus.yml
- job_name: 'your-app'
  static_configs:
    - targets: ['your-app:8080']
  metrics_path: '/metrics'
  scrape_interval: 15s
```

### 3. Deploy Application

```bash
# Deploy your application
cd your-app
docker-compose up -d

# Check status
docker-compose ps
```

## 🚨 Troubleshooting

### Common Issues

#### SSL Certificate Issues
```bash
# Check Traefik logs
cd traefik
make logs

# Check DNS
nslookup yourdomain.com

# Verify domain points to server
curl -I http://yourdomain.com
```

#### Service Not Accessible
```bash
# Check service status
./manage.sh status all

# Check Traefik routing
curl -k https://yourdomain.com/traefik/api/rawdata
```

#### Security Issues
```bash
# Run security check
./security-check.sh

# Check firewall
sudo ufw status

# Check SSH
sudo systemctl status sshd
```

### Getting Help

1. **Check Logs**: `./manage.sh logs [service]`
2. **Security Check**: `./security-check.sh`
3. **Documentation**: See [README.md](README.md)
4. **Issues**: Create GitHub issue

## 📚 Additional Documentation

- [README.md](README.md) - Main documentation
- [SECURITY.md](SECURITY.md) - Security setup guide
- [SECURITY_ARCHITECTURE.md](SECURITY_ARCHITECTURE.md) - Security architecture
- [DNS_SETUP.md](DNS_SETUP.md) - DNS configuration
- [Traefik Setup](traefik/README.md) - Traefik documentation
- [Monitoring Setup](monitoring/README.md) - Monitoring documentation

## 🎯 Next Steps

1. **Configure Monitoring**: Add custom dashboards
2. **Set Up Alerts**: Configure alert rules
3. **Deploy Applications**: Add your services
4. **Monitor Security**: Regular security checks
5. **Backup**: Set up automated backups

## 📞 Support

- **Documentation**: Check the docs first
- **Issues**: GitHub Issues
- **Security**: Follow security best practices
- **Updates**: Keep system updated

---

**🎉 Congratulations!** Your universal infrastructure is now ready to deploy any application securely.
