#!/usr/bin/env bash
# Parse before installing anything; later flags override earlier selections.
parse_install_options() {
  INSTALL_DOCKER=0 INSTALL_CODEX=0 INSTALL_CLAUDE=0 INSTALL_HERDR=0
  INSTALL_NODE=0 INSTALL_PNPM=0 INSTALL_YARN=0 INSTALL_BUN=0
  NODE_VERSION='lts/*'
  local flag
  for flag in "$@"; do
    case "$flag" in
      --with-docker) INSTALL_DOCKER=1 ;;
      --no-docker) INSTALL_DOCKER=0 ;;
      --with-codex) INSTALL_CODEX=1 ;;
      --no-codex) INSTALL_CODEX=0 ;;
      --with-node) INSTALL_NODE=1 ;;
      --with-pnpm) INSTALL_PNPM=1; INSTALL_NODE=1 ;;
      --with-yarn) INSTALL_YARN=1; INSTALL_NODE=1 ;;
      --with-bun) INSTALL_BUN=1; INSTALL_NODE=1 ;;
      --no-pnpm) INSTALL_PNPM=0 ;;
      --no-yarn) INSTALL_YARN=0 ;;
      --no-bun) INSTALL_BUN=0 ;;
      --node-version=*) NODE_VERSION="${flag#*=}"; INSTALL_NODE=1 ;;
      --no-node) INSTALL_NODE=0; INSTALL_PNPM=0; INSTALL_YARN=0; INSTALL_BUN=0 ;;
      --with-herdr) INSTALL_HERDR=1 ;;
      --no-herdr) INSTALL_HERDR=0 ;;
      --with-claude) INSTALL_CLAUDE=1 ;;
      --no-claude) INSTALL_CLAUDE=0 ;;
      *) log "Unknown option: $flag (see README.md for supported options)"; return 2 ;;
    esac
  done
  if [[ ! "$NODE_VERSION" =~ ^(lts/\*|lts/[a-zA-Z]+|node|stable|[0-9]+(\.[0-9]+){0,2})$ ]]; then
    log "Invalid Node version: $NODE_VERSION (use lts/*, 22, 22.14, or 22.14.0)"
    return 2
  fi
  # Codex requires Node even when the standalone Node selection is disabled.
  [[ "$INSTALL_CODEX" != 1 ]] || INSTALL_NODE=1
  export INSTALL_DOCKER INSTALL_CODEX INSTALL_CLAUDE INSTALL_HERDR INSTALL_NODE NODE_VERSION INSTALL_PNPM INSTALL_YARN INSTALL_BUN
}
