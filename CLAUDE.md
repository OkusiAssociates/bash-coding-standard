# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Context

This is the **canonical Bash coding standard repository** designed by Okusi Associates and used by the Indonesian Open Technology Foundation (YaTTI) and others. It defines comprehensive Bash coding guidelines for Bash 5.2+ scripts exclusively. This is not a compatibility standard - it presumes modern Bash.

**Target audience:** Both human programmers and AI assistants

**Key principle:** Rules must be clear and demonstrated so that both programmers and AI assistants completely understand them. Examples of core functions are deliberate and must remain. No rules should be lost or diminished.

## Repository Files

### Primary Documents
- **`BASH-CODING-STANDARD.md`** - The complete coding standard (2,945 lines, 14 sections)
- **`README.md`** - Comprehensive repository introduction and quick start guide
- **`LICENSE`** - CC BY-SA 4.0 license

### Scripts
- **`bash-coding-standard`** - Multi-command CLI toolkit (v1.0.0) with 11 subcommands
  - Dual-purpose: Can be executed or sourced for function access
  - Modern subcommand architecture with dispatcher pattern
  - FHS-compliant search paths for BASH-CODING-STANDARD.md
  - See "Subcommand Architecture" section below for details

### Templates
- **`data/templates/`** - BCS-compliant script templates for rapid prototyping
  - `minimal.sh.template` - Bare essentials (~13 lines)
  - `basic.sh.template` - Standard with metadata (~27 lines)
  - `complete.sh.template` - Complete toolkit (~104 lines)
  - `library.sh.template` - Sourceable library pattern (~38 lines)

### Tests
- **`tests/`** - Comprehensive test suite (19 test scripts, 600+ tests, 74% pass rate)
  - `run-all-tests.sh` - Master test runner
  - `test-helpers.sh` - Shared assertion functions with 12 enhanced helpers
  - `coverage.sh` - Test coverage analyzer (39% function coverage, 100% command coverage)
  - `test-bash-coding-standard.sh` - Core functionality tests
  - `test-subcommand-*.sh` - Individual subcommand test suites (11 subcommands)
  - `test-data-structure.sh` - Data directory integrity validation
  - `test-integration.sh` - End-to-end workflow tests
  - `test-self-compliance.sh` - BCS compliance self-validation
  - Test pattern: Each subcommand has dedicated test file
  - See `TESTING-SUMMARY.md` for complete test documentation

### Builtins (Separate Sub-Project)
- **`builtins/`** - High-performance bash loadable builtins (10-158x faster)
  - Separate sub-project with own build system, tests, and documentation
  - Provides C implementations of: basename, dirname, realpath, head, cut
  - Optional performance enhancement (not required for BCS compliance)
  - See builtins/README.md for complete documentation
  - Install: `cd builtins && ./install.sh --user`

## Document Architecture: 14 Sections

The BASH-CODING-STANDARD.md is organized bottom-up (low-level to high-level):

1. **Script Structure & Layout** - Complete script organization with full example (includes Function Organization pattern)
2. **Variable Declarations & Constants** - All variable patterns including readonly, boolean flags, derived variables
3. **Variable Expansion & Parameter Substitution** - When to use braces vs simple `"$var"` form
4. **Quoting & String Literals** - Single vs double quotes, when each is required
5. **Arrays** - Declaration, iteration, safe list handling
6. **Functions** - Definition, organization, export, production optimization
7. **Control Flow** - Conditionals, case statements (compact vs expanded format), loops, arithmetic
8. **Error Handling** - Consolidated: `set -e`, exit codes, traps, return value checking
9. **Input/Output & Messaging** - Standard messaging functions, colors, echo vs messaging
10. **Command-Line Arguments** - Parsing patterns with short option support, validation, argument parsing location
11. **File Operations** - Testing, wildcards, process substitution, here docs
12. **Security Considerations** - SUID, PATH, eval, IFS, input sanitization
13. **Code Style & Best Practices** - Formatting, language practices, development practices (organized into themed subsections)
14. **Advanced Patterns** - Dry-run, testing, progressive state management, temp files, logging, performance

## BCS Code Structure

The Bash Coding Standard uses a hierarchical code system to uniquely identify every rule and subrule. BCS codes are derived directly from the `data/` directory structure.

**Format:** `BCS{catNo}[{ruleNo}][{subruleNo}]`
- All numbers are always **two digits** (zero-padded)
- Examples: `BCS01`, `BCS0102`, `BCS010201`

**Directory Structure Mapping:**
```
data/
├── 01-script-structure/              → BCS01 (Section/Category)
│   ├── 02-shebang.md                → BCS0102 (Rule)
│   ├── 02-shebang/                  → (Subrule container)
│   │   └── 01-dual-purpose.md       → BCS010201 (Subrule)
│   ├── 03-metadata.md               → BCS0103 (Rule)
│   └── 04-fhs.md                    → BCS0104 (Rule)
├── 02-variables/                     → BCS02 (Section/Category)
│   ├── 01-type-specific.md          → BCS0201 (Rule)
│   └── 02-scoping.md                → BCS0202 (Rule)
```

