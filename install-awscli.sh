#!/usr/bin/env bash
set -euo pipefail

APP_NAME="aws"
OPT_DIR="${1:-${HOME}/.local/opt}"
BIN_DIR="${2:-${HOME}/.local/bin}"
INSTALL_DIR="${OPT_DIR}/aws-cli"

ARCH="$(uname -m)"

case "${ARCH}" in
  x86_64)  DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" ;;
  aarch64) DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" ;;
  *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
esac

echo "Installing AWS CLI v2..."

# Create directories if they don't exist
mkdir -p "${OPT_DIR}" "${BIN_DIR}"

# Check if binary already exists
if [ -f "${BIN_DIR}/${APP_NAME}" ]; then
    read -r -p "${BIN_DIR}/${APP_NAME} already exists. Overwrite? [y/N] " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/awscliv2.zip"
unzip -qo "${TMP_DIR}/awscliv2.zip" -d "${TMP_DIR}"

# --update is only checked when an existing installation is found, so it is safe on a first install
"${TMP_DIR}/aws/install" -i "${INSTALL_DIR}" -b "${BIN_DIR}" --update > /dev/null

echo "AWS CLI installed to ${BIN_DIR}/${APP_NAME}"
