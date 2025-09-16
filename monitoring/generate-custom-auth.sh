#!/bin/bash

# Script to generate custom Traefik basic auth hashes
# Usage: ./generate-custom-auth.sh [password] [metrics_username] [grafana_username]

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[HEADER]${NC} $1"
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

# Get parameters from arguments or prompt
if [ -n "$1" ]; then
    PASSWORD=$1
else
    read -s -p "Enter password: " PASSWORD
    echo
fi

if [ -n "$2" ]; then
    METRICS_USERNAME=$2
else
    read -p "Enter metrics username (default: metrics): " METRICS_USERNAME
    METRICS_USERNAME=${METRICS_USERNAME:-metrics}
fi

if [ -n "$3" ]; then
    GRAFANA_USERNAME=$3
else
    read -p "Enter Grafana username (default: admin): " GRAFANA_USERNAME
    GRAFANA_USERNAME=${GRAFANA_USERNAME:-admin}
fi

if [ -z "$PASSWORD" ]; then
    echo "Error: Password cannot be empty"
    exit 1
fi

print_header "Generating custom basic auth hashes..."

# Generate hashes for custom usernames
METRICS_HASH=$(generate_hash "$PASSWORD" "$METRICS_USERNAME")
GRAFANA_HASH=$(generate_hash "$PASSWORD" "$GRAFANA_USERNAME")

print_status "Generated hashes with custom usernames:"
echo ""
echo "For metrics services (Prometheus, Node Exporter, cAdvisor):"
echo "  Username: $METRICS_USERNAME"
echo "  Hash: $METRICS_HASH"
echo ""
echo "For Grafana admin:"
echo "  Username: $GRAFANA_USERNAME"
echo "  Hash: $GRAFANA_HASH"
echo ""

print_status "Add these to your env.monitoring file:"
echo ""
echo "METRICS_AUTH_HASH=$METRICS_HASH"
echo "GRAFANA_AUTH_HASH=$GRAFANA_HASH"
echo ""

print_status "Or add directly to docker-compose.yml labels:"
echo ""
echo "- \"traefik.http.middlewares.prometheus-auth.basicauth.users=$METRICS_HASH\""
echo "- \"traefik.http.middlewares.node-exporter-auth.basicauth.users=$METRICS_HASH\""
echo "- \"traefik.http.middlewares.cadvisor-auth.basicauth.users=$METRICS_HASH\""
echo "- \"traefik.http.middlewares.grafana-auth.basicauth.users=$GRAFANA_HASH\""
echo ""

print_status "Login credentials:"
echo ""
echo "Metrics services (Prometheus, Node Exporter, cAdvisor):"
echo "  URL: https://your-domain.com/prometheus"
echo "  Username: $METRICS_USERNAME"
echo "  Password: [your password]"
echo ""
echo "Grafana:"
echo "  URL: https://your-domain.com/grafana"
echo "  Username: $GRAFANA_USERNAME"
echo "  Password: [your password]"
echo ""

print_warning "Don't forget to update your env.monitoring file!"
