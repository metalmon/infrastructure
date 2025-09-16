# Universal Infrastructure Stack

A universal infrastructure stack for deploying any application with Traefik reverse proxy and comprehensive monitoring.

## 🏗️ Architecture

```
infrastructure/
├── traefik/          # Universal reverse proxy
├── monitoring/       # Universal monitoring stack
└── manage.sh         # Unified management script
```

## 🚀 Quick Start

### 1. Setup Infrastructure

```bash
# Start Traefik
cd traefik
make install
nano env.traefik  # Configure domain and email
make start

# Start Monitoring
cd ../monitoring
make install
nano env.monitoring  # Configure passwords
make start
```

### 2. Configure Your Application

Add your application to the `traefik` network and configure Traefik labels:

```yaml
# In your app's docker-compose.yml
networks:
  - traefik

labels:
  - "traefik.enable=true"
  - "traefik.http.routers.yourapp.rule=Host(`yourdomain.com`) && PathPrefix(`/api`)"
  - "traefik.http.routers.yourapp.entrypoints=websecure"
  - "traefik.http.routers.yourapp.tls.certresolver=letsencrypt"
```

## 📊 Monitoring Stack

- **Prometheus** - Metrics collection
- **Grafana** - Visualization and dashboards
- **Node Exporter** - System metrics
- **cAdvisor** - Container metrics

## 🔧 Management

Use the unified management script:

```bash
# Start all services
./manage.sh start all

# Check status
./manage.sh status all

# View logs
./manage.sh logs all
```

## 🔒 Security

### Quick Security Setup

**⚠️ CRITICAL**: The security script disables root access! Create a new user first:

```bash
# 1. Create new user (as root)
sudo su -
adduser yourusername
usermod -aG sudo yourusername

# 2. Setup SSH keys for new user
su - yourusername
mkdir -p ~/.ssh
chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys  # Paste your public key here
chmod 600 ~/.ssh/authorized_keys

# 3. Test new user access
exit
ssh yourusername@your-server-ip

# 4. Run automated security setup
./setup-security.sh [ssh_port] [ssh_user]

# Example:
./setup-security.sh 2222 yourusername

# Manual security check
./security-check.sh
```

**⚠️ WARNING**: If you run the security script without creating a new user first, you will lose access to the server!

### Security Features

- **SSH Key Authentication**: Disable password login
- **Firewall**: UFW with essential ports only
- **Fail2Ban**: Brute force protection
- **Auto Updates**: Security patches automatically
- **Monitoring**: Security event logging

## 🌐 Access URLs

- **Traefik Dashboard**: `https://yourdomain.com/traefik`
- **Prometheus**: `https://yourdomain.com/prometheus`
- **Grafana**: `https://yourdomain.com/grafana`
- **Node Exporter**: `https://yourdomain.com/node-exporter`
- **cAdvisor**: `https://yourdomain.com/cadvisor`

**🔒 Security Note**: All services are accessed through Traefik reverse proxy with HTTPS and Basic Authentication. Internal ports (8080, 9090, 3000, 9100) are NOT exposed externally.

## 🔒 Security

All services are protected with HTTP Basic Authentication:
- **Username**: `admin`
- **Password**: Configured in environment files

## 📝 Configuration

### Traefik Configuration
- Domain configuration in `traefik/env.traefik`
- SSL certificates via Let's Encrypt
- Automatic HTTPS redirect

### Monitoring Configuration
- Passwords in `monitoring/env.monitoring`
- Custom dashboards in `monitoring/grafana/dashboards/`
- Alert rules in `monitoring/alert_rules.yml`

## 🔄 Integration with Applications

This infrastructure is designed to be application-agnostic. To integrate:

1. **Add your app to the `traefik` network**
2. **Configure Traefik labels for routing**
3. **Add custom dashboards to Grafana**
4. **Configure application-specific alerts**

## 📚 Documentation

- [Traefik Setup](traefik/README.md)
- [Monitoring Setup](monitoring/README.md)
- [DNS Configuration](DNS_SETUP.md)
- [Security Setup](SECURITY.md)
- [Security Architecture](SECURITY_ARCHITECTURE.md)

## 🛠️ Customization

### Adding Custom Dashboards
1. Create JSON dashboard files in `monitoring/grafana/dashboards/`
2. Restart monitoring stack: `cd monitoring && make restart`

### Adding Custom Alerts
1. Edit `monitoring/alert_rules.yml`
2. Restart monitoring stack: `cd monitoring && make restart`

### Adding New Services
1. Add service to `traefik/docker-compose.yml` or `monitoring/docker-compose.yml`
2. Configure Traefik labels for routing
3. Update `manage.sh` if needed

## 🚨 Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Check domain DNS configuration
   - Verify Let's Encrypt rate limits
   - Check Traefik logs: `cd traefik && make logs`

2. **Authentication Issues**
   - Regenerate auth hashes: `cd monitoring && ./generate-auth.sh`
   - Check environment variables

3. **Service Not Accessible**
   - Check Traefik labels
   - Verify network configuration
   - Check service logs

### Logs
- Traefik: `cd traefik && make logs`
- Monitoring: `cd monitoring && make logs`

## 📄 License

This infrastructure stack is provided as-is for universal use.