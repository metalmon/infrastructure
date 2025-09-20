# 📊 Universal Monitoring Stack

A comprehensive monitoring system with Prometheus, Grafana, Alertmanager, and Telegram notifications for any application.

## 📚 Documentation

**All documentation is located in the [`docs/`](docs/) directory:**

- **[docs/README.md](docs/README.md)** - Overview of all documentation
- **[docs/SETUP_INSTRUCTIONS.md](docs/SETUP_INSTRUCTIONS.md)** - Complete setup guide
- **[docs/QUICK_START.md](docs/QUICK_START.md)** - Quick start for experienced users
- **[docs/TELEGRAM_ALERTS_SETUP.md](docs/TELEGRAM_ALERTS_SETUP.md)** - Detailed Telegram alerts setup
- **[docs/SECURITY.md](docs/SECURITY.md)** - Security guide and secrets management
- **[docs/AUTH_SETUP.md](docs/AUTH_SETUP.md)** - Authentication setup guide

## 🚀 Quick Start

### 1. Setup Environment Variables
```bash
cd infrastructure/monitoring
cp env.template .env
```

### 2. Generate Authentication Hashes
```bash
# Simple generation (standard usernames)
./generate-auth.sh your_secure_password

# Or custom generation (custom usernames)
./generate-custom-auth.sh your_secure_password metrics_user admin_user
```

### 3. Edit .env File
```bash
nano .env  # Add your values
```

### 4. Start Monitoring
```bash
make start
```

### 5. Check Status
```bash
make status
```

## 🌐 Service Access

- **Prometheus**: `https://your-domain.com/prometheus/`
- **Grafana**: `https://your-domain.com/grafana/`
- **Alertmanager**: `https://your-domain.com/alertmanager/`

## 🔒 Security

- ✅ All secrets stored in `.env` file (not in git)
- ✅ `.env` added to `.gitignore`
- ✅ Service access protected by authentication
- ✅ Telegram notifications only to your chat

## 🏗️ Monitoring Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Prometheus    │    │     Grafana     │    │  Node Exporter  │
│   (Metrics)     │◄───┤  (Dashboards)   │    │ (System Metrics)│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌────────────────────┐
                    │     cAdvisor       │
                    │ (Container Metrics)│
                    └────────────────────┘
```

## 🚀 Quick Start

### 1. Installation

```bash
# Navigate to monitoring directory
cd monitoring

# Install monitoring stack
make install

# Configure environment variables
nano env.monitoring
```

### 2. Configuration

Edit the `env.monitoring` file:

```bash
# Domain configuration
DOMAIN=your-domain.com

# Grafana configuration
GRAFANA_ADMIN_PASSWORD=your-secure-password

# Metrics API key (for your application)
METRICS_API_KEY=your-secure-api-key-here
```

### 3. Start

```bash
# Start monitoring
make start

# Check status
make status
```

## 📋 Available Commands

```bash
make start              # Start monitoring
make stop               # Stop monitoring
make restart            # Restart monitoring
make logs               # Show logs
make status             # Show status
make clean              # Clean up data
make install            # Initial installation
make reload-prometheus  # Reload Prometheus configuration
make backup-grafana     # Create Grafana backup
make restore-grafana    # Restore Grafana from backup
```

## 🌐 Service Access

### Prometheus
- **URL**: `https://your-domain.com/prometheus` (via Traefik)
- **Description**: Metrics collection and storage
- **Features**: Metric queries, alerts, rules
- **Security**: Protected by Basic Auth and HTTPS

### Grafana
- **URL**: `https://your-domain.com/grafana` (via Traefik)
- **Login**: `admin`
- **Password**: Configured in `env.monitoring`
- **Description**: Metrics visualization and dashboards
- **Security**: Protected by Basic Auth and HTTPS

### Node Exporter
- **URL**: `https://your-domain.com/node-exporter` (via Traefik)
- **Description**: Server system metrics
- **Metrics**: CPU, memory, disk, network
- **Security**: Protected by Basic Auth and HTTPS

### cAdvisor
- **URL**: `https://your-domain.com/cadvisor` (via Traefik)
- **Description**: Docker container metrics
- **Metrics**: Container resource usage
- **Security**: Protected by Basic Auth and HTTPS

**⚠️ Important**: Internal ports (9090, 3000, 9100, 8080) are NOT exposed externally. All access is through Traefik reverse proxy with HTTPS and authentication.

## 📊 Dashboards

### System Overview
- **Description**: General system overview
- **Metrics**: CPU, memory, disk, network
- **Update**: Every 30 seconds

### Container Metrics
- **Status**: Are containers running
- **Resources**: CPU and memory usage by containers
- **Restarts**: Number of container restarts

