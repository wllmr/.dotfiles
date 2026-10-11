#!/usr/bin/env bash
# Offline regression checks: all writes stay in an isolated temporary directory.
set -euo pipefail
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/installers/common.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
failures=0
check() {
  if ( "$@" ); then printf 'PASS: %s\n' "$1";
  else printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); fi
}

checkout_migration() {
  mkdir -p "$test_dir/old/zsh" "$test_dir/new/zsh" "$test_dir/user"
  cp "$DOTFILES_DIR/zsh/.git.scmbrc" "$test_dir/old/zsh/"
  cp "$DOTFILES_DIR/zsh/.git.scmbrc" "$test_dir/new/zsh/"
  DOTFILES_DIR="$test_dir/old"
  configure_scm_breeze_config "$test_dir/user"
  DOTFILES_DIR="$test_dir/new"
  configure_scm_breeze_config "$test_dir/user"
  [[ ! -e "$test_dir/user/.git.scmbrc.local" ]] || return 1
  [[ "$(readlink "$test_dir/user/.git.scmbrc")" == "$DOTFILES_DIR/zsh/.git.scmbrc" ]] || return 1
  printf 'export GS_MAX_CHANGES=42\n' > "$test_dir/user/.git.scmbrc.local"
  DOTFILES_DIR="$test_dir/old"
  configure_scm_breeze_config "$test_dir/user" || return 1
  [[ "$(< "$test_dir/user/.git.scmbrc.local")" == 'export GS_MAX_CHANGES=42' ]]
}

node_flag_dependencies() {
  source "$DOTFILES_DIR/installers/options.sh" || return 1
  parse_install_options --with-pnpm --with-yarn --with-bun --no-node || return 1
  [[ "$INSTALL_NODE:$INSTALL_PNPM:$INSTALL_YARN:$INSTALL_BUN" == 0:0:0:0 ]] || return 1
  parse_install_options --no-node --with-pnpm || return 1
  [[ "$INSTALL_NODE:$INSTALL_PNPM" == 1:1 ]] || return 1
  parse_install_options --with-codex --no-node || return 1
  [[ "$INSTALL_NODE:$INSTALL_CODEX" == 1:1 ]] || return 1
  if parse_install_options --node-version=invalid; then return 1; fi
  parse_install_options --repo-dir='/tmp/projects with spaces' || return 1
  [[ "$SCM_REPO_DIR" == '/tmp/projects with spaces' ]] || return 1
  if parse_install_options --repo-dir=; then return 1; fi
}

