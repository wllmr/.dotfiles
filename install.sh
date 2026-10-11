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
source "$DOTFILES_DIR/installers/options.sh"
parse_install_options "$@"
select_node_package_managers() {
  local selected status
  selected="$(printf '%s\n' 'pnpm' 'Yarn' 'Bun' |
    fzf --multi --no-sort --no-info \
      --prompt='Node package managers> ' \
      --header='npm comes with Node | TAB selects extras | ENTER confirms' \
      --bind='tab:toggle+down' --height=40% --layout=reverse)" || {
    status=$?
    [[ "$status" != 1 && "$status" != 130 ]] || return 0
    log "ERROR: Node package-manager menu failed (fzf exit $status)"
    return "$status"
  }
  [[ "$selected" == *pnpm* ]] && INSTALL_PNPM=1
  [[ "$selected" == *Yarn* ]] && INSTALL_YARN=1
  [[ "$selected" == *Bun* ]] && INSTALL_BUN=1
  return 0
}
select_optional_tools() {
  local selected status
  if ! command -v fzf >/dev/null 2>&1; then
    log "WARNING: fzf unavailable; use --with-docker, --with-codex, --with-claude or --with-herdr."
    return
  fi
  # fzf is installed by install_packages before this menu runs.
  # TAB toggles entries; ENTER confirms; ESC skips the optional tools.
  selected="$(printf '%s\n' \
    'Docker (local Engine on Linux / Colima on macOS)' \
    'OpenAI Codex CLI' \
    'Claude Code CLI' \
    'Herdr (agent terminal multiplexer)' \
    'Node.js LTS (nvm)' \
    | fzf --multi --no-sort --no-info \
        --prompt='Optional tools> ' \
        --header='TAB to select/deselect | ENTER to install | ESC to skip' \
        --bind='tab:toggle+down' \
        --height=40% --layout=reverse)" || {
    status=$?
    [[ "$status" != 1 && "$status" != 130 ]] || return 0
    log "ERROR: Optional-tools menu failed (fzf exit $status)"
    return "$status"
  }
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
    *'Herdr (agent terminal multiplexer)'*) INSTALL_HERDR=1 ;;
  esac
  case "$selected" in
    *'Node.js LTS (nvm)'*) INSTALL_NODE=1 ;;
  esac
}

source "$DOTFILES_DIR/installers/ai-tools.sh"

install_packages
if [[ $# -eq 0 && -t 0 && -t 1 ]]; then
  select_optional_tools
  if [[ "$INSTALL_NODE" == 1 || "$INSTALL_CODEX" == 1 ]]; then
    printf 'Node.js version to install and make default [lts/*]: '
    IFS= read -r requested_version || requested_version=''
    NODE_VERSION="${requested_version:-lts/*}"
    if [[ ! "$NODE_VERSION" =~ ^(lts/\*|lts/[a-zA-Z]+|node|stable|[0-9]+(\.[0-9]+){0,2})$ ]]; then
      log "Invalid Node version: $NODE_VERSION"
      exit 2
    fi
    if [[ -t 0 && -t 1 ]]; then
      select_node_package_managers
    fi
  fi
fi
install_optional_packages
install_optional_node
install_optional_node_package_managers
install_optional_ai_tools
install_optional_herdr
install_rust
install_shared_config
configure_fd
install_scm_breeze
repository_prompt=0
if [[ -t 0 && -t 1 ]]; then repository_prompt=1; fi
configure_scm_repository_index "$repository_prompt"
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
