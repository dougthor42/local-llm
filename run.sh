#!/bin/bash

set -Eeuo pipefail

readonly C_RED='\033[0;91m'
readonly C_GREEN='\033[1;92m'
readonly C_YELLOW='\033[1;93m'
readonly C_BLUE='\033[1;94m'
readonly C_RESET='\033[0m'

readonly LLAMA_SERVER_SERVICE_NAME="llama-server"
readonly COMPOSE_FILE="containers/docker-compose.yaml"
readonly HARNESS_SERVICE_NAME="pi"

THIS_DIR="$(dirname "$(readlink --canonicalize "$0")")"
VENV_NAME=".venv"
ACTIVATE="${THIS_DIR}/${VENV_NAME}/bin/activate"

function success() {
  printf "${C_GREEN}SUCCESS:${C_RESET} %s\n" "$@" >&2
}

function info() {
  printf "${C_BLUE}INFO:   ${C_RESET} %s\n" "$@" >&2
}

function warning() {
  printf "${C_YELLOW}WARNING:${C_RESET} %s\n" "$@" >&2
}

function error() {
  printf "${C_RED}ERROR:  ${C_RESET} %s\n" "$@" >&2
}

(
  info "Activating ${VENV_NAME} in subshell"
  source "${ACTIVATE}"


  info "Starting ${LLAMA_SERVER_SERVICE_NAME}"
  podman-compose \
    --file "${COMPOSE_FILE}" \
    up \
    --detach \
    "${LLAMA_SERVER_SERVICE_NAME}"

  info "Starting harness container ${HARNESS_SERVICE_NAME}"
  podman-compose \
    --file "${COMPOSE_FILE}" \
    run \
    --rm \
    "${HARNESS_SERVICE_NAME}"
)
