#!/bin/bash

# N8N Queue Instance - Scale Workers Script
# Scales the N8N worker deployment

set -e

NAMESPACE="${1:-n8n}"
WORKER_COUNT="${2:-3}"

echo "=== N8N Worker Scaling ==="
echo "Namespace: $NAMESPACE"
echo "Target replicas: $WORKER_COUNT"

kubectl scale deployment n8n-worker -n "$NAMESPACE" --replicas="$WORKER_COUNT"

echo "Waiting for deployment to scale..."
kubectl rollout status deployment/n8n-worker -n "$NAMESPACE"

echo ""
echo "Current worker status:"
kubectl get pods -n "$NAMESPACE" -l app=n8n-worker

echo ""
echo "Scaling complete!"
