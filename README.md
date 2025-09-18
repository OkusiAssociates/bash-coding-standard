# Bash Coding Standard

A comprehensive coding standard for modern Bash 5.2+ scripts, designed for consistency, robustness, and maintainability.

Bash is a battle-tested, sophisticated programming language deployed on virtually every Unix-like system on Earth - from supercomputers to smartphones, from cloud servers to embedded devices. Despite persistent misconceptions that it's merely "glue code" or unsuitable for serious development, Bash possesses powerful constructs for complex data structures, robust error handling, and elegant control flow. When wielded with discipline and proper engineering principles - rather than as ad-hoc command sequences - Bash delivers production-grade solutions for system automation, data processing, and infrastructure orchestration. This standard codifies that discipline, transforming Bash from a loose scripting tool into a reliable programming platform.

## Overview

This repository contains the canonical Bash coding standards developed by [Okusi Associates](https://okusi.id) and adopted by the [Indonesian Open Technology Foundation (YaTTI)](https://github.com/Open-Technology-Foundation). These standards define precise patterns for writing production-grade Bash scripts that are both human-readable and machine-parseable.

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

## Usage

All Bash scripts in Okusi and YaTTI projects must comply with these standards. The structured approach enables:

- Automated code review and validation
- Consistent refactoring across large codebases
- Reliable script generation from templates
- Effective collaboration between human developers and AI coding assistants

## Documentation

- **[BASH-CODING-STYLE.md](BASH-CODING-STYLE.md)** - The complete coding standard

## Related Resources

- [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html) - Industry reference standard
- [ShellCheck](https://www.shellcheck.net/) - Required static analysis tool


## Validation

```bash
# All scripts must pass ShellCheck
shellcheck -x script.sh
```

## Example Structure

```bash
#!/usr/bin/env bash
#shellcheck disable=SC1090,SC1091
# Process and validate configuration files
set -euo pipefail

VERSION='1.0.0'
PRG0=$(readlink -en -- "$0")
PRG=${PRG0##*/}
PRGDIR=${PRG0%/*}
readonly -- VERSION PRG0 PRG PRGDIR

# Global variables
declare -i VERBOSE=1 DEBUG=0
declare -a Paths=()

# Colours
[[ -t 2 ]] && declare -- RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' NC=$'\033[0m' || declare -- RED='' GREEN='' YELLOW='' NC=''
readonly -- RED GREEN YELLOW NC

# Standard utility functions
# Core message function using FUNCNAME for context
_msg() {
  local -- status="${FUNCNAME[1]}" prefix="$PRG:" msg
  case "$status" in
    success) prefix+=" ${GREEN}✓${NC}" ;;
    warn)    prefix+=" ${YELLOW}⚡${NC}" ;;
    info)    prefix+=" ${CYAN}◉${NC}" ;;
    error)   prefix+=" ${RED}✗${NC}" ;;
    debug)   prefix+=" ${WARN}DEBUG${NC}:" ;;
    *)       ;;
  esac
  for msg in "$@"; do printf '%s %s\n' "$prefix" "$msg"; done
}
# Conditional output based on verbosity
vecho() { ((VERBOSE)) || return 0; _msg "$@"; }
success() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
warn() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
info() { ((VERBOSE)) || return 0; >&2 _msg "$@"; }
debug() { ((DEBUG)) || return 0; >&2 _msg "$@"; }
# Unconditional output
error() { >&2 _msg "$@"; }
die() { (($# > 1)) && error "${@:2}"; exit "${1:-0}"; }

s() { (( ${1:-1} == 1 )) || echo -n 's'; }

noarg() {
  if (($# < 2)) || [[ ${2:0:1} == '-' ]]; then
    die 2 "Missing argument for option '$1'"
  fi
  return 0
}

usage() {
  cat <<EOT
$PRG $VERSION - Process configuration files

Usage: $PRG [OPTIONS] [FILES...]

Options:
  -v|--verbose     Enable verbose output
  -q|--quiet       Suppress output
  -h|--help        Show this help message

Examples:
  $PRG config.txt
  $PRG -v *.conf
EOT
  exit "${1:-0}"
}

# Business logic functions
process_file() {
  local -- file="$1"
  [[ -r "$file" ]] || die 1 "Cannot read file: $file"
  vecho "Processing: $file"
  # Process file here
}

main() {
  local -- output=''
  local -i exitcode=0

  # Argument processing
  while (($#)); do case "$1" in
    -o|--output)    noarg "$@"; shift; output="$1" ;;
    -v|--verbose)   VERBOSE+=1 ;;
    -q|--quiet)     VERBOSE=0 ;;
    -h|--help)      usage 0 ;;
    -V|--version)   echo "$PRG $VERSION"; exit 0 ;;
    -[ovqhV]*) #shellcheck disable=SC2046 #split up single options
                    set -- '' $(printf -- "-%c " $(grep -o . <<<"${1:1}")) "${@:2}" ;;
    -*)             die 22 "Invalid option '$1'" ;;
    *)              Paths+=("$1") ;;
  esac; shift; done

  # Validate inputs
  ((${#Paths[@]})) || die 1 "No files specified"

  # Process files
  local -- path
  for path in "${Paths[@]}"; do
    process_file "$path" || exitcode=1
  done

  success "Processed ${#Paths[@]} file$(s ${#Paths[@]})"
  return "$exitcode"
}

main "$@"
#fin
```

## Contributing

This standard evolves through practical application in production systems. Proposed changes should demonstrate clear benefits for code reliability, maintainability, or automation capabilities.

## License

This work is licensed under [Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)](https://creativecommons.org/licenses/by-sa/4.0/).

You are free to:
- Share and redistribute the material
- Adapt and build upon the material

Under the following terms:
- Attribution to Okusi Associates and YaTTI
- ShareAlike - Distribute contributions under the same license

## Acknowledgments

Developed by Okusi Associates for enterprise Bash scripting. Incorporates compatible elements from Google's Shell Style Guide and industry best practices.

## Authors

Gary Dean, Okusi Associates

---
*For production systems requiring consistent, maintainable, and secure Bash scripting.*
