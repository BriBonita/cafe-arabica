#!/bin/bash
# =============================================================================
# stop_app.sh – Detiene los contenedores de Café Arábica (sin eliminarlos).
# Programado con cron para apagado automático.
# Ejemplo cron (cada día a las 22:30):
#   30 22 * * * /opt/cafe-arabica/stop_app.sh >> /var/log/cafe-cron.log 2>&1
# =============================================================================
set -euo pipefail

APP_DIR="/opt/cafe-arabica"
LOG_FILE="/var/log/cafe-arabica-app.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "INFO: Deteniendo aplicación Café Arábica"

if [ ! -f "$APP_DIR/docker-compose.yml" ]; then
  log "ERROR: docker-compose.yml no encontrado en $APP_DIR"
  exit 1
fi

cd "$APP_DIR"
docker-compose stop
log "INFO: Contenedores detenidos correctamente"
