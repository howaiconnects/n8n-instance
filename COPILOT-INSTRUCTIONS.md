---
applyTo: "howaiconnects/n8n-instance"
description: "Copilot Behavior Guidelines - AI Agent Behaviors, SSH Operations, and Code Generation Patterns"
---

# 🤖 Copilot Instructions - N8N Instance

**Purpose**: Define Copilot behavior patterns, SSH operations, and AI agent guidelines for the `howaiconnects/n8n-instance` repository.

**Scope**: All Copilot interactions with this repository and the DO N8N Instance (147.182.144.152).

---

## 🔴 PRIMARY COPILOT RULES

### Rule 1: SSH-First Pattern for Remote Operations

**ALWAYS establish SSH connection before executing any remote commands.**

```bash
ssh dimoss@147.182.144.152 "command"
```

- ✅ **DO**: Prefix all remote commands with SSH
- ❌ **DON'T**: Assume local execution
- ✅ **DO**: Verify remote context in responses
- ❌ **DON'T**: Execute commands without SSH prefix

### Rule 2: Separate Instruction Contexts

**ALWAYS distinguish between**:

- **COPILOT-INSTRUCTIONS.md** - How Copilot should behave
- **PROJECT-MANAGEMENT-INSTRUCTIONS.md** - How the team should work
- **COPILOT-SSH-INSTRUCTIONS.md** - SSH-specific remote operation patterns

### Rule 3: Error Handling & Validation

**Copilot MUST**:

- [ ] Verify SSH connection before executing commands
- [ ] Capture and report command errors
- [ ] Suggest rollback procedures
- [ ] Log security-sensitive operations
- [ ] Validate file permissions (600 for keys, 700 for dirs)

### Rule 4: Code Examples in Responses

**Every code example MUST include**:

- SSH prefix (if remote operation)
- Error handling
- Expected output
- Alternative methods (if applicable)
- Language identifier in code block

### Rule 5: Documentation References

When answering questions, **Copilot MUST reference**:

1. **COPILOT-INSTRUCTIONS.md** - For Copilot behaviors
2. **PROJECT-MANAGEMENT-INSTRUCTIONS.md** - For team standards
3. **COPILOT-SSH-INSTRUCTIONS.md** - For remote operations
4. **docs/ARCHITECTURE.md** - For system design
5. **docs/DEPLOYMENT.md** - For deployment procedures

---

## 🔧 SSH Operation Patterns

### Pattern 1: Single Remote Command

```bash
ssh dimoss@147.182.144.152 "command_here"
```

**Example:**

```bash
ssh dimoss@147.182.144.152 "docker ps -a"
```

### Pattern 2: Multi-Line Remote Operations

```bash
ssh dimoss@147.182.144.152 << 'EOF'
command1
command2
command3
EOF
```

### Pattern 3: File Transfer (SCP)

```bash
# Download
scp dimoss@147.182.144.152:/path/to/file /local/path

# Upload
scp /local/file dimoss@147.182.144.152:/path/to/destination
```

### Pattern 4: Error Handling Pattern

```bash
ssh dimoss@147.182.144.152 "command" || {
  echo "Command failed"
  exit 1
}
```

### Pattern 5: Output Capture Pattern

```bash
output=$(ssh dimoss@147.182.144.152 "command")
if [ $? -eq 0 ]; then
  echo "Result: $output"
else
  echo "Failed to execute command"
fi
```

---

## 📋 Required Copilot Behaviors

### When Answering Questions

✅ **DO**:

- Provide SSH-prefixed examples for remote operations
- Reference relevant documentation files
- Include error handling in code examples
- Explain WHY SSH is needed
- Verify context before suggesting commands

❌ **DON'T**:

- Execute commands without SSH for remote operations
- Assume local file system access to /home/dimoss/\*
- Mix local and remote operations in single example
- Ignore security implications
- Suggest hardcoding credentials

### When Making Code Changes

✅ **DO**:

- Update CHANGELOG.md with changes
- Follow commit message format: `<type>(<scope>): <subject>`
- Reference issue numbers in commits
- Test changes on feature branch first
- Require PR review before merge to main

❌ **DON'T**:

- Commit directly to main
- Include credentials in code
- Make multiple unrelated changes in one commit
- Update version numbers without agreement
- Push without CI/CD checks

### When Troubleshooting

✅ **DO**:

- Use SSH to check remote status
- Verify Docker containers are healthy
- Check database and queue connectivity
- Review logs from remote services
- Suggest diagnostic commands first

❌ **DON'T**:

- Assume services are running
- Suggest SQL/database modifications without backup
- Restart services without health check after
- Skip backup procedures
- Execute destructive commands without confirmation

---

## 🔍 Pre-Operation Checklist

Before any remote operation, Copilot MUST verify:

