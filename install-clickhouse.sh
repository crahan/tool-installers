#!/usr/bin/env bash
set -euo pipefail

APP_NAME="clickhouse"
INSTALL_DIR="${1:-${HOME}/.local/bin}"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  DIR="amd64" ;;
      aarch64) DIR="aarch64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64)  DIR="macos" ;;
      arm64)   DIR="macos-aarch64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac

echo "Installing ClickHouse..."

# Construct download URL
DOWNLOAD_URL="https://builds.clickhouse.com/master/${DIR}/clickhouse"

# Create install directory if it doesn't exist
mkdir -p "${INSTALL_DIR}"

# Check if binary already exists
if [ -f "${INSTALL_DIR}/${APP_NAME}" ]; then
    read -r -p "${INSTALL_DIR}/${APP_NAME} already exists. Overwrite? [y/N] " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Download clickhouse binary directly to install directory
curl -fsSL "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/${APP_NAME}"

chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo "ClickHouse installed to ${INSTALL_DIR}/${APP_NAME}"
"${INSTALL_DIR}/${APP_NAME}" --version
