# Bash Coding Standard

A comprehensive coding standard for modern Bash 5.2+ scripts, designed for consistency, robustness, and maintainability.

**Version 1.0.2** | **12 Sections** | **101 Rules** | **13 Subcommands**

---

## Overview

This repository contains the canonical Bash coding standards developed by [Okusi Associates](https://okusiassociates.com) and adopted by the [Indonesian Open Technology Foundation (YaTTI)](https://yatti.id).

Bash is a battle-tested, sophisticated programming language deployed on virtually every Unix-like system. When wielded with discipline and proper engineering principles, Bash delivers production-grade solutions for system automation, data processing, and infrastructure orchestration. This standard codifies that discipline.

### Key Features

- Targets **Bash 5.2+** exclusively (not a compatibility standard)
- Enforces strict error handling with `set -euo pipefail`
- Requires explicit variable declarations with type hints
- Mandates **ShellCheck** compliance
- Defines standard utility functions for consistent messaging
- **12 comprehensive sections** covering all aspects of Bash scripting
- **AI-powered** compliance checking via Claude

### Target Audience

- Human developers writing production-grade Bash scripts
- AI assistants generating or analyzing Bash code
- DevOps engineers and system administrators
- Organizations needing standardized scripting guidelines

---

## Quick Start

### Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| **Bash** | 5.2+ | `bash --version` |
| **ShellCheck** | 0.8.0+ | `shellcheck --version` |
| **Claude CLI** | Latest | `claude --version` (optional, for AI features) |

### Installation

```bash
git clone https://github.com/OkusiAssociates/bash-coding-standard.git
cd bash-coding-standard

# Run directly (development mode)
./bcs

# Or install system-wide
sudo make install
```

### First Commands

```bash
# View the standard
bcs                              # Auto-detect best viewer

# Generate a BCS-compliant script
bcs template -t complete -n myscript -o myscript.sh -x

# Check script compliance (requires Claude CLI)
bcs check myscript.sh

# Look up BCS rules
bcs codes                        # List all 101 rule codes
bcs decode BCS0102 -p            # View specific rule content
```

---

## The 12 Sections

| # | Section | Key Topics |
|---|---------|------------|
| 1 | **Script Structure & Layout** | 13-step mandatory structure, shebang, metadata, function organization |
| 2 | **Variable Declarations & Constants** | Declarations, scoping, naming, readonly patterns, arrays, parameter expansion |
| 3 | **Strings & Quoting** | Single vs double quotes, mixed quoting, here-docs |
| 4 | **Functions** | Definition patterns, organization, export, library patterns |
| 5 | **Control Flow** | Conditionals, case statements, loops, arithmetic |
| 6 | **Error Handling** | `set -e`, exit codes, traps, return value checking |
| 7 | **Input/Output & Messaging** | Standard messaging functions, colors, TUI basics |
| 8 | **Command-Line Arguments** | Parsing patterns, short option support |
| 9 | **File Operations** | Testing, wildcards, process substitution |
| 10 | **Security Considerations** | SUID, PATH, eval, IFS, input sanitization, temp files |
| 11 | **Concurrency & Jobs** | Background jobs, parallel execution, timeouts |
| 12 | **Style & Development** | Formatting, debugging, dry-run, testing |

---

## Mandatory Script Structure

Every BCS-compliant script follows this 13-step structure:

1. **Shebang:** `#!/usr/bin/env bash`
2. **ShellCheck directives** (if needed): `#shellcheck disable=SC####`
3. **Brief description comment:** One-line purpose
4. **Strict mode:** `set -euo pipefail` (mandatory)
5. **Shell options:** `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. **Script metadata:** VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
7. **Global variable declarations:** With explicit types
8. **Color definitions:** If terminal output needed
9. **Utility functions:** Messaging, helpers
10. **Business logic functions:** Core functionality
11. **`main()` function:** Required for scripts >200 lines
12. **Script invocation:** `main "$@"`
13. **End marker:** `#fin` (mandatory)

### Minimal Example

```bash
#!/usr/bin/env bash
# Brief description
set -euo pipefail

error() { >&2 echo "$0: $*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

main() {
  echo 'Hello, World!'
}

main "$@"
#fin
```

---

## Critical Patterns

### Variable Expansion

```bash
# Default: no braces
echo "$var"

# Use braces when required:
echo "${var##pattern}"      # Parameter expansion
echo "${var:-default}"      # Default values
echo "${array[@]}"          # Arrays
echo "${var1}${var2}"       # Concatenation
```

### Quoting

```bash
# Single quotes for static strings
info 'Processing files...'

# Double quotes when variables needed
info "Processing $count files"

# Always quote in conditionals
[[ -f "$file" ]]
```

### Arithmetic

```bash
# ✓ CORRECT - The ONLY acceptable increment form
declare -i i=0    # MUST declare as integer first
i+=1              # Clearest, safest, most readable

# ✗ WRONG - NEVER use these forms
((i+=1))          # Unnecessary parentheses
((i++))           # Fails with set -e when i=0
((++i))           # Unnecessary complexity
```

### Error Output

```bash
# Place >&2 at beginning
>&2 echo "error message"
```

### Process Substitution

```bash
# Prefer this (avoids subshell issues)
while IFS= read -r line; do
  count+=1
done < <(command)

# Avoid pipes to while (subshell loses variables)
command | while read -r line; do count+=1; done
```

---

## Subcommands

The `bcs` toolkit provides 13 subcommands:

| Command | Purpose |
|---------|---------|
| `display` | View standard document (default) |
| `about` | Project information and statistics |
| `template` | Generate BCS-compliant templates |
| `check` | AI-powered compliance checking |
| `compress` | AI-powered rule compression |
| `codes` | List all BCS rule codes |
| `generate` | Regenerate standard from data/ |
| `generate-rulets` | Generate rulet files |
| `search` | Search within standard |
| `decode` | Decode BCS code to file location |
| `sections` | List all 12 sections |
| `default` | Set or show default tier |
| `help` | Show help for commands |

### Common Usage

```bash
bcs                              # View standard
bcs template -t complete -o script.sh -x   # Generate script
bcs check script.sh              # AI compliance check
bcscheck script.sh               # Quick check (wrapper)
bcs codes                        # List all codes
bcs decode BCS0102 -p            # View rule content
bcs search "readonly"            # Search standard
```

---

## Templates

Four BCS-compliant templates in `data/templates/`:

| Template | Lines | Use Case |
|----------|-------|----------|
| `minimal` | 14 | Quick scripts, bare essentials |
| `basic` | 25 | Standard scripts with metadata |
| `complete` | 100 | Full toolkit, production scripts |
| `library` | 39 | Sourceable libraries |

```bash
bcs template -t minimal -o quick.sh -x
bcs template -t complete -n deploy -d "Deployment script" -o deploy.sh -x
bcs template -t library -n utils -o lib-utils.sh
```

---

## Multi-Tier Documentation

The standard exists in four tiers:

| Tier | Lines | Size | Purpose |
|------|-------|------|---------|
| **complete** | 22,870 | 574 KB | Authoritative source |
| **summary** | 11,178 | 271 KB | Default - condensed |
| **abstract** | 4,107 | 94 KB | High-level overview |
| **rulet** | 775 | 72 KB | Concise rule list |

### Tier Hierarchy

```
.complete.md  (SOURCE - manually edited)
    ↓ bcs compress
.summary.md   (DERIVED)
    ↓ bcs compress
.abstract.md  (DERIVED)

Separate: .rulet.md (Extracted concise rules)
```

The default tier is set by the `data/BASH-CODING-STANDARD.md` symlink. Change with `bcs default <tier>`.

---

## BCS Code System

**Format:** `BCS{section}{rule}[{subrule}]` - All numbers are two-digit zero-padded

| Code | Level | Example |
|------|-------|---------|
| `BCS01` | Section | Script Structure & Layout |
| `BCS0102` | Rule | Shebang and Initial Setup |
| `BCS010201` | Subrule | Dual-Purpose Scripts |

```bash
bcs codes                     # List all codes
bcs decode BCS0102            # Get file path
bcs decode BCS0102 -p         # Print content
```

---

## Repository Structure

```
bash-coding-standard/
├── bcs                       # Main CLI toolkit (170KB)
├── bash-coding-standard      # Symlink → bcs
├── Makefile                  # Installation targets
├── CLAUDE.md                 # AI assistant instructions
├── README.md                 # This file
├── data/                     # Standard source files
│   ├── BASH-CODING-STANDARD.md     # Symlink → default tier
│   ├── BASH-CODING-STANDARD.*.md   # Compiled standards
│   ├── 01-script-structure/        # Section 1
│   ├── ...                         # Sections 2-12
│   └── templates/                  # Script templates
├── BCS/                      # Numeric-indexed symlinks
├── lib/                      # Bundled tools (14 utilities)
├── tests/                    # Test suite (37 files)
├── workflows/                # Maintenance scripts (8 files)
├── examples/                 # Production examples
└── builtins/                 # Optional C builtins (5 commands)
```

---

## Testing

```bash
./tests/run-all-tests.sh              # Run all tests
./tests/test-subcommand-check.sh      # Run specific test
shellcheck -x bcs                     # Static analysis
```

---

## Development Workflow

```bash
# Validate changes before commit
shellcheck -x bcs && ./tests/run-all-tests.sh

# After modifying rules in data/
bcs compress --regenerate && bcs generate --canonical

# Verify BCS codes
bcs codes | wc -l    # Should be 101
```

---

## Security Requirements

| Rule | Requirement |
|------|-------------|
| **No SUID/SGID** | Never use SUID/SGID in Bash scripts |
| **PATH validation** | Lock down PATH or validate it early |
| **Avoid eval** | Never use `eval` with untrusted input |
| **Input sanitization** | Validate all external inputs |
| **Explicit paths** | Use `rm ./*` not `rm *` |
| **Readonly constants** | Use `readonly` for all constants |
| **Argument separator** | Always use `--` before file arguments |

---

## Optional: Performance Builtins

High-performance C implementations (optional enhancement):

| Builtin | Speedup |
|---------|---------|
| `basename` | 101x |
| `dirname` | 158x |
| `realpath` | 20-100x |
| `head` | 10-30x |
| `cut` | 15-40x |

```bash
cd builtins && ./install.sh --user
```

---

## Related Resources

- [ShellCheck](https://www.shellcheck.net/) - Static analysis tool
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) - Compatible where applicable
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) - Official documentation

---

## License

**CC BY-SA 4.0** (Creative Commons Attribution-ShareAlike 4.0 International)

---

## Acknowledgments

- **Developed by:** [Okusi Associates](https://okusiassociates.com)
- **Adopted by:** [Indonesian Open Technology Foundation (YaTTI)](https://yatti.id)

---

*Version 1.0.2*
