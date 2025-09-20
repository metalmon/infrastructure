# Monitoring Security

## Important! Secrets and Personal Data

**This is a public project! All secrets must be stored in `.env` file.**

### What should NOT go to git:

- ✅ **Bot tokens** (Telegram, Discord, etc.)
- ✅ **Chat ID** and other identifiers
- ✅ **Passwords** and authentication hashes
- ✅ **API keys** and secret keys
- ✅ **Domains** and personal data
- ✅ **Any other secrets**

### What should be in .env file:

```bash
# Telegram bot configuration
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here

# Domain configuration
DOMAIN=your-domain.com

# Authentication
METRICS_AUTH_HASH=your_metrics_auth_hash
GRAFANA_AUTH_HASH=your_grafana_auth_hash
GRAFANA_ADMIN_PASSWORD=your_grafana_password
```

## .env File Setup

### 1. Create .env file
```bash
cp env.template .env
```

### 2. Fill variables
```bash
# Edit .env file
nano .env
```

### 3. Check .gitignore
Make sure `.env` file is added to `.gitignore`:
```bash
echo ".env" >> .gitignore
```

## Authentication Hash Generation

### Use ready-made scripts:

#### Simple generation (standard usernames):
```bash
# Generate hashes for standard users
./generate-auth.sh your_password

# Result:
# METRICS_AUTH_HASH=metrics:$$2b$$10$$hash_here
# GRAFANA_AUTH_HASH=admin:$$2b$$10$$hash_here
```

#### Custom generation (custom usernames):
```bash
# Generate hashes with custom usernames
./generate-custom-auth.sh your_password metrics_user admin_user

# Result:
# METRICS_AUTH_HASH=metrics_user:$$2b$$10$$hash_here
# GRAFANA_AUTH_HASH=admin_user:$$2b$$10$$hash_here
```

### Manual generation (if needed):
```bash
# Install htpasswd (if not installed)
sudo apt-get install apache2-utils

# Generate hash for user 'metrics' with password 'password'
htpasswd -nbB metrics password
# Result: metrics:$2b$10$hash_here

# Use full result in .env file (escape $ with $$)
METRICS_AUTH_HASH=metrics:$$2b$$10$$hash_here
```

## Security Check

### 1. Check that secrets are not in git
```bash
# Check that .env is not tracked
git status

# Check that secrets are not in history
git log --all --full-history -- .env
```

### 2. Check file permissions
```bash
# .env file should be accessible only to owner
chmod 600 .env
```

### 3. Check configuration content
```bash
# Make sure configurations don't have hardcoded secrets
grep -r "bot_token\|chat_id\|password" . --exclude-dir=.git --exclude=".env"
```

## If Secrets Got Into Git

### 1. Immediately remove from history
```bash
# Remove file from git history
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch .env' \
  --prune-empty --tag-name-filter cat -- --all

# Force push changes
git push origin --force --all
```

### 2. Change all secrets
- Change bot tokens
- Change passwords
- Change API keys

### 3. Update .env file
```bash
# Create new .env with new secrets
cp env.template .env
# Fill with new values
```

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

## Best Practices

### 1. Use environment variables
```yaml
# In docker-compose.yml
env_file:
  - .env
```

### 2. Don't commit secrets
```bash
# Always check before commit
git diff --cached | grep -i "token\|password\|secret"
```

### 3. Use templates
```bash
# Create templates for documentation
cp env.template .env.example
```

### 4. Regularly rotate secrets
- Change passwords every 3-6 months
- Rotate API keys
- Update bot tokens

## Security Monitoring

### 1. Check logs
```bash
# Check logs for secret leaks
docker-compose logs | grep -i "token\|password\|secret"
```

### 2. Monitor access
- Check Alertmanager access logs
- Monitor Grafana login attempts
- Track suspicious activity

### 3. Regular audits
- Check file permissions
- Audit configurations for hardcoded secrets
- Check dependency updates

## Contacts

If you discover secret leaks:
1. Immediately change all secrets
2. Remove them from git history
3. Report the issue to the team