- [ ] SSH connection to 147.182.144.152 is available
- [ ] User is `dimoss`
- [ ] Docker is accessible: `docker --version`
- [ ] N8N services running: `docker ps | grep n8n`
- [ ] Database healthy: `docker exec n8n-compose-postgres-1 pg_isready`
- [ ] Queue healthy: `docker exec n8n-compose-redis-1 redis-cli ping`
- [ ] Disk space available: `df -h` (> 10% free)
- [ ] Network connectivity: `ping 8.8.8.8`

---

## 🛡️ Security Guidelines

### Credential Handling

✅ **Copilot MUST**:

- Never suggest hardcoding credentials
- Reference Azure Key Vault for secrets
- Use environment variables from .env
- Recommend credential rotation (quarterly)
- Always use SSH keys (not passwords)

❌ **Copilot MUST NEVER**:

- Display .env file contents in responses
- Suggest committing .env files
- Share credentials via chat/logs
- Use default passwords
- Create new credentials without rotation plan

### Git & Repository Security

✅ **Copilot MUST**:

- Require branch protection on main
- Enforce PR reviews before merge
- Verify commit signatures
- Check for secrets in commits
- Audit access logs regularly

---

## 📊 Copilot-Specific Commands

### Check Remote System Status

```bash
ssh dimoss@147.182.144.152 << 'EOF'
echo "=== System Info ===" && uname -a
echo "=== Docker Services ===" && docker ps -a
echo "=== Memory ===" && free -h
echo "=== Disk ===" && df -h
EOF
```

### Verify Copilot Context

```bash
# Verify correct context
ssh dimoss@147.182.144.152 "pwd && whoami && cat ~/.ssh/config | grep -A5 n8n" 2>/dev/null || echo "Context verification failed"
```

### Test SSH Connection

```bash
ssh dimoss@147.182.144.152 "echo 'SSH Connection Successful' && echo 'Working Directory:' && pwd"
```

---

## 🤖 AI Agent Behaviors

### Code Generation

When generating code for this repository, Copilot SHOULD:

1. **Always use SSH** for remote operations
2. **Follow commit conventions**: `feat:`, `fix:`, `docs:`, `chore:`, `infra:`
3. **Include error handling** in all scripts
4. **Add comments** for complex logic
5. **Use environment variables** for configuration
6. **Test locally first** before remote deployment
7. **Reference documentation** in code comments

### Problem Solving

When troubleshooting issues, Copilot SHOULD:

1. **Gather context** - Ask clarifying questions
2. **Check diagnostics** - Run health check scripts
3. **Review logs** - Use `docker logs` via SSH
4. **Verify connectivity** - Test network/DNS/ports
5. **Suggest debugging** - Provide step-by-step procedures
6. **Document findings** - Update TROUBLESHOOTING.md
7. **Provide rollback** - Always include undo steps

### Learning & Adaptation

Copilot SHOULD:

- Learn from project patterns and conventions
- Adapt to team preferences and standards
- Suggest improvements to procedures
- Update documentation when discovering issues
- Reference similar patterns in existing code
- Avoid repeating solved problems

---

## 📚 Reference Documentation

**Copilot must be aware of and reference**:

| File                               | Purpose                                 |
| ---------------------------------- | --------------------------------------- |
| COPILOT-INSTRUCTIONS.md            | This file - Copilot behavior guidelines |
| PROJECT-MANAGEMENT-INSTRUCTIONS.md | Team/project standards                  |
| COPILOT-SSH-INSTRUCTIONS.md        | SSH operation patterns                  |
| docs/ARCHITECTURE.md               | System design and components            |
| docs/DEPLOYMENT.md                 | Deployment procedures                   |
| docs/TROUBLESHOOTING.md            | Common issues and solutions             |
| README.md                          | Project overview                        |
| CONTRIBUTING.md                    | Development workflow                    |

---

## ✅ Validation Checklist

**Copilot interactions should always**:

- [ ] Use SSH for remote operations (147.182.144.152)
- [ ] Include error handling in code examples
- [ ] Reference relevant documentation
- [ ] Verify context before suggesting changes
- [ ] Never suggest hardcoding credentials
- [ ] Include pre-operation safety checks
- [ ] Provide rollback procedures
- [ ] Follow commit message conventions
- [ ] Require PR review for main changes
- [ ] Test locally before deployment

---

## 🔄 Update Procedures

When Copilot needs to update this file:

1. Always maintain version number (e.g., 1.0 → 1.1)
2. Update lastUpdated timestamp
3. Document all changes in CHANGELOG.md
4. Create a PR with detailed explanation
5. Require review before merging
6. Test in development environment
7. Deploy to main with merge commit

---

**Status**: Active - Governing all Copilot interactions with this repository  
**Version**: 1.0 (2025-11-19)  
**Applies To**: howaiconnects/n8n-instance repository and DO N8N Instance (147.182.144.152)
