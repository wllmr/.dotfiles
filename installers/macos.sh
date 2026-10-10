#!/usr/bin/env bash
install_packages() {
  if ! has brew; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    else
      log "Install Homebrew first: https://brew.sh"
      exit 1
    fi
  fi
  brew install zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting gh fzf starship eza bat zoxide wget git vim ruby curl ripgrep fd jq yq
}

configure_default_shell() {
  local desired current
  desired="$(command -v zsh)"
  current="$(dscl . -read "/Users/$(id -un)" UserShell | awk '{print $2}')"
  if [[ "$current" != "$desired" ]]; then
    if ! grep -Fxq "$desired" /etc/shells; then
      printf '%s\n' "$desired" | sudo tee -a /etc/shells >/dev/null
    fi
    log "Changing default shell to $desired (macOS may ask for your password)"
    chsh -s "$desired"
  fi
}
