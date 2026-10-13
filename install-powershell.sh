#!/usr/bin/env bash
set -euo pipefail

APP_NAME="pwsh"
REPO="PowerShell/PowerShell"
OPT_DIR="${1:-${HOME}/.local/opt}"
BIN_DIR="${2:-${HOME}/.local/bin}"
INSTALL_DIR="${OPT_DIR}/PowerShell"

OS="$(uname -s)"
ARCH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${ARCH}" in
      x86_64)  PLATFORM="linux-x64" ;;
      aarch64) PLATFORM="linux-arm64" ;;
      armv7l)  PLATFORM="linux-arm32" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  Darwin)
    case "${ARCH}" in
      x86_64)  PLATFORM="osx-x64" ;;
      arm64)   PLATFORM="osx-arm64" ;;
      *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;;
    esac
    ;;
  *) echo "Unsupported OS: ${OS}" >&2; exit 1 ;;
esac

echo "Installing PowerShell from ${REPO}..."

# Get the latest release tag from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

# Strip the leading 'v' from the tag string
VERSION="${LATEST_TAG#v}"

# Construct download URL
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/powershell-${VERSION}-${PLATFORM}.tar.gz"

# Create directories if they don't exist
mkdir -p "${OPT_DIR}" "${BIN_DIR}"

# Check if the PowerShell directory already exists and ask to overwrite
if [ -d "${INSTALL_DIR}" ]; then
    read -r -p "${INSTALL_DIR} already exists. Overwrite? [y/N] " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

# Download the archive to a temporary directory
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT
curl -fsSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/powershell.tar.gz"

# Replace the existing installation with the new version
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
tar -xzf "${TMP_DIR}/powershell.tar.gz" -C "${INSTALL_DIR}"

chmod +x "${INSTALL_DIR}/${APP_NAME}"

# Symlink pwsh to the bin directory
echo "Creating symlink at ${BIN_DIR}/${APP_NAME}..."
ln -sf "${INSTALL_DIR}/${APP_NAME}" "${BIN_DIR}/${APP_NAME}"

echo "PowerShell ${LATEST_TAG} installed to ${BIN_DIR}/${APP_NAME}"
