# 🔒 Security Architecture

This document explains the security architecture of the universal infrastructure stack.

## 🏗️ Network Architecture

```
Internet
    ↓
┌─────────────────┐
│   Firewall      │ ← Only ports 22, 80, 443 open
│   (UFW)         │
└─────────────────┘
    ↓
┌─────────────────┐
│   Traefik       │ ← Single entry point
│   (Reverse Proxy)│
└─────────────────┘
    ↓
┌─────────────────┐
│   Docker        │ ← Internal network
│   Network       │
└─────────────────┘
    ↓
┌─────────────────┐
│   Services      │ ← No external ports
│   (Prometheus,  │
│   Grafana, etc.)│
└─────────────────┘
```

## 🔐 Security Layers

### Layer 1: Network Security
- **Firewall (UFW)**: Only essential ports open (22, 80, 443)
- **No Direct Access**: Internal services not accessible from outside
- **Network Isolation**: Services run in isolated Docker networks

### Layer 2: Reverse Proxy Security
- **Single Entry Point**: Traefik handles all external traffic
- **SSL Termination**: Automatic HTTPS with Let's Encrypt
- **Path-based Routing**: Services accessible via path prefixes
- **Rate Limiting**: Protection against DDoS attacks

### Layer 3: Authentication Security
- **HTTP Basic Auth**: All services protected with username/password
- **Strong Passwords**: Generated with bcrypt hashing
- **Service Isolation**: Different credentials for different services

### Layer 4: Application Security
- **Container Isolation**: Each service runs in its own container
- **Resource Limits**: Docker resource constraints
- **Read-only Filesystems**: Where possible
- **Non-root Users**: Services run as non-privileged users

## 🚫 What's NOT Exposed

### Internal Ports (Blocked by Firewall)
- **8080**: Traefik Dashboard (local access only)
- **9090**: Prometheus (internal only)
- **3000**: Grafana (internal only)
- **9100**: Node Exporter (internal only)
- **8080**: cAdvisor (internal only)

### Database Ports (Blocked by Firewall)
- **3306**: MySQL
- **5432**: PostgreSQL
- **6379**: Redis
- **27017**: MongoDB

### Other Dangerous Ports
- **21**: FTP
- **23**: Telnet
- **25**: SMTP
- **53**: DNS
- **110**: POP3
- **143**: IMAP
- **993**: IMAPS
- **995**: POP3S

## ✅ What's Exposed

### Essential Ports Only
- **22**: SSH (with key authentication only)
- **80**: HTTP (redirects to HTTPS)
- **443**: HTTPS (Traefik handles all services)

## 🔧 Security Configuration

### Firewall Rules
```bash
# Default deny all incoming
sudo ufw default deny incoming

# Allow essential ports only
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Explicitly deny dangerous ports
sudo ufw deny 3306/tcp   # MySQL
sudo ufw deny 5432/tcp   # PostgreSQL
sudo ufw deny 6379/tcp   # Redis
```

### Docker Network Configuration
```yaml
# Services should NOT expose ports externally
services:
  prometheus:
    # ports:
    #   - "9090:9090"  # ❌ Remove this line
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.prometheus.rule=Host(`${DOMAIN}`) && PathPrefix(`/prometheus`)"
      - "traefik.http.routers.prometheus.entrypoints=websecure"
      - "traefik.http.routers.prometheus.tls.certresolver=letsencrypt"
```

### Traefik Security Labels
```yaml
# Basic authentication
- "traefik.http.middlewares.prometheus-auth.basicauth.users=${METRICS_AUTH_HASH}"

# Rate limiting
- "traefik.http.middlewares.rate-limit.ratelimit.burst=100"
- "traefik.http.middlewares.rate-limit.ratelimit.average=50"

# Security headers
- "traefik.http.middlewares.security-headers.headers.customrequestheaders.X-Forwarded-Proto=https"
- "traefik.http.middlewares.security-headers.headers.customresponseheaders.X-Frame-Options=DENY"
- "traefik.http.middlewares.security-headers.headers.customresponseheaders.X-Content-Type-Options=nosniff"
```

## 🚨 Security Benefits

### 1. **Single Entry Point**
- All traffic goes through Traefik
- Centralized security policies
- Easy to monitor and log

### 2. **No Direct Service Access**
- Services not accessible from outside
- Reduced attack surface
- Internal network isolation

### 3. **Automatic HTTPS**
- Let's Encrypt certificates
- No plaintext traffic
- Modern security standards

### 4. **Authentication Required**
- All services protected
- Strong password policies
- Different credentials per service

### 5. **Network Segmentation**
- Services isolated in Docker networks
- No cross-service communication
- Controlled access patterns

## 🔍 Security Monitoring

### Log Monitoring
- **SSH Logs**: `/var/log/auth.log`
- **Traefik Logs**: Docker container logs
- **System Logs**: `/var/log/syslog`
- **Fail2Ban Logs**: `/var/log/fail2ban.log`

### Metrics Collection
- **Prometheus**: Collects security metrics
- **Grafana**: Visualizes security data
- **Alerts**: Automatic security notifications

### Regular Checks
- **Security Audit**: `./security-check.sh`
- **Port Scan**: Check for open ports
- **Service Status**: Monitor service health
- **Update Status**: Check for security patches

## 🛡️ Security Best Practices

### 1. **Principle of Least Privilege**
- Services run with minimal permissions
- Users have only necessary access
- Network access restricted to essentials

### 2. **Defense in Depth**
- Multiple security layers
- No single point of failure
- Redundant security measures

### 3. **Regular Updates**
- Automatic security patches
- Regular dependency updates
- Security monitoring

### 4. **Monitoring and Alerting**
- Real-time security monitoring
- Automated alerts
- Regular security audits

## 🚨 Incident Response

### If Security Breach Detected
1. **Immediate Response**
   - Block suspicious IPs
   - Check service logs
   - Verify service integrity

2. **Investigation**
   - Analyze attack vectors
   - Check for data compromise
   - Document findings

3. **Recovery**
   - Patch vulnerabilities
   - Update security policies
   - Restore from backups if needed

4. **Prevention**
   - Update security measures
   - Improve monitoring
   - Train team on new threats

## 📊 Security Metrics

### Key Security Indicators
- **Failed Login Attempts**: Monitor brute force attacks
- **Port Scan Attempts**: Detect reconnaissance
- **SSL Certificate Status**: Ensure valid certificates
- **Service Availability**: Monitor service health
- **Resource Usage**: Detect unusual activity

### Security Dashboards
- **System Overview**: General security status
- **Network Traffic**: Monitor network activity
- **Service Health**: Check service status
- **Alert History**: Review security events

## 🔧 Security Tools

### Built-in Tools
- **UFW**: Firewall management
- **Fail2Ban**: Intrusion prevention
- **Traefik**: Reverse proxy security
- **Docker**: Container isolation

### Monitoring Tools
- **Prometheus**: Metrics collection
- **Grafana**: Security visualization
- **Node Exporter**: System metrics
- **cAdvisor**: Container metrics

### Security Scripts
- **setup-security.sh**: Automated security setup
- **security-check.sh**: Security audit
- **generate-auth.sh**: Password generation

## 📚 Additional Resources

- [SECURITY.md](SECURITY.md) - Detailed security setup guide
- [DNS_SETUP.md](DNS_SETUP.md) - DNS configuration
- [Traefik Documentation](https://doc.traefik.io/traefik/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
