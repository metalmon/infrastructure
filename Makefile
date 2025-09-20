# Universal Infrastructure Makefile
# Manages Traefik and Monitoring stack

.PHONY: help start stop restart logs status clean install security check-docker check-files

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

# Default target
help:
	@echo "$(BLUE)Universal Infrastructure Management$(NC)"
	@echo ""
	@echo "Usage: make <command> [service=traefik|monitoring|all]"
	@echo ""
	@echo "$(GREEN)Commands:$(NC)"
	@echo "  start     Start the service"
	@echo "  stop      Stop the service"
	@echo "  restart   Restart the service"
	@echo "  status    Show service status"
	@echo "  logs      Show service logs"
	@echo "  install   Prepare service for installation"
	@echo "  clean     Clean service (removes all data)"
	@echo "  security  Run security check"
	@echo ""
	@echo "$(GREEN)Services:$(NC)"
	@echo "  traefik      Traefik reverse proxy"
	@echo "  monitoring   Monitoring stack (Prometheus, Grafana, etc.)"
	@echo "  all          All services"
	@echo ""
	@echo "$(YELLOW)Examples:$(NC)"
	@echo "  make start service=all"
	@echo "  make status service=traefik"
	@echo "  make logs service=monitoring"
	@echo "  make install service=all"
	@echo "  make security"

# Check if Docker is running
check-docker:
	@if ! docker info >/dev/null 2>&1; then \
		echo "$(RED)[ERROR]$(NC) Docker is not running. Please start Docker first."; \
		exit 1; \
	fi

# Check if required files exist
check-files:
	@if [ "$(service)" = "traefik" ]; then \
		if [ ! -f "traefik/docker-compose.yml" ] || [ ! -f "traefik/env.traefik" ]; then \
			echo "$(RED)[ERROR]$(NC) Required files not found for traefik"; \
			echo "$(BLUE)[INFO]$(NC) Run 'make install service=traefik' first"; \
			exit 1; \
		fi; \
	elif [ "$(service)" = "monitoring" ]; then \
		if [ ! -f "monitoring/docker-compose.yml" ] || [ ! -f "monitoring/env.monitoring" ]; then \
			echo "$(RED)[ERROR]$(NC) Required files not found for monitoring"; \
			echo "$(BLUE)[INFO]$(NC) Run 'make install service=monitoring' first"; \
			exit 1; \
		fi; \
	elif [ "$(service)" = "all" ]; then \
		if [ ! -f "traefik/docker-compose.yml" ] || [ ! -f "traefik/env.traefik" ] || \
		   [ ! -f "monitoring/docker-compose.yml" ] || [ ! -f "monitoring/env.monitoring" ]; then \
			echo "$(RED)[ERROR]$(NC) Required files not found"; \
			echo "$(BLUE)[INFO]$(NC) Run 'make install service=all' first"; \
			exit 1; \
		fi; \
	fi

# Start service
start: check-docker check-files
	@if [ "$(service)" = "traefik" ]; then \
		echo "$(BLUE)[INFO]$(NC) Starting Traefik..."; \
		cd traefik && make start && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Traefik started successfully"; \
	elif [ "$(service)" = "monitoring" ]; then \
		echo "$(BLUE)[INFO]$(NC) Starting monitoring stack..."; \
		cd monitoring && make start && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Monitoring stack started successfully"; \
	elif [ "$(service)" = "all" ]; then \
		echo "$(BLUE)[INFO]$(NC) Starting all services..."; \
		cd traefik && make start && cd ..; \
		cd monitoring && make start && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) All services started successfully"; \
	else \
		echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
		echo "Available services: traefik, monitoring, all"; \
		exit 1; \
	fi

# Stop service
stop: check-docker check-files
	@if [ "$(service)" = "traefik" ]; then \
		echo "$(BLUE)[INFO]$(NC) Stopping Traefik..."; \
		cd traefik && make stop && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Traefik stopped successfully"; \
	elif [ "$(service)" = "monitoring" ]; then \
		echo "$(BLUE)[INFO]$(NC) Stopping monitoring stack..."; \
		cd monitoring && make stop && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Monitoring stack stopped successfully"; \
	elif [ "$(service)" = "all" ]; then \
		echo "$(BLUE)[INFO]$(NC) Stopping all services..."; \
		cd monitoring && make stop && cd ..; \
		cd traefik && make stop && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) All services stopped successfully"; \
	else \
		echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
		echo "Available services: traefik, monitoring, all"; \
		exit 1; \
	fi

# Restart service
restart: check-docker check-files
	@if [ "$(service)" = "traefik" ]; then \
		echo "$(BLUE)[INFO]$(NC) Restarting Traefik..."; \
		cd traefik && make restart && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Traefik restarted successfully"; \
	elif [ "$(service)" = "monitoring" ]; then \
		echo "$(BLUE)[INFO]$(NC) Restarting monitoring stack..."; \
		cd monitoring && make restart && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Monitoring stack restarted successfully"; \
	elif [ "$(service)" = "all" ]; then \
		echo "$(BLUE)[INFO]$(NC) Restarting all services..."; \
		cd traefik && make restart && cd ..; \
		cd monitoring && make restart && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) All services restarted successfully"; \
	else \
		echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
		echo "Available services: traefik, monitoring, all"; \
		exit 1; \
	fi

