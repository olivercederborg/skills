---
name: review-loop
description: Runs independent Claude and Codex code reviews in parallel, verifies and merges their findings, then fixes what the user approves and re-reviews until nothing actionable remains. Use when asked for a second opinion, a review by Claude or Codex (or both), a cross-check, or another review pass.
compatibility: Requires git, plus the claude and codex CLIs for the cross-agent reviewer.
---

# Review loop

Two independent reviewers look at the same change. The main agent is the coordinator:
it verifies, merges, reports, and fixes, but it is not a third reviewer. A round ends in
**Clean** or a list of verified findings. Rounds repeat until the change is clean.

<!-- toolkit-format:start (synced from shared/format.md by scripts/sync-format.sh; edit there) -->
## Chat format

The user thinks visually and scans. They understand a problem through its flow and the
shape of the code.

**Cards.** Each item that needs a look is a card, in this order:

1. **Heading**: `### 2/5 · <kind>: <subject>`. The progress count shows what's left,
   and each skill defines its own kinds.
2. **Location**: who raised it (their login), and a linked `path:line`.
3. **Evidence lines**, a few words each:
   - `✅ Verified: <how>`, or `❌ Doesn't hold: <why>`
   - `🔎 Sources: <what was checked>`
   - `⚠️ Unverified: <gap>`, only when a gap remains
4. **A picture**, when the code alone doesn't make the flow clear: a text call tree, a
   failure sequence, a state flow, or a case table.
5. **The change** as a `diff`, with enough context to place it in the flow. That means
   the whole function when it's small, or one block per file in call order, each headed
   by its path.
6. **At most two one-line bullets** for risks or assumptions.

**Severity** for code findings:

- **Blocker**: wrong behavior, missing scope, a failing check, or a broken rule.
- **Should**: slop, scope creep, or a non-idiomatic pattern with a clear better form.
- **Optional**: a real improvement that can wait.

**Turns.**

- **Start with content**: the verdict, a table, a card, or the result.
- **Once per session**: show each piece of code, warning, and `FYI:` only once. List
  tests as one-line cases: `file: scenario → expected ✅`.
- **Only what needs the user**: report what they must look at or decide.
- **One-line bullets.**
- **Tables**: at most four columns, with a few words per cell.
- **Side information**, such as CI noise, goes on one `FYI:` line at the end.
- **End on `Next:`**: finish every turn with one bold `**Next:**` line of at most four
  short options. It is the turn's only question.
<!-- toolkit-format:end -->

Card kinds here: **Blocker**, **Should**, **Optional**.

## Reviewers

| Reviewer | Model | Effort |
|---|---|---|
| Claude | `opus` | `high` |
| Codex | the user's configured default Codex model | `high` |

Use these unless the user names other models for this run.

- **From Claude Code:**
  - The Claude reviewer is a subagent with model `opus`.
  - The Codex reviewer is a subagent that only runs Codex and returns its output
    verbatim:

    ```bash
    codex exec --sandbox read-only -C <repo-root> -c model_reasoning_effort=high \
      -o <out-file> - < <prompt-file>
    ```
- **From Codex:**
  - The Codex reviewer is a subagent on the default model with high reasoning effort.
  - The Claude reviewer runs:

    ```bash
    claude -p --model opus --effort high --add-dir <repo-root> \
      --allowedTools Read Grep Glob < <prompt-file>
    ```

    The prompt goes on stdin because `--allowedTools` takes several values and would
    swallow a prompt passed as an argument.

If a reviewer fails (missing CLI, auth, budget, or timeout), continue with the other
one, and label the round **single reviewer** with the reason.

## 1. Pin the target

- **Explicit**: a PR, branch, commit range, or set of files. When the user names one,
  review that.
- **Branch**: diff against the stack parent, or against the merge-base with the default
  branch.
- **PR**: use the live PR diff.
- **Working changes**: staged, unstaged, and relevant untracked files.

Leave out generated, vendored, lockfile, and binary content unless it's central to the
change.

## 2. Compose the prompt once

Both reviewers get the same prompt, byte for byte. Write it to a file, together with the
packet (target, base and head, changed files, and the diff). Save the file under the
repo root so sandboxed reviewers can read it, and delete it and the reviewer output
files when the loop ends.

```text
Review this change as a production code reviewer. Read-only: do not edit, stage,
commit, push, comment, or run destructive commands.

Target: <PR | branch | range | working changes>
Scope: <what is included and what is left out>
Intent: <the issue or spec, in one or two lines>
Packet: <path>
<Round 2+: Previous findings and their fixes: <list>. Check each fix, then look for
regressions and anything new in the updated diff.>

Report every finding with a severity, a file:line, the failure it causes, and the
smallest fix:
P0: data loss, security, or outage. P1: wrong behavior on a likely path.
P2: edge-case bug, or changed behavior without a test. P3: optional.
Give a complete, independent review. If there are no findings, say so.
```

## 3. Review, verify, merge

1. **Run both reviewers in parallel.**
2. **Verify each finding** against the code before showing it, following
   [grounding](references/grounding.md). Reviewers sometimes make false claims. Drop a
   finding that doesn't hold, and note the drop in one line.
3. **Map severity.** Reviewer P0 and P1 become **Blocker**, P2 becomes **Should**, and P3
   becomes **Optional**.
4. **Merge.** Group findings by root cause, note who raised each one (Claude, Codex, or
   both), and show severity disagreements as they are.

## 4. Report

````markdown
**Round 1: 1 blocker, 2 should.** Claude 2 · Codex 2 · both agree on 1.

| # | Where | Finding | Sev · who |
|---|-------|---------|-----------|
| 1 | `retry.ts:40` | Retry double-charges | Blocker · both |
| 2 | `retry.ts:12` | Backoff never caps | Should · Codex |
| 3 | `retry.test.ts` | No test for the timeout path | Should · Claude |

### 1/3 · Blocker: retry double-charges
[`src/retry.ts:40`](link)
✅ Verified: traced `charge` → `retry` → `charge`
🔎 Sources: provider docs on idempotency keys

```diff
-  await provider.charge(amount)
+  await provider.charge(amount, { idempotencyKey: attempt.id })
```

Dropped 1: Codex's "unhandled rejection" at `queue.ts:8` is caught at line 12.

**Next:** fix all · fix blockers · discuss N · stop
````

- **Verdict first.** Write **Clean**, or the round number and the counts by severity.
  A clean round ends with `**Next:** ready-check · open-pr`.
- **Cards** for blockers, and for any fix that changes the flow or design.

## 5. Fix and re-review

When the user approves fixes:

1. Apply them on the branch that owns each change, run the focused checks, and commit
   each fix as its own atomic commit.
2. Start the next round with the same reviewers and the updated diff. The prompt now
   lists the previous findings and their fixes.
3. Report only what is new or still open.

Stop when a round comes back with no blockers or should findings (**Clean**), or after
three rounds, or when the user stops. After three rounds, list what's still open and
let the user decide. Push only when the user asks.

## Challenges

"Anything else?" or "are you sure?" asks for a re-check. Re-verify against the code, and
change a verdict only on new evidence, naming that evidence.

**Done when:** a round is **Clean**, or every remaining finding is fixed, deferred, or
dropped by the user.
