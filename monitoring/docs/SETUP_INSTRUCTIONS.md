# Monitoring Setup Instructions with Telegram Alerts

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

### 3. Fill .env File
```bash
nano .env
# Required variables:
DOMAIN=your-domain.com
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_CHAT_ID=your_telegram_chat_id
METRICS_AUTH_HASH=metrics:$$2b$$10$$generated_hash
GRAFANA_AUTH_HASH=admin:$$2b$$10$$generated_hash
GRAFANA_ADMIN_PASSWORD=your_secure_password
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

## Service Access

- **Prometheus**: `https://your-domain.com/prometheus/`
- **Grafana**: `https://your-domain.com/grafana/`
- **Alertmanager**: `https://your-domain.com/alertmanager/`

## What Works

### Telegram Alerts
- **Critical**: repeat every 30 minutes
- **Warnings**: repeat every 2 hours
- **Regular**: repeat every hour

### Alert Types
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

## Security

- ✅ All secrets in `.env` file (not in git)
- ✅ `.env` added to `.gitignore`
- ✅ Service access protected by authentication
- ✅ Telegram notifications only to your chat

## Documentation

- `TELEGRAM_ALERTS_SETUP.md` - detailed instructions
- `QUICK_START.md` - quick start
- `SECURITY.md` - security guide
- `env.template` - environment variables template

## Troubleshooting

### If alerts don't arrive
1. Check logs: `make logs`
2. Make sure bot is added to chat
3. Check chat ID correctness

### If services don't start
1. Check logs: `make logs`
2. Make sure .env file is filled
3. Check file permissions

## Testing

### Create test alert
In `alert_rules.yml` add:
```yaml
- alert: TestAlert
  expr: vector(1)
  for: 0m
  labels:
    severity: warning
  annotations:
    summary: "Test alert"
    description: "This is a test alert"
```

### Check in Prometheus
1. Open Prometheus
2. Go to "Alerts"
3. Find "TestAlert"
4. Alert should appear and notification should be sent to Telegram