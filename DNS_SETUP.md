# 🌐 Universal DNS Setup Guide

Instructions for setting up DNS for any application with path prefixes.

## 📋 Requirements

- Domain (e.g., `example.com`)
- Access to DNS control panel
- Your server's IP address

## 🔧 DNS Configuration

### 1. Main A-Record

Add one A-record in your DNS control panel:

```
example.com    A    YOUR_SERVER_IP
```

**Example:**
```
example.com    A    192.168.1.100
```

### 2. Configuration Verification

After DNS configuration, verify:

```bash
# Check main record
nslookup example.com

# Check from your server
curl -I http://example.com
```

## 🌐 Service Access

After DNS configuration, all services will be accessible via path prefixes:

### Infrastructure Services
- **Traefik Dashboard**: `https://example.com/traefik`

### Monitoring Services
- **Prometheus**: `https://example.com/prometheus`
- **Grafana**: `https://example.com/grafana`
- **Node Exporter**: `https://example.com/node-exporter`
- **cAdvisor**: `https://example.com/cadvisor`

### Your Application
- **Your App**: `https://example.com/yourapp`

## 🔒 SSL Certificates

Traefik will automatically obtain SSL certificates from Let's Encrypt for the domain `example.com`. All path prefixes will work over HTTPS.

## 🚨 Troubleshooting

### Issue: DNS Not Resolving

**Solution:**
1. Check A-record in DNS panel
2. Wait 5-10 minutes for DNS propagation
3. Check from different DNS servers:
   ```bash
   nslookup example.com 8.8.8.8
   nslookup example.com 1.1.1.1
   ```

### Issue: SSL Certificate Not Created

**Solution:**
1. Ensure domain points to server
2. Check that ports 80 and 443 are open
3. Check Traefik logs:
   ```bash
   ./manage.sh logs traefik
   ```

### Issue: Services Not Accessible

**Solution:**
1. Check status of all services:
   ```bash
   ./manage.sh status
   ```
2. Check logs:
   ```bash
   ./manage.sh logs
   ```
3. Ensure all services are running

## 📊 Example Requests

### Check Prometheus
```bash
curl -k https://example.com/prometheus/api/v1/targets
```

### Check Grafana
```bash
curl -k https://example.com/grafana/api/health
```

### Check Your Application
```bash
curl -k https://example.com/yourapp/health
```

## 🎯 Benefits of Path Prefixes

1. **Single Domain** - No need to configure multiple subdomains
2. **Single SSL Certificate** - Let's Encrypt for one domain
3. **Simple Configuration** - Only one A-record in DNS
4. **Fewer Records** - Don't clutter DNS zone
5. **Easier to Remember** - All services on one domain

## 🔧 Alternative Configuration

If you want to use subdomains, you can change the configuration:

```yaml
# Instead of:
- "traefik.http.routers.prometheus.rule=Host(`${DOMAIN}`) && PathPrefix(`/prometheus`)"

# Use:
- "traefik.http.routers.prometheus.rule=Host(`prometheus.${DOMAIN}`)"
```

But then you'll need to configure additional A-records in DNS.

## 📝 Application Integration

To integrate your application with this infrastructure:

1. **Add to Traefik network** in your `docker-compose.yml`
2. **Configure Traefik labels** for routing
3. **Use path prefixes** for your application

### Example Application Configuration

```yaml
# In your app's docker-compose.yml
services:
  your-app:
    # ... your app configuration
    networks:
      - traefik
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.yourapp.rule=Host(`${DOMAIN}`) && PathPrefix(`/yourapp`)"
      - "traefik.http.routers.yourapp.entrypoints=websecure"
      - "traefik.http.routers.yourapp.tls.certresolver=letsencrypt"
      - "traefik.http.services.yourapp.loadbalancer.server.port=8080"

networks:
  traefik:
    external: true
```

## 🔐 Security Considerations

- **HTTPS Only**: All services use HTTPS with automatic SSL certificates
- **Basic Authentication**: Services are protected with HTTP Basic Auth
- **Network Isolation**: Services run in isolated Docker networks
- **Firewall**: Ensure only necessary ports are open (80, 443)

## 📞 Support

If you encounter problems:

1. Check DNS configuration
2. Verify server accessibility
3. Check service logs
4. Ensure all services are running
5. Verify SSL certificate status
