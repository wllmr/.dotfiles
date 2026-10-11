#!/usr/bin/env zsh
set -e
repo_dir=$1
dotfiles_dir=${0:A:h:h}
scm_dir="$HOME/.scm_breeze"
test_home=$(mktemp -d)
trap 'rm -rf -- "$test_home"' EXIT
export HOME="$test_home"
autoload -Uz compinit
compinit -i -D
source "$dotfiles_dir/zsh/.zsh_aliases"

# Source the complete upstream implementation with no personal preferences.
if [[ -s "$scm_dir/git.scmbrc.example" ]]; then
  ln -s "$scm_dir" "$HOME/.scm_breeze"
  ln -s "$scm_dir/scmbrc.example" "$HOME/.scmbrc"
  ln -s "$dotfiles_dir/zsh/.git.scmbrc" "$HOME/.git.scmbrc"
  set +e
  source "$HOME/.scm_breeze/scm_breeze.sh"
  set -e
  [[ $GIT_SETUP_ALIASES == yes ]]
  [[ $aliases[gs] == git_status_shortcuts ]]
  [[ $aliases[ga] == git_add_shortcuts ]]
  [[ $aliases[gpl] == 'git pull' ]]
  [[ $aliases[gps] == 'git push' ]]
  [[ $aliases[gl] == 'git log --graph '* ]]
  [[ $aliases[gca] == git_commit_all ]]
  [[ $aliases[gcm] == 'git commit --amend' ]]
  [[ $aliases[gap] == 'git add -p' ]]
  [[ ! ${+aliases[gp]} -eq 1 && ! ${+aliases[gcall]} -eq 1 ]]
  print 'PASS: SCM Breeze defaults with complete upstream implementation'
else
  print 'SKIP: SCM Breeze alias integration (SCM Breeze is not installed)'
fi

cd "$repo_dir"
# Verify the custom command at the Git boundary without pushing externally.
(
  function git() { print -r -- "$*"; }
  [[ $(gpsup) == 'push --set-upstream origin HEAD' ]]
  [[ $(gpsup --dry-run) == 'push --set-upstream origin HEAD --dry-run' ]]
  if [[ -s "$scm_dir/git.scmbrc.example" ]]; then
    [[ $(eval gpl) == pull ]]
    [[ $(eval gps) == push ]]
  fi
)

# A real push to a local bare repository verifies HEAD and upstream semantics.
command git -c user.name='Shortcut Test' -c user.email='shortcut@example.invalid' commit -q --allow-empty -m fixture
command git init -q --bare "$HOME/remote.git"
command git remote add origin "$HOME/remote.git"
gpsup
[[ $(command git config branch.shortcut-check.remote) == origin ]]
[[ $(command git config branch.shortcut-check.merge) == refs/heads/shortcut-check ]]
[[ $(command git --git-dir="$HOME/remote.git" rev-parse refs/heads/shortcut-check) == $(command git rev-parse HEAD) ]]
print 'PASS: gpsup sets upstream on a local remote'
