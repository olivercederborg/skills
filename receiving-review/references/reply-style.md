# Reply style

The reviewer, and often their agent, reads the reply. One to three sentences is
usually enough.

- **Lead with the outcome.** For a fix, say what changed and why it's now correct. For
  a decline, start with "Keeping X." and give the decisive reason.
- **Keep the tone collegial.** State the outcome plainly. A short acknowledgement
  ("Good catch.") fits when it's earned.
- **Match claims to the evidence.** Name any assumption.
- **Use a snippet only when prose would be ambiguous.** It must match the pushed code.
- **Give the outcome and the one reason that matters.** The reviewer can ask for more.

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
documentation as links, and reproductions as plain text. A claim needs a source you
can cite. Judgment and scope replies need no footer. When a reply has both footers,
put each on its own line, with `Fixed in` first.

## Examples

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Good catch. This came from an early requirement that no longer applies. The worker
> never reads these flags, and the scheduler already logs them, so I removed the
> field.
>
> <sub>Fixed in: `c8e93636a`</sub>

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Fixed. The example now imports from `./payments/payments.layer`, matching
> `billing.layer.ts`.
>
> <sub>Fixed in: `b4fb61fe1`</sub>

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Keeping the explicit mapping. `Struct.pick` plus spread would let extra Prisma
> fields cross the app boundary.
>
> <sub>Grounded in: `effect/Struct.d.ts`, tsc repro</sub>

> <sub>`AGENT` Claude Opus 5.5 · on behalf of **Oliver**</sub><br>
> Keeping this PR focused on the upload fix. The test-helper migration is tracked in
> EX-12.
