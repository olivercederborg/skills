#!/usr/bin/env bash
# Builds the review-teammate-pr eval repo in /tmp. Usage: ./setup.sh [target-dir]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="${1:-/tmp/review-teammate-pr-evals}"
case "$out" in /tmp/*|/private/tmp/*) ;; *) echo "Refusing to write outside /tmp: $out" >&2; exit 1;; esac
rm -rf "$out" && mkdir -p "$out/fee-rows"
commit() { git -c user.email=eval@example.com -c user.name=eval commit -qm "$1"; }

# Base on develop, PR head on feature/fee-rows
(cd "$out/fee-rows" && git init -q -b develop \
  && cp -R "$here/fee-rows/base/." . && git add src && commit "Base" \
  && git checkout -q -b feature/fee-rows \
  && cp -R "$here/fee-rows/head/." . && git add src && commit "Add fee rows to top-up export" \
  && cp "$here/fee-rows/pr.json" .)

echo "Scenario ready in $out"