**List all codes:**
```bash
# Display all BCS codes with their descriptions
./bcs codes

# Example output:
# BCS01:script-structure:Script Structure & Layout
# BCS0102:shebang:Shebang and Initial Setup
# BCS010201:dual-purpose:Dual-Purpose Scripts (Executable and Sourceable)
# BCS0103:metadata:Script Metadata

# Legacy script (deprecated, use 'bcs codes' instead)
./getbcscode.sh
```

**How Codes Are Generated:**
1. Extract all numeric prefixes from the file path
2. Strip hyphens and concatenate digits
3. Prefix with "BCS"

**Examples:**
- `data/01-script-structure/02-shebang.md` → `01` + `02` → `BCS0102`
- `data/01-script-structure/02-shebang/01-dual-purpose.md` → `01` + `02` + `01` → `BCS010201`
- `data/14-advanced-patterns/03-temp-files.md` → `14` + `03` → `BCS1403`

**Key Principles:**
- **Never use non-numeric prefixes** (e.g., `02a-`, `02b-`) - they break the code system
- **Use subdirectories for subrules** instead of alphabetic suffixes
- **Maintain two-digit zero-padding** for all directory/file names (e.g., `01-`, `02-`, not `1-`, `2-`)
- The system supports **unlimited nesting depth** for sub-subrules (e.g., `BCS01020301`)

## Subcommand Architecture

The `bash-coding-standard` script is a multi-command CLI toolkit with a dispatcher pattern. Understanding this architecture is critical when adding new features.

### Command Structure

```bash
# Pattern: bcs SUBCOMMAND [OPTIONS] [ARGS]
./bcs display --cat              # Subcommand: display
./bcs about --stats              # Subcommand: about
./bcs template -t complete -o test.sh  # Subcommand: template
./bcs check script.sh            # Subcommand: check
```

### How the Dispatcher Works

1. **Entry point** (lines 1374-1402):
   - Parse global options (-h, -V)
   - Extract first argument as `subcommand`
   - Handle backward compatibility (arguments starting with `-`)

2. **Dispatcher** (lines 1404-1439):
   - Routes to appropriate `cmd_SUBCOMMAND()` function
   - **No command aliases** - all aliases removed for simplicity (v1.0.0+)
   - Unknown commands show error and exit with code 2

3. **Subcommand Functions**:
   - Each subcommand is a `cmd_NAME()` function (e.g., `cmd_display()`, `cmd_about()`)
   - Self-contained: includes own argument parsing and help text
   - Declared with `declare -fx` for export when sourced
   - Help shown with: `bcs SUBCOMMAND --help` or `bcs help SUBCOMMAND`

### The 11 Subcommands

1. **display** - View standard document
2. **about** - Project information and statistics
3. **template** - Generate BCS-compliant templates
4. **check** - AI-powered compliance checking
5. **compress** - Compress rules using Claude AI (developer mode)
6. **codes** - List all BCS rule codes
7. **generate** - Regenerate standard from data/
8. **search** - Search within standard
9. **decode** - Decode BCS code to file location or print contents
   - **Default tier: determined by BASH-CODING-STANDARD.md symlink** (v1.0.0+)
   - Function `get_default_tier()` reads symlink to set default
   - Supports section codes (2-digit like BCS01) → returns 00-section.{tier}.md
   - Accepts multiple codes on command line (v1.0.0+)
   - Use `-p` flag to print content directly
10. **sections** - List all 14 sections
11. **help** - Show help for commands

**Note**: All command aliases removed in v1.0.0 for simplification.

### Adding a New Subcommand

To add a new subcommand `foo`:

1. **Create the function** (around line 882-1115):
```bash
cmd_foo() {
  # Parse arguments
  while (($#)); do
    case "$1" in
      -h|--help) cat <<'EOF'
bcs foo - Description
Usage: bcs foo [OPTIONS]
...
EOF
        return 0
        ;;
      # ... other options
    esac
  done

  # Implementation
}
declare -fx cmd_foo
```

2. **Add to dispatcher** (lines 1404-1439):
```bash
case "$subcommand" in
  # ... existing cases
  foo|foo-alias)
    cmd_foo "$@"
    ;;
```

3. **Add to help** (lines 1118-1203):
```bash
# In cmd_help() topic routing:
foo|foo-alias)
  cmd_foo --help
  ;;

# In general help command list:
  foo                Brief description
```

4. **Create test file** `tests/test-subcommand-foo.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/test-helpers.sh"
SCRIPT="$(dirname "${BASH_SOURCE[0]}")/../bash-coding-standard"

test_foo_basic() {
  # Test implementation
}

test_foo_basic
test_summary
```

