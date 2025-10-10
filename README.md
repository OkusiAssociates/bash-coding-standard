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

Clone this repository or install the viewer script globally:

```bash
# Clone the repository
git clone https://github.com/OkusiAssociates/bash-coding-standard.git
cd bash-coding-standard

# Optional: Install bash-coding-standard viewer globally
sudo cp bash-coding-standard /usr/local/bin/
sudo chmod +x /usr/local/bin/bash-coding-standard
```

### View the Standard

```bash
# View in terminal with markdown rendering (if md2ansi is installed)
./bash-coding-standard

# Or view directly
cat BASH-CODING-STANDARD.md

# Or if installed globally
bash-coding-standard
```

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
├── BASH-CODING-STANDARD.md          # The complete coding standard (2,145 lines)
├── bash-coding-standard             # Viewer script for the standard
├── CLAUDE.md                        # Guidance for Claude Code AI assistant
├── RESTRUCTURE-VALIDATION.md        # Validation checklist for 2025-10-10 restructuring
├── README.md                        # This file
├── LICENSE                          # CC BY-SA 4.0 license
├── .gitcommit                       # Helper script for git operations
└── .github/                         # GitHub workflows and configuration
```

## Documentation

### Primary Documents

- **[BASH-CODING-STANDARD.md](BASH-CODING-STANDARD.md)** - The complete coding standard (2,145 lines, 14 sections)
- **[CLAUDE.md](CLAUDE.md)** - Instructions for Claude Code when working with this repository
- **[RESTRUCTURE-VALIDATION.md](RESTRUCTURE-VALIDATION.md)** - Validation of the 2025-10-10 restructuring

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
SCRIPT_PATH=$(readlink -en -- "$0")
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

1. Consult [CLAUDE.md](CLAUDE.md) for repository-specific guidance
2. All generated scripts must comply with BASH-CODING-STANDARD.md
3. Use the standard messaging functions consistently
4. Include proper error handling in all functions
5. Remove unused utility functions in production scripts (see Section 6: Production Script Optimization)

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

See [RESTRUCTURE-VALIDATION.md](RESTRUCTURE-VALIDATION.md) for complete validation details.

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
- Check CLAUDE.md for AI-specific guidance

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
