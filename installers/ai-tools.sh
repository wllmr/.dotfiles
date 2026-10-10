#!/usr/bin/env bash
# Optional AI developer tools. No authentication is performed by this installer.
install_optional_ai_tools() {
  if [[ "$INSTALL_CODEX" == 1 ]]; then
    if has codex || [[ -x "$HOME/.local/bin/codex" ]]; then
      log "Codex CLI already installed; skipping"
    else
      if ! has npm; then
        log "WARNING: Codex CLI requires npm. Install Node.js/npm and rerun with --with-codex."
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
