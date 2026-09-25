---
name: build
description: Implements an agreed plan in small, verified steps (grounded APIs, the minimum tests, focused checks after each step), stays inside the plan's scope, and shows the resulting code. Use when asked to implement, build, or code up a plan, spec, or ticket.
compatibility: Requires git.
---

# Build

Implement exactly what was agreed. Every API or pattern gets grounded, every step gets
verified, and anything outside the plan is raised as a question instead of being
built quietly.

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

Card kinds here: **Decision** (a choice the plan didn't cover) and **Deviation** (the
build had to differ from the plan).

## 1. Load the plan

- **Plan**: the decisions and the **Not in scope** list from `scope-grill`, taken from
  this conversation or the ticket, plus the linked issue or spec.
- **Standards**: the repo's guidance and conventions, and `coding-standards` when it's
  installed.
- **Branch**: confirm the current branch is the one that owns the change. In a stack,
  use the lowest branch that owns each change. Note any uncommitted work, and keep it
  out of the build.
- **Checks**: find the repo's focused typecheck, lint, and test commands.

When there is no agreed plan and the work isn't trivial, offer `scope-grill` first.

**Done when:** the decisions, the Not in scope list, the branch, and the check commands
are known.

## 2. Build in steps

Split the plan into small vertical steps. After each step, the code builds and the tests
pass. For each step:

1. **Ground it.** Before writing a non-trivial API call or pattern, ground it by
   following [grounding](references/grounding.md). Label a combination you haven't
   verified as `Proposal` until a check confirms it.
2. **Test first where behavior can regress.** Write the fewest tests that cover the
   step's distinct cases, at the seams the plan agreed on. Don't write tautological
   tests.
3. **Implement the smallest code that makes the step work.** Follow the plan's decisions
   and the standards.
4. **Run the focused checks** for the touched files. A failing check stops the step until
   it's fixed.
5. **Verify the behavior itself**, by running the code, calling the function, or
   exercising the UI. A passing typecheck alone isn't enough.

Run the full test suite once at the end.

## 3. Stay in scope

- **Needed but not planned.** When the build needs something the plan didn't decide,
  stop and show a **Decision** card. Give each option its scope label (`= Same scope`,
  `− Narrower`, or `+ Wider: <what it adds>`) and recommend the smallest option that
  works.
- **Listed as out.** Anything under **Not in scope** stays out, even when it's tempting
  or cheap. If the build can't work without it, raise a Decision card.
- **Forced deviations.** When the code must differ from a decision (for example, an API
  doesn't support the planned shape), show a **Deviation** card with the reason and its
  sources.
- **Other decisions keep going.** A pending decision pauses only the steps that depend
  on it.

## 4. Report

````markdown
**Built: 3 steps.** ✅ typecheck · ✅ lint · ✅ tests 14/14 · ✅ ran the export on sample data

```diff
 exportTransactionsCsv
   toRows
-    [date, description, amount]
+    [date, description, amount, currency]
```

Tests added:
- `export.test.ts`: from and to dates are included → rows kept ✅
- `export.test.ts`: currency column → `EUR` in every row ✅

⚠️ Deviation: none · Not in scope: untouched

**Next:** ready-check · commit · review-loop
````

- **Code the user hasn't seen**, as the change outline: a call tree, the file tree, or
  key hunks, in the order that tells the story.
- **Tests** as one-line cases.
- **Deviations and scope**: any deviation, and confirmation that everything under Not in
  scope was left alone.

Commit and push only when the user asks. Commit one step per commit when that makes the
history easier to review.

**Done when:** every decision in the plan is implemented, all checks pass, the behavior
was run, nothing outside the plan was built, and the user has seen the code.
