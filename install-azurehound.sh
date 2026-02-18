#!/usr/bin/env bash
set -euo pipefail

APP_NAME="azurehound"
REPO="SpecterOps/AzureHound"
INSTALL_DIR="${1:-${HOME}/.local/bin}"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  PLATFORM="linux_amd64" ;;
      aarch64) PLATFORM="linux_arm64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64)  PLATFORM="darwin_amd64" ;;
      arm64)   PLATFORM="darwin_arm64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac

echo "Installing AzureHound from ${REPO}..."

# Get the latest release tag from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

# Construct download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/AzureHound_${LATEST_TAG}_${PLATFORM}.zip"

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

# Download and extract azurehound binary directly to install directory
TMPFILE="$(mktemp)"
curl -fsSL "${DOWNLOAD_URL}" -o "${TMPFILE}"
unzip -o -j "${TMPFILE}" "${APP_NAME}" -d "${INSTALL_DIR}"
rm -f "${TMPFILE}"

chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo "AzureHound ${LATEST_TAG} installed to ${INSTALL_DIR}/${APP_NAME}"
"${INSTALL_DIR}/${APP_NAME}" --version
