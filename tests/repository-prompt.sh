#!/usr/bin/env bash
# Exercise real terminal input and Readline completion in an isolated HOME.
set -euo pipefail
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v expect >/dev/null 2>&1; then
  printf 'SKIP: repository prompt terminal integration (expect not installed)\n'
  exit 0
fi
scm_dir="$HOME/.scm_breeze"
if [[ ! -s "$scm_dir/scm_breeze.sh" ]]; then
  printf 'SKIP: repository prompt terminal integration (SCM Breeze not installed)\n'
  exit 0
fi
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
export HOME="$test_dir/home" INPUTRC=/dev/null TERM=xterm-256color
mkdir -p "$HOME/Projects With Spaces" "$HOME/Documents One" "$HOME/Documents Two"
ln -s "$scm_dir" "$HOME/.scm_breeze"
ln -s "$scm_dir/scmbrc.example" "$HOME/.scmbrc"
ln -s "$DOTFILES_DIR/zsh/.git.scmbrc" "$HOME/.git.scmbrc"
git init -q "$HOME/Projects With Spaces/project"
expect "$DOTFILES_DIR/tests/repository-prompt.exp" "$DOTFILES_DIR" blank
[[ ! -e "$HOME/.config/dotfiles/scm-repo-dir" ]]
printf 'PASS: blank terminal input skips an unconfigured repository root\n'
expect "$DOTFILES_DIR/tests/repository-prompt.exp" "$DOTFILES_DIR" complete
root="$(cd "$HOME/Projects With Spaces" && pwd -P)"
[[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]]
grep -Fxq "$root/project" "$root/.git_index"
printf 'PASS: terminal Tab completion selects a repository path containing spaces\n'
expect "$DOTFILES_DIR/tests/repository-prompt.exp" "$DOTFILES_DIR" list
[[ "$(< "$HOME/.config/dotfiles/scm-repo-dir")" == "$root" ]]
printf 'PASS: double Tab lists existing folders; blank retains the selected root\n'
