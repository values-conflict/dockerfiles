#!/usr/bin/env bash
set -Eeuo pipefail

wget -qO versions.json.new 'https://pi.dev/api/latest-version'

jq --raw-output '
	if .ok and .version and .packageName then
		"\(.packageName): \(.version)"
	else
		error("either not OK or missing version/packageName!\n\(.)")
	end
' versions.json.new

jq --tab '.' versions.json.new > versions.json
rm versions.json.new
