<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.6 Pre-commit hooks

Pre-commit hooks fail a commit before it is recorded, which is cheaper
than fixing CI red later. The Python `pre-commit` framework
(<https://pre-commit.com>) is the de-facto standard: it pins each linter
to a known git revision, isolates them in their own venv or container,
and runs only on staged files by default. Install it once
(`pipx install pre-commit`) and configure per-repo via
`.pre-commit-config.yaml`.

A working configuration for a BCS-flavoured bash repo runs `shellcheck`,
`shfmt`, and `bcscheck` on every `*.bash`, `*.sh`, and shebang-bash
file:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.10.0
    hooks:
      - id: shellcheck
        args: [--severity=warning, --external-sources]

  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.8.0-1
    hooks:
      - id: shfmt
        args: [-i, '2', -ci, -bn, -sr, -d]   # 2-space indent, diff mode

  - repo: local
    hooks:
      - id: bcscheck
        name: BCS compliance
        entry: bcscheck
        language: system
        types: [shell]
        args: [-m, fast, -e, low]
        require_serial: true                 # LLM-backed: don't fan out
```

Activate the hook for the working tree once per clone:

```bash
# scenario: enable hooks for a freshly cloned repo
pre-commit install                   # installs the git hook
pre-commit run --all-files           # smoke-test against the entire tree
# ⇒ commits now fail until shellcheck, shfmt, and bcscheck all pass
```

Notes:

- The `local` repo entry assumes `bcscheck` is on `PATH`; on a CI
  runner you may need to install BCS first or pin a path
  (`entry: /opt/bcs/bin/bcscheck`).
- `types: [shell]` matches files via `pre-commit`'s identifier list,
  which catches shebang-bash files without `.sh` extensions; explicit
  `files: '\.bash$'` also works.
- `require_serial: true` matters for LLM-backed checkers — running ten
  in parallel will throttle or rate-limit the backend.
- Bypass with `git commit --no-verify` is intentionally inconvenient.
  Reserve it for hot-fix branches and mention the bypass in the commit
  body so reviewers know to re-run the hooks before merging.
- `pre-commit autoupdate` bumps each `rev:` to the latest tag; review
  the diff before committing the bump (BCS releases sometimes change
  default severity tiers).

For larger repos consider also wiring `pre-commit` into CI itself
(§21.7) — the same config drives both, so divergence between local and
CI is impossible.

### Stage-aware hooks

`pre-commit` runs hooks only on *staged* files by default — partial
adds (`git add -p`) skip unstaged hunks. To validate the full file
even when only part of it is staged, use the `pass_filenames: false`
escape hatch and let the hook glob the working tree itself:

```yaml
  - repo: local
    hooks:
      - id: bcscheck-fulltree
        name: BCS compliance (full tree)
        entry: bash -c 'bcscheck $(git ls-files "*.bash" "*.sh")'
        language: system
        pass_filenames: false
        stages: [pre-push]                 # only on push, not commit
```

Splitting fast hooks (`shellcheck`, `shfmt`) into the `pre-commit`
stage and slow LLM-backed hooks (`bcscheck`) into `pre-push` keeps the
inner loop tight while still gating the network round-trip before the
remote sees the change.

**See also**: §21.1 (ShellCheck), §21.4 (shfmt), §21.5 (bcscheck),
§21.7 (CI integration), `BCS Section 13` (env config / `bcs.conf`).

#fin
