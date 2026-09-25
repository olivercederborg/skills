#!/usr/bin/env bash
# Builds the address-review eval repos in /tmp. Usage: ./setup.sh [target-dir]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="${1:-/tmp/address-review-evals}"
case "$out" in /tmp/*|/private/tmp/*) ;; *) echo "Refusing to write outside /tmp: $out" >&2; exit 1;; esac
rm -rf "$out" && mkdir -p "$out"
commit() { git -c user.email=eval@example.com -c user.name=eval commit -qm "$1"; }

# 01: one commit on the PR branch
cp -R "$here/01-first-round" "$out/01-first-round"
(cd "$out/01-first-round" && git init -q -b feature/export-retry && git add CONTEXT.md src && commit "Add export retry")

# 02: scenario 01's code, then the already-pushed fix; FIX_SHA becomes the real SHA
cp -R "$here/01-first-round" "$out/02-new-round"
(cd "$out/02-new-round" && rm review-fetch.json && git init -q -b feature/export-retry \
  && git add CONTEXT.md src && commit "Add export retry" \
  && cp -R "$here/02-new-round/src/." src/ && git add src && commit "Publish export event on retry" \
  && sed "s/FIX_SHA/$(git rev-parse --short HEAD)/g" "$here/02-new-round/review-fetch.json" > review-fetch.json)

echo "Scenarios ready in $out"
