#!/usr/bin/env bash
# Optional AI developer tools. No authentication is performed by this installer.
# Node.js is installed via nvm only when selected (or required by Codex).
install_optional_node() {
  if [[ "$INSTALL_NODE" != 1 && "$INSTALL_CODEX" != 1 ]]; then return; fi
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    local script
    script="$(mktemp)"
    if ! curl --fail --silent --show-error --location \
      https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh -o "$script"; then
      rm -f "$script"
      log "ERROR: Unable to download nvm installer"
      return 1
    fi
    PROFILE=/dev/null bash "$script"
    rm -f "$script"
  fi
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log "ERROR: nvm was not installed successfully"
    return 1
  fi
  # nvm is a shell function: loading it here exposes node/npm immediately.
  # shellcheck disable=SC1091
  source "$NVM_DIR/nvm.sh"
  nvm install "$NODE_VERSION"
  # Pin the actual installed version as the default for future shells.
  local installed_version
  installed_version="$(node --version)"
  nvm alias default "$installed_version"
  nvm use default
  log "Node.js default: $(node --version); npm: $(npm --version)"
}


# npm ships with Node. pnpm/Yarn use Corepack for per-project versions.
install_optional_node_package_managers() {
  if [[ "$INSTALL_PNPM" == 1 || "$INSTALL_YARN" == 1 ]]; then
    if ! command -v corepack >/dev/null 2>&1; then
      npm install --global corepack
    fi
    corepack enable
    if [[ "$INSTALL_PNPM" == 1 ]]; then
      corepack install --global pnpm@latest
      log "pnpm: $(pnpm --version)"
    fi
    if [[ "$INSTALL_YARN" == 1 ]]; then
      corepack install --global yarn@stable
      log "Yarn: $(yarn --version)"
    fi
  fi
  if [[ "$INSTALL_BUN" == 1 ]]; then
    if [[ ! -x "$HOME/.bun/bin/bun" ]] && ! command -v bun >/dev/null 2>&1; then
      # Bun's official installer needs unzip on Linux.
      if ! command -v unzip >/dev/null 2>&1; then
        log "WARNING: Bun installer requires unzip; install unzip and retry."
        return 0
      fi
      local script
      script="$(mktemp)"
      if curl -fsSL https://bun.com/install -o "$script"; then
        bash "$script"
      else
        log "WARNING: Could not download Bun installer"
      fi
      rm -f "$script"
    fi
    if [[ -x "$HOME/.bun/bin/bun" ]]; then
      export BUN_INSTALL="$HOME/.bun"
      export PATH="$BUN_INSTALL/bin:$PATH"
    fi
  fi
}

install_optional_ai_tools() {
  if [[ "$INSTALL_CODEX" == 1 ]]; then
    if has codex || [[ -x "$HOME/.local/bin/codex" ]]; then
      log "Codex CLI already installed; skipping"
    else
      if ! has npm; then
        log "ERROR: npm not available after Node.js setup; Codex cannot be installed."
      else
        mkdir -p "$HOME/.local"
        npm install --global --prefix "$HOME/.local" @openai/codex
        log "Codex CLI installed; sign in by running: codex"
      fi
    fi
  fi

  if [[ "$INSTALL_CLAUDE" == 1 ]]; then
    if has claude || [[ -x "$HOME/.local/bin/claude" ]]; then
      log "Claude Code already installed; skipping"
    else
      local script
      script="$(mktemp)"
      if curl --fail --silent --show-error --location https://claude.ai/install.sh -o "$script"; then
        bash "$script"
        log "Claude Code installed; sign in by running: claude"
      else
        log "WARNING: Could not download the Claude Code installer"
      fi
      rm -f "$script"
    fi
  fi
}
