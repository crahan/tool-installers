#!/usr/bin/env bash
set -euo pipefail

APP_NAME="trufflehog"
REPO="trufflesecurity/trufflehog"
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

echo "Installing TruffleHog from ${REPO}..."

# Get the latest release tag from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

# Strip the leading 'v' for the filename
VERSION="${LATEST_TAG#v}"

# Construct download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/trufflehog_${VERSION}_${PLATFORM}.tar.gz"

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

# Download and extract trufflehog binary directly to install directory
curl -fsSL "${DOWNLOAD_URL}" | tar -xz -C "${INSTALL_DIR}" "${APP_NAME}"

chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo "TruffleHog ${LATEST_TAG} installed to ${INSTALL_DIR}/${APP_NAME}"
"${INSTALL_DIR}/${APP_NAME}" --version
