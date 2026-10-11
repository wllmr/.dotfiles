# Load real installed nvm, replacing only its external version lookup.
source "$NODE_TEST_NVM_SCRIPT" "$@"
nvm_remote_version() { printf '%s\n' "$NODE_TEST_VERSION"; }
