# Organizational Template Repository

This is the official N8N Queue Instance template repository for rapid deployment.

## About This Template

This template provides a production-ready N8N Queue mode deployment with:

- ✅ Multi-worker architecture for horizontal scaling
- ✅ Kubernetes-native deployment configurations
- ✅ Docker Compose for local development
- ✅ High Availability setup
- ✅ Auto-scaling with HPA
- ✅ Security policies and RBAC

## Using This Template

### Clone for New Deployment

```bash
# Create new repository from this template
gh repo create my-n8n-deployment --template adhameldeeb/n8n-queue-instance --private
```

### Customize for Your Environment

1. Update `.env.example` with your configuration
2. Modify `kubernetes/manifests.yaml` for your infrastructure
3. Update domain names in ingress configurations
4. Adjust resource limits based on your needs

## Quick Deployment

### Local Development

```bash
cp .env.example .env
docker-compose -f docker/docker-compose.dev.yml up -d
```

### Kubernetes Production

```bash
kubectl create namespace n8n
kubectl apply -f kubernetes/manifests.yaml
./scripts/health-check.sh
```

## Directory Structure

- `docker/` - Docker build files and Compose configurations
- `kubernetes/` - K8s manifests, Helm charts, and configurations
- `scripts/` - Deployment and utility scripts
- `docs/` - Comprehensive documentation
- `config/` - Configuration templates

## Support & Issues

- See `docs/TROUBLESHOOTING.md` for common issues
- Check `docs/ARCHITECTURE.md` for system design
- Review `docs/DEPLOYMENT.md` for detailed deployment steps

## License

Proprietary - Dimoss Organization
