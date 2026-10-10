#!/usr/bin/env bash
install_packages() {
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting git curl wget vim ruby ca-certificates fzf
  for pkg in gh eza bat zoxide zsh-completions; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    else
      log "WARNING: $pkg unavailable in configured apt repositories."
    fi
  done
  if ! has starship; then
    mkdir -p "$HOME/.local/bin"
    local tmp
    tmp="$(mktemp)"
    curl -fsSL https://starship.rs/install.sh -o "$tmp"
    sh "$tmp" -y -b "$HOME/.local/bin"
    rm -f "$tmp"
  fi
}

configure_default_shell() {
  local desired current
  desired="$(command -v zsh)"
  current="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ "$current" != "$desired" ]]; then
    sudo usermod --shell "$desired" "$(id -un)"
    log "Set default shell to $desired"
  fi
}
