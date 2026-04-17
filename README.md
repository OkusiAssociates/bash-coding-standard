# Bash Coding Standard (BCS)

**Concise, actionable coding rules for Bash 5.2+**

Designed by [Okusi Associates](https://www.okusi.id) for the [Indonesian Open Technology Foundation (YaTTI)](https://www.yatti.id).

Bash is a battle-tested, sophisticated programming language deployed on virtually every Unix-like system. When wielded with discipline and proper engineering principles, Bash delivers production-grade solutions for system automation, data processing, and infrastructure orchestration. This standard codifies that discipline.

## Install

```bash
git clone https://github.com/Open-Technology-Foundation/bash-coding-standard.git && cd bash-coding-standard && sudo make install
```

## Key Features

- Targets Bash 5.2+ exclusively (not a compatibility standard)
- Enforces strict error handling with `set -euo pipefail`
- Requires explicit variable declarations with type hints
- Mandates ShellCheck compliance
- Defines standard utility functions for consistent messaging
- AI-powered compliance checking via multiple LLM backends

## Target Audience

- Human developers writing production-grade Bash scripts
- AI assistants generating or analyzing Bash code
- DevOps engineers and system administrators
- Organizations needing standardized scripting guidelines

## Quick Start

```bash
# View the standard
bcs

# Symlink the standard into your current directory
bcs -S

# Generate a BCS-compliant script
bcs template -t complete -n deploy -d 'Deploy script' -o deploy.sh -x

# Check a script for compliance
bcs check myscript.sh

# List all BCS rule codes
bcs codes
```

## Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Bash | 5.2+ | `bash --version` |
| ShellCheck | 0.8.0+ | `shellcheck --version` |

The `bcs check` subcommand requires an LLM backend. At least one of the following:

| Backend | Requirement | Notes |
|---------|-------------|-------|
| Anthropic API | `ANTHROPIC_API_KEY` + curl + jq | Recommended -- best accuracy/speed ratio |
| OpenAI API | `OPENAI_API_KEY` + curl + jq | Best speed; strong on simpler scripts |
| Google Gemini API | `GOOGLE_API_KEY` + curl + jq | `thorough` tier recommended |
| Ollama (local or cloud) | Running Ollama server | No API key for local; `ollama signin` for cloud. Low accuracy on cloud models; glm-5.1:cloud is currently unreachable (HTTP 403 from ollama.com) -- use for offline/private checking only |
| Claude Code CLI | `claude` installed | Optional -- deepest rule citations but slowest (2--14 min per check in the 2026-04-17 refresh) |

## Installation

```bash
git clone https://github.com/Open-Technology-Foundation/bash-coding-standard.git
cd bash-coding-standard
sudo make install              # Install to /usr/local (default)
sudo make PREFIX=/usr install  # Install to /usr (system-wide)
sudo make uninstall            # Uninstall
```

Installs the `bcs` and `bcscheck` binaries, data files, bash completions, and the `bcs(1)` and `BCS-bash(1)` manpages.

## Overview

The Bash Coding Standard defines 98 substantive rules (plus 12 section overviews) across 12 sections in a single ~3,000-line document. Rules are written for both human programmers and AI assistants, with code examples for every rule. Every rule is tagged with a tier (`core`, `recommended`, or `style`) that drives severity in `bcs check`.

### 12 Sections

| # | Section | Key Rules |
|---|---------|-----------|
| 1 | Script Structure & Layout | Shebang, strict mode, metadata, function organization |
| 2 | Variables & Data Types | Type declarations, scoping, naming, arrays |
| 3 | Strings & Quoting | Single vs double quotes, conditionals, here-docs |
| 4 | Functions & Libraries | Definition, organization, export, library patterns |
| 5 | Control Flow | Conditionals, case, loops, arithmetic |
| 6 | Error Handling | Exit codes, traps, return value checking |
| 7 | I/O & Messaging | Standard messaging functions, colors, TUI |
| 8 | Command-Line Arguments | Parsing patterns, option bundling, validation |
| 9 | File Operations | File testing, wildcards, process substitution |
| 10 | Security | PATH, eval avoidance, input sanitization |
| 11 | Concurrency & Jobs | Background jobs, parallel execution, timeouts |
| 12 | Style & Development | Formatting, debugging, dry-run, testing |

## The `bcs` CLI Tool

| Command | Purpose |
|---------|---------|
| `bcs display` | View the standard document (default); `--symlink` to link into cwd |
| `bcs template` | Generate BCS-compliant script templates |
| `bcs check` | AI-powered compliance checking (multi-backend) |
| `bcs codes` | List all BCS rule codes |
| `bcs generate` | Regenerate standard from section files |
| `bcs help` | Show help for commands |

### Templates

Four template types for different needs:

```bash
bcs template -t minimal     # Bare essentials (~16 lines)
bcs template -t basic       # Standard with metadata (~26 lines)
bcs template -t complete    # Full toolkit (~119 lines)
bcs template -t library     # Sourceable library (~40 lines)
```

### Compliance Checking

Uses LLM-powered analysis to validate scripts against the full standard.
Supports multiple backends: Ollama (local), Anthropic API, Google Gemini API,
OpenAI API, and Claude Code CLI. The backend is resolved from the `-m` model
name.

```bash
bcs check myscript.sh                      # Probe available backends (balanced tier)
bcs check -m minimax-m2:cloud myscript.sh  # Route to local Ollama
bcs check -m claude-sonnet-4-6 myscript.sh # Route to Anthropic API
bcs check -m gemini-2.5-pro myscript.sh    # Route to Google Gemini API
bcs check -m gpt-5.4 myscript.sh           # Route to OpenAI API
bcs check -m claude-code myscript.sh       # Route to Claude Code CLI (balanced)
bcs check -m claude-code:thorough deploy.sh # Claude Code CLI at thorough tier
bcs check --strict deploy.sh               # Treat warnings as violations
bcs check --effort high myscript.sh        # Thorough analysis
bcs check -m thorough -e max deploy.sh     # Higher quality + exhaustive
bcscheck myscript.sh                       # Convenience shim for bcs check
```

### Model Grammar and Backend Routing

The `-m` value determines both the backend and the concrete model:

| `-m` value | Backend | Model |
|------------|---------|-------|
| `fast` / `balanced` / `thorough` | Probe in order: ollama, anthropic, openai, google, claude | Tier's default per backend |
| `claude-*` (e.g. `claude-opus-4-6`) | Anthropic API | Pass-through |
| `gemini-*` (e.g. `gemini-2.5-pro`) | Google Gemini API | Pass-through |
| `gpt-*` / `o[0-9]*` (e.g. `gpt-5.4`, `o3-mini`) | OpenAI API | Pass-through |
| `claude-code` | Claude Code CLI | `balanced` tier default |
| `claude-code:<tier-or-model>` | Claude Code CLI | Stripped suffix |
| anything else (e.g. `minimax-m2:cloud`) | Local Ollama | Pass-through |

Tier keywords map to concrete defaults per backend:

| Tier | Ollama | Anthropic | Google | OpenAI |
|------|--------|-----------|--------|--------|
| fast | qwen3.5:9b | claude-haiku-4-5 | gemini-2.5-flash-lite | gpt-4.1-mini |
| balanced | qwen3.5:14b | claude-sonnet-4-6 | gemini-2.5-flash | gpt-5.4-mini |
| thorough | qwen3.5:14b | claude-opus-4-6 | gemini-2.5-pro | gpt-5.4 |

▲ Ollama models whose names happen to match `claude-*`, `gemini-*`, `gpt-*` or `o[0-9]*` are unreachable through `-m` -- rename the local model if you need to target it.

### Recommended Settings

Not all model/effort combinations produce equally reliable results. Based on accuracy testing against BCS-compliant scripts of varying complexity (see `tests/accuracy/LLM-ACCURACY.md`, 2026-04-17 refresh):

| Use Case | Recommended Setting | Notes |
|----------|-------------------|-------|
| **Quick sanity check** | `-m gpt-5.4 -e medium` | 9--71s; clean on `cln`/`which` (0--1 FP), noisier on function-free scripts |
| **Daily development** | `-m claude-sonnet-4-6 -e medium` | 35--83s; zero false positives across all four test scripts; reliable suppression handling |
| **Pre-commit review** | `-m claude-sonnet-4-6 -e high` | 43--101s; more findings; still zero FPs on most scripts |
| **Thorough audit** | `-m claude-sonnet-4-6 -e max` | 42--128s; top scorer on md2ansi (6/10) and accuracy.sh (4/4) in the refresh |
| **Pre-release audit** | `-m claude-code -e max` | Deepest `which` analysis (3/3); very slow (5--14 min on larger scripts) |

**Backend accuracy ranking** (2026-04-17 refresh, 60 completed runs across four scripts; 12 glm-5.1 runs failed HTTP 403 and are excluded):

1. **Anthropic API (`claude-*`)** -- Best speed/accuracy ratio and most consistent across script types. claude-sonnet-4-6 at max is the top scorer on md2ansi (6/10) and accuracy.sh (4/4); at high it leads on cln (3.5/4); at medium it is the only model with zero FPs across all four scripts (35--83s). Only model to find both missing `local --` separators and both `((FLAG == 0))` sites. Recommended for daily development.
2. **Claude Code (`claude-code`)** -- Deepest rule citation on suppression/fence patterns. claude-code max scores 3/3 on `which` (tied for top). Tradeoff: **very slow** (5--14 min on larger scripts in this refresh). Best for final pre-release audits.
3. **OpenAI API (`gpt-*`, `o[0-9]*`)** -- Fastest backend (4--109s). gpt-5.4 at medium scores 2/4 on cln and 2/3 on which with 0--1 FP; degrades on function-free scripts where it misapplies BCS0202. Best for quick checks. Avoid `max` effort on `cln` and `accuracy.sh` -- introduces false positives without adding coverage.
4. **Google API (`gemini-*`)** -- Not included in the 2026-04-17 refresh matrix. Prior guidance stands: `thorough` tier at `medium` effort is reliable; lower tiers over-report.
5. **Ollama cloud models** -- Not recommended for accuracy-sensitive work. Refreshed scores: minimax-m2.7:cloud 0--2/3, qwen3-coder:480b-cloud 0--2/3 per script, both with persistent FPs (2--6 per run). The 2026-04-12 hallucinations (minimax producing 4 wrong claims on cln, qwen3 emitting XML tool-call tokens) did **not** recur; output is now well-formed but recall remains low. glm-5.1:cloud is currently unavailable (all 12 runs failed with HTTP 403 "a subscription is required for access" via ollama.com).

**Effort levels** control analysis depth and output token budget:

| Effort | Behaviour | Notes |
|--------|-----------|-------|
| `low` | Only clear violations. Concise output. | |
| `medium` | Violations and significant warnings. | Best default for gpt-5.4 (speed) and claude-sonnet-4-6 (zero-FP baseline) |
| `high` | All violations and warnings. Thorough. | Beneficial for Claude backends; marginal for gpt-5.4 and cloud models |
| `max` | Exhaustive line-by-line audit. Expensive. | Recommended for claude-sonnet-4-6 when catching low-rate findings matters; for gpt-5.4 and cloud-ollama models, tends to inflate runtime and FP count without new insights |

For most users, `-m claude-sonnet-4-6 -e medium` (or configure these as defaults in `bcs.conf`) provides the best balance of accuracy, speed, and cost. For pre-commit hooks where speed matters, `-m gpt-5.4 -e medium` is 9--71s with 0--1 FP on most scripts.

### Tiers and Severity

Every rule carries a `**Tier:**` field. `bcs check` maps tier to severity:

| Tier | Count | Severity | Behaviour |
|------|-------|----------|-----------|
| `core` | 33 | `[ERROR]` | Real correctness/safety bugs. Non-zero exit if any are found. |
| `recommended` | 41 | `[WARN]` | Bash hygiene; prevents subtle issues. |
| `style` | 24 | `[WARN]` | Taste; no correctness impact. |
| `disabled` | -- | (silent) | Applied only via policy; never reported. |

Filter with `-T <tier>` (only that tier) or `-M <tier>` (that tier and higher severity). For CI gates, use `bcscheck -T core script.sh` to fail only on core violations.

### Policy Overrides

Teams and individuals may reclassify or disable any rule via `policy.conf`:

```bash
# ~/.config/bcs/policy.conf  -- or .bcs/policy.conf per-repo
BCS0301 = style        # downgrade single-quote dogma
BCS0109 = disabled     # silence #fin end-marker noise
BCS9801 = core         # classify a user rule
```

Cascade (later wins): `/etc/bcs/policy.conf` → `~/.config/bcs/policy.conf` → `.bcs/policy.conf`. Parsed with strict regex, never sourced. See `bcs.policy.sample` for a template.

### User Rules

Add custom rules in the reserved `BCS9800-BCS9899` namespace. Place markdown files (same structure as any BCS rule) at:

- `data/98-user.md` (single file, optional)
- `data/98-user.d/*.md` (drop-in directory, optional)

Both may be symlinks to rule files in your home directory. `bcs generate` splices them into `BASH-CODING-STANDARD.md` after section 12; `bcs check` and `bcs codes` honour them like any other rule. Both paths are `.gitignore`d so your rules never ship with upstream BCS.

### Configuration

Config files are sourced as bash in cascade order (later files override earlier):

1. `/etc/bcs.conf` (system -- flat file)
2. `/etc/bcs/bcs.conf` (system -- directory)
3. `/usr/local/etc/bcs/bcs.conf` (local install)
4. `~/.config/bcs/bcs.conf` (user -- XDG standard)

Any file may set a subset of values; keys it doesn't touch inherit from earlier layers. This lets a user override a single setting without re-declaring every default.

```bash
BCS_MODEL=balanced        # fast, balanced, thorough, or a direct model name
                          # (e.g. claude-sonnet-4-6, minimax-m2:cloud, claude-code)
BCS_EFFORT=medium         # low, medium, high, max

# Override model for a specific backend (bypasses tier mapping)
BCS_OPENAI_MODEL=gpt-5.4
```

See `bcs.conf.sample` for all options including per-tier array overrides. CLI flags override config file settings; config overrides environment variables.

## Examples

The `examples/` directory contains exemplar BCS-compliant scripts:

| Script | Lines | Demonstrates |
|--------|-------|-------------|
| `cln` | 246 | File operations, argument parsing, arrays |
| `md2ansi` | 1430 | Large-scale text processing, ANSI formatting |
| `which` | 111 | Dual-purpose script pattern |

## Testing

```bash
./tests/run-all-tests.sh              # Run all tests
./tests/test-subcommand-template.sh   # Run specific suite
shellcheck -x bcs                     # Mandatory validation
```

## Coding Principles

- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not any simpler."

## Bash 5.2 Reference (Strict Mode)

BCS includes a rewritten Bash 5.2 reference manpage tailored for strict-mode scripting. It removes legacy syntax (backtick substitution, `[ ]` tests), POSIX compatibility modes, and `sh`-emulation caveats -- leaving a clean, modern reference that assumes `set -euo pipefail` and `[[ ]]` throughout.

```bash
man BCS-bash    # View the reference (also: man bcs-bash)
```

The reference source lives in `docs/BCS-bash/` as structured Markdown files mirroring the original bash(1) man page sections.

## AI Tooling (`ai-agents/`)

The [`ai-agents/`](ai-agents/README.md) package bundles BCS-aware agents, slash commands, and rule snapshots for Claude Code, opencode, and codex. Drop them into `~/.claude/`, `~/.config/opencode/`, or `~/.codex/` to give any AI session BCS-aware scaffolding, auditing, and shellcheck remediation. See [`ai-agents/README.md`](ai-agents/README.md) for the narrative introduction and [`ai-agents/AGENTS.md`](ai-agents/AGENTS.md) for the flat file inventory.

## Related Resources

- [ShellCheck](https://www.shellcheck.net/) -- Static analysis tool for shell scripts
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) -- Google's shell scripting conventions
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) -- Official GNU Bash documentation

## License

CC BY-SA 4.0 - See LICENSE for details.

## Acknowledgments

Developed by [Okusi Associates](https://www.okusi.id) for the [Indonesian Open Technology Foundation (YaTTI)](https://www.yatti.id).
