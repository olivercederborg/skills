---
name: scope-grill
description: Stress-tests a plan or design by asking only the decisions that matter, showing what each option changes in the code and whether it widens the scope, and defaulting to the smallest option that meets the goal. Produces a "Not in scope" list for a spec, ticket, or PR description. Use when the user wants to be grilled on a plan, to decide an approach before building, or to scope an existing spec, ticket, or PR.
---

# Scope grill

Help the user decide a plan by seeing each option's consequences in the code, with the
scope kept in the open. AI-driven plans tend to widen scope one reasonable-sounding
decision at a time, until an MVP becomes a large, slow, over-built PR. Every question
here shows whether an option keeps the scope, narrows it, or widens it, and the default
is always the smallest option that meets the goal.

## 1. Set the scope line

Before asking anything, read the request, the linked issue, and the code involved. When
the starting point is an existing spec, ticket, or PR, read that too, plus the PR's diff
against its base. Mark anything in it that goes beyond the goal as a candidate for
**Not now**. Then state the baseline in one short block and have the user confirm it:

````markdown
**Goal:** export transactions as CSV for one date range
**Must have (MVP):** CSV with 4 columns · inclusive date filter · one download button
**Not now:** JSON or other formats · scheduling · column picker
**Size now:** ~4 files · 1 PR

**Next:** confirm · edit
````

The line is what the goal needs, not what would be nice. Anything that doesn't serve the
goal goes under **Not now**. Below the block, give at most three one-line reasons, such
as a dependency or a blocker found in the code.

## 2. Ask only the questions that matter

- **Only decisions that change the MVP's code.** Park other questions in the **Not in
  scope** list, one line each.
- **Question creep is scope creep.** When a question only exists because an earlier
  answer widened the scope, say so.
- **Work the design tree.** Each decision opens the decisions that depend on it. A
  round asks only the **frontier**: decisions whose prerequisites are settled. A
  question that depends on another question still open this round waits for a later
  round. After each answer, recompute the frontier.
- **Ask in rounds** of two or three frontier questions, highest impact first. Each has a
  recommended option, and one answer can settle the round: `accept all recs` or
  `2B, rest recs`.
- **Facts are yours; decisions are the user's.** Look up anything the code, config,
  or tools can answer yourself, if needed with sub-agents in parallel. Don't ask the
  user for it. While a lookup runs, only the questions that depend on it wait; ask the
  rest now.

## 3. Show each option's impact

Each question lists its options side by side. For each option show:

- **Change**: the smallest view that makes the impact clear, as a `diff` of the call
  tree, the file tree, or the code shape. Use a real excerpt from the code when it
  exists, and keep it to about six lines.
- **Scope**: one of three labels.
  - `= Same scope`
  - `− Narrower: <what it drops>`
  - `+ Wider: <what it adds>`, where the addition is a new concept, module, config,
    migration, public API, or test surface.
- **Size**: files touched, with `≈` for an estimate. Base the count on a search of the
  codebase, not a guess.
- **Undo**: two-way door (easy to change later) or one-way door (hard to reverse,
  such as a migration or a public API).

````markdown
**Scope:** MVP + 0 · ~4 files

### Q2/5 · Where does the date filter run?

**A · In the export function** (recommended) · `= Same scope` · 1 file · two-way
```diff
 exportTransactionsCsv
+  transactions.filter(inRange(from, to))
   toCsv
```

**B · In the database query** · `+ Wider: new repository method and index` · ≈3 files and a migration · one-way
```diff
 exportTransactionsCsv
-  transactions
+  transactionsRepository.findInRange(from, to)
```

**Recommend A:** exports are small enough to filter in memory. **B becomes worth it
when** an export exceeds ~10k rows.
🔎 Grounded: `export.ts` precedent · largest export in fixtures is 2k rows

**Next:** A · B · discuss
````

- **Grounded recommendation**: before recommending, ground it by following
  [grounding](references/grounding.md): library docs and source, repo precedent, and
  the repo's rules. Show `🔎 Grounded: <sources>` under the recommendation, plus
  `⚠️ Not grounded: <what>` for any gap. Ground a losing option too when its idiom is
  what decides the question.
- **The recommendation** is the smallest option that meets the must-haves. When a wider
  option wins on merit, say plainly what it adds and why that is worth it now.
- **"Becomes worth it when"**: every wider option that loses gets one line naming the
  concrete signal that would justify it later. It then goes to the **Not in scope** list.
- **Scope meter**: open every turn with `Scope: MVP + N · ~files`, and show a change in
  the meter the moment an answer widens the scope.

## 4. Watch the whole plan

- **A wider pick** gets the meter change shown in the same turn, together with any
  new questions it creates.
- **A second PR**: when the size passes what one reviewable PR can hold, say so. Propose
  the split using `scope-pull-request` if it's installed.
- **Challenges**: "are you sure?" asks for a re-check. Change a recommendation only on
  new evidence, and name that evidence.

## 5. Summary

When every question is decided, finish with:

- **Decisions**: one line each, with the scope label.
- **Resulting shape**: one combined `diff` of the call tree or the file tree.
- **Scope**: the final meter against the baseline, and every widening with the answer
  that caused it.
- **Not in scope**: the parked questions, the options that lost, and everything under
  **Not now**, in the format below.
- **Size**: the estimated PR count and size.

End with `**Next:** add Not in scope to <spec | ticket | PR> · done`. Offer an ADR only
when the user wants one.

## Not in scope

Each item gets one line: what is out, why the goal doesn't need it, and the signal that
would bring it back.

```markdown
## Not in scope

- **JSON export**: the request is CSV only. Revisit when a consumer needs JSON.
- **Per-company time zones**: transaction dates carry no time. Revisit when dates
  include times or month boundaries are reported wrong.
- **Job runner**: an external scheduler runs the command. Revisit when a second
  scheduled job needs one.
```

When the user asks to add it to an artifact:

1. **Show the exact section first,** with its target: the spec file, the ticket, or the
   PR.
2. **Write it once the user approves.**
   - **Spec file:** edit the file.
   - **Ticket:** use the repo's issue-tracker tool.
   - **PR:** `gh pr view N --json body`, then `gh pr edit N --body-file <file>`.
3. **Replace an existing "Not in scope" section** rather than adding a second one, and
   leave the rest of the artifact unchanged.
4. **Confirm the change is visible,** and link it.

**Done when:** the frontier is empty, with no decision left silently assumed. Every
widening must have been explicitly chosen, and the Not in scope list must hold
everything left out, in the artifact the user chose. Build nothing until the user
confirms the shared understanding.
