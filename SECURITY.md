# 🔒 Server Security Setup Guide

Complete guide for securing your server with SSH keys and firewall configuration.

## 📋 Prerequisites

- Root or sudo access to the server
- Access to the server via SSH
- Your local SSH key pair

## 🔑 SSH Key Setup

### 1. Generate SSH Key Pair (on your local machine)

```bash
# Generate new SSH key pair
ssh-keygen -t ed25519 -C "your-email@example.com"

# Or use RSA if ed25519 is not supported
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"
```

### 2. Copy Public Key to Server

```bash
# Method 1: Using ssh-copy-id (recommended)
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@your-server-ip

# Method 2: Manual copy
cat ~/.ssh/id_ed25519.pub | ssh user@your-server-ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"

# Method 3: Copy and paste manually
cat ~/.ssh/id_ed25519.pub
# Copy the output and paste it to ~/.ssh/authorized_keys on the server
```

### 3. Test SSH Key Authentication

```bash
# Test connection
ssh -i ~/.ssh/id_ed25519 user@your-server-ip

# If successful, you should connect without password prompt
```

## 🛡️ SSH Server Configuration

### 1. Edit SSH Configuration

```bash
# Edit SSH daemon configuration
sudo nano /etc/ssh/sshd_config
```

### 2. Recommended SSH Settings

```bash
# Disable password authentication
PasswordAuthentication no

# Disable root login
PermitRootLogin no

# Allow only specific users (optional)
AllowUsers your-username

# Change default SSH port (optional, for extra security)
Port 2222

# Disable X11 forwarding
X11Forwarding no

# Disable empty passwords
PermitEmptyPasswords no

# Set maximum authentication attempts
MaxAuthTries 3

# Set login grace time
LoginGraceTime 30

# Disable DNS lookup
UseDNS no
```

### 3. Restart SSH Service

```bash
# Test configuration
sudo sshd -t

# If test passes, restart SSH service
sudo systemctl restart sshd

# Check SSH service status
sudo systemctl status sshd
```

### 4. Important: Keep SSH Session Open

**⚠️ CRITICAL**: Before restarting SSH, make sure you have another SSH session open or you can access the server via console. If SSH configuration is wrong, you might lose access!

```bash
# Open second SSH session before restarting
ssh user@your-server-ip

# In the second session, restart SSH
sudo systemctl restart sshd
```

## 🔥 Firewall Configuration

### 1. Install and Enable UFW (Ubuntu/Debian)

```bash
# Install UFW
sudo apt update
sudo apt install ufw

# Enable UFW
sudo ufw enable

# Check status
sudo ufw status verbose
```

### 2. Configure Basic Firewall Rules

```bash
# Deny all incoming connections by default
sudo ufw default deny incoming

# Allow all outgoing connections
sudo ufw default allow outgoing

# Allow SSH (adjust port if you changed it)
sudo ufw allow ssh
# Or if you changed SSH port:
sudo ufw allow 2222/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow Docker networks (if needed)
sudo ufw allow from 172.16.0.0/12
sudo ufw allow from 192.168.0.0/16
sudo ufw allow from 10.0.0.0/8
```

### 3. Advanced Firewall Rules

```bash
# Allow specific IP addresses only (optional)
sudo ufw allow from YOUR_TRUSTED_IP to any port 22

# Allow specific services (only if NOT using Traefik)
# sudo ufw allow 8080/tcp  # For Traefik dashboard (if needed)
# sudo ufw allow 9090/tcp  # For Prometheus (if needed)
# sudo ufw allow 3000/tcp  # For Grafana (if needed)

# NOTE: If using Traefik reverse proxy, these ports should NOT be opened externally
# Traefik handles all external access through ports 80 and 443

# Deny specific ports
sudo ufw deny 3306/tcp  # MySQL
sudo ufw deny 5432/tcp  # PostgreSQL
sudo ufw deny 6379/tcp  # Redis
```

### 4. Firewall for CentOS/RHEL (iptables)

```bash
# Install iptables-services
sudo yum install iptables-services

# Enable iptables
sudo systemctl enable iptables
sudo systemctl start iptables

# Basic rules
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -A INPUT -j DROP

# Save rules
sudo service iptables save
```

## 🔍 Security Hardening

### 1. Update System

```bash
# Update package lists
sudo apt update  # Ubuntu/Debian
sudo yum update  # CentOS/RHEL

# Upgrade packages
sudo apt upgrade  # Ubuntu/Debian
sudo yum upgrade  # CentOS/RHEL
```

### 2. Install Fail2Ban

```bash
# Install Fail2Ban
sudo apt install fail2ban  # Ubuntu/Debian
sudo yum install fail2ban   # CentOS/RHEL

# Configure Fail2Ban
sudo nano /etc/fail2ban/jail.local
```

Add to `/etc/fail2ban/jail.local`:
```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3
```

```bash
# Start Fail2Ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status
```

### 3. Disable Unnecessary Services

```bash
# List running services
sudo systemctl list-units --type=service --state=running

# Disable unnecessary services
sudo systemctl disable bluetooth
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
sudo systemctl disable snapd
```

### 4. Configure Automatic Security Updates

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades

# Configure automatic updates
sudo dpkg-reconfigure unattended-upgrades

