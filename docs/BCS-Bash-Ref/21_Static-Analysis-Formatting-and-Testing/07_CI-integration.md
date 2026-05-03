<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.7 CI integration

CI runs the same linters as the pre-commit hook (§21.6), but on every
push and pull request, against the *committed* tree rather than the
staged diff. The contract is simple: any warning is a failure, and the
default branch is protected so unmergable failures cannot be merged.
Two recipes — GitHub Actions and GitLab CI — cover the vast majority
of real repositories.

### GitHub Actions

A single workflow file at `.github/workflows/lint.yml` runs on every
push and PR. ShellCheck and shfmt come from upstream actions;
`bcscheck` is invoked as a normal step after installing BCS:

```yaml
# .github/workflows/lint.yml
name: lint
on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ludeeus/action-shellcheck@2.0.0
        env:
          SHELLCHECK_OPTS: --severity=warning --external-sources
        with:
          severity: warning

  shfmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: luizm/action-sh-checker@v0.9.0
        env:
          SHFMT_OPTS: '-i 2 -ci -bn -sr -d'

  bcscheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: install bcs
        run: |
          git clone --depth=1 https://github.com/Okusi/BCS.git /tmp/bcs
          sudo make -C /tmp/bcs install
      - name: run bcscheck
        env:
          BCS_MODEL: claude-code:fast
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          shopt -s globstar nullglob
          for f in **/*.bash **/*.sh; do
            bcscheck -e low "$f" || exit 1
          done
```

A few editorial points:

- Pin every action by SHA or tag (`@2.0.0`, not `@main`). Floating
  tags are an exfiltration risk and break reproducibility.
- Cache the `bcscheck` install in a separate job that publishes an
  artefact for the lint job; for small repos the inline `make install`
  is cheaper than the cache plumbing.
- `fail-fast` is on by default for matrix jobs and that's correct —
  the first ShellCheck failure should short-circuit the rest of the
  bash matrix.

### GitLab CI

The `.gitlab-ci.yml` equivalent uses GitLab's built-in image
mechanism — no marketplace actions, just a Docker image with the
tools pre-installed:

```yaml
# .gitlab-ci.yml
stages: [lint]

lint:bash:
  stage: lint
  image: koalaman/shellcheck-alpine:v0.10.0
  before_script:
    - apk add --no-cache bash make git curl
    - curl -fsSL https://github.com/mvdan/sh/releases/download/v3.8.0/shfmt_v3.8.0_linux_amd64 -o /usr/local/bin/shfmt
    - chmod +x /usr/local/bin/shfmt
  script:
    - shellcheck --severity=warning --external-sources $(git ls-files '*.bash' '*.sh')
    - shfmt -i 2 -ci -bn -sr -d $(git ls-files '*.bash' '*.sh')
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

Branch protection completes the loop: in GitHub, mark the lint job as
a *required status check*; in GitLab, set the protected branch to
require a successful pipeline before merge. With those rules in place
a commit that fails the lint cannot reach the default branch, even
with admin override.

### Operational tips

- Treat any warning as an error. Severity downgrades belong in the
  source (`# shellcheck disable=SC1234` with a justification — see
  §21.2), not in the workflow.
- Cache the binaries (`actions/cache`, GitLab `cache:`) so that
  shellcheck and shfmt are fetched once per week, not once per run.
- For LLM-backed `bcscheck`, gate on PR labels (`run-bcs`) or schedule
  it on a nightly job; running it on every push will burn credits and
  slow the queue.
- Mirror `pre-commit` and CI from the *same* config so a developer
  cannot pass locally and fail in CI (§21.6).
- Surface failures inline. GitHub Actions parses ShellCheck's
  `--format=gcc` output as annotations on the offending lines —
  pass `-f gcc` instead of the default tty format and the warnings
  show up directly on the PR diff.
- Separate fast and slow gates. Run ShellCheck and shfmt on every
  push (sub-second feedback), and gate `bcscheck` on a `run-bcs`
  label or a nightly schedule. The CI job should call the same
  `bcscheck -e low` invocation the pre-commit hook uses (§21.6) so
  results are reproducible across both.

**See also**: §21.1 (ShellCheck), §21.4 (shfmt), §21.5 (bcscheck),
§21.6 (pre-commit), Appendix L (exit codes).

#fin
