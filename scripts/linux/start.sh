#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

ROOT="$(hermes_project_root)"
cd "${ROOT}"
ENV_PATH="${ROOT}/.env"

REQUESTED_DATA_MODE=""
if [[ "${1:-}" == "--volume" || "${1:-}" == "--named-volume" ]]; then
  REQUESTED_DATA_MODE="volume"
elif [[ "${1:-}" == "--bind" ]]; then
  REQUESTED_DATA_MODE="bind"
elif [[ $# -gt 0 ]]; then
  echo "Unknown option: $1" >&2
  echo "Usage: $0 [--bind|--volume]" >&2
  exit 1
fi

if [[ ! -f ".env" ]]; then
  echo "Missing .env. Run scripts/linux/bootstrap.sh first, then set API_SERVER_KEY." >&2
  exit 1
fi

DATA_MODE="$(hermes_resolve_data_mode "${ROOT}" "${ENV_PATH}" "${REQUESTED_DATA_MODE}")"
DATA_VOLUME="$(hermes_data_volume_name "${ENV_PATH}")"
hermes_print_data_mode_notice "${DATA_MODE}" "${ROOT}" "${DATA_VOLUME}"

if [[ "${DATA_MODE}" == "volume" ]]; then
  docker volume create "${DATA_VOLUME}" >/dev/null
  docker compose -f docker-compose.yml -f docker-compose.volume.yml up -d --build
  docker compose -f docker-compose.yml -f docker-compose.volume.yml ps
else
  docker compose up -d --build
  docker compose ps
fi
