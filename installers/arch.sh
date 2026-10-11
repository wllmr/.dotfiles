#!/usr/bin/env bash
install_packages() {
  sudo pacman -Syu --needed zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting github-cli fzf starship eza bat zoxide wget git vim ruby curl ca-certificates base-devel ripgrep fd jq go-yq
}

install_optional_packages() {
  if [[ "$INSTALL_DOCKER" == 1 ]]; then
    sudo pacman -S --needed docker docker-compose
  fi
}
