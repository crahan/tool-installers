#!/usr/bin/env bash
set -euo pipefail

APP_NAME="aws-list-resources"
REPO="welldone-cloud/aws-list-resources"
OPT_DIR="${1:-${HOME}/.local/opt}"
BIN_DIR="${2:-${HOME}/.local/bin}"
INSTALL_DIR="${OPT_DIR}/aws-list-resources"

echo "Installing ${APP_NAME} from ${REPO}..."

# Create install directories if they don't exist
mkdir -p "${OPT_DIR}" "${BIN_DIR}"

# Clone or update the repository
if [ -d "${INSTALL_DIR}/.git" ]; then
    echo "Repository already cloned. Updating..."
    git -C "${INSTALL_DIR}" pull --ff-only
else
    echo "Cloning ${REPO} to ${INSTALL_DIR}..."
    git clone "https://github.com/${REPO}.git" "${INSTALL_DIR}"
fi

# Create wrapper script to run via uv
echo "Creating wrapper script at ${BIN_DIR}/${APP_NAME}..."
cat > "${BIN_DIR}/${APP_NAME}" <<WRAPPER
#!/usr/bin/env bash
exec uv run \\
  --no-project \\
  --with 'setuptools==66.1.1' \\
  --with-requirements "${INSTALL_DIR}/requirements.txt" \\
  "${INSTALL_DIR}/aws_list_resources.py" \\
  "\$@"
WRAPPER
chmod +x "${BIN_DIR}/${APP_NAME}"

echo "aws-list-resources installed to ${BIN_DIR}/${APP_NAME}"
