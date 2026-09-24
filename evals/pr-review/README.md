# PR review skill evals

Scenarios for `receiving-review` and `review-teammate-pr`. Each scenario is a small git
repo plus a JSON file that stands in for the GitHub fetch. The prompts, the user's
scripted replies, and the pass/fail assertions are in [`evals.json`](evals.json).
Rerun the evals after editing either skill or anything in `shared/`.

```sh
./setup.sh   # builds throwaway repos in /tmp/pr-review-evals
```

## Scenario runs

For each scenario:

1. Start a fresh session with its working directory set to
   `/tmp/pr-review-evals/<id>`. The agent that edited the skill shouldn't be the one
   testing it.
2. Tell the agent: "The JSON file in this repo is the GitHub fetch result. Use no `gh`
   and no network. Pretend posts and pushes succeed."
3. Invoke the skill for real with the scenario's `prompt`, then send its `turns` one
   by one. Don't point the agent at the skill's files. Following the links is part of
   what's being tested.
4. Grade every assertion PASS or FAIL, quoting the evidence.

Run each scenario twice: once with the skill installed, and once with it disabled as
a baseline. The skill should win clearly on the assertions. Repeat on at least two
models.

## Trigger checks

`evals.json` → `triggers` lists prompts that should and shouldn't load each skill.
Check them in a fresh session with the skills installed, but only if automatic
invocation is enabled.

## Not covered yet

- A stack of PRs
- The PR head moving before posting
- An existing pending review
- The `edit N` path
