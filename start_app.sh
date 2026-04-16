#!/bin/bash
# =============================================================================
# start_app.sh – Inicia los contenedores de Café Arábica.
# Programado con cron para arranque automático.
# Ejemplo cron (cada día a las 07:00):
#   0 7 * * * /opt/cafe-arabica/start_app.sh >> /var/log/cafe-cron.log 2>&1
# =============================================================================
set -euo pipefail

APP_DIR="/opt/cafe-arabica"
LOG_FILE="/var/log/cafe-arabica-app.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "INFO: Iniciando aplicación Café Arábica"

if [ ! -f "$APP_DIR/docker-compose.yml" ]; then
  log "ERROR: docker-compose.yml no encontrado en $APP_DIR"
  exit 1
fi

cd "$APP_DIR"
docker-compose start
log "INFO: Contenedores iniciados correctamente"
docker-compose ps | tee -a "$LOG_FILE"
