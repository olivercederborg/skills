---
name: review-loop
description: Runs independent Claude and Codex code reviews in parallel, verifies and merges their findings, then fixes what the user approves and re-reviews until nothing actionable remains. Use when asked for a second opinion, a review by Claude or Codex (or both), a cross-check, or another review pass.
compatibility: Requires git, plus the claude and codex CLIs for the cross-agent reviewer.
---

# Review loop

Two independent reviewers look at the same change. The main agent coordinates: it
verifies, merges, reports, and fixes, and adds no findings of its own. Rounds repeat
until one comes back **Clean**, three rounds have run, or the user stops.

<!-- toolkit-format:start (synced from shared/format.md by scripts/sync-format.sh; edit there) -->
## Chat format

The user thinks visually and scans. They understand a problem through its flow and the
shape of the code.

**Cards.** Each item that needs a look is a card, in this order:

1. **Heading**: `### 2/5 · <kind>: <subject>`. The progress count shows what's left,
   and each skill defines its own kinds.
2. **Location**: a linked `path:line`, plus the login of whoever raised it.
3. **Evidence lines**, a few words each:
   - `✅ Verified: <how>` when the finding or claim holds, or `❌ Doesn't hold: <why>`
     when a reviewer's claim turns out wrong
   - `🔎 Sources: <what was checked>`
   - `⚠️ Unverified: <gap>`, only when a gap remains
4. **A picture**, when the code alone doesn't make the flow clear: a text call tree, a
   failure sequence, a state flow, or a case table.
5. **The change** as a `diff`, with enough context to place it in the flow. That means
   the whole function when it's small, or one block per file in call order, each headed
   by its path.
6. **One-line bullets** for the risks or assumptions that change the decision.

**Severity** for code findings:

- **Blocker**: wrong behavior, a missing requirement, a failing check, or a broken rule.
- **Should**: slop, scope creep, or a non-idiomatic pattern with a clear better form.
- **Optional**: a real improvement that can wait.

**Turns.**

- **Start with content**: the verdict, a table, a card, or the result.
- **Say it once**: show each piece of code, warning, and `FYI:` once per session.
- **Tests** as one-line cases: `file: scenario → expected ✅`.
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

- **Explicit**: a PR, branch, commit range, or set of files the user names.
- **Branch**: diff against the stack parent, or against the merge-base with the default
  branch.
- **PR**: the live PR diff.
- **Working changes**: staged, unstaged, and relevant untracked files.

Leave out generated, vendored, lockfile, and binary content unless it's central to the
change.

**Done when:** the target, base, head, and file list are known.

## 2. Compose the prompt once

Both reviewers get the same prompt, byte for byte. Write it to a file with the packet
(target, base and head, changed files, and the diff). Save the file under the repo root
so sandboxed reviewers can read it, and keep it out of the review target. Delete it and
the reviewer outputs when the loop ends.

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
Blocker: wrong behavior, data loss, security, a failing check, or a broken rule.
Should: slop, scope creep, a non-idiomatic pattern, or changed behavior without a test.
Optional: a real improvement that can wait.
Give a complete, independent review. If there are no findings, say so.
```

## 3. Review, verify, merge

1. **Run both reviewers in parallel.**
2. **Verify each finding** against the code with [grounding](references/grounding.md).
   Reviewers sometimes make false claims. Drop any finding that doesn't hold, and note
   the drop in one line.
3. **Merge.** Group findings by root cause, note who raised each (Claude, Codex, or
   both), and show severity disagreements as they are.

**Done when:** every finding is verified or dropped, and merged by root cause.

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

- **Verdict first**: **Clean** (plus "N optional" when any remain), or the round number
  and the counts by severity. A clean round ends with `**Next:** open-pr · done`.
- **Cards** for blockers, and for any fix that changes the flow or design.

## 5. Fix and re-review

When the user approves fixes:

1. Apply each fix on the branch that owns it, run the focused checks, and commit it as
   its own atomic commit.
2. Run the next round with the same reviewers on the updated diff. The prompt now lists
   the previous findings and their fixes.
3. Report only what is new or still open.

After three rounds without **Clean**, list what's still open and let the user decide.
Push only when the user asks.

**Done when:** a round is **Clean**, or the user has fixed, deferred, or dropped every
remaining finding.
