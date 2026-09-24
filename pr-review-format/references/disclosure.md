# Agent disclosure

Every comment or reply posted to GitHub starts with:

```markdown
<sub>`AGENT` {model} · on behalf of **{name}**</sub><br>
```

- `{model}` is the exact active model from the runtime, e.g. `Claude Opus 5.5` or
  `GPT-5.6 Sol`.
- `{name}` is the user's first name.
- Keep only the segments you can verify, so that the posted line is always complete.
  The shorter forms are `<sub>`AGENT` {model}</sub><br>`,
  `<sub>`AGENT` on behalf of **{name}**</sub><br>`, and `<sub>`AGENT`</sub><br>`.
- Keep `<br>` directly after `</sub>` so that the body starts on the next line.

Older agent replies start with `🤖 **[Agent]:**`. Count those as ours too when checking
whether a thread is already answered.