## Development Commands

### Testing
```bash
# Run all test suites
./tests/run-all-tests.sh

# Run specific subcommand tests
./tests/test-subcommand-about.sh
./tests/test-subcommand-template.sh
./tests/test-subcommand-check.sh

# Run single test (edit test file, comment out other tests)
./tests/test-bash-coding-standard.sh

# Test pattern: Each file reports passed/failed count
```

### Validation
```bash
# Mandatory - all scripts must pass
shellcheck -x bash-coding-standard
shellcheck -x tests/*.sh

# Syntax check
bash -n bash-coding-standard

# Test specific subcommand functionality
./bcs about --help              # Should show help
./bcs template -t minimal       # Should output template
./bcs codes | head -5           # Should list codes
```

### Using the Toolkit
```bash
# View the standard
./bcs                           # Auto-detect viewer
./bcs display --cat             # Force plain text

# Project information
./bcs about                     # General info
./bcs about --stats             # Statistics
./bcs about --json              # JSON output

# Generate templates
./bcs template                  # Basic template to stdout
./bcs template -t complete -o test.sh -x  # Complete template, executable
./bcs template -t library -n mylib    # Library template

# Check compliance (requires Claude CLI)
./bcs check myscript.sh         # AI-powered check
./bcs check --strict deploy.sh  # Strict mode for CI/CD

# Work with rules
./bcs codes                     # List all BCS codes
./bcs decode BCS010201 -p       # View specific rule (default tier from symlink)
./bcs search readonly           # Search in standard

# Decode BCS codes (v1.0.0+)
./bcs decode BCS0102            # Print file path (tier from BASH-CODING-STANDARD.md symlink)
./bcs decode BCS0102 -p         # Print contents to stdout (default tier)
./bcs decode BCS0102 -c -p      # Print complete tier contents
./bcs decode BCS01              # Section code - shows 00-section.{tier}.md path
./bcs decode BCS01 BCS02 -p     # Multiple section codes with contents
./bcs decode BCS0102 -p | less  # View rule with pager
./bcs decode BCS0102 --all      # Show all three tier file paths

# Regenerate standard
./bcs generate                  # To stdout (safe)
./bcs generate --canonical      # Overwrite BASH-CODING-STANDARD.md
./bcs generate -t abstract -o /tmp/BCS-short.md
```

### Installation
```bash
# Install to /usr/local (default)
sudo make install

# Install to /usr (system-wide)
sudo make PREFIX=/usr install

# Uninstall
sudo make uninstall

# View Makefile help
make help
```

## Mandatory Script Structure (13 Steps)

1. Shebang: `#!/usr/bin/env bash` (or `#!/bin/bash`, `#!/usr/bin/bash`)
2. ShellCheck directives (if needed): `#shellcheck disable=SCxxxx`
3. Brief description comment
4. `set -euo pipefail` (mandatory)
5. `shopt` settings (strongly recommended: `shopt -s inherit_errexit shift_verbose extglob nullglob`)
6. Script metadata:
   ```bash
   VERSION='1.0.0'
   SCRIPT_PATH=$(realpath -- "$0")
   SCRIPT_DIR=${SCRIPT_PATH%/*}
   SCRIPT_NAME=${SCRIPT_PATH##*/}
   readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME
   ```
7. Global variable declarations
8. Color definitions (if terminal output)
9. Utility functions (messaging, helpers)
10. Business logic functions
11. `main()` function (required for scripts >40 lines)
12. Script invocation: `main "$@"`
13. End marker: `#fin` (mandatory)

## Critical Patterns

**Variable Expansion:**
- Default: `"$var"` (no braces)
- Use braces only when required: `"${var##pattern}"`, `"${var:-default}"`, `"${array[@]}"`, `"${var1}${var2}"`

**Quoting:**
- Single quotes for static strings: `info 'Processing files...'`
- Double quotes when variables/commands needed: `info "Processing $count files"`
- Always quote variables in conditionals: `[[ -f "$file" ]]`

**Arithmetic:**
- Use `i+=1` or `((i+=1))` for increment
- Never `((i++))` - returns original value, fails with `set -e` when i=0

**Conditionals:**
- Use `[[ ]]` not `[ ]`
- Use `(())` for arithmetic conditionals

**Error Output:**
- Place `>&2` at beginning of command: `>&2 echo "error message"`

**Process Substitution:**
- Prefer `< <(command)` over pipes to while loops (avoids subshell issues)

## Standard Utility Functions

Every compliant script should implement these (but remove unused ones in production):

```bash
_msg() { ... }                    # Core message function using FUNCNAME
vecho() { ... }                   # Verbose output
success() { ... }                 # Success messages
warn() { ... }                    # Warnings
info() { ... }                    # Info messages
debug() { ... }                   # Debug output
error() { ... }                   # Unconditional error output
die() { ... }                     # Exit with error
yn() { ... }                      # Yes/no prompt
noarg() { ... }                   # Argument validation
```

