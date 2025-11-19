# Copilot Instructions - Remote VM SSH Operations

**These instructions apply to all interactions with remote virtual machines, specifically the DO N8N Instance.**

## Primary Rule: SSH First, Always

When working with remote VMs like `147.182.144.152` (DO N8N Instance):

1. ✅ **ALWAYS** prefix commands with SSH connection
2. ✅ **NEVER** assume local file system execution
3. ✅ **ALWAYS** verify the command runs on the remote host
4. ✅ **ALWAYS** include SSH in all code examples
5. ✅ **ALWAYS** reference the remote VM documentation

---

## SSH Prefix Pattern

### For Single Commands

```bash
ssh dimoss@147.182.144.152 "command_here"
```

### For Multi-Line Operations

```bash
ssh dimoss@147.182.144.152 << 'EOF'
line1
line2
line3
EOF
```

### For Long-Running Operations (background)

```bash
ssh dimoss@147.182.144.152 "nohup command &"
```

---

## DO N8N Instance Configuration

```
IP Address:    147.182.144.152
Username:      dimoss
SSH Port:      22
Region:        Toronto (tor1)
OS:            Ubuntu 24.04.3 LTS
Docker:        28.4.0
N8N Location:  /home/dimoss/n8n-compose
```

---

## Required Copilot Behaviors

### 1. Command Execution

**❌ WRONG** - This runs locally:
```bash
docker ps
cd /home/dimoss/n8n-compose
docker-compose logs
```

**✅ CORRECT** - This runs on the remote VM:
```bash
ssh dimoss@147.182.144.152 "docker ps"
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && docker-compose logs"
```

### 2. File Operations

**❌ WRONG** - Tries to access local filesystem:
```bash
cat /home/dimoss/n8n-compose/.env
```

**✅ CORRECT** - Accesses remote filesystem via SSH:
```bash
ssh dimoss@147.182.144.152 "cat /home/dimoss/n8n-compose/.env"
```

### 3. Script Execution

**❌ WRONG** - Script runs locally:
```bash
./deploy.sh
bash scripts/health-check.sh
```

**✅ CORRECT** - Script runs on remote VM:
```bash
ssh dimoss@147.182.144.152 "bash /home/dimoss/n8n-compose/deploy.sh"
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && ./deploy.sh"
```

### 4. Diagnostic Commands

**❌ WRONG**:
```bash
docker exec n8n-compose-n8n-1 curl http://localhost:5678/healthz
```

**✅ CORRECT**:
```bash
ssh dimoss@147.182.144.152 "docker exec n8n-compose-n8n-1 curl http://localhost:5678/healthz"
```

---

## Code Block Requirements

### All Bash Code Blocks Must Include SSH

Every code example in responses should show SSH usage:

```bash
# ✅ Format: Start with SSH, then the command
ssh dimoss@147.182.144.152 "command"

# ✅ Multi-command format
ssh dimoss@147.182.144.152 << 'EOF'
command1
command2
command3
EOF

# ✅ With file transfer
scp dimoss@147.182.144.152:/path/to/file ./local/path
ssh dimoss@147.182.144.152 "command_using_file"

# ❌ NEVER start with just the command - always SSH first
# This is wrong: docker ps
# This is correct: ssh dimoss@147.182.144.152 "docker ps"
```

---

## Common N8N Operations via SSH

### Check N8N Status

```bash
ssh dimoss@147.182.144.152 "docker ps -f name=n8n"
```

### View N8N Logs

```bash
ssh dimoss@147.182.144.152 "docker logs -f n8n-compose-n8n-1 --tail 50"
```

### Check Workers

```bash
ssh dimoss@147.182.144.152 "docker ps -f name=worker"
```

### Health Check All Services

```bash
ssh dimoss@147.182.144.152 << 'HEALTH'
echo "=== N8N Services ===" && docker ps
echo -e "\n=== Database ===" && docker exec n8n-compose-postgres-1 psql -U n8n -d n8n -c "SELECT 1"
echo -e "\n=== Queue ===" && docker exec n8n-compose-redis-1 redis-cli ping
HEALTH
```

### Restart Services

```bash
ssh dimoss@147.182.144.152 "cd /home/dimoss/n8n-compose && docker-compose restart"
```

