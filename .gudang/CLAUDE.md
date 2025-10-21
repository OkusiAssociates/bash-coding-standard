# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose
This is a Bash coding standard repository containing the organization's comprehensive Bash coding guidelines in `BASH-CODING-STANDARD.md`. All Bash scripts should strictly follow these standards.

## Bash Coding Standards (from BASH-CODING-STANDARD.md)
When writing or reviewing Bash scripts, follow the standards defined in BASH-CODING-STANDARD.md:

### Critical Requirements
- Target Bash 5.2+ exclusively
- Always use `#!/usr/bin/env bash` shebang
- Always include `set -euo pipefail` for strict error handling
- Use 2-space indentation (NOT tabs)
- End all scripts with `#fin` marker

### Standard Script Structure
1. Shebang and shellcheck directives
2. `set -euo pipefail`
3. Script metadata (VERSION, PRG0, PRG, PRGDIR)
4. Global variable declarations with proper types (`declare -i`, `declare -a`, etc.)
5. Color definitions (if terminal output)
6. Utility functions
7. Business logic functions
8. `main()` function
9. Script invocation: `main "$@"`
10. End marker: `#fin`

### Variable Declaration Requirements
- Always declare variables with proper types:
  - `declare -i` for integers
  - `declare -a` for indexed arrays
  - `declare -A` for associative arrays
  - `declare --` for strings
  - `readonly --` for constants
- Use `local` for function variables
- Global variables: UPPER_CASE or CamelCase
- Local variables: lower_case with underscores

### Key Patterns to Follow
- Use `[[` over `[` for conditionals
- Use `((arithmetic))` for numeric operations
- Always use `((var+=1))` instead of `((var++))` to avoid non-zero exit codes
- Quote all variables: `"$var"` not `$var`
- Use `$()` for command substitution, never backticks
- Implement standard utility functions: `_msg()`, `vecho()`, `success()`, `warn()`, `info()`, `error()`, `die()`

### Argument Parsing Pattern
```bash
while (($#)); do case "$1" in
  -v|--verbose)   VERBOSE+=1 ;;
  -q|--quiet)     VERBOSE=0 ;;
  -*)             die 22 "Invalid option '$1'" ;;
  *)              Paths+=("$1") ;;
esac; shift; done
```

## Development Commands
- Run shellcheck on scripts: `shellcheck -x <script.sh>`
- Validate against coding standard: Review against BASH-CODING-STANDARD.md requirements

## Important Notes
- The `.gudang` directory should be ignored (contains backups)
- When creating example scripts, ensure they demonstrate the coding standards
- All scripts must pass shellcheck validation