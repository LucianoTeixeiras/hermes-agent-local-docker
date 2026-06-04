#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ENV_PATH="${ROOT}/.env"
EXAMPLE_PATH="${ROOT}/.env.example"
DATA_PATH="${ROOT}/hermes-data"
DATA_VOLUME="${HERMES_DATA_VOLUME:-hermes-agent-data}"

PORTAL=0
DATA_MODE="${HERMES_DATA_MODE:-bind}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --portal)
      PORTAL=1
      shift
      ;;
    --volume|--named-volume)
      DATA_MODE="volume"
      shift
      ;;
    --bind)
      DATA_MODE="bind"
      shift
      ;;
    *)
      echo "Unknown option: $1" >&2
      echo "Usage: $0 [--portal] [--bind|--volume]" >&2
      exit 1
      ;;
  esac
done

if [[ ! -f "${ENV_PATH}" ]]; then
  cp "${EXAMPLE_PATH}" "${ENV_PATH}"
  echo "Created .env from .env.example. Edit API_SERVER_KEY before starting the gateway."
fi

if [[ "${DATA_MODE}" == "volume" ]]; then
  docker volume create "${DATA_VOLUME}" >/dev/null
  DATA_MOUNT="${DATA_VOLUME}:/opt/data"
else
  mkdir -p "${DATA_PATH}"
  DATA_MOUNT="${DATA_PATH}:/opt/data"
fi

if [[ "${PORTAL}" == "1" ]]; then
  docker run -it --rm -v "${DATA_MOUNT}" nousresearch/hermes-agent setup --portal
else
  docker run -it --rm -v "${DATA_MOUNT}" nousresearch/hermes-agent setup
fi
