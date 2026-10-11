#!/usr/bin/env bash
# Offline integration with installed nvm: reproduce competing Node PATH order.
set -euo pipefail
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
export NODE_TEST_NVM_SCRIPT="$HOME/.nvm/nvm.sh"
if [[ ! -s "$NODE_TEST_NVM_SCRIPT" ]]; then
  printf 'SKIP: real nvm PATH integration (nvm not installed)\n'
  exit 0
fi
node_dir=''
for candidate in "$HOME"/.nvm/versions/node/v24*/bin/node; do
  if [[ -x "$candidate" ]]; then node_dir="${candidate%/bin/node}"; break; fi
done
if [[ -z "$node_dir" ]]; then
  printf 'SKIP: real nvm PATH integration (Node 24 not installed)\n'
  exit 0
fi
export NODE_TEST_VERSION="$("$node_dir/bin/node" --version)"
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
export HOME="$test_dir/home"
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR/alias" "$NVM_DIR/versions/node" "$test_dir/system/bin"
ln -s "$node_dir" "$NVM_DIR/versions/node/$NODE_TEST_VERSION"
cp "$DOTFILES_DIR/tests/fixtures/nvm-path.sh" "$NVM_DIR/nvm.sh"
cp "$DOTFILES_DIR/tests/fixtures/system-node.sh" "$test_dir/system/bin/node"
cp "$DOTFILES_DIR/tests/fixtures/system-npm.sh" "$test_dir/system/bin/npm"
chmod +x "$test_dir/system/bin/node" "$test_dir/system/bin/npm"
printf 'v26.3.0\n' > "$NVM_DIR/alias/default"
export PATH="$test_dir/system/bin:$NVM_DIR/versions/node/$NODE_TEST_VERSION/bin:/usr/bin:/bin:/usr/sbin:/sbin"
[[ "$(node --version)" == v26.3.0 ]]
source "$DOTFILES_DIR/installers/common.sh"
source "$DOTFILES_DIR/installers/options.sh"
source "$DOTFILES_DIR/installers/developer-tools.sh"
parse_install_options --node-version=24
install_optional_node
[[ "$(node --version)" == "$NODE_TEST_VERSION" ]]
[[ "$(nvm version default)" == "$NODE_TEST_VERSION" ]]
[[ "$(command -v node)" == "$NVM_DIR/versions/node/$NODE_TEST_VERSION/bin/node" ]]
printf 'PASS: installer selects real nvm Node ahead of a competing system Node\n'

# Start with the same bad ordering again; managed startup must repair it too.
export PATH="$test_dir/system/bin:$NVM_DIR/versions/node/$NODE_TEST_VERSION/bin:/usr/bin:/bin:/usr/sbin:/sbin"
TERM=xterm-256color zsh -f -c 'source "$1/zsh/.zshrc"; [[ "$(node --version)" == "$NODE_TEST_VERSION" && "$(nvm version default)" == "$NODE_TEST_VERSION" ]]' check "$DOTFILES_DIR"
printf 'PASS: managed Zsh startup selects nvm Node ahead of Homebrew/system Node\n'
