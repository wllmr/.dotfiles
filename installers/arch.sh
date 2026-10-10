#!/usr/bin/env bash
install_packages() {
  sudo pacman -Syu --needed zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting github-cli fzf starship eza bat zoxide wget git vim ruby curl ca-certificates base-devel ripgrep fd jq go-yq
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
