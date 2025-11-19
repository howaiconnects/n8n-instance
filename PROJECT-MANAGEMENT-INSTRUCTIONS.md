---
applyTo: "howaiconnects/n8n-instance"
description: "Project Management Instructions - Team Standards, Policies, and Organizational Guidelines"
---

# 📋 Project Management Instructions - N8N Instance

**Purpose**: Define team standards, project policies, organizational guidelines, and development workflows for the `howaiconnects/n8n-instance` repository.

**Scope**: All team members, contributors, and stakeholders working on this project.

---

## 🏢 Organization Standards (howaiconnects)

### Repository Naming Convention

- **Format**: lowercase, hyphenated, descriptive
- **Example**: `n8n-instance` ✅ (not `n8n_instance` or `N8NInstance`)
- **Length**: 20-50 characters recommended
- **Purpose**: Clear from name alone

### Documentation Requirements

**Every repository MUST include**:

1. **README.md**

   - Project overview and purpose
   - Quick start guide
   - Key features and capabilities
   - Links to detailed documentation
   - License information

2. **CONTRIBUTING.md**

   - Development environment setup
   - Code style guide
   - PR process and requirements
   - Testing requirements
   - Commit message conventions

3. **CHANGELOG.md**

   - Semantic versioning (MAJOR.MINOR.PATCH)
   - Release dates for each version
   - New features, bug fixes, breaking changes
   - Links to PRs/issues

4. **docs/ Directory**
   - ARCHITECTURE.md - System design
   - DEPLOYMENT.md - Setup and deployment
   - TROUBLESHOOTING.md - Common issues
   - API documentation (if applicable)

### Code Quality Standards

| Standard    | Requirement                                            |
| ----------- | ------------------------------------------------------ |
| Linting     | Language-specific linters (shellcheck, yamllint, etc.) |
| Comments    | Complex logic must be commented                        |
| Errors      | All external calls must handle errors                  |
| Credentials | NO hardcoded credentials or secrets                    |
| Testing     | Unit tests for critical paths                          |
| Security    | Security scanning in CI/CD                             |

### Security Policies

✅ **MUST DO**:

- Use environment variables for all configuration
- Rotate credentials quarterly
- Enable branch protection on main
- Require code review for all PRs
- Use SSH keys (not passwords) for access
- Enable security scanning in CI/CD

❌ **NEVER**:

- Commit .env files or credentials
- Use hardcoded API keys
- Push directly to main
- Skip security reviews
- Ignore security warnings
- Share credentials via chat/email

---

## 📊 Repository Standards (n8n-instance)

### Branch Strategy

**Main Branch**:

- `main` - Production-ready code
- ✅ Protected branch (require PR review)
- ✅ Require status checks pass
- ✅ Require branches up to date

**Feature Branches**:

- `feature/description-of-feature` - New features
- `bugfix/description-of-bug` - Bug fixes
- `hotfix/description-of-issue` - Production hotfixes
- `chore/description-of-task` - Maintenance tasks
- `docs/description-of-documentation` - Documentation updates

**Branch Naming Rules**:

- Use lowercase, hyphenated descriptions
- Be specific: `feature/user-authentication` ✅ (not `feature/fix`)
- Include issue number if applicable: `feature/add-logging-#42`
- Delete after merge

### Commit Message Format

```plaintext
<type>(<scope>): <subject>

<body>

<footer>
```

**Commit Types**:

| Type  | Purpose        | Example                                  |
| ----- | -------------- | ---------------------------------------- |
| feat  | New feature    | `feat(docker): add multi-stage build`    |
| fix   | Bug fix        | `fix(worker): handle queue timeout`      |
| docs  | Documentation  | `docs(deployment): update K8s guide`     |
| chore | Maintenance    | `chore(deps): update dependencies`       |
| perf  | Performance    | `perf(queries): optimize database calls` |
| test  | Tests          | `test(health): add endpoint tests`       |
| infra | Infrastructure | `infra(k8s): add network policies`       |

**Commit Rules**:

