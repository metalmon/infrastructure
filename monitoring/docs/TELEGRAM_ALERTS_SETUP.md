# Telegram Alerts Setup for Prometheus

## What Was Configured

### 1. Alertmanager Configuration
- Created `alertmanager.yml` file with Telegram bot settings
- Configured single recipient with different repeat intervals for critical and warning alerts
- Uses environment variables from `.env` file for security

### 2. Docker Compose Updates
- Added Alertmanager service to `docker-compose.yml`
- Configured access through Traefik at `/alertmanager/`
- Added volume for Alertmanager data storage

### 3. Prometheus Configuration
- Updated `prometheus.yml` to connect to Alertmanager
- Added application alert rules

### 4. Alert Rules
- Added application-specific alerts:
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

## How to Start

### 1. Setup Environment Variables
```bash
cd infrastructure/monitoring
cp env.template .env
# Edit .env file and add your values:
# - TELEGRAM_BOT_TOKEN=your_bot_token
# - TELEGRAM_CHAT_ID=your_chat_id
# - DOMAIN=your_domain
# - METRICS_AUTH_HASH=your_auth_hash
# - GRAFANA_AUTH_HASH=your_grafana_hash
# - GRAFANA_ADMIN_PASSWORD=your_grafana_password
```

### 2. Restart Monitoring
```bash
make restart
```

### 3. Check Service Status
```bash
make status
```

### 4. Check Alertmanager
- Open `https://your-domain.com/alertmanager/`
- Login/password same as for Prometheus

### 5. Check Prometheus
- Open `https://your-domain.com/prometheus/`
- Go to "Alerts" section - new rules should appear

## How Alerts Work

### 1. Prometheus
- Collects metrics every 15 seconds
- Checks alert rules every 15 seconds
- Sends alerts to Alertmanager

### 2. Alertmanager
- Receives alerts from Prometheus
- Groups alerts by name
- Sends notifications to Telegram

### 3. Telegram Notifications
- **Critical alerts**: repeat every 30 minutes
- **Warnings**: repeat every 2 hours
- **Regular alerts**: repeat every hour

## Notification Format

### Critical Alerts
```
🔥 CRITICAL ALERT: ServiceDown

Status: firing
Severity: critical

Summary: Service is down
Description: Application service is not responding
Instance: app:8080
Job: app
Time: 2024-01-15 14:30:25
```

### Warnings
```
⚠️ Warning: HighErrorRate

Status: firing
Severity: warning

Summary: High error rate detected
Description: Application error rate is 0.15 errors per second
Instance: app:8080
Job: app
Time: 2024-01-15 14:30:25
```

## Service Access

- **Prometheus**: `https://your-domain.com/prometheus/`
- **Grafana**: `https://your-domain.com/grafana/`
- **Alertmanager**: `https://your-domain.com/alertmanager/`

## Alert Threshold Configuration

You can change thresholds in `alert_rules.yml`:

```yaml
# Change error threshold from 0.1 to 0.05
expr: rate(http_requests_total{job="app",status=~"5.."}[5m]) > 0.05

# Change memory threshold from 500MB to 1GB
expr: process_resident_memory_bytes{job="app"} > 1000000000

# Change CPU threshold from 0.8 to 0.9
expr: rate(process_cpu_seconds_total{job="app"}[5m]) > 0.9
```

## Alert Testing

### Test Alert
You can create a test alert:

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

### Telegram Bot Check
Make sure bot can send messages to your chat:
- Bot should be added to chat
- Bot should have permission to send messages
- Chat ID should be correct

## Troubleshooting

### If alerts don't arrive
1. Check logs: `make logs`
2. Make sure bot is added to chat
3. Check chat ID correctness

### If services don't start
1. Check logs: `make logs`
2. Make sure ports are free
3. Check file permissions

## Additional Settings

### Change repeat intervals
In `alertmanager.yml`:
```yaml
repeat_interval: 30m  # For critical
repeat_interval: 2h   # For warnings
```

### Add new recipients
```yaml
receivers:
  - name: 'telegram-critical'
    telegram_configs:
      - bot_token: 'YOUR_BOT_TOKEN'
        chat_id: 'YOUR_CHAT_ID'
```

### Configure grouping
```yaml
route:
  group_by: ['alertname', 'instance']
  group_wait: 10s
  group_interval: 10s
```

## Security

- Bot token stored in Alertmanager configuration
- Access to Alertmanager protected by basic authentication
- All notifications sent only to your chat

## Alert Monitoring

- You can create dashboard in Grafana for alert monitoring
- You can view alert statistics in Prometheus
- You can view active alerts in Alertmanager