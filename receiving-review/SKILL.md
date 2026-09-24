---
name: receiving-review
description: "Handles review comments on your own PR or stack: verifies each claim, then fixes, commits, pushes, replies, and resolves. Use when reviewers or bots (cubic, CodeRabbit) commented on your PR. For someone else's PR use review-teammate-pr; for your own unreviewed diff use code-review."
---

# Receiving review

Each comment is a claim to verify, not an order. Recommend a call, fix what the user
accepts, and close the loop: push, reply, resolve. The loop is closed when every item
has its reply posted and its thread in the agreed state.

Read these shared references before the first turn:

- [Chat format](../pr-review-format/references/chat-format.md): the
  card layout and the rules for every turn.
- [Grounding](../pr-review-format/references/grounding.md): the
  research behind every fix direction and every decline.

## Example turns

Triage:

````markdown
| # | Who · where | Claim | Call |
|---|-------------|-------|------|
| 1 | cubic · `upload.ts:31` | Retry duplicates receipt | Fix |
| 2 | sam · `upload.ts:12` | Inline `toKey` helper | Fix |
| 3 | CodeRabbit · body | Log file size | Decline: PII policy |

### 1/3 · Fix: upload retry creates a duplicate receipt
cubic · [`receipts/upload.ts:31`](link)
✅ Confirmed: a failing test uploads the same file twice
🔎 Grounded: `upsert` precedent in `card-top-up.repository.ts` · Prisma compound-unique docs

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
> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Fixed. Uploads now upsert on `(transactionId, key)`, so a retried upload reuses the
> receipt.
>
> <sub>Fixed in: `{sha}`</sub>

**3** · CodeRabbit · PR comment
> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Keeping file metadata out of logs. The logging policy treats uploaded file details
> as PII.
>
> <sub>Grounded in: `docs/conventions/logging.md`</sub>

**Next:** commit, push, reply, resolve · edit N · commit only
````

## 1. Fetch

- Resolve the scope. It is an explicit PR number or URL, `stack` (every open PR in the
  current stack, for example a Graphite stack), or the current branch's PR.
- Read the repository's version-control and pull-request guidance once.
- Fetch with the [GitHub commands](../pr-review-format/references/github.md):
  unresolved review threads, review bodies, PR conversation comments, and CI. Some bots
  (CodeRabbit) post findings in review bodies, and a failing check often explains a
  comment.
- Keep threads that still need an answer: unresolved threads where the latest comment
  is someone else's. A thread whose latest comment is our agent reply is already
  answered. Also keep real findings from review bodies. Praise and bot walkthroughs are
  context only.
- On "new round of comments", list only the items that are new or changed since the
  last round.

**Done when:** every open thread and review-body finding has a number, or the fetch
shows none remain.

## 2. Triage

Give each item a number and keep it for the whole session. The user refers to items by
number ("don't address 1", "do 2-3").

Verify each claim against the PR head. In a stack, check whether another PR already
handles it. Then give each item one call:

- **Fix**: the smallest fix that fully solves it.
- **Decline**: the claim is wrong, or the change isn't worth the risk. Give the
  decisive reason.
- **Defer**: valid but out of scope. Propose a follow-up issue in the repo's tracker.
- **No change**: already handled. Resolve the thread.

Show the triage table. With more than five items, group the ones that share a root
cause, code path, or fix. Add a Group column (`A — Retry`, or `—` for an item that
stands alone) and keep each group's rows together. There is still one row per thread.

Below the table, show cards for:

- the highest-value item, and
- every other fix that changes the flow or design, such as control flow, a module
  boundary, a public API, or data shape.

Small local fixes, such as a rename, an import, or a guard, show their code in the
report after fixing. A card quotes the reviewer's comment with its link. Strip bot
boilerplate and agent prompts from the quote.

When every call is clear, end with `**Next:** all as recommended · discuss N`, so that
one answer settles the round. Otherwise, go through the items that need a decision one
card at a time. The user can also answer in a batch ("1 fix, 2 decline, 4 defer").

**Done when:** every item has a call the user accepted, and every flow-changing fix
has been shown as a card.

## 3. Fix

"yes", "go for it", "fix it", or "do it" after a proposal authorizes that fix. A batch
answer authorizes each item it names.

- Start from a clean view of the working tree, and keep unrelated changes out of the
  fix. Fix on the lowest stack branch that owns the code, then restack.
- Stay within the accepted scope, and run the repo's focused checks for the touched
  files.
- Report in the "After fixing" shape above. Include code the user hasn't seen yet,
  such as extra files or small fixes, and list tests as one-line cases.

**Done when:** every accepted fix is applied, its checks pass, and the user has seen
all of its code.

## 4. Deliver, reply, resolve

As soon as the fixes are done, draft the replies. They follow the
[reply style](references/reply-style.md), and each starts with the
[agent disclosure](../pr-review-format/references/disclosure.md).
Offer the rest of the loop as one `Next:`: commit, push, reply, resolve. One "yes"
covers all of it.

- Push only when the user says so, either through that `Next:` or in their own words.
  When they ask for part of the loop ("commit and push", "just reply"), do exactly
  that part.
- When the user says they pushed, confirm the fix commit is on the remote PR head,
  then continue with the replies.
- Approving the displayed drafts ("looks good", "post them", "yes") means posting them.
  If the user edits a draft, show the revised version.

What each call gets:

- **Fix**: a reply after the commit is on the remote PR, with a `Fixed in` footer. Then
  resolve the thread.
- **Decline**: a reply with the decisive reason, bots included. Resolve bot threads,
  and leave human threads for the reviewer to resolve.
- **Defer**: propose the follow-up issue (title and scope). Create it once approved, then
  reply with the link and leave the thread open.
- **No change**: resolve. Add a reply when the reviewer needs the context.

Re-fetch each thread right before posting to it. If a new reply has arrived, show it
first. After posting, confirm the reply is visible. After an unclear write, read the
thread before retrying, so each reply lands exactly once.

**Done when:** every item has its reply posted and visible and its thread in the
agreed state, or the blocker is named.

## 5. Finish

End with a table of each item's outcome, commit, reply, and thread state. Then list
what's still open: unpushed commits, pending follow-ups, and threads waiting on a
reviewer.
