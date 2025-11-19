# Architecture Overview

## System Design

```
┌─────────────────────────────────────────────────────┐
│               External Clients                       │
└────────────────┬────────────────────────────────────┘
                 │
                 │ HTTPS
                 ▼
        ┌────────────────┐
        │   Load Balancer │
        │  (Ingress/LB)  │
        └────────────┬───┘
                     │
        ┌────────────┴──────────────┐
        │                           │
        ▼                           ▼
    ┌───────────────┐        ┌──────────────┐
    │  N8N Main #1  │        │  N8N Main #2 │
    │  (Primary)    │        │  (Standby)   │
    └───────┬───────┘        └──────┬───────┘
            │                       │
            └───────────┬───────────┘
                        │
                ┌───────┴────────┐
                │                │
                ▼                ▼
          ┌──────────┐    ┌──────────────┐
          │ PostgreSQL   │  │    Redis    │
          │ (Metadata)   │  │   (Queue)   │
          └──────────┘    └──────────────┘
                │                │
                └────────┬───────┘
                         │
        ┌────────────────┴────────────────┐
        │                                 │
        ▼                                 ▼
    ┌─────────────┐              ┌─────────────┐
    │N8N Worker #1│              │N8N Worker #N│
    │   (Active)  │ ... more ... │   (Active)  │
    └─────────────┘              └─────────────┘
```

## Components

### N8N Main
- **Purpose**: Manages workflows, UI, API endpoints
- **Replicas**: 2 (HA setup)
- **Responsibilities**:
  - Workflow management
  - Web UI hosting
  - REST API
  - Queue coordination
- **Scaling**: Manual or auto-scaling based on API load

### N8N Workers
- **Purpose**: Execute queued jobs
- **Replicas**: 3-10 (auto-scales)
- **Responsibilities**:
  - Workflow execution
  - Job processing
  - Activity polling
- **Scaling**: Horizontal via HPA (CPU/Memory based)

### PostgreSQL
- **Purpose**: Data persistence
- **Setup**: Single instance with persistent volume
- **Database**: n8n metadata
- **Backup**: Regular snapshots recommended

### Redis
- **Purpose**: Job queue backend
- **Setup**: Single instance with persistence
- **Data**: Bull queue data
- **Memory**: Monitor and adjust based on queue depth

## Data Flow

1. **User Action**: User creates/triggers workflow via UI
2. **API Processing**: N8N Main receives request
3. **Queue Creation**: Job enqueued to Redis Bull queue
4. **Worker Assignment**: Available worker picks up job
5. **Execution**: Worker processes the workflow
6. **Result Storage**: Results saved to PostgreSQL
7. **UI Update**: N8N Main fetches and displays results

## High Availability

### N8N Main HA
- Multiple replicas behind load balancer
- Anti-affinity rules prevent co-location
- Shared state via PostgreSQL
- Stateless design enables easy scaling

### Data Persistence HA
- PostgreSQL: Daily backups to external storage
- Redis: AOF persistence enabled
- Both use persistent volumes with snapshots

### Failover
- Automatic pod restart on failure
- Health checks every 30 seconds
- Automatic traffic rerouting via service mesh

## Security Layers

```
┌─────────────────────────────┐
│  Ingress / Load Balancer    │
│  (TLS/HTTPS)                │
└──────────┬──────────────────┘
           │
│ ┌────────┴─────────────────┐
│ │ Network Policy            │
│ │ (Pod-to-pod)             │
│ └──────────┬────────────────┘
│            │
│ ┌──────────┴────────────────┐
│ │ RBAC / ServiceAccount      │
│ │ (API Access Control)       │
│ └────────────────────────────┘
│
└─ Application Layer
   - Secret Management
   - Encryption Keys
   - JWT Authentication
```

## Resource Allocation

### N8N Main
- **CPU Request**: 250m
- **CPU Limit**: 500m
- **Memory Request**: 512Mi
- **Memory Limit**: 1Gi

### N8N Worker
- **CPU Request**: 250m
- **CPU Limit**: 1000m
- **Memory Request**: 512Mi
- **Memory Limit**: 2Gi

### PostgreSQL
- **CPU Request**: 100m
- **CPU Limit**: 500m
- **Memory Request**: 256Mi
- **Memory Limit**: 512Mi
- **Storage**: 20Gi persistent volume

### Redis
- **CPU Request**: 100m
- **CPU Limit**: 500m
- **Memory Request**: 256Mi
- **Memory Limit**: 512Mi
- **Storage**: 10Gi persistent volume

## Monitoring & Observability

### Metrics
- Pod CPU/Memory usage
- Queue depth (Redis)
- Database query performance
- Workflow execution times

### Logging
- Application logs: `/var/log/n8n/`
- Database logs: PostgreSQL logs
- Access logs: Ingress controller logs

### Alerts
- Pod restart rate > 2 in 5 min
- Memory utilization > 90%
- Queue depth > threshold
- API response time > 5s
