<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# BCS Advanced Bash Reference

**A comprehensive, lookup-oriented reference for modern Bash on Linux.**

Designed by Okusi Associates for the Indonesian Open Technology Foundation (YaTTI).
Target audience: working engineers, library authors, reviewers, and AI assistants.

Strict-mode assumptions throughout. Bottom-up structure: from the Unix model Bash sits on, through the language itself, through engineering discipline, to internals — closing on Bash 5.3 and beyond.

## Companion documents

[Bash Coding Standard (BCS)](../../data/BASH-CODING-STANDARD.md) — ~100 actionable rules for BCS-compliant Bash 5.2+ scripts.

[BCS-bash](../BCS-bash/index.md) — the `bash(1)` man page rewritten under strict-mode assumptions (`set -euo pipefail`, `[[ ]]` only, no POSIX compat).

[Examples directory](../../examples/) — exemplar BCS-compliant scripts.

[Templates](../../examples/templates/) — `complete`, `basic`, `minimal`, `library` script scaffolds.

---

## About this reference

This is a **structural reference guide** for advanced Bash users. It assumes Bash 5.2 or newer on Ubuntu 24.04 (or comparable Linux), strict-mode operation (`set -euo pipefail` with `shopt -s inherit_errexit`), and that the reader can already write at least basic shell.

It is organised bottom-up: the Unix model first (because Bash is a thin language over Unix primitives), then Bash as a program, then the language proper (lexical structure, parameters, expansions, redirection, control flow), then the engineering layer (functions, libraries, process management, signals, errors, I/O, CLI, concurrency, IPC), then the interactive layer (readline), then performance, security, tooling, idioms, portability, and internals — closing on Bash 5.3 and beyond.

### Who this is for

- Working engineers who write Bash regularly and need a single authoritative lookup.
- Library and tool authors who must understand semantics precisely, not approximately.
- Reviewers and standards authors who need cross-references between code, the BCS coding standard, and the Bash 5.2 man page.

### What this is *not*

- Not a coding standard. See [`../data/BASH-CODING-STANDARD.md`](../../data/BASH-CODING-STANDARD.md) for ~100 actionable rules.
- Not a re-statement of the bash(1) man page. See [`BCS-bash/`](../BCS-bash/) for a strict-mode-rewritten man-page reference. This document is *organised pedagogically* and routinely cross-references both BCS and BCS-bash.

### Conventions

- **Section numbering.** `Part N → Chapter N.M → Section N.M.K`. Cross-references use §N.M.K. Anchors follow the heading text.
- **Cross-references.** *BCS hook* → coding-standard section. *BCS-bash* → strict-mode man-page file. *Greg* → Greg Wooledge's wiki at `mywiki.wooledge.org`. *Manual* → GNU Bash Reference Manual.
- **Strict mode is assumed.** Every example, every recommendation. POSIX `sh` deviations are called out explicitly when relevant; otherwise not mentioned.
- **British English** throughout, matching BCS docs.
- **Briefing notes** under each heading describe the intended content of that section. Sub-bullets list the specific topics to cover. This document is the *structural skeleton* of the reference; full content lives in (or will live in) the chapter bodies.

### How to use this document

For lookup, use the Table of Contents. Each chapter is self-contained — you should never need to read prior chapters to understand a later one, though forward references are flagged. For systematic study, read top-to-bottom; the ordering is bottom-up by design.

## Table of Contents

### [Part I — The Unix Model from Bash](01_The-Unix-Model-from-Bash/index.md)

- [1.1 Processes — fork, exec, wait](01_The-Unix-Model-from-Bash/01_Processes-fork-exec-wait.md)
- [1.2 The file descriptor model](01_The-Unix-Model-from-Bash/02_The-file-descriptor-model.md)
- [1.3 Files, directories, and special files](01_The-Unix-Model-from-Bash/03_Files-directories-and-special-files.md)
- [1.4 Streams and the standard descriptors](01_The-Unix-Model-from-Bash/04_Streams-and-the-standard-descriptors.md)
- [1.5 The shell environment](01_The-Unix-Model-from-Bash/05_The-shell-environment.md)
- [1.6 Users, groups, permissions](01_The-Unix-Model-from-Bash/06_Users-groups-permissions.md)
- [1.7 Exit status and process termination](01_The-Unix-Model-from-Bash/07_Exit-status-and-process-termination.md)
- [1.8 Signals — overview](01_The-Unix-Model-from-Bash/08_Signals-overview.md)
- [1.9 The controlling terminal and TTY layer](01_The-Unix-Model-from-Bash/09_The-controlling-terminal-and-TTY-layer.md)

### [Part II — Bash as a Program](02_Bash-as-a-Program/index.md)

- [2.1 Genealogy and the shell family](02_Bash-as-a-Program/01_Genealogy-and-the-shell-family.md)
- [2.2 Bash version landscape](02_Bash-as-a-Program/02_Bash-version-landscape.md)
- [2.3 Build configuration and feature detection](02_Bash-as-a-Program/03_Build-configuration-and-feature-detection.md)
- [2.4 Invocation modes](02_Bash-as-a-Program/04_Invocation-modes.md)
- [2.5 Startup file chains](02_Bash-as-a-Program/05_Startup-file-chains.md)
- [2.6 `BASH_ENV` and `ENV`](02_Bash-as-a-Program/06_BASH_ENV-and-ENV.md)
- [2.7 Command-line options to bash itself](02_Bash-as-a-Program/07_Command-line-options-to-bash-itself.md)
- [2.8 Exit and shell session lifecycle](02_Bash-as-a-Program/08_Exit-and-shell-session-lifecycle.md)

