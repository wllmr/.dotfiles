#!/usr/bin/env bash
# Exercise installation/migration in an isolated directory, without changing HOME.
set -euo pipefail
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES_DIR/installers/common.sh"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT

if ! declare -F configure_scm_breeze_config >/dev/null; then
  printf 'FAIL: shared setup does not configure SCM Breeze alias ownership\n' >&2
  exit 1
fi

mkdir -p "$test_dir/user"
printf '%s\n' 'export GIT_SETUP_ALIASES="yes"' 'export GS_MAX_CHANGES="42"' > "$test_dir/user/.git.scmbrc"
configure_scm_breeze_config "$test_dir/user"
cmp "$test_dir/user/.git.scmbrc.local" <(printf '%s\n' 'export GIT_SETUP_ALIASES="yes"' 'export GS_MAX_CHANGES="42"')
[[ "$(readlink "$test_dir/user/.git.scmbrc")" == "$DOTFILES_DIR/zsh/.git.scmbrc" ]]
configure_scm_breeze_config "$test_dir/user"
cmp "$test_dir/user/.git.scmbrc.local" <(printf '%s\n' 'export GIT_SETUP_ALIASES="yes"' 'export GS_MAX_CHANGES="42"')

# Restore a deleted managed config without replacing surviving preferences.
mkdir -p "$test_dir/recovery"
printf 'export GS_MAX_CHANGES="42"\n' > "$test_dir/recovery/.git.scmbrc.local"
configure_scm_breeze_config "$test_dir/recovery"
[[ "$(readlink "$test_dir/recovery/.git.scmbrc")" == "$DOTFILES_DIR/zsh/.git.scmbrc" ]]
[[ "$(< "$test_dir/recovery/.git.scmbrc.local")" == 'export GS_MAX_CHANGES="42"' ]]

# Refuse an ambiguous migration rather than overwriting either preference file.
mkdir -p "$test_dir/conflict"
printf 'old config\n' > "$test_dir/conflict/.git.scmbrc"
printf 'local config\n' > "$test_dir/conflict/.git.scmbrc.local"
if configure_scm_breeze_config "$test_dir/conflict"; then
  printf 'FAIL: conflicting local preferences were overwritten\n' >&2
  exit 1
fi
[[ "$(< "$test_dir/conflict/.git.scmbrc")" == 'old config' ]]
[[ "$(< "$test_dir/conflict/.git.scmbrc.local")" == 'local config' ]]

# The pinned upstream files are needed for an integration check.
install_git_shortcuts "$test_dir/plugin"
install_git_shortcuts "$test_dir/plugin"
git init -q -b shortcut-check "$test_dir/repo"
zsh -f "$DOTFILES_DIR/tests/git-tools.zsh" "$test_dir/plugin/current" "$test_dir/repo"
printf 'PASS: Git plugin installation, SCM config migration/recovery and Git shortcuts\n'
