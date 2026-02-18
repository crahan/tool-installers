#!/usr/bin/env bash
set -euo pipefail

APP_NAME="caido-cli"
REPO="caido/caido"
INSTALL_DIR="${1:-${HOME}/.local/bin}"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  PLATFORM="linux-x86_64" ;;
      aarch64) PLATFORM="linux-aarch64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    EXT="tar.gz"
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64)  PLATFORM="mac-x86_64" ;;
      arm64)   PLATFORM="mac-aarch64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    EXT="zip"
    ;;
  *) echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac

echo "Installing Caido CLI from ${REPO}..."

# Get the latest release tag from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

# Construct download URL
DOWNLOAD_URL="https://caido.download/releases/${LATEST_TAG}/${APP_NAME}-${LATEST_TAG}-${PLATFORM}.${EXT}"

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

# Download and extract caido-cli binary directly to install directory
if [ "${EXT}" = "tar.gz" ]; then
    curl -fsSL "${DOWNLOAD_URL}" | tar -xz -C "${INSTALL_DIR}" --strip-components=0
else
    TMPFILE="$(mktemp)"
    curl -fsSL "${DOWNLOAD_URL}" -o "${TMPFILE}"
    unzip -o -j "${TMPFILE}" "${APP_NAME}" -d "${INSTALL_DIR}"
    rm -f "${TMPFILE}"
fi

chmod +x "${INSTALL_DIR}/${APP_NAME}"

echo "Caido CLI ${LATEST_TAG} installed to ${INSTALL_DIR}/${APP_NAME}"
"${INSTALL_DIR}/${APP_NAME}" --version