See Section 9 for full implementations.

## Function Organization Pattern

Organize functions bottom-up (Section 1):
1. Messaging functions (lowest level - used by everything)
2. Documentation functions (help, usage)
3. Helper/utility functions
4. Validation functions
5. Business logic functions
6. Orchestration/flow functions
7. `main()` function (highest level - orchestrates everything)

**Rationale:** Each function can safely call functions defined above it. Readers understand primitives first, then composition.

## Production Script Optimization

Once a script is mature (Section 6):
- Remove unused utility functions (e.g., `yn()`, `decp()`, `trim()`, `s()` if not used)
- Remove unused global variables (e.g., `PROMPT`, `DEBUG` if not referenced)
- Remove unused messaging functions
- Keep only what the script actually needs

## Template System

Templates are stored in `data/templates/` and use placeholder substitution for customization.

### Template Placeholders

All templates support these placeholders:
- `{{NAME}}` - Script or library name (auto-inferred from output filename if not specified)
- `{{DESCRIPTION}}` - Brief description comment
- `{{VERSION}}` - Version string (default: 1.0.0)

### Template Types

**minimal.sh.template** (~13 lines):
- Bare essentials for BCS compliance
- `set -euo pipefail`
- `error()` and `die()` functions
- `main()` function
- Use for: Quick scripts, throwaway automation

**basic.sh.template** (~27 lines):
- Standard template with metadata
- Adds: VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME
- `_msg()` helper function
- readonly declarations
- Use for: Most production scripts

**complete.sh.template** (~104 lines):
- Complete toolkit with all utilities
- Colors support (terminal detection)
- Complete messaging suite: vecho, success, warn, info, debug
- Argument parsing: --help, --version, --verbose, --quiet, --debug
- `yn()` prompt function
- Use for: Complex scripts, user-facing tools

**library.sh.template** (~38 lines):
- Sourceable library pattern
- Namespace-prefixed variables and functions (`{{NAME}}_`)
- Exported functions (`declare -fx`)
- Initialization function (`{{NAME}}_init()`)
- No `set -e` (doesn't modify caller's shell)
- Use for: Shared functions, library modules

### Template Usage Pattern

```bash
# Prototype quickly
./bcs template -t minimal > test.sh
chmod +x test.sh

# Production script
./bcs template -t complete -n deploy -d "Deploy to production" \
  -v "1.5.0" -o deploy.sh -x

# Shared library
./bcs template -t library -n auth -d "Authentication utilities" \
  -o lib-auth.sh
```

## AI-Powered Compliance Checking

The `bcs check` subcommand uses Claude AI to validate scripts against the full standard.

### How It Works

1. **Load full standard** - Embeds entire BASH-CODING-STANDARD.md (2,384 lines) as system prompt
2. **Construct prompt** - Adds validation instructions and output format requirements
3. **Read script** - Loads target script content
4. **Invoke Claude** - Pipes script to `claude -p "$system_prompt"`
5. **Return analysis** - Claude provides comprehensive, context-aware compliance check

### Key Advantages

- **Context-aware**: Understands WHY rules exist, not just WHAT they are
- **Natural language**: Returns helpful explanations, not cryptic error codes
- **Intent recognition**: Recognizes legitimate exceptions mentioned in standard
- **Comment evaluation**: Assesses whether comments explain WHY (good) vs WHAT (bad)
- **Self-updating**: Automatically reflects changes to BASH-CODING-STANDARD.md

### Output Format

**Text mode** (default):
```
✓ COMPLIANT: [Section/Rule] - Brief explanation
✗ VIOLATION: [Section/Rule] - Critical issue at line X
⚠ WARNING: [Section/Rule] - Potential issue at line Y
💡 SUGGESTION: [Best practice] - Improvement at line Z
```

**JSON mode** (`--format json`):
- Machine-parseable for CI/CD integration
- Structured violations, warnings, suggestions
- Compliance metrics and assessment

**Markdown mode** (`--format markdown`):
- Well-formatted report with headings
- Code examples where relevant
- Actionable recommendations

### Requirements

- **Claude CLI** must be installed: `https://claude.ai/code`
- Command must be available in PATH (default: `claude`)
- Alternative command: `bcs check --claude-cmd /path/to/claude`

## bash-coding-standard Script Architecture

### Dual-Purpose Design
The script works both as executable and sourceable library:

**Executed mode** (lines 1358-1439):
- Sets `set -euo pipefail` and `shopt` settings
- Finds BASH-CODING-STANDARD.md in FHS locations
- Dispatches to subcommand functions

**Sourced mode** (lines 1336-1354):
- Skips `set -e` (doesn't modify caller's shell)
- Pre-loads `BCS_MD` variable with file content
- Makes all variables readonly (BCS_VERSION, BCS_PATH, BCS_DIR, BCS_FILE, BCS_MD)
- Exports all `cmd_*` functions for direct use

