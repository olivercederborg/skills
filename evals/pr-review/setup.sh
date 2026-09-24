#!/usr/bin/env bash
# Builds the eval scenarios as throwaway git repos. Usage: ./setup.sh [target-dir]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="${1:-/tmp/pr-review-evals}"
case "$out" in /tmp/*|/private/tmp/*) ;; *) echo "Refusing to write outside /tmp: $out" >&2; exit 1;; esac
rm -rf "$out" && mkdir -p "$out"
commit() { git -c user.email=eval@example.com -c user.name=eval commit -qm "$1"; }

# 01: one commit on the PR branch
cp -R "$here/01-receiving-first-round" "$out/01-receiving-first-round"
(cd "$out/01-receiving-first-round" && git init -q -b feature/export-retry && git add CONTEXT.md src && commit "Add export retry")

# 02: base on develop, PR head on feature/fee-rows
mkdir -p "$out/02-teammate-fee-rows"
(cd "$out/02-teammate-fee-rows" && git init -q -b develop \
  && cp -R "$here/02-teammate-fee-rows/base/." . && git add src && commit "Base" \
  && git checkout -q -b feature/fee-rows \
  && cp -R "$here/02-teammate-fee-rows/head/." . && git add src && commit "Add fee rows to top-up export" \
  && cp "$here/02-teammate-fee-rows/pr.json" .)

# 03: scenario 01's code, then the already-pushed fix; FIX_SHA becomes the real SHA
cp -R "$here/01-receiving-first-round" "$out/03-receiving-new-round"
(cd "$out/03-receiving-new-round" && rm review-fetch.json && git init -q -b feature/export-retry \
  && git add CONTEXT.md src && commit "Add export retry" \
  && cp -R "$here/03-receiving-new-round/src/." src/ && git add src && commit "Publish export event on retry" \
  && sed "s/FIX_SHA/$(git rev-parse --short HEAD)/g" "$here/03-receiving-new-round/review-fetch.json" > review-fetch.json)

echo "Scenarios ready in $out"
