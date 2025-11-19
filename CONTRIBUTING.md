# Contributing Guidelines

## Repository Structure

```
n8n-queue-instance/
├── docker/                 # Docker builds
├── kubernetes/             # K8s manifests and Helm
├── config/                 # Configuration templates
├── scripts/                # Automation scripts
├── docs/                   # Documentation
└── .github/                # GitHub workflows and templates
```

## Development Workflow

1. Clone the repository
2. Create a feature branch: `git checkout -b feature/description`
3. Make changes following conventions below
4. Commit with meaningful messages
5. Push and create a Pull Request

## Naming Conventions

### Branches

- `feature/*` - New features
- `bugfix/*` - Bug fixes
- `hotfix/*` - Production hotfixes
- `docs/*` - Documentation updates

### Commits

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `chore:` - Maintenance
- `perf:` - Performance improvement

Example: `git commit -m "feat: add Redis Sentinel support"`

## Code Standards

### Kubernetes YAML

- Use snake_case for field names
- Include resource limits/requests
- Document non-obvious configurations
- Use ConfigMaps for non-sensitive data
- Use Secrets for sensitive data

### Bash Scripts

- Include shebang: `#!/bin/bash`
- Add usage comments
- Use error handling: `set -e`
- Validate inputs

### Docker

- Use Alpine images for smaller size
- Multi-stage builds for optimization
- Non-root user for security
- Health checks included

## Documentation

- Update `README.md` for user-facing changes
- Add/update docs in `docs/` folder
- Include examples and use cases
- Document breaking changes in CHANGELOG

## Testing

1. Test locally with Docker Compose
2. Test K8s deployment in minikube or kind cluster
3. Verify scaling works correctly
4. Test backup/restore procedures

## Pull Request Process

1. Update documentation
2. Include test results
3. Add description of changes
4. Link related issues
5. Request review from maintainers
6. Ensure CI/CD passes

## Release Process

1. Update version in package.json
2. Update CHANGELOG.md
3. Create release tag: `git tag -a v1.0.0 -m "Release 1.0.0"`
4. Push tags: `git push origin --tags`
5. Create GitHub Release with notes

## Questions?

Create an issue with the `question` label or contact the maintainers.
