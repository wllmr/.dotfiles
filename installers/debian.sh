#!/usr/bin/env bash
# Shared apt-based package setup for Ubuntu and Kali.
install_packages() {
  sudo apt-get update
  sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting git curl wget vim ruby ca-certificates fzf build-essential ripgrep jq
  for pkg in gh eza bat zoxide zsh-completions fd-find; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    else
      log "WARNING: $pkg unavailable in configured apt repositories."
    fi
  done
  install_go_yq_binary
  if ! has starship; then
    mkdir -p "$HOME/.local/bin"
    local tmp
    tmp="$(mktemp)"
    curl -fsSL https://starship.rs/install.sh -o "$tmp"
    sh "$tmp" -y -b "$HOME/.local/bin"
    rm -f "$tmp"
  fi
}

install_optional_packages() {
  if [[ "$INSTALL_DOCKER" == 1 ]]; then
    for pkg in docker.io docker-compose-v2; do
      if apt-cache show "$pkg" >/dev/null 2>&1; then
        sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
      else
        log "WARNING: Docker package $pkg unavailable in configured repositories."
      fi
    done
  fi
}

