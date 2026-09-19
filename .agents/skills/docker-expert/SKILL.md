---
name: docker-expert
description: Minimalist, production-ready containerization. Focuses on multi-stage builds, non-root users, minimal attack surface, layer caching, and clean docker-compose services. Use for Dockerfile creation, compose setups, or image optimization.
compatibility: opencode
---

# Docker Expert

Craft minimal, secure, and reproducible container environments without bloat.

## Principles

1. **Minimal Base**: Choose the smallest viable base image (distroless, alpine, or debian-slim). Never use untagged or `:latest` images in production.
2. **Multi-stage Builds**: Separate the build environment from the runtime environment. The runtime image must contain only the compiled artifact and runtime dependencies.
3. **Layer Cache Optimization**: Order instructions from least frequently changed to most frequently changed. Copy lockfiles and install dependencies before copying application source.
4. **Security by Default**:
   - Never run as `root`. Define and switch to an unprivileged user (`USER appuser`).
   - Keep secrets out of images. Never `COPY .env` or embed API keys in build args.
   - Use read-only root filesystems where practical.
5. **Hygiene**: Always pair every `Dockerfile` with a strict `.dockerignore` file excluding `.git`, test artifacts, local cache, and environment secrets.

## Dockerfile Pattern (Standard Multi-stage)

```dockerfile
# Build stage
FROM node:22-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --ignore-scripts
COPY . .
RUN npm run build && npm prune --production

# Runtime stage
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder --chown=appuser:appgroup /app/dist ./dist
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appgroup /app/package.json ./package.json
USER appuser
EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## Verification

- Inspect image size: ensure no build tools or devDependencies leaked into runtime.
- Verify user: run `docker run --rm <image> whoami` to confirm execution as non-root.
- Verify health: run the container and check logs for clean startup without runtime errors.
