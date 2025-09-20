# .env File Tips

## Important: Escaping $ Characters

### The Problem
Bcrypt hashes start with `$2b$10$`, but in `.env` files, `$` characters are interpreted as variable references. This causes authentication to fail.

### The Solution
Use `$$` to escape each `$` character in `.env` files:

```bash
# Wrong (will not work):
METRICS_AUTH_HASH=metrics:$2b$10$hash_here

# Correct (will work):
METRICS_AUTH_HASH=metrics:$$2b$$10$$hash_here
```

### Example
If your script generates:
```
metrics:$2b$10$abc123def456
```

In `.env` file write:
```
METRICS_AUTH_HASH=metrics:$$2b$$10$$abc123def456
```

## Common Issues

### Authentication Fails
- **Cause**: `$` characters not escaped in `.env` file
- **Solution**: Use `$$` instead of `$` in hash values

### Services Don't Start
- **Cause**: Invalid environment variable format
- **Solution**: Check `.env` file syntax, escape special characters

### Hash Not Recognized
- **Cause**: Hash format corrupted by variable substitution
- **Solution**: Regenerate hash and properly escape `$` characters

## Best Practices

### 1. Always Escape $ Characters
```bash
# For any bcrypt hash in .env files
HASH_VALUE=$$2b$$10$$your_hash_here
```

### 2. Test Authentication
```bash
# After updating .env file, test login
curl -u username:password https://your-domain.com/prometheus/
```

### 3. Check .env File Format
```bash
# Verify no unescaped $ characters
grep -n '\$[^$]' .env
```

## Troubleshooting

### Check Hash Format
```bash
# View current hash format
cat .env | grep AUTH_HASH
```

### Regenerate Hash
```bash
# Generate new hash
./generate-auth.sh your_password

# Copy to .env with proper escaping
# metrics:$2b$10$hash -> metrics:$$2b$$10$$hash
```

### Verify Environment Variables
```bash
# Check if variables are loaded correctly
make status
```
