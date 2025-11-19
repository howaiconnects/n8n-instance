#!/bin/bash

# N8N Queue Instance - Health Check Script
# Checks the health of all N8N components

set -e

NAMESPACE="${1:-n8n}"
TIMEOUT=10

echo "=== N8N Queue Instance Health Check ==="
echo "Namespace: $NAMESPACE"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_pod() {
    local pod_name=$1
    local namespace=$2
    
    echo -n "Checking $pod_name... "
    
    if kubectl get pod -n "$namespace" -l app="$pod_name" &>/dev/null; then
        local status=$(kubectl get pod -n "$namespace" -l app="$pod_name" -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "Unknown")
        
        if [ "$status" = "Running" ]; then
            echo -e "${GREEN}✓ Running${NC}"
            return 0
        else
            echo -e "${RED}✗ Status: $status${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⊗ Not found${NC}"
        return 2
    fi
}

check_service() {
    local service_name=$1
    local namespace=$2
    
    echo -n "Checking service $service_name... "
    
    if kubectl get svc -n "$namespace" "$service_name" &>/dev/null; then
        echo -e "${GREEN}✓ Available${NC}"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Check components
echo "Pod Status:"
check_pod "n8n-main" "$NAMESPACE"
check_pod "n8n-worker" "$NAMESPACE"
check_pod "postgres" "$NAMESPACE"
check_pod "redis" "$NAMESPACE"

echo ""
echo "Service Status:"
check_service "n8n-main" "$NAMESPACE"
check_service "postgres" "$NAMESPACE"
check_service "redis" "$NAMESPACE"

echo ""
echo "N8N API Health:"
n8n_pod=$(kubectl get pod -n "$NAMESPACE" -l app=n8n-main -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$n8n_pod" ]; then
    if kubectl exec -n "$NAMESPACE" "$n8n_pod" -- curl -s http://localhost:5678/healthz &>/dev/null; then
        echo -e "${GREEN}✓ N8N API responding${NC}"
    else
        echo -e "${RED}✗ N8N API not responding${NC}"
    fi
else
    echo -e "${YELLOW}⊗ No N8N pods found${NC}"
fi

echo ""
echo "Replica Status:"
kubectl get deployments -n "$NAMESPACE" -o wide

echo ""
echo "=== Health check complete ==="
