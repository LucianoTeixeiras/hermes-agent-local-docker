#!/usr/bin/env bash

hermes_project_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd
}

hermes_env_value() {
  local name="$1"
  local env_path="$2"

  if [[ -f "${env_path}" ]]; then
    awk -F= -v key="${name}" '
      $0 !~ /^[[:space:]]*#/ && $1 == key {
        sub(/^[^=]*=/, "")
        gsub(/\r/, "")
        gsub(/^[[:space:]]+|[[:space:]]+$/, "")
        gsub(/^"|"$/, "")
        gsub(/^'\''|'\''$/, "")
        print
        exit
      }
    ' "${env_path}"
  fi
}

hermes_validate_volume_name() {
  local volume="$1"

  if [[ ! "${volume}" =~ ^[a-zA-Z0-9][a-zA-Z0-9_.-]*$ ]]; then
    echo "Invalid Docker volume name: ${volume@Q}" >&2
    echo "Use only letters, numbers, underscore, dot and dash. Example: hermes-agent-data" >&2
    exit 1
  fi
}

hermes_is_wsl_windows_mount() {
  local root="$1"

  if [[ ! -r /proc/version ]] || ! grep -qiE "microsoft|wsl" /proc/version; then
    return 1
  fi

  [[ "${root}" =~ ^/mnt/[a-zA-Z](/|$) ]]
}

hermes_resolve_data_mode() {
  local root="$1"
  local env_path="$2"
  local requested="${3:-}"
  local env_mode

  env_mode="$(hermes_env_value HERMES_DATA_MODE "${env_path}")"

  if [[ -n "${requested}" ]]; then
    echo "${requested}"
  elif [[ -n "${HERMES_DATA_MODE:-}" ]]; then
    echo "${HERMES_DATA_MODE}"
  elif [[ -n "${env_mode}" ]]; then
    echo "${env_mode}"
  elif hermes_is_wsl_windows_mount "${root}"; then
    echo "volume"
  else
    echo "bind"
  fi
}

hermes_data_volume_name() {
  local env_path="$1"
  local env_volume

  env_volume="$(hermes_env_value HERMES_DATA_VOLUME "${env_path}")"
  local volume="${HERMES_DATA_VOLUME:-${env_volume:-hermes-agent-data}}"
  volume="${volume//$'\r'/}"
  hermes_validate_volume_name "${volume}"
  echo "${volume}"
}

hermes_print_data_mode_notice() {
  local mode="$1"
  local root="$2"
  local volume="$3"

  if [[ "${mode}" == "volume" ]]; then
    echo "Hermes data mode: Docker named volume (${volume})."
    echo "This avoids chmod/logging issues on WSL paths backed by Windows/OneDrive."
  else
    echo "Hermes data mode: local bind mount (${root}/hermes-data)."
  fi
}
