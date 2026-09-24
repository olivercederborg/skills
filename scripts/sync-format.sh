#!/usr/bin/env bash
# Copies shared/format.md into every SKILL.md between the toolkit-format markers.
# Usage: scripts/sync-format.sh          # write
#        scripts/sync-format.sh --check  # exit 1 if any copy differs
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
python3 - "$root" "${1:-}" <<'PY'
import pathlib, re, sys
root, mode = pathlib.Path(sys.argv[1]), sys.argv[2]
block = (root / "shared/format.md").read_text().strip()
pattern = re.compile(r"<!-- toolkit-format:start.*?<!-- toolkit-format:end -->", re.S)
stale = []
for skill in sorted(root.glob("*/SKILL.md")):
    text = skill.read_text()
    if not pattern.search(text):
        continue
    synced = pattern.sub(lambda _: block, text)
    if synced != text:
        stale.append(str(skill.relative_to(root)))
        if mode != "--check":
            skill.write_text(synced)
if mode == "--check" and stale:
    print("Out of sync with shared/format.md:", *stale, sep="\n  ")
    sys.exit(1)
print("synced" if mode != "--check" else "format blocks in sync", *stale, sep="\n  ")
PY
