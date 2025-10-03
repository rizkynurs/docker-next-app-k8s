# syntax=docker/dockerfile:1
# Multi-stage Dockerfile for a Next.js production image (lightweight)
# Stage 1: install deps
FROM node:20-alpine AS deps
WORKDIR /app
# Only copy package*.json to leverage Docker layer caching
COPY app/package*.json ./
# Install dependencies (prefer npm ci when lockfile exists)
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Stage 2: build
FROM node:20-alpine AS build
WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1
COPY --from=deps /app/node_modules ./node_modules
COPY app/ ./
# Build the app (Next.js standalone mode configured in next.config.js)
RUN mkdir -p public && npm run build

# Stage 3: runtime (minimal, production)
FROM node:20-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1
# Copy the standalone server output
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public
# Expose port
EXPOSE 3000
# Basic healthcheck
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=5       CMD wget -qO- http://localhost:3000/api/healthz || exit 1
# Run as non-root (node user exists in node:alpine)
USER node
# Entry file is created by Next.js in standalone mode
CMD ["node", "server.js"]
