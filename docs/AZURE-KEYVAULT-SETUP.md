# Azure Key Vault Integration Guide

**Purpose**: Secure credential management for N8N Instance using Azure Key Vault  
**Status**: Template for implementation  
**Version**: 1.0

---

## 🔐 Overview

Azure Key Vault provides centralized, enterprise-grade secret management for the N8N Instance, replacing hardcoded credentials and .env files in production environments.

### Benefits

- ✅ Centralized secret management
- ✅ Automatic rotation policies
- ✅ Audit logging and compliance
- ✅ Access control and RBAC
- ✅ Encryption at rest and in transit
- ✅ Integrated with Kubernetes secrets

---

## 📋 Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated
- Kubernetes cluster with Azure identity (AKS recommended)
- N8N Instance running on AKS or with Azure SDKs

---

## 🚀 Setup Steps

### Step 1: Create Azure Key Vault

```bash
# Set variables
RESOURCE_GROUP="n8n-rg"
KEY_VAULT_NAME="n8n-kv-$(date +%s)"
LOCATION="canadacentral"  # Same as DO region equivalent

# Create resource group (if not exists)
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Key Vault
az keyvault create \
  --resource-group $RESOURCE_GROUP \
  --name $KEY_VAULT_NAME \
  --location $LOCATION \
  --enable-rbac-authorization true

echo "Key Vault created: $KEY_VAULT_NAME"
```

### Step 2: Store Secrets in Key Vault

```bash
# Database credentials
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "db-username" \
  --value "n8n"

az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "db-password" \
  --value "$(openssl rand -base64 32)"

# Redis password
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "redis-password" \
  --value "$(openssl rand -base64 32)"

# N8N encryption keys
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "n8n-encryption-key" \
  --value "$(openssl rand -base64 32)"

# GitHub token
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "github-token" \
  --value "$GITHUB_TOKEN"

echo "Secrets stored in Key Vault"
```

### Step 3: Configure Key Vault Access

```bash
# Get current user's object ID
USER_ID=$(az ad signed-in-user show --query id -o tsv)

# Grant secret reader role
az role assignment create \
  --assignee $USER_ID \
  --role "Key Vault Secrets User" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"

echo "Access configured"
```

### Step 4: Update .env.example with Key Vault References

```bash
# Create production-ready .env.example

cat > .env.example << 'EOF'
# ===== Database Configuration =====
# Reference: azure://keyvault/db-username and azure://keyvault/db-password
DB_HOST=postgres
DB_PORT=5432
DB_NAME=n8n
DB_USER=${VAULT_DB_USERNAME}  # Retrieved from Key Vault
DB_PASSWORD=${VAULT_DB_PASSWORD}  # Retrieved from Key Vault

# ===== Redis Configuration =====
# Reference: azure://keyvault/redis-password
QUEUE_MODE_ACTIVE=true
QUEUE_BULL_REDIS_HOST=redis
QUEUE_BULL_REDIS_PORT=6379
QUEUE_BULL_REDIS_PASSWORD=${VAULT_REDIS_PASSWORD}  # Retrieved from Key Vault

# ===== N8N Configuration =====
# Reference: azure://keyvault/n8n-encryption-key
N8N_ENCRYPTION_KEY=${VAULT_N8N_ENCRYPTION_KEY}  # Retrieved from Key Vault
N8N_HOST=n8n.example.com
N8N_PORT=5678
N8N_PROTOCOL=https

# ===== GitHub Integration =====
# Reference: azure://keyvault/github-token
GITHUB_TOKEN=${VAULT_GITHUB_TOKEN}  # Retrieved from Key Vault

# ===== Key Vault Configuration =====
AZURE_KEYVAULT_NAME=n8n-kv-xxxxx
AZURE_KEYVAULT_URL=https://n8n-kv-xxxxx.vault.azure.net/
AZURE_TENANT_ID=${VAULT_AZURE_TENANT_ID}
AZURE_CLIENT_ID=${VAULT_AZURE_CLIENT_ID}
AZURE_CLIENT_SECRET=${VAULT_AZURE_CLIENT_SECRET}

# ===== Monitoring & Logging =====
LOG_LEVEL=info
SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
EOF

cat .env.example
```

