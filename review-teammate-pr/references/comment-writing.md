# Comment style

The author, and often their agent, reads the comment. Both should know what to do
after one read.

- **One concern per comment,** with one bounded request.
- **Match the wording to the user's decision:**
  - **lock**: state the condition and the consequence, then the fix: "If X, then Y.
    Could we Z?"
  - **optional**: prefix `Non-blocking:`.
  - **question**: prefix `Question:` and ask it, or frame it as something for the author
    to verify. A question never blocks.
- **Keep it short:** only what the author needs to act.
- **Add a snippet only when the fix would otherwise be ambiguous.** Use a `diff`, or a
  sketch labeled `Target shape`, with real symbols and installed APIs.
- **Ask for a test** when the behavior could silently regress.
- **Keep the scope tight.** Name adjacent work as a follow-up.

## Examples (illustrative: match the shape, not the content)

lock, small fix:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> After a failed first selection, the Combobox ignores the reset to `undefined` and
> keeps showing the old value. Could we keep the empty value controlled?
>
> ```diff
> - value={displayedCategoryId ?? undefined}
> + value={optimisticCategoryId ?? ""}
> ```

lock, less obvious:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> This query has no `companyId` filter, so an export returns every company's
> transactions in the date range. Could we scope it with `CurrentCompany`, like
> `transactions.repository.ts` does? A test with two companies would lock this in.

question:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Question: the CSV columns are now built from `Object.keys(row)`. Do
> any consumers rely on the old header order? If so, an explicit column list would
> keep it stable.

optional:

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Non-blocking: you should be able to replace this hand-written stub with
> `Layer.mock`.
