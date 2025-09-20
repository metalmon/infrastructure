# Make Commands Reference

## Overview

The monitoring system includes a convenient Makefile with predefined commands for easy management.

## Basic Commands

### Start Monitoring
```bash
make start
```
- Starts all monitoring services
- Checks for required configuration files
- Shows service URLs after startup

### Stop Monitoring
```bash
make stop
```
- Stops all monitoring services
- Gracefully shuts down containers

### Restart Monitoring
```bash
make restart
```
- Stops and starts monitoring services
- Useful after configuration changes

### Check Status
```bash
make status
```
- Shows status of all containers
- Displays running/stopped services

### View Logs
```bash
make logs
```
- Shows logs from all services
- Use `Ctrl+C` to exit log view

## Maintenance Commands

### Clean Up
```bash
make clean
```
- Stops services and removes volumes
- Cleans up Docker system
- **Warning**: This removes all data!

### Install (First Time)
```bash
make install
```
- Creates required directories
- Sets proper permissions
- Run once for initial setup

### Reload Prometheus Config
```bash
make reload-prometheus
```
- Reloads Prometheus configuration
- Useful after changing `prometheus.yml`

### Backup Grafana
```bash
make backup-grafana
```
- Creates timestamped backup of Grafana data
- Saves to `grafana-backup-YYYYMMDD-HHMMSS.tar.gz`

### Restore Grafana
```bash
make restore-grafana BACKUP_FILE=backup.tar.gz
```
- Restores Grafana from backup
- Specify backup file with `BACKUP_FILE` parameter

## Help

### Show All Commands
```bash
make help
```
- Displays all available commands
- Shows command descriptions

## Examples

### First Time Setup
```bash
# Install monitoring stack
make install

# Create .env file
cp env.template .env
nano .env

# Generate auth hashes
./generate-auth.sh your_password

# Start monitoring
make start
```

### Daily Operations
```bash
# Check status
make status

# View logs
make logs

# Restart after config changes
make restart
```

### Maintenance
```bash
# Create backup
make backup-grafana

# Clean up (removes all data!)
make clean

# Restore from backup
make restore-grafana BACKUP_FILE=grafana-backup-20241220-120000.tar.gz
```

## Troubleshooting

### Services Won't Start
```bash
# Check logs
make logs

# Check status
make status

# Clean and restart
make clean
make install
make start
```

### Configuration Changes
```bash
# After editing prometheus.yml
make reload-prometheus

# After editing docker-compose.yml
make restart
```

### Permission Issues
```bash
# Reinstall with proper permissions
make clean
make install
make start
```

## Tips

- Always use `make` commands instead of direct `docker-compose` commands
- Use `make logs` to troubleshoot issues
- Use `make clean` only when you want to remove all data
- Create backups regularly with `make backup-grafana`
- Check `make help` for available commands
