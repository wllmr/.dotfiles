#!/usr/bin/env zsh
# Exercise the complete startup file without using personal configuration.
set -eu
repo_dir=${0:A:h:h}
test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
export HOME="$test_dir/home"
mkdir -p "$HOME" "$test_dir/brew/share/zsh-completions"
print '#compdef review-command' > "$test_dir/brew/share/zsh-completions/_review_command"
plugin_dir="$HOME/.local/share/dotfiles/oh-my-zsh/current"
mkdir -p "$plugin_dir/lib" "$plugin_dir/plugins/git"
for file in lib/git.zsh lib/clipboard.zsh plugins/git/git.plugin.zsh; do
  print '# fixture' > "$plugin_dir/$file"
done
# Replace external integration generators, not the startup logic under test.
brew() { [[ $1 == --prefix ]] && print -r -- "$test_dir/brew"; }
fzf() {
  print call >> "$test_dir/fzf-calls"
  [[ $1 == --zsh ]] || return 1
  print "alias review_fzf='print integration-loaded'"
}
starship() { return 0; }
zoxide() { return 0; }
# The command checks in .zshrc inspect executable availability.
commands[fzf]=/usr/bin/true
commands[starship]=/usr/bin/true
commands[zoxide]=/usr/bin/true
set +e
source "$repo_dir/zsh/.zshrc"
set -e
failures=0
if [[ ${_comps[review-command]:-} == _review_command ]]; then
  print 'PASS: Homebrew completion discovered'
else
  print -u2 'FAIL: Homebrew completion missing'; (( failures += 1 ))
fi
if [[ ${aliases[review_fzf]:-} == 'print integration-loaded' && $(wc -l < "$test_dir/fzf-calls") -eq 1 ]]; then
  print 'PASS: fzf integration generated once'
else
  print -u2 'FAIL: fzf integration missing or generated twice'; (( failures += 1 ))
fi

# Model system package paths in a temporary filesystem, not the real /usr.
# Only those external paths are substituted; the complete startup logic runs.
mkdir -p "$test_dir/debian"
print "alias review_legacy_keys='print keys-loaded'" > "$test_dir/debian/key-bindings.zsh"
print "alias review_legacy_completion='print completion-loaded'" > "$test_dir/debian/completion.zsh"
fzf() { return 2; }
legacy_source=$(< "$repo_dir/zsh/.zshrc")
legacy_source=${legacy_source//\/usr\/share\/fzf/$test_dir/missing}
legacy_source=${legacy_source//\/usr\/share\/doc\/fzf\/examples/$test_dir/debian}
set +e
eval "$legacy_source"
set -e
if [[ ${aliases[review_legacy_keys]:-} == 'print keys-loaded' &&
      ${aliases[review_legacy_completion]:-} == 'print completion-loaded' ]]; then
  print 'PASS: legacy Debian fzf keys and completions loaded'
else
  print -u2 'FAIL: legacy Debian fzf integration missing'; (( failures += 1 ))
fi
exit $failures
