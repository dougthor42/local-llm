#!/bin/bash

set -Eeuo pipefail

THIS_DIR="$(dirname "$(readlink --canonicalize "$0")")"

readonly BIN_DIR="${HOME}/.local/bin"
readonly BIN_NAME="llm_cli"
readonly BIN_FULL_PATH="${BIN_DIR}/${BIN_NAME}"

rm "${BIN_FULL_PATH}" || true

ln --symbolic "${THIS_DIR}/run.sh" "${BIN_FULL_PATH}"
