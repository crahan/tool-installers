#!/usr/bin/env bash
set -euo pipefail

APP_NAME="jwt-tool"
REPO_URL="https://github.com/ticarpi/jwt_tool.git"

OPT_DIR="${1:-${HOME}/.local/opt}"
BIN_DIR="${2:-${HOME}/.local/bin}"
CLONE_PATH="${OPT_DIR}/jwt_tool"

echo "Installing ${APP_NAME}..."

# Create install directories if they don't exist
mkdir -p "${OPT_DIR}" "${BIN_DIR}"

# Clone or update the repository
if [ -d "${CLONE_PATH}/.git" ]; then
    echo "Repository already cloned. Updating..."
    git -C "${CLONE_PATH}" pull --ff-only
else
    echo "Cloning ${REPO_URL} to ${CLONE_PATH}..."
    git clone "${REPO_URL}" "${CLONE_PATH}"
fi

# Create wrapper script to run via uv
echo "Creating wrapper script at ${BIN_DIR}/${APP_NAME}..."
cat > "${BIN_DIR}/${APP_NAME}" <<WRAPPER
#!/usr/bin/env bash
exec uv run \\
  --no-project \\
  --with-requirements "${CLONE_PATH}/requirements.txt" \\
  "${CLONE_PATH}/jwt_tool.py" \\
  "\$@"
WRAPPER
chmod +x "${BIN_DIR}/${APP_NAME}"

echo "${APP_NAME} installed successfully."
