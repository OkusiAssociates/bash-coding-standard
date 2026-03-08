# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Context

The **Bash Coding Standard (BCS)** defines 101 concise, actionable rules across 12 sections for Bash 5.2+ scripts. Designed by Okusi Associates for the Indonesian Open Technology Foundation (YaTTI).

**Target audience:** Both human programmers and AI assistants. Rules must be clear enough that AI agents don't make mistakes. Examples of core functions are deliberate and must remain. No rules should be lost or diminished.

## Development Commands

```bash
# Validate changes (always run both together)
shellcheck -x bcs bcscheck && ./tests/run-all-tests.sh

# Run a single test suite
./tests/test-subcommand-template.sh

# Regenerate standard from section files (after editing data/*.md)
./bcs generate

# Verify all BCS codes present
./bcs codes | wc -l    # Should be 101

# Or via make targets (equivalent shortcuts)
make check    # shellcheck -x bcs bcscheck
make test     # ./tests/run-all-tests.sh

# Install / uninstall
sudo make install
sudo make uninstall
```

`bcscheck` is a thin wrapper that calls `bcs check --strict --fast` — it always treats warnings as violations and uses low effort for speed.

## Architecture

### Standard Document Pipeline

The standard is assembled from 12 section source files:

```
data/01-script-structure.md  →  ./bcs generate  →  data/BASH-CODING-STANDARD.md
data/02-variables.md         →                      (single assembled document)
...                          →
data/12-style-development.md →
```

**Never edit `BASH-CODING-STANDARD.md` directly** — edit the section files and regenerate.

### BCS Code Format

`BCS{sectionNo}{ruleNo}` — always 4 digits, zero-padded. Each rule is a `## BCS####` header in its section file.

Examples: `BCS0101` (Section 1, Rule 01), `BCS0505` (Section 5, Rule 05)

### Subcommand Dispatcher

The `bcs` script uses a `case` dispatcher in `main()`:

| Command | Purpose |
|---------|---------|
| `display` | View standard document (default when no args) |
| `template` | Generate BCS-compliant script templates |
| `check` | AI-powered compliance checking (`--model sonnet` default, `--fast` for low effort) |
| `codes` | List all BCS rule codes from section files |
| `generate` | Concatenate section files into BASH-CODING-STANDARD.md |
| `help` | Show help for a command |

Each subcommand follows the pattern: `cmd_NAME()` function + `show_NAME_help()` function + case entry in `main()`.

### Adding a New Subcommand

1. Create function: `cmd_foo() { ... }`
2. Add help function: `show_foo_help() { ... }`
3. Add case pattern in `main()` dispatcher
4. Add to `cmd_help()` routing
5. Create test file: `tests/test-subcommand-foo.sh`

Every subcommand's argument loop must include an option bundling pattern for combined short options. The character class must list all short options for that subcommand:

```bash
-[tndVoxfh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

### `check` Subcommand Internals

`cmd_check()` creates a temp directory and `cd`s into it before invoking `claude`, and clears `CLAUDECODE=`. This prevents Claude from loading the local `CLAUDE.md`, ensuring the compliance check uses only the BCS standard as its prompt context.

The BCS standard is passed via `--system-prompt` (enabling prompt caching) and only the script content goes through `-p`. Defaults to `--model sonnet` for speed; use `-m/--model` to override. The `-f/--fast` flag adds `--effort low` for quick checks.

### FHS Search Path Resolution

Both `find_bcs_md()` and `find_data_dir()` search in order:
1. `$SCRIPT_DIR/data` (development mode — script's own directory)
2. `${SCRIPT_DIR%/bin}/share/yatti/BCS/data` (relative PREFIX)
3. `/usr/local/share/yatti/BCS/data` (local install)
4. `/usr/share/yatti/BCS/data` (system install)

### Test Framework

Tests use `test-helpers.sh` which provides assertion functions and shared state:

```bash
source "$(dirname "$0")"/test-helpers.sh   # Sets up BCS_CMD, DATA_DIR, counters

begin_test 'description'                   # Increment TESTS_RUN, set CURRENT_TEST
assert_equal expected actual [msg]         # String equality
assert_contains haystack needle [msg]      # Substring match
assert_matches value pattern [msg]         # Regex match
assert_not_empty value [msg]               # Non-empty check
assert_success msg command [args...]       # Exit code 0
assert_fails msg command [args...]         # Non-zero exit
assert_file_exists path [msg]              # File existence
assert_gt actual threshold [msg]           # Numeric comparison
print_summary 'suite-name'                # Final pass/fail summary (exits non-zero on failure)
```

Each test file is standalone — `run-all-tests.sh` iterates `test-*.sh` files (skipping `test-helpers.sh`).

## Mandatory Script Structure (13 Steps)

1. Shebang: `#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash`
2. ShellCheck directives (if needed)
3. Brief description comment
4. `set -euo pipefail` (mandatory)
5. `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. Script metadata: `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME` with `declare -r`
7. Global variable declarations
8. Color definitions (if terminal output)
9. Utility functions (messaging, helpers)
10. Business logic functions
11. `main()` function (required for scripts >200 lines)
12. Script invocation: `main "$@"`
13. End marker: `#fin` (mandatory)

## Critical Anti-Patterns

```bash
# wrong — double quotes for static strings
info "Checking prerequisites..."     # use single quotes
# wrong — unnecessary braces
echo "${PREFIX}/bin"                  # use "$PREFIX"/bin
# wrong — dangerous increment
((count++))                          # use count+=1
# wrong — unquoted variable in [ ]
[ -f $file ]                         # use [ -f "$file" ] or [[ -f "$file" ]]
# wrong — pipe to while
command | while read -r line; do     # use < <(command)
# wrong — local without --
local file="$1"                      # use local -- file="$1"
# wrong — redundant arithmetic
if ((count > 0)); then               # use if ((count)); then
```

## Standard Utility Functions

Functions defined in the `bcs` script itself:

```bash
_msg()    # Core message function using FUNCNAME dispatch
info()    # Info messages (cyan ◉), respects VERBOSE
success() # Success messages (green ✓), respects VERBOSE
warn()    # Warnings (yellow ▲), always shown
error()   # Error output (red ✗), always shown
die()     # Exit with error: die exit_code [messages...]
noarg()   # Argument validation: noarg "$@" inside option parsing
```

The BCS standard also defines `yn()` and `vecho()` for use in compliant scripts, but these are not used in `bcs` itself.

## Template System

Placeholders: `{{NAME}}`, `{{DESCRIPTION}}`, `{{VERSION}}`

Types: minimal (~15 lines), basic (~25 lines), complete (~105 lines), library (~39 lines)

## Exit Codes

| Code | Use Case |
|------|----------|
| 0 | Success |
| 1 | General error |
| 2 | Usage error |
| 3 | File not found |
| 5 | I/O error |
| 13 | Permission denied |
| 18 | Missing dependency |
| 22 | Invalid argument |
| 24 | Timeout |

## Key Constraints

- **Single standard document** — no tier system; one definitive document
- **BCS codes are 4-digit** — format `BCS{section}{rule}`, always zero-padded
- **`realpath` not `readlink`** — this repo uses `realpath` exclusively
- **Shebang:** `#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash`
- **Rules must be preserved** — never lose or diminish rules
- **Examples are deliberate** — do not remove core function examples
