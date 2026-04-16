#!/usr/bin/env bash
set -Eeuo pipefail

case "${1:-}" in
	'' | -* ) set -- claude "$@" ;;
esac

exec "$@"
