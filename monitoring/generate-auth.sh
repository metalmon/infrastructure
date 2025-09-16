#!/bin/bash

# Script to generate Traefik basic auth hashes
# Usage: ./generate-auth.sh [password]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to generate hash
generate_hash() {
    local password=$1
    local username=$2
    
    # Generate hash using htpasswd
    local hash=$(htpasswd -nbB "$username" "$password" | cut -d: -f2)
    echo "$username:$hash"
}

# Check if htpasswd is available
if ! command -v htpasswd &> /dev/null; then
    print_warning "htpasswd not found. Installing apache2-utils..."
    sudo apt-get update && sudo apt-get install -y apache2-utils
fi

# Get password from argument or prompt
if [ -n "$1" ]; then
    PASSWORD=$1
else
    read -s -p "Enter password: " PASSWORD
    echo
fi

if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty"
    exit 1
fi

print_status "Generating basic auth hashes..."

# Generate hashes for different services
METRICS_HASH=$(generate_hash "$PASSWORD" "metrics")
ADMIN_HASH=$(generate_hash "$PASSWORD" "admin")

print_status "Generated hashes:"
echo ""
echo "For metrics services (Prometheus, Node Exporter, cAdvisor):"
echo "  $METRICS_HASH"
echo ""
echo "For Grafana admin:"
echo "  $ADMIN_HASH"
echo ""

print_status "Add these to your docker-compose.yml labels:"
echo ""
echo "# For Prometheus, Node Exporter, cAdvisor:"
echo "- \"traefik.http.middlewares.prometheus-auth.basicauth.users=$METRICS_HASH\""
echo "- \"traefik.http.middlewares.node-exporter-auth.basicauth.users=$METRICS_HASH\""
echo "- \"traefik.http.middlewares.cadvisor-auth.basicauth.users=$METRICS_HASH\""
echo ""
echo "# For Grafana:"
echo "- \"traefik.http.middlewares.grafana-auth.basicauth.users=$ADMIN_HASH\""
echo ""

print_status "Or update your env.monitoring file:"
echo "METRICS_API_KEY=$PASSWORD"
echo "GRAFANA_ADMIN_PASSWORD=$PASSWORD"
