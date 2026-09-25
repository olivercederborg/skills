---
name: scope-grill
description: Stress-tests a plan by asking only the decisions that matter, showing each option's code impact and scope, and ending with a "Not in scope" list. Use when the user wants to be grilled on a plan, to decide an approach before building, or to scope a spec, ticket, or PR.
---

# Scope grill

Decide a plan by its code impact, with scope in the open. Plans widen one reasonable
decision at a time, so every option carries a scope label, and the default is the
smallest option that meets the goal.

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

Card kind here: **Question**, one per decision.

## 1. Set the scope line

Before asking anything, read:

- the request, the linked issue, and the code involved;
- the domain docs: `CONTEXT.md` (or the context `CONTEXT-MAP.md` points to) and the
  ADRs for the area;
- when starting from an existing spec, ticket, or PR, that artifact, and for a PR its
  diff against the base.

Then state the baseline and have the user confirm it:

````markdown
**Goal:** export transactions as CSV for one date range
**Must have (MVP):** CSV with 4 columns · inclusive date filter · one download button
**Not in scope:** JSON or other formats · scheduling · column picker
**Size now:** ~4 files · 1 PR

**Next:** confirm · edit
````

**Must have** is what the goal needs, and everything else goes under **Not in scope**.
Below the block, give the one-line reasons that shaped it, such as a dependency or a
blocker found in the code.

## 2. Ask only the questions that matter

- **MVP decisions only.** Ask about decisions that change the MVP's code, and park
  everything else in **Not in scope**, one line each.
- **Question creep is scope creep.** When a question exists only because an earlier
  answer widened the scope, say so.
- **Work the design tree.** A round asks only the **frontier**, meaning decisions whose
  prerequisites are settled. A question that depends on one still open waits for a
  later round. Recompute the frontier after each answer.
- **Rounds** have two or three frontier questions, highest impact first. Each has a
  recommended option, and one answer can settle the round: `accept all recs` or
  `2B, rest recs`.
- **Facts are yours; decisions are the user's.** Look up what the code, config, or
  tools can answer, using sub-agents in parallel if needed. While a lookup runs, only
  the questions that depend on it wait.

## 3. Show each option's impact

Each question lists its options side by side. For each option show:

- **Change**: the smallest view that makes the impact clear, as a `diff` of the call
  tree, the file tree, or the code shape. Use a real excerpt from the code when one
  exists, trimmed to the lines that show the impact.
- **Scope**: one of three labels.
  - `= Same scope`
  - `− Narrower: <what it drops>`
  - `+ Wider: <what it adds>`: a new concept, module, config, migration, public API,
    test surface, or a seam with only one real implementation. A seam is real when two
    implementations need it now. Use `codebase-design` for seam questions when it's
    installed.
- **Size**: files touched, counted from a codebase search. Mark estimates with `≈`.
- **Undo**: two-way door (easy to change later) or one-way door (hard to reverse,
  such as a migration or a public API).
- **ADR conflicts**: say so on any option that contradicts an existing ADR.

## Example question (illustrative: match the shape, not the content)

````markdown
**Scope:** MVP + 0 · ~4 files

### 2/5 · Question: where does the date filter run?

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
🔎 Sources: `export.ts` precedent · largest export in fixtures is 2k rows

**Next:** A · B · discuss
````

- **The recommendation** is the smallest option that meets the must-haves. Ground it
  with [grounding](references/grounding.md) and show its evidence lines. Also ground a
  losing option when its idiom decides the question. When a wider option wins on
  merit, say what it adds and why it's worth it now.
- **"Becomes worth it when"**: every wider option that loses gets one line naming the
  signal that would justify it later, and then moves to **Not in scope**.
- **Scope meter**: open every turn with `Scope: MVP + N · ~files`. N counts the
  widenings the user accepted.

### Domain docs as you go

- **Glossary conflicts**: when the user's word conflicts with the glossary, or is fuzzy
  (for example, "account" could mean Customer or User), ask which they mean.
- **Terms**: when an answer settles a domain term, show it on that card as a one-line
  addition to `CONTEXT.md`, and write it when the user accepts the round. A term never
  gets its own question. `CONTEXT.md` stays a glossary, with no implementation details.
- **ADRs**: offer one, as `+ ADR` in that turn's `Next:`, only when a decision passes all
  three tests:
  1. It's hard to reverse (the winning option is a one-way door).
  2. It's the result of a real trade-off (a losing option has a "becomes worth it when"
     line).
  3. A future reader would be surprised without the reason.
- **File formats**: use `domain-modeling` for file formats and for repos with several
  contexts, when it's installed. Create files only when there is something to write.

## 4. Watch the whole plan

- **A wider pick** changes the meter in the same turn and shows any new questions it
  creates.
- **A second PR**: when the size passes what one reviewable PR can hold, say so, and
  propose the split, using `scope-pull-request` if it's installed.
  - Split into vertical slices, each shipping a working part of the outcome.
  - A wide rename or contract change goes expand → migrate → contract.
- **Challenges**: "are you sure?" asks for a re-check. Change a recommendation only on
  new evidence, and name that evidence.

## 5. Summary

When the frontier is empty, finish with:

- **Decisions**: one line each, with its scope label.
- **Resulting shape**: one combined `diff` of the call tree or the file tree.
- **Scope**: the final meter against the baseline, and each widening with the answer
  that caused it.
- **Not in scope**: the parked questions, the losing options, and the baseline's
  exclusions, in the format below.
- **Size**: the estimated PR count and size.
- **Test seams**: where the tests hook in. Use the highest seam that covers the
  behavior, ideally one.
- **Docs**: `+N terms · N ADRs` written, or none.

End with `**Next:** build · add Not in scope to <spec | ticket | PR> · done`. Offer
`build` only after the user confirms the summary.

**Done when:** no decision is left silently assumed, the user explicitly chose every
widening, and the Not in scope list holds everything left out.

## Not in scope

Each item gets one line: what is out, why the goal doesn't need it, and the signal that
would bring it back.

```markdown
## Not in scope

- **JSON export**: the request is CSV only. Revisit when a consumer needs JSON.
- **Per-company time zones**: transaction dates carry no time. Revisit when dates
  include times or month boundaries are reported wrong.
```

When the user asks to add it to an artifact:

1. **Show the exact section** and its target: the spec file, the ticket, or the PR.
2. **Write it once the user approves.**
   - **Spec file:** edit the file.
   - **Ticket:** use the repo's issue-tracker tool.
   - **PR:** `gh pr view N --json body`, then `gh pr edit N --body-file <file>`.
3. **Replace any existing "Not in scope" section,** and leave the rest of the artifact
   as it is.
4. **Confirm the change is visible,** and link it.