- Subject: 50 chars or less, imperative mood
- Body: Explain WHAT and WHY (not HOW)
- Footer: Reference issues (#123) and breaking changes
- Example:

  ```
  feat(queue): implement job retry mechanism

  Add exponential backoff for failed jobs with max 3 retries.
  Redis queue now persists job state for recovery.

  Fixes #42
  ```

### File Organization Standards

```plaintext
howaiconnects/n8n-instance/
├── docker/                    # Docker configurations
│   ├── Dockerfile             # Production image
│   ├── docker-compose.dev.yml # Local development
│   └── .dockerignore
├── kubernetes/                # K8s deployment
│   ├── manifests.yaml         # Core resources
│   ├── hpa-workers.yaml       # Auto-scaling
│   └── network-policy.yaml    # Security
├── scripts/                   # Automation
│   ├── health-check.sh
│   └── scale.sh
├── docs/                      # Documentation
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   └── TROUBLESHOOTING.md
├── config/                    # Configuration
│   └── .env.example
├── .github/                   # GitHub automation
│   └── workflows/
├── .gitignore
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── COPILOT-INSTRUCTIONS.md
├── COPILOT-SSH-INSTRUCTIONS.md
└── PROJECT-MANAGEMENT-INSTRUCTIONS.md
```

### PR (Pull Request) Process

**Before Creating PR**:

- [ ] Create feature branch: `git checkout -b feature/description`
- [ ] Make changes following code standards
- [ ] Run tests: `npm test` or equivalent
- [ ] Run linters: `eslint`, `shellcheck`, `yamllint`
- [ ] Commit with proper message format
- [ ] Push to remote: `git push origin feature/description`

**When Creating PR**:

- [ ] Title: Clear, descriptive (same as commit subject)
- [ ] Description: Explain changes, link issues (#42)
- [ ] Reference related issues: "Closes #42"
- [ ] Screenshots/examples if applicable
- [ ] Checklist:
  - [ ] Tests pass
  - [ ] Documentation updated
  - [ ] No breaking changes (or documented)
  - [ ] Code reviewed by self

**PR Review Requirements**:

- ✅ At least 1 approval required
- ✅ All status checks must pass
- ✅ Branch must be up to date
- ✅ No merge conflicts
- ✅ Commits properly formatted

**After Approval**:

- [ ] Squash and merge (for single feature)
- [ ] Delete branch after merge
- [ ] Close related issues
- [ ] Update CHANGELOG.md

---

## 🚀 Development Workflow

### Local Development Setup

```bash
# 1. Clone repository
git clone https://github.com/howaiconnects/n8n-instance.git
cd n8n-instance

# 2. Install dependencies
docker-compose -f docker/docker-compose.dev.yml build

# 3. Start local environment
docker-compose -f docker/docker-compose.dev.yml up -d

# 4. Verify
docker-compose -f docker/docker-compose.dev.yml ps
```

### Feature Development

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes and test locally
# ... edit files, run tests ...

# 3. Commit changes
git add .
git commit -m "feat(scope): description of feature"

# 4. Push and create PR
git push origin feature/my-feature
# Then create PR on GitHub
```

### Testing Requirements

**Before Push**:

- Unit tests pass
- Integration tests pass
- Linters pass (shellcheck, yamllint)
- No security warnings

**Docker Testing**:

```bash
docker-compose -f docker/docker-compose.dev.yml run n8n npm test
```

### Deployment Workflow

**Staging/Development**:

1. PR created on feature branch
2. Tests pass on PR
3. Code reviewed
4. Merge to main
5. CI/CD deploys to staging

**Production**:

1. Tag release: `git tag -a v1.0.0 -m "Release 1.0.0"`
2. Push tag: `git push origin v1.0.0`
3. GitHub Actions builds and pushes image
4. Manual approval for production deployment
5. Deploy to production

---

## 📋 N8N Instance Operational Standards

### Service Health Requirements

**Critical Services** (must always be running):

- n8n-compose-n8n-1 (Main N8N instance)
- n8n-compose-postgres-1 (Database)
- n8n-compose-redis-1 (Queue backend)

**Supporting Services**:

- n8n-compose-n8n-worker-\* (Scale as needed)
- n8n-compose-traefik-1 (Load balancer)

### Deployment Checklist

**Pre-Deployment**:

- [ ] All tests pass
- [ ] PR approved
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Database migration tested
- [ ] Backup created
- [ ] Rollback plan documented

**Deployment Steps**:

1. Tag release in GitHub
2. CI/CD builds and tests
3. Manual approval for prod
4. Deploy to production
5. Verify health checks
6. Monitor for errors

**Post-Deployment**:

- [ ] Health checks passing
- [ ] Services responding
- [ ] No error logs
- [ ] Performance acceptable
- [ ] Document deployment

### Backup & Recovery Standards

**Backup Schedule**:

- Database: Daily at 2 AM UTC
- Configuration: On every deployment
- Retention: 30 days minimum

**Recovery Procedures**:

1. Identify time of backup needed
2. Stop services: `docker-compose stop`
3. Restore database
4. Restore configuration files
5. Verify integrity
6. Restart services

---

## 🛡️ Security Guidelines

### Credential Management

**Storage**:

- ✅ Use Azure Key Vault for secrets
- ✅ Use environment variables in containers
- ✅ Use .env files locally (not committed)
- ❌ Never hardcode credentials
- ❌ Never commit .env files

**Rotation Policy**:

- API Keys: Every 90 days
- Database passwords: Every 180 days
- SSH keys: Every 365 days
- Review: Quarterly

### Access Control

**SSH Access**:

- ✅ SSH keys only (no passwords)
- ✅ Key-based authentication
- ✅ Disable password login
- ✅ Limited user accounts (dimoss)

**GitHub Access**:

- ✅ 2FA required for all accounts
- ✅ Personal access tokens expire yearly
- ✅ SSH keys for git operations
- ✅ Audit access logs quarterly

### Code Security

**Required Checks**:

- ✅ Static code analysis (linting)
- ✅ Secret scanning (no credentials)
- ✅ Dependency scanning (vulnerabilities)
- ✅ Container scanning (image vulnerabilities)

---

## 📊 Release Management

### Semantic Versioning

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (e.g., 1.0.0 → 2.0.0)
- **MINOR**: New features, backward compatible (e.g., 1.0.0 → 1.1.0)
- **PATCH**: Bug fixes (e.g., 1.0.0 → 1.0.1)

### Release Process

1. **Prepare Release**:

   - Update version in package.json
   - Update CHANGELOG.md
   - Create release PR: `release/v1.0.0`

2. **Testing**:

   - Run all tests
   - Manual verification
   - Security scanning

3. **Tag Release**:

   - Merge PR to main
   - Create tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
   - Push tag: `git push origin v1.0.0`

4. **Deploy**:

   - CI/CD builds image
   - Manual approval
   - Deploy to production

5. **Verify**:
   - Health checks pass
   - Monitor logs
   - Performance acceptable

---

## 🔄 Meeting & Communication Standards

### Planning Meetings

**Sprint Planning** (Bi-weekly):

- Review backlog
- Estimate effort
- Assign tasks
- Set sprint goals

**Daily Standup** (15 min):

- What did I accomplish?
- What will I do today?
- Any blockers?

### Communication Channels

- **Code Changes**: Pull requests with detailed descriptions
- **Issues**: GitHub Issues for bugs and features
- **Discussions**: GitHub Discussions for architecture/design
- **Documentation**: README.md, CONTRIBUTING.md, docs/

---

## 📚 Documentation Standards

**All documentation MUST**:

- Use Markdown format
- Include code examples
- Have clear headings (H2, H3)
- Link to related docs
- Include troubleshooting section
- Keep updated with code changes

**Code Comments**:

- Complex logic: Explain WHY
- Functions: Include parameters and return values
- Todos: Mark with `// TODO: description`

---

## ✅ Compliance Checklist

**Repository Compliance**:

- [ ] README.md exists and complete
- [ ] CONTRIBUTING.md exists
- [ ] CHANGELOG.md maintained
- [ ] docs/ directory exists
- [ ] COPILOT-INSTRUCTIONS.md exists
- [ ] PROJECT-MANAGEMENT-INSTRUCTIONS.md exists
- [ ] .gitignore configured
- [ ] Branch protection enabled
- [ ] PR reviews required
- [ ] CI/CD configured

**Team Compliance**:

- [ ] All commits follow format
- [ ] PR descriptions complete
- [ ] Reviews completed timely
- [ ] Issues tracked in GitHub
- [ ] Changelog kept current
- [ ] Documentation updated
- [ ] Security checks passed
- [ ] Tests maintained

---

## 📞 Escalation & Support

**Issue Categories**:

- **Bug**: Unexpected behavior - create Issue
- **Feature**: Enhancement - create Discussion first
- **Security**: Vulnerability - contact owners directly
- **Deployment**: Production issue - page on-call

**Resolution SLA**:

- Critical (production down): 1 hour
- High (major feature broken): 4 hours
- Medium (feature impact): 1 business day
- Low (minor issue): 1 week

---

**Status**: Active - Governing project management and team standards  
**Version**: 1.0 (2025-11-19)  
**Organization**: howaiconnects  
**Repository**: n8n-instance  
**Applies To**: All team members and contributors
