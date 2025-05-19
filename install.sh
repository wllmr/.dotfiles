#!/bin/bash
set -e

echo "🔧 Setting up Codespaces environment..."

# Install Zsh if missing
if ! command -v zsh >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y zsh
fi

# Install Oh My Zsh (no auto shell switch)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "⬇️ Installing Oh My Zsh..."
  export RUNZSH=no
  export CHSH=no
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
  echo "✨ Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
fi

# Install plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# Symlink all dotfiles (skip install.sh and .git)
for file in "$HOME/.dotfiles"/.*; do
  name="$(basename "$file")"
  case "$name" in '.'|'..'|'.git'|'install.sh') continue ;; esac
  ln -sf "$file" "$HOME/$name"
done

# Ensure Zsh is used in interactive shells
if ! grep -q 'exec zsh' "$HOME/.bashrc"; then
  echo '[[ $- != *i* ]] && return' >> "$HOME/.bashrc"
  echo 'if [ -t 1 ] && command -v zsh >/dev/null 2>&1; then exec zsh; fi' >> "$HOME/.bashrc"
fi

echo "✅ Environment is ready!"
