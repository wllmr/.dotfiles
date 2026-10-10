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
show_optional_tools() {
  printf '\nOptional tools (toggle with 1, 2, or 3; Enter to continue):\n'
  printf '  1. [%s] Docker (local Engine on Linux / Colima on macOS)\n' "$([[ "$INSTALL_DOCKER" == 1 ]] && printf x || printf ' ')"
  printf '  2. [%s] OpenAI Codex CLI\n' "$([[ "$INSTALL_CODEX" == 1 ]] && printf x || printf ' ')"
  printf '  3. [%s] Claude Code CLI\n' "$([[ "$INSTALL_CLAUDE" == 1 ]] && printf x || printf ' ')"
}
for flag in "$@"; do
  case "$flag" in
    --with-docker) INSTALL_DOCKER=1 ;;
    --no-docker) INSTALL_DOCKER=0 ;;
    --with-codex) INSTALL_CODEX=1 ;;
    --no-codex) INSTALL_CODEX=0 ;;
    --with-claude) INSTALL_CLAUDE=1 ;;
    --no-claude) INSTALL_CLAUDE=0 ;;
    *) log "Usage: ./install.sh [--with-docker|--no-docker] [--with-codex|--no-codex] [--with-claude|--no-claude]"; exit 2 ;;
  esac
done
if [[ $# -eq 0 && -t 0 && -t 1 ]]; then
  while :; do
    show_optional_tools
    printf 'Selection: '
    IFS= read -r choice || break
    case "$choice" in
      1) INSTALL_DOCKER=$((1 - INSTALL_DOCKER)) ;;
      2) INSTALL_CODEX=$((1 - INSTALL_CODEX)) ;;
      3) INSTALL_CLAUDE=$((1 - INSTALL_CLAUDE)) ;;
      "") break ;;
      *) printf 'Invalid selection.\n' ;;
    esac
  done
fi
export INSTALL_DOCKER INSTALL_CODEX INSTALL_CLAUDE
source "$DOTFILES_DIR/installers/ai-tools.sh"

install_packages
install_optional_packages
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
