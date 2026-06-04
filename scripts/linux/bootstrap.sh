#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

ROOT="$(hermes_project_root)"
ENV_PATH="${ROOT}/.env"
EXAMPLE_PATH="${ROOT}/.env.example"
DATA_PATH="${ROOT}/hermes-data"

PORTAL=0
REQUESTED_DATA_MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --portal)
      PORTAL=1
      shift
      ;;
    --volume|--named-volume)
      REQUESTED_DATA_MODE="volume"
      shift
      ;;
    --bind)
      REQUESTED_DATA_MODE="bind"
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

DATA_MODE="$(hermes_resolve_data_mode "${ROOT}" "${ENV_PATH}" "${REQUESTED_DATA_MODE}")"
DATA_VOLUME="$(hermes_data_volume_name "${ENV_PATH}")"
hermes_print_data_mode_notice "${DATA_MODE}" "${ROOT}" "${DATA_VOLUME}"

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