unique_backups() {
  mkdir -p "$test_dir/backups"
  printf 'personal contents\n' > "$test_dir/backups/config"
  # Force the timestamp collision that occurs on fast repeated migrations.
  date() { printf '20261011000000\n'; }
  link_dotfile "$test_dir/first" "$test_dir/backups/config"
  link_dotfile "$test_dir/second" "$test_dir/backups/config"
  local backups=( "$test_dir/backups"/config.backup.* )
  [[ ${#backups[@]} -eq 2 ]] || return 1
  local saved_personal=0 saved_link=0 backup
  for backup in "${backups[@]}"; do
    [[ ! -L "$backup/original" ]] || saved_link=1
    if [[ -f "$backup/original" && "$(< "$backup/original")" == 'personal contents' ]]; then saved_personal=1; fi
  done
  [[ "$saved_personal:$saved_link" == 1:1 ]]
}

linux_installers() {
  local platform
  for platform in ubuntu kali arch; do
    (
      source "$DOTFILES_DIR/installers/$platform.sh"
      INSTALL_DOCKER=1
      sudo() { printf '%s\n' "$*" >> "$test_dir/$platform.commands"; }
      apt-cache() { [[ "$2" != fd-find ]]; }
      has() { [[ "$1" == starship ]]; }
      install_go_yq_binary() { :; }
      getent() { printf '%s:x:1000:1000::/home/user:/bin/bash\n' "$(id -un)"; }
      install_packages
      install_optional_packages
      configure_default_shell
      grep -Fq "usermod --shell $(command -v zsh) $(id -un)" "$test_dir/$platform.commands"
    ) || return 1
  done
  cmp "$test_dir/ubuntu.commands" "$test_dir/kali.commands"
}

fzf_menus() {
  # Load the real menus without executing package installation.
  eval "$(sed -n '/^select_node_package_managers()/,/^source .*ai-tools.sh/p' "$DOTFILES_DIR/install.sh")"
  INSTALL_NODE=0 INSTALL_PNPM=0
  fzf() {
    local arg
    for arg in "$@"; do
      # fzf 0.29 rejects adaptive height. Model that external boundary.
      [[ "$arg" != --height=~* ]] || return 2
    done
    cat >/dev/null
    printf 'Node.js LTS (nvm)\npnpm\n'
  }
  select_optional_tools
  select_node_package_managers
  [[ "$INSTALL_NODE:$INSTALL_PNPM" == 1:1 ]]
}

fzf_menu_errors() {
  eval "$(sed -n '/^select_node_package_managers()/,/^source .*ai-tools.sh/p' "$DOTFILES_DIR/install.sh")"
  fzf() { cat >/dev/null; return 2; }
  local menu
  for menu in select_optional_tools select_node_package_managers; do
    if "$menu"; then return 1; else [[ $? == 2 ]] || return 1; fi
  done
  fzf() { cat >/dev/null; return 130; }
  select_optional_tools && select_node_package_managers
}

repository_index_setup() {
  local scm_dir="$HOME/.scm_breeze"
  if [[ ! -s "$scm_dir/scm_breeze.sh" ]]; then
    printf 'SKIP: repository index integration (SCM Breeze not installed)\n'
    return
  fi
  local fixture_home="$test_dir/index-home" root="$test_dir/projects with spaces"
  mkdir -p "$fixture_home" "$root"
  root="$(cd "$root" && pwd -P)"
  ln -s "$root" "$fixture_home/projects"
  ln -s "$scm_dir" "$fixture_home/.scm_breeze"
  ln -s "$scm_dir/scmbrc.example" "$fixture_home/.scmbrc"
  ln -s "$DOTFILES_DIR/zsh/.git.scmbrc" "$fixture_home/.git.scmbrc"
  printf 'export GS_MAX_CHANGES=42\n' > "$fixture_home/.git.scmbrc.local"
  git init -q "$root/project"
  (
    export HOME="$fixture_home"
    SCM_REPO_DIR=''
    configure_scm_repository_index 0 || return 1
    [[ ! -e "$HOME/.config/dotfiles/scm-repo-dir" ]] || return 1
    configure_scm_repository_index 1 <<< '' || return 1
    [[ ! -e "$HOME/.config/dotfiles/scm-repo-dir" ]] || return 1
    # The interactive input path accepts a directory and saves it once.
    configure_scm_repository_index 1 <<< "$root" || return 1
    [[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]] || return 1
    grep -Fxq "$root/project" "$root/.git_index" || return 1
    [[ "$(< "$HOME/.git.scmbrc.local")" == 'export GS_MAX_CHANGES=42' ]] || return 1
    configure_scm_repository_index 1 <<< '' || return 1
    [[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]] || return 1
    # A noninteractive rerun preserves the selected directory.
    configure_scm_repository_index 0 || return 1
    [[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]] || return 1
    SCM_REPO_DIR="$test_dir/blocked-index"
    mkdir -p "$SCM_REPO_DIR/.git_index"
    if configure_scm_repository_index 0; then return 1; fi
    [[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]] || return 1
    SCM_REPO_DIR="$root/missing"
    if configure_scm_repository_index 0; then return 1; fi
    [[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]] || return 1
    SCM_REPO_DIR='~/projects'
    configure_scm_repository_index 0 || return 1
    zsh -f -c 'autoload -Uz compinit; compinit -i -D; source "$HOME/.scm_breeze/scm_breeze.sh"; [[ ${_comps[c]} == _git_index_tab_completion ]] || exit 1; eval "c project"; [[ "$PWD" == "$1" ]]' check "$root/project"
  )
}

check checkout_migration
check node_flag_dependencies
check unique_backups
check linux_installers
check fzf_menus
check fzf_menu_errors
check repository_index_setup
exit "$failures"