### [Part III — Lexical Structure and Shell Grammar](03_Lexical-Structure-and-Shell-Grammar/index.md)

- [3.1 Tokenisation](03_Lexical-Structure-and-Shell-Grammar/01_Tokenisation.md)
- [3.2 Reserved words](03_Lexical-Structure-and-Shell-Grammar/02_Reserved-words.md)
- [3.3 Comments](03_Lexical-Structure-and-Shell-Grammar/03_Comments.md)
- [3.4 Quoting overview](03_Lexical-Structure-and-Shell-Grammar/04_Quoting-overview.md)
- [3.5 Single quotes](03_Lexical-Structure-and-Shell-Grammar/05_Single-quotes.md)
- [3.6 Double quotes](03_Lexical-Structure-and-Shell-Grammar/06_Double-quotes.md)
- [3.7 ANSI-C quoting `$'...'`](03_Lexical-Structure-and-Shell-Grammar/07_ANSI-C-quoting.md)
- [3.8 Locale-translation `$"..."`](03_Lexical-Structure-and-Shell-Grammar/08_Locale-translation.md)
- [3.9 Backslash escapes](03_Lexical-Structure-and-Shell-Grammar/09_Backslash-escapes.md)
- [3.10 Shell grammar](03_Lexical-Structure-and-Shell-Grammar/10_Shell-grammar.md)
- [3.11 Operator precedence](03_Lexical-Structure-and-Shell-Grammar/11_Operator-precedence.md)

### [Part IV — Parameters, Variables, and Arrays](04_Parameters-Variables-and-Arrays/index.md)

- [4.1 Parameter taxonomy](04_Parameters-Variables-and-Arrays/01_Parameter-taxonomy.md)
- [4.2 Positional parameters](04_Parameters-Variables-and-Arrays/02_Positional-parameters.md)
- [4.3 Special parameters](04_Parameters-Variables-and-Arrays/03_Special-parameters.md)
- [4.4 Shell variables](04_Parameters-Variables-and-Arrays/04_Shell-variables.md)
- [4.5 The `declare` builtin and attributes](04_Parameters-Variables-and-Arrays/05_The-declare-builtin-and-attributes.md)
- [4.6 `local` and dynamic scope](04_Parameters-Variables-and-Arrays/06_local-and-dynamic-scope.md)
- [4.7 `readonly` and immutability](04_Parameters-Variables-and-Arrays/07_readonly-and-immutability.md)
- [4.8 `export` and the environment](04_Parameters-Variables-and-Arrays/08_export-and-the-environment.md)
- [4.9 Indexed arrays](04_Parameters-Variables-and-Arrays/09_Indexed-arrays.md)
- [4.10 Associative arrays](04_Parameters-Variables-and-Arrays/10_Associative-arrays.md)
- [4.11 Namerefs (`-n`)](04_Parameters-Variables-and-Arrays/11_Namerefs-n.md)
- [4.12 Integer arithmetic semantics](04_Parameters-Variables-and-Arrays/12_Integer-arithmetic-semantics.md)
- [4.13 Variable assignment semantics](04_Parameters-Variables-and-Arrays/13_Variable-assignment-semantics.md)
- [4.14 Unsetting](04_Parameters-Variables-and-Arrays/14_Unsetting.md)

### [Part V — Expansions](05_Expansions/index.md)

- [5.1 Order of expansions](05_Expansions/01_Order-of-expansions.md)
- [5.2 Brace expansion](05_Expansions/02_Brace-expansion.md)
- [5.3 Tilde expansion](05_Expansions/03_Tilde-expansion.md)
- [5.4 Parameter and variable expansion](05_Expansions/04_Parameter-and-variable-expansion.md)
- [5.5 Arithmetic expansion](05_Expansions/05_Arithmetic-expansion.md)
- [5.6 Command substitution](05_Expansions/06_Command-substitution.md)
- [5.7 Process substitution](05_Expansions/07_Process-substitution.md)
- [5.8 Word splitting and IFS](05_Expansions/08_Word-splitting-and-IFS.md)
- [5.9 Pathname expansion (globbing)](05_Expansions/09_Pathname-expansion-globbing.md)
- [5.10 Quote removal](05_Expansions/10_Quote-removal.md)
- [5.11 Glob options](05_Expansions/11_Glob-options.md)
- [5.12 Extended globs (extglob)](05_Expansions/12_Extended-globs-extglob.md)
- [5.13 Locale and pattern matching](05_Expansions/13_Locale-and-pattern-matching.md)

### [Part VI — Redirection and Pipelines](06_Redirection-and-Pipelines/index.md)

