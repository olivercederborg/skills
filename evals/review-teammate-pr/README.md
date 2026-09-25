# review-teammate-pr evals

One scenario: a small git repo plus `pr.json` standing in for the PR metadata. The
prompt, scripted replies, and assertions are in [`evals.json`](evals.json).

```sh
./setup.sh   # builds a throwaway repo in /tmp/review-teammate-pr-evals
```

## How to run

1. Start a fresh session with its working directory set to the scenario folder. The
   agent that edited the skill shouldn't be the one testing it.
2. Tell the agent: "The JSON file in this repo is the GitHub fetch result. Use no `gh`
   and no network. Pretend posts and pushes succeed."
3. Invoke the skill with the scenario's `prompt`, then send its `turns` one by one. Keep
   the agent off the skill's files: following the links is part of the test.
4. Grade every assertion PASS or FAIL, quoting the evidence.

Run each scenario with the skill installed and again with it disabled, on at least two
models. `evals.json` → `triggers` lists prompts that should and shouldn't load the
skill; check them in a fresh session.

## Not covered yet

- The PR head moving before posting
- An existing pending review
- Re-review after fixes
