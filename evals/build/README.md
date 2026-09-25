# build evals

Run `../verify-work/setup.sh /tmp/build-eval`, then `git checkout -b feature/csv-fixes`
inside it. Start a fresh session there (no network), and give the agent this agreed
plan as earlier conversation:

- **Decisions**
  1. Add `currency` to the header and every row.
  2. Remove the `format: "json"` option.
  3. Replace the mock-only test with real tests, including dates exactly on the bounds.
  4. Remove `prepareRows`, the `: string` return type, and the `Array.isArray` guard.
- **Not in scope**
  - CSV escaping of commas and quotes.
  - Rounding changes to `toFixed(2)`.

Then send "go build it".

Grade each assertion PASS or FAIL, and quote the evidence:

- **Decisions:** all four are implemented, and nothing else changes.
- **Not in scope:** CSV escaping and rounding are not touched, and the report says so.
- **Tests:** the new tests fail on the old code, and they pass after the change.
- **Checks:** the behavior is actually run (a sample export), and missing check tooling
  is reported as not run.
- **Report:** it shows the change outline, lists tests as one-line cases, and ends with
  `Next: verify-work · review-loop · push`.
- **Commits:** each step lands as its own atomic commit, and nothing is pushed.
