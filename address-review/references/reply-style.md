# Reply style

The reviewer, and often their agent, reads the reply. Give them the outcome and what
they need to act on it, nothing more.

- **Lead with the outcome.** For a fix, say what changed and why it's now correct. For
  a decline, start with "Keeping X." and give the decisive reason.
- **Acknowledge when earned** ("Good catch.").
- **Match claims to the evidence,** and name any assumption.
- **Use a snippet only when prose would be ambiguous.** It must match the pushed code.

## Footers

A fix reply ends with the pushed commit:

```markdown
<sub>Fixed in: `c8e93636a`</sub>
```

A decline, or any reply that rests on a factual claim, ends with its sources:

```markdown
<sub>Grounded in: `effect/Struct.d.ts`, tsc repro</sub>
```

Name sources a reviewer can re-check: files or type declarations in backticks,
documentation as links, and reproductions as plain text. Judgment and scope replies
need no footer. When a reply has both footers, put each on its own line, with
`Fixed in` first.

## Examples (illustrative: match the shape, not the content)

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Good catch. This came from an early requirement that no longer applies. The worker
> never reads these flags, and the scheduler already logs them, so I removed the
> field.
>
> <sub>Fixed in: `c8e93636a`</sub>

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Keeping the explicit mapping. `Struct.pick` plus spread would let extra Prisma
> fields cross the app boundary.
>
> <sub>Grounded in: `effect/Struct.d.ts`, tsc repro</sub>

> <sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
> Keeping this PR focused on the upload fix. The test-helper migration is tracked in
> EX-12.
