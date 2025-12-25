# Bash Coding Standard

A comprehensive coding standard for modern Bash 5.2+ scripts, designed for consistency, robustness, and maintainability.

**Version 1.0.0** | **12 Sections** | **101 Rules** | **13 Subcommands**

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
- **AI-powered** compliance checking and rule compression via Claude

### Target Audience

- Human developers writing production-grade Bash scripts
- AI assistants generating or analyzing Bash code
- DevOps engineers and system administrators
- Organizations needing standardized scripting guidelines

### Minimal Example

A minimal BCS-compliant script:

```bash
#!/usr/bin/env bash
# Brief description of the script
set -euo pipefail
shopt -s inherit_errexit shift_verbose

VERSION='1.0.0'
SCRIPT_PATH=$(realpath -e -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

error() { >&2 printf '%s: %s\n' "$SCRIPT_NAME" "$*"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-1}"; }

main() {
  echo "Hello from $SCRIPT_NAME v$VERSION"
}

main "$@"
#fin
```

---

## Quick Start

### Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| **Bash** | 5.2+ | `bash --version` |
| **ShellCheck** | 0.8.0+ | `shellcheck --version` |
| **Claude CLI** | Latest | `claude --version` (optional, for AI features) |

**Install ShellCheck:**
```bash
# Ubuntu/Debian
sudo apt install shellcheck

# macOS
brew install shellcheck

# Fedora/RHEL
sudo dnf install ShellCheck
```

### Installation

**Quick Install (one-liner):**
```bash
git clone https://github.com/OkusiAssociates/bash-coding-standard.git && cd bash-coding-standard && sudo make install
```

**Standard Installation:**
```bash
git clone https://github.com/OkusiAssociates/bash-coding-standard.git
cd bash-coding-standard

# Run directly (development mode)
./bcs

# Or install system-wide
sudo make install
```

**Makefile Targets:**
```bash
sudo make install              # Install to /usr/local (default)
sudo make PREFIX=/usr install  # Install to /usr (system-wide)
sudo make uninstall            # Remove installation
make help                      # Show all targets
make check-deps                # Check optional dependencies
```

### First Commands

```bash
# View the standard
bcs                              # Auto-detect best viewer
bcs display --cat                # Plain text output

# Generate a BCS-compliant script
bcs template -t complete -n myscript -o myscript.sh -x

# Check script compliance (requires Claude CLI)
bcs check myscript.sh

# Look up BCS rules
bcs codes                        # List all 101 rule codes
bcs decode BCS0102 -p            # View specific rule content
bcs search "readonly"            # Search the standard
```

---

## Complete Subcommand Reference

The `bcs` toolkit provides 13 subcommands for working with the Bash Coding Standard.

### display (Default)

View the coding standard document with multiple output formats.

```bash
bcs                          # Auto-detect viewer (md2ansi → less → cat)
bcs display                  # Explicit display command
```

**Options:**
| Option | Description |
|--------|-------------|
| `-c, --cat` | Force plain text output (bypass md2ansi) |
| `-a, --md2ansi` | Force md2ansi output |
| `-j, --json` | Output as JSON |
| `-b, --bash` | Export as bash variable declaration |
| `-s, --squeeze` | Squeeze consecutive blank lines |
| `-h, --help` | Show help |

**Legacy compatibility:** `bcs -c`, `bcs -j`, `bcs -b` still work.

---

### about

Display project information, statistics, and metadata.

```bash
bcs about                    # Default: project info + philosophy + quick stats
bcs about --stats            # Statistics only
bcs about --json             # JSON output for scripting
```

**Options:**
| Option | Description |
|--------|-------------|
| `-s, --stats` | Show statistics only |
| `-l, --links` | Show documentation links |
| `-v, --verbose` | Show all information |
| `-q, --quote` | Show philosophy quote only |
| `--json` | JSON output |
| `-h, --help` | Show help |

---

### template

Generate BCS-compliant script templates instantly.

```bash
bcs template                           # Generate basic template to stdout
bcs template -t complete -o script.sh -x   # Complete template, executable
bcs template -t library -n mylib       # Library template
```

