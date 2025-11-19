# Multi-stage build for N8N Queue Instance

# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /build

# Install build dependencies
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    pixman-dev

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Stage 2: Runtime
FROM node:18-alpine

WORKDIR /home/node/app

# Install runtime dependencies only
RUN apk add --no-cache \
    tini \
    curl \
    ca-certificates \
    libstdc++ \
    libgomp

# Create non-root user
RUN addgroup -g 1000 n8n && \
    adduser -D -u 1000 -G n8n n8n

# Copy from builder
COPY --from=builder --chown=n8n:n8n /build/node_modules ./node_modules

# Copy application files
COPY --chown=n8n:n8n . .

# Switch to non-root user
USER n8n

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Use tini as entrypoint for proper signal handling
ENTRYPOINT ["/sbin/tini", "--"]

# Start N8N
CMD ["node", "dist/index.js"]

# Metadata
LABEL org.opencontainers.image.title="N8N Queue Instance"
LABEL org.opencontainers.image.description="Multi-worker N8N deployment with queue mode"
LABEL org.opencontainers.image.vendor="Dimoss"