### View Environment Config

```bash
ssh dimoss@147.182.144.152 "cat /home/dimoss/n8n-compose/.env"
```

---

## Error Handling

### Check SSH Connection First

```bash
ssh dimoss@147.182.144.152 "echo 'SSH Connection OK'" || echo "SSH Connection Failed"
```

### Verify Docker Access

```bash
ssh dimoss@147.182.144.152 "docker --version" || echo "Docker not accessible"
```

### Capture Command Output

```bash
output=$(ssh dimoss@147.182.144.152 "docker ps")
echo "Result: $output"
```

---

## File Transfer Patterns

### Download from VM

```bash
scp dimoss@147.182.144.152:/home/dimoss/n8n-compose/.env ./n8n-env-backup
```

### Upload to VM

```bash
scp ./new-config.env dimoss@147.182.144.152:/home/dimoss/n8n-compose/
```

### Sync Directory

```bash
scp -r dimoss@147.182.144.152:/home/dimoss/n8n-compose/workflows ./local-backup/
```

---

## Explanation Requirements

When providing code examples, always explain:

1. **What the command does** - brief description
2. **Why we use SSH** - emphasize it runs on remote VM
3. **Expected output** - what to expect
4. **Alternative methods** - if applicable

Example:

```bash
# Check N8N main service status on the remote VM
ssh dimoss@147.182.144.152 "docker ps -f name=n8n-main"
# Output: Shows running N8N main container details
```

---

## When to Use SSH

✅ **Use SSH When**:
- Working with Docker containers on 147.182.144.152
- Checking service status on the remote VM
- Viewing logs from remote services
- Executing deployment scripts
- Managing N8N workflows/data
- Any operation on the /home/dimoss/n8n-compose directory
- Checking system resources on the remote VM
- Modifying configuration files
- Performing backups
- Troubleshooting issues

❌ **Don't Need SSH When**:
- Reviewing this GitHub repository code
- Reading documentation
- Planning architecture
- Writing code that will be pushed to GitHub

---

## SSH Session Best Practices

### Persistent Session (if needed)

```bash
# Establish and stay in SSH session
ssh dimoss@147.182.144.152

# Once connected, all commands run on the VM
docker ps
docker logs -f n8n-compose-n8n-1
# Press Ctrl+C to exit logs, type 'exit' to leave SSH
```

### One-Time Commands

```bash
# Execute single command and return to local terminal
ssh dimoss@147.182.144.152 "docker ps"
```

### Batch Operations

```bash
# Multiple related commands
ssh dimoss@147.182.144.152 << 'BATCH'
cd /home/dimoss/n8n-compose
docker-compose stop
docker-compose pull
docker-compose up -d
BATCH
```

---

## Documentation References

For detailed SSH operations, refer to:
- `docs/REMOTE-SSH-OPERATIONS.md` - Comprehensive SSH guide
- `docs/DEPLOYMENT.md` - Deployment procedures
- `README.md` - Project overview

---

## Verification Checklist

Before executing remote operations, verify:

- [ ] SSH connection works: `ssh dimoss@147.182.144.152 "echo OK"`
- [ ] Docker is accessible: `ssh dimoss@147.182.144.152 "docker ps"`
- [ ] N8N services are running: `ssh dimoss@147.182.144.152 "docker ps | grep n8n"`
- [ ] Database is healthy: `ssh dimoss@147.182.144.152 "docker exec n8n-compose-postgres-1 psql -U n8n -d n8n -c 'SELECT 1'"`
- [ ] Queue is available: `ssh dimoss@147.182.144.152 "docker exec n8n-compose-redis-1 redis-cli ping"`

---

## Summary

🔒 **Security**: Always use SSH for remote operations  
📍 **Consistency**: Every remote command starts with `ssh dimoss@147.182.144.152`  
✅ **Clarity**: Always explain why SSH is needed  
🔄 **Reliability**: Include error handling  
📚 **Documentation**: Reference this file and REMOTE-SSH-OPERATIONS.md  

---

**Last Updated**: 2025-11-19  
**Applies To**: Remote VM Operations (DO N8N Instance 147.182.144.152)  
**Status**: Active - All Copilot interactions must follow these guidelines
