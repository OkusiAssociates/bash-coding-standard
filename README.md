# Bash Coding Standard (BCS)

**Concise, actionable coding rules for Bash 5.2+**

Designed by [Okusi Associates](https://www.okusi.id) for the [Indonesian Open Technology Foundation (YaTTI)](https://www.yatti.id).

## Quickstart

```bash
git clone https://github.com/Open-Technology-Foundation/bash-coding-standard.git
cd bash-coding-standard && sudo make install

bcs                                                  # View the standard
bcs template -t complete -n deploy -o deploy.sh -x   # Scaffold a script
bcs check deploy.sh                                  # AI-powered compliance check
bcs codes                                            # List all 110 BCS rule codes
```

You now have:

| Tool | Purpose |
|------|---------|
| `bcs` | CLI for the standard (display / template / check / codes / generate) |
| `bcscheck` | Convenience shim for `bcs check` (defaults configured in `bcs.conf`) |
| `man bcs`, `man BCS-bash` | Manpages for the CLI and a strict-mode Bash 5.2 reference |

## For AI Readers

Programmatic anchors for machine consumption:

| Resource | Path / Command | Use |
|----------|----------------|-----|
| Standard document | [`data/BASH-CODING-STANDARD.md`](data/BASH-CODING-STANDARD.md) | Single assembled doc; `## BCS####` headers |
| Section sources | `data/01-*.md` ... `data/12-*.md` | Edit these, never the assembled doc |
| Rule codes | `bcs codes` / `bcs codes -E BCSdddd` | List all, or explain one |
| AI tooling inventory | [`ai-agents/AGENTS.md`](ai-agents/AGENTS.md) | Flat inventory of agents, slash commands, rule snapshots |

Canonical command phrasings: `bcs check <path>`, `bcs codes [-E BCSdddd]`, `bcs template -t <type> -n <name> -o <path>`, `man bcs`, `man BCS-bash`. Rule references in body text use the bare form `BCSdddd`; in links use `[BCSdddd](data/<section>.md)`.

## Why BCS

Bash is a battle-tested programming language deployed on virtually every Unix-like system. When wielded with discipline it delivers production-grade automation, data processing, and infrastructure orchestration. *KISS -- keep it simple.*

- Targets Bash 5.2+ exclusively (not a compatibility standard)
- Strict error handling with `set -euo pipefail`
- Explicit variable declarations and scoping
- Mandatory ShellCheck compliance
- Standard utility functions for consistent messaging
- AI-powered compliance checking across five LLM backends

Audience: human developers writing production-grade Bash, AI assistants generating or analysing Bash code, DevOps engineers and organisations needing standardised guidelines.

## Installation

```bash
git clone https://github.com/Open-Technology-Foundation/bash-coding-standard.git
cd bash-coding-standard
sudo make install              # Install to /usr/local (default)
sudo make PREFIX=/usr install  # System-wide
sudo make uninstall            # Uninstall
```

Installs the `bcs` CLI plus per-subcommand shims (`bcscheck`, `bcsdisplay`, `bcstemplate`, `bcscodes`, `bcsgenerate`), data files, bash completions, the `bcs(1)` and `BCS-bash(1)` manpages, and the rendered HTML reference trees under `docs/BCS-bash.html/` and `docs/BCS-Bash-Ref.html/`.

**Prerequisites:** Bash 5.2+ (`bash --version`) and ShellCheck 0.8.0+ (`shellcheck --version`).

**LLM backends** (optional, for `bcs check`) -- at least one of:

| Backend | Requirement |
|---------|-------------|
| Anthropic API | `ANTHROPIC_API_KEY` + `curl` + `jq` |
| OpenAI API | `OPENAI_API_KEY` + `curl` + `jq` |
| Google Gemini API | `GOOGLE_API_KEY` + `curl` + `jq` |
| Ollama (local or cloud) | Running Ollama server |
| Claude Code CLI | `claude` installed on `PATH` |

See [Compliance Checking](#compliance-checking) for backend trade-offs.

## The Standard

The Bash Coding Standard defines **98 substantive rules plus 12 section overviews** (110 total codes) across 12 sections in a single ~3,000-line document. Every rule carries examples, a `**Tier:**` label, and a BCS code (`BCSssrr`, four digits, zero-padded).

| # | Section | Focus |
|---|---------|-------|
| 1 | Script Structure & Layout | Shebang, strict mode, metadata, function organisation |
| 2 | Variables & Data Types | Type declarations, scoping, naming, arrays |
| 3 | Strings & Quoting | Single vs double quotes, conditionals, here-docs |
| 4 | Functions & Libraries | Definition, organisation, export, library patterns |
| 5 | Control Flow | Conditionals, `case`, loops, arithmetic |
| 6 | Error Handling | Exit codes, traps, return-value checking |
| 7 | I/O & Messaging | Standard messaging functions, colours, TUI |
| 8 | Command-Line Arguments | Parsing patterns, option bundling, validation |
| 9 | File Operations | File testing, wildcards, process substitution |
| 10 | Security | `PATH`, `eval` avoidance, input sanitisation |
| 11 | Concurrency & Jobs | Background jobs, parallel execution, timeouts |
| 12 | Style & Development | Formatting, debugging, dry-run, testing |

**Tier distribution** -- `bcs check` maps tier to severity:

| Tier | Count | Severity | Behaviour |
|------|-------|----------|-----------|
| `core` | 34 | `[ERROR]` | Real correctness/safety bugs. Non-zero exit if any are found. |
| `recommended` | 41 | `[WARN]` | Bash hygiene; prevents subtle issues. |
| `style` | 23 | `[WARN]` | Taste; no correctness impact. |
| `disabled` | -- | (silent) | Applied only via `policy.conf`; never reported. |

## CLI Reference

Subcommands, frequency-ordered:

| Command | Purpose |
|---------|---------|
| `bcs check` | AI-powered compliance check against the full standard |
| `bcs template` | Generate BCS-compliant script templates |
| `bcs codes` | List rule codes; `-E BCSdddd` to explain one |
| `bcs display` | View the standard (default when no subcommand) |
| `bcs generate` | Reassemble `BASH-CODING-STANDARD.md` from section files (maintainer) |
| `bcs help [CMD]` | Per-command help |

### `bcs check`

```bash
bcs check myscript.sh                      # Default alias 'sonnet' (claude-sonnet-4-6)
bcs check -m opus deploy.sh                # Alias-expanded to claude-opus-4-7
bcs check -m gpt5 -e high deploy.sh        # OpenAI gpt-5 with reasoning_effort=medium
bcs check -m claude-code:opus ci.sh        # Claude Code CLI with the opus alias
bcs check --strict -T core deploy.sh       # CI gate: core-only, warnings fatal
bcs check --no-shellcheck myscript.sh      # Skip the shellcheck static-analysis prelude
bcscheck myscript.sh                       # Equivalent shim (defaults from bcs.conf)
```

When `shellcheck` is on `PATH`, `bcs check` prepends its `--format=json -x` output to the LLM prompt as deterministic static-analysis context (cheap, precise AST-level findings that the LLM would otherwise rediscover). Disable per-call with `--no-shellcheck` or globally via `BCS_SHELLCHECK=0` in `bcs.conf`.

### `bcs template`

```bash
bcs template -t complete -n deploy -d 'Deploy script' -o deploy.sh -x
```

| Type | Lines | Use |
|------|-------|-----|
| `minimal` | ~18 | Bare essentials |
| `basic` | ~43 | Standard with metadata (default) |
| `complete` | ~112 | Full toolkit (main, args, messaging, cleanup) |
| `library` | ~37 | Sourceable library (no `main`) |

### `bcs codes`

```bash
bcs codes                  # All rules, tier-decorated
bcs codes -T core          # Only core-tier rules (34)
bcs codes -E BCS0101       # Explain one rule
bcs codes -p               # Plain output (no tier decoration)
```

### `bcs display` & `bcs generate`

`bcs` (no args) renders the standard via `md2ansi` + `less` in a terminal. Flags: `-c` plain, `-S` symlink the standard into cwd, `-f` print its path. `bcs generate` rebuilds `data/BASH-CODING-STANDARD.md` from the `data/[0-9]*.md` section files -- maintainer-only; never edit the assembled document directly.

## Compliance Checking

`bcs check` analyses a script with an LLM and reports findings keyed to BCS codes. The backend is resolved entirely from the `-m` model name -- there is no separate `--backend` flag.

**Backend routing**

The `-m` value is alias-expanded then routed by name prefix. Legacy tier
keywords (`fast`/`balanced`/`thorough`) exit non-zero with a migration hint.

| `-m` value | Backend | Notes |
|------------|---------|-------|
| `claude-*` (e.g. `claude-opus-4-7`) | Anthropic API | Pass-through |
| `gemini-*` (e.g. `gemini-2.5-pro`) | Google Gemini API | Pass-through |
| `gpt-*` / `o[0-9]*` (e.g. `gpt-5`, `o3-mini`) | OpenAI API | Pass-through |
| `claude-code` | Claude Code CLI | `BCS_MODEL` or `sonnet` default |
| `claude-code:<alias-or-model>` | Claude Code CLI | Suffix alias-expanded |
| anything else (e.g. `minimax-m2:cloud`) | Local Ollama | Pass-through |

▲ Local Ollama models whose names match `claude-*`, `gemini-*`, `gpt-*`, or `o[0-9]*` are unreachable through `-m` -- rename the local model.

**Built-in model aliases**

Set `MODEL_ALIASES[name]=canonical-id` in `bcs.conf` to extend or override.

| Alias | Canonical ID | Backend |
|-------|--------------|---------|
| `opus` | `claude-opus-4-7` | Anthropic |
| `sonnet` (default) | `claude-sonnet-4-6` | Anthropic |
| `haiku` | `claude-haiku-4-5` | Anthropic |
| `flash` | `gemini-2.5-flash` | Google |
| `pro` | `gemini-2.5-pro` | Google |
| `flash-lite` | `gemini-2.5-flash-lite` | Google |
| `gpt5` | `gpt-5` | OpenAI |
| `gpt5-mini` | `gpt-5-mini` | OpenAI |
| `qwen` | `qwen3.5:14b` | Ollama |
| `qwen-small` | `qwen3.5:9b` | Ollama |

**Effort levels**

`-e` sets the max output tokens AND the thinking/reasoning budget on capable
models. Anthropic `thinking.budget_tokens` auto-applies on `opus` and
`sonnet-4-6/4-7`; OpenAI `reasoning_effort` auto-applies on `o[0-9]*` and
`gpt-5*`; Gemini `thinkingConfig.thinkingBudget` auto-applies on the 2.5
family except `flash-lite`. Other models silently ignore the budget.

| `-e` | Max tokens | Thinking budget | OpenAI `reasoning_effort` |
|------|------------|------------------|---------------------------|
| `low` | 4000 | 0 (off) | minimal |
| `medium` (default) | 8000 | 2000 | low |
| `high` | 32000 | 8000 | medium |
| `max` | 64000 | 16000 | high |

**Recommended defaults**

| Use case | Setting |
|----------|---------|
| Quick sanity check | `-m gpt5 -e medium` |
| Daily development | `-m sonnet -e medium` |
| Pre-commit review | `-m sonnet -e high` |
| Thorough audit | `-m sonnet -e max` |
| Pre-release audit | `-m claude-code:opus -e max` |

**Filtering, CI gates, suppression**

- `-T <tier>` -- only findings at that tier (e.g. `bcscheck -T core deploy.sh` as a CI gate).
- `-M <tier>` -- that tier or stricter (`-M recommended` excludes style).
- `--strict` -- treat warnings as violations (non-zero exit on any finding).
- `#bcscheck disable=BCSdddd` on its own line suppresses a rule for the next command, function, or `{ ... }` block -- same scope rules as `shellcheck` directives.

**Accuracy data** -- backend accuracy is measured against four BCS-compliant scripts (`cln`, `md2ansi`, `which`, `tests/accuracy/bcs-check-accuracy.sh`) across multiple models and effort levels. See [`tests/accuracy/LLM-ACCURACY.md`](tests/accuracy/LLM-ACCURACY.md) for the current scoring matrix and refresh date.

## Customisation

### Policy Overrides (`policy.conf`)

Reclassify or disable any rule:

```
# ~/.config/bcs/policy.conf  -- or .bcs/policy.conf per repo
BCS0301 = style        # downgrade single-quote dogma
BCS0109 = disabled     # silence #fin end-marker noise
BCS9801 = core         # classify a user rule
```

Cascade, later wins: `/etc/bcs/policy.conf` → `~/.config/bcs/policy.conf` → `.bcs/policy.conf`. Parsed with a strict regex, never sourced as shell. See [`bcs.policy.sample`](bcs.policy.sample).

### Custom Rules (`BCS9800`--`BCS9899`)

The `BCS98xx` namespace is reserved for user rules. Place markdown files (same structure as any BCS rule) at `data/98-user.md` (single file) or `data/98-user.d/*.md` (drop-in directory); both may be symlinks. `bcs generate` splices them into `BASH-CODING-STANDARD.md` after section 12. Both paths are `.gitignore`d so user rules never ship upstream.

### Configuration (`bcs.conf`)

Cascading bash-sourced config, later wins: `/etc/bcs.conf` → `/etc/bcs/bcs.conf` → `/usr/local/etc/bcs/bcs.conf` → `~/.config/bcs/bcs.conf` (XDG).

```bash
BCS_MODEL=sonnet                      # alias or canonical model ID
BCS_EFFORT=medium                     # min, low, medium, high, xhigh, max
BCS_STRICT=0                          # 0 or 1
MODEL_ALIASES[mycloud]=minimax-m2:cloud  # extend or override the alias map
EFFORT_THINKING[xhigh]=12000          # tune Anthropic/Google thinking budget
```

CLI flags override config; config overrides environment. See [`bcs.conf.sample`](bcs.conf.sample) for all options including `MODEL_ALIASES`, `EFFORT_TOKENS`, `EFFORT_THINKING`, and `EFFORT_REASONING` overrides.

## Examples

### Standalone Scripts

`examples/` contains exemplar BCS-compliant scripts:

| Script | Lines | Demonstrates |
|--------|-------|--------------|
| [`cln`](examples/cln) | 246 | File operations, argument parsing, arrays |
| [`md2ansi`](examples/md2ansi) | 1430 | Large-scale text processing, ANSI formatting |
| [`which`](examples/which) | 111 | Dual-purpose script pattern |

### Reference Codebase Library & Templates

[`examples/lib/`](examples/lib/index.md) is a curated set of working, BCS-compliant reference codebases organised by domain (`file/`, `math/`, `str/`, `sys/`, `time/`) -- see the index for an annotated tour of each project. Generate fresh BCS-compliant skeletons with `bcs template -t {minimal,basic,complete,library}` (see [CLI Reference](#bcs-template)).

## AI Tooling (`ai-agents/`)

The [`ai-agents/`](ai-agents/README.md) package bundles BCS-aware agents, slash commands, and rule snapshots for Claude Code, opencode, and codex. Drop them into `~/.claude/`, `~/.config/opencode/`, or `~/.codex/` to give any AI session BCS-aware scaffolding, auditing, and ShellCheck remediation.

| Component | Inventory | Use |
|-----------|-----------|-----|
| Agents | `bash-expert`, `bcs-auditor`, `script-scaffolder`, `shellcheck-fixer`, `documentation-writer` | Autonomous BCS-aware sub-agents |
| Slash commands | `/audit-bash`, `/bcs-check`, `/bcs-codes`, `/fix-shellcheck`, `/scaffold`, `/pfu`, `/update-docs`, `/update-internal-docs` | Single-shot operations |
| Rule snapshots | `bash-coding-standard.md`, `coding-principles.md`, `documentation.md`, ... | Drop-in rule files |

See [`ai-agents/AGENTS.md`](ai-agents/AGENTS.md) for the flat file inventory.

## Bash References (`BCS-bash`, `BCS-Bash-Ref`)

BCS ships two complementary Bash references, both authored for strict-mode scripting (`set -euo pipefail`, `[[ ]]`, no backtick substitution, no POSIX/`sh`-emulation caveats):

| Reference | Scope | Source | Rendered |
|-----------|-------|--------|----------|
| **`BCS-bash`** | Rewritten Bash 5.2 manpage | [`docs/BCS-bash/`](docs/BCS-bash/) | [`docs/BCS-bash.html/`](docs/BCS-bash.html/), `man BCS-bash` |
| **`BCS-Bash-Ref`** | Advanced Bash Reference (25 Parts + Appendices, ~350 leaves) | [`docs/BCS-Bash-Ref/`](docs/BCS-Bash-Ref/) | [`docs/BCS-Bash-Ref.html/`](docs/BCS-Bash-Ref.html/) |

```bash
man BCS-bash                                       # Manpage (also: man bcs-bash)
xdg-open docs/BCS-Bash-Ref.html/index.html         # Advanced reference (HTML)
```

The HTML trees are checked-in artefacts. The `BCS-Bash-Ref.html/` tree is rebuilt via [`docs/BCS-Bash-Ref.html.build`](docs/BCS-Bash-Ref.html.build), which wraps `mdview --preserve-tmp` and rsyncs the rendered tree into place.

## Testing & Self-Compliance

```bash
./tests/run-all-tests.sh             # Run all suites
./tests/test-subcommand-template.sh  # Run a single suite
shellcheck -x bcs bcscheck           # Mandatory static check
make check && make test              # Equivalent shortcuts
```

✓ **Self-compliance:** `bcs check bcs` passes -- the `bcs` script is itself BCS-compliant. The invariant is enforced by [`tests/test-self-compliance.sh`](tests/test-self-compliance.sh) and runs as part of every test suite invocation.

## Related Resources

- [ShellCheck](https://www.shellcheck.net/) -- Static analysis for shell scripts
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) -- Google's conventions
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) -- Official GNU Bash documentation

## License & Acknowledgments

BCS is dual-licensed to suit the two kinds of material it contains:

- The **BCS CLI tooling** (`bcs`, `bcscheck`, tests, Makefile, templates,
  man pages, first-party examples) is licensed under
  [GPL-3.0-or-later](LICENSE).
- The **Bash Coding Standard document** (`data/*`) -- prose, a creative
  work -- is licensed under [CC BY-SA 4.0](data/LICENSE).
- Bundled reference implementations under `examples/lib/**/` ship with
  their own per-project LICENSE files (predominantly GPL-3).

See [`COPYING`](COPYING) for a plain-English summary of the split. Every
first-party file carries an `SPDX-License-Identifier` header so tooling
(e.g. REUSE) can identify each file's licence unambiguously.

Developed by [Okusi Associates](https://www.okusi.id) for the [Indonesian Open Technology Foundation (YaTTI)](https://www.yatti.id).
