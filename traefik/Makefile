# Traefik Makefile

.PHONY: help start stop restart logs status clean

# Default target
help:
	@echo "Available targets:"
	@echo "  start     - Start Traefik proxy"
	@echo "  stop      - Stop Traefik proxy"
	@echo "  restart   - Restart Traefik proxy"
	@echo "  logs      - Show Traefik logs"
	@echo "  status    - Show Traefik status"
	@echo "  clean     - Clean up Traefik data"
	@echo "  network   - Create Traefik network"

# Start Traefik
start:
	@echo "Starting Traefik proxy..."
	@if [ ! -f env.traefik ]; then \
		echo "Error: env.traefik file not found!"; \
		echo "Please create env.traefik with your domain and email:"; \
		echo "DOMAIN=your-domain.com"; \
		echo "ACME_EMAIL=admin@your-domain.com"; \
		exit 1; \
	fi
	@export $$(cat env.traefik | grep -v '^#' | xargs) && docker compose up -d
	@echo "Traefik started successfully!"
	@echo "Dashboard: http://localhost:8080"
	@echo "API: http://localhost:8080/api/rawdata"

# Stop Traefik
stop:
	@echo "Stopping Traefik proxy..."
	docker compose down
	@echo "Traefik stopped successfully!"

# Restart Traefik
restart: stop start

# Show logs
logs:
	docker compose logs -f

# Show status
status:
	docker compose ps

# Clean up
clean:
	@echo "Cleaning up Traefik data..."
	docker compose down -v
	docker system prune -f
	@echo "Cleanup completed!"

# Create network
network:
	@echo "Creating Traefik network..."
	docker network create traefik || true
	@echo "Network created successfully!"

# Install (first time setup)
install: network
	@echo "Installing Traefik..."
	mkdir -p letsencrypt
	chmod 600 letsencrypt
	@echo "Traefik installation completed!"
	@echo "Please edit env.traefik with your domain and email"
