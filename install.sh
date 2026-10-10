#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
log() { printf '[dotfiles] %s\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

if [[ "$(id -u)" -eq 0 ]]; then
  log "Run as your regular user (not root); sudo will be used for system packages."
  exit 1
fi

if [[ "$(uname -s)" == Darwin ]]; then
  if ! has brew; then
    log "Homebrew is required on macOS: https://brew.sh"
    exit 1
  fi
  eval "$(brew shellenv)"
  brew install zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting gh fzf starship eza bat zoxide wget git vim ruby curl
elif [[ -f /etc/arch-release ]]; then
  sudo pacman -Syu --needed zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting github-cli fzf starship eza bat zoxide wget git vim ruby curl ca-certificates
elif [[ -f /etc/os-release ]] && grep -Eqi '^(ID|ID_LIKE)=.*(ubuntu|debian)' /etc/os-release; then
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting git curl wget vim ruby ca-certificates fzf
  # Ubuntu release/repository differences: install packages only when available.
  for pkg in gh eza bat zoxide zsh-completions; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    else
      log "WARNING: $pkg unavailable via configured apt repositories; install separately."
    fi
  done
  if ! has starship; then
    mkdir -p "$HOME/.local/bin"
    tmp="$(mktemp)"
    curl -fsSL https://starship.rs/install.sh -o "$tmp"
    sh "$tmp" -y -b "$HOME/.local/bin"
    rm -f "$tmp"
  fi
else
  log "Unsupported system. Supported: Arch Linux, Ubuntu and macOS."
  exit 1
fi

mkdir -p "$HOME/.config" "$HOME/.local/bin"

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
link_dotfile "$ROOT/.zshrc" "$HOME/.zshrc"
link_dotfile "$ROOT/.gitconfig" "$HOME/.gitconfig"
link_dotfile "$ROOT/.zsh_aliases" "$HOME/.zsh_aliases"
link_dotfile "$ROOT/starship.toml" "$HOME/.config/starship.toml"

if [[ ! -f "$HOME/.scm_breeze/scm_breeze.sh" ]]; then
  if [[ ! -d "$HOME/.scm_breeze" ]]; then
    git clone --depth 1 https://github.com/scmbreeze/scm_breeze.git "$HOME/.scm_breeze"
  fi
  log "Running SCM Breeze upstream setup (may prompt for input)"
  bash "$HOME/.scm_breeze/install.sh"
fi

zsh_bin="$(command -v zsh)"
if [[ "$(uname -s)" == Darwin ]]; then
  current_shell="$(dscl . -read "/Users/$(id -un)" UserShell | awk '{print $2}')"
  if [[ "$current_shell" != "$zsh_bin" ]]; then
    if ! grep -Fxq "$zsh_bin" /etc/shells; then
      printf '%s\n' "$zsh_bin" | sudo tee -a /etc/shells >/dev/null
    fi
    log "Setting login shell to $zsh_bin (may request your account password)"
    chsh -s "$zsh_bin"
  fi
else
  current_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ "$current_shell" != "$zsh_bin" ]]; then
    log "Setting default login shell to $zsh_bin"
    sudo usermod --shell "$zsh_bin" "$(id -un)"
  fi
fi
log "Ready. Restart your terminal; for WSL, restart the distro using 'wsl --terminate <distro>' in PowerShell."
