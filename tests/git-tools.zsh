#!/usr/bin/env zsh
set -e
plugin_dir=$1
repo_dir=$2
autoload -Uz compinit
compinit -D
zstyle ':omz:alpha:lib:git' async-prompt no
source "$plugin_dir/lib/git.zsh"
source "$plugin_dir/lib/clipboard.zsh"
source "$plugin_dir/plugins/git/git.plugin.zsh"

# Use the installed SCM Breeze implementation if available; no installer runs.
if [[ -s "$HOME/.scm_breeze/git.scmbrc.example" ]]; then
  source "${0:A:h:h}/zsh/.git.scmbrc"
  # SCM Breeze targets interactive shells; some feature probes return false.
  set +e
  source "$HOME/.scm_breeze/lib/scm_breeze.sh"
  source "$HOME/.scm_breeze/lib/git/helpers.sh"
  source "$HOME/.scm_breeze/lib/git/aliases.sh"
  set -e
  [[ $GIT_SETUP_ALIASES == no ]]
  [[ $aliases[gs] == git_status_shortcuts ]]
  [[ $aliases[ga] == git_add_shortcuts ]]
  [[ $aliases[gcall] == git_commit_all ]]
  print 'PASS: SCM Breeze alias integration with installed upstream libraries'
else
  print 'SKIP: SCM Breeze alias integration (SCM Breeze is not installed)'
fi

cd "$repo_dir"
[[ $(git_current_branch) == shortcut-check ]]
[[ $aliases[gp] == 'git push' ]]
[[ $aliases[gl] == 'git pull' ]]
[[ ! ${+aliases[gps]} -eq 1 ]]

# Intercept the Git command at the boundary: verify arguments, never push/pull.
function git() { print -r -- "$*"; }
[[ $(eval gp) == push ]]
[[ $(eval gl) == pull ]]
[[ $(eval gpsup) == 'push --set-upstream origin shortcut-check' ]]