### FHS Compliance

Script searches for BASH-CODING-STANDARD.md in standard locations (function `find_bcs_file()`):
1. Script directory (development mode)
2. `/usr/local/share/yatti/bash-coding-standard/` (local install)
3. `/usr/share/yatti/bash-coding-standard/` (system install)

This enables both development (`./bcs`) and system-wide usage (`bcs`) after installation.

### Known BCS0101 Compliance Issues

**Status**: The `bash-coding-standard` script (also aliased as `bcs`) should serve as a **model example of a dual-purpose script** (both sourceable and executable). It is largely BCS0101-compliant and successfully demonstrates the dual-purpose pattern, but has specific structural deficiencies when analyzed against the strict 13-step BCS0101 layout.

**Self-Analysis Observation**: There are deficiencies in how the script analyzes itself for BCS0101 compliance. This may be related to how the rules are organized and/or broken down in the standard itself.

**Critical BCS0101 Violations Identified:**

1. **`set -euo pipefail` location** (Step 4 violation)
   - **Current**: Located at line 2505 in executed mode section
   - **Expected**: Should be at line 4 (immediately after description comment)
   - **Impact**: Does not enforce strict error handling for most of the script's function definitions

2. **Missing `main()` function** (Step 11 violation)
   - **Current**: Direct command dispatcher at lines 2519-2588 with no `main()` wrapper
   - **Expected**: All execution logic should be within a `main()` function
   - **Impact**: Cannot be easily tested; global code execution instead of orchestrated flow
   - **Note**: Script is 2,591 lines, well over the 40-line threshold requiring `main()`

3. **Dual-purpose structure non-standard** (Step 2 violation)
   - **Current**: Uses conditional check `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]` at line 2503
   - **Expected**: BCS0101 dual-purpose pattern places library functions first, then sourcing check, then executable section with strict mode
   - **Impact**: `set -euo pipefail` only applies when executed, not when defining functions

**Lower-Severity Issues:**

4. **Color variable declarations** (Step 8 violation)
   - **Current**: Uses `declare --` for color variables (lines 17-19)
   - **Expected**: Should use `readonly --` per BCS0101
   - **Note**: Changed from `readonly` to `declare` to fix test re-sourcing errors (pragmatic workaround)

5. **Incomplete `shopt` settings** (Step 5 violation)
   - **Current**: Only sets `shopt -s extglob nullglob` (line 2506)
   - **Expected**: Should include `inherit_errexit shift_verbose` per BCS0101 recommendations

**Architectural Considerations:**

The `bash-coding-standard` script demonstrates the tension between:
- Being a 2,591-line complex CLI toolkit with 11 subcommands
- Following the strict 13-step BCS0101 structure
- Serving as both a sourceable library and standalone executable

**Recommended Restructuring** (for full BCS0101 compliance):
```bash
#!/bin/bash
# bash-coding-standard - BCS compliance toolkit
# Can be executed or sourced for function access
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Metadata (steps 6-7)
VERSION='1.0.0'
# ... standard metadata pattern ...

# Color definitions (step 8) - use readonly
if [[ -t 1 && -t 2 ]]; then
  readonly -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' # ...
else
  readonly -- RED='' GREEN='' # ...
fi

# All utility and subcommand functions (steps 9-10)
cmd_display() { ... }
cmd_about() { ... }
# ... all other cmd_* functions ...

# Main function (step 11)
main() {
  local -- subcommand="${1:-display}"
  shift || true

  case "$subcommand" in
    display|show) cmd_display "$@" ;;
    about|info) cmd_about "$@" ;;
    # ... all subcommand routing ...
  esac
}

# Dual-purpose check and invocation (step 12)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

#fin
```

**Current Priority**: The script is functional and demonstrates dual-purpose usage effectively. Full BCS0101 restructuring would be beneficial for making it a true reference implementation, but is not blocking current functionality.

**Testing Implications**: Self-compliance checking may need refinement as the rule organization/breakdown could be affecting how the script analyzes its own structure.

## When Creating/Refactoring Scripts

1. **Follow the exact 13-step structure** from BASH-CODING-STANDARD.md Section 1
2. **Use standard utility functions** - include full implementations from Section 9
3. **Implement standard argument parsing** - including short options processing (Section 10)
4. **Use proper error handling** - traps, return value checking (Section 8)
5. **End with `#fin` marker** - mandatory
6. **Pass ShellCheck** - use `#shellcheck disable=SCxxxx` only with explanatory comments
7. **Remove unused functions** - before production deployment (Section 6)

## Critical Anti-Patterns to Avoid

