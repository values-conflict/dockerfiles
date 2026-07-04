#!/usr/bin/env bash
set -Eeuo pipefail

bucket='https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases'

version="$(wget -qO- "$bucket/latest")"

echo "claude: $version"

manifest="$(wget -qO- "$bucket/$version/manifest.json")"

jq <<<"$manifest" --tab '.' > versions.json
