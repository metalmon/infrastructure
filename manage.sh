#!/bin/bash

# Universal Infrastructure Management Script
# Manages Traefik and Monitoring stack

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Check if required files exist
check_files() {
    local service=$1
    local required_files=()
    
    case $service in
        "traefik")
            required_files=("traefik/docker-compose.yml" "traefik/env.traefik")
            ;;
        "monitoring")
            required_files=("monitoring/docker-compose.yml" "monitoring/env.monitoring")
            ;;
        "all")
            required_files=("traefik/docker-compose.yml" "traefik/env.traefik" "monitoring/docker-compose.yml" "monitoring/env.monitoring")
            ;;
    esac
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file not found: $file"
            print_info "Run 'make install' in the $service directory first"
            exit 1
        fi
    done
}

# Start service
start_service() {
    local service=$1
    print_info "Starting $service..."
    
    case $service in
        "traefik")
            cd traefik
            docker-compose up -d
            cd ..
            print_success "Traefik started successfully"
            ;;
        "monitoring")
            cd monitoring
            docker-compose up -d
            cd ..
            print_success "Monitoring stack started successfully"
            ;;
        "all")
            start_service "traefik"
            start_service "monitoring"
            print_success "All services started successfully"
            ;;
        *)
            print_error "Unknown service: $service"
            exit 1
            ;;
    esac
}

# Stop service
stop_service() {
    local service=$1
    print_info "Stopping $service..."
    
    case $service in
        "traefik")
            cd traefik
            docker-compose down
            cd ..
            print_success "Traefik stopped successfully"
            ;;
        "monitoring")
            cd monitoring
            docker-compose down
            cd ..
            print_success "Monitoring stack stopped successfully"
            ;;
        "all")
            stop_service "monitoring"
            stop_service "traefik"
            print_success "All services stopped successfully"
            ;;
        *)
            print_error "Unknown service: $service"
            exit 1
            ;;
    esac
}

# Restart service
restart_service() {
    local service=$1
    print_info "Restarting $service..."
    stop_service "$service"
    start_service "$service"
}

# Show status
show_status() {
    local service=$1
    print_info "Status of $service:"
    
    case $service in
        "traefik")
            cd traefik
            docker-compose ps
            cd ..
            ;;
        "monitoring")
            cd monitoring
            docker-compose ps
            cd ..
            ;;
        "all")
            show_status "traefik"
            echo
            show_status "monitoring"
            ;;
        *)
            print_error "Unknown service: $service"
            exit 1
            ;;
    esac
}

# Show logs
show_logs() {
    local service=$1
    print_info "Logs for $service:"
    
    case $service in
        "traefik")
            cd traefik
            docker-compose logs -f
            ;;
        "monitoring")
            cd monitoring
            docker-compose logs -f
            ;;
        "all")
            print_warning "Showing logs for all services. Use Ctrl+C to exit."
            cd traefik && docker-compose logs -f &
            cd ../monitoring && docker-compose logs -f &
            wait
            ;;
        *)
            print_error "Unknown service: $service"
            exit 1
            ;;
    esac
}

# Install service
install_service() {
    local service=$1
    print_info "Installing $service..."
    
    case $service in
        "traefik")
            cd traefik
            if [[ ! -f "env.traefik" ]]; then
                print_warning "Creating env.traefik template..."
                cat > env.traefik << EOF
# Domain Configuration
DOMAIN=yourdomain.com
ACME_EMAIL=your-email@example.com

# Network Configuration
TRAEFIK_NETWORK=traefik
EOF
                print_info "Please edit traefik/env.traefik with your domain and email"
            fi
            cd ..
            print_success "Traefik installation prepared"
            ;;
        "monitoring")
            cd monitoring
            if [[ ! -f "env.monitoring" ]]; then
                print_warning "Creating env.monitoring template..."
                cat > env.monitoring << EOF
# Domain Configuration
DOMAIN=yourdomain.com

# Grafana Configuration
GRAFANA_ADMIN_PASSWORD=your-secure-password

# API Key for Metrics
METRICS_API_KEY=your-metrics-api-key

# Authentication Hashes (generated by generate-auth.sh)
METRICS_AUTH_HASH=metrics:\$2y\$10\$real.hash.here
GRAFANA_AUTH_HASH=admin:\$2y\$10\$real.hash.here
EOF
                print_info "Please edit monitoring/env.monitoring with your passwords"
                print_info "Run './generate-auth.sh' to generate authentication hashes"
            fi
            cd ..
            print_success "Monitoring installation prepared"
            ;;
        "all")
            install_service "traefik"
            install_service "monitoring"
            print_success "All services installation prepared"
            ;;
        *)
            print_error "Unknown service: $service"
            exit 1
            ;;
    esac
}

# Clean service
clean_service() {
    local service=$1
    print_warning "Cleaning $service (this will remove all data)..."
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        case $service in
            "traefik")
                cd traefik
                docker-compose down -v
                docker system prune -f
                cd ..
                print_success "Traefik cleaned successfully"
                ;;
            "monitoring")
                cd monitoring
                docker-compose down -v
                docker system prune -f
                cd ..
                print_success "Monitoring stack cleaned successfully"
                ;;
            "all")
                clean_service "monitoring"
                clean_service "traefik"
                print_success "All services cleaned successfully"
                ;;
            *)
                print_error "Unknown service: $service"
                exit 1
                ;;
        esac
    else
        print_info "Clean operation cancelled"
    fi
}

# Security check
security_check() {
    print_info "Running security check..."
    if [[ -f "./security-check.sh" ]]; then
        ./security-check.sh
    else
        print_error "Security check script not found"
        exit 1
    fi
}

# Show help
show_help() {
    echo "Universal Infrastructure Management Script"
    echo
    echo "Usage: $0 <command> [service]"
    echo
    echo "Commands:"
    echo "  start     Start the service"
    echo "  stop      Stop the service"
    echo "  restart   Restart the service"
    echo "  status    Show service status"
    echo "  logs      Show service logs"
    echo "  install   Prepare service for installation"
    echo "  clean     Clean service (removes all data)"
    echo "  security  Run security check"
    echo
    echo "Services:"
    echo "  traefik      Traefik reverse proxy"
    echo "  monitoring   Monitoring stack (Prometheus, Grafana, etc.)"
    echo "  all          All services"
    echo
    echo "Examples:"
    echo "  $0 start all"
    echo "  $0 status traefik"
    echo "  $0 logs monitoring"
    echo "  $0 install all"
    echo "  $0 security"
}

# Main script logic
main() {
    check_docker
    
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi
    
    local command=$1
    local service=${2:-""}
    
    # Commands that don't require service parameter
    if [[ "$command" == "security" || "$command" == "help" || "$command" == "-h" || "$command" == "--help" ]]; then
        service=""
    elif [[ -z "$service" ]]; then
        print_error "Service not specified"
        show_help
        exit 1
    fi
    
    case $command in
        "start")
            check_files "$service"
            start_service "$service"
            ;;
        "stop")
            check_files "$service"
            stop_service "$service"
            ;;
        "restart")
            check_files "$service"
            restart_service "$service"
            ;;
        "status")
            check_files "$service"
            show_status "$service"
            ;;
        "logs")
            check_files "$service"
            show_logs "$service"
            ;;
        "install")
            install_service "$service"
            ;;
        "clean")
            clean_service "$service"
            ;;
        "security")
            security_check
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"