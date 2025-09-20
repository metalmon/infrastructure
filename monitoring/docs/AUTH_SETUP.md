# Authentication Setup

## Overview

The monitoring system uses basic authentication to protect access to services. All passwords are stored as hashes in environment variables.

## Hash Generation

### Simple Generation (Recommended)

Use standard usernames:

```bash
./generate-auth.sh your_secure_password
```

**Result:**
```
For metrics services (Prometheus, Node Exporter, cAdvisor):
  metrics:$2b$10$hash_here

For Grafana admin:
  admin:$2b$10$hash_here
```

### Custom Generation

Use your own usernames:

```bash
./generate-custom-auth.sh your_secure_password metrics_user admin_user
```

**Result:**
```
For metrics services (Prometheus, Node Exporter, cAdvisor):
  Username: metrics_user
  Hash: metrics_user:$2b$10$hash_here

For Grafana admin:
  Username: admin_user
  Hash: admin_user:$2b$10$hash_here
```

## .env File Setup

### 1. Copy template
```bash
cp env.template .env
```

### 2. Add generated hashes
```bash
nano .env
```

```bash
# Domain configuration
DOMAIN=your-domain.com

# Authentication hashes (from generate-auth.sh output)
# IMPORTANT: Use $$ to escape $ in .env files!
METRICS_AUTH_HASH=metrics:$$2b$$10$$your_generated_hash_here
GRAFANA_AUTH_HASH=admin:$$2b$$10$$your_generated_hash_here

# Telegram bot configuration
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
TELEGRAM_CHAT_ID=your_telegram_chat_id

# Grafana admin password (for initial setup)
GRAFANA_ADMIN_PASSWORD=your_secure_password
```

## Service Access

### Metrics (Prometheus, Node Exporter, cAdvisor)
- **URL**: `https://your-domain.com/prometheus/`
- **Username**: `metrics` (or your custom)
- **Password**: your password

### Grafana
- **URL**: `https://your-domain.com/grafana/`
- **Username**: `admin` (or your custom)
- **Password**: your password

## Security

### ✅ What's correct:
- Passwords stored as hashes
- Hashes generated using `htpasswd -nbB`
- Uses bcrypt algorithm (`$2b$10$`)
- All secrets in `.env` file (not in git)
- **Important**: Use `$$` to escape `$` in `.env` files!

### ❌ What's wrong:
- Storing passwords in plain text
- Using weak hashing algorithms
- Committing secrets to git

## Important: Escaping $ in .env Files

### The Problem
Bcrypt hashes start with `$2b$10$`, but in `.env` files, `$` characters are interpreted as variable references. This causes authentication to fail.

### The Solution
Use `$$` to escape each `$` character in `.env` files:

```bash
# Wrong (will not work):
METRICS_AUTH_HASH=metrics:$2b$10$hash_here

# Correct (will work):
METRICS_AUTH_HASH=metrics:$$2b$$10$$hash_here
```

### Example
If your script generates:
```
metrics:$2b$10$abc123def456
```

In `.env` file write:
```
METRICS_AUTH_HASH=metrics:$$2b$$10$$abc123def456
```

## Troubleshooting

### If you can't log into services

1. **Check hashes in .env file:**
   ```bash
   cat .env | grep AUTH_HASH
   ```

2. **Regenerate hashes:**
   ```bash
   ./generate-auth.sh your_new_password
   ```

3. **Update .env file:**
   ```bash
   nano .env
   ```

4. **Restart services:**
   ```bash
   docker-compose restart
   ```

### If scripts don't work

1. **Install htpasswd:**
   ```bash
   sudo apt-get install apache2-utils
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x generate-auth.sh
   chmod +x generate-custom-auth.sh
   ```

### If you forgot password

1. **Generate new hashes:**
   ```bash
   ./generate-auth.sh your_new_password
   ```

2. **Update .env file**

3. **Restart services**

## Recommendations

### Passwords
- Use complex passwords (minimum 12 characters)
- Include letters, numbers and special characters
- Don't use same passwords for different services

### Rotation
- Change passwords every 3-6 months
- Update hashes when changing passwords
- Test access after changes

### Monitoring
- Check logs for suspicious activity
- Monitor login attempts
- Set up alerts for multiple failed login attempts