- [6.1 The fd table from Bash's perspective](06_Redirection-and-Pipelines/01_The-fd-table-from-Bashs-perspective.md)
- [6.2 Input redirection](06_Redirection-and-Pipelines/02_Input-redirection.md)
- [6.3 Output redirection](06_Redirection-and-Pipelines/03_Output-redirection.md)
- [6.4 Stderr redirection and merging](06_Redirection-and-Pipelines/04_Stderr-redirection-and-merging.md)
- [6.5 Reading-and-writing](06_Redirection-and-Pipelines/05_Reading-and-writing.md)
- [6.6 Duplicating fds](06_Redirection-and-Pipelines/06_Duplicating-fds.md)
- [6.7 Moving and closing fds](06_Redirection-and-Pipelines/07_Moving-and-closing-fds.md)
- [6.8 Here-documents](06_Redirection-and-Pipelines/08_Here-documents.md)
- [6.9 Here-strings](06_Redirection-and-Pipelines/09_Here-strings.md)
- [6.10 Process substitution as redirection](06_Redirection-and-Pipelines/10_Process-substitution-as-redirection.md)
- [6.11 Order of evaluation](06_Redirection-and-Pipelines/11_Order-of-evaluation.md)
- [6.12 `exec` for fd manipulation](06_Redirection-and-Pipelines/12_exec-for-fd-manipulation.md)
- [6.13 Pipelines](06_Redirection-and-Pipelines/13_Pipelines.md)
- [6.14 Stderr pipelines (`|&`)](06_Redirection-and-Pipelines/14_Stderr-pipelines.md)
- [6.15 `pipefail` semantics](06_Redirection-and-Pipelines/15_pipefail-semantics.md)
- [6.16 `lastpipe` semantics](06_Redirection-and-Pipelines/16_lastpipe-semantics.md)

### [Part VII — Control Flow and Compound Commands](07_Control-Flow-and-Compound-Commands/index.md)

- [7.1 Compound command overview](07_Control-Flow-and-Compound-Commands/01_Compound-command-overview.md)
- [7.2 `if`/`elif`/`else`/`fi`](07_Control-Flow-and-Compound-Commands/02_ifelifelsefi.md)
- [7.3 `case`/`esac`](07_Control-Flow-and-Compound-Commands/03_caseesac.md)
- [7.4 `for x in list`](07_Control-Flow-and-Compound-Commands/04_for-x-in-list.md)
- [7.5 C-style `for ((;;))`](07_Control-Flow-and-Compound-Commands/05_C-style-for.md)
- [7.6 `while`/`until`](07_Control-Flow-and-Compound-Commands/06_whileuntil.md)
- [7.7 `select`](07_Control-Flow-and-Compound-Commands/07_select.md)
- [7.8 Subshell grouping `( )`](07_Control-Flow-and-Compound-Commands/08_Subshell-grouping.md)
- [7.9 Brace grouping `{ }`](07_Control-Flow-and-Compound-Commands/09_Brace-grouping.md)
- [7.10 `&&` and `||` short-circuits](07_Control-Flow-and-Compound-Commands/10_and-short-circuits.md)
- [7.11 `break` and `continue`](07_Control-Flow-and-Compound-Commands/11_break-and-continue.md)
- [7.12 `return`](07_Control-Flow-and-Compound-Commands/12_return.md)
- [7.13 `exit`](07_Control-Flow-and-Compound-Commands/13_exit.md)
- [7.14 `:`, `true`, `false`](07_Control-Flow-and-Compound-Commands/14_true-false.md)

### [Part VIII — Conditional Expressions and Arithmetic](08_Conditional-Expressions-and-Arithmetic/index.md)

- [8.1 `[[ ]]` overview](08_Conditional-Expressions-and-Arithmetic/01_overview.md)
- [8.2 File test operators](08_Conditional-Expressions-and-Arithmetic/02_File-test-operators.md)
- [8.3 File comparison operators](08_Conditional-Expressions-and-Arithmetic/03_File-comparison-operators.md)
- [8.4 String operators](08_Conditional-Expressions-and-Arithmetic/04_String-operators.md)
- [8.5 Pattern matching with `==`](08_Conditional-Expressions-and-Arithmetic/05_Pattern-matching-with.md)
- [8.6 Regex matching with `=~`](08_Conditional-Expressions-and-Arithmetic/06_Regex-matching-with.md)
- [8.7 Logical operators and grouping](08_Conditional-Expressions-and-Arithmetic/07_Logical-operators-and-grouping.md)
- [8.8 Quoting rules inside `[[ ]]`](08_Conditional-Expressions-and-Arithmetic/08_Quoting-rules-inside.md)
- [8.9 Arithmetic context `(( ))`](08_Conditional-Expressions-and-Arithmetic/09_Arithmetic-context.md)
- [8.10 Arithmetic operators and precedence](08_Conditional-Expressions-and-Arithmetic/10_Arithmetic-operators-and-precedence.md)
- [8.11 Integer types, overflow, base prefixes](08_Conditional-Expressions-and-Arithmetic/11_Integer-types-overflow-base-prefixes.md)
- [8.12 Floating-point — workarounds](08_Conditional-Expressions-and-Arithmetic/12_Floating-point-workarounds.md)
- [8.13 `let` builtin](08_Conditional-Expressions-and-Arithmetic/13_let-builtin.md)
- [8.14 The deprecated `[ ]` and `test`](08_Conditional-Expressions-and-Arithmetic/14_The-deprecated-and-test.md)

### [Part IX — Functions](09_Functions/index.md)

- [9.1 Definition syntax](09_Functions/01_Definition-syntax.md)
- [9.2 Argument passing](09_Functions/02_Argument-passing.md)
- [9.3 `local` and scope](09_Functions/03_local-and-scope.md)
- [9.4 Return value via `return N`](09_Functions/04_Return-value-via-return-N.md)
- [9.5 Communicating results](09_Functions/05_Communicating-results.md)
- [9.6 Recursion and `FUNCNEST`](09_Functions/06_Recursion-and-FUNCNEST.md)
- [9.7 Function tracing](09_Functions/07_Function-tracing.md)
- [9.8 Listing and inspecting functions](09_Functions/08_Listing-and-inspecting-functions.md)
- [9.9 Exporting functions](09_Functions/09_Exporting-functions.md)
- [9.10 Naming conventions](09_Functions/10_Naming-conventions.md)
- [9.11 Self-locating with `BASH_SOURCE`](09_Functions/11_Self-locating-with-BASH_SOURCE.md)
- [9.12 Calling-convention discipline](09_Functions/12_Calling-convention-discipline.md)

### [Part X — Sourcing, Libraries, and Modules](10_Sourcing-Libraries-and-Modules/index.md)

- [10.1 `source` semantics](10_Sourcing-Libraries-and-Modules/01_source-semantics.md)
- [10.2 The `BASH_SOURCE` array](10_Sourcing-Libraries-and-Modules/02_The-BASH_SOURCE-array.md)
- [10.3 Self-locating library pattern](10_Sourcing-Libraries-and-Modules/03_Self-locating-library-pattern.md)
- [10.4 Idempotent sourcing guards](10_Sourcing-Libraries-and-Modules/04_Idempotent-sourcing-guards.md)
- [10.5 Namespace prefixes](10_Sourcing-Libraries-and-Modules/05_Namespace-prefixes.md)
- [10.6 Public vs private conventions](10_Sourcing-Libraries-and-Modules/06_Public-vs-private-conventions.md)
- [10.7 Version negotiation](10_Sourcing-Libraries-and-Modules/07_Version-negotiation.md)
- [10.8 Lazy and conditional loading](10_Sourcing-Libraries-and-Modules/08_Lazy-and-conditional-loading.md)
- [10.9 Cross-shell sourcing pitfalls](10_Sourcing-Libraries-and-Modules/09_Cross-shell-sourcing-pitfalls.md)
- [10.10 API design](10_Sourcing-Libraries-and-Modules/10_API-design.md)
- [10.11 Distribution and installation](10_Sourcing-Libraries-and-Modules/11_Distribution-and-installation.md)

### [Part XI — Process Management](11_Process-Management/index.md)

- [11.1 The Bash process tree at runtime](11_Process-Management/01_The-Bash-process-tree-at-runtime.md)
- [11.2 PIDs: `$$`, `$BASHPID`, `$PPID`](11_Process-Management/02_PIDs-BASHPID-PPID.md)
- [11.3 Subshell origins](11_Process-Management/03_Subshell-origins.md)
- [11.4 `BASH_SUBSHELL` depth tracking](11_Process-Management/04_BASH_SUBSHELL-depth-tracking.md)
- [11.5 Foreground vs background](11_Process-Management/05_Foreground-vs-background.md)
- [11.6 Process groups and sessions](11_Process-Management/06_Process-groups-and-sessions.md)
- [11.7 The job table](11_Process-Management/07_The-job-table.md)
- [11.8 Job specifications](11_Process-Management/08_Job-specifications.md)
- [11.9 Job-control builtins](11_Process-Management/09_Job-control-builtins.md)
- [11.10 `kill` and signal delivery](11_Process-Management/10_kill-and-signal-delivery.md)
- [11.11 `nohup` and `setsid`](11_Process-Management/11_nohup-and-setsid.md)
- [11.12 Detaching from the terminal](11_Process-Management/12_Detaching-from-the-terminal.md)
- [11.13 Environment inheritance](11_Process-Management/13_Environment-inheritance.md)

### [Part XII — Signals and Traps](12_Signals-and-Traps/index.md)

- [12.1 Signal taxonomy](12_Signals-and-Traps/01_Signal-taxonomy.md)
- [12.2 Signal numbers and names](12_Signals-and-Traps/02_Signal-numbers-and-names.md)
- [12.3 Uncatchable signals](12_Signals-and-Traps/03_Uncatchable-signals.md)
- [12.4 Signal disposition](12_Signals-and-Traps/04_Signal-disposition.md)
- [12.5 The `trap` builtin](12_Signals-and-Traps/05_The-trap-builtin.md)
- [12.6 Pseudo-signals: EXIT, ERR, DEBUG, RETURN](12_Signals-and-Traps/06_Pseudo-signals-EXIT-ERR-DEBUG-RETURN.md)
- [12.7 `trap -p` and trap inspection](12_Signals-and-Traps/07_trap-p-and-trap-inspection.md)
- [12.8 Trap inheritance](12_Signals-and-Traps/08_Trap-inheritance.md)
- [12.9 Trap reset across `exec`](12_Signals-and-Traps/09_Trap-reset-across-exec.md)
- [12.10 Synchronous vs asynchronous delivery](12_Signals-and-Traps/10_Synchronous-vs-asynchronous-delivery.md)
- [12.11 Signal-safe code](12_Signals-and-Traps/11_Signal-safe-code.md)
- [12.12 Idempotent cleanup patterns](12_Signals-and-Traps/12_Idempotent-cleanup-patterns.md)
- [12.13 Tempfile and tempdir lifecycle](12_Signals-and-Traps/13_Tempfile-and-tempdir-lifecycle.md)
- [12.14 Lockfile pattern](12_Signals-and-Traps/14_Lockfile-pattern.md)
- [12.15 Atomic file write](12_Signals-and-Traps/15_Atomic-file-write.md)
- [12.16 Reload-on-SIGHUP](12_Signals-and-Traps/16_Reload-on-SIGHUP.md)

### [Part XIII — Error Handling and Exit Status](13_Error-Handling-and-Exit-Status/index.md)

- [13.1 Exit status fundamentals](13_Error-Handling-and-Exit-Status/01_Exit-status-fundamentals.md)
- [13.2 `set -e` (errexit) — full semantics](13_Error-Handling-and-Exit-Status/02_set-e-errexit-full-semantics.md)
- [13.3 The errexit exemption matrix](13_Error-Handling-and-Exit-Status/03_The-errexit-exemption-matrix.md)
- [13.4 `set -u` (nounset)](13_Error-Handling-and-Exit-Status/04_set-u-nounset.md)
- [13.5 `set -o pipefail`](13_Error-Handling-and-Exit-Status/05_set-o-pipefail.md)
- [13.6 `inherit_errexit`](13_Error-Handling-and-Exit-Status/06_inherit_errexit.md)
- [13.7 `||:` and `|| true` idioms](13_Error-Handling-and-Exit-Status/07_and-true-idioms.md)
- [13.8 The `ERR` trap](13_Error-Handling-and-Exit-Status/08_The-ERR-trap.md)
- [13.9 `errtrace` and trap inheritance](13_Error-Handling-and-Exit-Status/09_errtrace-and-trap-inheritance.md)
- [13.10 Exit code conventions](13_Error-Handling-and-Exit-Status/10_Exit-code-conventions.md)
- [13.11 Propagating exit codes](13_Error-Handling-and-Exit-Status/11_Propagating-exit-codes.md)
- [13.12 Rich error output](13_Error-Handling-and-Exit-Status/12_Rich-error-output.md)

### [Part XIV — Input, Output, and Messaging](14_Input-Output-and-Messaging/index.md)

- [14.1 Standard streams discipline](14_Input-Output-and-Messaging/01_Standard-streams-discipline.md)
- [14.2 The `read` builtin](14_Input-Output-and-Messaging/02_The-read-builtin.md)
- [14.3 `mapfile` / `readarray`](14_Input-Output-and-Messaging/03_mapfile-readarray.md)
- [14.4 The `printf` builtin](14_Input-Output-and-Messaging/04_The-printf-builtin.md)
- [14.5 `printf` vs `echo`](14_Input-Output-and-Messaging/05_printf-vs-echo.md)
- [14.6 Format specifiers](14_Input-Output-and-Messaging/06_Format-specifiers.md)
- [14.7 Logging discipline](14_Input-Output-and-Messaging/07_Logging-discipline.md)
- [14.8 Log levels](14_Input-Output-and-Messaging/08_Log-levels.md)
- [14.9 Coloured output and TERM detection](14_Input-Output-and-Messaging/09_Coloured-output-and-TERM-detection.md)
- [14.10 Progress indicators](14_Input-Output-and-Messaging/10_Progress-indicators.md)
- [14.11 Reading binary data](14_Input-Output-and-Messaging/11_Reading-binary-data.md)
- [14.12 File locking for concurrent writes](14_Input-Output-and-Messaging/12_File-locking-for-concurrent-writes.md)

### [Part XV — Command-Line Processing](15_Command-Line-Processing/index.md)

- [15.1 CLI conventions](15_Command-Line-Processing/01_CLI-conventions.md)
- [15.2 `getopts` builtin](15_Command-Line-Processing/02_getopts-builtin.md)
- [15.3 GNU `getopt(1)` external](15_Command-Line-Processing/03_GNU-getopt1-external.md)
- [15.4 Hand-rolled `while case shift`](15_Command-Line-Processing/04_Hand-rolled-while-case-shift.md)
- [15.5 Long options](15_Command-Line-Processing/05_Long-options.md)
- [15.6 Bundled short options](15_Command-Line-Processing/06_Bundled-short-options.md)
- [15.7 `--` end-of-options](15_Command-Line-Processing/07_end-of-options.md)
- [15.8 Subcommand dispatch](15_Command-Line-Processing/08_Subcommand-dispatch.md)
- [15.9 Help text conventions](15_Command-Line-Processing/09_Help-text-conventions.md)
- [15.10 Synopsis grammar](15_Command-Line-Processing/10_Synopsis-grammar.md)
- [15.11 Auto-generating usage](15_Command-Line-Processing/11_Auto-generating-usage.md)

### [Part XVI — Concurrency and Parallelism](16_Concurrency-and-Parallelism/index.md)

- [16.1 Sequential vs background execution](16_Concurrency-and-Parallelism/01_Sequential-vs-background-execution.md)
- [16.2 `wait` and `wait -n`](16_Concurrency-and-Parallelism/02_wait-and-wait-n.md)
- [16.3 `wait $pid` for specific child](16_Concurrency-and-Parallelism/03_wait-pid-for-specific-child.md)
- [16.4 Capturing per-child exit status](16_Concurrency-and-Parallelism/04_Capturing-per-child-exit-status.md)
- [16.5 Bounded-concurrency fan-out](16_Concurrency-and-Parallelism/05_Bounded-concurrency-fan-out.md)
- [16.6 The job table under concurrency](16_Concurrency-and-Parallelism/06_The-job-table-under-concurrency.md)
- [16.7 `xargs -P`](16_Concurrency-and-Parallelism/07_xargs-P.md)
- [16.8 GNU parallel](16_Concurrency-and-Parallelism/08_GNU-parallel.md)
- [16.9 Race conditions in shell](16_Concurrency-and-Parallelism/09_Race-conditions-in-shell.md)
- [16.10 Locking primitives](16_Concurrency-and-Parallelism/10_Locking-primitives.md)
- [16.11 Signal handling under concurrency](16_Concurrency-and-Parallelism/11_Signal-handling-under-concurrency.md)
- [16.12 Queue patterns](16_Concurrency-and-Parallelism/12_Queue-patterns.md)

### [Part XVII — Coprocesses and IPC](17_Coprocesses-and-IPC/index.md)

- [17.1 The `coproc` builtin](17_Coprocesses-and-IPC/01_The-coproc-builtin.md)
- [17.2 Bidirectional fd pairs](17_Coprocesses-and-IPC/02_Bidirectional-fd-pairs.md)
- [17.3 Multiple coprocesses](17_Coprocesses-and-IPC/03_Multiple-coprocesses.md)
- [17.4 Named pipes (FIFOs)](17_Coprocesses-and-IPC/04_Named-pipes-FIFOs.md)
- [17.5 Anonymous pipes](17_Coprocesses-and-IPC/05_Anonymous-pipes.md)
- [17.6 `/dev/tcp` and `/dev/udp`](17_Coprocesses-and-IPC/06_devtcp-and-devudp.md)
- [17.7 `/dev/shm` shared memory](17_Coprocesses-and-IPC/07_devshm-shared-memory.md)
- [17.8 External IPC tools](17_Coprocesses-and-IPC/08_External-IPC-tools.md)
- [17.9 Choosing the right primitive](17_Coprocesses-and-IPC/09_Choosing-the-right-primitive.md)

### [Part XVIII — Readline, History, and Completion](18_Readline-History-and-Completion/index.md)

- [18.1 Readline overview](18_Readline-History-and-Completion/01_Readline-overview.md)
- [18.2 Editing modes](18_Readline-History-and-Completion/02_Editing-modes.md)
- [18.3 Key bindings](18_Readline-History-and-Completion/03_Key-bindings.md)
- [18.4 Bindable functions](18_Readline-History-and-Completion/04_Bindable-functions.md)
- [18.5 History](18_Readline-History-and-Completion/05_History.md)
- [18.6 The `history` builtin](18_Readline-History-and-Completion/06_The-history-builtin.md)
- [18.7 History expansion](18_Readline-History-and-Completion/07_History-expansion.md)
- [18.8 Programmable completion](18_Readline-History-and-Completion/08_Programmable-completion.md)
- [18.9 Compspec actions](18_Readline-History-and-Completion/09_Compspec-actions.md)
- [18.10 `_init_completion`](18_Readline-History-and-Completion/10__init_completion.md)
- [18.11 Dynamic completion functions](18_Readline-History-and-Completion/11_Dynamic-completion-functions.md)
- [18.12 `COMPREPLY` and `COMP_*` variables](18_Readline-History-and-Completion/12_COMPREPLY-and-COMP_-variables.md)
- [18.13 Prompts](18_Readline-History-and-Completion/13_Prompts.md)
- [18.14 Prompt escapes](18_Readline-History-and-Completion/14_Prompt-escapes.md)
- [18.15 Coloured and multi-line prompts](18_Readline-History-and-Completion/15_Coloured-and-multi-line-prompts.md)
- [18.16 Terminal capability detection](18_Readline-History-and-Completion/16_Terminal-capability-detection.md)

### [Part XIX — Performance](19_Performance/index.md)

- [19.1 The Bash cost model](19_Performance/01_The-Bash-cost-model.md)
- [19.2 Profiling tools](19_Performance/02_Profiling-tools.md)
- [19.3 `time` builtin vs `time` external](19_Performance/03_time-builtin-vs-time-external.md)
- [19.4 `BASH_XTRACEFD`](19_Performance/04_BASH_XTRACEFD.md)
- [19.5 `PS4` instrumentation](19_Performance/05_PS4-instrumentation.md)
- [19.6 `EPOCHREALTIME` for sub-second timing](19_Performance/06_EPOCHREALTIME-for-sub-second-timing.md)
- [19.7 Common optimisations](19_Performance/07_Common-optimisations.md)
- [19.8 Parameter expansion vs external commands](19_Performance/08_Parameter-expansion-vs-external-commands.md)
- [19.9 Pipes vs redirection](19_Performance/09_Pipes-vs-redirection.md)
- [19.10 Builtins vs externals](19_Performance/10_Builtins-vs-externals.md)
- [19.11 Bash 5.3 no-fork command substitution](19_Performance/11_Bash-5.3-no-fork-command-substitution.md)
- [19.12 Memory considerations](19_Performance/12_Memory-considerations.md)
- [19.13 When Bash is the wrong tool](19_Performance/13_When-Bash-is-the-wrong-tool.md)

### [Part XX — Security](20_Security/index.md)

- [20.1 Threat model](20_Security/01_Threat-model.md)
- [20.2 PATH hardening](20_Security/02_PATH-hardening.md)
- [20.3 IFS reset](20_Security/03_IFS-reset.md)
- [20.4 `eval` avoidance](20_Security/04_eval-avoidance.md)
- [20.5 Command injection vectors](20_Security/05_Command-injection-vectors.md)
- [20.6 Input validation](20_Security/06_Input-validation.md)
- [20.7 Quoting under `set -u`](20_Security/07_Quoting-under-set-u.md)
- [20.8 SUID restrictions](20_Security/08_SUID-restrictions.md)
- [20.9 Secrets handling](20_Security/09_Secrets-handling.md)
- [20.10 `noclobber`](20_Security/10_noclobber.md)
- [20.11 Privilege drop](20_Security/11_Privilege-drop.md)
- [20.12 Sanitising filenames](20_Security/12_Sanitising-filenames.md)
- [20.13 Symlink races](20_Security/13_Symlink-races.md)
- [20.14 Restricted shell mode](20_Security/14_Restricted-shell-mode.md)

### [Part XXI — Static Analysis, Formatting, and Testing](21_Static-Analysis-Formatting-and-Testing/index.md)

- [21.1 ShellCheck warnings](21_Static-Analysis-Formatting-and-Testing/01_ShellCheck-warnings.md)
- [21.2 ShellCheck directives](21_Static-Analysis-Formatting-and-Testing/02_ShellCheck-directives.md)
- [21.3 Source-path management](21_Static-Analysis-Formatting-and-Testing/03_Source-path-management.md)
- [21.4 `shfmt`](21_Static-Analysis-Formatting-and-Testing/04_shfmt.md)
- [21.5 `bcscheck`](21_Static-Analysis-Formatting-and-Testing/05_bcscheck.md)
- [21.6 Pre-commit hooks](21_Static-Analysis-Formatting-and-Testing/06_Pre-commit-hooks.md)
- [21.7 CI integration](21_Static-Analysis-Formatting-and-Testing/07_CI-integration.md)
- [21.8 bats-core](21_Static-Analysis-Formatting-and-Testing/08_bats-core.md)
- [21.9 Bats setup and teardown](21_Static-Analysis-Formatting-and-Testing/09_Bats-setup-and-teardown.md)
- [21.10 Bats `run` and assertions](21_Static-Analysis-Formatting-and-Testing/10_Bats-run-and-assertions.md)
- [21.11 Mocking via PATH injection](21_Static-Analysis-Formatting-and-Testing/11_Mocking-via-PATH-injection.md)
- [21.12 shunit2](21_Static-Analysis-Formatting-and-Testing/12_shunit2.md)
- [21.13 Coverage with kcov](21_Static-Analysis-Formatting-and-Testing/13_Coverage-with-kcov.md)

### [Part XXII — Idioms, Patterns, and Anti-Patterns](22_Idioms-Patterns-and-Anti-Patterns/index.md)

- [22.1 The strict-mode preamble](22_Idioms-Patterns-and-Anti-Patterns/01_The-strict-mode-preamble.md)
- [22.2 Self-locating script directory](22_Idioms-Patterns-and-Anti-Patterns/02_Self-locating-script-directory.md)
- [22.3 Argument-parsing skeleton](22_Idioms-Patterns-and-Anti-Patterns/03_Argument-parsing-skeleton.md)
- [22.4 Default-value patterns](22_Idioms-Patterns-and-Anti-Patterns/04_Default-value-patterns.md)
- [22.5 Lazy initialisation](22_Idioms-Patterns-and-Anti-Patterns/05_Lazy-initialisation.md)
- [22.6 Memoisation](22_Idioms-Patterns-and-Anti-Patterns/06_Memoisation.md)
- [22.7 Iterating an associative array deterministically](22_Idioms-Patterns-and-Anti-Patterns/07_Iterating-an-associative-array-deterministically.md)
- [22.8 Building structured output](22_Idioms-Patterns-and-Anti-Patterns/08_Building-structured-output.md)
- [22.9 Reading config files safely](22_Idioms-Patterns-and-Anti-Patterns/09_Reading-config-files-safely.md)
- [22.10 Atomic file write](22_Idioms-Patterns-and-Anti-Patterns/10_Atomic-file-write.md)
- [22.11 Exclusive lock](22_Idioms-Patterns-and-Anti-Patterns/11_Exclusive-lock.md)
- [22.12 Bounded retry with exponential backoff](22_Idioms-Patterns-and-Anti-Patterns/12_Bounded-retry-with-exponential-backoff.md)
- [22.13 Tempdir lifecycle](22_Idioms-Patterns-and-Anti-Patterns/13_Tempdir-lifecycle.md)
- [22.14 Mock-friendly subprocess wrapper](22_Idioms-Patterns-and-Anti-Patterns/14_Mock-friendly-subprocess-wrapper.md)
- [22.15 Stack-trace error reporter](22_Idioms-Patterns-and-Anti-Patterns/15_Stack-trace-error-reporter.md)
- [22.16 Self-test mode (dual-purpose script)](22_Idioms-Patterns-and-Anti-Patterns/16_Self-test-mode-dual-purpose-script.md)
- [22.17 Anti-patterns catalogue](22_Idioms-Patterns-and-Anti-Patterns/17_Anti-patterns-catalogue.md)

### [Part XXIII — POSIX Conformance and Portability](23_POSIX-Conformance-and-Portability/index.md)

- [23.1 Bash vs POSIX sh](23_POSIX-Conformance-and-Portability/01_Bash-vs-POSIX-sh.md)
- [23.2 The bashisms list](23_POSIX-Conformance-and-Portability/02_The-bashisms-list.md)
- [23.3 Bash vs dash](23_POSIX-Conformance-and-Portability/03_Bash-vs-dash.md)
- [23.4 Bash vs ksh](23_POSIX-Conformance-and-Portability/04_Bash-vs-ksh.md)
- [23.5 Bash vs zsh](23_POSIX-Conformance-and-Portability/05_Bash-vs-zsh.md)
- [23.6 Bash 3.2 on macOS](23_POSIX-Conformance-and-Portability/06_Bash-3.2-on-macOS.md)
- [23.7 BSD `sh`](23_POSIX-Conformance-and-Portability/07_BSD-sh.md)
- [23.8 `--posix` mode](23_POSIX-Conformance-and-Portability/08_posix-mode.md)
- [23.9 `shopt` compatibility levels](23_POSIX-Conformance-and-Portability/09_shopt-compatibility-levels.md)
- [23.10 When to write portable sh](23_POSIX-Conformance-and-Portability/10_When-to-write-portable-sh.md)
- [23.11 Forward-compatibility hygiene](23_POSIX-Conformance-and-Portability/11_Forward-compatibility-hygiene.md)
- [23.12 Targeting multiple Bash versions](23_POSIX-Conformance-and-Portability/12_Targeting-multiple-Bash-versions.md)

### [Part XXIV — Bash Internals](24_Bash-Internals/index.md)

- [24.1 The execution pipeline](24_Bash-Internals/01_The-execution-pipeline.md)
- [24.2 The bison grammar](24_Bash-Internals/02_The-bison-grammar.md)
- [24.3 Variable storage](24_Bash-Internals/03_Variable-storage.md)
- [24.4 Function storage](24_Bash-Internals/04_Function-storage.md)
- [24.5 The job table](24_Bash-Internals/05_The-job-table.md)
- [24.6 The trap table](24_Bash-Internals/06_The-trap-table.md)
- [24.7 The execution environment](24_Bash-Internals/07_The-execution-environment.md)
- [24.8 Subshell forking](24_Bash-Internals/08_Subshell-forking.md)
- [24.9 Builtin loadables](24_Bash-Internals/09_Builtin-loadables.md)
- [24.10 Reading the bash source](24_Bash-Internals/10_Reading-the-bash-source.md)

### [Part XXV — Bash 5.3 and the Future](25_Bash-5.3-and-the-Future/index.md)

- [25.1 No-fork command substitution `${ cmd; }`](25_Bash-5.3-and-the-Future/01_No-fork-command-substitution-cmd.md)
- [25.2 Other Bash 5.3 additions](25_Bash-5.3-and-the-Future/02_Other-Bash-5.3-additions.md)
- [25.3 Release cadence](25_Bash-5.3-and-the-Future/03_Release-cadence.md)
- [25.4 Roadmap signals](25_Bash-5.3-and-the-Future/04_Roadmap-signals.md)
- [25.5 Forward-compatibility considerations](25_Bash-5.3-and-the-Future/05_Forward-compatibility-considerations.md)

### [Appendices](99_Appendices/index.md)

- [Appendix A — Builtin Reference (alphabetical)](99_Appendices/A_Builtin-Reference-alphabetical.md)
- [Appendix B — Special Parameters Reference](99_Appendices/B_Special-Parameters-Reference.md)
- [Appendix C — Shell Variables Reference](99_Appendices/C_Shell-Variables-Reference.md)
- [Appendix D — `set` Options Reference](99_Appendices/D_set-Options-Reference.md)
- [Appendix E — `shopt` Options Reference](99_Appendices/E_shopt-Options-Reference.md)
- [Appendix F — ANSI-C Escape Sequences](99_Appendices/F_ANSI-C-Escape-Sequences.md)
- [Appendix G — Glob and Extglob Patterns](99_Appendices/G_Glob-and-Extglob-Patterns.md)
- [Appendix H — Conditional Expression Operators](99_Appendices/H_Conditional-Expression-Operators.md)
- [Appendix I — Parameter Expansion Cheat Sheet](99_Appendices/I_Parameter-Expansion-Cheat-Sheet.md)
- [Appendix J — Redirection Operators](99_Appendices/J_Redirection-Operators.md)
- [Appendix K — Signal Numbers (Linux)](99_Appendices/K_Signal-Numbers-Linux.md)
- [Appendix L — Exit Code Conventions](99_Appendices/L_Exit-Code-Conventions.md)
- [Appendix M — Bash Version History](99_Appendices/M_Bash-Version-History.md)
- [Appendix N — Glossary](99_Appendices/N_Glossary.md)
- [Appendix O — Cross-Reference: Sections to BCS Sections](99_Appendices/O_Cross-Reference-Sections-to-BCS-Sections.md)
- [Appendix P — Cross-Reference: Sections to BCS-bash Files](99_Appendices/P_Cross-Reference-Sections-to-BCS-bash-Files.md)
- [Appendix Q — Further Reading](99_Appendices/Q_Further-Reading.md)

---

*End of reference.*

*This document is a structural reference guide — a comprehensive outline with briefing notes describing the intended content of each section. It identifies what an authoritative Bash 5.2+ reference must cover and how to organise it. Filling out each chapter into a fully written reference is the work that follows from this structure.*

#fin
