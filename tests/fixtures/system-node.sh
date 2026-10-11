#!/usr/bin/env bash
# A competing system Node at the package-manager boundary.
case "${1:-}" in
  --version|-v) printf 'v26.3.0\n' ;;
  *) exit 1 ;;
esac