---

## 🐳 Docker Integration

### Using Azure SDK in Docker

```dockerfile
# Dockerfile snippet for Key Vault integration
FROM node:18-alpine

# Install Azure CLI for secret retrieval
RUN apk add --no-cache python3 py3-pip

# Copy application
COPY . /app
WORKDIR /app

# Install dependencies
RUN npm ci --only=production

# Install Azure SDK
RUN npm install @azure/identity @azure/keyvault-secrets

# Script to fetch secrets from Key Vault before starting N8N
COPY scripts/fetch-secrets.sh /app/fetch-secrets.sh
RUN chmod +x /app/fetch-secrets.sh

# Entrypoint that fetches secrets then starts N8N
ENTRYPOINT ["/app/fetch-secrets.sh"]
CMD ["node", "bin/n8n"]
```

### Fetch Secrets Script

```bash
#!/bin/bash
# scripts/fetch-secrets.sh

set -e

echo "Fetching secrets from Azure Key Vault..."

# Authenticate to Azure
if [ -z "$AZURE_CLIENT_SECRET" ]; then
  echo "Using Managed Identity..."
  export AZURE_AUTH_METHOD="managed_identity"
else
  echo "Using Service Principal..."
  export AZURE_AUTH_METHOD="service_principal"
fi

# Fetch secrets using Azure CLI
fetch_secret() {
  local secret_name=$1
  local env_var=$2
  
  echo "Fetching: $secret_name"
  value=$(az keyvault secret show \
    --vault-name $AZURE_KEYVAULT_NAME \
    --name $secret_name \
    --query value -o tsv)
  
  export "$env_var=$value"
}

# Fetch all required secrets
fetch_secret "db-username" "DB_USER"
fetch_secret "db-password" "DB_PASSWORD"
fetch_secret "redis-password" "QUEUE_BULL_REDIS_PASSWORD"
fetch_secret "n8n-encryption-key" "N8N_ENCRYPTION_KEY"
fetch_secret "github-token" "GITHUB_TOKEN"

echo "All secrets loaded successfully"

# Execute the main command
exec "$@"
```

---

## ☸️ Kubernetes Integration

### Using Key Vault with AKS

```yaml
# kubernetes/keyvault-secret-provider.yaml

apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: n8n-keyvault
spec:
  provider: azure
  parameters:
    usePodIdentity: "true"  # Use AKS Pod Identity
    keyvaultName: "n8n-kv-xxxxx"
    tenantId: "${AZURE_TENANT_ID}"
    objects: |
      array:
        - |
          objectName: db-username
          objectType: secret
          objectAlias: DB_USER
        - |
          objectName: db-password
          objectType: secret
          objectAlias: DB_PASSWORD
        - |
          objectName: redis-password
          objectType: secret
          objectAlias: REDIS_PASSWORD
        - |
          objectName: n8n-encryption-key
          objectType: secret
          objectAlias: N8N_ENCRYPTION_KEY
```

### Pod with Key Vault Secrets

```yaml
# kubernetes/n8n-deployment-with-keyvault.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: n8n
  namespace: n8n
spec:
  replicas: 2
  selector:
    matchLabels:
      app: n8n
  template:
    metadata:
      labels:
        app: n8n
    spec:
      containers:
      - name: n8n
        image: n8n:latest
        volumeMounts:
        - name: secrets-mount
          mountPath: "/mnt/secrets"
          readOnly: true
        env:
        - name: DB_USER
          valueFrom:
            secretKeyRef:
              name: n8n-secrets
              key: db-username
        - name: DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: n8n-secrets
              key: db-password
        - name: AZURE_KEYVAULT_NAME
          value: "n8n-kv-xxxxx"
      volumes:
      - name: secrets-mount
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "n8n-keyvault"
```

---

