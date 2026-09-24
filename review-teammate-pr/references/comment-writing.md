# Comment style

The author, and often their agent, reads the comment. Both should know what to do
after one read.

- **One concern per comment,** with one bounded request.
- **Match the wording to the user's decision:**
  - **lock**: state the condition and the consequence, then the fix: "If X, then Y.
    Could we Z?"
  - **optional**: prefix `Non-blocking:`.
  - **question**: ask it, or frame it as something for the author to verify.
- **Keep it short.** Two to four sentences, holding only what the author needs to act.
- **Add a snippet only when the fix would otherwise be ambiguous.** Use a `diff`, or a
  sketch labeled `Target shape`, with real symbols and installed APIs.
- **Ask for a test only when one is needed** to lock in the behavior.
- **Keep the scope tight.** Name adjacent work as a follow-up.

## Examples

lock, small fix:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Could we keep the empty value controlled?
>
> ```diff
> - value={displayedCategoryId ?? undefined}
> + value={optimisticCategoryId ?? ""}
> ```
>
> The Combobox ignores a reset to `undefined`, so after a failed first selection the
> old value stays displayed.

lock, less obvious:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> This query has no `companyId` filter, so an export returns every company's
> transactions in the date range. Could we scope it with `CurrentCompany`, like
> `transactions.repository.ts` does? A test with two companies would lock this in.

question:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Question, non-blocking: the CSV columns are now built from `Object.keys(row)`. Do
> any consumers rely on the old header order? If so, an explicit column list would
> keep it stable.

optional:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Non-blocking: you should be able to replace this hand-written stub with
> `Layer.mock`.