**Options:**
| Option | Description |
|--------|-------------|
| `-t, --type TYPE` | Template type: `minimal`, `basic`, `complete`, `library` |
| `-n, --name NAME` | Script name (sanitized for bash) |
| `-d, --description DESC` | Script description |
| `-v, --version VERSION` | Version string (default: 1.0.0) |
| `-o, --output FILE` | Output file (default: stdout) |
| `-x, --executable` | Make output file executable |
| `-f, --force` | Overwrite existing file |
| `-h, --help` | Show help |

**Template Types:**
| Type | Lines | Contents |
|------|-------|----------|
| `minimal` | ~13 | `set -euo pipefail`, `error()`, `die()`, `main()` |
| `basic` | ~27 | + metadata, messaging functions, readonly |
| `complete` | ~104 | + colors, arg parsing, all utility functions |
| `library` | ~38 | Sourceable pattern, function exports (no `set -e`) |

**Placeholders:** `{{NAME}}`, `{{DESCRIPTION}}`, `{{VERSION}}`

---

### check

AI-powered compliance checking using Claude CLI.

```bash
bcs check myscript.sh                    # Comprehensive check
bcs check --strict deploy.sh             # Strict mode (for CI/CD)
bcs check --format json script.sh        # JSON output
```

**Options:**
| Option | Description |
|--------|-------------|
| `-s, --strict` | Strict mode (warnings become violations) |
| `-f, --format FORMAT` | Output: `text`, `json`, `markdown`, `bcs-json` |
| `-q, --quiet` | Suppress non-error output |
| `--codes CODE1,CODE2` | Validate only specific BCS codes |
| `--sections N1,N2` | Validate only sections 1-12 |
| `--tier TIER` | Documentation tier: `abstract` (fast), `complete` (thorough) |
| `--severity LEVEL` | Filter: `all`, `violations`, `warnings` |
| `--claude-cmd CMD` | Custom Claude command path |
| `--append-prompt TEXT` | Additional system prompt |
| `--allowed-tools TOOLS` | Restrict Claude tools |
| `--add-dir PATH` | Add directory for Claude context |
| `--skip-permissions` | Skip permission checks |
| `-h, --help` | Show help |

**Exit Codes:** 0 = Compliant, 1 = Warnings only, 2 = Violations

**Requirements:** Claude CLI (`claude` command) in PATH

---

### compress

AI-powered compression of BCS rule files (developer mode).

```bash
bcs compress                              # Report oversized files only
bcs compress --regenerate                 # Regenerate all tiers
bcs compress --regenerate --context-level abstract   # Recommended
```

**Options:**
| Option | Description |
|--------|-------------|
| `--report-only` | Report oversized files only (default) |
| `--regenerate` | Delete and regenerate compressed files |
| `--tier TIER` | Process tier: `summary` or `abstract` |
| `--force` | Force regeneration (bypass timestamp checks) |
| `--summary-limit N` | Max summary size in bytes (default: 10000) |
| `--abstract-limit N` | Max abstract size in bytes (default: 1500) |
| `--context-level LEVEL` | Context: `none`, `toc`, `abstract`, `summary`, `complete` |
| `-n, --dry-run` | Preview changes without writing |
| `-q, --quiet` | Quiet mode |
| `-v, --verbose` | Verbose mode (default) |
| `--claude-cmd CMD` | Claude CLI path |
| `-h, --help` | Show help |

**Context Levels:**
- `none` - Fastest, each rule in isolation (default)
- `abstract` - Recommended, cross-rule deduplication (~83KB context)
- `complete` - Maximum context awareness (~520KB)

---

### codes

List all BCS rule codes from the data/ directory.

```bash
bcs codes                    # List all codes
bcs codes | wc -l            # Count rules (101)
bcs codes | grep variable    # Find variable-related rules
```

**Output Format:** `BCS{code}:{shortname}:{title}`

**Example:**
```
BCS010201:dual-purpose:Dual-Purpose Scripts (Executable and Sourceable)
BCS0103:metadata:Script Metadata
BCS0205:readonly-after-group:Readonly After Group
```

---

### generate

Regenerate BASH-CODING-STANDARD.md from the data/ directory.

```bash
bcs generate                 # Generate to stdout (default tier)
bcs generate --canonical     # Regenerate all canonical files
bcs generate -t abstract     # Generate abstract tier only
```

