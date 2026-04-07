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
./bcs

# Symlink the standard into your project directory
./bcs display --symlink

# Generate a BCS-compliant script
./bcs template -t complete -n deploy -d 'Deploy script' -o deploy.sh -x

# Check a script for compliance
./bcs check myscript.sh

# List all BCS rule codes
./bcs codes
```

## Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Bash | 5.2+ | `bash --version` |
| ShellCheck | 0.8.0+ | `shellcheck --version` |
| curl + jq | Any | `curl --version && jq --version` (for `bcs check` API backends) |
| Claude CLI | Latest | `claude --version` (optional, for `bcs check --backend claude`) |

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

The Bash Coding Standard defines 105 rules across 12 sections in a single ~2,300-line document. Rules are written for both human programmers and AI assistants, with code examples for every rule.

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
./bcs template -t minimal     # Bare essentials (~15 lines)
./bcs template -t basic       # Standard with metadata (~25 lines)
./bcs template -t complete    # Full toolkit (~105 lines)
./bcs template -t library     # Sourceable library (~39 lines)
```

### Compliance Checking

Uses LLM-powered analysis to validate scripts against the full standard.
Supports multiple backends: Ollama (local), Anthropic API, Google Gemini API,
OpenAI API, and Claude CLI. Auto-detects the first available backend.

```bash
./bcs check myscript.sh                      # Auto-detect backend
./bcs check --backend ollama myscript.sh     # Use local Ollama
./bcs check --backend anthropic myscript.sh  # Use Anthropic API
./bcs check --backend google myscript.sh     # Use Google Gemini API
./bcs check --backend openai myscript.sh     # Use OpenAI API
./bcs check --strict deploy.sh               # Treat warnings as violations
./bcs check --effort high myscript.sh        # Thorough analysis
./bcs check --model thorough -e max deploy.sh # Higher quality + exhaustive
./bcscheck myscript.sh                       # Convenience shim for bcs check
```

### Backends and Model Tiers

The `-m` flag selects an abstract quality tier mapped to concrete models per backend:

| Tier | Ollama | Anthropic | Google | OpenAI |
|------|--------|-----------|--------|--------|
| fast | qwen3.5:9b | claude-haiku-4-5 | gemini-2.5-flash-lite | gpt-4.1-mini |
| balanced | qwen3.5:14b | claude-sonnet-4-6 | gemini-2.5-flash | gpt-5.4-mini |
| thorough | qwen3.5:14b | claude-opus-4-6 | gemini-2.5-pro | gpt-5.4 |

### Configuration

Defaults can be set in `~/.config/bcs/bcs.conf` (sourced as bash):

```bash
BCS_BACKEND=ollama        # auto, claude, ollama, anthropic, google, openai
BCS_MODEL=balanced        # fast, balanced, thorough
BCS_EFFORT=medium         # low, medium, high, max

# Override model for a specific backend (bypasses tier mapping)
BCS_OPENAI_MODEL=gpt-5.4
```

See `bcs.conf.sample` for all options including per-tier array overrides. CLI flags override config file settings.

## Examples

The `examples/` directory contains exemplar BCS-compliant scripts:

| Script | Lines | Demonstrates |
|--------|-------|-------------|
| `cln` | 250 | File operations, argument parsing, arrays |
| `md2ansi` | 1434 | Large-scale text processing, ANSI formatting |
| `which` | 125 | Dual-purpose script pattern |

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

BCS includes a rewritten Bash 5.2 reference manpage tailored for strict-mode scripting. It removes legacy syntax (backtick substitution, `[ ]` tests), POSIX compatibility modes, and `sh`-emulation caveats — leaving a clean, modern reference that assumes `set -euo pipefail` and `[[ ]]` throughout.

```bash
man BCS-bash    # View the reference (also: man bcs-bash)
```

The reference source lives in `docs/BCS-bash/` as structured Markdown files mirroring the original bash(1) man page sections.

## Related Resources

- [ShellCheck](https://www.shellcheck.net/) — Static analysis tool for shell scripts
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) — Google's shell scripting conventions
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) — Official GNU Bash documentation

## License

CC BY-SA 4.0 - See LICENSE for details.

## Acknowledgments

Developed by [Okusi Associates](https://www.okusi.id) for the [Indonesian Open Technology Foundation (YaTTI)](https://www.yatti.id).