```bash
# ✗ Wrong - double quotes for static strings
info "Checking prerequisites..."

# ✓ Correct
info 'Checking prerequisites...'

# ✗ Wrong - unnecessary braces
echo "${PREFIX}/bin"

# ✓ Correct
echo "$PREFIX/bin"

# ✗ Wrong - dangerous increment
((i++))

# ✓ Correct
i+=1

# ✗ Wrong - unquoted variable in conditional
[[ -f $file ]]

# ✓ Correct
[[ -f "$file" ]]

# ✗ Wrong - pipe to while (creates subshell, variables don't persist)
command | while read -r line; do
  count+=1
done

# ✓ Correct - process substitution
while IFS= read -r line; do
  count+=1
done < <(command)
```

## Special Patterns to Preserve

### Boolean Flags Pattern (Section 2)
```bash
declare -i INSTALL_BUILTIN=0
declare -i DRY_RUN=0

# Test with (())
((DRY_RUN)) && info 'Dry-run mode enabled'
```

### Readonly After Group Pattern (Section 2)
```bash
# Declare first
VERSION='1.0.0'
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}

# Then make readonly together
readonly -- VERSION SCRIPT_PATH SCRIPT_DIR
```

### Derived Variables Pattern (Section 2)
```bash
# Base values
declare -- PREFIX=/usr/local

# Derived paths - update when PREFIX changes
declare -- BIN_DIR="$PREFIX"/bin
declare -- LIB_DIR="$PREFIX"/lib
```

### Dry-Run Pattern (Section 14)
```bash
declare -i DRY_RUN=0

build_standalone() {
  if ((DRY_RUN)); then
    info '[DRY-RUN] Would build standalone binaries'
    return 0
  fi
  # Actual build operations
}
```

### Progressive State Management (Section 14)
Use boolean flags that change based on runtime conditions, separating decision logic from execution.

## Code Style Essentials

- **Indentation**: 2 spaces (never tabs)
- **Line length**: 100 characters (except URLs/paths)
- **Comments**: Explain WHY (rationale, business logic), not WHAT (code already shows)
- **Naming**:
  - Constants/Environment: `UPPER_CASE`
  - Functions: `lowercase_with_underscores`
  - Local variables: `lower_case`
- **ShellCheck**: Compulsory - document any disabled checks

## Security Requirements

- Never use SUID/SGID in Bash scripts
- Lock down PATH or validate it
- Avoid `eval` wherever possible
- Use explicit paths for wildcards: `rm ./*` not `rm *`
- Validate inputs early with sanitization functions
- Use `readonly` for constants
- Always use `--` separator before file arguments

## Data Directory Structure

The `data/` directory contains source files that generate BASH-CODING-STANDARD.md. Understanding this structure is critical for adding or modifying rules.

### BCS Rules Filename Structure

**Filename Format:**
```
[0-9][0-9]-{short-rule-desc}.{tier}.md
```

Where:
- `[0-9][0-9]` = Two-digit zero-padded number (01, 02, 03, etc.)
- `{short-rule-desc}` = Brief descriptive name (e.g., `layout`, `shebang`, `readonly-after-group`)
- `{tier}` = One of: `complete`, `summary`, or `abstract`

**Example:**
```
01-script-structure/
├── 01-layout.complete.md       # BCS0101 - Complete tier
├── 01-layout.summary.md        # BCS0101 - Summary tier
├── 01-layout.abstract.md       # BCS0101 - Abstract tier
├── 02-shebang.complete.md      # BCS0102 - Complete tier
├── 02-shebang.summary.md       # BCS0102 - Summary tier
├── 02-shebang.abstract.md      # BCS0102 - Abstract tier
```

**Critical Filename Rules:**

1. **Unique numbers**: Each two-digit number must be unique within its directory
   - `01-layout.complete.md` ✓
   - `01-shebang.complete.md` ✗ (01 already used)
   - `02-shebang.complete.md` ✓

2. **Three tiers always together**: Every rule must have all three versions with identical numbers and base names
   - `05-example.complete.md`
   - `05-example.summary.md`
   - `05-example.abstract.md`

3. **Short description flexibility**: The descriptive name can be modified slightly without changing the BCS code
   - `01-layout.complete.md` → BCS0101
   - `01-script-layout.complete.md` → Still BCS0101 (same number)

4. **No duplicate numbers**: If you rename a rule and the number stays the same, delete the old files first
   - Renaming `03-old-name.complete.md` → `03-new-name.complete.md`
   - Must delete all `03-old-name.*.md` files before creating `03-new-name.*.md` files

### File Types and Source Hierarchy

Each rule exists in three tiers, with **`.complete.md` as the CANONICAL source**:

- **`.complete.md`** - Complete version with all examples and explanations (SOURCE - manually written)
- **`.summary.md`** - Medium version with key examples (DERIVED - generated from .complete.md)
- **`.abstract.md`** - Minimal version with rules only (DERIVED - generated from .complete.md)

**Source-Generated Hierarchy:**
```
01-layout.complete.md  (SOURCE - manually edited)
    ↓ generates
01-layout.summary.md   (DERIVED - compressed version)
    ↓ generates
01-layout.abstract.md  (DERIVED - minimal version)
```