**Options:**
| Option | Description |
|--------|-------------|
| `-t, --type TYPE` | Tier: `complete`, `summary`, `abstract`, `rulet` |
| `-o, --output FILE` | Output to specific file |
| `--canonical` | Generate all four tiers to canonical files |
| `-x, --exclude CODES` | Exclude BCS codes (comma-separated) |
| `-f, --force` | Force regeneration ignoring timestamps |
| `-h, --help` | Show help |

**Exclusion Examples:**
- `-x 0103` - Exclude BCS0103
- `-x BCS01` - Exclude entire section 1
- `-x 0103,0201,010201` - Multiple exclusions

---

### generate-rulets

Extract concise rulets from complete.md files using AI.

```bash
bcs generate-rulets 02                    # Generate for section 02
bcs generate-rulets variables             # Same - by category name
bcs generate-rulets --all                 # Generate for all 12 categories
bcs generate-rulets --all --force         # Force regeneration
```

**Options:**
| Option | Description |
|--------|-------------|
| `-a, --all` | Generate rulets for all 12 categories |
| `-f, --force` | Force regeneration of existing files |
| `--agent-cmd PATH` | Path to bcs-rulet-extractor agent |
| `-h, --help` | Show help |

**Output:** `data/{NN}-{category}/00-{category}.rulet.md`

**Rulet Format:** `[BCS####] Concise rule statement with `code examples`.`

---

### search

Search within the coding standard document.

```bash
bcs search "readonly"         # Basic search
bcs search -i "SET -E"        # Case-insensitive
bcs search -C 10 "declare -fx"  # With 10 context lines
```

**Options:**
| Option | Description |
|--------|-------------|
| `-i, --ignore-case` | Case-insensitive search |
| `-C NUM` | Show NUM lines of context (default: 3) |
| `-h, --help` | Show help |

---

### decode

Resolve BCS codes to file locations or print rule content.

```bash
bcs decode BCS0102              # Show file path (default tier)
bcs decode BCS0102 -p           # Print rule content
bcs decode BCS01 BCS08 -p       # Multiple codes with separators
vim $(bcs decode BCS0205)       # Open in editor
```

**Options:**
| Option | Description |
|--------|-------------|
| `-a, --abstract` | Show abstract tier |
| `-s, --summary` | Show summary tier |
| `-c, --complete` | Show complete tier |
| `-r, --rulet` | Show rulet tier (section-level only) |
| `-p, --print` | Print file contents instead of path |
| `--all` | Show all three tier locations |
| `--relative` | Output relative to repository root |
| `--basename` | Output only filename |
| `--exists` | Exit 0 if code exists, 1 if not |
| `-h, --help` | Show help |

**Code Formats:**
- Section: `BCS01` (2 digits)
- Rule: `BCS0102` (4 digits)
- Subrule: `BCS010201` (6 digits)

---

### sections

List all 12 sections of the standard.

```bash
bcs sections                 # List all sections
```

**Output:**
```
1. Script Structure & Layout
2. Variables & Data Types
3. Strings & Quoting
...
12. Style & Development
```

---

### default

Set or show the default documentation tier.

```bash
bcs default                  # Show current default tier
bcs default complete         # Set default to complete tier
bcs default --list           # List all available tiers
```

**Options:**
| Option | Description |
|--------|-------------|
| `-l, --list` | List all available tiers (marks current with *) |
| `-h, --help` | Show help |

**Tiers:** `complete`, `summary`, `abstract`, `rulet`

---

### help

Show help for commands.

```bash
bcs help                     # General help with all commands
bcs help check               # Help for specific subcommand
bcs check --help             # Same as above
```

---

## The 12 Sections

The Bash Coding Standard is organized into 12 comprehensive sections:

| # | Section | Key Topics |
|---|---------|------------|
| 1 | **Script Structure & Layout** | 13-step mandatory structure, shebang, metadata, function organization |
| 2 | **Variables & Data Types** | Declarations, scoping, naming, readonly patterns, arrays, parameter expansion |
| 3 | **Strings & Quoting** | Single vs double quotes, mixed quoting, here-docs |
| 4 | **Functions & Libraries** | Definition patterns, organization, export, library patterns |
| 5 | **Control Flow** | Conditionals, case statements, loops, arithmetic |
| 6 | **Error Handling** | `set -e`, exit codes, traps, return value checking |
| 7 | **I/O & Messaging** | Standard messaging functions, colors, TUI basics |
| 8 | **Command-Line Arguments** | Parsing patterns, short option support |
| 9 | **File Operations** | Testing, wildcards, process substitution |
| 10 | **Security** | SUID, PATH, eval, IFS, input sanitization, temp files |
| 11 | **Concurrency & Jobs** | Background jobs, parallel execution, timeouts |
| 12 | **Style & Development** | Formatting, debugging, dry-run, testing |

### Mandatory Script Structure (13 Steps)

Every BCS-compliant script follows this structure:

1. **Shebang:** `#!/usr/bin/env bash`
2. **ShellCheck directives** (if needed): `#shellcheck disable=SC####`
3. **Brief description comment:** One-line purpose
4. **Strict mode:** `set -euo pipefail` (mandatory)
5. **Shell options:** `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. **Script metadata:** VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME → `readonly --`
7. **Global variable declarations:** With explicit types
8. **Color definitions:** If terminal output needed
9. **Utility functions:** Messaging, helpers
10. **Business logic functions:** Core functionality
11. **`main()` function:** Required for scripts >40 lines
12. **Script invocation:** `main "$@"`
13. **End marker:** `#fin` (mandatory)

### Critical Patterns

**Variable Expansion:**
```bash
# Default: no braces
echo "$var"

# Use braces when required:
echo "${var##pattern}"      # Parameter expansion
echo "${var:-default}"      # Default values
echo "${array[@]}"          # Arrays
echo "${var1}${var2}"       # Concatenation
```

**Quoting:**
```bash
# Single quotes for static strings
info 'Processing files...'

# Double quotes when variables needed
info "Processing $count files"

# Always quote in conditionals
[[ -f "$file" ]]
```

**Arithmetic:**
```bash
# Correct increment
i+=1
((i+=1))

# WRONG - fails with set -e when i=0
((i++))
```

**Error Output:**
```bash
# Place >&2 at beginning
>&2 echo "error message"
```

**Process Substitution:**
```bash
# Prefer this (avoids subshell issues)
while IFS= read -r line; do
  count+=1
done < <(command)

# Avoid pipes to while (subshell loses variables)
command | while read -r line; do count+=1; done
```

### Standard Utility Functions

Every compliant script should implement these messaging functions:

```bash
_msg() { ... }         # Core message function using FUNCNAME
vecho() { ... }        # Verbose output (respects VERBOSE)
success() { ... }      # Success messages (green ✓)
warn() { ... }         # Warnings (yellow ▲)
info() { ... }         # Info messages (cyan ◉)
debug() { ... }        # Debug output (respects DEBUG)
error() { ... }        # Unconditional error output (red ✗)
die() { ... }          # Exit with error message
yn() { ... }           # Yes/no prompt
```

### Function Organization Pattern

Organize functions bottom-up:
1. Messaging functions (lowest level)
2. Documentation functions (help, usage)
3. Helper/utility functions
4. Validation functions
5. Business logic functions
6. Orchestration/flow functions
7. `main()` function (highest level)

**Rationale:** Each function can safely call functions defined above it.

---

## Multi-Tier Documentation System

The standard exists in four tiers with decreasing detail levels:

| Tier | Lines | Size | Purpose |
|------|-------|------|---------|
| **complete** | ~24,333 | 610 KB | Authoritative source - full detail, all examples |
| **summary** | ~15,117 | 373 KB | Condensed - key rules, essential examples (default) |
| **abstract** | ~4,439 | 109 KB | High-level overview - rules only |
| **rulet** | ~714 | 72 KB | Concise rule list - one per section |

### Tier Hierarchy

```
.complete.md  (SOURCE - manually edited)
    ↓ bcs compress
.summary.md   (DERIVED - ~62% of complete)
    ↓ bcs compress
.abstract.md  (DERIVED - ~29% of complete)

Separate: .rulet.md (Extracted concise rules)
```

### Default Tier

The default tier is controlled by the `data/BASH-CODING-STANDARD.md` symlink:
- Currently points to `.summary.md`
- Change with: `bcs default complete`

### Tier Workflow

