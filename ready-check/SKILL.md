---
name: ready-check
description: Checks whether a branch, PR, or stack is actually done (scope, idiom, standards, slop, tests, verification, and PR description) and gives a done or not-done verdict, then fixes what the user approves. Use when asked if work is done, production-ready, idiomatic, or clean, or whether anything is left to improve.
compatibility: Requires git. Uses gh for PR metadata when available.
---

# Ready check

Answer "is this done?" with a verdict the user can trust, and a short list of what
stands between the work and done. Work that is done gets a plain **Done**. A padded
list of nitpicks is not a verdict.

## 1. Pin the scope

- **Target**: the named PR or branch, the current branch's PR, or `stack`. For a stack,
  check every PR on its own and then the stack as a whole.
- **Diff**: `git diff <base>...<head>` against the PR base or the parent branch. Only
  this diff is in scope. Code outside it is context.
- **Intent**: the linked issue or spec, the PR description, and what the user agreed in
  the conversation, including any **Not in scope** section. Missing intent is itself a
  finding.

**Done when:** the diff, its base, and the intended outcome are known.

## 2. Check

Go through the whole diff for each lens. Each finding needs a concrete consequence or
a rule it breaks.

| Lens | Question |
|---|---|
| **Scope** | Does it do what was asked, completely? Is anything here that wasn't asked for, such as speculative options, abstractions for future needs, or extra endpoints? Scope creep is a finding to cut, even when the code is good. Code for an item that the spec, ticket, or PR lists under **Not in scope** is always a finding: cut it, or have the user move the item back into scope. |
| **Idiom** | Is each non-trivial pattern how the library's authors intend it? Ground it with the `grounding` skill, or [grounding](references/grounding.md) when that skill isn't installed. Repo precedent shows consistency, not idiom. |
| **Standards** | Does it follow the repo's conventions and the user's coding standards? Apply a repo convention-pass skill and `coding-standards` when they're installed. |
| **Slop** | See the slop list below, and apply the `simplify` criteria when that skill is installed. |
| **Tests** | Does each test protect behavior that could regress? Are the minimum needed tests there, and no more? |
| **Placement** | Does new code live in the module or domain that owns it? Before flagging code that looks odd, check git blame and its linked issue: it may be intentional. |
| **Verification** | Do the repo's focused typecheck, lint, and test commands pass for the touched packages? Run them. |
| **PR** | Do the title and description match the actual diff, and follow the repo's PR template? |

### Slop

- **Tests that assert nothing real**: they check a mock returns what it was told, restate
  the implementation, or cover the same path twice.
- **Wrappers that only forward**: a function or type that adds nothing over the thing it
  wraps.
- **Vague verb prefixes**: `prepare*`, `handle*`, `process*`, `do*`, where a precise verb
  exists.
- **Leftover narration**: comments that retell the change or restate the code.
- **Annotations the repo doesn't write**: explicit return types or redundant type
  annotations where the repo relies on inference.
- **Impossible-state guards**: defensive checks for states the types already rule out.
- **Dead code**: unused exports, parameters, branches, and leftover compatibility paths
  for code that never shipped.

Sort each finding into one of:

- **Blocker**: wrong behavior, missing scope, a failing check, or a broken rule.
- **Should**: slop, scope creep, or a non-idiomatic pattern with a clear better form.
- **Optional**: a real improvement that can wait.

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
✅ Confirmed: failing test at the PR head
🔎 Grounded: repo retry precedent `payments.ts`

```diff
-  if (existing?.finalized) return existing
+  const account = existing?.finalized ? existing : await db.finalize(id)
```

✅ typecheck · ✅ lint · ❌ tests 11/12

**Next:** fix all · fix blockers · discuss N
````

- **Verdict first.** Write **Done**, **Done with optional notes**, or **Not done: N
  blockers, N should**.
- **Findings table**: at most four columns, with a few words per cell.
- **Cards**: only for blockers, and for findings whose fix changes the flow or
  design. Each card has a status line, a grounding line, and the fix as a `diff`.
- **Checks line**: one line showing each check's result.
- **Done**: when the work is done, say so and list the scope checked. "Done" needs no
  findings.
- **Next**: end with one bold `Next:` line, which is the turn's only question.

## 4. Fix and re-check

When the user approves ("fix all", "fix blockers", "fix 1, 3"):

1. Apply the approved fixes on the branch that owns each change. In a stack, that is the
   lowest branch that owns the code.
2. Re-run the focused checks.
3. Re-check only what the fixes touched, and give a new verdict in the same format.
   Show only code the user hasn't seen yet.

Repeat until the verdict is **Done**, or the user stops. Commit and push only when the
user asks.

## Challenges

"Anything else?", "nothing left to improve?", and "is that really done?" each ask for a
re-check, not for new findings on demand.

- Re-check against the lenses. When the re-check finds nothing new, say "Nothing
  further" and name the scope checked.
- Change the verdict only on new evidence, and name it.

**Done when:** the verdict is **Done**, or every remaining finding is approved,
deferred, or dropped by the user.
