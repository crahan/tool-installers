#!/usr/bin/env bash
set -euo pipefail

APP_NAME="llmfit"
REPO="AlexsJones/llmfit"
INSTALL_DIR="${1:-${HOME}/.local/bin}"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  PLATFORM="x86_64-unknown-linux-gnu" ;;
      aarch64) PLATFORM="aarch64-unknown-linux-gnu" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64)  PLATFORM="x86_64-apple-darwin" ;;
      arm64)   PLATFORM="aarch64-apple-darwin" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac

echo "Installing llmfit from ${REPO}..."

# Get the latest release tag from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

# Construct download URL
ARCHIVE_DIR="${APP_NAME}-${LATEST_TAG}-${PLATFORM}"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/${ARCHIVE_DIR}.tar.gz"

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

# Download and extract llmfit binary directly to install directory
curl -fsSL "${DOWNLOAD_URL}" | tar -xz -C "${INSTALL_DIR}" --strip-components=1 "${ARCHIVE_DIR}/${APP_NAME}"

chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo "llmfit ${LATEST_TAG} installed to ${INSTALL_DIR}/${APP_NAME}"
