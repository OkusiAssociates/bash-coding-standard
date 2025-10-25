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

## Table of Contents

- [Quick Start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Using the BCS Toolkit](#using-the-bcs-toolkit)
  - [Subcommands Reference](#subcommands-reference)
  - [Validate Your Scripts](#validate-your-scripts)
- [Workflows](#workflows)
  - [Available Workflows](#available-workflows)
  - [Real-World Examples](#real-world-examples)
  - [Comprehensive Documentation](#comprehensive-documentation)
  - [Testing](#testing)
- [Core Principles](#core-principles)
- [Minimal Example](#minimal-example)
- [Repository Structure](#repository-structure)
- [BCS Code Structure](#bcs-code-structure)
- [BCS Ruleset Structure](#bcs-ruleset-structure)
  - [Terminology](#terminology)
  - [Multi-Tier Documentation System](#multi-tier-documentation-system)
  - [File Naming Conventions](#file-naming-conventions)
  - [Directory Hierarchy](#directory-hierarchy)
  - [BCS Code Mapping](#bcs-code-mapping)
  - [Tier Generation Workflow](#tier-generation-workflow)
  - [Working with Rulesets](#working-with-rulesets)
  - [Relationship Diagram](#relationship-diagram)
- [Performance Enhancement: Bash Builtins](#performance-enhancement-bash-builtins)
- [Documentation](#documentation)
- [Usage Guidance](#usage-guidance)
- [Validation Tools](#validation-tools)
- [Recent Changes](#recent-changes)
- [Conclusions](#conclusions)
- [Contributing](#contributing)
- [Related Resources](#related-resources)
- [Troubleshooting](#troubleshooting)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Quick Start

### Prerequisites

Before using the Bash Coding Standard toolkit, ensure you have:

#### Required

- **Bash 5.2+** - Modern Bash version (check: `bash --version`)
- **ShellCheck** - Static analysis tool (mandatory for BCS compliance)

  **Installation:**
  ```bash
  # Ubuntu/Debian
  sudo apt install shellcheck

  # macOS
  brew install shellcheck

  # Fedora/RHEL
  sudo dnf install ShellCheck

  # Alpine Linux
  apk add shellcheck

  # Or download from: https://www.shellcheck.net/
  ```

  **Verify installation:**
  ```bash
  shellcheck --version  # Should be 0.8.0 or higher
  ```

#### Bundled Libraries and Scripts (No Installation Required)

The BCS includes **13 vendored tools** (~544KB total) in the `lib/` directory that work out-of-box after `git clone`. All tools are installed system-wide via `sudo make install`.

**Quick Reference:**

| Category | Tools | Purpose |
|----------|-------|---------|
| **Core BCS** | bcs-rulet-extractor, bcs-compliance | AI agents for BCS operations |
| **Markdown** | md2ansi, md, mdheaders | Document rendering and manipulation |
| **File/System** | whichx, dux, printline, bcx | Command location, disk analysis, terminal formatting, calculations |
| **Development** | shlock, trim, timer, post_slug, hr2int, remblanks | Scripting utilities |

---

##### Core BCS Tools

**bcs-rulet-extractor** (v1.0.1, ~5KB)
- **Purpose:** Extract concise rulets from complete.md rulefiles using Claude AI
- **Used by:** `bcs generate-rulets` subcommand
- **Installation:** Not installed to PATH (internal use only)

**bcs-compliance** (v1.0.1, ~900B)
- **Purpose:** BCS compliance checking wrapper for Claude
- **Used by:** External compliance workflows
- **Installation:** Not installed to PATH (internal use only)
- **Requires:** Claude Code CLI, shlock utility

---

##### Markdown Tools

**md2ansi** & **md** (git commit [6e8d7dc](https://github.com/Open-Technology-Foundation/md2ansi.bash), ~60KB)
- **Purpose:** Beautiful ANSI terminal rendering of markdown documents
- **Installation:** `/usr/local/bin/md2ansi` and `/usr/local/bin/md`
- **Usage:**
  ```bash
  md README.md               # Paginated viewing with less
  md2ansi file.md            # Direct ANSI output to stdout
  ```
- **Features:**
  - ✅ Full markdown support (headers, lists, tables, code blocks)
  - ✅ Syntax highlighting for code blocks
  - ✅ Color-coded elements
- **License:** MIT
- **Used by:** `bcs display` for enhanced viewing

**mdheaders** (git commit [6837187](https://github.com/Open-Technology-Foundation/whichx), ~54KB)
- **Purpose:** Markdown header level manipulation (upgrade/downgrade/normalize)
- **Installation:** `/usr/local/bin/mdheaders` and `/usr/local/bin/libmdheaders.bash`
- **Usage:**
  ```bash
  mdheaders upgrade -l 2 -ib file.md      # Increase levels, backup
  mdheaders normalize --start-level=2 doc.md  # Normalize to H2
  ```
- **Features:**
  - ✅ Upgrade/downgrade header levels
  - ✅ Normalize to target minimum level
  - ✅ Code block awareness (preserves fenced blocks)
- **License:** GPL v3

---

##### File & System Tools

**whichx** (v2.0, git commit [6f2b28b](https://github.com/Open-Technology-Foundation/whichx), ~45KB)
- **Purpose:** Robust command locator - drop-in replacement for system `which`
- **Installation:** `/usr/local/bin/whichx` + symlink `/usr/local/bin/which`
- **Usage:**
  ```bash
  which python3              # Find python3 location
  whichx -a bash             # Show all bash instances in PATH
  whichx -c vim              # Show canonical path (follow symlinks)
  ```
- **Features:**
  - ✅ POSIX-compliant PATH searching
  - ✅ Specific exit codes for scripting
  - ✅ Silent mode (`-s`) for conditional checks
- **License:** GPL v3
- **Note:** Shadows system `which` via `/usr/local/bin` priority

**dux / dir-sizes** (v1.2.0, git commit [ee0927c], ~56KB)
- **Purpose:** Directory size analyzer with sorted human-readable output
- **Installation:** `/usr/local/bin/dir-sizes` + symlink `/usr/local/bin/dux`
- **Usage:**
  ```bash
  dux                        # Analyze current directory
  dir-sizes /var             # Analyze /var subdirectories
  dux ~/Documents | tail -10 # Show 10 largest directories
  ```
- **Features:**
  - ✅ Recursive size calculation
  - ✅ Human-readable IEC units (B, KiB, MiB, GiB)
  - ✅ Sorted output (smallest to largest)
- **License:** GPL v3
- **Dependencies:** du, numfmt (GNU coreutils)

**printline** (v1.0.0, git commit [5e64288], ~52KB)
- **Purpose:** Terminal line drawing utility for section dividers and headers
- **Installation:** `/usr/local/bin/printline`
- **Usage:**
  ```bash
  printline                  # Draw line with '-' character
  printline '=' 'Section: '  # Print prefix then line
  echo -n "Status: "; printline '#'  # Combine with output
  ```
- **Features:**
  - ✅ Intelligent cursor position detection
  - ✅ Customizable character (default: `-`)
  - ✅ Dual-mode (executable or sourceable function)
- **License:** GPL v3
- **Dependencies:** stty, tput (standard utilities)

**bcx** (v1.0.0, git commit [f109472], ~44KB)
- **Purpose:** Terminal calculator for floating-point expressions with interactive REPL
- **Installation:** `/usr/local/bin/bcx`
- **Usage:**
  ```bash
  bcx "3.14 * 2"         # Quick calculation (returns 6.28)
  bcx "sqrt(144)"        # Math functions (returns 12)
  bcx                    # Interactive REPL mode
  result=$(bcx "42 * 72 / 3.14")  # Use in scripts
  ```
- **Features:**
  - ✅ Interactive REPL with readline history (arrow keys, Ctrl-R search)
  - ✅ Persistent command history (~/.bcx_history)
  - ✅ Math library support (sqrt, sin, cos, atan, log, exp)
  - ✅ x → * conversion in terminal mode (e.g., `3x4` becomes `3*4`)
  - ✅ Clean error handling and proper Ctrl-C support
- **License:** GPL v3
- **Dependencies:** bc (command-line calculator)

---

##### Development Utilities

**shlock** (git commit [49f1439](https://github.com/Open-Technology-Foundation/shlock), ~16KB)
- **Purpose:** Process locking and synchronization for shell scripts
- **Installation:** Not installed to PATH (used by bcs-compliance)
- **License:** MIT

**trim** (git commit [8b37c55](https://github.com/Open-Technology-Foundation/trim), ~92KB)
- **Purpose:** Pure Bash string trimming utilities (6 utilities)
- **Installation:** Not installed to PATH (available for sourcing from lib/)
- **Tools:** `trim`, `ltrim`, `rtrim`, `trimall`, `squeeze`, `trimv`
- **Features:**
  - ✅ Zero dependencies (pure Bash)
  - ✅ Dual-mode (command-line or sourceable)
  - ✅ No subprocess overhead
- **License:** GPL v3

**timer** (git commit [f8ac47a](https://github.com/Open-Technology-Foundation/timer), ~47KB)
- **Purpose:** Microsecond-precision command execution timing
- **Installation:** Not installed to PATH (available for sourcing from lib/)
- **Usage:** Source and wrap commands for performance measurement
- **Features:**
  - ✅ Microsecond precision using `$EPOCHREALTIME`
  - ✅ Optional formatted output (days/hours/minutes/seconds)
  - ✅ Exit code preservation
- **License:** GPL v3
- **Dependencies:** Pure Bash (none!)

**post_slug** (git commit [d4f73ff](https://github.com/Open-Technology-Foundation/post_slug), ~40KB)
- **Purpose:** Convert strings into URL or filename-friendly slugs
- **Installation:** Not installed to PATH (available for sourcing from lib/)
- **Features:**
  - ✅ HTML entity handling
  - ✅ UTF-8 to ASCII transliteration
  - ✅ Customizable separator
- **License:** GPL v3
- **Dependencies:** sed, iconv, tr (standard utilities)

**hr2int** (~3KB, internal YaTTI utility)
- **Purpose:** Convert human-readable numbers with size suffixes to integers
- **Installation:** Not installed to PATH (available for sourcing from lib/)
- **Functions:** `hr2int()` (1k → 1024), `int2hr()` (1024 → 1k)
- **License:** ⚠️ No explicit license (internal tool)
- **Dependencies:** numfmt (GNU coreutils)

**remblanks** (~1KB, internal YaTTI utility)
- **Purpose:** Strip comments and blank lines from input
- **Installation:** Not installed to PATH (available for sourcing from lib/)
- **License:** ⚠️ No explicit license (internal tool)
- **Dependencies:** grep

---

**Installation Behavior:**

Running `sudo make install` installs these tools to `/usr/local/bin/`:
- ✅ **Always installed:** bcs, md2ansi, md, mdheaders, whichx, dir-sizes, printline, bcx
- ✅ **Symlinks created:** bash-coding-standard → bcs, which → whichx, dux → dir-sizes
- ⚠️ **Symlink protection:** Install detects existing symlinks and prompts before removal
- ℹ️ **Not installed:** Agents, trim, timer, post_slug, hr2int, remblanks, shlock

**Benefits:**
- ✅ Works immediately after `git clone`
- ✅ No external dependency installation needed
- ✅ Consistent versions across all installations
- ✅ System-wide availability after installation
- ✅ Includes utilities for common scripting tasks

**Complete Documentation:** See [`lib/README.md`](lib/README.md) for:
- Detailed feature descriptions
- Complete usage examples
- Update procedures for each tool
- Licensing information
- Total size breakdown (~540KB)

#### Optional

- **Claude Code CLI** - For AI-powered features (`bcs check`, `bcs compress`)
  - Install from: https://claude.com/code

### Installation

Clone this repository and optionally install system-wide:

```bash
# Clone the repository
git clone https://github.com/OkusiAssociates/bash-coding-standard.git
cd bash-coding-standard

# Run from cloned directory (development mode)
./bcs                              # Main CLI toolkit script (v1.0.0, 156KB)
./bash-coding-standard             # Symlink to bcs (backwards compatibility)

# Or install system-wide (recommended for system use)
sudo make install

# Or install manually
sudo mkdir -p /usr/local/bin
sudo mkdir -p /usr/local/share/yatti/bash-coding-standard
sudo cp bcs /usr/local/bin/
sudo ln -s /usr/local/bin/bcs /usr/local/bin/bash-coding-standard
sudo chmod +x /usr/local/bin/bcs
sudo cp -r data /usr/local/share/yatti/bash-coding-standard/
```

**Uninstall:**
```bash
sudo make uninstall

# Or manually
sudo rm /usr/local/bin/bash-coding-standard
sudo rm -rf /usr/local/share/yatti/bash-coding-standard
```

### Using the BCS Toolkit

The `bcs` script provides a comprehensive toolkit with multiple subcommands:

```bash
# View the standard (default command)
./bcs                           # Auto-detect best viewer
./bcs display                   # Explicit display command

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

# Generate BCS-compliant script templates
./bcs template                  # Generate basic template (stdout)
./bcs template -t complete -o script.sh -x   # Complete template, executable
./bcs template -t minimal       # Minimal template
./bcs template -t library -n mylib       # Library template

# AI-powered compliance checker (requires Claude Code CLI)
./bcs check myscript.sh         # Comprehensive compliance check
./bcs check --strict deploy.sh  # Strict mode for CI/CD
./bcs check --format json script.sh      # JSON output
./bcs check --format markdown script.sh  # Markdown report

# List all BCS rule codes (replaces getbcscode.sh)
./bcs codes                     # List all 99 BCS codes

# Regenerate the standard (replaces regenerate-standard.sh)
./bcs generate                  # Generate complete standard to stdout
./bcs generate --canonical      # Regenerate canonical file
./bcs generate -t abstract      # Generate abstract version
./bcs generate -t summary       # Generate summary version

# Search within the standard
./bcs search "readonly"         # Basic search
./bcs search -i "SET -E"        # Case-insensitive
./bcs search -C 5 "declare -fx" # With context lines

# Decode BCS codes to file locations or view content
./bcs decode BCS010201          # Show file location (default tier via symlink)
./bcs decode BCS010201 -p       # Print rule content to stdout
./bcs decode BCS01              # Section codes supported (returns 00-section file)
./bcs decode BCS01 BCS02 BCS08  # Multiple codes supported
./bcs decode BCS0102 --all      # Show all three tiers
./bcs decode BCS01 BCS0102 -p   # Print contents of multiple codes

# List all sections
./bcs sections                  # Show all 14 sections

# Get help
./bcs help                      # General help
./bcs help check                # Help for specific subcommand
./bcs --version                 # Show version: bcs 1.0.0

# If installed globally
bcs codes | head -10            # First 10 BCS codes
bcs check deploy.sh > compliance-report.txt
```

**Toolkit Features:**
- **13 Subcommands**: display, about, template, check, compress, codes, generate, generate-rulets, search, decode, sections, default, help
- **No command aliases** - Simplified UX with canonical names only (v1.0.0+)
- **Symlink-based tier detection** - Default tier from BASH-CODING-STANDARD.md symlink
- **AI-powered validation**: Leverage Claude for comprehensive compliance checking
- **AI-powered compression**: Automatically compress rules to summary/abstract tiers with context awareness
- **Template generation**: Create BCS-compliant scripts instantly
- **Comprehensive help**: `bcs help [subcommand]`
- **Backward compatible**: Legacy options still work
- **Dual-purpose**: Can be executed or sourced for functions
- **FHS-compliant**: Searches standard locations

### Subcommands Reference

The `bcs` toolkit provides 12 powerful subcommands for working with the Bash Coding Standard:

#### display (Default)

View the coding standard document with multiple output formats:

```bash
bcs                          # Auto-detect (md2ansi if available)
bcs display                  # Explicit

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

#### codes

List all BCS rule codes from the data/ directory tree:

```bash
bcs codes                    # List all codes

# Output format: BCS{code}:{shortname}:{title}
# Example output:
#   BCS010201:dual-purpose:Dual-Purpose Scripts (Executable and Sourceable)
#   BCS0103:metadata:Script Metadata
#   BCS0205:readonly-after-group:Readonly After Group Declaration
```

**Purpose:** Catalog all 99 BCS rule codes with their descriptions
**Replaces:** `getbcscode.sh` script
**Use case:** Finding specific rules, building documentation indexes

#### generate

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
- `complete` - Complete standard with all examples (21,431 lines)
- `summary` - Medium detail, key examples only (12,666 lines)
- `abstract` - Minimal version, rules and patterns only (3,794 lines)

#### search

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

#### decode

Resolve BCS codes to file locations or print rule content directly.

**Options:**
```bash
# Tier selection
bcs decode BCS####              # Default tier (symlink-based, currently summary)
bcs decode BCS#### -c           # Complete tier  -s summary  -a abstract  --all (all three)

# Output modes
bcs decode BCS####              # Show file path
bcs decode BCS#### -p           # Print content to stdout

# Path formatting
bcs decode BCS#### --relative   # Relative path  --basename (filename only)
bcs decode BCS#### --exists     # Silent validation (exit 0 if exists)

# Multiple codes (v1.0.0+)
bcs decode BCS01 BCS02 -p       # Print multiple codes with separators
```

**Quick examples:**
```bash
# View rule content
bcs decode BCS0102 -p | less

# Open in editor
vim $(bcs decode BCS0205)

# Validate existence
bcs decode BCS0102 --exists && echo "Exists"

# Multiple section overviews
bcs decode BCS01 BCS08 BCS13 -p
```

**Purpose:** Resolve BCS codes to file locations or view rule content
**Default tier:** Symlink-based (currently summary)
**New in v1.0.0:** Section codes, multiple codes, symlink-based defaults

**See also:** `docs/BCS-DECODE-PATTERNS.md` for 9 advanced usage patterns (editor integration, tier comparison, batch processing, etc.)

#### sections

List all 14 sections in the standard:

```bash
bcs sections                 # List all sections

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

#### about

Display project information, statistics, and metadata:

```bash
bcs about                    # Default: project info + philosophy + quick stats

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
#   - Total rules: 99
#   - Lines of standard: 3,794 (abstract tier, canonical symlink)
#   - Complete tier: 21,431 lines
#   - Summary tier: 12,666 lines
#   - Source files: 99 (.complete.md files)
#   - Test files: 19
```

**Purpose:** Get project metadata and repository statistics
**Use case:** Understanding scope, documentation links, CI/CD integration
**Output modes:** text (default), stats, links, quote, json, verbose

#### template

Generate BCS-compliant script templates instantly:

```bash
bcs template                 # Generate basic template to stdout

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

#### check

AI-powered compliance checking using Claude Code CLI:

```bash
bcs check SCRIPT             # Comprehensive compliance check

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
- Embeds entire BASH-CODING-STANDARD.md (symlink to tier file in data/) as Claude's system prompt
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

#### compress (Developer Mode)

AI-powered compression of BCS rule files using Claude Code CLI.

**Basic usage:**
```bash
bcs compress                              # Report oversized files
bcs compress --regenerate                 # Regenerate all tiers
bcs compress --regenerate --context-level abstract   # Recommended (deduplication across rules)
```

**Common options:**
```bash
--tier summary|abstract               # Compress specific tier only
--context-level none|toc|abstract|summary|complete  # Context awareness (default: none)
--summary-limit 10000                 # Max summary size (bytes)
--abstract-limit 1500                 # Max abstract size (bytes)
--dry-run                             # Preview without changes
```

**Purpose:** Compress .complete.md files to .summary.md and .abstract.md tiers using AI
**Requires:** Claude Code CLI (`claude` command must be available)
**Use case:** Maintaining multi-tier documentation, compressing custom rules

**Context levels:**
- `none` - Fastest, each rule in isolation (default)
- `abstract` - Recommended, cross-rule deduplication (~83KB context)
- `toc`, `summary`, `complete` - Increasing context awareness

**Size limits:**
- summary: 10000 bytes (adjustable)
- abstract: 1500 bytes (adjustable)

**Note:** Developer-mode feature for maintaining the multi-tier system. Most users don't need this - the repository already contains compressed tiers. See `docs/BCS-COMPRESS-GUIDE.md` for detailed guide.

#### generate-rulets

AI-powered extraction of highly concise rulets (1-2 sentence rules) from .complete.md files using the `bcs-rulet-extractor` agent.

**Basic usage:**
```bash
bcs generate-rulets 02                    # Generate rulet file for category 02 (variables)
bcs generate-rulets variables             # Same - by category name
bcs generate-rulets --all                 # Generate for all 14 categories
bcs generate-rulets --all --force         # Force regeneration of existing files
```

**Options:**
```bash
-a, --all                    Generate rulets for all categories
-f, --force                  Force regeneration of existing rulet files
--agent-cmd PATH             Path to bcs-rulet-extractor agent (default: /ai/scripts/claude/agents/bcs-rulet-extractor)
```

**Purpose:** Extract concise, actionable rules (rulets) from complete.md files
**Requires:** `bcs-rulet-extractor` agent with `claude.x` CLI
**Use case:** Creating quick reference guides, AI-optimized rule summaries

**Output format:**
- Files written to: `data/{NN}-{category}/00-{category}.rulet.md`
- Example: `data/02-variables/00-variables.rulet.md`

**Rulet format:**
Each rulet is a 1-2 sentence bullet point with:
- BCS code prefix: `[BCS0205]` or `[BCS0205,BCS0206]` for multiple sources
- Concise statement: actionable rule in imperative voice
- Code examples: inline backticks where helpful

**Example rulets:**
```markdown
## Readonly After Group Pattern

- [BCS0205] When declaring multiple readonly variables, initialize them first with values, then make them all readonly in a single statement: `readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME`.
- [BCS0205,BCS0206] Never make variables readonly individually when they belong to a logical group; this improves maintainability and visual clarity.
```

**Category resolution:**
The command accepts flexible category inputs:
- Numeric: `01`, `02`, `1`, `2`
- Name: `variables`, `arrays`, `functions`
- Full directory name: `01-script-structure`, `02-variables`

**Retry logic:**
The agent includes exponential backoff retry logic (3 retries with 5s, 10s, 20s delays) to handle API rate limits gracefully.

**Testing:**
Test suite: `tests/test-subcommand-generate-rulets.sh` (19/19 tests passing)

**Note:** This is a developer-mode feature for maintaining rulet documentation. The repository already contains rulet files extracted from complete.md files. Use `--force` to regenerate if complete.md files have been updated.

### Unified Toolkit Benefits

The `bcs` script provides a unified command interface with multiple benefits:

- Single command interface (`bcs`) with 13 subcommands
- Consistent help system (`bcs help <subcommand>`)
- Better error messages and validation
- Backward compatibility with legacy options (e.g., `bcs -c`, `bcs --json`)
- Additional features (search, decode, sections, compress)
- Comprehensive test coverage (19 test files)

### Validate Your Scripts

```bash
# All scripts must pass ShellCheck
shellcheck -x your-script.sh

# For scripts with documented exceptions
shellcheck -x your-script.sh
# Use #shellcheck disable=SCxxxx with explanatory comments
```

## Workflows

**NEW:** The `workflows/` directory provides production-ready scripts for common BCS maintenance and development tasks. These 8 comprehensive workflow scripts (2,939 lines) automate rule management, data validation, and compliance checking.

**Quick Overview:**
- 🔍 **30-validate-data.sh** - 11 validation checks for data integrity
- 📊 **04-interrogate-rule.sh** - Inspect rules by BCS code or file path
- ✅ **40-check-compliance.sh** - Batch compliance checking with reports
- 📝 **20-generate-canonical.sh** - Generate canonical BCS files
- 🗜️ **10-compress-rules.sh** - AI-powered rule compression
- ➕ **01-add-rule.sh** - Create new rules interactively
- ✏️ **02-modify-rule.sh** - Safely edit existing rules
- 🗑️ **03-delete-rule.sh** - Delete rules with safety checks

All workflows include dry-run modes, backup options, and comprehensive error handling.

### Available Workflows

#### 30-validate-data.sh
Comprehensive validation of the `data/` directory structure:

```bash
./workflows/30-validate-data.sh              # Run all 11 validation checks
./workflows/30-validate-data.sh --check tier-completeness  # Specific check
./workflows/30-validate-data.sh --quiet      # Minimal output
```

**Validation checks:**
1. Tier file completeness (.complete, .summary, .abstract all present)
2. BCS code uniqueness (no duplicate codes)
3. File naming conventions (NN-name.tier.md pattern)
4. BCS code format validation
5. Section directory naming
6. File size limits (summary ≤10KB, abstract ≤1.5KB)
7. BCS code markers in files
8. #fin markers present
9. Markdown structure validity
10. Cross-reference validation
11. Sequential numbering checks

#### 04-interrogate-rule.sh
Inspect rules by BCS code or file path:

```bash
./workflows/04-interrogate-rule.sh BCS0102              # Show rule info
./workflows/04-interrogate-rule.sh BCS0102 --show-tiers # Show all three tiers
./workflows/04-interrogate-rule.sh BCS0102 --format json  # JSON output
./workflows/04-interrogate-rule.sh data/01-script-structure/03-metadata.complete.md
```

#### 40-check-compliance.sh
Batch compliance checking with multiple output formats:

```bash
./workflows/40-check-compliance.sh script.sh           # Check single script
./workflows/40-check-compliance.sh *.sh                # Batch checking
./workflows/40-check-compliance.sh --format json script.sh
./workflows/40-check-compliance.sh --strict deploy.sh  # CI/CD mode
```

#### 20-generate-canonical.sh
Generate canonical BASH-CODING-STANDARD files from data/:

```bash
./workflows/20-generate-canonical.sh                   # Generate all tiers
./workflows/20-generate-canonical.sh --tier complete   # Specific tier
./workflows/20-generate-canonical.sh --backup          # Backup before generating
./workflows/20-generate-canonical.sh --validate        # Validate after generation
```

#### 10-compress-rules.sh
AI-powered wrapper for rule compression:

```bash
./workflows/10-compress-rules.sh                       # Check for oversized files
./workflows/10-compress-rules.sh --regenerate          # Regenerate all tiers
./workflows/10-compress-rules.sh --context-level abstract  # With context awareness
./workflows/10-compress-rules.sh --dry-run             # Preview changes
```

#### 01-add-rule.sh
Add new BCS rules interactively:

```bash
./workflows/01-add-rule.sh                             # Interactive mode
./workflows/01-add-rule.sh --section 02 --number 10 --name new-rule
./workflows/01-add-rule.sh --no-interactive --section 08 --number 05 --name trap-handlers
```

#### 02-modify-rule.sh
Modify existing rules safely:

```bash
./workflows/02-modify-rule.sh BCS0206                  # Edit by code
./workflows/02-modify-rule.sh data/02-variables/06-special-vars.complete.md
./workflows/02-modify-rule.sh BCS0206 --no-compress   # Skip auto-compression
./workflows/02-modify-rule.sh BCS0206 --validate      # Validate after edit
```

#### 03-delete-rule.sh
Delete rules with safety checks:

```bash
./workflows/03-delete-rule.sh BCS9999                  # Delete with confirmation
./workflows/03-delete-rule.sh BCS9999 --dry-run        # Preview deletion
./workflows/03-delete-rule.sh BCS9999 --force --no-backup  # Skip confirmation and backup
./workflows/03-delete-rule.sh BCS9999 --no-check-refs  # Skip reference checking
```

### Real-World Examples

The `examples/` directory contains three production-ready BCS-compliant scripts demonstrating real-world patterns:

**production-deploy.sh** (304 lines)
- Production deployment with backup and rollback
- Environment validation, health checks
- Dry-run mode, confirmation prompts
- Demonstrates: Complete BCS compliance, error handling, user interaction

**data-processor.sh** (183 lines)
- CSV file processing with validation
- Field validation, statistics tracking
- Demonstrates: Array operations, file I/O, validation patterns

**system-monitor.sh** (366 lines)
- System resource monitoring with alerts
- CPU, memory, disk usage tracking
- Email alerts, continuous monitoring mode
- Demonstrates: Thresholds, logging, colorized output

### Comprehensive Documentation

See **[docs/WORKFLOWS.md](docs/WORKFLOWS.md)** (1132 lines) for:
- Detailed workflow guides
- Usage examples and patterns
- Best practices
- Troubleshooting
- CI/CD integration examples

### Testing

All workflow scripts have comprehensive test coverage:
- `tests/test-workflow-validate.sh` - 20 tests
- `tests/test-workflow-interrogate.sh` - 20 tests
- `tests/test-workflow-check-compliance.sh` - 14 tests
- `tests/test-workflow-generate.sh` - 12 tests
- `tests/test-workflow-compress.sh` - 12 tests
- `tests/test-workflow-add.sh` - 14 tests
- `tests/test-workflow-modify.sh` - 12 tests
- `tests/test-workflow-delete.sh` - 14 tests

Run all workflow tests:
```bash
./tests/run-all-tests.sh  # Includes all 27 test files
```

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
11. `main()` function (for scripts >200 lines)
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

## Repository Structure

```
bash-coding-standard/
├── bcs                              # Main CLI toolkit script (v1.0.0, 156KB)
├── bash-coding-standard             # Symlink to bcs (backwards compatibility)
├── README.md                        # This file
├── ACTION-ITEMS.md                  # Consolidated action items from archived planning docs
├── TESTING-SUMMARY.md               # Test suite documentation (31 test files)
├── LICENSE                          # CC BY-SA 4.0 license
├── Makefile                         # Installation/uninstallation helper
├── lib/                             # Vendored dependencies (~540KB total)
│   ├── README.md                    # Dependency documentation and update procedures
│   ├── agents/                      # Claude AI agent wrappers
│   │   ├── bcs-rulet-extractor      # Rulet generation agent (v1.0.1, ~5KB)
│   │   └── bcs-compliance           # Compliance checking wrapper (v1.0.1, ~900B)
│   ├── md2ansi/                     # Markdown to ANSI renderer (~60KB)
│   │   ├── md2ansi                  # Main renderer script (installed to /usr/local/bin)
│   │   ├── md                       # Pager wrapper (installed to /usr/local/bin)
│   │   └── lib/                     # Renderer library files
│   ├── mdheaders/                   # Markdown header manipulation (~54KB)
│   │   ├── mdheaders                # Main CLI tool (installed to /usr/local/bin)
│   │   ├── libmdheaders.bash        # Library file (installed to /usr/local/bin)
│   │   └── README.md, LICENSE       # Documentation (GPL v3)
│   ├── whichx/                      # Command locator (~45KB)
│   │   ├── whichx                   # Main script (installed to /usr/local/bin, symlinked as 'which')
│   │   └── README.md, LICENSE       # Documentation (GPL v3)
│   ├── dux/                         # Directory size analyzer (~56KB)
│   │   ├── dir-sizes                # Main script (installed to /usr/local/bin, symlinked as 'dux')
│   │   └── README.md, LICENSE       # Documentation (GPL v3)
│   ├── printline/                   # Terminal line drawing utility (~52KB)
│   │   ├── printline                # Main script (installed to /usr/local/bin)
│   │   ├── .version                 # Version file
│   │   └── README.md, LICENSE       # Documentation (GPL v3)
│   ├── shlock/                      # Process locking utility (~16KB)
│   │   └── shlock                   # Shell locking script
│   ├── trim/                        # String trimming utilities (~92KB)
│   │   ├── trim, ltrim, rtrim       # Whitespace trimming scripts
│   │   ├── trimall, squeeze         # Whitespace normalization
│   │   ├── trimv                    # Trim with variable assignment
│   │   └── README.md, LICENSE       # Documentation (GPL v3)
│   ├── timer/                       # High-precision command timer (~47KB)
│   │   ├── timer                    # Microsecond-precision timer script
│   │   └── README.md, LICENSE       # Documentation (GPL v3)
│   ├── post_slug/                   # URL/filename slug generator (~40KB)
│   │   ├── post_slug.bash           # Slug generation script
│   │   └── LICENSE                  # GPL v3 license
│   ├── hr2int/                      # Human-readable number converter (~3KB)
│   │   └── hr2int.bash              # Number conversion script (hr↔int)
│   ├── remblanks/                   # Comment/blank line stripper (~1KB)
│   │   └── remblanks                # Tiny grep-based utility
│   └── LICENSES/                    # Dependency licenses (~321KB)
│       ├── md2ansi.LICENSE          # MIT license
│       ├── mdheaders.LICENSE        # GPL v3 license
│       ├── whichx.LICENSE           # GPL v3 license
│       ├── dux.LICENSE              # GPL v3 license
│       ├── printline.LICENSE        # GPL v3 license
│       ├── shlock.LICENSE           # MIT license
│       ├── trim.LICENSE             # GPL v3 license
│       ├── timer.LICENSE            # GPL v3 license
│       └── post_slug.LICENSE        # GPL v3 license
├── docs/                            # Comprehensive usage guides
│   ├── BCS-DECODE-PATTERNS.md       # Advanced decode patterns and workflows (481 lines)
│   └── BCS-COMPRESS-GUIDE.md        # Complete compression guide (665 lines)
├── .gudang/                         # Archived analysis and planning documents
├── data/                            # Canonical rule source files (generates standard)
│   ├── BASH-CODING-STANDARD.md      # Symlink to default tier (currently summary)
│   ├── BASH-CODING-STANDARD.complete.md # Complete tier (21,431 lines)
│   ├── BASH-CODING-STANDARD.summary.md  # Summary tier (12,666 lines) - gitignored
│   ├── BASH-CODING-STANDARD.abstract.md # Abstract tier (3,794 lines) - gitignored
│   ├── 01-script-structure/         # Section 1 rules
│   │   ├── 02-shebang/              # Shebang subsection
│   │   │   └── 01-dual-purpose.md   # BCS010201 - Dual-purpose scripts
│   │   ├── 03-metadata.md           # BCS0103 - Script metadata
│   │   └── ...
│   ├── 02-variables/                # Section 2 rules
│   └── ...
├── workflows/                       # User workflow scripts for typical BCS operations
│   ├── 01-add-rule.sh               # Add new BCS rule interactively
│   ├── 02-modify-rule.sh            # Modify existing rule safely
│   ├── 03-delete-rule.sh            # Delete rule with safety checks
│   ├── 04-interrogate-rule.sh       # Inspect rules by BCS code or file path
│   ├── 10-compress-rules.sh         # AI-powered rule compression wrapper
│   ├── 20-generate-canonical.sh     # Generate canonical BCS files from data/
│   ├── 30-validate-data.sh          # Validate data/ directory (11 checks)
│   └── 40-check-compliance.sh       # Batch compliance checking with reports
├── examples/                        # Real-world BCS-compliant example scripts
│   ├── production-deploy.sh         # Production deployment with backup/rollback
│   ├── data-processor.sh            # CSV processing with validation
│   └── system-monitor.sh            # System resource monitoring with alerts
├── tests/                           # Test suite (31 test files)
│   ├── test-helpers.sh              # Test helper functions (12 enhanced helpers)
│   ├── coverage.sh                  # Test coverage analyzer
│   ├── run-all-tests.sh             # Run entire test suite
│   ├── fixtures/                    # Test fixture scripts
│   │   ├── sample-minimal.sh        # Minimal BCS-compliant script
│   │   ├── sample-complete.sh       # Full-featured BCS-compliant script
│   │   └── sample-non-compliant.sh  # Non-compliant script for testing
│   ├── test-bash-coding-standard.sh # Core functionality tests
│   ├── test-argument-parsing.sh     # Argument parsing tests
│   ├── test-data-structure.sh       # Data directory integrity validation
│   ├── test-integration.sh          # End-to-end workflow tests
│   ├── test-self-compliance.sh      # BCS compliance self-validation
│   ├── test-subcommand-dispatcher.sh # Command routing tests
│   ├── test-subcommand-display.sh   # Display subcommand tests
│   ├── test-subcommand-about.sh     # About subcommand tests
│   ├── test-subcommand-codes.sh     # Codes subcommand tests
│   ├── test-subcommand-generate.sh  # Generate subcommand tests
│   ├── test-subcommand-search.sh    # Search subcommand tests
│   ├── test-subcommand-decode.sh    # Decode subcommand tests
│   ├── test-subcommand-sections.sh  # Sections subcommand tests
│   ├── test-subcommand-template.sh  # Template subcommand tests
│   ├── test-subcommand-check.sh     # Check subcommand tests
│   ├── test-subcommand-compress.sh  # Compress subcommand tests
│   ├── test-workflow-validate.sh    # Workflow validation tests
│   ├── test-workflow-interrogate.sh # Workflow interrogation tests
│   ├── test-workflow-check-compliance.sh # Workflow compliance tests
│   ├── test-workflow-generate.sh    # Workflow generation tests
│   ├── test-workflow-compress.sh    # Workflow compression tests
│   ├── test-workflow-add.sh         # Workflow add-rule tests
│   ├── test-workflow-modify.sh      # Workflow modify-rule tests
│   └── test-workflow-delete.sh      # Workflow delete-rule tests
└── builtins/                        # High-performance loadable builtins (separate sub-project)
    ├── README.md                    # Complete user guide
    ├── QUICKSTART.md                # Fast-start installation
    ├── CREATING-BASH-BUILTINS.md   # Developer guide
    ├── PERFORMANCE.md               # Benchmark results
    ├── Makefile                     # Build system
    ├── install.sh / uninstall.sh   # Installation scripts
    ├── src/                         # C source code (basename, dirname, realpath, head, cut)
    └── test/                        # Builtin test suite
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

### BCS Rules Filename Structure

Understanding the filename structure is critical for adding or modifying rules.

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

**Source-Generated Hierarchy:**

**`.complete.md` is the CANONICAL source** - the other two tiers are derivatives:

```
01-layout.complete.md  (SOURCE - manually written)
    ↓ generates
01-layout.summary.md   (DERIVED - compressed version)
    ↓ generates
01-layout.abstract.md  (DERIVED - minimal version)
```

**Workflow:**
1. Edit the `.complete.md` file (the authoritative version)
2. Generate `.summary.md` and `.abstract.md` from it using compression tools
3. Never edit `.summary.md` or `.abstract.md` directly - regenerate them from `.complete.md`
4. Run `./bcs generate --canonical` to rebuild the final BASH-CODING-STANDARD.md

## BCS Ruleset Structure

This section provides comprehensive documentation of the BCS ruleset architecture, terminology, and file organization. Understanding this structure is essential for both human programmers and AI assistants working with the Bash Coding Standard.

### Terminology

The BCS uses precise terminology to describe different components of the ruleset:

#### Rule

A **rule** is a description of a specific coding requirement or pattern in markdown format. Each rule documents:
- What the requirement is (the rule itself)
- Why it exists (rationale)
- How to implement it (examples)
- What not to do (anti-patterns)

Example: "Always use `set -euo pipefail` early in scripts (BCS0801)"

#### Rule Category (rulecat)

A **rule category** (rulecat) is a logical grouping of related rules represented as a directory in the `data/` tree. Each rulecat corresponds to one of the 14 major sections of the Bash Coding Standard.

**Name format:** `{[0-9][0-9]}-{short-category-title}/`

Examples:
- `01-script-structure/` - Rules about script organization and layout
- `02-variables/` - Rules about variable declarations and constants
- `07-control-flow/` - Rules about conditionals, loops, and case statements
- `14-advanced-patterns/` - Rules about debugging, logging, and testing

Within each rulecat directory, there are rulefiles.

#### Rule File (rulefile)

A **rulefile** contains a description of a rule or group of rules in markdown format. Rulefiles exist in three tiers plus an optional rulet format.

**Name format:** `{[0-9][0-9]}-{rule-file-title}.{tier}.md`

Examples:
- `02-shebang.complete.md` - Complete version of shebang rule
- `02-shebang.summary.md` - Summary version of shebang rule
- `02-shebang.abstract.md` - Abstract version of shebang rule
- `00-variables.rulet.md` - Rulet extraction for variables category

**The canonical rulefile for any rule is `.complete.md`** - the summary and abstract tiers are generated from complete, and rulet files are extracted from complete.

Within each rulefile, there are extractable rulets.

#### Rulet

A **rulet** is a highly refined, accurate, and concise rule expressed as a one- or two-sentence bullet point. Rulets are the distilled essence of rules, optimized for quick reference and AI consumption.

**Characteristics:**
- 1-2 sentences maximum per rulet
- Actionable: "what to do" and "what not to do"
- Include code examples in backticks where helpful
- No explanations, rationale, or background - only pure rules
- Grouped under logical section headers
- **Prefixed with BCS code reference** to show source rule(s)

**BCS Code Reference Format:**

Each rulet is prefixed with its source BCS code(s) in square brackets:

- **Single source**: `[BCS0205] Rulet text here...`
- **Multiple sources**: `[BCS0205,BCS0206] Combined rulet from multiple rules...`

This enables quick lookup using `bcs decode BCS0205` to read the full source rule.

**Example rulets:**
```markdown
## Variable Quoting in Conditionals

- [BCS0406] Always quote variables in test expressions: `[[ -f "$file" ]]`
- [BCS0406] Never leave variables unquoted in conditionals
- [BCS0406] Quote variables in integer comparisons: `[[ "$count" -eq 0 ]]`

## Readonly After Group Pattern

- [BCS0205] When declaring multiple readonly variables, initialize them first with values, then make them all readonly in a single statement: `readonly -- VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME`.
- [BCS0205] Group logically related variables together for readability: script metadata group, color definitions group, path constants group.
- [BCS0205,BCS0206] Never make variables readonly individually when they belong to a logical group; this improves maintainability and visual clarity.
```

**Rulet file format:** `00-{short-category-title}.rulet.md`

Example: `data/02-variables/00-variables.rulet.md`

### Multi-Tier Documentation System

The BCS uses a sophisticated four-tier documentation system to serve different use cases:

#### Complete Tier (.complete.md) - CANONICAL SOURCE

- **Purpose**: Authoritative, fully-detailed documentation
- **Audience**: Learning, reference, comprehensive understanding
- **Content**: Full examples, rationale, edge cases, anti-patterns
- **Status**: **SOURCE** - manually written and edited
- **Size**: Largest (typically 200-2000 lines per rule)
- **Example**: `data/02-variables/05-readonly-after-group.complete.md`

**This is the ONLY file you should edit.** All other tiers are generated from complete.

#### Summary Tier (.summary.md) - DERIVED

- **Purpose**: Balanced documentation with key examples
- **Audience**: Daily reference, quick lookup
- **Content**: Essential examples, concise explanations
- **Status**: **DERIVED** - generated from .complete.md using `bcs compress`
- **Size**: Medium (typically 50-70% of complete)
- **Example**: `data/02-variables/05-readonly-after-group.summary.md`

**Never edit directly** - regenerate using `bcs compress`.

#### Abstract Tier (.abstract.md) - DERIVED

- **Purpose**: Minimal, rules-only documentation
- **Audience**: Experienced developers, quick scanning
- **Content**: Rules only, minimal examples
- **Status**: **DERIVED** - generated from .summary.md using `bcs compress`
- **Size**: Smallest (typically 15-30% of complete)
- **Example**: `data/02-variables/05-readonly-after-group.abstract.md`

**Never edit directly** - regenerate using `bcs compress`.

#### Rulet Format (.rulet.md) - EXTRACTED

- **Purpose**: Ultra-concise, one-liner rule extraction
- **Audience**: AI assistants, cheat sheets, quick reference
- **Content**: 1-2 sentence rulets with minimal code examples
- **Status**: **EXTRACTED** - generated from all .complete.md files in category using `bcs generate-rulets`
- **Size**: One file per category (typically 50-200 lines total)
- **Example**: `data/02-variables/00-variables.rulet.md`

**Never edit directly** - regenerate using `bcs generate-rulets`.

### File Naming Conventions

Understanding the naming patterns is critical for navigating and modifying the BCS ruleset.

#### Rule Category Directory

**Format:** `{[0-9][0-9]}-{short-category-title}/`

- Two-digit zero-padded number (01-14)
- Hyphen separator
- Lowercase with hyphens
- No spaces

**Examples:**
```
01-script-structure/
02-variables/
07-control-flow/
14-advanced-patterns/
```

#### Rule File

**Format:** `{[0-9][0-9]}-{rule-file-title}.{tier}.md`

- Two-digit zero-padded number (matches position in category)
- Hyphen separator
- Lowercase descriptive title with hyphens
- Tier identifier (`.complete`, `.summary`, `.abstract`)
- Markdown extension (`.md`)

**Examples:**
```
02-shebang.complete.md
02-shebang.summary.md
02-shebang.abstract.md
05-readonly-after-group.complete.md
05-readonly-after-group.summary.md
05-readonly-after-group.abstract.md
```

#### Section Overview File

**Format:** `00-section.{tier}.md`

Every rulecat contains a section overview file that describes the category as a whole.

**Examples:**
```
data/02-variables/00-section.complete.md
data/02-variables/00-section.summary.md
data/02-variables/00-section.abstract.md
```

#### Rulet File

**Format:** `00-{short-category-title}.rulet.md`

One rulet file per category, containing extracted rulets from all rules in that category.

**Examples:**
```
data/01-script-structure/00-script-structure.rulet.md
data/02-variables/00-variables.rulet.md
data/07-control-flow/00-control-flow.rulet.md
```

#### Subrule Directory

**Format:** `{[0-9][0-9]}-{rule-file-title}/`

When a rule has sub-rules, create a directory with the same numeric prefix and title as the parent rule.

**Example:**
```
02-shebang.complete.md              (Parent rule - BCS0102)
02-shebang/                         (Subrule directory)
└── 01-dual-purpose.complete.md     (Subrule - BCS010201)
```

### Directory Hierarchy

The complete `data/` directory structure follows this pattern:

```
data/
├── 00-header.{complete,summary,abstract}.md    # Document header
├── BASH-CODING-STANDARD.{complete,summary,abstract}.md  # Generated standard files
│
├── 01-script-structure/                        # BCS01 - Script Structure category
│   ├── 00-script-structure.rulet.md            # Rulet file for category
│   ├── 00-section.{complete,summary,abstract}.md  # Section overview
│   ├── 01-layout/                              # Subrule directory for layout
│   │   ├── 01-complete-example.{complete,summary,abstract}.md
│   │   ├── 02-anti-patterns.{complete,summary,abstract}.md
│   │   └── 03-edge-cases.{complete,summary,abstract}.md
│   ├── 01-layout.{complete,summary,abstract}.md    # BCS0101 - Layout rule
│   ├── 02-shebang/                             # Subrule directory for shebang
│   │   └── 01-dual-purpose.{complete,summary,abstract}.md  # BCS010201
│   ├── 02-shebang.{complete,summary,abstract}.md   # BCS0102 - Shebang rule
│   ├── 03-metadata.{complete,summary,abstract}.md  # BCS0103 - Metadata rule
│   ├── 04-fhs.{complete,summary,abstract}.md       # BCS0104 - FHS rule
│   ├── 05-shopt.{complete,summary,abstract}.md     # BCS0105 - shopt rule
│   ├── 06-extensions.{complete,summary,abstract}.md  # BCS0106 - Extensions rule
│   └── 07-function-organization.{complete,summary,abstract}.md  # BCS0107
│
├── 02-variables/                               # BCS02 - Variables category
│   ├── 00-variables.rulet.md                   # Rulet file for category
│   ├── 00-section.{complete,summary,abstract}.md  # Section overview
│   ├── 01-type-specific.{complete,summary,abstract}.md  # BCS0201
│   ├── 02-scoping.{complete,summary,abstract}.md      # BCS0202
│   ├── 03-naming.{complete,summary,abstract}.md       # BCS0203
│   └── ...                                     # Additional variable rules
│
├── 03-expansion/                               # BCS03 - Expansion category
├── 04-quoting/                                 # BCS04 - Quoting category
├── 05-arrays/                                  # BCS05 - Arrays category
├── 06-functions/                               # BCS06 - Functions category
├── 07-control-flow/                            # BCS07 - Control Flow category
├── 08-error-handling/                          # BCS08 - Error Handling category
├── 09-io-messaging/                            # BCS09 - I/O & Messaging category
├── 10-command-line-args/                       # BCS10 - Command-Line Args category
├── 11-file-operations/                         # BCS11 - File Operations category
├── 12-security/                                # BCS12 - Security category
├── 13-code-style/                              # BCS13 - Code Style category
├── 14-advanced-patterns/                       # BCS14 - Advanced Patterns category
│
├── templates/                                  # Script templates
│   ├── minimal.sh.template
│   ├── basic.sh.template
│   ├── complete.sh.template
│   └── library.sh.template
│
└── README.md                                   # Data directory documentation
```

**Key observations:**
- **14 rule categories** (01-14), each with its own directory
- **Section overviews** (`00-section.*.md`) in every category
- **Rulet files** (`00-*.rulet.md`) in every category
- **Three tiers** (complete, summary, abstract) for every rule
- **Subrule directories** have same numeric prefix as parent rule
- **Consistent naming** enables deterministic code generation

### BCS Code Mapping

BCS codes are derived directly from the directory and file structure. Understanding this mapping is essential for navigating the ruleset.

#### Code Generation Rules

**Pattern:** Extract numeric prefixes from file path, concatenate, prefix with "BCS"

**Examples:**

| File Path | Numeric Extraction | BCS Code |
|-----------|-------------------|----------|
| `01-script-structure/` | `01` | `BCS01` (section) |
| `01-script-structure/00-section.md` | `01` + `00` | `BCS0100` (section overview) |
| `01-script-structure/02-shebang.md` | `01` + `02` | `BCS0102` (rule) |
| `01-script-structure/02-shebang/01-dual-purpose.md` | `01` + `02` + `01` | `BCS010201` (subrule) |
| `02-variables/05-readonly-after-group.md` | `02` + `05` | `BCS0205` (rule) |
| `14-advanced-patterns/03-temp-files.md` | `14` + `03` | `BCS1403` (rule) |

#### Code Types

**Section Code** (2 digits): `BCS01`, `BCS02`, ..., `BCS14`
- Identifies a rule category
- Maps to directory: `01-script-structure/`, `02-variables/`, etc.

**Section Overview Code** (4 digits ending in 00): `BCS0100`, `BCS0200`
- Identifies section overview file
- Maps to file: `01-script-structure/00-section.md`

**Rule Code** (4 digits): `BCS0102`, `BCS0205`, `BCS1403`
- Identifies a specific rule
- Maps to file: `01-script-structure/02-shebang.md`

**Subrule Code** (6+ digits): `BCS010201`, `BCS01020304`
- Identifies a subrule or sub-subrule
- Maps to file: `01-script-structure/02-shebang/01-dual-purpose.md`
- System supports unlimited nesting depth

#### Decoding BCS Codes

Use the `bcs decode` command to resolve BCS codes to file locations:

```bash
# Decode to file path (default tier from BASH-CODING-STANDARD.md symlink)
bcs decode BCS0102
# Output: data/01-script-structure/02-shebang.summary.md

# Decode to file path (specific tier)
bcs decode BCS0102 -c      # complete tier
bcs decode BCS0102 -s      # summary tier
bcs decode BCS0102 -a      # abstract tier

# Print rule content to stdout
bcs decode BCS0102 -p      # Print default tier content
bcs decode BCS0102 -c -p   # Print complete tier content

# Decode section code
bcs decode BCS01           # Returns: data/01-script-structure/00-section.summary.md
bcs decode BCS01 -p        # Print section overview content

# Decode multiple codes
bcs decode BCS01 BCS02 BCS08 -p   # Print multiple sections

# Show all tiers
bcs decode BCS0102 --all   # Show paths to all three tiers
```

See `docs/BCS-DECODE-PATTERNS.md` for comprehensive decode usage patterns.

### Tier Generation Workflow

Understanding the generation hierarchy is critical for maintaining the BCS ruleset.

```
                    EDIT THIS
                        ↓
            ┌──────────────────────┐
            │  .complete.md        │  ← SOURCE (manually written)
            │  (2,000 lines)       │
            └──────────────────────┘
                        ↓
                 bcs compress
                 --tier summary
                        ↓
            ┌──────────────────────┐
            │  .summary.md         │  ← DERIVED (compressed)
            │  (1,200 lines)       │
            └──────────────────────┘
                        ↓
                 bcs compress
                 --tier abstract
                        ↓
            ┌──────────────────────┐
            │  .abstract.md        │  ← DERIVED (compressed)
            │  (400 lines)         │
            └──────────────────────┘
                        ↓
              bcs generate-rulets
             (process all .complete
              files in category)
                        ↓
            ┌──────────────────────┐
            │  .rulet.md           │  ← EXTRACTED (one-liners)
            │  (150 lines)         │
            └──────────────────────┘
```

**Generation Commands:**

```bash
# Compress complete → summary → abstract
cd /path/to/bash-coding-standard
bcs compress --regenerate           # Regenerate all tiers

# Extract rulets from complete files
bcs generate-rulets --regenerate    # Regenerate all rulet files

# Generate final standard document
bcs generate --canonical            # Generate BASH-CODING-STANDARD.md
```

**Critical Rules:**

1. **Only edit .complete.md files** - Never edit .summary.md, .abstract.md, or .rulet.md
2. **Regenerate after edits** - Run `bcs compress` and `bcs generate-rulets` after editing .complete.md
3. **Version control .complete.md only** - Derived files are gitignored (except rulet files which are tracked for reference)
4. **Test before committing** - Run `bcs generate --canonical` to ensure standard regenerates correctly

### Working with Rulesets

#### Adding a New Rule

1. **Create .complete.md file** with appropriate numeric prefix:
   ```bash
   cd data/02-variables
   touch 10-my-new-rule.complete.md
   ```

2. **Write comprehensive rule** in .complete.md:
   - Clear title and BCS code comment
   - Full explanation with rationale
   - Multiple examples
   - Anti-patterns
   - Edge cases

3. **Generate derived tiers**:
   ```bash
   bcs compress --regenerate --category 02
   ```

4. **Update rulet file**:
   ```bash
   bcs generate-rulets --regenerate --category 02
   ```

5. **Regenerate standard**:
   ```bash
   bcs generate --canonical
   ```

6. **Verify**:
   ```bash
   bcs codes | grep BCS0210    # Check code appears
   bcs decode BCS0210 -p       # View rule content
   ```

#### Modifying an Existing Rule

1. **Edit .complete.md file** (never edit derived tiers):
   ```bash
   vim data/02-variables/05-readonly-after-group.complete.md
   ```

2. **Regenerate derived tiers**:
   ```bash
   bcs compress --regenerate --tier summary
   bcs compress --regenerate --tier abstract
   ```

3. **Update rulet file**:
   ```bash
   bcs generate-rulets --regenerate --category 02
   ```

4. **Verify changes**:
   ```bash
   bcs decode BCS0205 -p
   ```

#### Deleting a Rule

1. **Remove all tier files**:
   ```bash
   rm data/02-variables/05-readonly-after-group.*.md
   ```

2. **Regenerate rulet file**:
   ```bash
   bcs generate-rulets --regenerate --category 02
   ```

3. **Regenerate standard**:
   ```bash
   bcs generate --canonical
   ```

4. **Verify removal**:
   ```bash
   bcs codes | grep BCS0205    # Should not appear
   ```

### Relationship Diagram

Visual representation of how all components relate:

```
BCS RULESET ARCHITECTURE
═══════════════════════════════════════════════════════════════

 RULECAT (Category Directory)
 ┌────────────────────────────────────────────────────────────┐
 │ 02-variables/                              BCS02 (Section) │
 │                                                             │
 │  SECTION OVERVIEW                                           │
 │  ┌───────────────────────────────────────────────────────┐ │
 │  │ 00-section.complete.md      BCS0200 (Overview)        │ │
 │  │ 00-section.summary.md       (DERIVED)                 │ │
 │  │ 00-section.abstract.md      (DERIVED)                 │ │
 │  └───────────────────────────────────────────────────────┘ │
 │                                                             │
 │  RULET FILE (Category Summary)                              │
 │  ┌───────────────────────────────────────────────────────┐ │
 │  │ 00-variables.rulet.md       (EXTRACTED from all       │ │
 │  │                              .complete.md files)       │ │
 │  └───────────────────────────────────────────────────────┘ │
 │                                                             │
 │  RULEFILE (Individual Rule)                                 │
 │  ┌───────────────────────────────────────────────────────┐ │
 │  │ 05-readonly-after-group.complete.md   BCS0205         │ │
 │  │ 05-readonly-after-group.summary.md    (DERIVED)       │ │
 │  │ 05-readonly-after-group.abstract.md   (DERIVED)       │ │
 │  └───────────────────────────────────────────────────────┘ │
 │                                                             │
 │  SUBRULE DIRECTORY                                          │
 │  ┌───────────────────────────────────────────────────────┐ │
 │  │ 07-boolean-flags/             (Subrule container)     │ │
 │  │ └── 01-integer-declaration.complete.md  BCS020701     │ │
 │  │     01-integer-declaration.summary.md   (DERIVED)     │ │
 │  │     01-integer-declaration.abstract.md  (DERIVED)     │ │
 │  └───────────────────────────────────────────────────────┘ │
 └────────────────────────────────────────────────────────────┘

GENERATION FLOW
═══════════════════════════════════════════════════════════════

  .complete.md (SOURCE)
       ↓
  [bcs compress]
       ↓
  .summary.md (DERIVED)
       ↓
  [bcs compress]
       ↓
  .abstract.md (DERIVED)
       ↓
  [bcs generate-rulets]
       ↓
  .rulet.md (EXTRACTED)
```

### Cross-References

Related documentation:
- **[BCS Code Structure](#bcs-code-structure)** - How BCS codes are generated from file paths
- **[bcs compress](docs/BCS-COMPRESS-GUIDE.md)** - Complete guide to tier compression
- **[bcs decode](docs/BCS-DECODE-PATTERNS.md)** - Advanced decode patterns and workflows
- **[bcs generate](#generate)** - Regenerating the canonical standard
- **[bcs generate-rulets](#generate-rulets)** - Generating rulet files (future)
- **[Data README](data/README.md)** - Data directory structure documentation

### Summary

**Key Takeaways for Programmers:**
- Edit only `.complete.md` files (canonical source)
- Regenerate derived tiers after editing
- Use `bcs codes` to find BCS codes
- Use `bcs decode` to resolve codes to files
- Follow strict naming conventions
- Rulet files provide quick reference

**Key Takeaways for AI Assistants:**
- `.complete.md` = SOURCE (edit here)
- `.summary.md` and `.abstract.md` = DERIVED (never edit)
- `.rulet.md` = EXTRACTED (never edit)
- BCS codes map directly to file paths
- Multi-tier system serves different use cases
- Rulets are optimized for AI consumption

**File Generation Hierarchy:**
```
complete.md → summary.md → abstract.md → rulet.md
  (SOURCE)     (DERIVED)     (DERIVED)   (EXTRACTED)
```

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

- **[BASH-CODING-STANDARD.md](data/BASH-CODING-STANDARD.md)** - The coding standard (symlink to summary tier, 12,666 lines, 14 sections)
  - Also available: [Complete tier](data/BASH-CODING-STANDARD.complete.md) (21,431 lines), [Abstract tier](data/BASH-CODING-STANDARD.abstract.md) (3,794 lines)
- **[ACTION-ITEMS.md](ACTION-ITEMS.md)** - Consolidated action items from archived planning documents
- **[TESTING-SUMMARY.md](TESTING-SUMMARY.md)** - Test suite documentation (31 test files)

**Usage Guides:**
- **[docs/WORKFLOWS.md](docs/WORKFLOWS.md)** - **NEW:** Complete workflow automation guide (1,132 lines, 14 sections)
- **[docs/BCS-DECODE-PATTERNS.md](docs/BCS-DECODE-PATTERNS.md)** - Comprehensive decode patterns and workflows (481 lines, 9 usage patterns)
- **[docs/BCS-COMPRESS-GUIDE.md](docs/BCS-COMPRESS-GUIDE.md)** - Complete compression guide with context levels (665 lines)

**Archived Reference:**
- See `.gudang/REBUTTALS-FAQ.md` for responses to common criticisms and FAQs (archived)

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

## Usage Guidance

### For Human Developers

1. Read [BASH-CODING-STANDARD.md](data/BASH-CODING-STANDARD.md) thoroughly
2. Use the standard utility functions (`_msg`, `vecho`, `success`, `warn`, `info`, `error`, `die`)
3. Always run `shellcheck -x` before committing
4. Follow the 14-section structure when reading/writing complex scripts
5. Use single quotes for static strings, double quotes for variables

### For AI Assistants

1. All generated scripts must comply with [BASH-CODING-STANDARD.md](data/BASH-CODING-STANDARD.md)
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

### v1.1.0 (2025-10-17) - Workflow System Addition

**NEW: Comprehensive Workflow Automation System**
- **8 Production-Ready Workflow Scripts** (2,939 lines)
  - `01-add-rule.sh` - Interactive rule creation with templates
  - `02-modify-rule.sh` - Safe rule modification with auto-backup
  - `03-delete-rule.sh` - Safe deletion with reference checking
  - `04-interrogate-rule.sh` - Rule inspection with multiple output formats
  - `10-compress-rules.sh` - AI-powered compression with context awareness
  - `20-generate-canonical.sh` - Canonical file generation with backup/validation
  - `30-validate-data.sh` - 11 validation checks for data/ directory integrity
  - `40-check-compliance.sh` - Batch compliance checking with JSON/markdown reports

- **Real-World Examples** (3 scripts, 853 lines)
  - `production-deploy.sh` - Production deployment patterns
  - `data-processor.sh` - CSV processing and validation
  - `system-monitor.sh` - System resource monitoring

- **Comprehensive Testing** (8 test suites, 118 tests)
  - Test fixtures for all scenarios
  - Integration with existing test framework
  - All tests use standard test-helpers.sh pattern

- **Documentation**
  - `docs/WORKFLOWS.md` (1,132 lines) - Complete workflow guide
  - README.md updated with workflow section
  - Usage examples and best practices
  - CI/CD integration patterns

**Features:**
- ✅ Complete CRUD operations for BCS rules
- ✅ Data validation and integrity checking
- ✅ Multiple output formats (text, JSON, markdown)
- ✅ Safety features (dry-run, backups, confirmations)
- ✅ AI integration for compression and compliance
- ✅ Fully tested and documented

### v1.0.0 (2025-10-17) - Major Improvements

**Phase 4: Alias Removal & Symlink-Based Configuration**
- **All command aliases removed** for simplification (v1.0.0+)
  - Removed: `show`, `info`, `list-codes`, `regen`, `grep`, `toc`
  - Impact: Cleaner UX, reduced cognitive load, simpler documentation
  - Use canonical names only: `display`, `about`, `codes`, `generate`, `search`, `sections`

- **Symlink-based default tier detection** implemented (v1.0.0+)
  - New function: `get_default_tier()` reads `data/BASH-CODING-STANDARD.md` symlink
  - Default tier now dynamic based on symlink target (`.complete.md`, `.abstract.md`, `.summary.md`)
  - Commands affected: `generate`, `decode`, `check`
  - Single source of truth for default tier configuration
  - Change default tier project-wide: `ln -sf BASH-CODING-STANDARD.complete.md data/BASH-CODING-STANDARD.md`

- **Test Suite Enhancements** (see `TESTING-SUMMARY.md`)
  - **19 test files** (was 15), 600+ tests, **74% pass rate** (was 6%)
  - New tests: data structure validation, integration tests, self-compliance
  - Coverage tracking: 39% function coverage, 100% command coverage
  - CI/CD pipelines: Automated testing, shellcheck, releases
  - 12 new test helpers: Enhanced assertions, mocking, fixtures

- **Bugs discovered and fixed:**
  1. Duplicate BCS0206 code (critical - needs resolution)
  2. Missing main() function in bcs script
  3. Missing VERSION variable
  4. Corrupted data file (fixed: `data/01-script-structure/02-shebang/01-dual-purpose.complete.md`)

**BCS Toolkit Enhancements:**
- **Section codes supported** - `BCS01`, `BCS02`, etc. return `00-section.{tier}.md` files
- **Multiple codes supported** in `bcs decode` - process multiple codes in a single command
  - Example: `bcs decode BCS01 BCS02 BCS08 -p` prints all three sections
  - Automatic separators added between codes in print mode
- **Three-tier documentation system** fully implemented:
  - **Complete** (.complete.md) - Full examples and explanations (canonical source, 21,431 lines)
  - **Summary** (.summary.md) - Medium detail with key examples (derived, 12,666 lines)
  - **Abstract** (.abstract.md) - Rules and patterns only (derived, 3,794 lines)
- **New `compress` subcommand** for maintaining multi-tier documentation:
  - AI-powered compression of .complete.md files to .summary.md and .abstract.md tiers
  - Five context awareness levels (none, toc, abstract, summary, complete) for cross-rule deduplication
  - Automatic file permissions (664) and timestamp syncing across tiers

**Documentation:**
- README.md significantly expanded with comprehensive usage patterns
- CLAUDE.md updated with Phase 4 changes and test information
- TESTING-SUMMARY.md created documenting complete test suite revamp
- Clarified section codes, multiple codes, and tier selection
- Updated all examples to reflect symlink-based defaults

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

This standard transforms Bash from a loose scripting tool into a reliable programming platform by codifying engineering discipline for production-grade automation, data processing, and infrastructure orchestration.

### Core Philosophy

Modern software development increasingly relies on automated refactoring, AI-assisted coding, and static analysis tools. This standard provides **deterministic patterns**, **strict structural requirements**, **consistent conventions**, and **security-first practices** designed to be equally parseable by humans and AI assistants.

### Key Pillars

The standard is built on four foundational pillars (detailed in Core Principles section):

1. **Structural Discipline**: 13-step mandatory script structure, bottom-up function organization, required `main()` for scripts >200 lines
2. **Safety & Reliability**: Strict error handling (`set -euo pipefail`), safe arithmetic patterns, process substitution over pipes, explicit wildcard paths
3. **Code Clarity**: Explicit variable declarations with type hints, readonly after group pattern, consistent quoting discipline (single for static, double for expansion)
4. **Production Quality**: Standard messaging functions, ShellCheck compliance, security hardening (no SUID/SGID, PATH validation, input sanitization)

### Compliance Requirements

- **Bash 5.2+ exclusive** - Modern features, not a compatibility standard
- **ShellCheck compulsory** - All scripts must pass with documented exceptions
- **FHS (Filesystem Hierarchy Standard)** - Standard installation locations
- **CC BY-SA 4.0 license** - Attribution required, share-alike for derivatives

### Flexibility & Pragmatism

The standard emphasizes **avoiding over-engineering**. Scripts should be as simple as necessary, but no simpler:

- Scripts >200 lines require `main()` function; shorter scripts can be simpler
- Remove unused utility functions in production
- Include only required structures—not every script needs all patterns
- Provides comprehensive patterns for complex scripts while allowing simpler structures for straightforward tasks

**Target audience:** Both human developers building production systems and AI assistants generating/refactoring code. Deterministic patterns enable both to produce consistent, maintainable, secure Bash scripts.

---

**In summary:** This standard codifies professional Bash development as disciplined engineering, providing structure for reliable automation while matching complexity to requirements.

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

*Version: 1.1.0*
*Last updated: 2025-10-17*
