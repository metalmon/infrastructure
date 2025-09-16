# Universal Monitoring Makefile

.PHONY: help start stop restart logs status clean install

# Default target
help:
	@echo "Available targets:"
	@echo "  start     - Start monitoring stack"
	@echo "  stop      - Stop monitoring stack"
	@echo "  restart   - Restart monitoring stack"
	@echo "  logs      - Show monitoring logs"
	@echo "  status    - Show monitoring status"
	@echo "  clean     - Clean up monitoring data"
	@echo "  install   - Install monitoring stack"

# Start monitoring
start:
	@echo "Starting monitoring stack..."
	docker-compose --env-file env.monitoring up -d
	@echo "Monitoring stack started successfully!"
	@echo "Prometheus: http://localhost:9090"
	@echo "Grafana: http://localhost:3000 (admin/admin123)"
	@echo "Node Exporter: http://localhost:9100"
	@echo "cAdvisor: http://localhost:8081"

# Stop monitoring
stop:
	@echo "Stopping monitoring stack..."
	docker-compose --env-file env.monitoring down
	@echo "Monitoring stack stopped successfully!"

# Restart monitoring
restart: stop start

# Show logs
logs:
	docker-compose --env-file env.monitoring logs -f

# Show status
status:
	docker-compose --env-file env.monitoring ps

# Clean up
clean:
	@echo "Cleaning up monitoring data..."
	docker-compose --env-file env.monitoring down -v
	docker system prune -f
	@echo "Cleanup completed!"

# Install (first time setup)
install:
	@echo "Installing monitoring stack..."
	mkdir -p prometheus_data grafana_data
	chmod 755 prometheus_data grafana_data
	@echo "Monitoring installation completed!"
	@echo "Please edit env.monitoring with your configuration"

# Update Prometheus config
reload-prometheus:
	@echo "Reloading Prometheus configuration..."
	curl -X POST http://localhost:9090/-/reload
	@echo "Prometheus configuration reloaded!"

# Backup Grafana data
backup-grafana:
	@echo "Backing up Grafana data..."
	tar -czf grafana-backup-$(shell date +%Y%m%d-%H%M%S).tar.gz grafana_data/
	@echo "Grafana backup completed!"

# Restore Grafana data
restore-grafana:
	@echo "Restoring Grafana data..."
	@echo "Please specify backup file: make restore-grafana BACKUP_FILE=backup.tar.gz"
	@if [ -z "$(BACKUP_FILE)" ]; then echo "Error: BACKUP_FILE not specified"; exit 1; fi
	tar -xzf $(BACKUP_FILE)
	@echo "Grafana data restored!"
