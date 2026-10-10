#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
has() { command -v "$1" >/dev/null 2>&1; }
if [[ "$(uname)" == "Darwin" ]]; then
  if ! has brew; then echo "Install Homebrew from https://brew.sh first"; exit 1; fi
  eval "$(brew shellenv)"
  brew install zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting gh fzf starship eza bat zoxide wget git vim ruby
elif [[ -f /etc/arch-release ]]; then
  sudo pacman -Syu --needed zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting github-cli fzf starship eza bat zoxide wget git vim ruby curl
elif [[ -f /etc/os-release ]] && grep -qiE "^(ID|ID_LIKE)=.*(ubuntu|debian)" /etc/os-release; then
  sudo apt-get update
  sudo apt-get install -y zsh zsh-autosuggestions zsh-syntax-highlighting gh fzf eza bat zoxide wget git vim ruby curl ca-certificates
  if ! has starship; then
    mkdir -p "$HOME/.local/bin"
    tmp="$(mktemp)"
    curl -fsSL https://starship.rs/install.sh -o "$tmp"
    sh "$tmp" -y -b "$HOME/.local/bin"
    rm -f "$tmp"
  fi
else echo "Supported: Arch, Ubuntu, macOS"; exit 1; fi
mkdir -p "$HOME/.config" "$HOME/.local/bin"
link_file() {
  local src="$1" dest="$2"
  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then return; fi
  if [[ -e "$dest" || -L "$dest" ]]; then mv "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"; fi
  ln -s "$src" "$dest"
}
link_file "$ROOT/.zshrc" "$HOME/.zshrc"
link_file "$ROOT/.gitconfig" "$HOME/.gitconfig"
link_file "$ROOT/starship.toml" "$HOME/.config/starship.toml"
if [[ ! -f "$HOME/.scm_breeze/scm_breeze.sh" ]]; then
  git clone --depth 1 https://github.com/scmbreeze/scm_breeze.git "$HOME/.scm_breeze"
  bash "$HOME/.scm_breeze/install.sh"
fi
echo "Done. Run: chsh -s $(command -v zsh) (if needed), then restart your terminal."
