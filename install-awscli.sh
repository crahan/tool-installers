#!/usr/bin/env bash
set -euo pipefail

APP_NAME="aws"
INSTALL_DIR="${1:-${HOME}/.local/bin}"
OPT_DIR="${HOME}/.local/opt"

ARCH="$(uname -m)"

case "${ARCH}" in
  x86_64)  DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" ;;
  aarch64) DOWNLOAD_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" ;;
  *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
esac

echo "Installing AWS CLI v2..."

# Create directories if they don't exist
mkdir -p "${INSTALL_DIR}"
mkdir -p "${OPT_DIR}"

# Check if binary already exists
if [ -f "${INSTALL_DIR}/${APP_NAME}" ]; then
    read -r -p "${INSTALL_DIR}/${APP_NAME} already exists. Overwrite? [y/N] " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

TMPDIR="$(mktemp -d)"
curl -fsSL "${DOWNLOAD_URL}" -o "${TMPDIR}/awscliv2.zip"
unzip -qo "${TMPDIR}/awscliv2.zip" -d "${TMPDIR}"

if [ -d "${OPT_DIR}/aws-cli" ]; then
    "${TMPDIR}/aws/install" -i "${OPT_DIR}/aws-cli" -b "${INSTALL_DIR}" --install > /dev/null
else
    "${TMPDIR}/aws/install" -i "${OPT_DIR}/aws-cli" -b "${INSTALL_DIR}" > /dev/null
fi
rm -rf "${TMPDIR}"

echo "AWS CLI installed to ${INSTALL_DIR}/${APP_NAME}"
if [ -f "${INSTALL_DIR}/${APP_NAME}" ]; then
    "${INSTALL_DIR}/${APP_NAME}" --version
fi
