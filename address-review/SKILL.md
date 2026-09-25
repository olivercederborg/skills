---
name: address-review
description: "Handles review comments on the user's own PR or stack: verifies each claim, fixes, replies, and resolves threads. Use when reviewers or bots have commented on the PR, including a new round of comments."
compatibility: Requires git, gh (authenticated), and jq.
---

# Address review

Each comment is a claim to verify, not an order. Recommend a call, fix what the user
accepts, and close the loop: push, reply, resolve. The loop is closed when every item
has its reply posted and its thread in the agreed state.

Before proposing any fix direction or technical decline, ground it by following
[grounding](references/grounding.md).

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

Card kinds here: **Fix**, **Decline**, **Defer**, **No change**.

## Example turns

````markdown
| # | Who · where | Claim | Call |
|---|-------------|-------|------|
| 1 | cubic · `upload.ts:31` | Retry duplicates receipt | Fix |
| 2 | sam · `upload.ts:12` | Inline `toKey` helper | Fix |
| 3 | CodeRabbit · review | Log file size | Decline: PII policy |

### 1/3 · Fix: upload retry creates a duplicate receipt
cubic · [`receipts/upload.ts:31`](link)
✅ Verified: failing test uploads twice
🔎 Sources: `upsert` precedent in `payments.repository.ts` · Prisma compound-unique docs

```text
attempt 1: storage.put ✓ → receipts.create ✓ → respond ✗ timeout
attempt 2: storage.put ✓ → receipts.create ✓   ← second receipt row
```

```diff
 // receipts/upload.ts
 export const uploadReceipt = (input: UploadInput) =>
   Effect.gen(function* () {
     const key = yield* storage.put(input.file)
-    return yield* receipts.create({ transactionId: input.transactionId, key })
+    return yield* receipts.upsert({
+      where: { transactionId_key: { transactionId: input.transactionId, key } },
+      create: { transactionId: input.transactionId, key },
+      update: {},
+    })
   })
```

- ⚠️ Needs a unique index on `(transactionId, key)`, which adds a migration

**Next:** all as recommended · discuss N
````

After fixing:

````markdown
### Fixed locally · ✅ tests 4/4 · ✅ lint · ✅ typecheck

```diff
 // receipts/upload.ts
-const toKey = (file: File) => file.name
-const key = yield* storage.put(input.file, toKey(input.file))
+const key = yield* storage.put(input.file, input.file.name)
```

Tests added:
- `upload.test.ts`: same file uploaded twice → one receipt ✅

**1** · cubic · reply + resolve
> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Fixed. Uploads now upsert on `(transactionId, key)`, so a retried upload reuses the
> receipt.
>
> <sub>Fixed in: `{sha}`</sub>

**3** · CodeRabbit · PR comment
> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Keeping file metadata out of logs. The logging policy treats uploaded file details
> as PII.
>
> <sub>Grounded in: `docs/conventions/logging.md`</sub>

**Next:** commit, push, reply, resolve · edit N · commit only
````

## 1. Fetch

- Resolve the scope: an explicit PR number or URL, `stack` (every open PR in the
  current stack), or the current branch's PR.
- Read the repository's version-control and pull-request guidance once.
- Fetch threads, review bodies, conversation comments, and CI with the
  [GitHub commands](references/github.md). Some bots post findings in review bodies,
  and a failing check often explains a comment.
- **Open items**: unresolved threads where the latest comment is someone else's, and
  review-body findings that none of our PR comments quote yet. Praise and bot
  walkthroughs are context only.
- **Answered but open**: unresolved threads where our agent reply is the latest
  comment. The resolve defaults in step 4 apply to them.
- On a new round, continue the numbering from the previous round and list only the
  new or changed items.

**Done when:** every open item has a number, and every answered-but-open thread is
known.

## 2. Triage

The user refers to items by number ("don't address 1", "do 2-3").

Verify each claim against the PR head. In a stack, check whether another PR already
handles it. Then give each item one call:

- **Fix**: the smallest fix that fully solves it.
- **Decline**: the claim is wrong, or the change isn't worth the risk.
- **Defer**: valid but out of scope. Name the follow-up issue's title and scope.
- **No change**: already handled.

Show the triage table. With more than five items, prefix related items with a group
letter in the `#` cell (`A1`, `A2`) and keep each group's rows together. Answered but
open threads get one line under the table, for example:
`Answered, still open: 4, 7 → resolve with this round`.

Below the table, show cards for:

- the highest-value item, and
- every other fix that changes the flow or design, such as control flow, a module
  boundary, a public API, or data shape.

Small local fixes, such as a rename, an import, or a guard, show their code in the
report after fixing. A card quotes the reviewer's comment with its link, without bot
boilerplate or agent prompts.

When every call is clear, end with `**Next:** all as recommended · discuss N`. One
answer settles the round, including the Defer issues as named. Otherwise, go through
the items that need a decision one card at a time. The user can also answer in a batch
("1 fix, 2 decline, 4 defer").

**Done when:** every item has a call the user accepted, and every flow-changing fix
has been shown as a card.

## 3. Fix

An affirmative reply to a proposal authorizes it. A batch answer authorizes each item
it names.

- Start from a clean view of the working tree, and keep unrelated changes out of the
  fix. Fix on the lowest stack branch that owns the code, then restack.
- Stay within the accepted scope, and run the repo's focused checks for the touched
  files.
- Report in the "After fixing" shape, with the code the user hasn't seen yet.

**Done when:** every accepted fix is applied, its checks pass, and the user has seen
all of its code.

## 4. Deliver, reply, resolve

As soon as the fixes are done, draft the replies in the
[reply style](references/reply-style.md). Each starts with the
[agent disclosure](references/disclosure.md). Offer the rest of the loop as one
`Next:`: commit, push, reply, resolve, plus "create N issues" when there are Defers.
One "yes" covers all of it.

- Push only when the user says so, through that `Next:` or in their own words. When
  they ask for part of the loop ("commit and push", "just reply"), do exactly that
  part.
- When the user says they pushed, confirm the fix commit is on the remote PR head,
  then continue with the replies.
- Approving the displayed drafts means posting them. If the user edits a draft, show
  the revised version.

Resolve defaults:

- **Fix**: reply once the commit is on the remote PR, with a `Fixed in` footer.
  Resolve.
- **Decline**: reply with the decisive reason. Resolve bot threads, and leave human
  threads for the reviewer.
- **Defer**: create the issue, reply with its link, and leave the thread open.
- **No change**: resolve bot threads. On a human thread, reply with where it's handled
  and leave it for the reviewer.
- **Answered but open**: the same defaults, with no new reply.

Re-fetch each thread right before posting to it. If a new reply has arrived, show it
first. After posting, confirm the reply is visible.

**Done when:** every item has its reply posted and visible and its thread in the
agreed state, or the blocker is named.

## 5. Finish

End with a table: `# · Outcome · Commit · Reply / thread`. Then list what's still
open: unpushed commits, pending follow-ups, and threads waiting on a reviewer.

**Done when:** every item has a row, and everything still open is listed.
