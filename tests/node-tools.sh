#!/usr/bin/env bash
# Opt-in integration: downloads real nvm/Node into an isolated temporary HOME.
set -euo pipefail
DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ "${RUN_NODE_INTEGRATION:-0}" != 1 ]]; then
  printf 'SKIP: real Node integration (set RUN_NODE_INTEGRATION=1; requires network)\n'
  exit 0
fi
test_dir="$(mktemp -d)"
trap 'rm -rf -- "$test_dir"' EXIT
export HOME="$test_dir/home"
mkdir -p "$HOME"
unset NVM_DIR NVM_BIN NVM_INC NODE_VERSION
# Exclude host Node installations, npm configuration, and optional shell hooks.
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
unset BASH_ENV ENV npm_config_prefix NPM_CONFIG_PREFIX
source "$DOTFILES_DIR/installers/common.sh"
source "$DOTFILES_DIR/installers/options.sh"
source "$DOTFILES_DIR/installers/developer-tools.sh"
parse_install_options --node-version=24

# Exercise the real bootstrap, checking its effect before our Node step runs.
# nvm installation must not implicitly install Node from the exported selector.
bootstrap_pending=1
bash() {
  command bash "$@"
  if [[ "$bootstrap_pending" == 1 && "$1" != -c ]]; then
    bootstrap_pending=0
    if [[ -d "$HOME/.nvm/versions/node" ]]; then
      printf 'FAIL: nvm bootstrap installed Node before explicit version selection\n' >&2
      return 86
    fi
  fi
}

verify_node_setup() {
  local selected
  selected="$(command node --version)"
  [[ "$selected" == v24.* ]]
  [[ "$(nvm version default)" == "$selected" ]]
  [[ "$(< "$HOME/.nvm/alias/default")" == "$selected" ]]
  install_shared_config
  [[ -r "$HOME/.zshrc" && -r "$HOME/.config/starship.toml" ]]
  # Prove a new process can activate the saved default, not just this session.
  bash -c 'set -euo pipefail; source "$HOME/.nvm/nvm.sh"; [[ "$(command node --version)" == "$1" ]]' check "$selected"
}

install_optional_node
verify_node_setup
printf 'PASS: fresh real nvm installation selects Node 24 and creates shell config\n'

# A different, missing default must not override the requested version.
nvm alias default v26.3.0
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
hash -r
install_optional_node
verify_node_setup
printf 'PASS: existing real nvm installation repairs a stale default\n'

# Match the reported state: Node 24 is active, but the saved default is missing.
nvm alias default v26.3.0
[[ "$(command node --version)" == v24.* ]]
install_optional_node
verify_node_setup
printf 'PASS: real nvm repairs a stale default while Node 24 is already active\n'

install_optional_node
verify_node_setup
printf 'PASS: real nvm rerun with Node already installed\n'