**Workflow:**
1. Edit the `.complete.md` file (the authoritative version)
2. Generate `.summary.md` and `.abstract.md` from it
3. Never edit `.summary.md` or `.abstract.md` directly - regenerate them from `.complete.md`

The `bcs generate` command assembles these into the final standard.

### Directory Organization

```
data/
├── 00-header.md                    # Document preamble
├── 01-script-structure/            # Section 1
│   ├── 00-section.md               # Section introduction
│   ├── 01-layout.md                # BCS0101
│   ├── 02-shebang.md               # BCS0102
│   ├── 02-shebang/                 # Subrules container
│   │   └── 01-dual-purpose.md      # BCS010201
│   ├── 03-metadata.md              # BCS0103
│   └── 07-function-organization.md # BCS0107
├── 02-variables/                   # Section 2
│   ├── 00-section.md
│   ├── 01-type-specific.md         # BCS0201
│   └── 05-readonly-after-group.md  # BCS0205
└── templates/                      # Script templates
    ├── minimal.sh.template
    ├── basic.sh.template
    ├── complete.sh.template
    └── library.sh.template
```

### Adding a New Rule

To add rule BCS0209 (new variable pattern):

1. **Create the file**: `data/02-variables/09-new-pattern.complete.md`
2. **Follow naming**: `##-shortname.complete.md` where ## is two-digit zero-padded
3. **Write content**: Include title, rationale, examples, anti-patterns
4. **Generate variants**: Create `.abstract.md` and `.summary.md` versions
5. **Regenerate**: Run `./bcs generate --canonical`
6. **Verify code**: Run `./bcs codes | grep BCS0209`

### Modifying Existing Rules

1. Edit source file in `data/##-section/##-rule.complete.md`
2. Also update `.abstract.md` and `.summary.md` variants
3. Regenerate standard: `./bcs generate --canonical`
4. Verify: `./bcs decode BCS#### -p`
5. Run tests: `./tests/run-all-tests.sh`

### Critical Rules

- **Numeric prefixes only**: Never use `02a-`, `02b-` (breaks BCS code system)
- **Two-digit padding**: Always `01-`, `02-`, not `1-`, `2-`
- **Subrules use directories**: Not alphabetic suffixes
- **Section 00-section.md**: Always present in each section directory
- **Header hierarchy**: Use `##` for section, `###` for rule, `####` for subrule

## Builtins Subdirectory

The `builtins/` subdirectory is a **separate sub-project** providing high-performance loadable builtins. It has its own architecture, build system, and documentation.

### Purpose and Integration

- **Performance enhancement**: 10-158x faster than external commands in loops
- **Separate management**: Independent build, install, test, and documentation
- **Optional**: Not required for BCS compliance (scripts work fine without builtins)
- **C implementation**: Uses bash loadable builtin API from `loadables.h`

### Key Files

```
builtins/
├── README.md                      # Complete user documentation
├── QUICKSTART.md                  # Fast installation guide
├── CREATING-BASH-BUILTINS.md     # Developer guide (31KB)
├── PERFORMANCE.md                 # Benchmark results
├── Makefile                       # Auto-detects bash headers
├── install.sh / uninstall.sh     # Installation automation
├── bash-builtins-loader.sh       # Auto-loader for bash sessions
├── src/*.c                        # Builtin implementations
└── test/test-builtins.sh         # Comprehensive test suite
```

### Available Builtins

- **basename** (101x faster) - Strip directory from paths
- **dirname** (158x faster) - Extract directory component
- **realpath** (20-100x faster) - Resolve absolute paths
- **head** (10-30x faster) - Output first lines
- **cut** (15-40x faster) - Field extraction

### Development Commands

```bash
# Build builtins
cd builtins && make

# Run builtin tests
cd builtins && make test

# Install for user (no root)
cd builtins && ./install.sh --user

# Check builtin status
check_builtins  # After installation
```

### When to Work on Builtins

- User reports performance issues in file processing loops
- Adding new utility as loadable builtin
- Updating builtin implementations for new features
- Performance optimization work

**Important**: Builtins use `readlink` in test files for compatibility, but main bash-coding-standard repository uses `realpath` exclusively per BCS standards.

## Recent Changes (v1.0.0)

### 1. Symlink-Based Default Tier Detection
Implemented dynamic tier configuration system:

- **New function**: `get_default_tier()` (bcs:138-176)
- **Reads symlink**: `BASH-CODING-STANDARD.md` → determines default tier
- **Searches locations**: `$BCS_DIR`, `${BCS_DIR%/bin}` (FHS-compliant)
- **Extracts tier**: From filename (`complete.md`, `abstract.md`, `summary.md`)
- **Fallback**: Returns `'abstract'` if symlink unavailable

