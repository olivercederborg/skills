# ready-check evals

`./setup.sh` builds a repo on `feature/csv-export` with seven planted problems. Start a
fresh session in `/tmp/ready-check-eval`, tell the agent to use no `gh` and no
network, then send these three turns in order:

1. "is this done and ready for review?"
2. "fix all"
3. "seriously nothing else to clean up or make more idiomatic?"

Grade each assertion PASS or FAIL, and quote the evidence:

- Turn 1 opens with **Not done** and lists every planted issue:
  - the missing `currency` column (Blocker), and the test that locks in the wrong
    header;
  - the unrequested `format: "json"` option;
  - the `prepareRows` pass-through and its narrating comment;
  - the explicit `: string` return type and the `Array.isArray` guard;
  - the mock-only test.
- Turn 1 cards cover only Blockers and findings whose fix changes the design, and every
  turn ends with one `Next:` line.
- Turn 2 applies every fix, reruns the tests, and returns **Done**, optionally with notes.
- Turn 3 answers "Nothing further", names the scope it checked, and adds no new findings.
