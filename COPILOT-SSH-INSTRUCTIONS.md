---
applyTo: 'howaiconnects/n8n-instance'
version: '1.0'
lastUpdated: '2025-11-19'
---

# 🤖 Copilot Instructions - N8N Instance Remote VM Operations

**Scope**: All interactions with the `howaiconnects/n8n-instance` repository and the DO N8N Instance (147.182.144.152)

---

## 🔴 PRIMARY RULE: ALWAYS SSH FIRST

**When working with remote VMs, ALWAYS establish SSH connection before executing any commands.**

### DO N8N Instance Configuration

```plaintext
Organization:  howaiconnects
Repository:    n8n-instance
Remote VM:     147.182.144.152
User:          dimoss
SSH Port:      22 (default)
Region:        Toronto (tor1)
OS:            Ubuntu 24.04.3 LTS
Docker:        28.4.0
Status:        Production (6 containers running)
```

---

## 🔧 SSH Command Patterns

### Pattern 1: Single Command Execution

```bash
ssh dimoss@147.182.144.152 "command_here"
```

**Example:**

```bash
ssh dimoss@147.182.144.152 "docker ps -a"
```

### Pattern 2: Multi-Line Operations

```bash
ssh dimoss@147.182.144.152 << 'EOF'
command1
command2
command3
EOF
```

**Example:**

```bash
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
docker-compose ps
docker-compose logs --tail 10
EOF
```

### Pattern 3: Background Operations (Long-Running)

```bash
ssh dimoss@147.182.144.152 "nohup long_running_command > /tmp/output.log 2>&1 &"
```

### Pattern 4: Interactive Session

```bash
ssh dimoss@147.182.144.152
# Now in remote shell, commands execute on VM
exit  # Return to local shell
```

### Pattern 5: File Transfer (SCP)

```bash
# Download from remote
scp dimoss@147.182.144.152:/remote/path /local/path

# Upload to remote
scp /local/path dimoss@147.182.144.152:/remote/path
```

---

## 📋 Repository Standards & Policies

### Branch Strategy

- **Primary Branch**: `main`
- **Feature Branches**: `feature/description`
- **Bugfix Branches**: `bugfix/description`
- **Hotfix Branches**: `hotfix/description`

### Commit Message Format

```markdown
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `chore:` - Maintenance
- `perf:` - Performance
- `test:` - Tests
- `infra:` - Infrastructure

### File Organization Standards

```plaintext
howaiconnects/n8n-instance/
├── docker/
├── kubernetes/
├── scripts/
├── docs/
├── config/
└── .github/
```

---

## 🏢 Organization Standards (howaiconnects)

### Documentation Requirements

All repositories MUST include:

1. **README.md** - Overview, quick start, features
2. **CONTRIBUTING.md** - Development guidelines
3. **CHANGELOG.md** - Version history
4. **docs/** - Architecture, deployment, troubleshooting

### Code Quality Standards

- Use language-specific linters
- Require comments for complex logic
- Handle all external errors
- No hardcoded credentials

### Security Policies

✅ **Must Do**:

- Use environment variables for secrets
- Rotate credentials regularly
- Enable branch protection
- Require code reviews

❌ **Never**:

- Commit credentials or secrets
- Use hardcoded API keys
- Push to main directly

---

## 🚀 N8N Instance Operational Standards

### Running Services (Verify via SSH)

```bash
ssh dimoss@147.182.144.152 "docker ps --format 'table {{.Names}}\t{{.Status}}'"
```

Expected containers:

- n8n-compose-n8n-1 (Main)
- n8n-compose-n8n-worker-1, 2 (Workers)
- n8n-compose-postgres-1 (Database)
- n8n-compose-redis-1 (Queue)
- n8n-compose-traefik-1 (Load Balancer)

### Health Checks

```bash
# Full system health
ssh dimoss@147.182.144.152 "docker ps -a && docker stats --no-stream"
```plaintext
```

### Configuration Management

**Environment Variables Location**:

```bash
ssh dimoss@147.182.144.152 "cat /home/dimoss/n8n-compose/.env"
```

---

## 🔄 Development Workflow

### Feature Development

```bash
git checkout -b feature/new-feature
# Make changes
git add .
git commit -m "feat: describe the feature"
git push origin feature/new-feature
```

### Testing on Remote VM

```bash
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
git fetch origin
git checkout feature/new-feature
docker-compose down
docker-compose up -d
EOF
```

### Deployment to Production

```bash
# Only after PR approval and merge
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
git pull origin main
docker-compose down
docker-compose up -d
EOF
```

---

## 📊 Deployment Procedures

### Pre-Deployment Checklist

- [ ] All tests pass
- [ ] PR reviewed and approved
- [ ] Documentation updated
- [ ] Backup created

### Deployment Steps

```bash
# Step 1: Backup
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
docker exec n8n-compose-postgres-1 pg_dump -U n8n n8n > /tmp/backup-$(date +%Y%m%d-%H%M%S).sql
EOF

# Step 2: Pull and restart
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
git pull origin main
docker-compose down
docker-compose pull
docker-compose up -d
EOF
```

### Rollback Procedure

```bash
ssh dimoss@147.182.144.152 << 'EOF'
cd /home/dimoss/n8n-compose
git revert HEAD
docker-compose down
docker-compose up -d
EOF
```

---

## 🛡️ Security Guidelines

### SSH Key Management

✅ **Recommended**:

- Use SSH keys (not passwords)
- Store keys in `~/.ssh/` with 600 permissions
- Use key passphrases
- Rotate keys annually

### Credential Management

✅ **Do**:

- Store secrets in `.env` (not committed)
- Use environment variables in code
- Rotate API keys regularly

❌ **Never**:

- Commit credentials
- Share credentials via chat
- Hardcode API keys

---

## 🐛 Troubleshooting Remote Operations

### SSH Connection Issues

```bash
ssh -v dimoss@147.182.144.152 "echo connected"
```

### Container Issues

```bash
ssh dimoss@147.182.144.152 "docker logs n8n-compose-n8n-1 --tail 100"
```

### Network Issues

```bash
ssh dimoss@147.182.144.152 "nslookup github.com"
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
