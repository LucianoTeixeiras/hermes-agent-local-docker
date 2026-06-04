#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"

DATA_MODE="${HERMES_DATA_MODE:-bind}"
if [[ "${1:-}" == "--volume" || "${1:-}" == "--named-volume" ]]; then
  DATA_MODE="volume"
elif [[ "${1:-}" == "--bind" ]]; then
  DATA_MODE="bind"
elif [[ $# -gt 0 ]]; then
  echo "Unknown option: $1" >&2
  echo "Usage: $0 [--bind|--volume]" >&2
  exit 1
fi

if [[ "${DATA_MODE}" == "volume" ]]; then
  docker compose -f docker-compose.yml -f docker-compose.volume.yml down
else
  docker compose down
fi
