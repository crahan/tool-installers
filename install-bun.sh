#!/usr/bin/env bash
set -euo pipefail

APP_NAME="bun"
REPO="oven-sh/bun"
INSTALL_DIR="${1:-${HOME}/.local/bin}"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  TARGET="linux-x64" ;;
      aarch64) TARGET="linux-aarch64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64)  TARGET="darwin-x64" ;;
      arm64)   TARGET="darwin-aarch64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac

echo "Installing bun from ${REPO}..."

# Get the latest release tag from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

# Construct download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/bun-${TARGET}.zip"

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

# Download and extract bun binary directly to install directory
TMPFILE="$(mktemp)"
curl -fsSL "${DOWNLOAD_URL}" -o "${TMPFILE}"
unzip -o -j "${TMPFILE}" "bun-${TARGET}/${APP_NAME}" -d "${INSTALL_DIR}"
rm -f "${TMPFILE}"

chmod +x "${INSTALL_DIR}/${APP_NAME}"

# Create bunx symlink to the bun binary
ln -sf "${APP_NAME}" "${INSTALL_DIR}/bunx"

echo "bun ${LATEST_TAG} installed to ${INSTALL_DIR}/${APP_NAME} (with bunx symlink)"
