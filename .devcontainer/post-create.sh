#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

mkdir -p "${CODEX_HOME:-$HOME/.codex}" \
  "$HOME/.cursor-server" \
  "$HOME/.local/bin" \
  "$HOME/.vscode-server"

mvn -version

if command -v codex >/dev/null 2>&1; then
  codex --version
else
  npm config set prefix "$HOME/.local"
  npm install -g @openai/codex
  codex --version
fi
