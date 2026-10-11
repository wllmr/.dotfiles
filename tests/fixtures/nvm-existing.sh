# Offline nvm boundary: auto-use of a missing default exits with status 3.
# Model an existing installation; do not download or change host Node versions.
if [[ "${1:-}" != --no-use ]]; then return 3; fi
npm() { [[ "$1" == --version ]] && printf '11.0.0\n'; }
nvm() {
  case "$1" in
    deactivate) [[ "$2" == --silent ]] ;;
    install)
      [[ "$2" == 24 ]] || return 1
      if [[ "${NODE_INSTALL_FAILURE:-0}" == 1 ]]; then return 7; fi
      node() { printf 'v24.21.0\n'; }
      ;;
    alias)
      [[ "$2:$3" == default:v24.21.0 ]] || return 1
      printf '%s\n' "$3" > "$NVM_DIR/alias/default"
      ;;
    use)
      [[ "$2" == default && "$(< "$NVM_DIR/alias/default")" == v24.21.0 ]]
      ;;
    version)
      [[ "$2" == default ]] || return 1
      printf '%s\n' "$(< "$NVM_DIR/alias/default")"
      ;;
    --version) printf 'test-fixture\n' ;;
    *) return 1 ;;
  esac
}
