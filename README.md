# N8N Queue Instance - Multi-Worker Deployment Template

Enterprise-grade N8N Queue Mode deployment template with multi-worker scalability, optimized for Kubernetes and self-hosted environments.

## Features

- **Queue Mode Architecture**: Distributed job processing with multiple workers
- **Kubernetes Ready**: Production-ready Helm charts and manifests included
- **Auto-Scaling**: Horizontal pod autoscaling based on queue depth
- **High Availability**: Redis-backed queue with failover support
- **Docker Optimized**: Minimal images with multi-stage builds
- **Infrastructure as Code**: Complete IaC setup for rapid deployment
- **Multi-Environment Support**: Dev, staging, and production configurations

## Quick Start

### Prerequisites

- Docker & Docker Compose (for local development)
- Kubernetes 1.24+ (for production deployment)
- Helm 3.x (for K8s deployment)
- Redis (for queue backend)
- PostgreSQL 12+ (for N8N database)

### Local Development with Docker Compose

```bash
# Clone and setup
git clone <repository-url>
cd n8n-queue-instance

# Start with docker-compose
docker-compose -f docker/docker-compose.dev.yml up -d

# Access N8N
# UI: http://localhost:5678
# API: http://localhost:5678/api
```

### Kubernetes Deployment

```bash
# Install using Helm
helm repo add n8n-queue ./kubernetes/helm
helm repo update

# Deploy to cluster
helm install n8n-queue n8n-queue/chart \
  --namespace n8n \
  --values kubernetes/values-prod.yaml
```

## Project Structure

```
.
├── docker/                 # Docker build files and compose configs
│   ├── Dockerfile          # Multi-stage N8N image build
│   ├── docker-compose.dev.yml
│   ├── docker-compose.prod.yml
│   └── .dockerignore
├── kubernetes/             # K8s manifests and Helm charts
│   ├── helm/              # Helm chart for deployments
│   ├── manifests/         # Raw K8s YAML files
│   ├── kustomize/         # Kustomize overlays (dev/staging/prod)
│   └── values-*.yaml      # Environment-specific values
├── config/                 # Configuration templates
│   ├── .env.example       # Environment variables template
│   ├── n8n.json          # N8N configuration
│   └── redis.conf        # Redis configuration
├── scripts/               # Deployment and utility scripts
│   ├── deploy.sh         # Deployment automation
│   ├── scale.sh          # Worker scaling script
│   └── health-check.sh   # Health verification
├── docs/                  # Documentation
│   ├── ARCHITECTURE.md
│   ├── DEPLOYMENT.md
│   ├── TROUBLESHOOTING.md
│   └── SCALING.md
└── .github/workflows/     # CI/CD pipelines
    ├── build.yml         # Docker image build
    ├── deploy.yml        # Automated deployment
    └── tests.yml         # Test suite
```

## Configuration

### Environment Variables

Copy `.env.example` to `.env` and update values:

```bash
# Core
N8N_PORT=5678
N8N_PROTOCOL=https
N8N_HOST=your-domain.com
N8N_EDITOR_BASE_URL=https://your-domain.com/

# Database
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=secure_password

# Queue
QUEUE_MODE_ACTIVE=true
QUEUE_BULL_REDIS_HOST=redis
QUEUE_BULL_REDIS_PORT=6379

# Workers
N8N_WORKER_COUNT=3
N8N_WORKER_MEMORY_LIMIT=2048
```

### Queue Configuration

Edit `config/n8n.json` for queue-specific settings:

```json
{
  "queue": {
    "mode": "bull",
    "redis": {
      "host": "redis",
      "port": 6379,
      "db": 0,
      "maxRetriesPerRequest": null,
      "enableReadyCheck": false
    },
    "bull": {
      "concurrency": 1,
      "lockDuration": 30000,
      "lockRenewTime": 15000
    }
  }
}
```

## Deployment Guides

### Development Environment

```bash
cd docker
docker-compose -f docker-compose.dev.yml up -d
```

### Production on Kubernetes

See [DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed instructions.

### Scaling Workers

```bash
./scripts/scale.sh --workers 5 --namespace production
```

## Monitoring & Logging

### Health Checks

```bash
./scripts/health-check.sh
```

### Logs

```bash
# Docker
docker-compose logs -f n8n-main
docker-compose logs -f n8n-worker

# Kubernetes
kubectl logs -n n8n -l app=n8n-main -f
kubectl logs -n n8n -l app=n8n-worker -f
```

### Metrics

Access Prometheus metrics at: `http://localhost:9090`

## High Availability Setup

This template includes HA configuration with:

- Redis Sentinel for database failover
- PostgreSQL replication (optional)
- Multiple N8N main instances
- Distributed worker pool
- Load balancing with Nginx/HAProxy

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed HA setup.

## Security

- API authentication required
- TLS/SSL support included
- Secret management via K8s secrets or Vault
- RBAC policies included
- Network policies for pod isolation

## Troubleshooting

Common issues and solutions in [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Contributing

1. Create a branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -am 'Add feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Submit a pull request

## Support

- Issues: GitHub Issues
- Documentation: `/docs` folder
- Community: N8N Community Forum

## License

Proprietary - Dimoss Organization

## Version

- **Current**: 1.0.0
- **N8N Version**: Latest
- **Last Updated**: November 2025
