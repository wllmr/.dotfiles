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
  Darwin) installer="$DOTFILES_DIR/installers/macos.sh" ;;
  Linux)
    if [[ -f /etc/os-release ]] && grep -Eq '^ID=kali"$DOTFILES_DIR/installers/arch.sh"
    elif [[ -f /etc/os-release ]] && grep -Eqi '^(ID|ID_LIKE)=.*(ubuntu|debian)' /etc/os-release; then
      installer="$DOTFILES_DIR/installers/ubuntu.sh"
    else
      log "Unsupported Linux distribution. Supported: Arch, Kali and Ubuntu."
      exit 1
    fi ;;
  *) log "Unsupported operating system"; exit 1 ;;
esac

source "$installer"
install_packages
install_rust
install_shared_config
install_scm_breeze
configure_default_shell
log "Installation finished. Restart the terminal (and WSL distro if applicable)."
 /etc/os-release; then
      installer="$DOTFILES_DIR/installers/kali.sh"
    elif [[ -f /etc/arch-release ]]; then
      installer="$DOTFILES_DIR/installers/arch.sh"
    elif [[ -f /etc/os-release ]] && grep -Eqi '^(ID|ID_LIKE)=.*(ubuntu|debian)' /etc/os-release; then
      installer="$DOTFILES_DIR/installers/ubuntu.sh"
    else
      log "Unsupported Linux distribution. Supported: Arch and Ubuntu."
      exit 1
    fi ;;
  *) log "Unsupported operating system"; exit 1 ;;
esac

source "$installer"
install_packages
install_shared_config
install_scm_breeze
configure_default_shell
log "Installation finished. Restart the terminal (and WSL distro if applicable)."
