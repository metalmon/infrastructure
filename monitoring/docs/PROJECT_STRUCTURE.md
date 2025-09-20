# Project Structure

## Overview

The monitoring project is organized as follows:

```
infrastructure/monitoring/
├── 📁 docs/                          # All documentation
│   ├── README.md                     # Documentation overview
│   ├── SETUP_INSTRUCTIONS.md         # Complete setup guide
│   ├── QUICK_START.md                # Quick start
│   ├── TELEGRAM_ALERTS_SETUP.md      # Telegram alerts setup
│   ├── SECURITY.md                   # Security guide
│   ├── AUTH_SETUP.md                 # Authentication setup
│   ├── PROJECT_STRUCTURE.md          # This file
│   └── CHANGELOG.md                  # Version history
├── 📁 grafana/                       # Grafana configuration
│   ├── provisioning/                 # Automatic setup
│   └── dashboards/                   # Dashboards
├── 📄 docker-compose.yml             # Docker Compose configuration
├── 📄 prometheus.yml                 # Prometheus configuration
├── 📄 alertmanager.yml               # Alertmanager configuration
├── 📄 alert_rules.yml                # Alert rules
├── 📄 env.template                   # Environment variables template
├── 📄 .env                           # Environment variables (not in git)
├── 📄 .gitignore                     # Git exclusions
├── 📄 README.md                      # Main README
├── 📄 Makefile                       # Management commands
└── 📄 generate-auth.sh               # Authentication generation script
```

## File Description

### Configuration Files

- **`docker-compose.yml`** - Main Docker Compose configuration
- **`prometheus.yml`** - Prometheus configuration (metrics collection)
- **`alertmanager.yml`** - Alertmanager configuration (alert management)
- **`alert_rules.yml`** - Alert rules for Prometheus

### Environment Variables

- **`env.template`** - Template for creating `.env` file
- **`.env`** - Real environment variables (not in git)
- **`.gitignore`** - Excludes secret files from git

### Documentation

- **`docs/README.md`** - Overview of all documentation
- **`docs/SETUP_INSTRUCTIONS.md`** - Complete setup guide
- **`docs/QUICK_START.md`** - Quick start for experienced users
- **`docs/TELEGRAM_ALERTS_SETUP.md`** - Detailed Telegram alerts guide
- **`docs/SECURITY.md`** - Security guide
- **`docs/AUTH_SETUP.md`** - Authentication setup guide

### Services

- **Prometheus** - Metrics collection and storage
- **Grafana** - Dashboard visualization
- **Alertmanager** - Alert management
- **Node Exporter** - System metrics
- **cAdvisor** - Container metrics

## Organization Principles

### 1. Separation of Configuration and Secrets
- Configuration in YAML files
- Secrets in `.env` file
- Templates for documentation

### 2. Documentation in Separate Folder
- All documentation in `docs/`
- Clear structure and navigation
- Separate files for different topics

### 3. Security
- `.env` file doesn't go to git
- All secrets in environment variables
- Security documentation

### 4. Ease of Use
- Clear setup instructions
- Quick start for experienced users
- Detailed guides for beginners

## Adding New Components

### New Monitoring Service
1. Add to `docker-compose.yml`
2. Configure in `prometheus.yml`
3. Update documentation in `docs/`

### New Alerts
1. Add rules to `alert_rules.yml`
2. Update documentation
3. Test alerts

### New Dashboards
1. Create JSON file in `grafana/dashboards/`
2. Configure in `grafana/provisioning/`
3. Update documentation

## Support

If you have questions about project structure:
1. Study documentation in `docs/`
2. Check configuration files
3. Refer to security guide