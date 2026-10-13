#!/usr/bin/env bash
set -euo pipefail

APP_NAME="jwt-tool"
REPO="ticarpi/jwt_tool"

OPT_DIR="${1:-${HOME}/.local/opt}"
BIN_DIR="${2:-${HOME}/.local/bin}"
CLONE_PATH="${OPT_DIR}/jwt_tool"

echo "Installing ${APP_NAME} from ${REPO}..."

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

# Create wrapper script to run via uv
echo "Creating wrapper script at ${BIN_DIR}/${APP_NAME}..."
cat > "${BIN_DIR}/${APP_NAME}" <<WRAPPER
#!/usr/bin/env bash
exec uv run \\
  --python 3.11 \\
  --no-project \\
  --with-requirements "${CLONE_PATH}/requirements.txt" \\
  "${CLONE_PATH}/jwt_tool.py" \\
  "\$@"
WRAPPER
chmod +x "${BIN_DIR}/${APP_NAME}"

echo "jwt-tool installed to ${BIN_DIR}/${APP_NAME}"
