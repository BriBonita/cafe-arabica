#!/bin/bash
# =============================================================================
# deploy.sh – Clona el repositorio, construye las imágenes y levanta los
#             contenedores de Café Arábica.
# Uso: bash deploy.sh [REPO_URL]
# =============================================================================
set -euo pipefail

REPO_URL="${1:-https://github.com/tu-usuario/cafe-arabica.git}"
APP_DIR="/opt/cafe-arabica"
LOG_FILE="/var/log/cafe-arabica-deploy.log"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

log "INFO: Iniciando despliegue de Café Arábica"

# ── 1. Verifica dependencias ────────────────────────────────────────────────
for cmd in git docker docker-compose; do
  if ! command -v "$cmd" &>/dev/null; then
    log "ERROR: '$cmd' no está instalado. Abortando."
    exit 1
  fi
done

# ── 2. Clona o actualiza el repositorio ────────────────────────────────────
if [ -d "$APP_DIR/.git" ]; then
  log "INFO: Repositorio existente – actualizando con git pull"
  git -C "$APP_DIR" pull --ff-only
else
  log "INFO: Clonando repositorio en $APP_DIR"
  git clone "$REPO_URL" "$APP_DIR"
fi

cd "$APP_DIR"

# ── 3. Construye las imágenes ───────────────────────────────────────────────
log "INFO: Construyendo imágenes Docker"
docker-compose build --no-cache

# ── 4. Levanta los contenedores ─────────────────────────────────────────────
log "INFO: Iniciando contenedores en modo detached"
docker-compose up -d

# ── 5. Verifica estado ──────────────────────────────────────────────────────
sleep 5
log "INFO: Estado de los contenedores:"
docker-compose ps | tee -a "$LOG_FILE"

log "INFO: Despliegue completado. Visita http://$(curl -s ifconfig.me):8080"
