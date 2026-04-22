<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
# Bash 5.2 Reference (Strict Mode)

This reference documents Bash 5.2 under the following standing assumptions:

- Scripts always begin with a bash shebang (`#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash`)
- Strict mode is always active: `set -euo pipefail` with `shopt -s inherit_errexit`
- All variables are explicitly declared with types (`declare -i`, `declare --`, `declare -a`, `declare -A`)

Content specific to POSIX sh compatibility, `[ ]` test syntax, backtick command substitution, and shell compatibility modes has been removed. See `bash5.2/` for the unfiltered reference.

---

- [01 NAME](01_NAME.md)
- [02 SYNOPSIS](02_SYNOPSIS.md)
- [03 DESCRIPTION](03_DESCRIPTION.md)
- [04 OPTIONS](04_OPTIONS.md)
- [05 ARGUMENTS](05_ARGUMENTS.md)
- [06 INVOCATION](06_INVOCATION.md)
- [07 DEFINITIONS](07_DEFINITIONS.md)
- [08 RESERVED WORDS](08_RESERVED-WORDS.md)
- [09 SHELL GRAMMAR](09_SHELL-GRAMMAR/index.md)
- [10 COMMENTS](10_COMMENTS.md)
- [11 QUOTING](11_QUOTING.md)
- [12 PARAMETERS](12_PARAMETERS/index.md)
- [13 EXPANSION](13_EXPANSION/index.md)
- [14 REDIRECTION](14_REDIRECTION/index.md)
- [15 ALIASES](15_ALIASES.md)
- [16 FUNCTIONS](16_FUNCTIONS.md)
- [17 ARITHMETIC EVALUATION](17_ARITHMETIC-EVALUATION.md)
- [18 CONDITIONAL EXPRESSIONS](18_CONDITIONAL-EXPRESSIONS.md)
- [19 SIMPLE COMMAND EXPANSION](19_SIMPLE-COMMAND-EXPANSION.md)
- [20 COMMAND EXECUTION](20_COMMAND-EXECUTION.md)
- [21 COMMAND EXECUTION ENVIRONMENT](21_COMMAND-EXECUTION-ENVIRONMENT.md)
- [22 ENVIRONMENT](22_ENVIRONMENT.md)
- [23 EXIT STATUS](23_EXIT-STATUS.md)
- [24 SIGNALS](24_SIGNALS.md)
- [25 JOB CONTROL](25_JOB-CONTROL.md)
- [26 PROMPTING](26_PROMPTING.md)
- [27 READLINE](27_READLINE/index.md)
- [28 HISTORY](28_HISTORY.md)
- [29 HISTORY EXPANSION](29_HISTORY-EXPANSION/index.md)
- [30 SHELL BUILTIN COMMANDS](30_SHELL-BUILTIN-COMMANDS/index.md)
- [31 RESTRICTED SHELL](31_RESTRICTED-SHELL.md)
- [32 FILES](32_FILES.md)
