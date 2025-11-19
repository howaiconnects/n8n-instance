# Remote VM SSH Operations Guide

## ⚠️ IMPORTANT: Always SSH into the remote VM first before executing any commands

This guide ensures all operations on the DO N8N Instance (147.182.144.152) are performed via SSH.

## Quick Reference

### DO N8N Instance Details

- **IP Address**: 147.182.144.152
- **Region**: Toronto (tor1)
- **User**: dimoss
- **SSH Port**: 22 (default)
- **OS**: Ubuntu 24.04.3 LTS
- **Docker**: 28.4.0

### SSH Connection Template

```bash
ssh dimoss@147.182.144.152 "command here"
```

### Establish Persistent SSH Session

```bash
ssh dimoss@147.182.144.152
# Now you're in the remote environment
# All subsequent commands run on the VM
```

---

## Common SSH Operations

### 1. Check Docker Status

```bash
ssh dimoss@147.182.144.152 "docker ps -a"
```

### 2. View Docker Compose Services

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && docker-compose ps"
```

### 3. View N8N Logs

```bash
ssh dimoss@147.182.144.152 "docker logs -f n8n-compose-n8n-1"
```

### 4. Check System Resources

```bash
ssh dimoss@147.182.144.152 "free -h && df -h && top -bn1 | head -20"
```

### 5. Restart Services

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && docker-compose restart"
```

### 6. Deploy Changes

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && docker-compose pull && docker-compose up -d"
```

---

## SSH Best Practices

### 1. Prefix All Commands with SSH

❌ **Wrong** (runs locally):

```bash
docker ps
docker logs n8n-compose-n8n-1
```

✅ **Correct** (runs on remote VM):

```bash
ssh dimoss@147.182.144.152 "docker ps"
ssh dimoss@147.182.144.152 "docker logs n8n-compose-n8n-1"
```

### 2. Use SSH for Script Execution

❌ **Wrong**:

```bash
./deploy.sh
```

✅ **Correct**:

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && ./deploy.sh"
```

### 3. Handle Special Characters in Commands

When commands contain pipes, quotes, or special characters:

```bash
# Escape properly for shell
ssh dimoss@147.182.144.152 "docker logs n8n-compose-n8n-1 | grep ERROR"

# Or use single quotes for literal strings
ssh dimoss@147.182.144.152 'docker ps --format "table {{.Names}}\t{{.Status}}"'
```

### 4. Multi-Line Commands via SSH

```bash
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
docker-compose stop
docker-compose rm -f
docker-compose up -d
EOF
```

---

## SSH Key Setup (Optional but Recommended)

### Generate SSH Key Locally

```bash
ssh-keygen -t ed25519 -f ~/.ssh/do_n8n -C "n8n@147.182.144.152"
```

### Copy Public Key to VM

```bash
ssh-copy-id -i ~/.ssh/do_n8n.pub dimoss@147.182.144.152
```

### Add to SSH Config (~/.ssh/config)

```plaintext
Host n8n-do
    HostName 147.182.144.152
    User dimoss
    IdentityFile ~/.ssh/do_n8n
    StrictHostKeyChecking no
```

### Then use simplified commands

```bash
ssh n8n-do "docker ps"
scp n8n-do:/home/dimoss/n8n-compose/.env ./
```

---

## Copilot Instructions for Remote Operations

When working with this N8N instance, **Copilot MUST**:

1. ✅ **Prefix all commands with SSH** to 147.182.144.152
2. ✅ **Never assume local execution** - always specify the remote host
3. ✅ **Include SSH in code blocks** - all examples must show SSH usage
4. ✅ **Verify remote context** - confirm operations are running on the VM
5. ✅ **Use SSH for file operations** - scp/sftp for file transfers
6. ✅ **Handle errors gracefully** - SSH connection failures should be caught

### Example Copilot Code Block Format

```bash
# ✅ CORRECT - SSH first, then command
ssh dimoss@147.182.144.152 "docker ps"

# ✅ CORRECT - Multi-step operation via SSH
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && docker-compose logs -f"

# ✅ CORRECT - File transfer
scp dimoss@147.182.144.152:/home/dimoss/n8n-compose/.env ./local-env-backup

# ❌ WRONG - Local execution (would fail)
cd /home/dimoss/n8n-compose
docker ps
```

---

## Troubleshooting SSH Connection

### Test SSH Connection

```bash
ssh -v dimoss@147.182.144.152 "echo SSH Connection Successful"
```

