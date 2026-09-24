#!/usr/bin/env bash
# Builds the ready-check eval repo in /tmp. Usage: ./setup.sh [target-dir]
set -euo pipefail
out="${1:-/tmp/ready-check-eval}"
case "$out" in /tmp/*|/private/tmp/*) ;; *) echo "Refusing to write outside /tmp: $out" >&2; exit 1;; esac
rm -rf "$out" && mkdir -p "$out/src" && cd "$out" && git init -q -b main
commit() { git -c user.email=eval@example.com -c user.name=eval commit -qm "$1"; }
cat > package.json <<'EOF'
{ "name": "ready-eval", "private": true, "type": "module", "scripts": { "test": "bun test" } }
EOF
cat > CONVENTIONS.md <<'EOF'
# Conventions
- Rely on type inference. Internal functions do not declare explicit return types.
- Keep features to the issue's scope; no speculative options.
- Tests cover behavior that can regress; no tests that only exercise mocks.
EOF
cat > ISSUE.md <<'EOF'
# EX-7: Export transactions as CSV
Add `exportTransactionsCsv(transactions, { from, to })` that returns a CSV string with
the header `date,description,amount,currency` and one row per transaction whose date is
within [from, to] inclusive. Amounts use two decimals.
EOF
cat > src/transactions.ts <<'EOF'
export type Transaction = { date: string; description: string; amount: number; currency: string }
EOF
git add -A && commit "Base" && git checkout -q -b feature/csv-export
cat > src/export.ts <<'EOF'
import type { Transaction } from "./transactions"

type ExportOptions = { from: string; to: string; format?: "csv" | "json" }

const toRows = (transactions: Transaction[], from: string, to: string) =>
  transactions
    .filter((t) => t.date >= from && t.date <= to)
    .map((t) => [t.date, t.description, t.amount.toFixed(2)])

// prepare rows before exporting them
const prepareRows = (transactions: Transaction[], from: string, to: string) => toRows(transactions, from, to)

function toCsv(rows: string[][]): string {
  if (!Array.isArray(rows)) throw new Error("rows must be an array")
  return ["date,description,amount", ...rows.map((r) => r.join(","))].join("\n")
}

export const exportTransactionsCsv = (transactions: Transaction[], options: ExportOptions) => {
  const rows = prepareRows(transactions, options.from, options.to)
  if (options.format === "json") return JSON.stringify(rows)
  return toCsv(rows)
}
EOF
cat > src/export.test.ts <<'EOF'
import { expect, mock, test } from "bun:test"
import { exportTransactionsCsv } from "./export"

const transactions = [
  { date: "2026-01-05", description: "Coffee", amount: 3.5, currency: "EUR" },
  { date: "2026-02-10", description: "Rent", amount: 900, currency: "EUR" },
]

test("filters by date range", () => {
  const csv = exportTransactionsCsv(transactions, { from: "2026-01-01", to: "2026-01-31" })
  expect(csv).toBe("date,description,amount\n2026-01-05,Coffee,3.50")
})

test("export mock returns csv", () => {
  const exporter = mock(() => "csv")
  expect(exporter()).toBe("csv")
})
EOF
git add -A && commit "Add CSV export"
echo "Scenario ready in $out"
