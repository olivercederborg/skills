---
name: verify-work
description: Checks whether a branch, PR, or stack is actually done and gives a done or not-done verdict, then fixes what the user approves. Use when asked if work is done, production-ready, idiomatic, or clean, or whether anything is left to improve.
compatibility: Requires git. Uses gh for PR metadata when available.
---

# Verify work

Answer "is this done?" with a verdict the user can trust, plus a short list of what
stands between the work and done. Done work gets a plain **Done**.

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

## 1. Pin the scope

- **Target**: the named PR or branch, the current branch's PR, or `stack`. For a stack,
  check every PR on its own, then the stack as a whole.
- **Diff**: `git diff <base>...<head>` against the PR base or the parent branch. Only
  this diff is in scope; code outside it is context.
- **Intent**: the linked issue or spec, the PR description, and what the user agreed in
  the conversation, including any **Not in scope** section. Missing intent is itself a
  finding.

**Done when:** the diff, its base, and the intended outcome are known.

## 2. Check

Apply every lens to the whole diff. Each finding needs a concrete consequence or a rule
it breaks.

| Lens | Question |
|---|---|
| **Scope** | Does it do everything asked, and nothing more? Speculative options, future-proof abstractions, and extra endpoints are scope creep (Should). Code for a **Not in scope** item is a Should: cut it, or the user moves it back into scope. |
| **Idiom** | Is each non-trivial pattern how the library's authors intend it? Ground it with [grounding](references/grounding.md). Repo precedent shows consistency, not idiom. |
| **Standards** | Does it follow the repo's conventions and the user's coding standards? Apply a repo convention-pass skill and `coding-standards` when installed. Names use the glossary's terms from `CONTEXT.md`; a term the glossary says to avoid is a Should. |
| **Slop** | Check the slop list below, and apply the `simplify` criteria when that skill is installed. |
| **Tests** | Does each test protect behavior that could regress, with the minimum needed and no more? Do tests go through the interface, rather than reaching past it (for example, by querying the database directly)? |
| **Placement** | Does new code live in the module or domain that owns it? Is a new port or abstraction backed by two real adapters? Use `codebase-design` when installed. Before flagging odd-looking code, check git blame and its linked issue: it may be intentional. |
| **Verification** | Run the repo's focused typecheck, lint, and test commands for the touched packages. |
| **PR** | Do the title and description match the diff and follow the repo's PR template? |

### Slop

- **Tests that assert nothing real**: they check a mock returns what it was told, restate
  the implementation, or cover the same path twice.
- **Wrappers that only forward**: a function or type that adds nothing over what it
  wraps.
- **Vague verb prefixes**: `prepare*`, `handle*`, `process*`, `do*`, where a precise verb
  exists.
- **Leftover narration**: comments that retell the change or restate the code.
- **Annotations the repo doesn't write**: explicit return types or redundant type
  annotations where the repo relies on inference.
- **Impossible-state guards**: checks for states the types already rule out.
- **Dead code**: unused exports, parameters, branches, and leftover compatibility paths
  for code that never shipped.
- **Leftover debug output**: tagged or untagged debug logs.
- **Heuristics** (Optional unless they cause harm):
  - **Mysterious names**: a name that doesn't say what it holds or does.
  - **Data clumps**: the same fields keep travelling together and want to be one type.
  - **Shotgun surgery**: one logical change forces edits across many files.

**Done when:** every lens has been applied to the whole diff and every check has run.

## 3. Verdict

Lead with the verdict, then the findings:

````markdown
**Not done: 1 blocker, 2 should.**

| # | Where | Finding | Kind |
|---|-------|---------|------|
| 1 | `export.ts:12` | Retry skips publish | Blocker |
| 2 | `export.test.ts:30` | Asserts the mock's own return | Should |
| 3 | `export.ts:4` | `prepareRows` only forwards | Should |

### 1/3 · Blocker: retry skips publish
[`src/export.ts:12`](link)
✅ Verified: failing test at the PR head
🔎 Sources: repo retry precedent `payments.ts`

```diff
-  if (existing?.finalized) return existing
+  const account = existing?.finalized ? existing : await db.finalize(id)
```

✅ typecheck · ✅ lint · ❌ tests 11/12

**Next:** fix all · fix blockers · discuss N
````

- **Verdict first**: **Done** (no findings), **Done with optional notes** (Optional
  findings only), or **Not done: N blockers, N should**.
- **Cards** only for blockers, and for findings whose fix changes the flow or design.
- **Checks line**: one line with each check's result.
- **When done**: list the scope checked, and end with `**Next:** review-loop · open-pr`.

## 4. Fix and re-check

When the user approves ("fix all", "fix blockers", "fix 1, 3"):

1. Apply each approved fix on the branch that owns it (in a stack, the lowest one), and
   commit it as its own atomic commit.
2. Re-run the focused checks.
3. Re-check what the fixes touched, and give a new verdict in the same format.

Repeat until **Done**, or until the user stops. Push only when the user asks.

"Anything else?", "nothing left?", and "is that really done?" ask for a re-check against
the lenses. When it finds nothing new, say "Nothing further" and name the scope checked.
Change the verdict only on new evidence, and name that evidence.

**Done when:** the verdict is **Done**, or the user has approved, deferred, or dropped
every remaining finding.
