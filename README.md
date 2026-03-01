# Bash Coding Standard (BCS)

**Concise, actionable coding rules for Bash 5.2+**

Designed by Okusi Associates for the Indonesian Open Technology Foundation (YaTTI).

## Quick Start

```bash
# View the standard
./bcs

# Generate a BCS-compliant script
./bcs template -t complete -n deploy -d 'Deploy script' -o deploy.sh -x

# Check a script for compliance
./bcs check myscript.sh

# List all BCS rule codes
./bcs codes
```

## Installation

```bash
sudo make install              # Install to /usr/local (default)
sudo make PREFIX=/usr install  # Install to /usr (system-wide)
sudo make uninstall            # Uninstall
```

## Overview

The Bash Coding Standard defines 100 rules across 12 sections in a single ~2,000-line document. Rules are written for both human programmers and AI assistants, with code examples for every rule.

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
| `bcs display` | View the standard document (default) |
| `bcs template` | Generate BCS-compliant script templates |
| `bcs check` | AI-powered compliance checking (requires Claude CLI) |
| `bcs codes` | List all BCS rule codes |
| `bcs generate` | Regenerate standard from section files |
| `bcs help` | Show help for commands |

### Templates

Four template types for different needs:

```bash
./bcs template -t minimal     # Bare essentials (~13 lines)
./bcs template -t basic       # Standard with metadata (~27 lines)
./bcs template -t complete    # Full toolkit (~104 lines)
./bcs template -t library     # Sourceable library (~38 lines)
```

### Compliance Checking

Uses Claude AI to validate scripts against the full standard:

```bash
./bcs check myscript.sh           # Standard check
./bcs check --strict deploy.sh    # Treat warnings as violations
./bcscheck myscript.sh            # Quick check wrapper
```

## Examples

The `examples/` directory contains exemplar BCS-compliant scripts:

| Script | Lines | Demonstrates |
|--------|-------|-------------|
| `cln` | 247 | File operations, argument parsing, arrays |
| `data-processor.sh` | 188 | CSV processing, validation, dry-run |
| `production-deploy.sh` | 325 | Deployment, backup, rollback |
| `system-monitor.sh` | 365 | Monitoring, alerts, continuous mode |
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

## License

CC BY-SA 4.0 - See LICENSE for details.
