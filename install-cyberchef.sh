#!/usr/bin/env bash
set -euo pipefail

APP_NAME="CyberChef"
REPO="gchq/CyberChef"
INSTALL_DIR="${1:-${HOME}/.local/opt}"

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
CYBERCHEF_DIR="${INSTALL_DIR}/${APP_NAME}"

# Create install directory if it doesn't exist
mkdir -p "${INSTALL_DIR}"

# Check if the directory already exists and ask to overwrite
if [ -d "${CYBERCHEF_DIR}" ]; then
    read -r -p "${CYBERCHEF_DIR} already exists. Overwrite? [y/N] " confirm
    if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
    rm -rf "${CYBERCHEF_DIR}"
fi

# Download and extract the latest version of CyberChef
curl -fsSL -o "${INSTALL_DIR}/${ARCHIVE_NAME}" "${CYBERCHEF_URL}"

# Unpack the archive
unzip -q "${INSTALL_DIR}/${ARCHIVE_NAME}" -d "${CYBERCHEF_DIR}"

# Create a relative symlink to the CyberChef HTML file
(cd "${CYBERCHEF_DIR}" && ln -sf CyberChef_v*.html CyberChef.html)

# Delete the downloaded archive
rm "${INSTALL_DIR}/${ARCHIVE_NAME}"

echo "CyberChef ${LATEST_TAG} installed to ${CYBERCHEF_DIR}"
