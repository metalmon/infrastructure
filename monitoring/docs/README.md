# Monitoring Documentation

## Overview

This directory contains all documentation for setting up and using the monitoring system with Telegram alerts.

## Documentation Structure

### 📋 Main Instructions
- **[SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)** - Complete monitoring setup guide
- **[QUICK_START.md](QUICK_START.md)** - Quick start for experienced users

### 🔧 Detailed Guides
- **[TELEGRAM_ALERTS_SETUP.md](TELEGRAM_ALERTS_SETUP.md)** - Detailed Telegram alerts setup guide
- **[MAKE_COMMANDS.md](MAKE_COMMANDS.md)** - Complete reference for make commands

### 🔒 Security
- **[SECURITY.md](SECURITY.md)** - Security guide and secrets management
- **[AUTH_SETUP.md](AUTH_SETUP.md)** - Authentication setup and hash generation
- **[ENV_FILE_TIPS.md](ENV_FILE_TIPS.md)** - Important tips for .env files

### 📁 Project Structure
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - File and folder organization description

### 📝 Change History
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and changes

## Quick Start

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
nano .env
# Add your values
```

### 4. Start Monitoring
```bash
make start
```

### 5. Check Status
```bash
make status
```

## Available Commands

### Basic Commands
- `make start` - Start monitoring stack
- `make stop` - Stop monitoring stack
- `make restart` - Restart monitoring stack
- `make status` - Show monitoring status
- `make logs` - Show monitoring logs

### Maintenance Commands
- `make clean` - Clean up monitoring data
- `make install` - Install monitoring stack (first time)
- `make reload-prometheus` - Reload Prometheus configuration
- `make backup-grafana` - Create Grafana backup
- `make restore-grafana` - Restore Grafana from backup

### Help
- `make help` - Show all available commands

## What's Included

### Monitoring Services
- **Prometheus** - Metrics collection
- **Grafana** - Dashboard visualization
- **Alertmanager** - Alert management
- **Node Exporter** - System metrics
- **cAdvisor** - Container metrics

### Telegram Integration
- Automatic alert notifications
- Different intervals for critical and warning alerts
- Secure token storage in environment variables

### Application Alerts
- ServiceDown (critical)
- HighErrorRate (warning)
- SlowResponseTime (warning)
- HighMemoryUsage (warning)
- HighCPUUsage (warning)
- HighGoroutineCount (warning)
- HighAPIErrorRate (warning)
- HighWebhookFailureRate (warning)
- HighRateLimitHitRate (warning)
- HighFailureRate (warning)

## Service Access

- **Prometheus**: `https://your-domain.com/prometheus/`
- **Grafana**: `https://your-domain.com/grafana/`
- **Alertmanager**: `https://your-domain.com/alertmanager/`

## Security

- ✅ All secrets stored in `.env` file (not in git)
- ✅ `.env` added to `.gitignore`
- ✅ Service access protected by authentication
- ✅ Telegram notifications only to your chat

## Support

If you encounter problems:
1. Check [SECURITY.md](SECURITY.md) for security questions
2. Study [TELEGRAM_ALERTS_SETUP.md](TELEGRAM_ALERTS_SETUP.md) for detailed setup
3. Use [QUICK_START.md](QUICK_START.md) for quick problem resolution