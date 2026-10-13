#!/usr/bin/env bash
set -euo pipefail

APP_NAME="CyberChef"
REPO="gchq/CyberChef"
OPT_DIR="${1:-${HOME}/.local/opt}"
INSTALL_DIR="${OPT_DIR}/${APP_NAME}"

echo "Installing CyberChef from ${REPO}..."

# Get the latest release info from GitHub API
LATEST_TAG=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" | grep -o '"tag_name": *"[^"]*"' | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')

if [ -z "${LATEST_TAG}" ]; then
    echo "Error: Could not fetch latest release tag"
    exit 1
fi

echo "Latest version: ${LATEST_TAG}"

CYBERCHEF_URL="https://github.com/${REPO}/releases/download/${LATEST_TAG}/${APP_NAME}_${LATEST_TAG}.zip"
ARCHIVE_NAME=$(basename "${CYBERCHEF_URL}")

# Create opt directory if it doesn't exist
mkdir -p "${OPT_DIR}"

# Check if the directory already exists and ask to overwrite
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
curl -fsSL -o "${TMP_DIR}/${ARCHIVE_NAME}" "${CYBERCHEF_URL}"

# Replace the existing installation with the new version
rm -rf "${INSTALL_DIR}"
mkdir -p "${INSTALL_DIR}"
unzip -q "${TMP_DIR}/${ARCHIVE_NAME}" -d "${INSTALL_DIR}"

# Create a relative symlink to the CyberChef HTML file
(cd "${INSTALL_DIR}" && ln -sf CyberChef_v*.html CyberChef.html)

echo "CyberChef ${LATEST_TAG} installed to ${INSTALL_DIR}"
