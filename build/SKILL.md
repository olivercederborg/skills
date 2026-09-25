---
name: build
description: Implements an agreed plan in small, verified steps, stays inside the plan's scope, and shows the resulting code. Use when asked to implement, build, or code up a plan, spec, or ticket.
compatibility: Requires git.
---

# Build

Implement exactly the agreed plan: ground each API, verify each step, and raise anything
outside the plan as a Decision card.

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

Card kinds here: **Decision** (a choice the plan didn't cover) and **Deviation** (the
build had to differ from the plan).

## 1. Load the plan

- **Plan**: the decisions, test seams, and **Not in scope** list from `scope-grill`,
  taken from this conversation or the ticket, plus the linked issue or spec.
- **Domain terms**: read `CONTEXT.md` so names use the glossary's terms.
- **Standards**: the repo's guidance and conventions, and `coding-standards` when it's
  installed.
- **Branch**: confirm the current branch owns the change. In a stack, use the lowest
  branch that owns each change. Keep any uncommitted work out of the build.
- **Checks**: find the repo's focused typecheck, lint, and test commands.

When there is no agreed plan and the work isn't trivial, offer `scope-grill` first.

**Done when:** the decisions, the Not in scope list, the branch, and the check commands
are known.

## 2. Build in steps

Split the plan into small vertical slices, each a thin working path through the code,
and build one slice at a time:

1. **Ground** each non-trivial API call or pattern with
   [grounding](references/grounding.md) before writing it.
2. **Red.** Where behavior can regress, write the fewest tests that cover the step's
   distinct cases, at the plan's test seam, each asserting real behavior. Watch each
   fail for the right reason. Use `tdd` when it's installed.
3. **Green.** Write the smallest code that passes, using the glossary's names and the
   plan's decisions. Refactoring comes later, in `verify-work`.
4. **Check.** Run the focused checks for the touched files. A failing check stops the
   step until it's fixed.
5. **Run it.** Exercise the behavior itself: run the code, call the function, or use
   the UI.
6. **Commit** the step as one atomic commit with the repo's tooling (for example
   `gt modify -c` in a Graphite stack).

When a check fails and the cause isn't clear, use `diagnosing-bugs` when it's
installed: form a hypothesis you can disprove, then test it. Tag debug logs with a
unique prefix (`[DEBUG-a4f2]`), and remove them before the step's commit.

Run the full test suite once at the end.

## 3. Stay in scope

- **Needed but not planned**: show a **Decision** card. Give each option its scope
  label (`= Same scope`, `− Narrower`, or `+ Wider: <what it adds>`), and recommend the
  smallest option that works.
- **Listed as out**: items under **Not in scope** stay out, however cheap. If the build
  can't work without one, raise a Decision card.
- **Forced deviations**: when the code must differ from a decision (for example, an API
  doesn't support the planned shape), show a **Deviation** card with the reason and its
  sources.
- **Other decisions keep going.** A pending decision pauses only the steps that depend
  on it.

## 4. Report

````markdown
**Built: 3 steps, 3 commits.** ✅ typecheck · ✅ tests 14/14 · ✅ ran the export on sample data · ⚠️ lint not run (no config)

```diff
 exportTransactionsCsv
   toRows
-    [date, description, amount]
+    [date, description, amount, currency]
```

Tests added:
- `export.test.ts`: from and to dates are included → rows kept ✅
- `export.test.ts`: currency column → `EUR` in every row ✅

Deviations: none · Not in scope: untouched

**Next:** verify-work · push · open-pr
````

- **Code the user hasn't seen**, as the change outline: a call tree, the file tree, or
  key hunks, in the order that tells the story.
- **Checks**: mark a check that couldn't run as `⚠️ <check> not run (<why>)`.
- **Deviations and scope**: list any deviation, and confirm that Not in scope was left
  alone.

Push or submit only when the user asks.

**Done when:** every decision in the plan is implemented, all checks pass, the behavior
was run, nothing outside the plan was built, and the user has seen the code.