```bash
# Edit source (complete tier only)
vim $(bcs decode BCS0205 -c)

# Regenerate derived tiers
bcs compress --regenerate

# Rebuild canonical files
bcs generate --canonical
```

---

## BCS Code System

### Code Format

`BCS{section}{rule}[{subrule}]` - All numbers are **two-digit zero-padded**

| Code | Level | Example |
|------|-------|---------|
| `BCS01` | Section | Script Structure & Layout |
| `BCS0102` | Rule | Shebang and Initial Setup |
| `BCS010201` | Subrule | Dual-Purpose Scripts |

### Directory Mapping

```
data/01-script-structure/              → BCS01 (Section)
├── 00-section.*.md                    → BCS0100 (Section intro)
├── 02-shebang.*.md                    → BCS0102 (Rule)
├── 02-shebang/01-dual-purpose.*.md    → BCS010201 (Subrule)
└── 03-metadata.*.md                   → BCS0103 (Rule)
```

### BCS/ Index Directory

The `BCS/` directory provides numeric-indexed symlinks for quick lookups:

```
BCS/
├── 01/                      → 01-script-structure/
│   ├── 00.summary.md        → Section intro
│   ├── 02.summary.md        → Rule 02 (Shebang)
│   └── 02/01.summary.md     → Subrule 01 (Dual-Purpose)
└── 02/                      → 02-variables/
```

### Lookup Commands

```bash
bcs codes                     # List all codes
bcs decode BCS0102            # Get file path
bcs decode BCS0102 -p         # Print content
bcs decode BCS0102 --all      # Show all tiers
```

---

## Repository Structure

```
bash-coding-standard/
├── bcs                       # Main CLI toolkit (v1.0.0, 160KB)
├── bash-coding-standard      # Symlink → bcs
├── bcs.1                     # Man page (19KB)
├── bcs.bash_completion       # Bash completion (9KB)
├── Makefile                  # Installation targets
├── CLAUDE.md                 # AI assistant instructions
├── README.md                 # This file
├── LICENSE                   # CC BY-SA 4.0
│
├── data/                     # Standard source files
│   ├── BASH-CODING-STANDARD.md        # Symlink → default tier
│   ├── BASH-CODING-STANDARD.*.md      # Compiled standards (4 tiers)
│   ├── 00-header.*.md                 # Header files (4 tiers)
│   ├── 01-script-structure/           # Section 1
│   ├── 02-variables/                  # Section 2
│   ├── ...                            # Sections 3-12
│   └── templates/                     # Script templates (4 files)
│
├── BCS/                      # Numeric-indexed symlinks
├── lib/                      # Bundled tools (15 utilities, ~544KB)
├── tests/                    # Test suite (34 files, 600+ tests)
├── workflows/                # Maintenance scripts (8 files)
├── examples/                 # Production examples (3 scripts)
├── builtins/                 # Optional C builtins (5 commands)
├── docs/                     # Additional documentation
└── .github/workflows/        # CI/CD (3 workflows)
```

### Data Directory Pattern

Each section directory follows this structure:

```
data/{NN}-{category}/
├── 00-section.complete.md       # Section introduction
├── 00-section.summary.md
├── 00-section.abstract.md
├── 00-{category}.rulet.md       # Concise rules for section
├── {NN}-{rule}.complete.md      # Rule (canonical source)
├── {NN}-{rule}.summary.md       # Rule (derived)
├── {NN}-{rule}.abstract.md      # Rule (derived)
└── {NN}-{rule}/                 # Subrule directory (if any)
    └── {NN}-{subrule}.*.md
```

---

## Templates

Four BCS-compliant templates are available in `data/templates/`:

| Template | Lines | Use Case |
|----------|-------|----------|
| `minimal.sh.template` | ~13 | Quick scripts, bare essentials |
| `basic.sh.template` | ~27 | Standard scripts with metadata |
| `complete.sh.template` | ~104 | Full toolkit, production scripts |
| `library.sh.template` | ~38 | Sourceable libraries |

### Template Contents

**minimal:** `set -euo pipefail`, `error()`, `die()`, `main()`

**basic:** + VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME, `_msg()`

**complete:** + colors, VERBOSE/DEBUG flags, full messaging (`info`, `warn`, `success`, `debug`), argument parsing with `--help`/`--version`

