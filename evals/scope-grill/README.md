# scope-grill evals

Build the repo, then add the planning issue:

```sh
../verify-work/setup.sh /tmp/grill-eval
cd /tmp/grill-eval && git checkout -q main
printf '\n# EX-9: Monthly export email\nCompany admins want last month'"'"'s transactions CSV emailed to them on the 1st of each month.\n' >> ISSUE.md
mkdir -p src/jobs && echo 'export const jobs = [] as const // cron-style job registry, currently empty' > src/jobs/registry.ts
git add -A && git -c user.email=e@x -c user.name=e commit -qm "Add EX-9 and empty job registry"
```

Start a fresh session in `/tmp/grill-eval` and send these turns in order:

1. "grill me on how we should build EX-9 before we start"
2. "confirm, one company's admins get only their own company's CSV"
3. "2B, 3C, rest recs"

Grade each assertion PASS or FAIL, and quote the evidence:

- **Turn 1**
  - A scope line comes before any question: Goal, Must have, Not now, and Size, ending
    with confirm or edit.
  - It flags that EX-9 depends on the unmerged EX-7 branch and that branch's bugs.
- **Turn 2**
  - At most four questions.
  - Every option shows a code-shape `diff` or sketch, a scope label (`=`, `−`, or `+`),
    a file count, and a one-way or two-way door.
  - Each losing wider option says when it would become worth it.
  - The turn ends with `accept all recs`.
- **Turn 3**
  - The scope meter changes from `MVP + 0`, and it names the pick that caused the
    change.
  - Questions that only exist because of the wider pick are flagged as question creep.
  - A changed earlier recommendation names its reason.
- **Summary** (optional 4th turn, "accept all recs"): it ends with a `## Not in scope`
  list. Each item gives its reason and a revisit signal, and it offers to add the list
  to the ticket, spec, or PR.
