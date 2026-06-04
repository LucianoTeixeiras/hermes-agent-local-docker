#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${ROOT}"

if [[ ! -f ".env" ]]; then
  echo "Missing .env. Run scripts/linux/bootstrap.sh first, then set API_SERVER_KEY." >&2
  exit 1
fi

docker compose up -d --build
docker compose ps
