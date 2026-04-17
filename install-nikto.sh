#!/usr/bin/env bash
set -euo pipefail

APP_NAME="nikto"
REPO="sullo/nikto"

OPT_DIR="${1:-${HOME}/.local/opt}"
BIN_DIR="${2:-${HOME}/.local/bin}"
CLONE_PATH="${OPT_DIR}/nikto"

echo "Installing ${APP_NAME} from ${REPO}..."

# Check that Perl is available
if ! command -v perl &>/dev/null; then
    echo "Error: Perl is required but not found. Please install Perl first." >&2
    exit 1
fi

# Create install directories if they don't exist
mkdir -p "${OPT_DIR}" "${BIN_DIR}"

# Clone or update the repository
if [ -d "${CLONE_PATH}/.git" ]; then
    echo "Repository already cloned. Updating..."
    git -C "${CLONE_PATH}" pull --ff-only
else
    echo "Cloning ${REPO} to ${CLONE_PATH}..."
    git clone "https://github.com/${REPO}.git" "${CLONE_PATH}"
fi

# Symlink nikto.pl to the bin directory
echo "Creating symlink at ${BIN_DIR}/${APP_NAME}..."
ln -sf "${CLONE_PATH}/program/nikto.pl" "${BIN_DIR}/${APP_NAME}"

echo "Nikto installed to ${BIN_DIR}/${APP_NAME}"
