#!/usr/bin/env bash
# Builds the open-pr eval repos in /tmp. Usage: ./setup.sh [target-dir]
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
out="${1:-/tmp/open-pr-eval}"
case "$out" in /tmp/*|/private/tmp/*) ;; *) echo "Refusing to write outside /tmp: $out" >&2; exit 1;; esac
rm -rf "$out"
"$here/../ready-check/setup.sh" "$out/open" >/dev/null
"$here/../ready-check/setup.sh" "$out/sync" >/dev/null
cd "$out/sync"
cat > src/export.ts <<'EOF'
import type { Transaction } from "./transactions"

const escapeField = (value: string) => (/[",\r\n]/.test(value) ? `"${value.replaceAll('"', '""')}"` : value)

const toRows = (transactions: Transaction[], from: string, to: string) =>
  transactions
    .filter((t) => t.date >= from && t.date <= to)
    .map((t) => [t.date, t.description, t.amount.toFixed(2), t.currency])

const toCsv = (rows: string[][]) =>
  ["date,description,amount,currency", ...rows.map((r) => r.map(escapeField).join(","))].join("\n")

export const exportTransactionsCsv = (transactions: Transaction[], { from, to }: { from: string; to: string }) =>
  toCsv(toRows(transactions, from, to))
EOF
sed -i.bak 's/date,description,amount\\n2026-01-05,Coffee,3.50/date,description,amount,currency\\n2026-01-05,Coffee,3.50,EUR/' src/export.test.ts && rm src/export.test.ts.bak
git add -A && git -c user.email=eval@example.com -c user.name=eval commit -qm "Add currency and escaping, drop JSON option"
cat > pr.json <<'EOF'
{"number": 4620, "base": "main", "head": "feature/csv-export",
 "title": "Add CSV and JSON transaction export",
 "body": "Closes EX-7\n\n## Why the change\n\nFinance needs transactions exported for bookkeeping.\n\n## Special things to note\n\n- `format: \"json\"` returns rows as JSON for the upcoming API consumer.\n- I (robin) chose inclusive date bounds after talking to finance.\n\n## Change outline\n\n```text\nexportTransactionsCsv\n  prepareRows → toRows (filter by date, format amount)\n  format === \"json\" ? JSON.stringify : toCsv\n```\n"}
EOF
echo "Scenarios ready in $out (open/, sync/)"