**Updated commands**: `generate`, `decode`, `check` all use `get_default_tier()`

**Benefits**:
- Single source of truth for default tier (the symlink)
- No hardcoded tier defaults in code
- Easy project-wide tier changes

**Example**:
```bash
# Change default tier for entire project
ln -sf BASH-CODING-STANDARD.complete.md BASH-CODING-STANDARD.md

# All commands now default to complete tier
./bcs decode BCS0102        # Returns complete tier path
./bcs decode BCS0102 -p     # Prints complete tier content
./bcs generate              # Generates from complete tier
```

### 2. All Command Aliases Removed
Simplified command structure by removing all 6 aliases:

**Removed aliases**:
- `show` (use `display`)
- `info` (use `about`)
- `list-codes` (use `codes`)
- `regen` (use `generate`)
- `grep` (use `search`)
- `toc` (use `sections`)

**Impact**: Cleaner UX, reduced cognitive load, simpler documentation

### 3. BCS Decode Command Improvements
Major improvements to `bcs decode` command:

1. **Default tier from symlink** - Dynamic configuration
   - `bcs decode BCS0102` returns tier specified by symlink
   - No longer hardcoded to 'abstract'

2. **Section code support** - 2-digit codes (BCS01, BCS02) now supported
   - `bcs decode BCS01` returns `data/01-script-structure/00-section.{tier}.md`
   - Section codes map to `00-section.{tier}.md` files
   - Works with all output modes: `-p` (print), `--all` (all tiers), `--relative`, `--basename`

3. **Multiple code support** - Accept multiple BCS codes on command line
   - `bcs decode BCS01 BCS02 BCS08 -p` prints contents of all three sections
   - Separators (`=========================================`) between codes in print mode
   - Return code: 0 if at least one code found, 1 if none found

**Editor Integration Example:**
```bash
# Quick reference in vim (tier from symlink)
vim $(bcs decode BCS0102)           # Open default tier
vim $(bcs decode BCS0102 -c)        # Force complete tier
vim $(bcs decode BCS0102 -a)        # Force abstract tier

# View multiple sections
bcs decode BCS01 BCS08 BCS13 -p | less

# Compare tiers
diff <(bcs decode BCS0102 -a -p) <(bcs decode BCS0102 -c -p)
```

### 4. Test Suite Enhancements
Comprehensive testing infrastructure established:

- **19 test files** (was 15), 600+ tests, **74% pass rate**
- **New tests**: data structure validation, integration tests, self-compliance
- **Coverage tracking**: 39% function coverage, 100% command coverage
- **CI/CD pipelines**: Automated testing, shellcheck, releases
- **12 new test helpers**: Enhanced assertions, mocking, fixtures
- **See**: `TESTING-SUMMARY.md` for complete documentation

**Bugs discovered**:
1. Duplicate BCS0206 code (critical)
2. Missing main() function in bcs script
3. Missing VERSION variable
4. Corrupted data file (fixed)

## Important Notes for AI Assistants

1. **Examples are deliberate** - Do not remove examples of core functions thinking they are redundant
2. **Rules must be preserved** - Never lose or diminish rules when refactoring
3. **Clarity is paramount** - Both humans and AI must completely understand the rules
4. **Pedagogical repetition ≠ redundancy** - Same pattern shown in different contexts is intentional
5. **Production optimization** - Remove unused utilities only after script is mature (Section 6)
6. **Files in .gitignore** - Do not reference files in README.md that are excluded from the repository (e.g., CLAUDE.md, ANALYSIS-AND-FIXES.md)
7. **Subcommand architecture** - When adding features, follow the dispatcher pattern (see "Adding a New Subcommand")
8. **Template customization** - Templates use `{{PLACEHOLDER}}` format, not shell variable expansion
9. **BCS codes are sacred** - Never change directory numbering (breaks all references)
10. **Test everything** - Each subcommand must have comprehensive tests in `tests/test-subcommand-NAME.sh`
11. **Builtins are separate** - The builtins/ subdirectory is an independent sub-project; changes there don't require regenerating BASH-CODING-STANDARD.md
12. **realpath vs readlink** - Main repo uses `realpath` exclusively; builtins may use `readlink` in tests for historical compatibility
13. **Default tier from symlink** - `decode`, `generate`, and `check` commands read BASH-CODING-STANDARD.md symlink to determine default tier (v1.0.0+); no hardcoded defaults
14. **No command aliases** - All aliases removed (v1.0.0+); use canonical command names only

## References

- All rules derive from BASH-CODING-STANDARD.md - consult it as the authoritative source
- Compatible with Google Shell Style Guide where applicable
- ShellCheck compliance is mandatory
- Bash 5.2+ features are acceptable and encouraged
- Builtins documentation: See builtins/README.md, builtins/CREATING-BASH-BUILTINS.md
- do `chkpoint -q` commands every now and again di mark major working changes in particular, but also before major state changes are planned.