### Application Metrics
- **Custom dashboards**: Add your application-specific dashboards
- **Business metrics**: Track application-specific KPIs
- **Performance**: Response times, error rates

## 🔧 Configuration

### Prometheus (`prometheus.yml`)
- **Scrape interval**: 15 seconds
- **Retention**: 30 days
- **Targets**: Traefik, Node Exporter, cAdvisor, Grafana

### Grafana
- **Datasource**: Prometheus (automatically configured)
- **Dashboards**: Automatically loaded
- **Plugins**: Pie chart panel

### Alerts (`alert_rules.yml`)
- **High error rate**: > 10% errors
- **Slow response time**: > 1 second
- **Service down**: Service not responding
- **High resource usage**: > 80% CPU/memory
- **Low disk space**: < 10% free space

## 🔒 Security

### Authentication
- **Grafana**: Admin login/password
- **Prometheus**: Basic authentication for metrics
- **Traefik**: SSL certificates from Let's Encrypt

### Access
- **Local access**: Direct ports for development
- **External access**: Through Traefik with SSL
- **IP whitelist**: Can be configured in Traefik

## 📈 Metrics

### Traefik
- `traefik_entrypoint_open_connections` - Active connections
- `traefik_service_requests_total` - Service requests
- `traefik_service_response_duration_seconds` - Response time

### System (Node Exporter)
- `node_cpu_seconds_total` - CPU usage
- `node_memory_MemTotal_bytes` - Total memory
- `node_filesystem_avail_bytes` - Free disk space

### Containers (cAdvisor)
- `container_cpu_usage_seconds_total` - Container CPU usage
- `container_memory_usage_bytes` - Container memory usage
- `container_start_time_seconds` - Container start time

### Application Metrics
Add your application metrics to `prometheus.yml`:

```yaml
# Example: Your application metrics
- job_name: 'your-app'
  static_configs:
    - targets: ['your-app:8080']
  metrics_path: '/metrics'
  scrape_interval: 15s
  basic_auth:
    username: 'metrics'
    password: '${METRICS_API_KEY}'
```

## 🚨 Troubleshooting

### Issue: Prometheus Not Collecting Metrics

**Solution:**
1. Check status: `make status`
2. Check logs: `make logs`
3. Check configuration: `curl http://localhost:9090/api/v1/targets`

### Issue: Grafana Not Loading

**Solution:**
1. Check status: `make status`
2. Check logs: `make logs`
3. Check permissions: `ls -la grafana_data/`

### Issue: Metrics Not Displaying

**Solution:**
1. Check Prometheus connection in Grafana
2. Check metric queries in Prometheus
3. Ensure services are exporting metrics

## 🔄 Updates

```bash
# Stop monitoring
make stop

# Update images
docker-compose pull

# Start again
make start
```

## 💾 Backup

### Create Backup
```bash
make backup-grafana
```

### Restore
```bash
make restore-grafana BACKUP_FILE=grafana-backup-20231216-120000.tar.gz
```

## 📁 File Structure

```
monitoring/
├── docker-compose.yml           # Docker Compose configuration
├── prometheus.yml               # Prometheus configuration
├── alert_rules.yml             # Alert rules
├── env.monitoring              # Environment variables
├── Makefile                    # Management commands
├── README.md                   # Documentation
├── prometheus_data/            # Prometheus data
├── grafana_data/              # Grafana data
└── grafana/
    ├── provisioning/
    │   ├── datasources/
    │   │   └── prometheus.yml  # Data source
    │   └── dashboards/
    │       └── dashboard.yml   # Dashboard configuration
    └── dashboards/
        └── system-overview.json # System dashboard
```

## 🎯 Application Integration

To integrate with your application:

1. **Export metrics** from your application (e.g., `/metrics` endpoint)
2. **Add to Prometheus config** in `prometheus.yml`
3. **Create custom dashboards** in Grafana
4. **Set up alerts** in `alert_rules.yml`

### Example Application Metrics

```yaml
# In prometheus.yml
- job_name: 'your-app'
  static_configs:
    - targets: ['your-app:8080']
  metrics_path: '/metrics'
  scrape_interval: 15s
  basic_auth:
    username: 'metrics'
    password: '${METRICS_API_KEY}'
```

### Example Alert Rules

```yaml
# In alert_rules.yml
- alert: YourAppHighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
  for: 2m
  labels:
    severity: warning
  annotations:
    summary: "High error rate in your app"
    description: "Error rate is {{ $value }} errors per second"
```

## 📞 Support

If you encounter problems:

1. Check status: `make status`
2. Check logs: `make logs`
3. Check configuration in `env.monitoring`
4. Ensure domain points to server
5. Check that ports 9090, 3000, 9100, 8081 are open
