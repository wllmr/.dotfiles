#!/usr/bin/env bash
# Shared functions; sourced by install.sh and the platform installer.
log() { printf '[dotfiles] %s\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

link_dotfile() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then return; fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup="$dst.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    log "Backed up $dst to $backup"
  fi
  ln -s "$src" "$dst"
}

install_shared_config() {
  mkdir -p "$HOME/.config" "$HOME/.local/bin"
  link_dotfile "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
  link_dotfile "$DOTFILES_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
  link_dotfile "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
  link_dotfile "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"
}

install_scm_breeze() {
  if [[ -f "$HOME/.scm_breeze/scm_breeze.sh" ]]; then return; fi
  if [[ ! -d "$HOME/.scm_breeze" ]]; then
    git clone --depth 1 https://github.com/scmbreeze/scm_breeze.git "$HOME/.scm_breeze"
  fi
  log "Running SCM Breeze upstream installer (may prompt)"
  bash "$HOME/.scm_breeze/install.sh"
}

# Platform-specific implementations supply configure_default_shell().
