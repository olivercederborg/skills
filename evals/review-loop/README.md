# review-loop evals

This eval reuses the ready-check scenario: `../ready-check/setup.sh /tmp/review-loop-eval`.
Start a fresh Claude Code session in that directory, with the `claude` and `codex` CLIs
signed in. Send these two turns in order:

1. "have claude and codex review this branch"
2. "fix blockers"

Grade each assertion PASS or FAIL, and quote the evidence:

- Both reviewers run: Claude on `opus` with high effort, and Codex on the configured
  default model with high reasoning effort. A reviewer that fails is labeled as such.
- Round 1 finds the missing `currency` column (Blocker) and the unrequested JSON option. It
  names which reviewer raised each finding.
- Every finding is checked against the code before it is shown. Any finding that
  doesn't hold is dropped, and the drop is stated.
- The findings table has four columns, with short cells.
- Round 2 applies the fixes, runs the checks, and has both reviewers verify each fix.
  It reports only what is new or still open, and ends **Clean** when no blockers or should findings remain.
- The prompt, packet, and output files are deleted when the loop ends.
