#!/usr/bin/env bash
set -euo pipefail
mkdir -p backups
date_str="$(date +%F_%H-%M-%S)"
# Use the Compose project name to refer to volumes; adjust if your project name differs
PROM_VOL="${COMPOSE_PROJECT_NAME:-docker-next-app}_prometheus_data"
GRAF_VOL="${COMPOSE_PROJECT_NAME:-docker-next-app}_grafana_data"

echo "[INFO] Backing up Prometheus volume: $PROM_VOL"
docker run --rm -v "$PROM_VOL":/data -v "$PWD/backups":/backups alpine       sh -c "tar czf /backups/prometheus_data_${date_str}.tgz -C / data"

echo "[INFO] Backing up Grafana volume: $GRAF_VOL"
docker run --rm -v "$GRAF_VOL":/data -v "$PWD/backups":/backups alpine       sh -c "tar czf /backups/grafana_data_${date_str}.tgz -C / data"

echo "[OK] Backups written to ./backups"
