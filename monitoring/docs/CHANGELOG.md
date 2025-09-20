# Changelog

## Version 2.0.0 - Telegram Alerts Integration

### ✨ New Features

- **Telegram integration** - automatic alert notifications
- **Alertmanager** - alert management and notifications
- **Security** - all secrets in environment variables
- **Documentation organization** - all documentation in `docs/` folder

### 🔧 Changes

#### Security
- ✅ All secrets moved to `.env` file
- ✅ `.env` added to `.gitignore`
- ✅ Created `env.template` for documentation
- ✅ Updated all configurations to use environment variables

#### Telegram Alerts
- ✅ Added Alertmanager to `docker-compose.yml`
- ✅ Created `alertmanager.yml` configuration
- ✅ Added application alert rules to `alert_rules.yml`
- ✅ Configured different intervals for critical and warning alerts

#### Documentation
- ✅ All documentation moved to `docs/` folder
- ✅ Created main README for documentation
- ✅ Updated main project README
- ✅ Added security guide
- ✅ Created project structure guide

### 🚨 Application Alerts

- **ServiceDown** (critical) - service unavailable
- **HighErrorRate** (warning) - high error frequency
- **SlowResponseTime** (warning) - slow response time
- **HighMemoryUsage** (warning) - high memory usage
- **HighCPUUsage** (warning) - high CPU usage
- **HighGoroutineCount** (warning) - many goroutines
- **HighAPIErrorRate** (warning) - High API error rate
- **HighWebhookFailureRate** (warning) - high webhook error rate
- **HighRateLimitHitRate** (warning) - frequent rate limit hits
- **HighFailureRate** (warning) - high failure rate

### 📁 New Structure

```
infrastructure/monitoring/
├── 📁 docs/                          # All documentation
│   ├── README.md                     # Documentation overview
│   ├── SETUP_INSTRUCTIONS.md         # Complete setup guide
│   ├── QUICK_START.md                # Quick start
│   ├── TELEGRAM_ALERTS_SETUP.md      # Alert setup
│   ├── SECURITY.md                   # Security
│   ├── AUTH_SETUP.md                 # Authentication setup
│   ├── PROJECT_STRUCTURE.md          # Project structure
│   └── CHANGELOG.md                  # This file
├── 📄 alertmanager.yml                # Alertmanager configuration
├── 📄 env.template                    # Environment variables template
├── 📄 .env                           # Environment variables (not in git)
├── 📄 generate-auth.sh               # Hash generation script
├── 📄 generate-custom-auth.sh         # Custom generation script
└── 📄 .gitignore                     # Git exclusions
```

### 🔄 Migration

#### For existing users:

1. **Create .env file:**
   ```bash
   cd infrastructure/monitoring
   cp env.template .env
   ```

2. **Generate authentication hashes:**
   ```bash
   ./generate-auth.sh your_secure_password
   ```

3. **Fill .env file:**
   ```bash
   nano .env  # Add generated hashes
   ```

4. **Restart monitoring:**
   ```bash
   make restart
   ```

5. **Check status:**
   ```bash
   make status
   ```

### 📚 Documentation

- **[docs/README.md](README.md)** - Overview of all documentation
- **[docs/SETUP_INSTRUCTIONS.md](SETUP_INSTRUCTIONS.md)** - Complete setup guide
- **[docs/QUICK_START.md](QUICK_START.md)** - Quick start guide
- **[docs/TELEGRAM_ALERTS_SETUP.md](TELEGRAM_ALERTS_SETUP.md)** - Telegram alerts setup
- **[docs/MAKE_COMMANDS.md](MAKE_COMMANDS.md)** - Complete make commands reference
- **[docs/SECURITY.md](SECURITY.md)** - Security guide
- **[docs/AUTH_SETUP.md](AUTH_SETUP.md)** - Authentication setup
- **[docs/ENV_FILE_TIPS.md](ENV_FILE_TIPS.md)** - Important .env file tips
- **[docs/PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Project structure

### 🎯 What's Next

- Set up environment variables in `.env` file
- Start monitoring with new features
- Set up Telegram bot for notifications
- Study documentation in `docs/` folder

---

**Version 1.0.0** - Basic monitoring setup with Prometheus, Grafana and Traefik