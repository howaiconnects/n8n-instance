# Troubleshooting Guide

## Common Issues & Solutions

### Pods Not Starting

**Problem**: Pods are stuck in `Pending` or `CrashLoopBackOff` state

**Solutions**:

```bash
# Check pod events
kubectl describe pod -n n8n <pod-name>

# Check resource availability
kubectl get nodes -o wide
kubectl top nodes

# Check PVC status
kubectl get pvc -n n8n
```

**Common causes**:
- Insufficient cluster resources
- PVC not bound to any node
- Image pull errors
- Resource requests too high

---

### Database Connection Issues

**Problem**: "Connection refused" errors in N8N logs

**Solutions**:

```bash
# Test PostgreSQL connection
kubectl exec -n n8n n8n-main-<pod> -- \
  psql -h postgres -U n8n -d n8n -c "SELECT 1"

# Check PostgreSQL pod status
kubectl logs -n n8n postgres-0

# Verify service DNS
kubectl exec -n n8n n8n-main-<pod> -- nslookup postgres
```

**Common causes**:
- PostgreSQL pod not running
- Incorrect credentials
- Network policy blocking traffic
- DNS resolution issues

---

### Queue Connection Issues

**Problem**: Workers cannot connect to Redis queue

**Solutions**:

```bash
# Test Redis connection
kubectl exec -n n8n n8n-main-<pod> -- \
  redis-cli -h redis ping

# Check Redis pod logs
kubectl logs -n n8n redis-0

# Verify Redis persistence
kubectl exec -n n8n redis-0 -- redis-cli DBSIZE
```

**Common causes**:
- Redis pod crashed
- Memory full (eviction in progress)
- Network connectivity issues
- Port binding issues

---

### High Memory Usage

**Problem**: Pods getting OOMKilled or memory exceeding limits

**Solutions**:

```bash
# Check memory usage
kubectl top pods -n n8n

# Check queue depth
kubectl exec -n n8n redis-0 -- redis-cli INFO stats

# View memory limits
kubectl get pod -n n8n -o yaml | grep memory
```

**Fixes**:
- Increase memory limits in manifests
- Reduce concurrent workflow executions
- Archive completed executions
- Scale to more worker pods

---

### Slow Workflow Execution

**Problem**: Workflows running slower than expected

**Solutions**:

```bash
# Check worker availability
kubectl get pods -n n8n -l app=n8n-worker

# Check queue depth
kubectl exec -n n8n redis-0 -- redis-cli LLEN bull:n8n:jobs:active

# Check CPU/Memory utilization
kubectl top pods -n n8n

# View N8N logs
kubectl logs -n n8n -l app=n8n-worker -f
```

**Optimizations**:
- Scale up worker replicas
- Increase resource requests
- Optimize workflow logic
- Check external API response times
- Enable caching where applicable

---

### Network Policy Blocking Traffic

**Problem**: Pods cannot communicate with each other

**Solutions**:

```bash
# Test connectivity between pods
kubectl run -it --rm debug --image=busybox -n n8n -- sh
# Inside pod: wget http://postgres:5432

# Check network policies
kubectl get networkpolicies -n n8n
kubectl describe networkpolicy n8n-network-policy -n n8n

# Temporarily disable for testing
kubectl delete networkpolicy -n n8n n8n-network-policy
```

**Note**: Only disable for troubleshooting, re-enable afterward.

---

### Persistent Volume Issues

**Problem**: "ReadWriteOnce" PVC cannot mount on multiple nodes

**Solutions**:

```bash
# Check storage class
kubectl get storageclass

# Check PVC binding
kubectl get pvc -n n8n -o wide

# For multiple nodes, use ReadWriteMany
# Edit manifests to use shared storage (NFS, EBS multi-attach, etc.)
```

---

### SSL/TLS Certificate Issues

**Problem**: "Certificate not found" or HTTPS not working

**Solutions**:

```bash
# Check Ingress status
kubectl get ingress -n n8n
kubectl describe ingress n8n-ingress -n n8n

# Check cert-manager
kubectl get certificates -n n8n

# Manually issue certificate
kubectl create secret tls n8n-tls --cert=path/to/cert --key=path/to/key -n n8n
```

---

### Deployment Stuck

**Problem**: Rollout not completing or pods not becoming ready

**Solutions**:

```bash
# Check rollout status
kubectl rollout status deployment/n8n-main -n n8n

# View rollout history
kubectl rollout history deployment/n8n-main -n n8n

# Rollback to previous version
kubectl rollout undo deployment/n8n-main -n n8n

# Force restart
kubectl rollout restart deployment/n8n-main -n n8n
```

---

### Workflow Execution Failures

**Problem**: Workflows failing silently or with vague errors

**Solutions**:

```bash
# Check execution logs
kubectl logs -n n8n -l app=n8n-worker --tail=100 -f

# Check N8N UI for error details
# Port forward to access UI
kubectl port-forward -n n8n svc/n8n-main 5678:80

# Check database for execution records
kubectl exec -n n8n postgres-0 -- \
  psql -U n8n n8n -c "SELECT * FROM execution LIMIT 10;"
```

---

### Out of Disk Space

**Problem**: "No space left on device" errors

**Solutions**:

```bash
# Check disk usage
kubectl df node
df -h

# Check PVC usage
kubectl exec -n n8n postgres-0 -- du -sh /var/lib/postgresql/data

# Clean up old executions (carefully!)
kubectl exec -n n8n postgres-0 -- \
  psql -U n8n n8n -c "DELETE FROM execution WHERE startedAt < NOW() - INTERVAL '30 days';"
```

---

## Getting Help

1. **Check logs**:
   ```bash
   kubectl logs -n n8n -l app=n8n-main --tail=50
   ```

2. **Describe resources**:
   ```bash
   kubectl describe pod -n n8n <pod-name>
   ```

3. **Check events**:
   ```bash
   kubectl get events -n n8n --sort-by='.lastTimestamp'
   ```

4. **Run diagnostics**:
   ```bash
   ./scripts/health-check.sh n8n
   ```

5. **Create diagnostic bundle**:
   ```bash
   kubectl debug pod -n n8n <pod-name> -it --image=busybox
   ```

---

## Prevention Tips

- ✅ Monitor resource usage regularly
- ✅ Set appropriate resource limits
- ✅ Enable persistent backups
- ✅ Test disaster recovery procedures
- ✅ Keep N8N and dependencies updated
- ✅ Use pod disruption budgets
- ✅ Enable network policies
- ✅ Monitor queue depth
- ✅ Archive old executions
- ✅ Use structured logging

---

## Still Need Help?

- Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Check [DEPLOYMENT.md](DEPLOYMENT.md) for setup issues
- Search N8N community forums
- Create an issue in the repository
