# Bash Coding Standard

A comprehensive coding standard for modern Bash 5.2+ scripts, designed for consistency, robustness, and maintainability.

Bash is a battle-tested, sophisticated programming language deployed on virtually every Unix-like system on Earth -- from supercomputers to smartphones, from cloud servers to embedded devices.

Despite persistent misconceptions that it's merely "glue code" or unsuitable for serious development, Bash possesses powerful constructs for complex data structures, robust error handling, and elegant control flow. When wielded with discipline and proper engineering principles -- rather than as ad-hoc command sequences -- Bash delivers production-grade solutions for system automation, data processing, and infrastructure orchestration. This standard codifies that discipline, transforming Bash from a loose scripting tool into a reliable programming platform.

## Overview

This repository contains the canonical Bash coding standards developed by [Okusi Associates](https://okusiassociates.com) and adopted by the [Indonesian Open Technology Foundation (YaTTI)](https://yatti.id). These standards define precise patterns for writing production-grade Bash scripts that are both human-readable and machine-parseable.

## Purpose

Modern software development increasingly relies on automated refactoring, AI-assisted coding, and static analysis tools. This standard provides:

- **Deterministic patterns** that enable reliable automated code transformation
- **Strict structural requirements** that facilitate computer-aided programming and refactoring
- **Consistent conventions** that reduce cognitive load for both human developers and language models
- **Security-first practices** that prevent common shell scripting vulnerabilities

## Key Features

- Targets Bash 5.2+ exclusively (not a compatibility standard)
- Enforces strict error handling with `set -euo pipefail`
- Requires explicit variable declarations with type hints
- Mandates ShellCheck compliance
- Defines standard utility functions for consistent messaging
- Specifies precise file structure and naming conventions
- 14 comprehensive sections covering all aspects of Bash scripting

## Quick Start

### Installation

Clone this repository and optionally install system-wide:

```bash
# Clone the repository
git clone https://github.com/OkusiAssociates/bash-coding-standard.git
cd bash-coding-standard

# Run from cloned directory (development mode)
./bash-coding-standard          # Main script
./bcs                           # Convenience symlink (shorter)

# Or install system-wide (recommended for system use)
sudo make install

# Or install manually
sudo mkdir -p /usr/local/bin
sudo mkdir -p /usr/local/share/yatti/bash-coding-standard
sudo cp bash-coding-standard /usr/local/bin/
sudo chmod +x /usr/local/bin/bash-coding-standard
sudo cp BASH-CODING-STANDARD.md /usr/local/share/yatti/bash-coding-standard/
```

**Uninstall:**
```bash
sudo make uninstall

# Or manually
sudo rm /usr/local/bin/bash-coding-standard
sudo rm -rf /usr/local/share/yatti/bash-coding-standard
```

### Using the BCS Toolkit

The `bcs` script (symlink to `bash-coding-standard`) provides a comprehensive toolkit with multiple subcommands:

```bash
# View the standard (default command)
./bcs                           # Auto-detect best viewer
./bcs display                   # Explicit display command
./bcs show                      # Alias for display

# Display with options
./bcs display --cat             # Force plain text output
./bcs display --json            # Export as JSON
./bcs display --bash            # Export as bash variable
./bcs display --squeeze         # Squeeze consecutive blank lines

# Legacy compatibility (still works)
./bcs -c                        # Same as: ./bcs display --cat
./bcs --json                    # Same as: ./bcs display --json

# Project information and statistics
./bcs about                     # Show project information
./bcs about --stats             # Statistics only
./bcs about --links             # Links and references only
./bcs about --json              # JSON output for scripting
./bcs info                      # Alias for about

# Generate BCS-compliant script templates
./bcs template                  # Generate basic template (stdout)
./bcs template -t complete -o script.sh -x   # Complete template, executable
./bcs template -t minimal       # Minimal template
./bcs template -t library -n mylib       # Library template
./bcs new -t complete -o deploy.sh  # Alias: 'new'

# AI-powered compliance checker (requires Claude Code CLI)
./bcs check myscript.sh         # Comprehensive compliance check
./bcs check --strict deploy.sh  # Strict mode for CI/CD
./bcs check --format json script.sh      # JSON output
./bcs check --format markdown script.sh  # Markdown report

# List all BCS rule codes (replaces getbcscode.sh)
./bcs codes                     # List all 98 BCS codes
./bcs list-codes                # Alias

# Regenerate the standard (replaces regenerate-standard.sh)
./bcs generate                  # Generate complete standard to stdout
./bcs generate --canonical      # Regenerate canonical file
./bcs generate -t abstract      # Generate abstract version
./bcs generate -t summary       # Generate summary version

# Search within the standard
./bcs search "readonly"         # Basic search
./bcs search -i "SET -E"        # Case-insensitive
./bcs search -C 5 "declare -fx" # With context lines

# Explain specific BCS rules
./bcs explain BCS010201         # Complete explanation
./bcs explain BCS0102 -a        # Abstract version
./bcs explain BCS0205 -s        # Summary version

# List all sections
./bcs sections                  # Show all 14 sections
./bcs toc                       # Alias

# Get help
./bcs help                      # General help
./bcs help check                # Help for specific subcommand
./bcs --version                 # Show version: bcs 1.0.0

# If installed globally
bcs codes | head -10            # First 10 BCS codes
bcs check deploy.sh > compliance-report.txt
```

**Toolkit Features:**
- **10 Subcommands**: display, about, template, check, codes, generate, search, explain, sections, help
- **AI-powered validation**: Leverage Claude for comprehensive compliance checking
- **Template generation**: Create BCS-compliant scripts instantly
- **Comprehensive help**: `bcs help [subcommand]`
- **Backward compatible**: Legacy options still work
- **Dual-purpose**: Can be executed or sourced for functions
- **FHS-compliant**: Searches standard locations

### Subcommands Reference

The `bcs` toolkit provides ten powerful subcommands for working with the Bash Coding Standard:

#### display / show (Default)

View the coding standard document with multiple output formats:

```bash
bcs                          # Auto-detect (md2ansi if available)
bcs display                  # Explicit
bcs show                     # Alias

# Output formats
bcs display --cat            # Plain text (no formatting)
bcs display --json           # JSON export
bcs display --bash           # Bash variable declaration
bcs display --squeeze        # Squeeze blank lines

# Backward compatible (legacy)
bcs -c                       # Same as display --cat
bcs -j                       # Same as display --json
bcs -b                       # Same as display --bash
```

**Purpose:** View the complete BASH-CODING-STANDARD.md document
**Use case:** Reference while writing scripts, studying patterns

#### codes / list-codes

List all BCS rule codes from the data/ directory tree:

```bash
bcs codes                    # List all codes
bcs list-codes               # Alias

# Output format: BCS{code}:{shortname}:{title}
# Example output:
#   BCS010201:dual-purpose:Dual-Purpose Scripts (Executable and Sourceable)
#   BCS0103:metadata:Script Metadata
#   BCS0205:readonly-after-group:Readonly After Group Declaration
```

**Purpose:** Catalog all 98 BCS rule codes with their descriptions
**Replaces:** `getbcscode.sh` script
**Use case:** Finding specific rules, building documentation indexes

#### generate / regen

Regenerate BASH-CODING-STANDARD.md from the data/ directory:

```bash
bcs generate                 # Generate complete standard
bcs generate -t abstract     # Abstract version (rules only)
bcs generate -t summary      # Summary version (medium detail)
bcs generate -t complete     # Complete version (default, all examples)

bcs generate -o FILE         # Output to specific file
bcs generate --stdout        # Output to stdout

# Examples
bcs generate -t abstract -o BASH-CODING-STANDARD-SHORT.md
bcs generate --stdout | wc -l
```

**Purpose:** Build the standard document from source files
**Replaces:** `regenerate-standard.sh` script
**Use case:** Creating custom versions, updating after rule edits

**Tier types:**
- `complete` - Complete standard with all examples (2,945 lines)
- `summary` - Medium detail, key examples only
- `abstract` - Minimal version, rules and patterns only

#### search / grep

Search within the coding standard document:

```bash
bcs search PATTERN           # Basic search
bcs search -i PATTERN        # Case-insensitive
bcs search -C NUM PATTERN    # Show NUM context lines

# Examples
bcs search "readonly"
bcs search -i "SET -E"
bcs search -C 10 "declare -fx"
bcs search "BCS0205"         # Search for specific code
```

**Purpose:** Quickly find patterns, rules, or examples
**Use case:** Looking up specific syntax, finding rule references

#### explain / show-rule

Show detailed explanation of a specific BCS rule:

```bash
bcs explain BCS####          # Complete explanation (default)
bcs explain BCS#### -a       # Abstract version
bcs explain BCS#### -s       # Summary version
bcs explain BCS#### -c       # Complete version (explicit)

# Examples
bcs explain BCS010201        # Dual-purpose scripts
bcs explain BCS0102 -a       # Shebang (abstract)
bcs explain BCS0205 --summary   # Readonly pattern (summary)
```

**Purpose:** Get focused documentation for a single rule
**Use case:** Learning specific patterns, understanding rule context

**Supports:**
- Section codes (BCS01, BCS02, etc.)
- Rule codes (BCS0102, BCS0205, etc.)
- Subrule codes (BCS010201, etc.)

#### sections / toc

List all 14 sections in the standard:

```bash
bcs sections                 # List all sections
bcs toc                      # Alias (table of contents)

# Output:
#   1. Coding Principles
#   2. Contents
#   3. Script Structure & Layout
#   4. Variable Declarations & Constants
#   ...
#   16. Advanced Patterns
```

**Purpose:** Quick overview of standard structure
**Use case:** Navigation, understanding organization

#### about / info

Display project information, statistics, and metadata:

```bash
bcs about                    # Default: project info + philosophy + quick stats
bcs info                     # Alias

# Focused outputs
bcs about --stats            # Detailed statistics only
bcs about --links            # Documentation links and references
bcs about --quote            # Philosophy and coding principles
bcs about --json             # JSON output for scripting
bcs about --verbose          # Comprehensive (all information)

# Example outputs
bcs about --stats
#   Repository Statistics:
#   - Sections: 14
#   - Total rules: 98
#   - Lines of standard: 2,945
#   - Source files: 127
#   - Test files: 15
```

**Purpose:** Get project metadata and repository statistics
**Use case:** Understanding scope, documentation links, CI/CD integration
**Output modes:** text (default), stats, links, quote, json, verbose

#### template / new

Generate BCS-compliant script templates instantly:

```bash
bcs template                 # Generate basic template to stdout
bcs new                      # Alias

# Template types
bcs template -t minimal      # Minimal (~13 lines): set -e, error(), die(), main()
bcs template -t basic        # Basic (~27 lines): + metadata, messaging functions
bcs template -t complete     # Complete (~104 lines): + colors, arg parsing, all utilities
bcs template -t library      # Library (~38 lines): sourceable script pattern

# Output options
bcs template -o script.sh    # Write to file
bcs template -o script.sh -x # Make executable
bcs template -o script.sh -f # Force overwrite existing file

# Customization
bcs template -n myapp        # Set script name (replaces {{NAME}})
bcs template -d "Deploy script" # Set description
bcs template -v "2.0.0"      # Set version number

# Complete example
bcs template -t complete -n deploy -d "Production deployment script" \
             -v "1.5.0" -o deploy.sh -x
```

**Purpose:** Bootstrap new BCS-compliant scripts instantly
**Replaces:** Manual copying and adapting example scripts
**Use case:** Starting new scripts, learning patterns, rapid prototyping
**Templates include:** All mandatory structure, standard functions, proper patterns

**Template types:**
- `minimal` - Bare essentials: shebang, set -e, error/die functions, main()
- `basic` - Standard script: + metadata (VERSION, SCRIPT_PATH), messaging functions
- `complete` - Complete toolkit: + colors, verbose/quiet/debug flags, argument parsing, all utilities
- `library` - Sourceable library: proper export patterns, namespace prefixes, init function

**Placeholders:**
- `{{NAME}}` - Script/library name (auto-inferred from output filename)
- `{{DESCRIPTION}}` - Brief description comment
- `{{VERSION}}` - Version string (default: 1.0.0)

#### check / validate

AI-powered compliance checking using Claude Code CLI:

```bash
bcs check SCRIPT             # Comprehensive compliance check
bcs validate SCRIPT          # Alias

# Output formats
bcs check --format text script.sh     # Human-readable report (default)
bcs check --format json script.sh     # JSON for CI/CD integration
bcs check --format markdown script.sh # Markdown report

# Strict mode for CI/CD
bcs check --strict script.sh  # Exit non-zero on any violation
bcs check --strict *.sh       # Check multiple scripts

# Custom Claude command
bcs check --claude-cmd /path/to/claude script.sh

# Example CI/CD integration
bcs check --strict --format json deploy.sh > compliance-report.json
```

**Purpose:** Validate scripts against all 14 sections of BASH-CODING-STANDARD.md
**Requires:** Claude Code CLI (`claude` command must be available)
**Use case:** Pre-commit checks, code review, CI/CD validation, learning compliance

**Validation coverage (all 14 sections):**
1. Script structure and layout compliance
2. Variable declarations and constants
3. Variable expansion patterns
4. Quoting rules (single vs double quotes)
5. Array usage and iteration
6. Function definitions and organization
7. Control flow patterns
8. Error handling (set -e, traps, return values)
9. Messaging functions and output
10. Command-line argument parsing
11. File operations and testing
12. Security considerations
13. Code style and best practices
14. Advanced patterns usage

**How it works:**
- Embeds entire BASH-CODING-STANDARD.md (2,945 lines) as Claude's system prompt
- Claude analyzes script with full context of all rules
- Returns natural language explanations (not cryptic error codes)
- Understands intent, context, and legitimate exceptions
- Evaluates comment quality (WHY vs WHAT)

**Benefits over static analysis:**
- Context-aware (understands why rules exist)
- Natural language feedback
- Recognizes legitimate exceptions mentioned in standard
- Evaluates comment quality and documentation
- No false positives from regex patterns
- Automatically updates as standard evolves

### Migration from Legacy Scripts

If you've been using `getbcscode.sh` or `regenerate-standard.sh`, migrate to the new subcommands:

**Old way:**
```bash
./getbcscode.sh                      # List BCS codes
./regenerate-standard.sh             # Regenerate standard
./regenerate-standard.sh -t abstract # Generate abstract
```

**New way:**
```bash
./bcs codes                          # List BCS codes
./bcs generate                       # Regenerate standard
./bcs generate -t abstract           # Generate abstract
```

**Benefits of unified toolkit:**
- ✓ Single command interface (`bcs`) instead of multiple scripts
- ✓ Consistent help system (`bcs help <subcommand>`)
- ✓ Better error messages and validation
- ✓ Backward compatibility maintained (old scripts still work)
- ✓ Additional features (search, explain, sections)
- ✓ Comprehensive test coverage

### Validate Your Scripts

```bash
# All scripts must pass ShellCheck
shellcheck -x your-script.sh

# For scripts with documented exceptions
shellcheck -x your-script.sh
# Use #shellcheck disable=SCxxxx with explanatory comments
```

## Repository Structure

```
bash-coding-standard/
├── BASH-CODING-STANDARD.md          # The complete coding standard (2,945 lines)
├── bash-coding-standard             # Main toolkit script (v1.0.0)
├── bcs                              # Symlink to bash-coding-standard (convenience)
├── README.md                        # This file
├── LICENSE                          # CC BY-SA 4.0 license
├── Makefile                         # Installation/uninstallation helper
├── data/                            # Canonical rule source files (generates standard)
│   ├── 01-script-structure/         # Section 1 rules
│   │   ├── 02-shebang/              # Shebang subsection
│   │   │   └── 01-dual-purpose.md   # BCS010201 - Dual-purpose scripts
│   │   ├── 03-metadata.md           # BCS0103 - Script metadata
│   │   └── ...
│   ├── 02-variables/                # Section 2 rules
│   └── ...
├── tests/                           # Test suite (15 test files)
│   ├── test-helpers.sh              # Test helper functions
│   ├── run-all-tests.sh             # Run entire test suite
│   ├── test-bash-coding-standard.sh # Core functionality tests
│   ├── test-argument-parsing.sh     # Argument parsing tests
│   ├── test-environment.sh          # Environment validation
│   ├── test-execution-modes.sh      # Dual-purpose mode tests
│   ├── test-find-bcs-file.sh        # File location tests
│   ├── test-subcommand-dispatcher.sh # Command routing tests
│   ├── test-subcommand-display.sh   # Display subcommand tests
│   ├── test-subcommand-about.sh     # About subcommand tests
│   ├── test-subcommand-codes.sh     # Codes subcommand tests
│   ├── test-subcommand-generate.sh  # Generate subcommand tests
│   ├── test-subcommand-search.sh    # Search subcommand tests
│   ├── test-subcommand-explain.sh   # Explain subcommand tests
│   ├── test-subcommand-sections.sh  # Sections subcommand tests
│   └── test-subcommand-template.sh  # Template subcommand tests
├── builtins/                        # High-performance loadable builtins (separate sub-project)
│   ├── README.md                    # Complete user guide
│   ├── QUICKSTART.md                # Fast-start installation
│   ├── CREATING-BASH-BUILTINS.md   # Developer guide
│   ├── PERFORMANCE.md               # Benchmark results
│   ├── Makefile                     # Build system
│   ├── install.sh / uninstall.sh   # Installation scripts
│   ├── src/                         # C source code (basename, dirname, realpath, head, cut)
│   └── test/                        # Builtin test suite
├── getbcscode.sh                    # Legacy script (replaced by: bcs codes)
└── regenerate-standard.sh           # Legacy script (replaced by: bcs generate)
```

## BCS Code Structure

Each rule in the Bash Coding Standard is identified by a unique BCS code derived from its location in the directory structure.

**Format:** `BCS{catNo}[{ruleNo}][{subruleNo}]`

All numbers are **two-digit zero-padded** (e.g., BCS1401, BCS0402, BCS010201).

**Directory-to-Code Mapping:**
```
data/
├── 01-script-structure/              → BCS01 (Section)
│   ├── 02-shebang.md                → BCS0102 (Rule)
│   ├── 02-shebang/                  → (Subrule container)
│   │   └── 01-dual-purpose.md       → BCS010201 (Subrule)
│   ├── 03-metadata.md               → BCS0103 (Rule)
│   └── 07-function-organization.md  → BCS0107 (Rule)
├── 02-variables/                     → BCS02 (Section)
│   ├── 01-type-specific.md          → BCS0201 (Rule)
│   └── 05-readonly-after-group.md   → BCS0205 (Rule)
└── 14-advanced-patterns/             → BCS14 (Section)
    └── 03-temp-files.md             → BCS1403 (Rule)
```

**Key Principles:**

- **Numeric prefixes define codes**: `01-script-structure/02-shebang/01-dual-purpose.md` → BCS010201
- **Never use non-numeric prefixes**: `02a-`, `02b-` breaks the code system
- **Use subdirectories for subrules**: Not alphabetic suffixes
- **System supports unlimited nesting**: BCS01020304... is valid
- **Code extraction**: Use `bcs codes` to automatically extract codes from file paths

**Example:**
```bash
./bcs codes
# Output:
# BCS010201:dual-purpose:Dual-Purpose Scripts (Executable and Sourceable)
# BCS0103:metadata:Script Metadata
# BCS0201:type-specific:Type-Specific Declarations
# ...
```

**Legacy:** The `getbcscode.sh` script is still available but replaced by `bcs codes`.

The BCS code system ensures:
- **Unique identification**: Every rule has a distinct code
- **Hierarchical organization**: Codes reflect section/rule/subrule relationships
- **Deterministic generation**: File path directly determines code
- **Machine-parseable references**: Tools can link rules to specific file locations

## Performance Enhancement: Bash Builtins

The `builtins/` subdirectory contains a **separate sub-project** that provides high-performance bash loadable builtins to replace common external utilities. These builtins run directly inside the bash process, providing **10-158x performance improvements** by eliminating fork/exec overhead.

### Available Builtins

- **basename** (101x faster) - Strip directory from paths
- **dirname** (158x faster) - Extract directory component
- **realpath** (20-100x faster) - Resolve absolute paths
- **head** (10-30x faster) - Output first lines of files
- **cut** (15-40x faster) - Field/character extraction

### Quick Start

```bash
# Install for current user (no root required)
cd builtins
./install.sh --user

# Or install system-wide
sudo ./install.sh --system

# Verify installation
check_builtins
```

### When to Use

Maximum benefit when scripts:
- Call these utilities in loops (1000+ iterations)
- Process many files in batch operations
- Run in CI/CD pipelines or containers
- Require performance optimization

**Example performance gain:**
```bash
# Processing 100 files: 30 seconds → 2 seconds (15x faster)
for file in *.sh; do
    dir=$(dirname "$file")      # 158x faster than /usr/bin/dirname
    base=$(basename "$file")    # 101x faster than /usr/bin/basename
    # ... process files
done
```

### Documentation

- **[builtins/README.md](builtins/README.md)** - Complete user guide and installation
- **[builtins/QUICKSTART.md](builtins/QUICKSTART.md)** - Fast-start installation guide
- **[builtins/CREATING-BASH-BUILTINS.md](builtins/CREATING-BASH-BUILTINS.md)** - Developer guide for creating custom builtins
- **[builtins/PERFORMANCE.md](builtins/PERFORMANCE.md)** - Benchmark results and methodology

**Status:** Production-ready v1.0.0 (separate sub-project, optional enhancement)

**Note:** Builtins are **optional** and not required for BCS compliance. They provide performance enhancements for scripts that frequently call these utilities.

## Documentation

### Primary Documents

- **[BASH-CODING-STANDARD.md](BASH-CODING-STANDARD.md)** - The complete coding standard (2,945 lines, 14 sections)
- **[REBUTTALS-FAQ.md](REBUTTALS-FAQ.md)** - Responses to common criticisms and frequently asked questions about comprehensive Bash standards

### Standard Structure (14 Sections)

1. **Script Structure & Layout** - Complete script organization with full example
2. **Variable Declarations & Constants** - All variable patterns including readonly
3. **Variable Expansion & Parameter Substitution** - When to use braces
4. **Quoting & String Literals** - Single vs double quotes
5. **Arrays** - Declaration, iteration, safe list handling
6. **Functions** - Definition, organization, export
7. **Control Flow** - Conditionals, case, loops, arithmetic
8. **Error Handling** - Consolidated: set -e, exit codes, traps, return value checking
9. **Input/Output & Messaging** - Standard messaging functions, colors, echo vs messaging
10. **Command-Line Arguments** - Parsing patterns, validation
11. **File Operations** - Testing, wildcards, process substitution, here docs
12. **Security Considerations** - SUID, PATH, eval, IFS, input sanitization
13. **Code Style & Best Practices** - Formatting, language practices, development practices
14. **Advanced Patterns** - Dry-run, testing, progressive state management, temp files

## Core Principles

### Script Structure Requirements

Every script must follow this structure:

1. Shebang: `#!/usr/bin/env bash` (or `#!/bin/bash`)
2. ShellCheck directives (if needed)
3. Brief description comment
4. `set -euo pipefail`
5. `shopt` settings (strongly recommended: `inherit_errexit`, `shift_verbose`)
6. Script metadata (`SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`)
7. Global declarations
8. Color definitions (if terminal output)
9. Utility functions (messaging, helpers)
10. Business logic functions
11. `main()` function (for scripts >40 lines)
12. Script invocation: `main "$@"`
13. End marker: `#fin`

### Essential Patterns

**Variable Declarations:**
```bash
declare -i INTEGER_VAR=1      # Integers
declare -- STRING_VAR=''      # Strings
declare -a ARRAY_VAR=()       # Indexed arrays
declare -A HASH_VAR=()        # Associative arrays
readonly -- CONSTANT='val'    # Constants
local -i local_var=0          # Function locals
```

**Quoting Rules:**
```bash
# Use single quotes for static strings
info 'Processing files...'

# Use double quotes when variables are needed
info "Processing $count files"

# Always quote variables in conditionals
[[ -f "$file" ]] && process "$file"
```

**Error Handling:**
```bash
set -euo pipefail             # Mandatory
shopt -s inherit_errexit      # Strongly recommended

# Standard error functions
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }
```

## Minimal Example

A simple script following the standard:

```bash
#!/usr/bin/env bash
# Count files in directories
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Script metadata
SCRIPT_PATH=$(realpath -- "$0")
SCRIPT_DIR=${SCRIPT_PATH%/*}
SCRIPT_NAME=${SCRIPT_PATH##*/}
readonly -- SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME

# Global variables
declare -i VERBOSE=1

# Colors
[[ -t 1 && -t 2 ]] && declare -- GREEN=$'\033[0;32m' NC=$'\033[0m' || declare -- GREEN='' NC=''
readonly -- GREEN NC

# Messaging functions
_msg() {
  local -- prefix="$SCRIPT_NAME:" msg
  [[ "${FUNCNAME[1]}" == success ]] && prefix+=" ${GREEN}✓${NC}"
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

# Business logic
count_files() {
  local -- dir="$1"
  local -i count
  [[ -d "$dir" ]] || die 1 "Not a directory: $dir"

  count=$(find "$dir" -maxdepth 1 -type f | wc -l)
  success "Found $count files in $dir"
}

main() {
  local -- dir

  # Validate arguments
  (($# > 0)) || die 1 'No directory specified'

  # Process each directory
  for dir in "$@"; do
    count_files "$dir"
  done
}

main "$@"
#fin
```

## Usage Guidance

### For Human Developers

1. Read [BASH-CODING-STANDARD.md](BASH-CODING-STANDARD.md) thoroughly
2. Use the standard utility functions (`_msg`, `vecho`, `success`, `warn`, `info`, `error`, `die`)
3. Always run `shellcheck -x` before committing
4. Follow the 14-section structure when reading/writing complex scripts
5. Use single quotes for static strings, double quotes for variables

### For AI Assistants

1. All generated scripts must comply with BASH-CODING-STANDARD.md
2. Use the standard messaging functions consistently
3. Include proper error handling in all functions
4. Remove unused utility functions in production scripts (see Section 6: Production Script Optimization)

### Integration with Editors

**VSCode:**
```json
{
  "shellcheck.enable": true,
  "shellcheck.executablePath": "/usr/bin/shellcheck",
  "shellcheck.run": "onSave"
}
```

**Vim/Neovim:**
```vim
" Add to .vimrc or init.vim
let g:syntastic_sh_shellcheck_args = '-x'
```

## Validation Tools

- **ShellCheck** (mandatory): `shellcheck -x script.sh`
- **bash -n** (syntax check): `bash -n script.sh`
- **Test frameworks**: [bats-core](https://github.com/bats-core/bats-core) for testing

## Recent Changes

### 2025-10-10 Restructuring

The standard was restructured from 15 sections to 14 sections with significant improvements:

- **Reduced**: 2,246 lines → 2,145 lines (4.5% reduction)
- **Split**: "String Operations" into two focused sections:
  - Variable Expansion & Parameter Substitution
  - Quoting & String Literals
- **Consolidated**: Error Handling (previously fragmented across sections)
- **Eliminated**: Incoherent "Calling Commands" section (content redistributed)
- **Organized**: Best Practices into themed subsections
- **Preserved**: ALL rules, ALL examples, ALL security guidelines

## Conclusions

This standard transforms Bash from a loose scripting tool into a reliable programming platform by codifying engineering discipline for production-grade automation, data processing, and infrastructure orchestration. Rather than treating Bash as mere "glue code," these guidelines recognize it as a battle-tested, sophisticated programming language deployed universally across Unix-like systems—from supercomputers to smartphones, from cloud servers to embedded devices.

### Core Philosophy

Modern software development increasingly relies on automated refactoring, AI-assisted coding, and static analysis tools. This standard provides **deterministic patterns** that enable reliable automated code transformation, **strict structural requirements** that facilitate computer-aided programming, **consistent conventions** that reduce cognitive load for both human developers and language models, and **security-first practices** that prevent common shell scripting vulnerabilities. The standard is designed to be equally parseable by humans and AI assistants, with rules that are clear, complete, and demonstrated through deliberate examples.

### Major Features

**Structural Discipline:**
- **13-step mandatory script structure** from shebang through `#fin` marker, providing consistent organization across all scripts
- **Bottom-up function organization** where low-level utilities (messaging, helpers) come first, `main()` comes last, ensuring safe function dependencies
- **Mandatory `main()` function** for scripts >40 lines to improve organization, testability, and clarity

**Error Handling & Safety:**
- **Strict error handling** with `set -euo pipefail` (mandatory) and `shopt -s inherit_errexit shift_verbose` (strongly recommended)
- **Arithmetic safety** using `i+=1` or `((i+=1))` instead of dangerous `((i++))` which fails with `set -e` when i=0
- **Process substitution over pipes** (`< <(command)`) to avoid subshell variable persistence issues
- **Explicit wildcard paths** (`rm ./*` not `rm *`) to prevent flag injection attacks

**Variable Management:**
- **Explicit variable declarations** with type hints: `declare -i` for integers, `declare --` for strings, `declare -a` for arrays, `declare -A` for associative arrays
- **Readonly after group pattern** where related constants are declared first, then made readonly together for visual clarity
- **Variable expansion simplicity**: `"$var"` by default, braces `"${var}"` only when syntactically required (parameter expansion, concatenation, arrays)
- **Boolean flag patterns** using integer declarations tested with `((FLAG))` syntax

**Quoting Discipline:**
- **Single quotes for static strings** (`info 'Checking prerequisites...'`) signaling "literal text"
- **Double quotes for expansion** (`info "Processing $count files"`) signaling "shell processing needed"
- **Always quote variables** in conditionals (`[[ -f "$file" ]]`) for word-splitting safety
- **One-word literals may be unquoted** but quotes are more defensive and recommended

**Messaging & Output:**
- **Standard messaging functions** (`_msg`, `vecho`, `success`, `warn`, `info`, `debug`, `error`, `die`, `yn`) providing consistent formatting with colors and verbosity control
- **FUNCNAME-based message formatting** where `_msg()` automatically adapts output based on calling function
- **Error output to STDERR** with `>&2` placed at beginning of commands for clarity

**Security & Compliance:**
- **ShellCheck compliance mandatory** with documented exceptions only
- **No SUID/SGID ever** in Bash scripts due to security vulnerabilities
- **PATH hardening** to prevent command injection and trojan attacks
- **Input sanitization** functions for filenames, numbers, and user data
- **`--` separators** before all file arguments to prevent flag injection

**Advanced Patterns:**
- **Dry-run pattern** for safe preview of destructive operations before execution
- **Progressive state management** where boolean flags adapt based on runtime conditions (prerequisites, build failures)
- **Production optimization** removing unused utility functions when scripts mature (Section 6)
- **FHS compliance** following Filesystem Hierarchy Standard for system integration

### Important Compliances

- **Bash 5.2+ exclusive** - Not a compatibility standard; uses modern Bash features and constructs
- **ShellCheck compulsory** - All scripts must pass with documented exceptions only
- **Google Shell Style Guide compatible** - Where applicable, follows industry reference patterns
- **FHS (Filesystem Hierarchy Standard)** - Standard locations for system-wide and user-specific installations
- **CC BY-SA 4.0 license** - Attribution to Okusi Associates and YaTTI required, share-alike for derivative works

### Flexibility & Pragmatism

The standard emphasizes **avoiding over-engineering**. As stated in the opening note of BASH-CODING-STANDARD.md: "Do not over-engineer scripts; functions and variables not required for the operation of the script should not be included and/or removed."

**Practical flexibility:**
- **Scripts >40 lines** require `main()` function; **shorter scripts can be simpler** with top-level logic
- **Remove unused utility functions** in production—a simple script may only need `error()` and `die()`, not the full messaging suite
- **Include only required structures**—not every script needs all 7 messaging functions, boolean flags, or advanced patterns
- **One-word literals can be unquoted** in assignments and conditionals, though quotes are more defensive
- **Argument parsing location** can be inside `main()` (recommended for testability) or at top level (acceptable for simple scripts)
- **Section comments are lightweight**—use simple `# Description` format, not mandatory box drawing

**Rationale:** Scripts should be as simple as necessary to accomplish their purpose, but no simpler. The standard provides comprehensive patterns for complex production scripts while explicitly allowing simpler structures for straightforward tasks. This approach prevents both under-engineering (unsafe, unmaintainable code) and over-engineering (unnecessary complexity, maintenance burden).

### Target Audience

This standard serves both **human developers** building production systems and **AI assistants** generating or refactoring Bash code. The deterministic patterns, explicit rules, and comprehensive examples enable both audiences to produce consistent, maintainable, secure Bash scripts that work reliably across different environments and use cases.

---

**In summary:** This standard codifies professional Bash development as a disciplined engineering practice, providing the structure needed for reliable automation while maintaining the flexibility to match complexity to requirements.

## Contributing

This standard evolves through practical application in production systems. Contributions are welcome:

1. **Propose changes** via GitHub Issues with clear rationale
2. **Submit pull requests** with specific improvements
3. **Document real-world use cases** that demonstrate value
4. **Test thoroughly** with `shellcheck` before submitting

Changes should demonstrate clear benefits for:
- Code reliability
- Maintainability
- Automation capabilities
- Security
- Clarity for both humans and AI assistants

## Related Resources

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) - Industry reference standard
- [ShellCheck](https://www.shellcheck.net/) - Required static analysis tool (compulsory)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) - Official Bash documentation
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/) - Comprehensive reference
- [Bash Loadable Builtins](builtins/) - High-performance replacements for common utilities (this repository)

## Troubleshooting

### ShellCheck Warnings

If you see ShellCheck warnings:
1. First, try to fix the code to comply with the warning
2. Only disable checks when absolutely necessary
3. Document the reason with a comment:
   ```bash
   #shellcheck disable=SC2046  # Intentional word splitting for flag expansion
   ```

### Script Not Working After Compliance

Common issues:
- Forgot to quote variables in conditionals
- Used `((i++))` instead of `i+=1` or `((i+=1))`
- Forgot `set -euo pipefail` and script is failing on undefined variables
- Missing `shopt -s inherit_errexit` causing subshell issues

### Getting Help

- Open an issue on GitHub for standard clarifications
- Refer to specific sections in BASH-CODING-STANDARD.md

## License

This work is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

You are free to:
- Share and redistribute the material
- Fork, adapt, and build upon the material

Under the following terms:
- **Attribution** - You must give appropriate credit to Okusi Associates and YaTTI
- **ShareAlike** - Distribute contributions under the same license

See [LICENSE](LICENSE) for full details.

## Acknowledgments

Developed by **Okusi Associates** for enterprise Bash scripting. Incorporates compatible elements from Google's Shell Style Guide and industry best practices.

Adopted by the **Indonesian Open Technology Foundation (YaTTI)** for standardizing shell scripting across open technology projects.

---

**For production systems requiring consistent, maintainable, and secure Bash scripting.**

*Last updated: 2025-10-10*
