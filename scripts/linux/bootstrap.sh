#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_PATH="${ROOT}/.env"
EXAMPLE_PATH="${ROOT}/.env.example"
DATA_PATH="${ROOT}/hermes-data"

PORTAL=0
if [[ "${1:-}" == "--portal" ]]; then
  PORTAL=1
fi

if [[ ! -f "${ENV_PATH}" ]]; then
  cp "${EXAMPLE_PATH}" "${ENV_PATH}"
  echo "Created .env from .env.example. Edit API_SERVER_KEY before starting the gateway."
fi

mkdir -p "${DATA_PATH}"

if [[ "${PORTAL}" == "1" ]]; then
  docker run -it --rm -v "${DATA_PATH}:/opt/data" nousresearch/hermes-agent setup --portal
else
  docker run -it --rm -v "${DATA_PATH}:/opt/data" nousresearch/hermes-agent setup
fi
