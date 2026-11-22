#!/bin/bash

set -Eeuo pipefail

readonly C_RED='\033[0;91m'
readonly C_GREEN='\033[1;92m'
readonly C_GRAY='\033[1;90m'
readonly C_YELLOW='\033[1;93m'
readonly C_BLUE='\033[1;94m'
readonly C_RESET='\033[0m'

VERBOSITY=2

THIS_DIR="$(dirname "$(readlink --canonicalize "$0")")"

readonly LLAMA_SERVER_SERVICE_NAME="llama-server"
readonly COMPOSE_FILE="${THIS_DIR}/containers/docker-compose.yaml"
readonly DEFAULT_HARNESS_SERVICE_NAME="goose"
readonly HARNESSES=(
  "goose"
  "pi"
  # "aider"  # disabled because it'll fuck with my git config >:-(
)
CANDIDATE_HARNESS=""

VENV_NAME=".venv"
ACTIVATE="${THIS_DIR}/${VENV_NAME}/bin/activate"

function success() {
  printf "${C_GREEN}SUCCESS:${C_RESET} %s\n" "$@" >&2
}

function debug() {
  if [[ "${VERBOSITY}" -ge 2 ]]; then
    printf "${C_GRAY}DEBUG:  ${C_RESET} %s\n" "$@" >&2
  fi
}

function info() {
  if [[ "${VERBOSITY}" -ge 1 ]]; then
    printf "${C_BLUE}INFO:   ${C_RESET} %s\n" "$@" >&2
  fi
}

function warning() {
  printf "${C_YELLOW}WARNING:${C_RESET} %s\n" "$@" >&2
}

function error() {
  printf "${C_RED}ERROR:  ${C_RESET} %s\n" "$@" >&2
}

function usage() {
  cat <<EOF
Run a local LLM, defaulting to the ${DEFAULT_HARNESS_SERVICE_NAME} harness.

Usage: run.sh [<harness>]

Options:
  -l, --list-harnesses  List available harnesses.
  -h, --help            Show this help text.
EOF
}

function match_harness() {
  local candidate=$1

  for i in "${HARNESSES[@]}"; do
    debug "Checking for harness '${i}'..."
    if [[ "$i" == "${candidate}" ]]; then
      debug "Found '${i}'..."
      echo ${candidate}
      return
    else
      continue
    fi
    debug bottom of loop
  done
  error "Harness '${candidate}' not found. Please chose one of (${HARNESSES[*]})."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -l | --list-harnesses)
      echo "${HARNESSES[@]}"
      exit 0
      ;;
    -h | --help)
      usage >&2
      exit 0
      ;;
    -*)
      error "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -n "${CANDIDATE_HARNESS}" ]]; then
        error "Multiple harnesses specified (${CANDIDATE_HARNESS} $*)." >&2
        usage >&2
        exit 1
      fi
      HARNESS=$(match_harness $1)
      shift
      ;;
  esac
done

HARNESS="${HARNESS:-${DEFAULT_HARNESS_SERVICE_NAME}}"
info "Using harness ${HARNESS}"

(
  info "Activating ${VENV_NAME} in subshell"
  source "${ACTIVATE}"

  info "Starting ${LLAMA_SERVER_SERVICE_NAME}"
  podman-compose \
    --file "${COMPOSE_FILE}" \
    up \
    --detach \
    "${LLAMA_SERVER_SERVICE_NAME}"

  HOST_CWD=$(pwd)
  export WORKSPACE_PATH="${HOST_CWD}"
  info "Setting WORKSPACE_PATH to: ${WORKSPACE_PATH}"

  EMPTY_CUDA_DIR=$(mktemp -d)
  debug "Created dummy cuda compat dir at ${EMPTY_CUDA_DIR}"

  info "Starting harness container ${HARNESS}"
  podman-compose \
    --file "${COMPOSE_FILE}" \
    run \
    --rm \
    "${HARNESS}"
)
info "Done"
