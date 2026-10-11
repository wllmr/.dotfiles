#!/usr/bin/env bash
# Shared functions; sourced by install.sh and the platform installer.
log() { printf '[dotfiles] %s\n' "$*"; }
has() { command -v "$1" >/dev/null 2>&1; }

link_dotfile() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then return; fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    local backup
    backup="$(mktemp -d "$dst.backup.XXXXXXXX")/original"
    mv "$dst" "$backup"
    log "Backed up $dst to $backup"
  fi
  ln -s "$src" "$dst"
}

# Git tools modify ~/.gitconfig: preserve a writable home copy, not a repo symlink.
install_gitconfig() {
  local src="$DOTFILES_DIR/git/.gitconfig" dst="$HOME/.gitconfig"
  if [[ -L "$dst" ]]; then
    local tmp backup
    tmp="$(mktemp)"
    if [[ -f "$dst" ]]; then cp -L "$dst" "$tmp"; else cp "$src" "$tmp"; fi
    backup="$(mktemp -d "$dst.backup.XXXXXXXX")/original"
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

configure_scm_breeze_config() {
  local config_dir="${1:-$HOME}"
  local target="$config_dir/.git.scmbrc" personal="$config_dir/.git.scmbrc.local"
  local source_config="$DOTFILES_DIR/zsh/.git.scmbrc"
  if [[ -L "$target" && "$(readlink "$target")" == "$source_config" ]]; then return; fi
  # A managed wrapper from another checkout is not personal configuration.
  # This existing header also identifies wrappers installed before this check.
  if [[ -L "$target" && -f "$target" ]] &&
    [[ "$(head -n 1 "$target")" == '# Keep upstream defaults and existing personal SCM Breeze preferences.' ]]; then
    link_dotfile "$source_config" "$target"
    return
  fi
  if [[ -f "$target" ]]; then
    if [[ -e "$personal" || -L "$personal" ]]; then
      log "ERROR: Both $target and $personal exist; reconcile them before rerunning."
      return 1
    fi
    cp -L "$target" "$personal"
    log "Preserved SCM Breeze preferences in $personal"
  fi
  link_dotfile "$source_config" "$target"
}

install_scm_breeze() {
  if [[ -f "$HOME/.scm_breeze/scm_breeze.sh" && -s "$HOME/.scmbrc" && -s "$HOME/.git.scmbrc" ]]; then
    configure_scm_breeze_config
    return
  fi
  if [[ ! -d "$HOME/.scm_breeze" ]]; then
    git clone --depth 1 https://github.com/scmbreeze/scm_breeze.git "$HOME/.scm_breeze"
  fi
  # Establish ownership before upstream creates any missing preference files.
  # In particular, a surviving .local config must not conflict with fresh defaults.
  configure_scm_breeze_config
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

# Configure SCM Breeze's native repository index, without rewriting personal code.
configure_scm_repository_index() {
  local interactive="${1:-0}" requested="${SCM_REPO_DIR:-}" current=''
  if [[ -z "$requested" && "$interactive" != 1 ]]; then
    log "Keeping existing SCM repository directory (use --repo-dir=PATH to configure c)."
    return 0
  fi
  if [[ -z "$requested" ]]; then
    current="$(zsh -f -c 'source "$HOME/.git.scmbrc"; print -r -- "${GIT_REPO_DIR:-}"')"
    [[ -d "$current" ]] || current=''
    if [[ -n "$current" ]]; then
      printf 'Repository directory for c [%s] (Tab to complete): ' "$current"
    else
      printf 'Repository directory for c (Tab to complete; blank to skip): '
    fi
    if [[ -t 0 ]]; then
      # Readline escapes completed filenames (e.g. spaces); read decodes those
      # escapes without evaluating shell expressions. Piped input stays literal.
      IFS= read -e requested || requested=''
    else
      IFS= read -r requested || requested=''
    fi
    requested="${requested:-$current}"
    if [[ -z "$requested" ]]; then
      log "Skipping repository index setup."
      return 0
    fi
  fi
  case "$requested" in
    '~') requested="$HOME" ;;
    '~/'*) requested="$HOME/${requested#\~/}" ;;
  esac
  if [[ "$requested" == *$'\n'* || ! -d "$requested" ]]; then
    log "ERROR: Repository directory must be an existing directory: $requested"
    return 1
  fi
  requested="$(cd -- "$requested" && pwd -P)"
  local index="$requested/.git_index"
  if [[ ! -w "$requested" || ( ( -e "$index" || -L "$index" ) && ( ! -f "$index" || ! -w "$index" ) ) ]]; then
    log "ERROR: Cannot write a repository index in $requested"
    return 1
  fi
  log "Building SCM Breeze repository index in $requested"
  if ! zsh -f -c '
    autoload -Uz compinit
    compinit -i -D
    source "$HOME/.scm_breeze/scm_breeze.sh"
    if (( ! $+functions[git_index] )); then
      print -u2 "SCM Breeze repository index is not enabled. Check ~/.scmbrc."
      exit 1
    fi
    export GIT_REPO_DIR="$1"
    # Upstream can mask failed pipelines; enforce errors for the rebuild only.
    setopt ERR_EXIT PIPE_FAIL
    git_index --rebuild
    [[ -f "$GIT_REPO_DIR/.git_index" && -r "$GIT_REPO_DIR/.git_index" ]]
  ' repository-index "$requested"; then
    log "ERROR: Repository index rebuild failed; saved directory is unchanged."
    return 1
  fi
  mkdir -p "$HOME/.config/dotfiles"
  printf '%s\n' "$requested" > "$HOME/.config/dotfiles/scm-repo-dir"
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

# Shared Linux implementation; macOS supplies its own account lookup.
configure_default_shell() {
  local desired current
  desired="$(command -v zsh)"
  current="$(getent passwd "$(id -un)" | cut -d: -f7)"
  if [[ "$current" != "$desired" ]]; then
    sudo usermod --shell "$desired" "$(id -un)"
    log "Set default shell to $desired"
  fi
}

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