# Show status
status: check-docker check-files
	@if [ "$(service)" = "traefik" ]; then \
		echo "$(BLUE)[INFO]$(NC) Status of Traefik:"; \
		cd traefik && make status && cd ..; \
	elif [ "$(service)" = "monitoring" ]; then \
		echo "$(BLUE)[INFO]$(NC) Status of monitoring stack:"; \
		cd monitoring && make status && cd ..; \
	elif [ "$(service)" = "all" ]; then \
		echo "$(BLUE)[INFO]$(NC) Status of all services:"; \
		echo "$(BLUE)[INFO]$(NC) Traefik:"; \
		cd traefik && make status && cd ..; \
		echo ""; \
		echo "$(BLUE)[INFO]$(NC) Monitoring:"; \
		cd monitoring && make status && cd ..; \
	else \
		echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
		echo "Available services: traefik, monitoring, all"; \
		exit 1; \
	fi

# Show logs
logs: check-docker check-files
	@if [ "$(service)" = "traefik" ]; then \
		echo "$(BLUE)[INFO]$(NC) Logs for Traefik:"; \
		cd traefik && make logs; \
	elif [ "$(service)" = "monitoring" ]; then \
		echo "$(BLUE)[INFO]$(NC) Logs for monitoring stack:"; \
		cd monitoring && make logs; \
	elif [ "$(service)" = "all" ]; then \
		echo "$(YELLOW)[WARNING]$(NC) Showing logs for all services. Use Ctrl+C to exit."; \
		cd traefik && make logs & \
		cd ../monitoring && make logs & \
		wait; \
	else \
		echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
		echo "Available services: traefik, monitoring, all"; \
		exit 1; \
	fi

# Install service
install: check-docker
	@if [ "$(service)" = "traefik" ]; then \
		echo "$(BLUE)[INFO]$(NC) Installing Traefik..."; \
		cd traefik && make install && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Traefik installation prepared"; \
	elif [ "$(service)" = "monitoring" ]; then \
		echo "$(BLUE)[INFO]$(NC) Installing monitoring stack..."; \
		cd monitoring && make install && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) Monitoring installation prepared"; \
	elif [ "$(service)" = "all" ]; then \
		echo "$(BLUE)[INFO]$(NC) Installing all services..."; \
		cd traefik && make install && cd ..; \
		cd monitoring && make install && cd ..; \
		echo "$(GREEN)[SUCCESS]$(NC) All services installation prepared"; \
	else \
		echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
		echo "Available services: traefik, monitoring, all"; \
		exit 1; \
	fi

# Clean service
clean: check-docker check-files
	@echo "$(YELLOW)[WARNING]$(NC) Cleaning $(service) (this will remove all data)..."
	@read -p "Are you sure? (y/N): " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		if [ "$(service)" = "traefik" ]; then \
			echo "$(BLUE)[INFO]$(NC) Cleaning Traefik..."; \
			cd traefik && make clean && cd ..; \
			echo "$(GREEN)[SUCCESS]$(NC) Traefik cleaned successfully"; \
		elif [ "$(service)" = "monitoring" ]; then \
			echo "$(BLUE)[INFO]$(NC) Cleaning monitoring stack..."; \
			cd monitoring && make clean && cd ..; \
			echo "$(GREEN)[SUCCESS]$(NC) Monitoring stack cleaned successfully"; \
		elif [ "$(service)" = "all" ]; then \
			echo "$(BLUE)[INFO]$(NC) Cleaning all services..."; \
			cd monitoring && make clean && cd ..; \
			cd traefik && make clean && cd ..; \
			echo "$(GREEN)[SUCCESS]$(NC) All services cleaned successfully"; \
		else \
			echo "$(RED)[ERROR]$(NC) Unknown service: $(service)"; \
			echo "Available services: traefik, monitoring, all"; \
			exit 1; \
		fi; \
	else \
		echo "$(BLUE)[INFO]$(NC) Clean operation cancelled"; \
	fi

# Security check
security: check-docker
	@echo "$(BLUE)[INFO]$(NC) Running security check..."
	@if [ -f "./security-check.sh" ]; then \
		./security-check.sh; \
	else \
		echo "$(RED)[ERROR]$(NC) Security check script not found"; \
		exit 1; \
	fi

# Quick start (install + start all)
quick-start: install start
	@echo "$(GREEN)[SUCCESS]$(NC) Quick start completed!"
	@echo "$(BLUE)[INFO]$(NC) All services are running"
	@echo "$(BLUE)[INFO]$(NC) Check status with: make status service=all"
