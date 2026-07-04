#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

mkdir -p "${CODEX_HOME:-$HOME/.codex}" \
  "$HOME/.cursor-server" \
  "$HOME/.local/bin" \
  "$HOME/.vscode-server"

if [ -f /workspaces/mall/.devcontainer/zsh/.zshrc ]; then
  cp /workspaces/mall/.devcontainer/zsh/.zshrc "$HOME/.zshrc"
fi
touch "$HOME/.zshrc.local"

if [ -f /workspaces/mall/.devcontainer/git/.gitconfig ]; then
  cp /workspaces/mall/.devcontainer/git/.gitconfig "$HOME/.gitconfig"
fi

if command -v git-lfs >/dev/null 2>&1; then
  git lfs install --skip-repo
fi

codex_home="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$codex_home"
if [ ! -f "$codex_home/config.toml" ] && [ -f /workspaces/mall/.devcontainer/codex/config.toml ]; then
  cp /workspaces/mall/.devcontainer/codex/config.toml "$codex_home/config.toml"
fi

mvn -version
zsh --version

if command -v codex >/dev/null 2>&1; then
  codex --version
else
  npm config set prefix "$HOME/.local"
  npm install -g @openai/codex
  codex --version
fi