# Enable automatic updates
echo 'Unattended-Upgrade::Automatic-Reboot "false";' | sudo tee -a /etc/apt/apt.conf.d/50unattended-upgrades
```

## 🚨 Emergency Access

### 1. Console Access

If you lose SSH access, you can still access the server via:
- **VPS Console**: Most VPS providers offer web-based console access
- **Physical Console**: For dedicated servers
- **Recovery Mode**: Boot into recovery mode

### 2. Emergency SSH Recovery

```bash
# Boot into recovery mode
# Mount root filesystem
mount -o remount,rw /

# Edit SSH configuration
nano /etc/ssh/sshd_config

# Restart SSH
systemctl restart sshd
```

### 3. Backup SSH Configuration

```bash
# Create backup of SSH config
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Create backup of authorized_keys
cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.backup
```

## 🔧 Docker Security

### 1. Secure Docker Daemon

```bash
# Create Docker daemon configuration
sudo mkdir -p /etc/docker
sudo nano /etc/docker/daemon.json
```

Add to `/etc/docker/daemon.json`:
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "live-restore": true,
  "userland-proxy": false,
  "no-new-privileges": true
}
```

### 2. Docker Network Security

```bash
# Create isolated networks
docker network create --driver bridge traefik
docker network create --driver bridge monitoring

# Use non-default networks for applications
docker network create --driver bridge app-network
```

## 📊 Security Monitoring

### 1. Log Monitoring

```bash
# Monitor SSH logs
sudo tail -f /var/log/auth.log

# Monitor system logs
sudo journalctl -f

# Monitor Docker logs
docker logs -f container-name
```

### 2. Security Scanning

```bash
# Install Lynis for security auditing
sudo apt install lynis

# Run security audit
sudo lynis audit system

# Install ClamAV for malware scanning
sudo apt install clamav clamav-daemon
sudo freshclam
sudo clamscan -r /home
```

## 🎯 Infrastructure-Specific Security

### 1. Traefik Security

**⚠️ IMPORTANT: Port Security with Traefik**

When using Traefik as reverse proxy, **DO NOT** open internal service ports externally:

```bash
# ❌ WRONG - Don't do this with Traefik
sudo ufw allow 8080/tcp  # Traefik dashboard
sudo ufw allow 9090/tcp  # Prometheus  
sudo ufw allow 3000/tcp  # Grafana

# ✅ CORRECT - Only open these ports
sudo ufw allow 80/tcp    # HTTP (redirects to HTTPS)
sudo ufw allow 443/tcp   # HTTPS (Traefik handles all services)
sudo ufw allow 22/tcp    # SSH
```

**Why this is important:**
- Traefik acts as a single entry point
- All services are accessed through HTTPS (port 443)
- Internal ports (8080, 9090, 3000) should only be accessible within Docker network
- Opening internal ports externally creates security vulnerabilities

**Correct Docker configuration:**
```yaml
# In docker-compose.yml - services should NOT expose ports externally
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

```bash
# Use strong passwords for Basic Auth
cd infrastructure/monitoring
./generate-auth.sh

# Enable rate limiting in Traefik
# Add to traefik.yml:
```

```yaml
# Rate limiting middleware
http:
  middlewares:
    rate-limit:
      rateLimit:
        burst: 100
        average: 50
```

### 2. Monitoring Security

```bash
# Secure Prometheus
# Add to prometheus.yml:
```

```yaml
global:
  external_labels:
    cluster: 'production'
    replica: 'A'

# Enable authentication
web:
  basic_auth_users:
    admin: $2y$10$hashedpassword
```

## 📝 Security Checklist

- [ ] SSH key authentication enabled
- [ ] Password authentication disabled
- [ ] Root login disabled
- [ ] SSH port changed (optional)
- [ ] Firewall configured and enabled
- [ ] Unnecessary services disabled
- [ ] Automatic security updates enabled
- [ ] Fail2Ban installed and configured
- [ ] Strong passwords for all services
- [ ] Regular security audits scheduled
- [ ] Backup of SSH configuration
- [ ] Emergency access plan documented

## 🚨 Troubleshooting

### SSH Connection Issues

```bash
# Check SSH service status
sudo systemctl status sshd

# Check SSH logs
sudo journalctl -u sshd

# Test SSH configuration
sudo sshd -t

# Check firewall
sudo ufw status
```

### Firewall Issues

```bash
# Check UFW status
sudo ufw status verbose

# Check iptables rules
sudo iptables -L

# Reset firewall (emergency only)
sudo ufw --force reset
```

## 📞 Support

If you encounter security issues:

1. **Check logs**: `/var/log/auth.log`, `/var/log/syslog`
2. **Verify SSH configuration**: `sudo sshd -t`
3. **Check firewall status**: `sudo ufw status`
4. **Test from different IP**: Ensure rules work correctly
5. **Use console access**: If SSH is completely broken

## 🔐 Additional Security Tips

1. **Regular Updates**: Keep system and packages updated
2. **Strong Passwords**: Use complex passwords for all services
3. **Two-Factor Authentication**: Enable 2FA where possible
4. **Regular Backups**: Backup important configurations
5. **Monitor Access**: Log and monitor all access attempts
6. **Principle of Least Privilege**: Give minimal necessary permissions
7. **Network Segmentation**: Isolate services in separate networks
8. **Encryption**: Use encryption for sensitive data
9. **Audit Logs**: Regularly review security logs
10. **Incident Response**: Have a plan for security incidents
