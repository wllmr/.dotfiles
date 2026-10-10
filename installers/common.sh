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

# Git writes to ~/.gitconfig (e.g. git config --global). Keep it independent
# from the tracked template so local modifications never mutate the repository.
install_gitconfig() {
  local src="$DOTFILES_DIR/.gitconfig" dst="$HOME/.gitconfig"
  if [[ -L "$dst" ]]; then
    local backup="$dst.backup.$(date +%Y%m%d%H%M%S)"
    # Preserve the current effective configuration, including local edits.
    local tmp
    tmp="$(mktemp)"
    if [[ -f "$dst" ]]; then
      cp -L "$dst" "$tmp"
    else
      cp "$src" "$tmp"
    fi
    mv "$dst" "$backup"
    mv "$tmp" "$dst"
    chmod 600 "$dst"
    log "Replaced Git config symlink with independent copy; saved link at $backup"
  elif [[ ! -e "$dst" ]]; then
    cp "$src" "$dst"
    log "Installed Git config template into $dst"
  else
    log "Preserving existing Git configuration at $dst"
  fi
}

# Git tools modify ~/.gitconfig: preserve a writable home copy, not a repo symlink.
install_gitconfig() {
  local src="$DOTFILES_DIR/git/.gitconfig" dst="$HOME/.gitconfig"
  if [[ -L "$dst" ]]; then
    local tmp backup
    tmp="$(mktemp)"
    if [[ -f "$dst" ]]; then cp -L "$dst" "$tmp"; else cp "$src" "$tmp"; fi
    backup="$dst.backup.$(date +%Y%m%d%H%M%S)"
    mv "$dst" "$backup"
    mv "$tmp" "$dst"
    log "Migrated ~/.gitconfig symlink to a separate file; backed up link to $backup"
  elif [[ ! -e "$dst" ]]; then
    cp "$src" "$dst"
  else
    log "Preserving existing ~/.gitconfig"
  fi
}

install_shared_config() {
  mkdir -p "$HOME/.config" "$HOME/.local/bin" "$HOME/.vim/colors"
  link_dotfile "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  link_dotfile "$DOTFILES_DIR/zsh/.zsh_aliases" "$HOME/.zsh_aliases"
  install_gitconfig
  link_dotfile "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
  link_dotfile "$DOTFILES_DIR/vim/.vimrc" "$HOME/.vimrc"
  link_dotfile "$DOTFILES_DIR/vim/colors/oxocarbon.vim" "$HOME/.vim/colors/oxocarbon.vim"
}

install_scm_breeze() {
  if [[ -f "$HOME/.scm_breeze/scm_breeze.sh" ]]; then return; fi
  if [[ ! -d "$HOME/.scm_breeze" ]]; then
    git clone --depth 1 https://github.com/scmbreeze/scm_breeze.git "$HOME/.scm_breeze"
  fi
  log "Running SCM Breeze upstream installer without modifying managed .zshrc"
  # Upstream appends to ${ZDOTDIR:-$HOME}/.zshrc. Redirect that write
  # away from the symlinked configuration tracked in this repository.
  local temp_zdotdir
  temp_zdotdir="$(mktemp -d)"
  if ZDOTDIR="$temp_zdotdir" bash "$HOME/.scm_breeze/install.sh"; then
    rm -rf -- "$temp_zdotdir"
  else
    local status=$?
    rm -rf -- "$temp_zdotdir"
    return "$status"
  fi
}

install_rust() {
  if ! command -v rustup >/dev/null 2>&1 && [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
    log "Installing Rust via official rustup installer"
    local tmp
    tmp="$(mktemp)"
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs -o "$tmp"
    sh "$tmp" -y --profile minimal --no-modify-path
    rm -f "$tmp"
  fi
  local rustup_cmd
  rustup_cmd="$(command -v rustup 2>/dev/null || true)"
  [[ -n "$rustup_cmd" ]] || rustup_cmd="$HOME/.cargo/bin/rustup"
  "$rustup_cmd" default stable
}

# Platform-specific implementations supply configure_default_shell().

# Debian/Ubuntu name fd's binary fdfind. Provide a consistent fd command.
configure_fd() {
  if ! has fd && has fdfind; then
    mkdir -p "$HOME/.local/bin"
    ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

# Use Mike Farah's Go-based yq v4 on Debian-based distributions.
# apt's 'yq' can be the unrelated Python wrapper.
install_go_yq_binary() {
  if has yq && yq --version 2>/dev/null | grep -qi 'mikefarah'; then
    return
  fi
  local architecture artifact tmp
  case "$(uname -m)" in
    x86_64|amd64) architecture=amd64 ;;
    aarch64|arm64) architecture=arm64 ;;
    armv7l) architecture=arm ;;
    i386|i686) architecture=386 ;;
    *) log "WARNING: unsupported architecture for yq: $(uname -m)"; return 0 ;;
  esac
  artifact="yq_linux_${architecture}"
  mkdir -p "$HOME/.local/bin"
  tmp="$(mktemp)"
  if curl --fail --location --silent --show-error "https://github.com/mikefarah/yq/releases/latest/download/$artifact" -o "$tmp"; then
    chmod 755 "$tmp"
    mv "$tmp" "$HOME/.local/bin/yq"
  else
    rm -f "$tmp"
    log "WARNING: Failed to download Go yq. Install it manually."
  fi
}
