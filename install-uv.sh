#!/usr/bin/env bash
echo "Installing uv..."
export UV_NO_MODIFY_PATH=1
curl -fsSL 'https://astral.sh/uv/install.sh' | sh -s --