## 🔄 Secret Rotation

### Automatic Rotation Policy

```bash
# Set rotation policy for secrets

# Database password - rotate every 90 days
az keyvault secret set-attributes \
  --vault-name $KEY_VAULT_NAME \
  --name db-password \
  --expires $(($(date +%s) + 90 * 24 * 3600))

# API tokens - rotate every 30 days
az keyvault secret set-attributes \
  --vault-name $KEY_VAULT_NAME \
  --name github-token \
  --expires $(($(date +%s) + 30 * 24 * 3600))
```

### Manual Rotation Script

```bash
#!/bin/bash
# scripts/rotate-secrets.sh

set -e

VAULT_NAME="n8n-kv-xxxxx"
SECRETS_TO_ROTATE=("db-password" "redis-password" "github-token")

for secret in "${SECRETS_TO_ROTATE[@]}"; do
  echo "Rotating secret: $secret"
  
  # Generate new value
  new_value=$(openssl rand -base64 32)
  
  # Update in Key Vault
  az keyvault secret set \
    --vault-name $VAULT_NAME \
    --name $secret \
    --value "$new_value"
  
  # Trigger pod restart to pick up new values
  kubectl rollout restart deployment/n8n -n n8n
  
  echo "Secret rotated and pods restarted"
done
```

---

## 📊 Monitoring & Auditing

### Enable Key Vault Logging

```bash
# Create storage account for logs
STORAGE_ACCOUNT="n8nlogs$(date +%s)"

az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS

# Enable diagnostic logging
az monitor diagnostic-settings create \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME \
  --name keyvault-diagnostics \
  --storage-account $STORAGE_ACCOUNT \
  --logs '[{"category": "AuditEvent", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'

echo "Diagnostic logging enabled"
```

### View Access Logs

```bash
# View recent secret accesses
az monitor activity-log list \
  --resource-group $RESOURCE_GROUP \
  --query "[?contains(resourceId, '$KEY_VAULT_NAME')]" \
  --output table
```

---

## ✅ Validation Checklist

Before using in production:

- [ ] Key Vault created and accessible
- [ ] All secrets stored securely
- [ ] Access control configured (RBAC)
- [ ] Rotation policies set
- [ ] Docker integration tested
- [ ] Kubernetes secrets synced
- [ ] Audit logging enabled
- [ ] Monitoring dashboard created
- [ ] Backup/recovery plan documented
- [ ] Team trained on Key Vault usage

---

## 🔐 Security Best Practices

✅ **DO**:
- Use Managed Identity on AKS
- Enable firewall on Key Vault
- Rotate secrets regularly
- Audit all access
- Use separate vaults for dev/test/prod
- Enable soft delete on vault
- Use RBAC for access control

❌ **DON'T**:
- Store secrets in code or config files
- Share credentials via chat/email
- Use long-term credentials
- Skip audit logging
- Use same credentials across environments
- Disable access controls

---

## 🚨 Troubleshooting

### Cannot Access Key Vault

```bash
# Check authentication
az account show

# Verify Key Vault permissions
az keyvault show --name $KEY_VAULT_NAME

# List role assignments
az role assignment list --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.KeyVault/vaults/$KEY_VAULT_NAME"
```

### Secret Not Found

```bash
# List all secrets
az keyvault secret list --vault-name $KEY_VAULT_NAME

# Check secret value
az keyvault secret show --vault-name $KEY_VAULT_NAME --name SECRET_NAME
```

### Pod Cannot Access Secrets

```bash
# Check pod identity
kubectl describe pod POD_NAME -n n8n

# Check secret provider
kubectl get secretproviderclass -n n8n

# View pod logs
kubectl logs POD_NAME -n n8n
```

---

## 📚 References

- [Azure Key Vault Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [AKS Key Vault Integration](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)
- [Azure Identity SDK](https://learn.microsoft.com/en-us/python/api/azure-identity/)

---

**Status**: Template ready for implementation  
**Version**: 1.0  
**Last Updated**: 2025-11-19