**library:** Sourceable pattern, no `set -e`, `declare -fx` exports, namespace prefix

### Usage Examples

```bash
# Quick script
bcs template -t minimal -o quick.sh -x

# Production script with all utilities
bcs template -t complete -n deploy -d "Production deployment" -v 2.0.0 -o deploy.sh -x

# Sourceable library
bcs template -t library -n utils -o lib-utils.sh
```

---

## Bundled Tools

The `lib/` directory contains 15 vendored utilities (~544KB total):

| Category | Tools | Purpose |
|----------|-------|---------|
| **Markdown** | md2ansi, md, mdheaders | Terminal rendering, header manipulation |
| **Text** | trim, remblanks, post_slug | String processing, slug generation |
| **System** | whichx, dux, printline, bcx | Command location, disk analysis, calculator |
| **Development** | timer, hr2int | Timing, number conversion |
| **BCS Agents** | bcs-rulet-extractor, bcs-compliance | AI integration |

All tools are installed to `/usr/local/bin` via `make install`.

**Full documentation:** See [`lib/README.md`](lib/README.md)

---

## Toolkit Architecture

### Dual-Purpose Design

The `bcs` script can be used in two modes:

**Executed Mode** (`./bcs` or `bcs`):
```bash
# Standard CLI usage
bcs display
bcs check script.sh
bcs template -t complete -o test.sh
```
- Strict mode enabled: `set -euo pipefail`
- Dispatcher runs subcommands
- Returns exit codes