### Connection Timeout

```bash
# Check network connectivity
ping 147.182.144.152

# Try SSH with verbose output
ssh -vvv dimoss@147.182.144.152
```

### Permission Denied

```bash
# Verify SSH key permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa

# Test with password authentication
ssh dimoss@147.182.144.152
```

### SSH Config Issues

```bash
# Check SSH config syntax
ssh -G n8n-do

# Test connection
ssh n8n-do "hostname"
```

---

## Common Remote Operations Checklist

- [ ] SSH connection established to 147.182.144.152
- [ ] User verified as `dimoss`
- [ ] Docker services running: `docker ps`
- [ ] N8N main service: `docker exec n8n-compose-n8n-1 curl http://localhost:5678/healthz`
- [ ] PostgreSQL healthy: `docker ps -f name=postgres`
- [ ] Redis healthy: `docker ps -f name=redis`
- [ ] Disk space available: `df -h`
- [ ] Memory available: `free -h`
- [ ] Network connectivity: `ping 8.8.8.8`

---

## File Transfer Operations

### Copy File FROM VM to Local

```bash
scp dimoss@147.182.144.152:/home/dimoss/n8n-compose/.env ./local-backup.env
```

### Copy File TO VM from Local

```bash
scp ./new-config.yml dimoss@147.182.144.152:/home/dimoss/n8n-compose/
```

### Sync Directory (Recursive)

```bash
scp -r dimoss@147.182.144.152:/home/dimoss/n8n-compose/local-files ./n8n-files-backup
```

---

## Executing Scripts on Remote VM

### Method 1: Direct Execution

```bash
ssh dimoss@147.182.144.152 "bash /home/dimoss/n8n-compose/deploy.sh"
```

### Method 2: Heredoc with Script

```bash
ssh dimoss@147.182.144.152 << 'SCRIPT'
#!/bin/bash
cd /home/dimoss/n8n-compose
docker-compose down
docker-compose pull
docker-compose up -d
echo "Deployment complete"
SCRIPT
```

### Method 3: Upload then Execute

```bash
scp ./deploy.sh dimoss@147.182.144.152:/home/dimoss/
ssh dimoss@147.182.144.152 "bash /home/dimoss/deploy.sh"
```

---

## Environment Variables via SSH

### View Remote Environment

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && cat .env | grep N8N"
```

### Set Environment on Remote

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && echo 'NEW_VAR=value' >> .env"
```

### Use in Command

```bash
ssh dimoss@147.182.144.152 "export $(cat /home/dimoss/n8n-compose/.env | xargs) && echo \$N8N_PORT"
```

---

## Real-World Examples

### Example 1: Update and Restart N8N

```bash
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
docker-compose pull
docker-compose up -d
docker-compose logs -f n8n-compose-n8n-1
EOF
```

### Example 2: Backup Database

```bash
ssh dimoss@147.182.144.152 "docker exec n8n-compose-postgres-1 pg_dump -U n8n -d n8n" > n8n-backup-$(date +%Y%m%d).sql
```

### Example 3: Monitor Real-Time Logs

```bash
ssh dimoss@147.182.144.152 "docker logs -f --tail 50 n8n-compose-n8n-1"
```

### Example 4: Health Check

```bash
ssh dimoss@147.182.144.152 << 'HEALTH'
echo "=== Docker Services ==="
docker ps -a

echo -e "\n=== System Resources ==="
free -h
df -h

echo -e "\n=== N8N Health ==="
docker exec n8n-compose-n8n-1 curl -s http://localhost:5678/healthz || echo "N8N not responding"

echo -e "\n=== Redis Health ==="
docker exec n8n-compose-redis-1 redis-cli ping

echo -e "\n=== PostgreSQL Health ==="
docker exec n8n-compose-postgres-1 psql -U n8n -d n8n -c "SELECT 1" 2>&1
HEALTH
```

---

## Remember

🔒 **Security**: Always use SSH keys when possible  
📍 **Specify Host**: Always prefix with `ssh dimoss@147.182.144.152`  
✅ **Verify Context**: Confirm you're running on the remote VM  
📝 **Log Operations**: Keep track of changes made via SSH  
🔄 **Use Consistent Format**: Make SSH usage predictable and auditable

---

**Last Updated**: 2025-11-19  
**VM**: DO N8N Instance (147.182.144.152)  
**Status**: Ready for SSH operations
