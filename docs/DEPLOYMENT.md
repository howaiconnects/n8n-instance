# Deployment Guide

## Prerequisites

- Kubernetes cluster 1.24+ (EKS, AKS, GKE, or self-managed)
- `kubectl` configured to access your cluster
- Helm 3.x installed
- Persistent volume support enabled
- 4+ CPU cores, 8GB RAM minimum for cluster

## Quick Start - Kubernetes

### 1. Create Namespace

```bash
kubectl create namespace n8n
```

### 2. Create Secrets

```bash
# Generate secure values
DB_PASSWORD=$(openssl rand -base64 32)
ENCRYPTION_KEY=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)

# Create secret
kubectl create secret generic n8n-secrets \
  --from-literal=DB_POSTGRESDB_PASSWORD="$DB_PASSWORD" \
  --from-literal=N8N_ENCRYPTION_KEY="$ENCRYPTION_KEY" \
  --from-literal=N8N_USER_MANAGEMENT_JWT_SECRET="$JWT_SECRET" \
  -n n8n
```

### 3. Deploy Infrastructure

```bash
# Deploy base configuration
kubectl apply -f kubernetes/manifests.yaml

# Deploy HPA and network policies
kubectl apply -f kubernetes/hpa-workers.yaml
kubectl apply -f kubernetes/network-policy.yaml
```

### 4. Verify Deployment

```bash
./scripts/health-check.sh n8n
```

### 5. Access N8N

```bash
# Port forward for local access
kubectl port-forward -n n8n svc/n8n-main 5678:80

# Access at http://localhost:5678
```

## Production Deployment

### 1. Configure Domain & TLS

Create an Ingress for production:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: n8n-ingress
  namespace: n8n
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - n8n.yourdomain.com
    secretName: n8n-tls
  rules:
  - host: n8n.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: n8n-main
            port:
              number: 80
```

### 2. Configure Persistent Storage

For production, use real storage classes:

```bash
# Check available storage classes
kubectl get storageclass

# Update manifests to use your storage class
# Example for AWS EBS:
# storageClassName: ebs-sc
```

### 3. Set Environment Values

Update `config/.env` with production values:

```bash
N8N_HOST=n8n.yourdomain.com
N8N_PROTOCOL=https
DB_POSTGRESDB_PASSWORD=<secure-password>
N8N_ENCRYPTION_KEY=<secure-key>
```

### 4. Deploy with Helm (Optional)

```bash
helm repo add n8n-queue ./kubernetes/helm
helm install n8n-queue n8n-queue/chart \
  -n n8n \
  --values kubernetes/values-prod.yaml
```

## Scaling Configuration

### Horizontal Scaling (Workers)

The HPA automatically scales workers based on metrics:

```bash
# Manual scaling
./scripts/scale.sh n8n 5

# View HPA status
kubectl get hpa -n n8n

# Custom HPA thresholds (edit hpa-workers.yaml)
# - CPU threshold: 70% (default)
# - Memory threshold: 80% (default)
# - Max replicas: 10 (default)
```

### Vertical Scaling (Resource Limits)

Edit `kubernetes/manifests.yaml` to adjust:
- CPU requests/limits
- Memory requests/limits

## Backing Up Data

### PostgreSQL Backup

```bash
# Create manual backup
kubectl exec -n n8n postgres-0 -- pg_dump -U n8n n8n > backup.sql

# Restore from backup
kubectl exec -n n8n postgres-0 -- psql -U n8n n8n < backup.sql
```

### Redis Backup

```bash
# Get latest RDB file
kubectl exec -n n8n redis-0 -- cat /data/dump.rdb > redis-backup.rdb
```

## Monitoring

### View Logs

```bash
# N8N Main logs
kubectl logs -n n8n -l app=n8n-main -f

# Worker logs
kubectl logs -n n8n -l app=n8n-worker -f

# Database logs
kubectl logs -n n8n -l app=postgres -f
```

### Pod Metrics

```bash
# Install metrics-server (if not present)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# View resource usage
kubectl top pods -n n8n
kubectl top nodes
```

## Troubleshooting

### Pods not starting

```bash
# Check pod status
kubectl describe pod -n n8n <pod-name>

# Check events
kubectl get events -n n8n --sort-by='.lastTimestamp'
```

### Database connection issues

```bash
# Test PostgreSQL connection
kubectl exec -n n8n n8n-main-<pod> -- \
  psql -h postgres -U n8n -d n8n -c "SELECT 1"
```

### Queue issues

```bash
# Check Redis connection
kubectl exec -n n8n n8n-main-<pod> -- \
  redis-cli -h redis ping

# View queue depth
kubectl exec -n n8n redis-0 -- redis-cli --scan --pattern "*"
```

## Upgrade Process

### 1. Update Image Version

```yaml
# In kubernetes/manifests.yaml
image: n8n:latest  # Update tag
```

### 2. Apply Rolling Update

```bash
kubectl apply -f kubernetes/manifests.yaml
kubectl rollout status deployment/n8n-main -n n8n
```

### 3. Verify

```bash
./scripts/health-check.sh n8n
```

## Disaster Recovery

### 1. Enable Backups

```bash
# Daily backup cron job example
kubectl create cronjob n8n-backup --image=postgres:15-alpine \
  --schedule="0 2 * * *" \
  -- pg_dump -h postgres -U n8n n8n > /backups/backup-$(date +\%Y\%m\%d).sql
```

### 2. Multi-Region Setup

Deploy identical clusters in different regions and use DNS failover.

### 3. Recovery Steps

```bash
# 1. Restore database
kubectl exec -n n8n postgres-0 -- psql -U n8n n8n < backup.sql

# 2. Redeploy applications
kubectl apply -f kubernetes/manifests.yaml

# 3. Verify
./scripts/health-check.sh n8n
```
