#!/bin/bash

# Security Check Script
# Usage: ./security-check.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user."
    exit 1
fi

print_header "Security Status Check"
echo "Date: $(date)"
echo "User: $(whoami)"
echo "Hostname: $(hostname)"
echo

# SSH Configuration Check
print_header "SSH Configuration"
if systemctl is-active --quiet sshd; then
    print_success "SSH service is running"
else
    print_error "SSH service is not running"
fi

# Check SSH port
SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config 2>/dev/null | awk '{print $2}' || echo "22")
print_info "SSH Port: $SSH_PORT"

# Check password authentication
if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    print_success "Password authentication is disabled"
else
    print_warning "Password authentication is enabled"
fi

# Check root login
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
    print_success "Root login is disabled"
else
    print_warning "Root login is enabled"
fi

echo

# Firewall Check
print_header "Firewall Status"
if command -v ufw >/dev/null 2>&1; then
    if ufw status | grep -q "Status: active"; then
        print_success "UFW firewall is active"
        echo "Rules:"
        ufw status | grep -E "^(22|80|443)" | sed 's/^/  /'
        
        # Check for dangerous open ports
        DANGEROUS_PORTS=$(ufw status | grep -E "^(8080|9090|3000|3306|5432|6379)" | wc -l)
        if [ "$DANGEROUS_PORTS" -gt 0 ]; then
            print_warning "Potentially dangerous ports are open externally:"
            ufw status | grep -E "^(8080|9090|3000|3306|5432|6379)" | sed 's/^/  /'
            print_warning "If using Traefik, these ports should NOT be opened externally"
        else
            print_success "No dangerous ports are open externally"
        fi
    else
        print_warning "UFW firewall is not active"
    fi
elif command -v iptables >/dev/null 2>&1; then
    print_info "Checking iptables rules..."
    if iptables -L | grep -q "DROP"; then
        print_success "iptables has DROP rules"
    else
        print_warning "iptables may not be properly configured"
    fi
else
    print_error "No firewall detected"
fi

echo

# Fail2Ban Check
print_header "Fail2Ban Status"
if systemctl is-active --quiet fail2ban; then
    print_success "Fail2Ban is running"
    echo "Jails:"
    fail2ban-client status 2>/dev/null | grep "Jail list" | sed 's/^/  /'
else
    print_warning "Fail2Ban is not running"
fi

echo

# System Updates Check
print_header "System Updates"
if command -v apt >/dev/null 2>&1; then
    UPDATES=$(apt list --upgradable 2>/dev/null | wc -l)
    if [ "$UPDATES" -gt 1 ]; then
        print_warning "$UPDATES packages can be updated"
    else
        print_success "System is up to date"
    fi
elif command -v yum >/dev/null 2>&1; then
    UPDATES=$(yum check-update 2>/dev/null | wc -l)
    if [ "$UPDATES" -gt 0 ]; then
        print_warning "$UPDATES packages can be updated"
    else
        print_success "System is up to date"
    fi
fi

echo

# SSH Key Check
print_header "SSH Keys"
if [ -f ~/.ssh/id_ed25519.pub ]; then
    print_success "ED25519 SSH key found"
elif [ -f ~/.ssh/id_rsa.pub ]; then
    print_success "RSA SSH key found"
else
    print_warning "No SSH key found"
fi

# Check authorized_keys
if [ -f ~/.ssh/authorized_keys ]; then
    KEY_COUNT=$(wc -l < ~/.ssh/authorized_keys)
    print_info "Authorized keys: $KEY_COUNT"
else
    print_warning "No authorized_keys file found"
fi

echo

# Recent SSH Activity
print_header "Recent SSH Activity"
echo "Recent successful logins:"
grep "Accepted" /var/log/auth.log 2>/dev/null | tail -3 | sed 's/^/  /' || echo "  No recent logins found"

echo
echo "Recent failed attempts:"
grep "Failed password" /var/log/auth.log 2>/dev/null | tail -3 | sed 's/^/  /' || echo "  No failed attempts found"

echo

# Docker Security Check
print_header "Docker Security"
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        print_success "Docker is running"
        
        # Check if running as root
        if docker info 2>/dev/null | grep -q "Root Dir: /var/lib/docker"; then
            print_warning "Docker is running as root"
        fi
        
        # Check for exposed ports
        EXPOSED_PORTS=$(docker ps --format "table {{.Ports}}" | grep -v "PORTS" | grep -v "^$" | wc -l)
        if [ "$EXPOSED_PORTS" -gt 0 ]; then
            print_info "Exposed Docker ports: $EXPOSED_PORTS"
        fi
    else
        print_warning "Docker is not running or not accessible"
    fi
else
    print_info "Docker is not installed"
fi

echo

# Network Security Check
print_header "Network Security"
# Check listening ports
print_info "Listening ports:"
netstat -tlnp 2>/dev/null | grep LISTEN | awk '{print $4}' | sort -u | sed 's/^/  /' || echo "  Unable to check ports"

echo

# Check for suspicious processes
print_info "Suspicious processes:"
ps aux | grep -E "(nc|netcat|nmap|masscan)" | grep -v grep | sed 's/^/  /' || echo "  No suspicious processes found"

echo

# Disk Space Check
print_header "System Resources"
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    print_error "Disk usage is high: ${DISK_USAGE}%"
elif [ "$DISK_USAGE" -gt 80 ]; then
    print_warning "Disk usage is moderate: ${DISK_USAGE}%"
else
    print_success "Disk usage is normal: ${DISK_USAGE}%"
fi

# Memory usage
MEMORY_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ "$MEMORY_USAGE" -gt 90 ]; then
    print_error "Memory usage is high: ${MEMORY_USAGE}%"
elif [ "$MEMORY_USAGE" -gt 80 ]; then
    print_warning "Memory usage is moderate: ${MEMORY_USAGE}%"
else
    print_success "Memory usage is normal: ${MEMORY_USAGE}%"
fi

echo

# Security Recommendations
print_header "Security Recommendations"
echo "Based on the security check, consider the following:"
echo

if ! grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config 2>/dev/null; then
    echo "  • Disable password authentication in SSH"
fi

if ! grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
    echo "  • Disable root login in SSH"
fi

if ! ufw status | grep -q "Status: active" 2>/dev/null; then
    echo "  • Enable UFW firewall"
fi

# Check for dangerous ports
if ufw status 2>/dev/null | grep -q -E "^(8080|9090|3000|3306|5432|6379)"; then
    echo "  • Close dangerous ports (8080, 9090, 3000, 3306, 5432, 6379) if using Traefik"
fi

if ! systemctl is-active --quiet fail2ban; then
    echo "  • Install and configure Fail2Ban"
fi

if [ "$UPDATES" -gt 1 ] 2>/dev/null; then
    echo "  • Update system packages"
fi

if [ ! -f ~/.ssh/id_ed25519.pub ] && [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "  • Generate SSH key pair"
fi

echo
print_info "Security check completed!"
echo "For detailed security setup, see: SECURITY.md"
echo "For automated setup, run: ./setup-security.sh"
