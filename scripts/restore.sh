#!/usr/bin/env bash
set -euo pipefail
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <grafana_backup.tgz> <prometheus_backup.tgz>"
  exit 1
fi

GRAFANA_ARCHIVE="$1"
PROM_ARCHIVE="$2"

GRAF_VOL="${COMPOSE_PROJECT_NAME:-docker-next-app}_grafana_data"
PROM_VOL="${COMPOSE_PROJECT_NAME:-docker-next-app}_prometheus_data"

echo "[INFO] Restoring Grafana volume: $GRAF_VOL from $GRAFANA_ARCHIVE"
docker run --rm -v "$GRAF_VOL":/data -v "$PWD":/backups alpine       sh -c "rm -rf /data/* && tar xzf /backups/$(basename "$GRAFANA_ARCHIVE") -C / --strip-components=1 data"

echo "[INFO] Restoring Prometheus volume: $PROM_VOL from $PROM_ARCHIVE"
docker run --rm -v "$PROM_VOL":/data -v "$PWD":/backups alpine       sh -c "rm -rf /data/* && tar xzf /backups/$(basename "$PROM_ARCHIVE") -C / --strip-components=1 data"

echo "[OK] Restore completed."
