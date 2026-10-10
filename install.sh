#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR
source "$DOTFILES_DIR/installers/common.sh"

if [[ "$(id -u)" -eq 0 ]]; then
  log "Run the installer as a regular user, not root."
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    installer="$DOTFILES_DIR/installers/macos.sh"
    ;;
  Linux)
    if [[ -f /etc/os-release ]] && grep -Eq '^ID="?kali"?$' /etc/os-release; then
      installer="$DOTFILES_DIR/installers/kali.sh"
    elif [[ -f /etc/arch-release ]]; then
      installer="$DOTFILES_DIR/installers/arch.sh"
    elif [[ -f /etc/os-release ]] && grep -Eqi '^(ID|ID_LIKE)=.*(ubuntu|debian)' /etc/os-release; then
      installer="$DOTFILES_DIR/installers/ubuntu.sh"
    else
      log "Unsupported Linux distribution. Supported: Arch, Kali, Ubuntu."
      exit 1
    fi
    ;;
  *)
    log "Unsupported operating system. Supported: Arch, Kali, Ubuntu, macOS."
    exit 1
    ;;
esac

source "$installer"
# Optional software is off by default for unattended installations.
INSTALL_DOCKER=0
INSTALL_CODEX=0
INSTALL_CLAUDE=0
INSTALL_NODE=0
select_optional_tools() {
  local selected
  if ! command -v fzf >/dev/null 2>&1; then
    log "WARNING: fzf unavailable; use --with-docker, --with-codex or --with-claude."
    return
  fi
  # fzf is installed by install_packages before this menu runs.
  # TAB toggles entries; ENTER confirms; ESC skips the optional tools.
  selected="$(printf '%s\n' \
    'Docker (local Engine on Linux / Colima on macOS)' \
    'OpenAI Codex CLI' \
    'Claude Code CLI' \
    'Node.js LTS (nvm)' \
    | fzf --multi --no-sort --no-info \
        --prompt='Optional tools> ' \
        --header='TAB to select/deselect | ENTER to install | ESC to skip' \
        --bind='tab:toggle+down' \
        --height=~40% --layout=reverse)" || return 0
  case "$selected" in
    *'Docker (local Engine on Linux / Colima on macOS)'*) INSTALL_DOCKER=1 ;;
  esac
  case "$selected" in
    *'OpenAI Codex CLI'*) INSTALL_CODEX=1 ;;
  esac
  case "$selected" in
    *'Claude Code CLI'*) INSTALL_CLAUDE=1 ;;
  esac
  case "$selected" in
    *'Node.js LTS (nvm)'*) INSTALL_NODE=1 ;;
  esac
}

for flag in "$@"; do
  case "$flag" in
    --with-docker) INSTALL_DOCKER=1 ;;
    --no-docker) INSTALL_DOCKER=0 ;;
    --with-codex) INSTALL_CODEX=1 ;;
    --no-codex) INSTALL_CODEX=0 ;;
    --with-node) INSTALL_NODE=1 ;;
    --no-node) INSTALL_NODE=0 ;;
    --with-claude) INSTALL_CLAUDE=1 ;;
    --no-claude) INSTALL_CLAUDE=0 ;;
    *) log "Usage: ./install.sh [--with-docker|--no-docker] [--with-codex|--no-codex] [--with-claude|--no-claude] [--with-node|--no-node]"; exit 2 ;;
  esac
done
export INSTALL_DOCKER INSTALL_CODEX INSTALL_CLAUDE INSTALL_NODE
source "$DOTFILES_DIR/installers/ai-tools.sh"

install_packages
if [[ $# -eq 0 && -t 0 && -t 1 ]]; then
  select_optional_tools
fi
install_optional_packages
install_optional_node
install_optional_ai_tools
install_rust
install_shared_config
configure_fd
install_scm_breeze
configure_default_shell
log "Installation finished."
if [[ -t 0 && -t 1 ]]; then
  printf 'Start Zsh with Starship now? [Y/n] '
  read -r answer
  case "$answer" in
    ""|y|Y|yes|YES|Yes)
      log "Starting Zsh. Type 'exit' to return to your previous shell."
      exec zsh -l
      ;;
    *) log "To activate it later, run: exec zsh" ;;
  esac
else
  log "Non-interactive session: skipping shell launch. Run 'exec zsh' when ready."
fi
log "For WSL, restart the distribution if future sessions still use the old login shell."