**Sourced Mode** (`source bcs`):
```bash
# Use bcs functions in your scripts
source /usr/local/bin/bcs

# Access pre-loaded standard
echo "$BCS_MD" | head -20

# Use internal functions
cmd_codes
cmd_decode BCS0102
```
- Does NOT set `set -e` (doesn't affect caller)
- All `cmd_*` functions available
- `BCS_MD` variable pre-loaded

### FHS-Compliant Search Paths

The toolkit searches for files in standard locations:

**For BASH-CODING-STANDARD.md:**
1. Script directory (development)
2. `$(PREFIX)/share/yatti/bash-coding-standard/` (custom install)
3. `/usr/local/share/yatti/bash-coding-standard/` (local install)
4. `/usr/share/yatti/bash-coding-standard/` (system install)

### Dispatcher Pattern

The subcommand architecture uses a dispatcher pattern:

```bash
main() {
  local subcmd=${1:-display}
  shift || true
  case "$subcmd" in
    display)   cmd_display "$@" ;;
    about)     cmd_about "$@" ;;
    template)  cmd_template "$@" ;;
    # ... 13 commands total
    *)         die 1 "Unknown command: $subcmd" ;;
  esac
}
```

### Adding New Subcommands

1. **Create function:** `cmd_foo() { ... }; declare -fx cmd_foo`
   - Find location: `grep -n '^cmd_' bcs | tail -5`

2. **Add to dispatcher:** Add case pattern in main dispatch
   - Find location: `grep -n 'case "$subcmd"' bcs`

3. **Add to help:** Update help routing and command list
   - Find location: `grep -n 'show_help\|^Commands:' bcs`

4. **Create test file:** `tests/test-subcommand-foo.sh`

---

## Testing & Development

### Test Suite

| Metric | Value |
|--------|-------|
| Test files | 34 |
| Total tests | 600+ |
| Pass rate | 74% |
| Assertions | 21 types |

### Running Tests

```bash
./tests/run-all-tests.sh              # Run all test suites
./tests/test-subcommand-check.sh      # Run specific test file
./tests/coverage.sh                   # Analyze test coverage
```

### Available Assertions

The test framework (`tests/test-helpers.sh`) provides 21 assertion functions:

**Basic Assertions:**
- `assert_equals` - Compare two values
- `assert_contains` - Check substring presence
- `assert_not_contains` - Check substring absence
- `assert_not_empty` - Verify non-empty value

**Exit Code Assertions:**
- `assert_exit_code` - Check specific exit code
- `assert_success` - Verify exit code 0
- `assert_failure` - Verify non-zero exit

**File Assertions:**
- `assert_file_exists` - Verify file exists
- `assert_dir_exists` - Verify directory exists
- `assert_file_executable` - Verify file is executable
- `assert_file_contains` - Check file content

**Numeric Assertions:**
- `assert_zero` - Verify value is 0
- `assert_not_zero` - Verify value is non-zero
- `assert_greater_than` - Compare values
- `assert_less_than` - Compare values
- `assert_lines_between` - Check line count range

**Pattern Assertions:**
- `assert_regex_match` - Match regex pattern

**Organization:**
- `test_section` - Start named test section
- `test_summary` - Display pass/fail counts

### Test File Categories

**Subcommand Tests (13 files):**
```bash
test-subcommand-display.sh    test-subcommand-about.sh
test-subcommand-template.sh   test-subcommand-check.sh
test-subcommand-compress.sh   test-subcommand-codes.sh
test-subcommand-generate.sh   test-subcommand-generate-rulets.sh
test-subcommand-search.sh     test-subcommand-decode.sh
test-subcommand-sections.sh   test-subcommand-default.sh
test-subcommand-dispatcher.sh
```

**Integration Tests:**
```bash
test-integration.sh           test-execution-modes.sh
test-environment.sh           test-tier-system.sh
test-data-structure.sh        test-self-compliance.sh
```

**Workflow Tests:**
```bash
test-workflow-add.sh          test-workflow-modify.sh
test-workflow-delete.sh       test-workflow-compress.sh
test-workflow-generate.sh     test-workflow-validate.sh
```

### Development Workflow

```bash
# Validate changes before commit
shellcheck -x bcs && ./tests/run-all-tests.sh

# After modifying rules
bcs compress --regenerate && bcs generate --canonical

# Verify BCS codes
bcs codes | wc -l    # Should be 101
```

### CI/CD Workflows

| Workflow | Triggers | Purpose |
|----------|----------|---------|
| `test.yml` | Push, PR | Multi-version Bash testing (5.0, 5.1, 5.2) |
| `shellcheck.yml` | Push, PR | Static analysis |
| `release.yml` | Tag push | Automated releases |

---

## Workflow Scripts

The `workflows/` directory provides 8 production-ready maintenance scripts:

| Script | Purpose |
|--------|---------|
| `01-add-rule.sh` | Create new BCS rules interactively |
| `02-modify-rule.sh` | Safely edit existing rules |
| `03-delete-rule.sh` | Delete rules with safety checks |
| `04-interrogate-rule.sh` | Inspect rules by BCS code |
| `10-compress-rules.sh` | AI-powered rule compression wrapper |
| `20-generate-canonical.sh` | Generate canonical BCS files |
| `30-validate-data.sh` | 11 validation checks for data integrity |
| `40-check-compliance.sh` | Batch compliance checking |

### Usage Examples

```bash
# Add a new rule interactively
./workflows/01-add-rule.sh

# Validate data directory structure
./workflows/30-validate-data.sh

# Interrogate a rule
./workflows/04-interrogate-rule.sh BCS0102 --show-tiers

# Batch compliance check
./workflows/40-check-compliance.sh *.sh --format json
```

### Validation Checks (30-validate-data.sh)

1. Tier file completeness (.complete, .summary, .abstract)
2. BCS code uniqueness (no duplicates)
3. File naming conventions
4. BCS code format validation
5. Section directory naming
6. File size limits (summary ≤10KB, abstract ≤1.5KB)
7. BCS code markers in files
8. #fin markers present
9. Markdown structure validity
10. Cross-reference validation
11. Sequential numbering checks

---

## Examples

Three production-ready example scripts demonstrate BCS patterns:

| Script | Size | Demonstrates |
|--------|------|--------------|
| `production-deploy.sh` | 8.1KB | Deployment automation, rollback, health checks |
| `data-processor.sh` | 4.7KB | CSV processing, validation, statistics |
| `system-monitor.sh` | 9.9KB | Resource monitoring, alerts, logging |

### Example Patterns Demonstrated

**production-deploy.sh:**
- Complete 13-step script structure
- Dry-run mode implementation
- User confirmation prompts
- Rollback capability
- Health check integration
- Error handling with traps

**data-processor.sh:**
- Array operations
- CSV parsing with IFS
- Field validation
- Statistics tracking (counters)
- Color-coded output

**system-monitor.sh:**
- Continuous monitoring loop
- Threshold-based alerts
- Multiple output levels (VERBOSE, DEBUG)
- Log file integration
- Email notification (configurable)

**Location:** `examples/`

---

## Performance Builtins

Optional high-performance C implementations of common commands:

| Builtin | Speedup | Purpose |
|---------|---------|---------|
| `basename` | 101x | Extract filename |
| `dirname` | 158x | Extract directory |
| `realpath` | 20-100x | Resolve symlinks |
| `head` | 10-30x | First N lines |
| `cut` | 15-40x | Field extraction |

### Installation

```bash
cd builtins
./install.sh --user    # User installation
# or
make && sudo make install   # System-wide
```

**Note:** Not required for BCS compliance - purely optional performance enhancement.

**Full documentation:** See [`builtins/README.md`](builtins/README.md)

---

## Security Requirements

BCS Section 12 defines critical security practices:

### Mandatory Security Rules

| Rule | Requirement |
|------|-------------|
| **No SUID/SGID** | Never use SUID/SGID in Bash scripts |
| **PATH validation** | Lock down PATH or validate it early |
| **Avoid eval** | Never use `eval` with untrusted input |
| **Input sanitization** | Validate all external inputs |
| **Explicit paths** | Use `rm ./*` not `rm *` for wildcards |
| **Readonly constants** | Use `readonly` for all constants |
| **Argument separator** | Always use `--` before file arguments |

### Security Patterns

```bash
# Validate PATH
[[ "$PATH" == /usr/local/bin:/usr/bin:/bin ]] || die 1 'Invalid PATH'

# Sanitize input
[[ "$input" =~ ^[a-zA-Z0-9_-]+$ ]] || die 1 'Invalid input'

# Safe file operations
rm -- "$file"                    # Use -- separator
rm ./*.tmp                       # Explicit path for wildcards

# Prevent injection
printf '%s\n' "$user_input"      # printf, not echo
```

### ShellCheck Compliance

ShellCheck is **mandatory** for BCS compliance:

```bash
# Run ShellCheck
shellcheck -x script.sh

# Document exceptions with comments
#shellcheck disable=SC2155  # Intentional local assignment
local -r foo=$(command)
```

---

## Troubleshooting

### Common Issues

**"command not found: bcs"**
```bash
# Check if installed
which bcs || echo "Not installed"

# If using development mode, use full path
./bcs

# Or install system-wide
sudo make install
```

**"BASH-CODING-STANDARD.md not found"**
```bash
# Check symlink
ls -la data/BASH-CODING-STANDARD.md

# Regenerate if missing
bcs generate --canonical
```

**"Claude CLI not found" (for check/compress)**
```bash
# Install Claude Code CLI
# See: https://claude.com/code

# Or specify custom path
bcs check --claude-cmd /path/to/claude script.sh
```

**ShellCheck failures**
```bash
# Run with verbose output
shellcheck -x -f gcc script.sh

# Check specific error codes
# https://www.shellcheck.net/wiki/SCxxxx
```

**Tests failing**
```bash
# Run specific test for debugging
./tests/test-subcommand-check.sh

# Check test coverage
./tests/coverage.sh
```

### Getting Help

```bash
bcs help                  # General help
bcs help <command>        # Command-specific help
bcs about                 # Project information
```

---

## Contributing

Contributions are welcome! Please ensure:

1. All scripts pass ShellCheck: `shellcheck -x script.sh`
2. Tests pass: `./tests/run-all-tests.sh`
3. Follow BCS patterns in all contributions
4. Update documentation for new features

---

## Related Resources

- [ShellCheck](https://www.shellcheck.net/) - Static analysis tool
- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) - Compatible where applicable
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) - Official documentation

---

## License

This project is licensed under **CC BY-SA 4.0** (Creative Commons Attribution-ShareAlike 4.0 International).

See [LICENSE](LICENSE) for details.

---

## Acknowledgments

- **Developed by:** [Okusi Associates](https://okusiassociates.com)
- **Adopted by:** [Indonesian Open Technology Foundation (YaTTI)](https://yatti.id)
- **Philosophy:** "This isn't just a coding standard - it's a systems engineering philosophy applied to Bash." — Biksu Okusi

---

*Updated: 2025-12-25 | Version 1.0.0*
