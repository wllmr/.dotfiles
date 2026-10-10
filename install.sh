#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Install prerequisites and CLI enhancements on supported distributions.
if command -v pacman >/dev/null 2>&1; then
  sudo pacman -S --needed --noconfirm zsh git curl fzf eza bat zoxide
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y zsh git curl fzf bat
  # eza and zoxide availability depends on the distro/repository version.
  for package in eza zoxide; do
    if apt-cache show "$package" >/dev/null 2>&1; then
      sudo apt-get install -y "$package"
    else
      echo "Skipping $package: not available in configured apt repositories"
    fi
  done
else
  echo "Unknown package manager; install zsh, git, fzf, eza, bat and zoxide manually."
fi

# Oh My Zsh and its plugins.
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

for plugin in zsh-autosuggestions zsh-completions; do
  if [[ ! -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
    git clone --depth=1 "https://github.com/zsh-users/$plugin.git" "$ZSH_CUSTOM/plugins/$plugin"
  fi
done

# Link only managed dotfiles. Back up any existing, non-symlink files.
for name in .zshrc .zsh_aliases .p10k.zsh; do
  source_file="$DOTFILES_DIR/$name"
  target="$HOME/$name"
  [[ -f "$source_file" ]] || continue
  if [[ -e "$target" && ! -L "$target" ]]; then
    mv "$target" "$target.backup.$(date +%Y%m%d%H%M%S)"
  fi
  ln -sfn "$source_file" "$target"
done

echo "Installed shell configuration. Run 'exec zsh' (or 'chsh -s $(command -v zsh)' to make it default)."
echo "Run 'p10k configure' to personalize your prompt."
