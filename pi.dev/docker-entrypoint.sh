#!/usr/bin/env bash
set -Eeuo pipefail

case "${1:-}" in
	'' | -* ) set -- pi "$@" ;;
esac

exec "$@"
