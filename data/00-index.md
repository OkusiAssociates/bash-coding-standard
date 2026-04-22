<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Bash Coding Standard (BCS)

**Concise, actionable coding rules for BCS Bash 5.2+**

Designed by Okusi Associates for the Indonesian Open Technology Foundation (YaTTI).
Target audience: both human programmers and AI assistants.

[BCS Bash 5.2 Reference](../docs/BCS-bash/index.md) -- the `bash(1)` man page rewritten for BCS assumptions (`set -euo pipefail`, `[[ ]]` only, no POSIX compat, etc).

[Example exemplar BCS-compliant scripts directory](../examples/)

Templates for new scripts: [complete.sh.template](../examples/templates/complete.sh.template), [basic.sh.template](../examples/templates/basic.sh.template), [minimal.sh.template](../examples/templates/minimal.sh.template), [library.sh.template](../examples/templates/library.sh.template)

[Codebase examples](../examples/lib/index.md)

## Coding Principles
- K.I.S.S.
- "The best process is no process"
- "Everything should be made as simple as possible, but not any simpler."
- **Critical:** Do not over-engineer scripts; **remove unused functions and variables**

## Contents
01. Script Structure & Layout
02. Variables & Data Types
03. Strings & Quoting
04. Functions & Libraries
05. Control Flow
06. Error Handling
07. I/O & Messaging
08. Command-Line Arguments
09. File Operations
10. Security
11. Concurrency & Jobs
12. Style & Development
