# BCS Advanced Bash Reference

**A comprehensive, lookup-oriented reference for modern Bash on Linux.**

Designed by Okusi Associates for the Indonesian Open Technology Foundation (YaTTI).
Target audience: working engineers, library authors, reviewers, and AI assistants.

Strict-mode assumptions throughout. Bottom-up structure: from the Unix model Bash sits on, through the language itself, through engineering discipline, to internals — closing on Bash 5.3 and beyond.

## Companion documents

[Bash Coding Standard (BCS)](../data/BASH-CODING-STANDARD.md) — ~100 actionable rules for BCS-compliant Bash 5.2+ scripts.

[BCS-bash](BCS-bash/index.md) — the `bash(1)` man page rewritten under strict-mode assumptions (`set -euo pipefail`, `[[ ]]` only, no POSIX compat).

[Examples directory](../examples/) — exemplar BCS-compliant scripts.

[Templates](../examples/templates/) — `complete`, `basic`, `minimal`, `library` script scaffolds.

---

## About this reference

This is a **structural reference guide** for advanced Bash users. It assumes Bash 5.2 or newer on Ubuntu 24.04 (or comparable Linux), strict-mode operation (`set -euo pipefail` with `shopt -s inherit_errexit`), and that the reader can already write at least basic shell.

It is organised bottom-up: the Unix model first (because Bash is a thin language over Unix primitives), then Bash as a program, then the language proper (lexical structure, parameters, expansions, redirection, control flow), then the engineering layer (functions, libraries, process management, signals, errors, I/O, CLI, concurrency, IPC), then the interactive layer (readline), then performance, security, tooling, idioms, portability, and internals — closing on Bash 5.3 and beyond.

### Who this is for

- Working engineers who write Bash regularly and need a single authoritative lookup.
- Library and tool authors who must understand semantics precisely, not approximately.
- Reviewers and standards authors who need cross-references between code, the BCS coding standard, and the Bash 5.2 man page.

### What this is *not*

- Not a coding standard. See [`../data/BASH-CODING-STANDARD.md`](../data/BASH-CODING-STANDARD.md) for ~100 actionable rules.
- Not a re-statement of the bash(1) man page. See [`BCS-bash/`](BCS-bash/) for a strict-mode-rewritten man-page reference. This document is *organised pedagogically* and routinely cross-references both BCS and BCS-bash.

### Conventions

- **Section numbering.** `Part N → Chapter N.M → Section N.M.K`. Cross-references use §N.M.K. Anchors follow the heading text.
- **Cross-references.** *BCS hook* → coding-standard section. *BCS-bash* → strict-mode man-page file. *Greg* → Greg Wooledge's wiki at `mywiki.wooledge.org`. *Manual* → GNU Bash Reference Manual.
- **Strict mode is assumed.** Every example, every recommendation. POSIX `sh` deviations are called out explicitly when relevant; otherwise not mentioned.
- **British English** throughout, matching BCS docs.
- **Briefing notes** under each heading describe the intended content of that section. Sub-bullets list the specific topics to cover. This document is the *structural skeleton* of the reference; full content lives in (or will live in) the chapter bodies.

### How to use this document

For lookup, use the Table of Contents. Each chapter is self-contained — you should never need to read prior chapters to understand a later one, though forward references are flagged. For systematic study, read top-to-bottom; the ordering is bottom-up by design.

---

## Table of Contents

### Part I — The Unix Model from Bash
1.1 Processes — fork, exec, wait
1.2 The file descriptor model
1.3 Files, directories, and special files
1.4 Streams and the standard descriptors
1.5 The shell environment
1.6 Users, groups, permissions
1.7 Exit status and process termination
1.8 Signals — overview
1.9 The controlling terminal and TTY layer

### Part II — Bash as a Program
2.1 Genealogy and the shell family
2.2 Bash version landscape
2.3 Build configuration and feature detection
2.4 Invocation modes
2.5 Startup file chains
2.6 `BASH_ENV` and `ENV`
2.7 Command-line options to bash itself
2.8 Exit and shell session lifecycle

### Part III — Lexical Structure and Shell Grammar
3.1 Tokenisation
3.2 Reserved words
3.3 Comments
3.4 Quoting overview
3.5 Single quotes
3.6 Double quotes
3.7 ANSI-C quoting `$'...'`
3.8 Locale-translation `$"..."`
3.9 Backslash escapes
3.10 Shell grammar
3.11 Operator precedence

### Part IV — Parameters, Variables, and Arrays
4.1 Parameter taxonomy
4.2 Positional parameters
4.3 Special parameters
4.4 Shell variables
4.5 The `declare` builtin and attributes
4.6 `local` and dynamic scope
4.7 `readonly` and immutability
4.8 `export` and the environment
4.9 Indexed arrays
4.10 Associative arrays
4.11 Namerefs (`-n`)
4.12 Integer arithmetic semantics
4.13 Variable assignment semantics
4.14 Unsetting

### Part V — Expansions
5.1 Order of expansions
5.2 Brace expansion
5.3 Tilde expansion
5.4 Parameter and variable expansion
5.5 Arithmetic expansion
5.6 Command substitution
5.7 Process substitution
5.8 Word splitting and IFS
5.9 Pathname expansion (globbing)
5.10 Quote removal
5.11 Glob options
5.12 Extended globs (extglob)
5.13 Locale and pattern matching

### Part VI — Redirection and Pipelines
6.1 The fd table from Bash's perspective
6.2 Input redirection
6.3 Output redirection
6.4 Stderr redirection and merging
6.5 Reading-and-writing
6.6 Duplicating fds
6.7 Moving and closing fds
6.8 Here-documents
6.9 Here-strings
6.10 Process substitution as redirection
6.11 Order of evaluation
6.12 `exec` for fd manipulation
6.13 Pipelines
6.14 Stderr pipelines (`|&`)
6.15 `pipefail` semantics
6.16 `lastpipe` semantics

### Part VII — Control Flow and Compound Commands
7.1 Compound command overview
7.2 `if`/`elif`/`else`/`fi`
7.3 `case`/`esac`
7.4 `for x in list`
7.5 C-style `for ((;;))`
7.6 `while`/`until`
7.7 `select`
7.8 Subshell grouping `( )`
7.9 Brace grouping `{ }`
7.10 `&&` and `||` short-circuits
7.11 `break` and `continue`
7.12 `return`
7.13 `exit`
7.14 `:`, `true`, `false`

### Part VIII — Conditional Expressions and Arithmetic
8.1 `[[ ]]` overview
8.2 File test operators
8.3 File comparison operators
8.4 String operators
8.5 Pattern matching with `==`
8.6 Regex matching with `=~`
8.7 Logical operators and grouping
8.8 Quoting rules inside `[[ ]]`
8.9 Arithmetic context `(( ))`
8.10 Arithmetic operators and precedence
8.11 Integer types, overflow, base prefixes
8.12 Floating-point — workarounds
8.13 `let` builtin
8.14 The deprecated `[ ]` and `test`

### Part IX — Functions
9.1 Definition syntax
9.2 Argument passing
9.3 `local` and scope
9.4 Return value via `return N`
9.5 Communicating results
9.6 Recursion and `FUNCNEST`
9.7 Function tracing
9.8 Listing and inspecting functions
9.9 Exporting functions
9.10 Naming conventions
9.11 Self-locating with `BASH_SOURCE`
9.12 Calling-convention discipline

### Part X — Sourcing, Libraries, and Modules
10.1 `source` semantics
10.2 The `BASH_SOURCE` array
10.3 Self-locating library pattern
10.4 Idempotent sourcing guards
10.5 Namespace prefixes
10.6 Public vs private conventions
10.7 Version negotiation
10.8 Lazy and conditional loading
10.9 Cross-shell sourcing pitfalls
10.10 API design
10.11 Distribution and installation

### Part XI — Process Management
11.1 The Bash process tree at runtime
11.2 PIDs: `$$`, `$BASHPID`, `$PPID`
11.3 Subshell origins
11.4 `BASH_SUBSHELL` depth tracking
11.5 Foreground vs background
11.6 Process groups and sessions
11.7 The job table
11.8 Job specifications
11.9 Job-control builtins
11.10 `kill` and signal delivery
11.11 `nohup` and `setsid`
11.12 Detaching from the terminal
11.13 Environment inheritance

### Part XII — Signals and Traps
12.1 Signal taxonomy
12.2 Signal numbers and names
12.3 Uncatchable signals
12.4 Signal disposition
12.5 The `trap` builtin
12.6 Pseudo-signals: EXIT, ERR, DEBUG, RETURN
12.7 `trap -p` and trap inspection
12.8 Trap inheritance
12.9 Trap reset across `exec`
12.10 Synchronous vs asynchronous delivery
12.11 Signal-safe code
12.12 Idempotent cleanup patterns
12.13 Tempfile and tempdir lifecycle
12.14 Lockfile pattern
12.15 Atomic file write
12.16 Reload-on-SIGHUP

### Part XIII — Error Handling and Exit Status
13.1 Exit status fundamentals
13.2 `set -e` (errexit) — full semantics
13.3 The errexit exemption matrix
13.4 `set -u` (nounset)
13.5 `set -o pipefail`
13.6 `inherit_errexit`
13.7 `||:` and `|| true` idioms
13.8 The `ERR` trap
13.9 `errtrace` and trap inheritance
13.10 Exit code conventions
13.11 Propagating exit codes
13.12 Rich error output

### Part XIV — Input, Output, and Messaging
14.1 Standard streams discipline
14.2 The `read` builtin
14.3 `mapfile` / `readarray`
14.4 The `printf` builtin
14.5 `printf` vs `echo`
14.6 Format specifiers
14.7 Logging discipline
14.8 Log levels
14.9 Coloured output and TERM detection
14.10 Progress indicators
14.11 Reading binary data
14.12 File locking for concurrent writes

### Part XV — Command-Line Processing
15.1 CLI conventions
15.2 `getopts` builtin
15.3 GNU `getopt(1)` external
15.4 Hand-rolled `while case shift`
15.5 Long options
15.6 Bundled short options
15.7 `--` end-of-options
15.8 Subcommand dispatch
15.9 Help text conventions
15.10 Synopsis grammar
15.11 Auto-generating usage

### Part XVI — Concurrency and Parallelism
16.1 Sequential vs background execution
16.2 `wait` and `wait -n`
16.3 `wait $pid` for specific child
16.4 Capturing per-child exit status
16.5 Bounded-concurrency fan-out
16.6 The job table under concurrency
16.7 `xargs -P`
16.8 GNU parallel
16.9 Race conditions in shell
16.10 Locking primitives
16.11 Signal handling under concurrency
16.12 Queue patterns

### Part XVII — Coprocesses and IPC
17.1 The `coproc` builtin
17.2 Bidirectional fd pairs
17.3 Multiple coprocesses
17.4 Named pipes (FIFOs)
17.5 Anonymous pipes
17.6 `/dev/tcp` and `/dev/udp`
17.7 `/dev/shm` shared memory
17.8 External IPC tools
17.9 Choosing the right primitive

### Part XVIII — Readline, History, and Completion
18.1 Readline overview
18.2 Editing modes
18.3 Key bindings
18.4 Bindable functions
18.5 History
18.6 The `history` builtin
18.7 History expansion
18.8 Programmable completion
18.9 Compspec actions
18.10 `_init_completion`
18.11 Dynamic completion functions
18.12 `COMPREPLY` and `COMP_*` variables
18.13 Prompts
18.14 Prompt escapes
18.15 Coloured and multi-line prompts
18.16 Terminal capability detection

### Part XIX — Performance
19.1 The Bash cost model
19.2 Profiling tools
19.3 `time` builtin vs `time` external
19.4 `BASH_XTRACEFD`
19.5 `PS4` instrumentation
19.6 `EPOCHREALTIME` for sub-second timing
19.7 Common optimisations
19.8 Parameter expansion vs external commands
19.9 Pipes vs redirection
19.10 Builtins vs externals
19.11 Bash 5.3 no-fork command substitution
19.12 Memory considerations
19.13 When Bash is the wrong tool

### Part XX — Security
20.1 Threat model
20.2 PATH hardening
20.3 IFS reset
20.4 `eval` avoidance
20.5 Command injection vectors
20.6 Input validation
20.7 Quoting under `set -u`
20.8 SUID restrictions
20.9 Secrets handling
20.10 `noclobber`
20.11 Privilege drop
20.12 Sanitising filenames
20.13 Symlink races
20.14 Restricted shell mode

### Part XXI — Static Analysis, Formatting, and Testing
21.1 ShellCheck warnings
21.2 ShellCheck directives
21.3 Source-path management
21.4 `shfmt`
21.5 `bcscheck`
21.6 Pre-commit hooks
21.7 CI integration
21.8 bats-core
21.9 Bats setup and teardown
21.10 Bats `run` and assertions
21.11 Mocking via PATH injection
21.12 shunit2
21.13 Coverage with kcov

### Part XXII — Idioms, Patterns, and Anti-Patterns
22.1 The strict-mode preamble
22.2 Self-locating script directory
22.3 Argument-parsing skeleton
22.4 Default-value patterns
22.5 Lazy initialisation
22.6 Memoisation
22.7 Iterating an associative array deterministically
22.8 Building structured output
22.9 Reading config files safely
22.10 Atomic file write
22.11 Exclusive lock
22.12 Bounded retry with exponential backoff
22.13 Tempdir lifecycle
22.14 Mock-friendly subprocess wrapper
22.15 Stack-trace error reporter
22.16 Self-test mode (dual-purpose script)
22.17 Anti-patterns catalogue

### Part XXIII — POSIX Conformance and Portability
23.1 Bash vs POSIX sh
23.2 The bashisms list
23.3 Bash vs dash
23.4 Bash vs ksh
23.5 Bash vs zsh
23.6 Bash 3.2 on macOS
23.7 BSD `sh`
23.8 `--posix` mode
23.9 `shopt` compatibility levels
23.10 When to write portable sh
23.11 Forward-compatibility hygiene
23.12 Targeting multiple Bash versions

### Part XXIV — Bash Internals
24.1 The execution pipeline
24.2 The bison grammar
24.3 Variable storage
24.4 Function storage
24.5 The job table
24.6 The trap table
24.7 The execution environment
24.8 Subshell forking
24.9 Builtin loadables
24.10 Reading the bash source

### Part XXV — Bash 5.3 and the Future
25.1 No-fork command substitution `${ cmd; }`
25.2 Other Bash 5.3 additions
25.3 Release cadence
25.4 Roadmap signals
25.5 Forward-compatibility considerations

### Appendices
Appendix A — Builtin Reference (alphabetical)
Appendix B — Special Parameters Reference
Appendix C — Shell Variables Reference
Appendix D — `set` Options Reference
Appendix E — `shopt` Options Reference
Appendix F — ANSI-C Escape Sequences
Appendix G — Glob and Extglob Patterns
Appendix H — Conditional Expression Operators
Appendix I — Parameter Expansion Cheat Sheet
Appendix J — Redirection Operators
Appendix K — Signal Numbers (Linux)
Appendix L — Exit Code Conventions
Appendix M — Bash Version History
Appendix N — Glossary
Appendix O — Cross-Reference: Sections to BCS Sections
Appendix P — Cross-Reference: Sections to BCS-bash Files
Appendix Q — Further Reading

---

<!-- BODY-START -->

# Part I — The Unix Model from Bash

*Bash is a thin shell over Unix. Most "advanced Bash" mysteries dissolve once the underlying Unix model is clear. This Part documents the Unix abstractions Bash exposes, framed as Bash sees them. It is not a general Unix textbook — it is the minimum mental model required for the rest of this reference to make sense.*

---

---

## 1.1 Processes — fork, exec, wait

The kernel-level process model on which every Bash construct ultimately rests. Bash's notion of "what a command is" decomposes into builtins (executed in-process), functions (executed in the current shell or a subshell depending on context), and external commands (executed via `fork()` plus `execve()`). Documents PIDs, parent–child relationships, the semantics of `wait()`, the lifecycle of zombies and orphans, and the difference between `$$` and `$BASHPID`.

- `fork(2)` semantics — what is duplicated, what is shared (file descriptors, signal dispositions, environment), what is reset (PID, parent PID, alarms, pending signals).
- `execve(2)` semantics — image replacement, preserved fds, reset signal handlers, ELF interpreter resolution, the shebang mechanism.
- `wait(2)`, `waitpid(2)`, `wait4(2)` and how Bash uses them to reap children.
- Zombies (`Z` state) and how they are produced; orphans and their inheritance by `init` (PID 1) or by a subreaper.
- The relationship of bash's `wait` builtin to the kernel call.
- `$$` (the script's PID, fixed at startup) versus `$BASHPID` (the current shell's PID, updated in subshells).
- Process groups and sessions — see §11.6 for the deeper treatment.

## 1.2 The file descriptor model

A file descriptor is a small non-negative integer that indexes the kernel's per-process open-file table. This chapter documents the table structure, what `open(2)` and `dup2(2)` actually do, the inheritance rules across `fork()` and `exec()`, and how Bash exposes these primitives via its redirection operators.

- The per-process fd table — entries point to system-wide open-file descriptions, which in turn point to inodes.
- Conventional fds 0 (stdin), 1 (stdout), 2 (stderr) — convention, not magic.
- `dup(2)`, `dup2(2)`, `dup3(2)` — duplication as the primitive behind `>&` and `<&`.
- `O_CLOEXEC` and the `close-on-exec` flag — how Bash sets it, when it doesn't.
- `/proc/PID/fd/` and `/proc/PID/fdinfo/` for inspection.
- `/dev/fd/N` and `/proc/self/fd/N` symlinks — the substrate of `<(…)` and `>(…)`.
- `lsof -p $$` and `ls -l /proc/$$/fd` for runtime inspection.
- The `ulimit -n` (RLIMIT_NOFILE) cap and how it bounds Bash.

## 1.3 Files, directories, and special files

The Linux VFS exposes seven file types through one uniform API. Bash exploits this freely; knowing which type to reach for is half the skill of writing concise shell.

- Regular files (`-`), directories (`d`), symbolic links (`l`), FIFOs / named pipes (`p`), Unix sockets (`s`), character devices (`c`), block devices (`b`).
- The synthetic `/proc` filesystem — process introspection and kernel parameters.
- The synthetic `/sys` filesystem — device and subsystem control.
- `/dev/null`, `/dev/zero`, `/dev/full` — sink, source, and write-fail device.
- `/dev/random`, `/dev/urandom` — entropy sources and the post-2.6.x equivalence.
- `/dev/tcp/host/port` and `/dev/udp/host/port` — Bash-synthesised network endpoints (covered in detail in §17.6).
- `/dev/stdin`, `/dev/stdout`, `/dev/stderr` and the `/dev/fd/N` family.
- `tmpfs` filesystems: `/tmp`, `/run`, `/dev/shm`.

## 1.4 Streams and the standard descriptors

The C runtime convention that every program inherits stdin (fd 0), stdout (fd 1), and stderr (fd 2). The discipline of "stdout is data, stderr is diagnostics" is not enforced by the kernel — it is a convention Bash scripts must uphold to remain composable.

- Inheritance of standard descriptors across `fork`/`exec`.
- Buffering: line-buffered (terminals), fully-buffered (pipes/files), unbuffered (stderr by C runtime convention).
- `stdbuf(1)` and `unbuffer(1)` — managing buffering of children.
- `isatty(3)` semantics — `[[ -t N ]]` in Bash.
- Why `printf` is preferred over `echo` for both stdout and stderr (see §14.5).

## 1.5 The shell environment

Every process carries an environment — an array of `KEY=VALUE` strings inherited at fork and replaced at exec. This chapter covers what is in the environment, how it propagates, and how Bash distinguishes shell variables from environment variables.

- `environ(7)` — the underlying C representation.
- Environment vs shell variables — the role of `export`.
- Inheritance: parent → child via `fork` (copy), child → new program via `exec` (replacement of code, preservation of environment).
- The working directory (`$PWD`, `$OLDPWD`) — also inherited.
- `umask` — inherited, affects `open()` mode bits.
- `ulimit` (resource limits) — inherited, see `getrlimit(2)`.
- Locale variables: `LANG`, `LC_*`, `LANGUAGE` — see §5.13.
- Time zone via `$TZ`.
- `$PATH` — search semantics, security implications (§20.2).
- Detecting environment changes by another process: not possible without re-exec.

## 1.6 Users, groups, permissions

The discretionary access control model that Bash scripts must respect. Documents the standard mode bits, the SUID/SGID/sticky bits, supplementary groups, and the difference between real, effective, and saved user IDs.

- Real, effective, saved user/group IDs — `getuid`, `geteuid`, `getresuid`.
- Mode bits: read/write/execute for owner/group/other.
- Special bits: SUID (`s`), SGID (`s`/`l`), sticky (`t`).
- SUID on scripts — disabled in Linux for sound reasons (§20.8).
- ACLs (`getfacl`, `setfacl`) — extension to the basic mode.
- Capabilities (`getcap`, `setcap`) — fine-grained privilege.
- `umask` and how it masks file-creation modes.
- `chmod`, `chown`, `chgrp` semantics.
- `id`, `groups`, `whoami`, `who`, `w` — user-state inspection.

## 1.7 Exit status and process termination

Every process exits with an 8-bit status code. Bash exposes it as `$?` and propagates it through pipelines, traps, and exit. Documents the encoding, the conventions, and how Bash handles abnormal termination.

- The 8-bit exit status — values 0–255.
- 0 = success, non-zero = failure (universal convention).
- BCS exit-code table: 1 general, 2 usage, 3 not-found, 5 I/O, 13 permission, 18 missing dependency, 22 invalid argument, 24 timeout (see Appendix L).
- `sysexits.h` conventions — older Unix tradition, less used now.
- Termination by signal — exit status encoded as `128 + signum` by Bash.
- `exit N` with `N > 255` — masked to `N % 256`.
- Core dumps and `WIFSIGNALED`, `WTERMSIG`, `WCOREDUMP`.
- `$?` lifecycle — replaced by every command, frozen until next.

## 1.8 Signals — overview

Signals are asynchronous notifications delivered to a process. This chapter introduces the concept and enumerates the Linux signal set; the deep treatment is in Part XII.

- What a signal is — kernel-delivered software interrupt.
- Standard signals (SIGINT, SIGTERM, SIGHUP, SIGKILL, SIGSTOP, …).
- Real-time signals (SIGRTMIN…SIGRTMAX).
- Default disposition: terminate, core dump, ignore, stop, continue.
- Per-signal table: name, number, default action.
- Catchable vs uncatchable.
- Synchronous (SIGSEGV, SIGFPE) vs asynchronous (SIGINT, SIGTERM).
- Forward reference: `trap` builtin (§12.5), pseudo-signals (§12.6).

## 1.9 The controlling terminal and TTY layer

Interactive Bash is intimately bound up with the controlling terminal. Documents what a TTY is, how Bash discovers it, the line discipline, and the keyboard signals that terminal drivers synthesise.

- `tty(1)`, `/dev/tty`, `/dev/pts/N`, `/dev/console` — the device hierarchy.
- Pseudo-terminals (PTYs) and the master/slave model.
- Controlling terminal — the `O_NOCTTY` flag, `TIOCSCTTY`.
- Foreground process group — only one group at a time can read from the TTY.
- Line discipline: cooked, raw, cbreak.
- Terminal-generated signals: SIGINT (Ctrl-C), SIGQUIT (Ctrl-\\), SIGTSTP (Ctrl-Z).
- Window size: `SIGWINCH`, `stty size`, `$LINES`, `$COLUMNS` (interactive only).
- `stty(1)` for terminal configuration.
- Detecting TTY presence: `[[ -t 0 ]]`, `[[ -t 1 ]]`.

# Part II — Bash as a Program

*Bash is a specific program with a specific history, a specific build configuration, and specific invocation modes. This Part documents what bash actually is — distinct from "the shell" generically — so the reader can reason about which version they have, how it was built, and how it was invoked.*

---

---

## 2.1 Genealogy and the shell family

Bash sits inside a family of shells with distinct ancestries. Knowing the relationships clarifies which features are universal, which are bash-specific, and what to expect when porting to a sibling.

- Bourne shell (`sh`, 1977) — the ancestor.
- Korn shell (`ksh88`, `ksh93`, `mksh`) — the parallel evolution.
- C shell (`csh`, `tcsh`) — divergent syntax, mostly extinct for scripting.
- Almquist shell (`ash`, `dash`) — minimal POSIX-compliant; `dash` is Ubuntu/Debian's `/bin/sh`.
- Z shell (`zsh`) — rich interactive, scripting-divergent.
- BusyBox `sh` — embedded systems.
- macOS Bash 3.2 — the perpetual outlier (§23.6).
- Bash's specific lineage from Brian Fox (1989) through Chet Ramey (1992–present).
- POSIX 1003.2 / SUSv4 — the standardised baseline that all serious shells aim at.

## 2.2 Bash version landscape

Bash's feature set has grown substantially since 4.0 (2009). This chapter documents what each major release added so the reader can target a specific version with confidence.

- Bash 3.2 (2006) — the macOS perpetual baseline.
- Bash 4.0 (2009) — associative arrays, coprocesses, `mapfile`, `&>>`, `**` globstar, `;&`/`;;&` case modifiers, `read -i`, `case` modifiers, autocd.
- Bash 4.1 (2009) — `printf -v` for arrays, `BASH_XTRACEFD`, `&>` becoming standard.
- Bash 4.2 (2011) — `declare -g`, `printf %(fmt)T`, `lastpipe`.
- Bash 4.3 (2014) — namerefs (`declare -n`), `mapfile -d`, `wait -n`.
- Bash 4.4 (2016) — `${param@Q/E/P/A/a}`, `local -`, `SIGINT` handling for traps, `BASH_REMATCH` immutability.
- Bash 5.0 (2019) — `EPOCHSECONDS`, `EPOCHREALTIME`, `BASH_ARGV0`, `history -d` ranges.
- Bash 5.1 (2020) — random source improvements, `SRANDOM`, `BASH_REMATCH` reset.
- Bash 5.2 (2022) — recursive bison grammar for command substitution, `varredir_close` shopt, `${var@k}`, `globskipdots`, `noexpand_translation`.
- Bash 5.3 (2025) — no-fork `${ cmd; }` command substitution and other additions (§25).
- The full version-feature matrix is in Appendix M.

## 2.3 Build configuration and feature detection

Bash is configurable at build time. Distributions disable some features; some versions add features behind compile flags. This chapter documents how to discover what your bash supports at runtime.

- `bash --version` — version string format.
- `BASH_VERSION`, `BASH_VERSINFO[0..5]` — programmatic version inspection.
- `BASH_VERSINFO` array structure (major, minor, patch, build, release, machtype).
- Compile-time options visible in `${BASH_VERSINFO[5]}` (machtype).
- Loadable builtins (`enable -f`) — only available if built with `--enable-loadable-builtins`.
- Restricted shell support (`--enable-restricted-shell`).
- Detecting `extglob`, `globstar`, namerefs, etc. with `shopt` and `declare -n`.
- `enable -p` and `enable -a` for builtin enumeration.
- `compgen -b` for builtin enumeration as completion candidates.

## 2.4 Invocation modes

Bash behaves differently depending on how it was invoked. Confusing the modes is the most common source of "works in my terminal, breaks in cron" bugs.

- Interactive vs non-interactive — detected via `[[ $- == *i* ]]`.
- Login vs non-login — detected via `shopt -q login_shell`.
- The four-quadrant matrix: {interactive, non-interactive} × {login, non-login}.
- `bash -c 'cmd'` — non-interactive non-login, one shot.
- `bash script.sh` — non-interactive non-login.
- `bash -i` — force interactive.
- `bash -l` or `bash --login` — force login.
- `bash -r` or `bash --restricted` — restricted shell (§23, §20.14).
- `sh` symlink invocation — bash mimics POSIX sh.
- `--posix` — POSIX conformance mode.
- `--noprofile`, `--norc`, `--rcfile FILE` — startup control.
- Single-command mode: `bash -c` plus `$0` and `$1`+ semantics.
- Reading from stdin: `bash -s` or implicit when no script argument.

## 2.5 Startup file chains

Each invocation mode reads a different chain of startup files. This chapter is the canonical map of which files are sourced when, and the order they are tried.

- Login shells: `/etc/profile` then the first existing of `~/.bash_profile`, `~/.bash_login`, `~/.profile`.
- On exit of a login shell: `~/.bash_logout`, `/etc/bash.bash_logout`.
- Interactive non-login shells: `/etc/bash.bashrc` then `~/.bashrc` (Debian/Ubuntu); other distros may differ.
- Non-interactive shells: `BASH_ENV` only, if set and expanding to an existing file.
- POSIX-mode startup: `ENV` only (per POSIX rules).
- The "chain a `.bashrc` from `.bash_profile`" idiom and its motivation.
- Environment inheritance interaction: variables exported in `/etc/profile` persist into all descendants.
- Common pitfalls: putting interactive-only code in `.bash_profile` (broken under `bash -c`), putting environment variables in `.bashrc` only (unset under `ssh host cmd`).

## 2.6 `BASH_ENV` and `ENV`

Two specific environment variables that control startup file sourcing for non-interactive shells. Often overlooked, occasionally weaponised in exploits, always worth understanding.

- `BASH_ENV` — sourced by non-interactive bash if set and the file exists.
- `ENV` — sourced by POSIX-mode bash and by sh-mode bash.
- Subject to `PATH` lookup (with security implications under SUID — but SUID scripts are forbidden anyway).
- Use cases: per-tenant environment injection, per-user shell-script defaults.
- Pitfalls: `BASH_ENV` set in user environment can leak into scripts invoked from that environment.

## 2.7 Command-line options to bash itself

The bash binary accepts a long list of single-character and `--`-prefixed long options. This chapter is the canonical table.

- `-c string` — execute string as a one-shot script.
- `-i` — force interactive.
- `-l`, `--login` — force login.
- `-r`, `--restricted` — restricted mode.
- `-s` — read from stdin even with arguments.
- `-x` — `set -x` from start.
- `-v` — `set -v` from start (echo input lines).
- `-e`, `-u`, `-o option` — equivalent to `set -e`, `-u`, `-o option`.
- `-O shoptname`, `+O shoptname` — set/unset a `shopt`.
- `--norc`, `--noprofile`, `--rcfile FILE` — startup file control.
- `--posix` — POSIX mode.
- `--noediting` — no readline editing in interactive mode.
- `--debugger` — bash debugger support hooks.
- `--version`, `--help`.

## 2.8 Exit and shell session lifecycle

How and when bash terminates, what runs at exit, and the difference between exiting the shell and exiting the script.

- `exit N` — terminate current shell with status N.
- Implicit exit at end of script — status is the last command's exit status.
- `EXIT` trap fires once, at any cause of exit (clean exit, signal-induced exit if the signal is trapped, `exit` builtin).
- `~/.bash_logout` for login shells.
- `HUPONEXIT` shopt — send SIGHUP to background jobs on exit (interactive only).
- Subshell exit — does not run parent's EXIT trap unless `set -E` and parent's trap is inheritable (it isn't, by design).
- `exec` — replaces the shell image, no exit, no EXIT trap.
- `kill -KILL $$` — uncatchable; no EXIT trap fires.

# Part III — Lexical Structure and Shell Grammar

*Before any expansion, before any execution, bash tokenises and parses input. This Part documents the language at the level of characters and grammar — the rules that determine what counts as a word, an operator, or a reserved word.*

---

---

## 3.1 Tokenisation

Bash splits input into tokens — words and operators — using a specific algorithm that respects quoting. Understanding tokenisation explains why some constructs require spaces (`[[ -f $f ]]`, not `[[-f $f]]`) and others don't (`a=b`, not `a = b`).

- The tokeniser's character classes: blank, metacharacter, control operator.
- Words vs operators.
- The role of quoting in deferring tokenisation (single-quoted text is one word, regardless of contents).
- Operator recognition: longest-match.
- Why `[[` and `]]` are reserved words, not operators (and what that implies).
- Why `((` is parsed as `( (`.
- Why `&&` requires no space but `& &` is two tokens.
- The end-of-input token.

## 3.2 Reserved words

A small set of identifiers that bash recognises as syntax keywords when they appear in command position. Recognised only where the grammar permits a reserved word — elsewhere they are ordinary tokens.

- Full list: `!`, `[[`, `]]`, `{`, `}`, `case`, `coproc`, `do`, `done`, `elif`, `else`, `esac`, `fi`, `for`, `function`, `if`, `in`, `select`, `then`, `time`, `until`, `while`.
- Recognition contexts: head of command, after another reserved word that introduces a compound, after `;` or `&&` or `||`.
- Why `if [[ x ]]; then echo if; fi` works but `echo if` prints the literal "if".
- Quoting suppresses reserved-word recognition: `\if` is a command named `if`.
- Aliases vs reserved words — reserved words always win.

## 3.3 Comments

The `#` character introduces a comment to end-of-line, but only in specific contexts. This chapter documents when `#` is a comment and when it isn't.

- In a script: `#` starts a comment if it is the first character of a word.
- Mid-word: `foo#bar` is one word, no comment.
- Inside double quotes: `#` is literal.
- Inside single quotes: `#` is literal.
- After parameter expansion: `${var#prefix}` — `#` is the operator.
- Inside `[[ ]]`: `#` is treated as a word character.
- Interactive shells with `interactive_comments` shopt off: `#` is not a comment introducer.
- Style: leading `#`-comments only; no end-of-line comments after code.

## 3.4 Quoting overview

Quoting is the mechanism by which the user defers or suppresses bash's expansion behaviour. There are four mechanisms, each with different rules.

- Backslash escape (`\c`).
- Single quotes (`'…'`) — strongest, no expansion.
- Double quotes (`"…"`) — selective, allows `$`, `` ` ``, `\`, `!`.
- ANSI-C quoting (`$'…'`) — interprets backslash escapes.
- Locale-translation quoting (`$"…"`) — gettext lookup.
- The expansion-suppression hierarchy.
- Why `"$var"` is the always-correct default.
- Quoting inside `$(…)` is independent of outer quoting.
- Cross-reference to BCS-bash/11_QUOTING.md.

## 3.5 Single quotes

Single quotes preserve the literal value of every character within them. The only character that cannot appear inside single quotes is a single quote itself.

- No expansion of any kind.
- Backslash is literal (no escaping).
- Newlines are literal.
- The single-quote-inside-single-quote idiom: `'it'\''s'` (close, escape, reopen).
- ANSI-C quoting as a workaround when escape sequences are needed.
- Single quotes inside double quotes — literal.

## 3.6 Double quotes

Double quotes preserve most characters literally but allow parameter expansion, command substitution, arithmetic expansion, and backslash escaping for a small set.

- Expansion allowed: `$var`, `${var…}`, `$(…)`, `` `…` ``, `$(( ))`.
- Backslash escapes only: `\$`, `` \` ``, `\"`, `\\`, `\<newline>`.
- All other backslashes are literal.
- `!` is special only in interactive mode (history expansion).
- Word splitting and pathname expansion are *not* performed on the result of expansion inside double quotes — this is the whole reason for the `"$var"` discipline.
- `"$@"` — special: each positional becomes its own word.
- `"$*"` — special: positionals joined by first character of `IFS`.

## 3.7 ANSI-C quoting `$'...'`

Quoting form that interprets backslash escapes the way C does. Useful for embedding control characters and Unicode.

- Standard escapes: `\a`, `\b`, `\e`, `\E`, `\f`, `\n`, `\r`, `\t`, `\v`, `\\`, `\'`, `\"`, `\?`.
- Octal: `\nnn`.
- Hex: `\xHH`.
- Unicode: `\uHHHH`, `\UHHHHHHHH`.
- Control characters: `\cX` (Ctrl-X).
- The `IFS=$' \t\n'` idiom.
- The `printf '%b\n' "$var"` alternative for runtime escape interpretation.

## 3.8 Locale-translation `$"..."`

Quoting form that triggers a gettext lookup against the program's message catalogue. Used for internationalised scripts.

- `$"text"` — looks up `text` in the active locale's catalogue.
- `gettext.sh` from GNU gettext for setup.
- `TEXTDOMAIN` and `TEXTDOMAINDIR` variables.
- Extracting messages with `xgettext` from shell sources.
- The `noexpand_translation` shopt (Bash 5.2) — suppresses expansion of `$"..."` for security in some contexts.
- Rare in practice; mentioned for completeness.

## 3.9 Backslash escapes

Backslash outside quoting preserves the literal value of the next character. Inside double quotes, it preserves only specific characters. Inside single quotes, it has no special meaning.

- Outside quotes: `\X` is literal X (loses any special meaning).
- Outside quotes: `\<newline>` is line continuation (the newline is removed).
- Inside double quotes: only `\$`, `` \` ``, `\"`, `\\`, `\<newline>` are escapes; others are literal backslash + character.
- Inside single quotes: backslash is always literal.
- Inside `$'…'`: full C-style escape interpretation (§3.7).

## 3.10 Shell grammar

Bash's grammar at the structural level: simple commands, pipelines, lists, compound commands. Cross-references the bison grammar (§24.2) and BCS-bash/09_SHELL-GRAMMAR/.

- Simple command: `command [args] [redirections]`.
- Pipeline: `[time] [!] cmd1 [| cmd2 …]`.
- AND-OR list: `pipeline [&& or || pipeline …]`.
- List: `and-or-list [;|& and-or-list …] [;|&]`.
- Compound command: brace group, subshell, `if`, `case`, `while`, `until`, `for`, `select`, `(( ))`, `[[ ]]`.
- Function definition: `name () compound-command [redirections]`.

## 3.11 Operator precedence

The precedence and associativity of shell operators — distinct from arithmetic operator precedence (§8.10).

- Highest precedence: pipeline.
- Then: `&&`, `||` (left-associative, equal precedence).
- Then: `;` and `&` as terminators (lowest).
- The `time` reserved word applies to the following pipeline.
- The `!` reserved word negates the exit status of the following pipeline.
- Grouping with `( )` (subshell) or `{ ; }` (current shell).
- Examples of how precedence resolves ambiguous expressions.

# Part IV — Parameters, Variables, and Arrays

*Bash variables are not all strings. They have types, scopes, attributes, and namespaces. This Part documents the data model: the parameter taxonomy, the `declare` system, scope rules, and the array machinery.*

---

---

## 4.1 Parameter taxonomy

Bash distinguishes three kinds of parameters: positional (set by argument passing), special (single-character names with fixed semantics), and shell variables (named by the user or by bash itself).

- Positional: `$0`, `$1`, …, `$N`, `$@`, `$*`, `$#`.
- Special: `$?`, `$$`, `$!`, `$_`, `$-`, `$0` (script name).
- Shell variables: user-defined, plus bash's `BASH_*`, `COMP_*`, `HIST*`, `FUNCNAME`, etc.
- Environment variables vs shell variables — the role of `export`.
- The full list of special parameters is in Appendix B.

## 4.2 Positional parameters

Set by script invocation, function call, and `set --`. Documented as a unified mechanism.

- `$0` — script name (or `$BASH_ARGV0` if set).
- `$1` … `$9` — first nine arguments; beyond, `${10}`, `${11}`, … with braces required.
- `$#` — count of positionals.
- `$@` — all positionals; `"$@"` expands each as a separate word.
- `$*` — all positionals; `"$*"` joins with first character of `IFS`.
- `set -- a b c` — explicit assignment.
- `shift [N]` — discard the first N (default 1) positionals.
- Function call and the function's local positional set.
- `getopts` and how it consumes positionals.

## 4.3 Special parameters

Single-character parameters with fixed semantics, set by bash itself.

- `$?` — exit status of last foreground command.
- `$$` — PID of the script (fixed at script start, not subshell PID).
- `$!` — PID of last backgrounded process.
- `$_` — last argument of previous command (or, in some contexts, the script name).
- `$-` — flags passed to or set in the shell (e.g., "himBHs").
- `$0` — argument zero (script name).
- Pitfalls: `$_` is overwritten by every command; rely on it only immediately after the relevant command.

## 4.4 Shell variables

Bash maintains a long list of reserved variable names with specific semantics. This chapter is the canonical taxonomy; the full list is in Appendix C.

- `BASH`, `BASH_VERSION`, `BASH_VERSINFO[]` — version info.
- `BASH_SOURCE[]`, `FUNCNAME[]`, `BASH_LINENO[]` — call stack inspection.
- `BASH_ARGV[]`, `BASH_ARGC[]` — function call argument history (with `extdebug`).
- `BASH_REMATCH[]` — last `=~` regex submatches.
- `BASH_SUBSHELL` — subshell depth.
- `BASHPID` — current process PID (different from `$$` in subshells).
- `BASHOPTS`, `SHELLOPTS` — `shopt`/`set -o` state as colon-separated strings.
- `COMP_*` family — completion context.
- `HIST*` family — history configuration.
- `IFS` — internal field separator.
- `LANG`, `LC_*`, `LANGUAGE` — locale.
- `LINENO`, `SECONDS`, `EPOCHSECONDS`, `EPOCHREALTIME`, `RANDOM`, `SRANDOM` — runtime values.
- `PIPESTATUS[]` — exit status array of last pipeline.
- `PS1`, `PS2`, `PS3`, `PS4`, `PS0` — prompts (§18.13).
- `PWD`, `OLDPWD`.
- `UID`, `EUID`, `GROUPS[]` — user identity.
- `MAPFILE`, `READLINE_LINE`, `READLINE_POINT` — readline integration.

## 4.5 The `declare` builtin and attributes

Bash variables have *attributes* set via `declare` (alias `typeset`). Attributes determine type, scope visibility, mutability, and export status.

- `declare --` — terminate option processing; declare with no attribute.
- `-i` — integer; arithmetic context applies on assignment.
- `-a` — indexed array.
- `-A` — associative array.
- `-r` — readonly (immutable thereafter).
- `-x` — export to environment.
- `-l` — convert value to lowercase on assignment (Bash 4.0+).
- `-u` — convert value to uppercase on assignment (Bash 4.0+).
- `-n` — nameref (Bash 4.3+); see §4.11.
- `-t` — function trace (only meaningful for functions).
- `-g` — declare a global from inside a function.
- `-p` — print declarations (introspection).
- `-f`, `-F` — function declarations.
- Combining attributes: `declare -ar arr=(1 2 3)`.
- Inheritance of attributes via `local` from parent scope.

## 4.6 `local` and dynamic scope

Variables declared `local` inside a function are visible to that function and to functions it calls (dynamic scope), but invisible to its caller after return.

- `local -- name=value` — terminate option processing, then declare.
- Without `--`: `local file=…` — `file` could be misinterpreted as an option to `local`.
- Dynamic scope semantics — distinct from lexical scope (Lisp/Pascal/most modern languages).
- Visibility chain: locals in current function shadow same-named globals; callees see the local.
- Interaction with namerefs (§4.11).
- `local -p` for inspection.
- `local -A`, `local -a`, `local -i` for typed locals.

## 4.7 `readonly` and immutability

Variables marked readonly cannot be reassigned, unset, or have their attributes changed.

- `readonly name=value` and `declare -r name=value` are equivalent.
- Once readonly, always readonly — no way to revoke without exiting the shell.
- Functions can be readonly: `readonly -f funcname`.
- `readonly -p` for listing.
- Use cases: script metadata (`SCRIPT_NAME`, `VERSION`, `PREFIX`), inviolable defaults.
- Pitfall: setting a readonly variable in a function persists after function returns.

## 4.8 `export` and the environment

`export` marks a shell variable for inheritance by child processes.

- `export name=value` and `declare -x name=value` are equivalent.
- Exported state is per-variable, persists for the shell's lifetime.
- Modifying an exported variable in a subshell does not affect the parent.
- `export -p` for listing exported variables.
- `export -n name` removes the export attribute (variable remains as shell variable).
- `export -f funcname` — function export (encoded specially in environment).
- The function-export mechanism and its security history (Shellshock, CVE-2014-6271 et al.).
- Always-exported standards: `PATH`, `HOME`, `LANG`, `TERM`, etc.

## 4.9 Indexed arrays

Sparse, integer-indexed arrays. The default array type in Bash.

- Creation: `arr=(a b c)`, `declare -a arr`, `arr[5]=x`.
- Indexing: `${arr[i]}` (i evaluated as arithmetic).
- Length: `${#arr[@]}`, `${#arr[*]}`.
- All elements: `"${arr[@]}"` (each is a word), `"${arr[*]}"` (joined by IFS[0]).
- Indices: `"${!arr[@]}"`.
- Slice: `"${arr[@]:offset:length}"`.
- Element-level slice: `"${arr[i]:offset:length}"`.
- Append: `arr+=(d e f)`.
- Sparse arrays: `arr[10]=x; arr[20]=y` — `${#arr[@]}` is 2.
- Copy: `new=("${old[@]}")` (preserves order, loses sparseness — re-indexed contiguously).
- True copy preserving sparse indices: requires loop over `${!old[@]}`.
- Iteration: `for x in "${arr[@]}"` (always quoted).
- `mapfile -t arr < file` for line-oriented input (§14.3).
- `unset 'arr[i]'` — quoting required to suppress globbing.

## 4.10 Associative arrays

Hash maps from string keys to string values. Available since Bash 4.0.

- Declaration: `declare -A by_id` (must be declared before use; no implicit creation).
- Assignment: `by_id[alice]=42`, `by_id=([alice]=42 [bob]=17)`.
- Lookup: `${by_id[alice]}`.
- Keys: `"${!by_id[@]}"` — order is hash-table order, not insertion order.
- Values: `"${by_id[@]}"`.
- Length: `${#by_id[@]}`.
- Append into a key: `by_id[alice]+=more`.
- Membership test: `[[ -v by_id[alice] ]]`.
- Deletion: `unset 'by_id[alice]'`.
- Pitfalls: assigning a string to an undeclared associative array creates an indexed array with key 0.
- Deterministic iteration requires sorting the keys explicitly (§22.7).

## 4.11 Namerefs (`-n`)

A nameref is a variable whose value is the *name* of another variable; reads and writes through the nameref are forwarded to the target. Bash's pointer-to-variable mechanism.

- Declaration: `declare -n ref=target` or `local -n ref=target`.
- Read: `echo "$ref"` returns target's value.
- Write: `ref=newval` writes to target.
- Use cases: output parameters from functions, generic algorithms.
- Cycle detection: bash detects simple cycles and errors out.
- Indirection through namerefs: `${!ref}` does NOT compose as expected; use `${ref}` directly.
- Namerefs to array elements: `declare -n elt=arr[3]`.
- Scoping: a `local -n` becomes invalid when its scope ends.
- Pitfalls: passing the same name as both target and ref (`local -n self=self`); shadowing the target name in the function.

## 4.12 Integer arithmetic semantics

Bash arithmetic is signed 64-bit on every modern Linux. This chapter covers the type system, overflow behaviour, and the contexts that trigger arithmetic.

- Signed 64-bit on LP64 Linux; signed 32-bit on i386 (rare now).
- Overflow wraps silently (no exception, no diagnostic).
- Division rounds toward zero.
- Modulo follows the sign of the dividend.
- Base prefixes: `0` (octal), `0x`/`0X` (hex), `BASE#NUM` (arbitrary base 2-64).
- Bases 11+ use letters; `64#@` and `64#_` are valid digit characters.
- No floating point; for fixed-point, scale to integers; for true float, call `bc`/`awk`/`python`.
- Arithmetic contexts: `(( ))`, `$(( ))`, `let`, `[[ -i ]]` operators, array index, `for ((;;))`.

## 4.13 Variable assignment semantics

When and how bash evaluates assignments. Documents the sequence of operations during an assignment statement.

- `name=value` — RHS is subject to tilde, parameter, command, arithmetic, process substitution; *not* word splitting or pathname expansion.
- `name+=value` — appends to existing value (or to array end for `-a`/`-A`).
- `declare name=value` — same expansions as plain assignment.
- Array element assignment: `arr[i]=value` — `i` is evaluated as arithmetic.
- Compound array assignment: `arr=(…)` — each word is subject to all expansions, including word splitting and pathname expansion (unlike scalar assignment).
- Multiple assignments on one line: `a=1 b=2 c=3` — all in same scope.
- Assignment-prefixed command: `VAR=value cmd` — VAR is exported only for cmd's environment (unless cmd is a special builtin or function with POSIX rules).
- Read-only and integer attributes apply at assignment time.
- `declare -i x=2+3` evaluates RHS as arithmetic.

## 4.14 Unsetting

Removing variables and functions from the shell.

- `unset name` — removes variable `name` (or function if no variable).
- `unset -v name` — variable only.
- `unset -f name` — function only.
- `unset -n name` — when `name` is a nameref, unset the *nameref*, not the target.
- `unset 'arr[i]'` — remove single array element (quoting required to suppress globbing).
- `unset arr` — remove entire array.
- A readonly variable cannot be unset; `unset` errors.
- `unset` of an exported variable also removes it from the environment.
- Pitfall: `unset BASH_REMATCH` after a `=~` match silently undoes the regex result.

# Part V — Expansions

*Bash performs eight expansions in a fixed order on every command line. Most "Stack Overflow Bash bugs" trace to a misunderstanding of which expansion runs when, on what, and producing what. This Part documents each expansion, the order, and the rules.*

---

---

## 5.1 Order of expansions

The canonical sequence of operations bash performs between reading a command and executing it. Memorise this order; the entire chapter sequence in this Part follows it.

1. Brace expansion.
2. Tilde expansion.
3. Parameter and variable expansion.
4. Arithmetic expansion.
5. Command substitution.
6. Process substitution.
7. Word splitting.
8. Pathname expansion.

Plus the implicit:

9. Quote removal.

Each expansion operates on the result of the previous; word splitting and pathname expansion act only on unquoted results. Quoting suppresses everything from word splitting onward.

## 5.2 Brace expansion

Generates arbitrary strings from a brace pattern. Performed *before* parameter expansion — so brace expansion of `${var}` does not work the way naive intuition suggests.

- Comma form: `{a,b,c}` → `a b c`.
- Range form: `{1..10}`, `{a..z}`, `{1..10..2}` (with step).
- Nested: `{a,b}{1,2}` → `a1 a2 b1 b2`.
- Preamble and postscript: `pre{a,b}post`.
- No expansion of variables inside the braces (they expand later).
- No filename matching — purely textual.
- Unmatched braces or single elements: passed through unchanged.
- Use cases: file enumeration (`mv file.{txt,bak}`), bulk creation (`mkdir -p {2024,2025,2026}/{01..12}`).

## 5.3 Tilde expansion

Expands `~` and `~user` to home directories.

- Bare `~` at start of word — `$HOME`.
- `~+` — `$PWD`.
- `~-` — `$OLDPWD`.
- `~user` — user's home from passwd database.
- `~+/path`, `~-/path`, `~user/path` — concatenation forms.
- Within an assignment: `PATH=~/bin:$PATH` — tilde expanded.
- Within `${var:-~/bin}` — tilde expanded.
- Within quoted strings (`"~"`) — *not* expanded.
- Anywhere mid-word — *not* expanded.

## 5.4 Parameter and variable expansion

The richest expansion in bash. The full operator set is enumerated in Appendix I; this chapter is the structural treatment.

- Bare: `$name`, `${name}`.
- Default: `${var:-default}` — use default if unset or empty.
- Default-and-assign: `${var:=default}` — also assigns to `var`.
- Error: `${var:?message}` — error and exit if unset or empty.
- Alternative: `${var:+alt}` — use `alt` if set and non-empty.
- Substring: `${var:offset}`, `${var:offset:length}`.
- Length: `${#var}`.
- Pattern removal: `${var#prefix}`, `${var##prefix}`, `${var%suffix}`, `${var%%suffix}`.
- Pattern substitution: `${var/old/new}`, `${var//old/new}`, `${var/#old/new}` (anchored start), `${var/%old/new}` (anchored end).
- Case conversion: `${var^}`, `${var^^}`, `${var,}`, `${var,,}`.
- Indirect: `${!var}` — value of variable named in `var`.
- Prefix list: `${!prefix*}`, `${!prefix@}` — names matching prefix.
- Array indices: `${!arr[@]}` — indices of array.
- Transformation: `${var@Q}` (quoted), `${var@E}` (escape-interpreted), `${var@P}` (prompt-expanded), `${var@A}` (assignment-form), `${var@a}` (attributes), `${var@K}`/`${var@k}` (assoc-array form, Bash 5.2+), `${var@U}`/`${var@u}`/`${var@L}` (case).

## 5.5 Arithmetic expansion

`$(( expr ))` evaluates `expr` as an arithmetic expression and substitutes the result. The full operator set is in §8.10.

- Form: `$(( expression ))`.
- Result is a string representation of the integer.
- Variables referenced without `$` prefix: `$(( a + b ))`.
- Nested: `$(( $(( a )) + b ))` — usually unnecessary.
- Empty: `$(( ))` is `0`.
- Old form `$[expression]` — deprecated, do not use.
- Inside arithmetic context, all named variables are evaluated; unset variables are `0` (unless `set -u`, which still treats them as `0` in arithmetic — a notable inconsistency).

## 5.6 Command substitution

Replaces the construct with the standard output of the executed command, stripped of trailing newlines.

- Form: `$(command)` — preferred.
- Old form: `` `command` `` — deprecated; cannot nest cleanly.
- Bash 5.3+ no-fork form: `${ command; }` — runs in current shell, no fork (§25.1).
- Subshell semantics: `$(…)` runs in a subshell unless using `${ …; }`.
- Trailing newlines stripped (one or more).
- Embedded newlines preserved.
- Quoting: `"$(cmd)"` prevents word splitting and pathname expansion of result.
- `inherit_errexit` controls whether `set -e` propagates into the substitution.
- Pitfall: `$(<file)` — reads file into variable, faster than `$(cat file)`.

## 5.7 Process substitution

Replaces the construct with a `/dev/fd/N` path connected to the stdin or stdout of the substituted command.

- Form: `<(command)` — readable; opens for reading from command's stdout.
- Form: `>(command)` — writable; opens for writing to command's stdin.
- Underlying mechanism: `/dev/fd/N` (Linux) or named pipe (some systems without `/dev/fd`).
- Use cases: `diff <(sort a) <(sort b)`, `tee >(gzip > out.gz) | …`.
- Lifetime: substituted process runs concurrently; reaped on the consumer's behalf.
- Exit status not directly available — capture via `wait` on the explicit PID, or use a coproc.
- Not POSIX; bash and zsh only.

## 5.8 Word splitting and IFS

After parameter, command, and arithmetic expansion, the unquoted results are split into words on the characters in `IFS`. Quoted expansions are exempt.

- Default IFS: space, tab, newline.
- IFS-whitespace vs IFS-non-whitespace — different rules for adjacent runs.
- IFS-whitespace runs are collapsed; non-whitespace separators produce empty fields if adjacent.
- The `IFS=$' \t\n'` idiom — explicit assertion of safe whitespace.
- The `IFS=:` idiom for parsing colon-separated fields.
- Setting IFS only for one command: `IFS=$'\n' read -ra arr <<<"$str"`.
- Unsetting IFS: word splitting still occurs, default IFS used.
- Quoted expansions: `"$var"` — no splitting.
- The cardinal rule: always quote, except when you specifically want splitting.

## 5.9 Pathname expansion (globbing)

After word splitting, each word containing unquoted glob metacharacters is treated as a pattern and matched against filenames.

- Metacharacters: `*` (zero or more), `?` (one), `[…]` (one of class).
- Bracket expressions: `[abc]`, `[!abc]` (negate), `[a-z]` (range), `[[:alpha:]]` (POSIX class).
- POSIX character classes: `alnum`, `alpha`, `blank`, `cntrl`, `digit`, `graph`, `lower`, `print`, `punct`, `space`, `upper`, `xdigit`.
- Hidden files: dotfiles excluded by default unless pattern's first character is `.` (or `dotglob` is set).
- No match: pattern passes through unchanged (unless `nullglob` or `failglob`).
- Sort order: locale-dependent (LC_COLLATE).
- Inside `[[ a == pattern ]]`: pattern matching is glob, not regex.
- Inside `case`: glob.

## 5.10 Quote removal

The implicit final step. After all expansions, unquoted backslash, single-quote, and double-quote characters that did not result from an expansion are removed.

- Removes only quoting characters introduced by the user, not those produced by expansion.
- Example: `var='a\b'; echo "$var"` prints `a\b` — the backslash came from expansion, not from user quoting.
- Final step before `execve`.

## 5.11 Glob options

Behavioural toggles via `shopt`.

- `nullglob` — unmatched glob expands to nothing instead of itself.
- `failglob` — unmatched glob is an error.
- `dotglob` — include dotfiles in `*` matches.
- `nocaseglob` — case-insensitive matching.
- `nocasematch` — applies to `[[ ]]` and `case` glob comparisons.
- `globstar` — `**` matches any number of directories.
- `globskipdots` (Bash 5.2+) — exclude `.` and `..` from `*` and `?` matches.
- `extglob` — enables extended glob patterns (§5.12).
- `dirspell`, `cdspell`, `globasciiranges` — minor toggles.
- Setting locally: save with `local` not possible for shopt; use `shopt -s`/`shopt -u` in pairs around the local code.

## 5.12 Extended globs (extglob)

When `shopt -s extglob` is set, additional pattern operators are available.

- `?(pattern-list)` — zero or one occurrence.
- `*(pattern-list)` — zero or more occurrences.
- `+(pattern-list)` — one or more occurrences.
- `@(pattern-list)` — exactly one occurrence.
- `!(pattern-list)` — anything except.
- Pattern list separator: `|`.
- Composability: `*.@(jpg|png|gif)`, `!(*.bak|*.tmp)`.
- Used in pathname expansion, `[[ ]]` pattern matching, `case`.
- Pitfalls: unset `extglob` parses extended globs as ordinary text; setting it dynamically inside a function does not retroactively re-parse.

## 5.13 Locale and pattern matching

Locale settings affect glob matching, regex matching, and `[[ ]]` comparisons.

- `LC_COLLATE` — sort/range order. `[a-z]` may include accented letters depending on locale.
- `LC_CTYPE` — character classification. `[[:alpha:]]` includes Unicode letters in UTF-8 locales.
- `LC_ALL=C` — byte-safe, ASCII-only — essential for parsing protocols and hashes.
- `LC_MESSAGES` — error messages.
- Bash 5.2 introduces stricter UTF-8 handling in some areas.
- The `LANG` fallback variable.
- Setting at script start: `export LC_ALL=C` is a frequent BCS pattern for parsing-heavy scripts.

# Part VI — Redirection and Pipelines

*Redirection is fd manipulation by another name. Every operator resolves to a small sequence of `dup2()` and `open()` syscalls. This Part documents the operators, the ordering rules, and the pipeline mechanism that composes them.*

---

---

## 6.1 The fd table from Bash's perspective

Recap from §1.2 framed as Bash sees it. Bash maintains the fd table inherited from its parent and modifies it via redirection operators before `exec`.

- Bash inherits all open fds at fork unless `O_CLOEXEC` was set on them.
- Bash applies redirections after fork, before exec, so children see the modified fd table.
- Redirections in compound commands apply to every command in the compound.
- Redirections on a function definition apply at every call.
- The bash builtin shell has its own fd 0/1/2 — script-wide redirection via `exec` modifies these.
- Custom fds 3–9 are conventional for user use; 10+ work but bash may use them internally.

## 6.2 Input redirection

Reading from a file or fd.

- `< file` — open file for reading on fd 0.
- `n< file` — open on fd n.
- `<&n` — duplicate fd n onto fd 0.
- `n<&m` — duplicate fd m onto fd n.
- `<&-` — close fd 0.
- `n<&-` — close fd n.
- `<<` — here-document (§6.8).
- `<<<` — here-string (§6.9).
- `<>` — open for read+write (§6.5).

## 6.3 Output redirection

Writing to a file or fd.

- `> file` — open file for writing on fd 1; truncate or create.
- `n> file` — open on fd n.
- `>> file` — open for appending on fd 1.
- `n>> file` — append on fd n.
- `>| file` — force overwrite even with `noclobber`.
- `>&n`, `n>&m` — duplicate, see §6.6.
- `>&-`, `n>&-` — close.
- `&> file` — shorthand for `> file 2>&1`.
- `&>> file` — shorthand for `>> file 2>&1`.

## 6.4 Stderr redirection and merging

Bash's two shorthands and the underlying explicit forms for combining stdout and stderr.

- `2> file` — stderr to file.
- `2>> file` — append.
- `2>&1` — stderr to current stdout target.
- `1>&2` — stdout to current stderr target.
- `>file 2>&1` — both to file (correct order).
- `2>&1 >file` — stderr to terminal, stdout to file (different! left-to-right evaluation, §6.11).
- `&> file` — combined shorthand.
- `&>> file` — combined append shorthand.
- `2> >(cmd)` — stderr to a process substitution.

## 6.5 Reading-and-writing

`<>` opens a file for both reading and writing on the same fd.

- `<> file` — fd 0.
- `n<> file` — fd n.
- File created if absent (with `O_RDWR | O_CREAT`).
- Use cases: maintaining a position in a file across reads and writes; FIFO-like patterns on regular files.
- Less common than read-only or write-only; included for completeness.

## 6.6 Duplicating fds

`>&` and `<&` duplicate fds, sharing the underlying open file description.

- `n>&m` — fd n is made a copy of fd m (writes go to the same destination).
- `n<&m` — same, but expressed for reading.
- The duplicated fd shares offset, status flags, and underlying file with the source.
- Closing one does not close the other.
- The dance for "save and restore stdout": `exec 3>&1; …; exec 1>&3 3>&-`.
- Difference between dup-and-close (`n>&m-`) and just-dup (`n>&m`) — see §6.7.

## 6.7 Moving and closing fds

The `>&-`/`<&-` close form, and the dup-and-close form `n>&m-`.

- `>&-` — close fd 1.
- `<&-` — close fd 0.
- `n>&-`, `n<&-` — close fd n.
- `n>&m-` — duplicate m onto n, then close m (atomic move).
- `n<&m-` — same, for reading.
- Use cases: passing exactly the fds a child needs, no leaks.
- Closing fd 1 then writing to it: SIGPIPE-equivalent or write failure depending on context.

## 6.8 Here-documents

`<<DELIM` … `DELIM` — synthesise stdin from inline text.

- Syntax: `cmd <<DELIM\n…\nDELIM`.
- Quoted delimiter (`<<'DELIM'`) — no expansion of body.
- Unquoted delimiter — parameter, command, arithmetic expansion of body.
- Indented form `<<-DELIM` — leading tabs (only tabs, not spaces) stripped from each line.
- Multiple here-docs in one pipeline: each lines up with its own command.
- Interaction with quoting: `<<\DELIM` is also a quoted form.
- Here-doc as input to `cat`, `mysql`, `psql`, etc.
- Implementation: written to a temp file or anonymous pipe, depending on size.

## 6.9 Here-strings

`<<<` — single-line variant of here-document; supplies a string as stdin.

- Syntax: `cmd <<<"string"`.
- Trailing newline appended automatically.
- Subject to all expansions (per quoting rules).
- Use cases: `read -r var <<<"$some_string"`, `bc <<<"1+2"`, `tr a-z A-Z <<<"$line"`.
- Faster and clearer than `echo "string" | cmd` for short strings.

## 6.10 Process substitution as redirection

Process substitution (§5.7) is a redirection mechanism in disguise — `<(cmd)` produces a `/dev/fd/N` path that bash can pass as a filename.

- `diff <(sort a) <(sort b)` — fed as filenames to diff.
- `cmd > >(filter)` — pipe stdout through a filter.
- `cmd > >(tee log) 2> >(tee err >&2)` — split stdout and stderr to logs while preserving display.
- The substituted process's exit status is not bash's `$?`.
- Lifetime considerations.

## 6.11 Order of evaluation

Redirections are processed left-to-right. This is the rule that makes `> file 2>&1` and `2>&1 > file` differ.

- `cmd > file 2>&1`: open file on fd 1, then duplicate fd 1 onto fd 2 — both go to file.
- `cmd 2>&1 > file`: duplicate current fd 1 onto fd 2 (terminal), then open file on fd 1 — stderr to terminal, stdout to file.
- Always specify the target redirection before the merge.
- Multiple writes to the same file via different fds: each fd has its own offset; output may interleave unexpectedly.

## 6.12 `exec` for fd manipulation

`exec` without a command applies redirections to the current shell, persisting beyond a single command.

- `exec > script.log 2>&1` — script-wide redirection.
- `exec 3>&1` — save stdout on fd 3 for later restoration.
- `exec 3>&-` — close fd 3.
- `exec 7<>config.dat` — open config for read+write on fd 7.
- `read -u 7 line` — read from fd 7.
- `printf 'data' >&7` — write to fd 7.
- `exec` with a command replaces the shell process — a different operation entirely (§11.11 indirectly).
- The `varredir_close` shopt (Bash 5.2) — close redirected fds when the variable goes out of scope.

## 6.13 Pipelines

`a | b` connects a's stdout to b's stdin via a kernel pipe.

- Two processes (typically); both may be subshells.
- Each process's stdout buffered separately; bash inserts no buffering.
- `pipefail` (§6.15) controls overall exit status.
- Default pipeline status: only the last command's `$?`.
- `PIPESTATUS[]` array — exit status of each command in the last pipeline (§6.15).
- Pipeline runs in subshells unless `lastpipe` (§6.16).
- Multi-stage: `a | b | c | d` — three pipes, four processes.
- Time the whole pipeline: `time a | b | c`.
- Negate: `! a | b | c`.

## 6.14 Stderr pipelines (`|&`)

`a |& b` is shorthand for `a 2>&1 | b` — pipe both stdout and stderr.

- Bash 4.0+.
- Equivalent to `a 2>&1 | b` but more compact.
- Same exit-status rules as `|`.
- Useful for capturing diagnostic output of long pipelines.

## 6.15 `pipefail` semantics

`set -o pipefail` makes a pipeline's exit status the rightmost non-zero status, or zero if all succeeded.

- Without pipefail: only the last command's status counts.
- With pipefail: any failure in the pipeline is visible.
- `PIPESTATUS[N]` — individual exit statuses (always available).
- Interaction with `set -e` — pipefail makes errexit fire on any pipeline failure.
- `pipefail` plus `errexit` plus `inherit_errexit` is the strict-mode trio.
- Interaction with `||` — a pipeline followed by `|| handler` masks the failure cleanly.

## 6.16 `lastpipe` semantics

`shopt -s lastpipe` runs the last command of a pipeline in the current shell rather than a subshell — making variables set in it visible afterwards.

- Bash 4.2+.
- Only effective when job control is off (non-interactive shells, or interactive with `set +m`).
- Cures the `cmd | while read … done` outer-scope problem.
- Pitfall: still subject to `set -e` exemptions.
- Verification: `printf '%s\n' a b c | { read x; echo "$x"; }` — `x` is empty without lastpipe in interactive mode.

# Part VII — Control Flow and Compound Commands

*The compositional layer of bash: how to assemble simple commands into conditional, iterative, and grouped structures. This Part documents every compound command form.*

---

---

## 7.1 Compound command overview

A compound command is one of seven forms: brace group, subshell, `if`, `case`, `while`, `until`, `for`, `select`, `(( ))`, `[[ ]]`. Compound commands have an exit status (the last simple command's, or specific to the form).

- Each compound command can carry redirections that apply to every nested command.
- Compound commands can be the body of a function.
- Pipelines accept compound commands.
- Backgrounded compound commands run in subshells.
- Compound commands and word/operator boundaries.

## 7.2 `if`/`elif`/`else`/`fi`

The conditional. The condition is *any command's exit status*, not a boolean.

- Syntax: `if list; then list; [elif list; then list;] … [else list;] fi`.
- Condition is the exit status of the *last command* in the `if` list.
- `if [[ … ]]; then …; fi` — common idiom.
- `if cmd; then …; fi` — equally valid.
- Empty list bodies require at least `:` (the null command).
- One-line form: `if cond; then act; fi`.
- Negation: `if ! cmd; then …; fi`.
- Errexit interaction: condition lists are exempt (§13.3).

## 7.3 `case`/`esac`

Pattern-based dispatch. Patterns are *globs*, not literals or regexes.

- Syntax: `case word in pattern1 [| pattern2…]) list ;; …; esac`.
- Matched left-to-right; first match wins.
- `;;` — exit case after this branch (default).
- `;&` — fall through to the next branch unconditionally (Bash 4.0+).
- `;;&` — fall through with re-evaluation (Bash 4.0+).
- Patterns are subject to glob expansion: `*`, `?`, `[…]`, plus extended globs if `extglob` is set.
- Pattern `*)` as default branch.
- `nocasematch` shopt for case-insensitive matching.
- Quoting on the pattern: `case $x in "$y") …` matches `$y` literally rather than as a pattern.
- Use case dispatch over `if/elif` chains for any 3+ branch decision.

## 7.4 `for x in list`

Iterate over an explicit list.

- Syntax: `for var in word1 word2 …; do list; done`.
- `for var; do …; done` — equivalent to `for var in "$@"; do …; done`.
- The list is subject to all expansions including word splitting and pathname expansion.
- Iterate over array: `for x in "${arr[@]}"; do …`.
- Iterate over keys: `for k in "${!by_id[@]}"; do …`.
- One-line form: `for x in a b c; do echo "$x"; done`.

## 7.5 C-style `for ((;;))`

C-style numeric loop with arithmetic context.

- Syntax: `for (( init; cond; update )); do list; done`.
- All three expressions are arithmetic.
- Empty conditions: `for ((;;))` is an infinite loop.
- Variables referenced without `$` (arithmetic context).
- Use for indexed iteration where the index itself is needed.
- Standard idiom: `for ((i=0; i<${#arr[@]}; i++)); do echo "${arr[i]}"; done`.

## 7.6 `while`/`until`

Looping on a condition.

- `while list; do list; done` — repeat while last command in list returns 0.
- `until list; do list; done` — repeat until last command in list returns 0.
- `while :; do …; done` and `while true; do …; done` — infinite loop idioms.
- `while read -r line; do …; done < file` — line-oriented input idiom.
- Pitfall: `cmd | while read …` runs the loop in a subshell; use process substitution or `lastpipe`.
- `break` and `continue` apply (§7.11).

## 7.7 `select`

Generate a numbered menu and read a choice. Interactive use only.

- Syntax: `select var in list; do list; done`.
- Reads from stdin until EOF or `break`.
- `PS3` is the prompt.
- `REPLY` holds the user's literal input; `var` holds the selected element.
- Empty input redisplays the menu.
- Invalid input sets `var` empty.
- Rare in scripts; useful for ad-hoc tools.

## 7.8 Subshell grouping `( )`

Run a list in a subshell.

- Syntax: `( list )`.
- Forks a subshell; variable assignments do not affect parent.
- Inherits open fds, traps reset for non-EXIT signals.
- `BASH_SUBSHELL` increments.
- Use cases: scoped variable changes, `cd` without affecting caller, throwaway environment.
- Distinguished from `( )` in arithmetic and conditional contexts (different parsers).

## 7.9 Brace grouping `{ }`

Run a list in the current shell.

- Syntax: `{ list; }` — note required spaces and trailing semicolon (or newline).
- No fork; variable assignments persist.
- Common with redirection: `{ cmd1; cmd2; } > file`.
- Distinguished from brace expansion (§5.2) by context (only valid as command).
- The `if`-equivalent grouping mechanism without forking.

## 7.10 `&&` and `||` short-circuits

AND-OR lists chain commands with conditional execution.

- `cmd1 && cmd2` — run `cmd2` only if `cmd1` succeeded.
- `cmd1 || cmd2` — run `cmd2` only if `cmd1` failed.
- Left-associative; equal precedence.
- The condition of `&&`/`||` is the *immediate left command's* exit status, not the whole left chain's.
- `cmd1 && cmd2 || cmd3` is *not* `if cmd1 then cmd2 else cmd3` — `cmd3` runs if either `cmd1` or `cmd2` fails.
- Use parentheses or grouping to disambiguate: `cmd1 && { cmd2; cmd3; }` vs `(cmd1 && cmd2) || cmd3`.
- Errexit exemption: AND-OR list left sides are exempt.

## 7.11 `break` and `continue`

Loop control.

- `break [N]` — exit N enclosing loops (default 1).
- `continue [N]` — restart from condition of N-th enclosing loop.
- N out of range: error.
- `case` is *not* a loop — `break` does not affect it.
- `select` is a loop; `break` exits it.

## 7.12 `return`

Return from a function with a status code.

- `return [N]` — N defaults to status of last command.
- N is 0–255; values outside wrap.
- `return` outside a function: in a sourced script, terminates sourcing; outside both, error.
- Distinct from `exit`: `return` leaves the shell running.

## 7.13 `exit`

Terminate the shell.

- `exit [N]` — N defaults to status of last command.
- N modulo 256.
- Triggers EXIT trap.
- `exit` from within a subshell exits only the subshell.
- Subshell exit does not run parent's EXIT trap.

## 7.14 `:`, `true`, `false`

Three commands that exist primarily to satisfy syntax requirements.

- `:` — null command, returns 0. Faster than `true` (it's a special builtin).
- `true` — returns 0.
- `false` — returns 1.
- Use cases: empty body of a control structure (`while :; do …; done`), forcing success in `||:` idiom, infinite loops.
- `: ${VAR:=default}` — assign default via parameter expansion side effect.

# Part VIII — Conditional Expressions and Arithmetic

*Bash has two test contexts: `[[ ]]` for file/string/regex and `(( ))` for arithmetic. The legacy `[ ]` POSIX test exists but is not used in modern Bash. This Part documents both contexts, their operators, and their precedence rules.*

---

---

## 8.1 `[[ ]]` overview

The modern conditional command. A reserved word, parsed before expansion — quoting rules differ from ordinary commands.

- Syntax: `[[ expression ]]`.
- Returns 0 (true) or 1 (false).
- Operands subject to parameter, command, arithmetic, process substitution; *not* word splitting or pathname expansion.
- Logical operators inside: `&&`, `||`, `!`, parentheses.
- No need to quote variable expansions (though it does no harm).
- Right-hand side of `==` is treated as a glob pattern unless quoted.
- Right-hand side of `=~` is treated as ERE regex; do not quote (or quoting changes semantics, see §8.6).

## 8.2 File test operators

Single-operand tests on files. The full table:

- `-e file` — exists.
- `-f file` — regular file.
- `-d file` — directory.
- `-L file`, `-h file` — symbolic link.
- `-b file` — block device.
- `-c file` — character device.
- `-p file` — named pipe (FIFO).
- `-S file` — socket.
- `-r file` — readable by EUID.
- `-w file` — writable by EUID.
- `-x file` — executable by EUID.
- `-s file` — non-zero size.
- `-N file` — modified since last read.
- `-O file` — owned by EUID.
- `-G file` — group owned by EGID.
- `-k file` — sticky bit.
- `-u file` — SUID bit.
- `-g file` — SGID bit.
- `-t fd` — fd refers to a terminal.

## 8.3 File comparison operators

Two-operand file tests.

- `file1 -nt file2` — file1 newer than file2 (modification time).
- `file1 -ot file2` — file1 older than file2.
- `file1 -ef file2` — same inode (hard links, same file).
- Pitfalls: `-nt` returns true if file2 doesn't exist; `-ot` returns true if file1 doesn't exist.

## 8.4 String operators

String comparison and inspection.

- `-z str` — empty.
- `-n str` — non-empty.
- `str1 = str2` — equal (POSIX form).
- `str1 == str2` — equal (bash form).
- `str1 != str2` — not equal.
- `str1 < str2` — lexicographically less (locale-dependent).
- `str1 > str2` — lexicographically greater.
- The `<` and `>` operators must be inside `[[ ]]`, not redirections.
- Variable existence: `[[ -v var ]]` — true if var is set.
- Element existence: `[[ -v arr[i] ]]`.
- Reference test: `[[ -R name ]]` — true if name is a nameref.

## 8.5 Pattern matching with `==`

Right-hand side of `==` (or `=`) inside `[[ ]]` is a glob pattern unless quoted.

- `[[ $f == *.sh ]]` — pattern match.
- `[[ $f == "*.sh" ]]` — literal match (the asterisk is literal).
- `[[ $f == @(yes|no|maybe) ]]` — extended glob (requires `extglob`).
- Pattern rules same as pathname expansion (§5.9).
- `nocasematch` shopt makes matching case-insensitive.
- Use this for cheap dispatch instead of regex when glob suffices.

## 8.6 Regex matching with `=~`

Right-hand side of `=~` is an ERE (extended regular expression).

- `[[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]`.
- Captures populate `BASH_REMATCH[]`: `[0]` is the full match, `[1]…[N]` are capture groups.
- Quoting changes behaviour: `[[ $x =~ "pattern" ]]` matches the literal string, suppressing regex metacharacters.
- For literal matching with metacharacters, store regex in a variable and reference unquoted: `pat='^foo$'; [[ $x =~ $pat ]]`.
- Locale affects character classes (`[[:alpha:]]`, etc.).
- POSIX character classes supported.
- `BASH_REMATCH` is volatile — capture immediately or copy.

## 8.7 Logical operators and grouping

Inside `[[ ]]`, logical operators combine sub-expressions.

- `! expr` — negation.
- `expr1 && expr2` — short-circuit AND.
- `expr1 || expr2` — short-circuit OR.
- `( expr )` — grouping.
- Precedence: `!` > `&&` > `||`.
- Combine: `[[ -f $f && -r $f && -s $f ]]` — file exists, readable, non-empty.

## 8.8 Quoting rules inside `[[ ]]`

`[[ ]]` is a reserved word, parsed specially. Quoting rules are relaxed compared to ordinary commands.

- Variable expansions: quoting is optional but harmless.
- Right of `==`: quoting matters (glob vs literal).
- Right of `=~`: quoting matters (regex vs literal).
- Word splitting and pathname expansion do not occur inside `[[ ]]`.
- Operators must not be quoted: `"<"` is the literal character, not the comparison operator.

## 8.9 Arithmetic context `(( ))`

`(( expression ))` evaluates expression as arithmetic, returns 0 if non-zero, 1 if zero.

- Returns 0 (true) when the expression evaluates to a non-zero value.
- Variables referenced without `$` (arithmetic context).
- Integer-only.
- Useful as condition: `if ((count > 0)); then …; fi`.
- Useful as standalone: `((count++))` — but see the errexit pitfall (§13.3).
- Distinct from `$(( ))` which substitutes the value (§5.5).

## 8.10 Arithmetic operators and precedence

Bash arithmetic supports a rich operator set with C-like precedence. Full table is in Appendix H; this is the structural overview.

- Unary: `++`, `--` (pre and post), `+`, `-`, `!`, `~`.
- Multiplicative: `*`, `/`, `%`.
- Additive: `+`, `-`.
- Shift: `<<`, `>>`.
- Comparison: `<`, `<=`, `>`, `>=`.
- Equality: `==`, `!=`.
- Bitwise: `&`, `^`, `|`.
- Logical: `&&`, `||`.
- Conditional: `cond ? then : else`.
- Assignment: `=`, `+=`, `-=`, `*=`, `/=`, `%=`, `<<=`, `>>=`, `&=`, `^=`, `|=`.
- Comma: `,` — evaluate left, return right.
- Exponentiation: `**`.

## 8.11 Integer types, overflow, base prefixes

Bash arithmetic uses signed C `intmax_t` — typically 64-bit on Linux.

- Range: -2^63 to 2^63 - 1 on 64-bit Linux.
- Overflow wraps silently — no exception, no diagnostic.
- Bases: decimal default; `0` prefix for octal; `0x`/`0X` for hex; `BASE#NUM` for arbitrary base 2–64.
- Base 64 uses `0-9 a-z A-Z @ _` for digits 0–63.
- Examples: `0755` = 493, `0xff` = 255, `2#1010` = 10, `36#zz` = 1295.

## 8.12 Floating-point — workarounds

Bash has no native floats. Workarounds:

- Scaled integers: store amounts in cents instead of dollars.
- `bc -l`: `result=$(bc -l <<<"3.14 * 2")`.
- `awk 'BEGIN { print 3.14 * 2 }'`.
- `printf '%.2f\n' "$value"` for formatting integer-derived approximations.
- `python3 -c 'print(3.14 * 2)'` if Python is available.

## 8.13 `let` builtin

`let` evaluates its arguments as arithmetic expressions, returning failure if the last evaluates to zero.

- `let x=5 y=10 z=x+y` — multiple assignments.
- `let "x = 5"` — quoting required for spaces.
- Returns 1 if last expression is zero — interacts with `set -e` the same way `((x))` does.
- Use `(( ))` instead in modern code; `let` is older and slightly less safe.

## 8.14 The deprecated `[ ]` and `test`

POSIX `test` builtin and its `[ ]` synonym. Used by sh and by historical bash code; not used in modern Bash scripts.

- `[` is a builtin command requiring matching `]` as last argument.
- Field-splits its operands — must quote: `[ -f "$file" ]`.
- No regex, no `&&`/`||` (only `-a`, `-o` which are dangerous).
- No `=~`.
- Always use `[[ ]]` instead.
- Documented here only because the reader will encounter it in legacy code.

# Part IX — Functions

*Functions are bash's primary unit of code organisation. This Part documents definition syntax, argument passing, scope, return semantics, output discipline, and the inspection mechanisms.*

---

---

## 9.1 Definition syntax

Two equivalent forms, with subtle differences.

- POSIX form: `name() { body; }`.
- Bash keyword form: `function name { body; }` or `function name() { body; }`.
- The `function` keyword form does not require parentheses.
- Either form's body may be any compound command (brace group, subshell, etc.).
- Body in `( )` instead of `{ }`: every call forks a subshell.
- Trailing redirections: `name() { body; } 2>&1` — applied at every call.
- Function name can be any valid identifier; with `function` keyword, hyphens are also legal.
- Style: BCS prefers the POSIX form; reserve `function` keyword for cases that require it.

## 9.2 Argument passing

Arguments arrive as positional parameters local to the function.

- `$1`, `$2`, … `${10}`, `${11}`, … (braces required for index ≥10).
- `$#` — count.
- `$@` — all (each as separate word when quoted).
- `$*` — all (joined by IFS[0] when quoted).
- `$0` — script name (NOT function name); use `${FUNCNAME[0]}` for the function name.
- No declared parameter list — purely positional.
- Default values: `local arg="${1:-default}"`.
- Required arguments via `:?`: `local arg="${1:?usage: name arg}"`.
- Forwarding: `helper "$@"` (quoted, not `$*`).

## 9.3 `local` and scope

Variables declared `local` inside a function are dynamically scoped — visible to that function and its callees, invisible to its caller after return.

- `local --` to terminate option processing.
- `local -- name=value`, `local -i name=N`, `local -a name=(…)`, `local -A name`.
- `local -n ref=target` for namerefs (§4.11).
- Without `local`: assignment touches a global (shadowing not possible without `local`).
- Functions called from inside the function inherit the local's visibility (dynamic scope).
- `local -p` for inspection.
- `local -` (Bash 4.4+) — save and restore `$-` (shell options) for the function.
- Performance: `local` is slightly slower than bare assignment; in tight loops, it matters.

## 9.4 Return value via `return N`

Functions return an 8-bit exit status.

- `return N` — N is 0–255.
- `return` without N — uses last command's status.
- Default return at function end — last command's status.
- Calling function: `$?` after the call holds the function's return.
- Distinct from `exit` — `return` stays in the shell.
- Use codes: 0 success, non-zero failure, with consistent meaning across the codebase.

## 9.5 Communicating results

A function communicates results via four mechanisms; the choice has style and correctness implications.

- **stdout** — standard. Caller captures with `result=$(func args)`.
- **Namerefs** — output parameter. `func() { local -n out=$1; out=value; }; func myvar`.
- **Globals** — possible but discouraged; couples the function to a name.
- **Exit status** — for boolean predicates only; not for communicating data.
- Trade-offs: stdout is composable but forks a subshell (cost ~1ms); namerefs avoid the subshell but require caller cooperation; globals are silently coupled.
- BCS preference: stdout for data-returning functions, namerefs for performance-sensitive paths.

## 9.6 Recursion and `FUNCNEST`

Functions may call themselves, but bash's stack is limited.

- Default `FUNCNEST` is 0 (no limit) — but practical limit is around 5000–10000 frames.
- `FUNCNEST=N` sets a hard cap; exceeding it returns 1 from the recursive call.
- Use cases for recursion: tree walking, depth-first search, parser-style code.
- Tail call optimisation: not performed; deep recursion will hit memory limits.
- Pitfalls: recursion plus `set -e` plus a failed base case can produce confusing exit chains.
- The call stack is visible via `FUNCNAME[]` and `BASH_LINENO[]` (§9.11).

## 9.7 Function tracing

Hooks for observing function entry, exit, and DEBUG events.

- `set -T` (alias `set -o functrace`) — DEBUG and RETURN traps inherited by functions.
- `set -E` (alias `set -o errtrace`) — ERR trap inherited by functions.
- `RETURN` trap — fires when a function returns or sourcing completes.
- `DEBUG` trap — fires before each simple command.
- `declare -t funcname` — turn on function tracing for a specific function.
- `declare -ft funcname` — make a function exportable with tracing.
- Use cases: instrumentation, profiling, debugging.

## 9.8 Listing and inspecting functions

Bash provides multiple builtins for function introspection.

- `declare -F` — list all defined function names.
- `declare -F funcname` — show name (and source line if `extdebug` is on).
- `declare -f` — show all function definitions with bodies.
- `declare -f funcname` — show one function's body.
- `type -t funcname` — returns "function" for a function.
- `compgen -A function` — list as completion candidates.
- `compgen -A function -X '!my*'` — filter by prefix.

## 9.9 Exporting functions

Functions can be exported into the environment of child bash processes.

- `export -f funcname`.
- `declare -fx funcname` — equivalent.
- Encoded specially in environment as `BASH_FUNC_funcname%%=() { body }`.
- Inherited only by bash children, not by other programs (which see the encoded variable as garbage).
- Security history: Shellshock (CVE-2014-6271) exploited the function-encoding parser in older bash.
- Use sparingly; namespace pollution risk.

## 9.10 Naming conventions

Convention shapes maintainability. BCS-aligned conventions.

- Lowercase with underscores: `process_file`, `read_config`.
- Private functions prefixed with `_`: `_internal_helper`.
- Library namespaces: `mylib::function` (Bash supports `::` in function names).
- Avoid clashing with builtins (`test`, `read`, `printf`).
- Avoid one-letter names (debugging difficulty).
- Action verb + noun: `validate_input`, `parse_args`, `emit_report`.
- BCS messaging helpers: `info()`, `success()`, `warn()`, `error()`, `die()`.

## 9.11 Self-locating with `BASH_SOURCE`

A function can determine the file it was defined in via the `BASH_SOURCE` array.

- `BASH_SOURCE[0]` — source file of the current function (or script if at top level).
- `BASH_SOURCE[N]` — source file of the function call at depth N.
- `FUNCNAME[N]` — function name at depth N (`FUNCNAME[0]` is current).
- `BASH_LINENO[N]` — line in the file at depth N+1 that called depth N.
- Self-location idiom: `lib_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")`.
- Library version compatibility checks via `BASH_SOURCE`.

## 9.12 Calling-convention discipline

Stylistic and architectural rules for clean function design.

- Pure functions: no globals, all input via parameters, output via stdout or namerefs.
- One return path or consistent return paths; no surprise exits.
- Document expected `$1`, `$2`, … in a comment or via `${1:?}` enforcement.
- Validate at boundary: top of function checks args; internals trust them.
- Avoid command substitution in tight loops (forks a subshell).
- Prefer namerefs when output is large; avoid for tiny scalars (overhead).
- Functions over inline complex logic; reuse over duplication.

# Part X — Sourcing, Libraries, and Modules

*Bash's `source` (alias `.`) is the primary mechanism for code reuse across scripts. This Part documents sourcing semantics and the conventions that make Bash libraries composable, distributable, and safe.*

---

---

## 10.1 `source` semantics

`source file` executes `file` in the current shell's context.

- Aliases: `.` (POSIX) and `source` (bash).
- File is searched along `PATH` if no slash in name (POSIX rule).
- All variable, function, and trap modifications persist in the calling shell.
- File need not be executable.
- `set -e` propagates into sourced file.
- `return` in sourced file at top level: terminates sourcing, returns to caller.
- `exit` in sourced file: exits the caller's shell.
- File arguments via `source file arg1 arg2` — set as positional parameters during sourcing.

## 10.2 The `BASH_SOURCE` array

Tracks the call chain of sourced files and function calls.

- `BASH_SOURCE[0]` — file of current execution context.
- `BASH_SOURCE[N]` — file at depth N in the call stack.
- Length: `${#BASH_SOURCE[@]}`.
- Top-level script: `BASH_SOURCE[0]` is the script.
- Sourced library: `BASH_SOURCE[0]` is the library file.
- Function within library: `BASH_SOURCE[0]` is still the library file (function carries its source).
- Pairs with `FUNCNAME[]` and `BASH_LINENO[]`.

## 10.3 Self-locating library pattern

The canonical pattern by which a library determines its own installation directory at runtime.

```bash
lib_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")
data_dir=$lib_dir/data
```

- Use `realpath` (not `readlink`) — see BCS-bash conventions.
- `dirname` on `${BASH_SOURCE[0]}` gives the library's directory.
- Resolves symlinks — important when installed via symlink.
- Must run at sourcing time (not call time) so it captures the library's location.
- Pitfall: running this inside a function captures the *file* — same answer either way for a single-file library, but matters for multi-file.

## 10.4 Idempotent sourcing guards

Prevents double-loading when multiple files source the same library.

```bash
[[ -n ${_MYLIB_LOADED:-} ]] && return
_MYLIB_LOADED=1
```

- Use a unique sentinel name per library.
- Place at top of library, before any work.
- Avoids duplicate function definitions, redundant variable initialisation.
- Combined with `set -e` exemption: `[[ ]] && return` is in `&&` context, so guard is exempt.

## 10.5 Namespace prefixes

Bash function names can include `::` and other characters, enabling namespacing.

- `mylib::function_name` is a valid function name.
- Avoids collision with other libraries.
- Convention: library prefix in lowercase, `::` separator.
- Equivalent: prefix with `_libname_` if `::` looks awkward.
- Variables: prefix with `MYLIB_` for globals.
- Local variables in functions need no namespacing.

## 10.6 Public vs private conventions

Distinguishing exported API from internal helpers.

- Public functions: bare names, documented in library header.
- Private functions: leading underscore (`_helper`).
- Documented only the public API; private functions may change without notice.
- Variables follow the same convention.
- BCS recommends explicit documentation in library header listing public names.

## 10.7 Version negotiation

Libraries should declare a version; callers should check it.

```bash
# In library
declare -r MYLIB_VERSION_MAJOR=2
declare -r MYLIB_VERSION_MINOR=1
declare -r MYLIB_VERSION=2.1.0

# In caller
if (( MYLIB_VERSION_MAJOR != 2 )); then
  die 1 "mylib version 2.x required, got $MYLIB_VERSION"
fi
```

- Semantic versioning recommended.
- Major version incompatibility → caller errors out.
- Minor version: backward-compatible additions; caller may check for features it needs.
- Use sentinel variables, not function-existence tests, for the version check itself.

## 10.8 Lazy and conditional loading

Loading libraries only when needed reduces startup cost.

- Lazy: source the library on first use of a feature.
- Conditional: source different libraries based on environment (`OS`, `BASH_VERSINFO`).
- Pitfall: lazy loading inside a function, but the loaded library defines globals — those globals are scoped to the function unless declared `-g`.
- Use `declare -g` for globals defined inside functions during lazy loading.

## 10.9 Cross-shell sourcing pitfalls

When a library might be sourced by both bash and sh.

- Detect bash: `[[ -n ${BASH_VERSION:-} ]]`.
- Avoid bashisms in sh-compatible code paths.
- Use POSIX-only constructs: `[ ]` instead of `[[ ]]`, no arrays, no namerefs, no `<<<`.
- Or: refuse to load: `[[ -z ${BASH_VERSION:-} ]] && { echo 'bash required' >&2; exit 1; }`.
- The sh-mode-of-bash trap: bash invoked as `sh` disables many features silently.

## 10.10 API design

Designing a library API that other people will use.

- Small public surface; large private substrate.
- Consistent naming across functions in the library.
- Standard parameter order (e.g., source before destination, or vice versa — but consistent).
- Use namerefs for output parameters; avoid mutating globals from public API.
- Document side effects (variables touched, files written, traps installed).
- Versioned: bump major on breaking changes.
- Idempotent: sourcing twice has the same effect as once.
- Fail predictably: clear error messages, consistent exit codes.

## 10.11 Distribution and installation

How Bash libraries are packaged and deployed.

- FHS layout: libraries in `/usr/share/PROJECT/lib/` or `/usr/local/share/PROJECT/lib/`.
- Per-user: `~/.local/share/PROJECT/lib/`.
- Discovery: scripts use FHS search path resolution (BCS pattern).
- Versioning files: `MYLIB_VERSION` constant in the library, plus a separate `VERSION` file at install root.
- Packaging: deb, rpm, tarball, git submodule, or copy-into-tree.
- Symlinks via `symlink -S` for PATH-exposed scripts.
- Pre-source vs source-on-demand trade-offs.

# Part XI — Process Management

*Bash sits at the intersection of the shell language and the Unix process model. This Part documents how Bash creates, tracks, signals, and manages processes — its own and its children.*

---

---

## 11.1 The Bash process tree at runtime

A running Bash script has a process tree shape determined by its constructs. This chapter maps construct → tree shape.

- Builtins: no fork. Run in current shell.
- External commands: fork+exec.
- Command substitution `$(…)`: fork.
- Process substitution `<(…)`, `>(…)`: fork.
- Pipelines `a | b`: fork per command (typically).
- Subshell `( … )`: fork.
- Background `&`: fork.
- Brace group `{ …; }`: no fork.
- Functions: no fork (run in current shell).
- `exec cmd`: replaces current shell, no fork.
- Inspection: `pstree -p $$` to see the tree from the script down.

## 11.2 PIDs: `$$`, `$BASHPID`, `$PPID`

Three variables, three different meanings.

- `$$` — PID of the script when invoked. Fixed for the script's lifetime, even in subshells.
- `$BASHPID` — PID of the current shell. Updates to the subshell PID inside a subshell.
- `$PPID` — parent PID of the script. Fixed.
- Use `$$` for "is this script still running" lockfile checks.
- Use `$BASHPID` when you need the actual PID of the current process (e.g., per-subshell tempdir).
- `$$` in subshell vs `$BASHPID` in subshell — different.
- Pitfall: subshell of subshell — `$$` still the original script's PID.

## 11.3 Subshell origins

Constructs that fork a subshell.

- `( … )` — explicit subshell.
- `$( … )` — command substitution.
- `<( … )`, `>( … )` — process substitution.
- `cmd1 | cmd2` — pipeline (at least one subshell, often both, depending on `lastpipe`).
- `cmd &` — background command.
- A function called from a subshell context runs in that subshell.
- Subshell inherits variables, fds, traps (with reset for non-EXIT signals).
- Subshell variable changes do not affect parent.

## 11.4 `BASH_SUBSHELL` depth tracking

Bash maintains a counter of subshell depth.

- 0 in the top-level script.
- Incremented on each fork into a subshell.
- Useful for "am I in a subshell?" detection.
- Library code can check `(( BASH_SUBSHELL == 0 ))` to refuse to run as a child.
- Reset (well, lower) when a subshell exits.
- Distinct from `SHLVL` which counts shell invocations (e.g., `bash` inside `bash`).

## 11.5 Foreground vs background

Bash distinguishes foreground commands (the shell waits for them) from background (started with `&`).

- `cmd` — foreground; shell waits for completion before reading next command.
- `cmd &` — background; shell continues immediately, `$!` set to backgrounded PID.
- Backgrounded jobs still write to script's stdout/stderr unless redirected.
- `wait` — wait for all backgrounded children.
- `wait $pid` — wait for a specific child.
- `wait -n` — wait for any child to exit.
- Backgrounded jobs may receive SIGHUP when shell exits, depending on `huponexit` shopt.

## 11.6 Process groups and sessions

The kernel groups processes into process groups and sessions for signal delivery and terminal control.

- Process group: set of processes that receive terminal-generated signals together.
- Session: collection of process groups sharing a controlling terminal.
- Each pipeline becomes a process group when job control is on.
- `setpgid(2)`, `setsid(2)`.
- `getpgrp(2)`, `getsid(2)`.
- `setsid` command: start a process in a new session, detached from controlling terminal.
- `tcsetpgrp` for foreground group selection.

## 11.7 The job table

When job control is on, bash maintains a table of jobs.

- Each pipeline started by the shell becomes a job.
- `jobs` builtin lists current jobs.
- Each job has a job number and a status (Running, Stopped, Done).
- Job control is on by default in interactive shells; off in non-interactive (overridable with `set -m`).
- Job table is per-shell; subshells have their own.

## 11.8 Job specifications

Jobs can be referenced by several syntaxes.

- `%N` — job number N.
- `%+` or `%%` — current job (most recent).
- `%-` — previous job.
- `%cmd` — job whose command starts with `cmd`.
- `%?str` — job whose command contains `str`.
- Used with `fg`, `bg`, `kill`, `wait`, `disown`.

## 11.9 Job-control builtins

Manipulate the job table.

- `jobs` — list jobs. `-l` adds PID; `-p` shows only PIDs; `-r` only running; `-s` only stopped; `-n` only changed.
- `fg [%spec]` — bring job to foreground.
- `bg [%spec]` — resume stopped job in background.
- `disown [%spec]` — remove from job table; `-h` retains in table but doesn't SIGHUP.
- `wait [%spec | $pid]` — wait for completion.
- `suspend` — suspend the shell itself (login shell refuses without `-f`).

## 11.10 `kill` and signal delivery

The `kill` builtin sends signals.

- `kill [-SIGNAL] PID` — default SIGTERM.
- `kill -l` — list signal numbers and names.
- `kill -SIGNAL %1` — send to job 1.
- `kill -0 PID` — test if PID exists (no signal sent).
- Signal can be name (`SIGTERM` or `TERM`), number (`15`), or shorthand.
- Negative PID: `-PID` sends to process group.
- `killall name` — by name (external command, not builtin).
- `pkill -SIGNAL pattern` — by name pattern (external).

## 11.11 `nohup` and `setsid`

Decoupling from the controlling terminal.

- `nohup cmd` — ignore SIGHUP, redirect stdout/stderr to `nohup.out` if not already redirected.
- `setsid cmd` — start in new session, fully detached.
- `disown` — remove from current shell's job table but keep running.
- `(cmd &)` in a subshell, then exit subshell — orphans the child.
- `daemonise` patterns: combine `setsid`, `cd /`, redirect fds, double-fork.

## 11.12 Detaching from the terminal

Comprehensive detachment for daemons.

- Steps: fork, parent exits; child calls `setsid`; child forks again, parent exits; child calls `chdir("/")`; child calls `umask(0)`; child closes fds 0/1/2 and reopens to `/dev/null` or log files.
- Bash equivalent: hard. Most "daemons" written in bash use `nohup ... &` plus `disown` plus redirection.
- For true daemonisation, prefer systemd unit files over bash daemonisation.

## 11.13 Environment inheritance

Children inherit the environment at fork+exec.

- Subshells: full inheritance, including variable changes made before the fork.
- Children via `cmd`: inherit only exported variables.
- Per-command export: `VAR=value cmd` exports VAR for cmd's environment only.
- `env -i cmd` — empty environment for cmd.
- `env VAR=value cmd` — augment environment for cmd.
- Environment size limit: `ARG_MAX` (typically 2 MB on Linux).

# Part XII — Signals and Traps

*Signals are bash's primary mechanism for asynchronous communication and lifecycle hooks. This Part documents the signal catalogue, the trap builtin, the pseudo-signals, and the discipline required to write signal-safe code.*

---

---

## 12.1 Signal taxonomy

Signals fall into broad functional categories.

- Termination: SIGTERM, SIGINT, SIGQUIT, SIGKILL.
- Stop / continue: SIGSTOP, SIGTSTP, SIGCONT.
- Errors: SIGSEGV, SIGBUS, SIGILL, SIGFPE.
- Communication: SIGUSR1, SIGUSR2, SIGHUP, SIGPIPE.
- Children: SIGCHLD.
- Resources: SIGXCPU, SIGXFSZ.
- Alarms: SIGALRM, SIGVTALRM, SIGPROF.
- Real-time: SIGRTMIN..SIGRTMAX (queued, prioritised).
- Window change: SIGWINCH.

## 12.2 Signal numbers and names

The mapping is platform-specific but stable on Linux. Full table in Appendix K.

- `kill -l` lists all signals known to bash.
- Names: with or without `SIG` prefix (`SIGTERM` and `TERM` both work).
- Numbers: stable on Linux.
- Real-time signals: `SIGRTMIN+N` and `SIGRTMAX-N` syntax.
- POSIX requires SIGHUP=1, SIGINT=2, SIGQUIT=3, SIGILL=4, SIGTRAP=5, SIGABRT=6.

## 12.3 Uncatchable signals

Two signals cannot be caught, blocked, or ignored.

- SIGKILL — kill the process unconditionally.
- SIGSTOP — stop the process unconditionally.
- SIGCONT — cannot be blocked (but can be caught).
- All others can be trapped.
- Implication: cleanup traps cannot run on `kill -9`. For critical cleanup, prefer SIGTERM and ensure the parent uses it.

## 12.4 Signal disposition

Each signal has one of four dispositions per process.

- Default — kernel's default action (terminate, ignore, stop, continue).
- Ignored — discarded by the kernel.
- Caught — handler function runs.
- Blocked — held pending until unblocked.
- Bash sets handlers via `trap`; ignored signals via `trap '' SIGNAL`; reset to default via `trap - SIGNAL`.
- Inherited from parent at fork; reset on exec to default for caught signals.

## 12.5 The `trap` builtin

Registers handler commands for signals and pseudo-signals.

- `trap 'commands' SIGNAL [SIGNAL …]` — install handler.
- `trap '' SIGNAL` — ignore.
- `trap - SIGNAL` — reset to default.
- `trap` (no args) or `trap -p` — list current traps.
- `trap -l` — list signal names and numbers.
- Multiple signals: one trap, comma-separated or repeated arg.
- Handler is a string evaluated in the shell's context — full expansion at signal time.
- Pre-evaluation pitfall: `trap "echo $var" EXIT` captures `$var`'s value at trap-set time; use `trap 'echo $var' EXIT` (single quotes) for signal-time expansion.

## 12.6 Pseudo-signals: EXIT, ERR, DEBUG, RETURN

Bash extends signals with four pseudo-signals tied to script lifecycle events.

- `EXIT` — fires when the shell exits, by any means short of SIGKILL.
- `ERR` — fires whenever a command exits non-zero (under same conditions as `set -e`).
- `DEBUG` — fires before each simple command.
- `RETURN` — fires when a function returns or sourced script completes.
- Each can have its own trap; combine with regular signals freely.
- `BASH_COMMAND` available in DEBUG/ERR traps — the command about to run / that just failed.

## 12.7 `trap -p` and trap inspection

Listing the current trap state.

- `trap -p` — print all traps in re-eval-able format.
- `trap -p SIGNAL` — print trap for one signal.
- `declare -p` does not show traps.
- Useful for debugging "why didn't my trap fire" — verify it's installed.

## 12.8 Trap inheritance

Subshells reset most traps; functions inherit unless `set -E`/`set -T`.

- Subshells inherit ignored signals; reset caught signals to default (so the subshell's parent can re-install).
- Exception: EXIT, ERR, DEBUG, RETURN traps are reset in subshells unless...
- `set -E` (errtrace) — ERR trap inherited by functions, command substitutions, and subshells.
- `set -T` (functrace) — DEBUG and RETURN traps inherited by functions, command substitutions, and subshells.
- The `extdebug` shopt enables additional inheritance and inspection.

## 12.9 Trap reset across `exec`

On `exec`, signal handlers are reset (POSIX requirement).

- Handlers installed by bash via `trap` become default in the new program.
- Ignored signals remain ignored (this is a kernel guarantee).
- Implication: a child program cannot inherit your bash trap function.

## 12.10 Synchronous vs asynchronous delivery

Bash delivers signals between commands, not mid-command.

- Synchronous signals (SIGSEGV, SIGFPE) are delivered immediately when raised by the process itself.
- Asynchronous signals (SIGINT, SIGTERM) are queued by bash and delivered when the next foreground builtin completes or the next external command would start.
- Long-running external commands deliver signals to themselves; bash delivers to children when the child exits.
- This is why `trap 'cleanup' INT` does not interrupt a `sleep 1000` until the sleep ends — bash is itself in `wait()`, the kernel kills the sleep, bash returns from wait, then runs the trap.

## 12.11 Signal-safe code

Within a trap handler, certain operations are unsafe.

- Avoid `read` — handler can race against pending I/O.
- Avoid `wait` — can deadlock if signal arrives during wait.
- Avoid commands that themselves may receive the same signal.
- Keep handlers short; ideally just set a flag and return.
- Signal delivery during handler execution: bash may queue or coalesce.
- Re-installing the trap inside the handler: not necessary in bash (unlike POSIX C).

## 12.12 Idempotent cleanup patterns

Traps that must run at most once and produce the same effect on every invocation.

- Use a sentinel: `[[ -n ${_CLEANED:-} ]] && return; _CLEANED=1`.
- Or use unset-on-first-run: at start of cleanup, `trap - EXIT INT TERM` to disable further invocations.
- Multiple signals to one handler: `trap cleanup EXIT INT TERM` — fires on any.
- The handler should tolerate being called from any signal or from EXIT.
- Resource-by-resource cleanup with individual existence checks: `[[ -d $tmpdir ]] && rm -rf -- "$tmpdir"`.

## 12.13 Tempfile and tempdir lifecycle

The canonical pattern for safe temporary storage.

```bash
tmpdir=$(mktemp -d -t myscript-XXXXXX) || die 1 "mktemp failed"
trap 'rm -rf -- "$tmpdir"' EXIT
```

- `mktemp -d` for directories; `mktemp` for files.
- `-t TEMPLATE` with at least 6 X's.
- `TMPDIR` honoured; defaults to `/tmp`.
- The trap fires on any exit; cleanup is automatic.
- Multiple tempdirs: keep them in an array, loop in cleanup.
- Lock the directory if needed (§12.14).

## 12.14 Lockfile pattern

Mutual exclusion across script invocations.

```bash
exec 9>"$lockfile"
flock -n 9 || die 1 "another instance is running"
```

- `flock` builtin (in `util-linux`) takes an fd and an exclusion mode.
- `-n` non-blocking; `-w N` wait up to N seconds; default block.
- `-x` exclusive (default); `-s` shared.
- The lock is held while fd 9 is open; closing fd 9 releases it.
- The lockfile itself need not be removed; flock is on the open file description.
- Pitfall: `flock $lockfile cmd` is a separate invocation; the `exec 9>` form holds the lock for the script's lifetime.

## 12.15 Atomic file write

Write to a sibling tempfile, then rename.

```bash
tmp=$(mktemp -- "${target}.XXXXXX") || die 5 "mktemp failed"
write_data > "$tmp"
mv -- "$tmp" "$target"
```

- `mv` within the same filesystem is atomic (rename(2) syscall).
- Readers either see the old version or the new — never partial.
- Add `sync` between write and mv if durability matters across reboot.
- Cross-filesystem: `mv` is copy+delete, NOT atomic; use a per-FS staging dir.
- Combine with EXIT trap to clean up the tmpfile on failure.

## 12.16 Reload-on-SIGHUP

Convention: SIGHUP requests "reload your config".

```bash
reload_config() {
  source -- "$config_file"
  info 'config reloaded'
}
trap reload_config HUP
```

- Convention only; no kernel enforcement.
- Long-running daemons should support it.
- Race: signal can arrive during reload. Use a flag-and-defer pattern.
- Equivalent for `nginx`, `apache`, etc. — bash daemons should match the convention.

# Part XIII — Error Handling and Exit Status

*Bash's error-handling semantics are notoriously subtle. `set -e` does not mean "exit on any error" — it means "exit on any error in one of N specific contexts, with M specific exemptions". This Part documents the full semantics and the strict-mode discipline that makes them predictable.*

---

---

## 13.1 Exit status fundamentals

Every command produces an 8-bit exit status. Bash exposes it as `$?` and uses it for control-flow decisions.

- Range: 0–255.
- 0 = success; non-zero = failure.
- 128 + N = killed by signal N.
- `$?` reflects the last *foreground* command.
- Pipelines: `$?` is the last command's status (without `pipefail`) or the rightmost non-zero (with).
- Functions return their last command's status, or `return N`.
- Sourced scripts return their last command's status, or `return N`.
- `exit N` masks `N` to `N % 256`.

## 13.2 `set -e` (errexit) — full semantics

Exit on any non-zero command status, except in the exemption matrix (§13.3).

- Equivalent: `set -o errexit`.
- Triggered when a command exits non-zero and is not in an exempt context.
- The command must be a "simple command" or a pipeline (subject to the pipeline rules).
- Exit status of the failing command propagates to script exit.
- ERR trap fires before exit (§13.8).
- `set +e` to disable temporarily.
- Inheritance: `inherit_errexit` controls propagation into command substitutions.

## 13.3 The errexit exemption matrix

Contexts in which `set -e` does *not* fire on failure. Memorise this list — it is the single largest source of "set -e didn't trigger" complaints.

- Left side of `&&` or `||`: `false && true` does not exit.
- Condition of `if`, `while`, `until`: `if false; then …` does not exit.
- Negated command: `! false` does not exit.
- Command in a pipeline that is not the last: `false | true` does not exit (without `pipefail`).
- A function whose last command's failure is in one of the above contexts.
- Command substitution `$(…)`: failures are not propagated (without `inherit_errexit`).
- Subshells in a pipeline that's not the last.
- `(( expression ))` evaluating to zero — counts as failure (gotcha for `((count++))` when count starts at 0).
- `let` expression evaluating to zero — same.

## 13.4 `set -u` (nounset)

Treat references to unset variables as errors.

- Equivalent: `set -o nounset`.
- Reading an unset variable: error and exit (or trigger ERR trap).
- Exception: `${var:-default}` and `${var-default}` are not errors even if unset.
- Exception: `$@` and `$*` are not errors when there are no positional parameters.
- Pitfall: `${arr[@]}` on an unset array errors; use `${arr[@]:-}` to be safe.
- BCS pattern: declare every variable with `declare` or `local` before use.

## 13.5 `set -o pipefail`

Make a pipeline's exit status the rightmost non-zero status.

- Without pipefail: `false | true` returns 0.
- With pipefail: `false | true` returns 1.
- All-success pipeline returns 0.
- Combined with `set -e`: any pipeline failure exits.
- `PIPESTATUS[]` always available regardless of pipefail.
- The rightmost-non-zero rule is sometimes counter-intuitive; for "first failure", read `PIPESTATUS[]` manually.

## 13.6 `inherit_errexit`

`shopt -s inherit_errexit` makes command substitutions inherit `errexit` from the parent.

- Bash 4.4+.
- Without it: `result=$(grep foo file)` does not exit on grep failure even with `set -e`.
- With it: command substitutions exit on internal failures.
- Required for fully strict scripts.
- Combined with `set -e -u -o pipefail` and `inherit_errexit` is the BCS strict-mode contract.

## 13.7 `||:` and `|| true` idioms

Two equivalent idioms for "I expected this to potentially fail and I don't care".

- `cmd || true` — explicit, readable.
- `cmd ||:` — compact (`:` is the null command, returns 0).
- Use after every command where failure is acceptable.
- Discriminate from "always succeed" (suppress errors): if you actually need to handle failure, use `if ! cmd; then handle; fi` instead.
- Pitfall: `cmd && other_cmd ||:` does not protect `other_cmd` (the `||:` applies to the AND-OR list as a whole).

## 13.8 The `ERR` trap

Fires whenever a command would cause `set -e` to exit. Useful for diagnostics.

```bash
on_err() {
  local rc=$? line=$1
  error "command failed at line $line with exit $rc"
}
trap 'on_err $LINENO' ERR
```

- Available variables in trap: `$?`, `$BASH_COMMAND`, `$LINENO`, `BASH_LINENO[]`, `FUNCNAME[]`, `BASH_SOURCE[]`.
- Pass `$LINENO` as a positional via `'on_err $LINENO'` so the trap captures the line where the error occurred.
- Combine with stack-trace function for rich error reporting (§13.12).

## 13.9 `errtrace` and trap inheritance

`set -E` (alias `set -o errtrace`) propagates ERR trap to functions, command substitutions, and subshells.

- Default: ERR trap is reset in functions and subshells.
- With `errtrace`: ERR trap is inherited.
- Required for ERR trap to fire on errors inside library functions.
- `set -T` (functrace) does the same for DEBUG and RETURN traps.
- Strict-mode scripts often use `set -eET -o pipefail` plus `inherit_errexit`.

## 13.10 Exit code conventions

Standardised exit codes that callers can interpret.

- 0 — success.
- 1 — generic error.
- 2 — usage error (BSD convention; argued).
- 64–113 — `sysexits.h` (`EX_USAGE`=64, `EX_DATAERR`=65, `EX_NOINPUT`=66, etc.).
- 126 — found but not executable.
- 127 — command not found.
- 128 + N — killed by signal N.
- BCS codes: 1, 2, 3 (not found), 5 (I/O), 13 (perm), 18 (missing dep), 22 (invalid arg), 24 (timeout).
- Choose a convention and document it; consistency is more important than which convention.

## 13.11 Propagating exit codes

How to ensure a function's failure surfaces to the caller and how to capture it cleanly.

- Functions return their last command's status implicitly.
- Explicit: `return $?` after the call you want to propagate.
- Pipelines: capture with `local rc=${PIPESTATUS[0]}` immediately after.
- Background jobs: `wait $pid; rc=$?`.
- Subshells: subshell's `exit N` becomes the subshell's exit, captured by `$?` in parent.
- Through `||`: the OR side may need to re-emit: `cmd || { rc=$?; cleanup; return $rc; }`.

## 13.12 Rich error output

Producing diagnostics that help debugging.

```bash
bash_stack() {
  local i frame
  for ((i = 1; i < ${#FUNCNAME[@]}; i++)); do
    frame="${FUNCNAME[i]} (${BASH_SOURCE[i]}:${BASH_LINENO[i-1]})"
    printf '  at %s\n' "$frame" >&2
  done
}

on_err() {
  local rc=$? line=$1
  error "command failed (rc=$rc) at line $line: $BASH_COMMAND"
  bash_stack
}
trap 'on_err $LINENO' ERR
```

- `FUNCNAME[]`, `BASH_SOURCE[]`, `BASH_LINENO[]` arrays — the call stack.
- Walk index 1 to N (index 0 is the trap itself).
- Include `BASH_COMMAND` for the failing command text.
- Include `$?` for the exit status.
- Optional: include process state (`$$`, `$BASHPID`, `$PPID`).
- Format consistently for log parsing.

# Part XIV — Input, Output, and Messaging

*Bash's I/O builtins (`read`, `printf`, `mapfile`) and the disciplines around them. The cardinal rule: stdout is data, stderr is diagnostics; never mix them.*

---

---

## 14.1 Standard streams discipline

The convention that distinguishes a composable script from a broken one.

- stdout (fd 1) — the script's *data output*, the thing a downstream pipe consumes.
- stderr (fd 2) — *diagnostics*: info, warn, error, debug, progress.
- Mixing the two destroys composability.
- A script that emits no data to stdout is fine (returns success or failure via exit code).
- A script that emits diagnostics to stdout breaks pipelines.
- Always `>&2` for diagnostics; never bare `echo` or `printf` for them.

## 14.2 The `read` builtin

Read input from stdin (or a specified fd) into one or more variables.

- `read var` — single variable; field-splits on IFS.
- `read var1 var2 var3` — multiple; last variable gets the remainder.
- `read -r` — raw mode; do not interpret backslash escapes (almost always wanted).
- `read -d DELIM` — read until DELIM character instead of newline.
- `read -d ''` — read until NUL; pairs with `find -print0`.
- `read -p PROMPT` — interactive prompt to stderr.
- `read -t TIMEOUT` — timeout in seconds (fractional in Bash 4.0+).
- `read -n N` — read at most N characters.
- `read -N N` — read exactly N characters.
- `read -u FD` — read from a specific fd.
- `read -e` — use readline (interactive only).
- `read -i TEXT` — pre-fill the line with TEXT (with `-e`).
- `read -s` — silent (no echo, for password prompts).
- `read -a arr` — read into an indexed array, splitting on IFS.
- BCS rule: always `read -r` for safety; specify timeouts where appropriate.

## 14.3 `mapfile` / `readarray`

Read all of stdin (or fd) into an array, one line per element.

- `mapfile -t arr < file` — strip trailing newline (`-t`).
- `readarray` is an alias for `mapfile`.
- `-d DELIM` — use DELIM instead of newline as separator (Bash 4.4+).
- `-d ''` — NUL-separated input; pairs with `find -print0`.
- `-n N` — read at most N elements.
- `-O ORIGIN` — start storing at index ORIGIN.
- `-s SKIP` — discard first SKIP elements.
- `-c COUNT -C CALLBACK` — call CALLBACK every COUNT elements (rare).
- `-u FD` — read from fd FD.
- Faster and safer than `while IFS= read -r line; do arr+=("$line"); done`.

## 14.4 The `printf` builtin

Formatted output. Always preferred over `echo`.

- `printf 'format' arg1 arg2 …`.
- Format string is reused for additional args: `printf '%s\n' a b c` prints three lines.
- Specifiers: `%s`, `%d`, `%i`, `%u`, `%o`, `%x`, `%X`, `%c`, `%b`, `%q`, `%(fmt)T`.
- `%b` — interpret `\` escapes in the argument.
- `%q` — quote the argument for re-input to shell.
- `%(fmt)T` — format a Unix timestamp; `-1` is current time, `-2` is shell start.
- `printf -v VAR 'format' args` — store result in VAR instead of stdout.
- Width and precision: `%-10s`, `%05d`, `%.3f`.
- Width via argument: `%*s` (Bash 4.0+).

## 14.5 `printf` vs `echo`

`echo` is unsafe in scripts. `printf` is the universal answer.

- `echo` interprets `-n`, `-e`, `-E` flags inconsistently across shells and `echo` versions.
- `echo "$var"` may print `-e` if `$var` is `-e`.
- `echo` cannot reliably emit text containing a leading `-`.
- `echo` line termination is fixed (or controlled by flags).
- `printf '%s\n' "$var"` always works.
- Memorise: `printf '%s\n' "$var"` for a line; `printf '%s' "$var"` without newline; `printf '%s\0' "$var"` for NUL-terminated.

## 14.6 Format specifiers

Detailed reference.

- `%d`, `%i` — signed integer.
- `%u` — unsigned integer.
- `%o` — octal.
- `%x`, `%X` — hex (lower/upper).
- `%e`, `%E` — scientific.
- `%f`, `%F` — fixed-point float.
- `%g`, `%G` — auto-format float.
- `%c` — single character.
- `%s` — string.
- `%b` — string with `\` escapes interpreted.
- `%q` — shell-quoted string.
- `%n$X` — positional argument N (Bash 4.0+).
- `%(fmt)T` — date/time.
- Flags: `-` left-align, `+` always sign, ` ` space-pad sign, `#` alternate, `0` zero-pad.

## 14.7 Logging discipline

Conventions for diagnostic output.

- Single message helper that dispatches by FUNCNAME (BCS pattern).
- Always to stderr.
- Timestamp where relevant: `printf '[%(...)T] %s\n' -1 "$msg" >&2`.
- Script name: `[%s]` prefix with `$SCRIPT_NAME`.
- Severity: include level token in output.
- Quiet mode: `info()` respects `$VERBOSE`; `warn()` and `error()` always show.
- Exit on error: `die()` writes message and exits with given code.

## 14.8 Log levels

Standard severity hierarchy.

- DEBUG — detailed trace, off by default.
- INFO — normal operational message.
- WARN — concerning but not failing.
- ERROR — failed operation.
- FATAL — failed and exiting.
- BCS aliases: `info`, `success`, `warn`, `error`, `die`.
- Filter via verbosity flag: `-q` (quiet), `-v` (verbose), `-vv` (debug).
- Structured logging: emit JSON or key=value for downstream parsing.

## 14.9 Coloured output and TERM detection

Coloured terminals improve readability; piped or non-TTY targets should not see escape codes.

- Detect TTY: `[[ -t 1 ]]`.
- Detect colour support: `[[ -t 1 && -n ${TERM:-} && $TERM != dumb ]]`.
- Better: `tput setaf N` for colour N from terminfo.
- ANSI escape codes: `\033[31m` red, `\033[32m` green, `\033[33m` yellow, `\033[0m` reset.
- BCS pattern: define `RED`, `GREEN`, `YELLOW`, `RESET` variables, set to escape codes if TTY else empty.
- 256-colour and 24-bit colour: terminal-dependent.
- Don't colour log files — disable colours when output is redirected.

## 14.10 Progress indicators

Long-running tasks benefit from progress feedback.

- Spinner: rotate `|/-\` characters with `\r` carriage return.
- Percentage: `printf '\r[%3d%%]' "$pct"`.
- Bar: build from `#` and ` ` of length proportional to progress.
- Library: `pv` for pipe progress; `dialog`/`whiptail` for richer UI.
- Disable when `-q` or non-TTY.
- Always end with newline when done.

## 14.11 Reading binary data

Bash is byte-oriented but treats NUL specially. Reading binary requires care.

- Bash strings cannot contain NUL bytes.
- `read -d ''` reads until NUL (the NUL itself is the delimiter).
- `mapfile -d ''` reads NUL-separated chunks into array.
- For binary processing, prefer external tools: `xxd`, `od`, `hexdump`, `dd`.
- Reading raw bytes into a variable: `IFS= read -r -n N var` (loses NULs).
- Best practice: don't process binary in bash; shell out to a tool.

## 14.12 File locking for concurrent writes

Multiple processes writing to the same file: lock or interleave.

- `flock` for advisory locking (§12.14).
- Append-only with O_APPEND: kernel guarantees atomicity for writes ≤ PIPE_BUF (typically 4096 bytes).
- Bash uses `>>` which sets O_APPEND.
- Writes larger than PIPE_BUF may interleave even with O_APPEND.
- For larger atomic writes, lock around the write.
- Log files: rely on small-write atomicity; rotate carefully.

# Part XV — Command-Line Processing

*Parsing command-line arguments is the most-reused piece of code in Bash scripts. This Part documents the conventions and the canonical patterns: getopts, hand-rolled parsing, GNU getopt, and subcommand dispatch.*

---

---

## 15.1 CLI conventions

Conventions for command-line interfaces that bash scripts should follow.

- Short options: `-x`, single character, may take a value (`-fname` or `-f name`).
- Long options: `--long`, may take a value (`--file=name` or `--file name`).
- Bundled short: `-abc` is `-a -b -c` (each must be flag-only).
- `--` terminates options; everything after is positional.
- `-` alone is conventionally "stdin" or "stdout".
- Help: `-h` or `--help`.
- Version: `-V` or `--version`.
- Verbose: `-v` or `--verbose`; `-q` or `--quiet`.
- Dry-run: `-n` or `--dry-run`.
- Standard exit codes (§13.10).

## 15.2 `getopts` builtin

POSIX shell builtin for short-option parsing.

- Syntax: `getopts OPTSTRING name [args]`.
- OPTSTRING: each char is an option; `:` after means takes value.
- Leading `:` in OPTSTRING enables silent error mode.
- `OPTIND` — index of next argument to process; reset to 1 between invocations.
- `OPTARG` — value of option requiring a value.
- Limitations: no long options; one-char options only; no value-validation hooks.
- Use case: minimal POSIX-compatible scripts.

## 15.3 GNU `getopt(1)` external

The external GNU `getopt` parses both short and long options.

- Syntax: `getopt -o SHORT -l LONG -- "$@"`.
- Output: requoted command line; eval into `set --`.
- Pitfall: not all systems have GNU getopt; BSD has a different `getopt` with no long-option support.
- Pitfall: requires `eval` of output; quoting tricky.
- Generally not preferred in BCS-compliant scripts.

## 15.4 Hand-rolled `while case shift`

The BCS canonical pattern. Handles long-with-equals, bundled short, end-of-options.

```bash
parse_args() {
  while (($#)); do
    case $1 in
      -h|--help)        usage; return 0 ;;
      -v|--verbose)     VERBOSE=1 ;;
      -q|--quiet)       VERBOSE=0 ;;
      -n|--dry-run)     DRY_RUN=1 ;;
      -f|--file)        shift; noarg "$@"; FILE=$1 ;;
      --file=*)         FILE=${1#*=} ;;
      -[abc]?*)         set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)               shift; POSITIONAL+=("$@"); break ;;
      -*)               die 22 "unknown option: $1" ;;
      *)                POSITIONAL+=("$1") ;;
    esac
    shift
  done
}
```

- `noarg "$@"` — BCS helper; errors if next arg missing or begins with `-`.
- Bundled short expansion: `-[abc]?*` means a recognised short followed by more chars; expand to two args and continue.
- `--*=*` for long-with-equals; `--*` for long without.
- `--` ends options; positionals follow.
- Catch-all `-*` for unknown options.
- Catch-all `*` for positionals.
- See BCS-bash/04_OPTIONS.md and BCS §08.

## 15.5 Long options

Two equivalent forms.

- Space-separated: `--file value` — handled in `case` as `--file)` with `shift; noarg`.
- Equals: `--file=value` — handled as `--file=*)` with `${1#*=}`.
- Either both forms or only one; consistency.
- Documentation should show both forms.

## 15.6 Bundled short options

Combining multiple short flags into one argument.

- `-abc` parsed as `-a -b -c`.
- Implementation: detect `-XY...` pattern; split to `-X` and `-Y...`.
- Bash idiom: `set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue`.
- Only flags can be bundled (no value-taking options in middle).
- Last bundled may take a value: `-abco file` could be `-a -b -c -o file` (BCS does not bundle value-takers).

## 15.7 `--` end-of-options

Standard convention for ending option processing.

- Everything after `--` is treated as positional, even if it starts with `-`.
- Essential for filenames starting with `-` (e.g., `-rf`).
- Implementation: `case --) shift; POSITIONAL+=("$@"); break ;;`.
- Pass through to children: `cmd -- "$@"` ensures children receive your positionals as positionals.

## 15.8 Subcommand dispatch

Multi-command CLIs (like `git`) dispatch a subcommand to a handler function.

```bash
case ${1:-} in
  init)    shift; cmd_init "$@" ;;
  build)   shift; cmd_build "$@" ;;
  deploy)  shift; cmd_deploy "$@" ;;
  help)    shift; cmd_help "$@" ;;
  ''|-h|--help)  usage; exit 0 ;;
  *)       die 22 "unknown subcommand: $1" ;;
esac
```

- One function per subcommand: `cmd_NAME`.
- Each subcommand parses its own options.
- Top-level options (before subcommand) parsed separately.
- Help: per-subcommand `show_NAME_help`.
- `bcs` itself uses this pattern (§ "Subcommand Dispatcher" in CLAUDE.md).

## 15.9 Help text conventions

Conventions for `--help` output.

- Usage line: `Usage: name [OPTIONS] [ARGS]`.
- Brief description.
- Options block: `-x, --long DESC` indented two spaces, aligned.
- Examples block: at least one realistic example.
- Exit codes block (if non-trivial).
- See also: pointer to man page, related commands, project URL.
- Width: 80 columns or current terminal width.

## 15.10 Synopsis grammar

Notation for documenting CLI syntax.

- `[X]` — optional.
- `X|Y` — choice.
- `X...` — one or more.
- `[X...]` — zero or more.
- Uppercase: placeholder; lowercase: literal.
- Example: `cmd [-v] [-f FILE] {init|build|deploy} [ARGS...]`.
- Match the man-page convention for consistency.

## 15.11 Auto-generating usage

Maintaining usage in sync with parser.

- Single source of truth: define options once.
- Generate usage from a structured spec (associative array, here-doc).
- Heredoc with placeholders: `cat <<EOF` … `EOF`.
- Pitfall: usage drift when adding new options without updating the help.
- Tests: `cmd --help | grep -F -- '--new-option'` ensures help stays in sync.

# Part XVI — Concurrency and Parallelism

*Bash supports background jobs, wait-for-any, bounded fan-out, and external parallelism tools. This Part documents the patterns and the pitfalls.*

---

---

## 16.1 Sequential vs background execution

- `cmd` — foreground, blocks until completion.
- `cmd &` — background, returns immediately, sets `$!`.
- `cmd &` plus `wait $!` — equivalent to `cmd` (foreground).
- Multiple `&` followed by `wait` — parallel fan-out.
- Background's stdout/stderr go to script's, mingled — usually want to redirect.

## 16.2 `wait` and `wait -n`

Wait for child processes.

- `wait` — wait for all children.
- `wait $pid` — wait for specific child; `$?` is that child's exit status.
- `wait -n` — wait for any child to exit (Bash 4.3+); `$?` is exited child's status.
- `wait -n $pid1 $pid2 …` — wait for any of these specific children (Bash 5.1+).
- `wait -p VAR -n` — store the PID of the exited child in VAR (Bash 5.1+).
- Without children: returns 127.

## 16.3 `wait $pid` for specific child

Capture per-child exit status.

```bash
sleep 1 & pid1=$!
sleep 2 & pid2=$!
wait $pid1; rc1=$?
wait $pid2; rc2=$?
```

- After waiting, status accessible via `$?` or saved variable.
- `wait` on a PID that's already been reaped returns its remembered status (bash keeps a small cache).
- Order doesn't matter for capturing — wait blocks until that child exits.

## 16.4 Capturing per-child exit status

Patterns for collecting status from many children.

- Loop: `for pid in "${pids[@]}"; do wait "$pid" || rc=$?; done`.
- Per-child status into array: `wait $pid; status[$i]=$?`.
- Aggregate: any non-zero → script fails.
- Per-child timeout: `timeout` command around the child.

## 16.5 Bounded-concurrency fan-out

Run N tasks in parallel with a cap on concurrent jobs.

```bash
max=4
pids=()
for task in "${tasks[@]}"; do
  while (( ${#pids[@]} >= max )); do
    wait -n -p done_pid
    pids=("${pids[@]/$done_pid}")
  done
  do_task "$task" &
  pids+=($!)
done
wait
```

- `wait -n -p done_pid` returns the PID of the next-finished child.
- Remove the PID from the tracking array.
- `wait` at the end ensures everything completes.
- Alternative: GNU `parallel -j N` — external dep but battle-tested.

## 16.6 The job table under concurrency

When job control is on, jobs are tracked.

- Non-interactive bash: job control off by default. `jobs` returns empty.
- Override: `set -m` to enable job control in non-interactive.
- Each backgrounded process is a job in interactive shells.
- Pipelines as a unit: one job per pipeline.

## 16.7 `xargs -P`

External tool for parallel one-shot work.

- `xargs -P N -I {} cmd {}` — run N parallel.
- Reads work items from stdin.
- `-n N` — N items per invocation.
- `-0` — NUL-separated input; pairs with `find -print0`.
- Exit status: 123 if any invocation failed (1-125); 124 if killed by signal.
- Use case: per-file processing where each file's command is independent.

## 16.8 GNU parallel

Richer parallel execution tool.

- `parallel cmd ::: arg1 arg2 …` — explicit args.
- `parallel -j N` — concurrency.
- `parallel --joblog FILE` — per-job log.
- `parallel --resume` — pick up where previous run left off.
- External dependency; not always installed.
- Heavier than `xargs -P` but more capable.

## 16.9 Race conditions in shell

Common races and how to avoid them.

- Test-then-act: `[[ -f $f ]] && rm $f` — file might be created/deleted between test and action.
- Lock-then-do: `flock` for serialisation.
- Tempfile races: `mktemp` is safe; `tempfile` is not on all systems.
- Symlink races: `ln -sf` on a directory traversal — attacker substitutes target.
- Signal-during-handler: signals queued.
- Solution: `flock`, atomic operations, kernel-level guarantees.

## 16.10 Locking primitives

Choosing the right lock.

- `flock` — fd-based advisory lock; cleanest.
- `mkdir LOCK` — directory creation is atomic; remove on cleanup.
- `lockfile` (procmail) — older alternative.
- `O_EXCL | O_CREAT` via `noclobber`: `set -C; > LOCK || die 'locked'; set +C`.
- Persistence: lockfile that survives crashes can deadlock; use PID-bearing lockfile and check with `kill -0`.
- Per-resource locks: lock the resource itself, not a separate file.

## 16.11 Signal handling under concurrency

Signal delivery with multiple children is subtle.

- Foreground process group receives terminal signals.
- Background children: do not receive Ctrl-C unless they trap it.
- `kill 0` sends to entire process group.
- Trap pattern: forward signal to children, then wait for cleanup.
- Pitfall: trap in parent doesn't affect children unless they trap independently.

## 16.12 Queue patterns

Producer-consumer in shell.

- File-as-queue: append items to a file; consumer reads with lock.
- FIFO-as-queue: `mkfifo Q; producer > Q & consumer < Q`.
- Process-substitution queue: `consumer < <(producer)`.
- Multiple consumers from a FIFO: works, but order non-deterministic.
- Persistent queue with crash recovery: not bash's wheelhouse — use a real queue (Redis, RabbitMQ).

# Part XVII — Coprocesses and IPC

*Inter-process communication primitives available to bash scripts: coprocesses, FIFOs, anonymous pipes, network sockets via `/dev/tcp`, and shared memory via `/dev/shm`.*

---

---

## 17.1 The `coproc` builtin

Starts a process with a bidirectional pipe to it.

- Syntax: `coproc NAME { commands; }` or `coproc NAME command`.
- Default name: `COPROC`.
- Creates an array NAME with two fds: `${NAME[0]}` to read from coproc's stdout, `${NAME[1]}` to write to coproc's stdin.
- The coproc's PID is in `NAME_PID`.
- Bash 4.0+.
- `coproc` without name and with a simple command uses `COPROC` and `COPROC_PID`.
- Restrictions in older bash: only one coproc at a time (Bash 4.x); 5.x lifted this.

## 17.2 Bidirectional fd pairs

The pattern of using a coproc as a persistent worker.

```bash
coproc BC { bc -l; }
echo '3.14 * 2' >&"${BC[1]}"
read -r result <&"${BC[0]}"
```

- Write to `${BC[1]}` to send input.
- Read from `${BC[0]}` to receive output.
- Persistent: the bc process stays alive across calls.
- Faster than forking bc per request.
- Beware buffering: bc auto-flushes; other tools may not (use `stdbuf -oL`).

## 17.3 Multiple coprocesses

Running several coprocs simultaneously.

- Bash 4.4+: multiple coprocs allowed.
- Each gets its own NAME and PID variable.
- Manage fd lifetimes carefully — close when done.
- Use case: pool of workers, each consuming from the same input and producing to different sinks.

## 17.4 Named pipes (FIFOs)

`mkfifo` creates a named pipe — a persistent file-system entity that two processes use for one-way communication.

- `mkfifo FIFO` — creates the FIFO file.
- `cmd1 > FIFO &` — writer (blocks until a reader opens it).
- `cmd2 < FIFO` — reader.
- Both ends must open before either side proceeds.
- Bidirectional: open two FIFOs.
- Cleanup: `rm FIFO` after use.
- Use case: cross-script communication when parents and children don't share a parent-child relationship.

## 17.5 Anonymous pipes

`a | b` creates an anonymous pipe — kernel-allocated, no filesystem entity.

- Parent and child only; cannot be opened by unrelated processes.
- Auto-cleanup on close.
- Half-closed: writer continues until close; reader sees EOF.
- SIGPIPE on write to closed reader (default action: terminate).
- Pipeline subshell semantics (§6.13).

## 17.6 `/dev/tcp` and `/dev/udp`

Bash-synthesised network endpoints.

- Read: `exec 3<>/dev/tcp/host/port`.
- Write: `printf 'GET / HTTP/1.0\r\n\r\n' >&3`.
- Read response: `cat <&3`.
- UDP equivalent: `/dev/udp/host/port`.
- Not real device files — handled internally by bash if compiled with `--enable-net-redirections`.
- Limitations: no TLS, no name resolution beyond what `gethostbyname` does, no IPv6 syntax in older bash.
- Use case: ad-hoc network diagnostics, tiny clients without `curl`.
- Bash 5.x: improved IPv6 support.

## 17.7 `/dev/shm` shared memory

`tmpfs` mounted at `/dev/shm` — RAM-backed file system.

- Files in `/dev/shm` live in RAM.
- Cleared on reboot.
- Use case: high-throughput temp files; lock files that must survive only during shell session.
- Quota: shared RAM with system; don't write GB of data.
- Cross-process visible (any user with permission).
- Pitfall: not all systems mount `/dev/shm`.

## 17.8 External IPC tools

When bash's primitives aren't enough.

- `socat` — multi-protocol relay; can bridge anything to anything.
- `ncat` (nmap), `nc` (BSD or GNU) — TCP/UDP utility.
- `redis-cli` — message broker.
- D-Bus via `gdbus`/`busctl` — desktop IPC.
- These extend bash's reach without replacing it.

## 17.9 Choosing the right primitive

Decision tree.

- **One-off pipe between two commands you control:** `|` (anonymous pipe).
- **Bidirectional with a persistent helper:** `coproc`.
- **Cross-script communication:** FIFO.
- **Network:** `/dev/tcp` for trivial cases; `socat` or `curl` otherwise.
- **Shared memory between unrelated processes:** `/dev/shm` with file-based protocol.
- **Robust message passing:** external broker (Redis, Kafka, RabbitMQ).
- Match primitive to durability, throughput, and concurrency needs.

# Part XVIII — Readline, History, and Completion

*Bash's interactive layer. This Part is irrelevant for batch scripts but central to writing tools your team will use day-to-day.*

---

---

## 18.1 Readline overview

The GNU Readline library handles line editing in interactive bash.

- Provides command-line editing, history navigation, completion.
- Configured per-user via `~/.inputrc`; system-wide via `/etc/inputrc`.
- Bash binds default keys; `bind` builtin allows runtime customisation.
- Two editing modes: emacs (default) and vi.
- Active only when stdin is a terminal.
- Disabled with `bash --noediting` or `set +o emacs`.

## 18.2 Editing modes

Two key-binding regimes.

- emacs: `set -o emacs` (default).
- vi: `set -o vi`.
- Key bindings differ; same underlying functions.
- vi mode has insert and command modes; emacs mode is single-mode.
- Switch at runtime: `set -o vi`.
- Indicator in prompt via `\$`-conditional or readline variable.

## 18.3 Key bindings

`bind` builtin and `~/.inputrc` configure key bindings.

- `bind '"\C-l": clear-screen'` — bind Ctrl-L.
- `bind -p` — list current bindings.
- `bind -P` — list with descriptions.
- `bind -l` — list available functions.
- `bind -f FILE` — load bindings from file (typically `~/.inputrc`).
- `~/.inputrc` syntax: `"keysequence": function-name` or `"keysequence": "string"`.
- Keysequences: `\C-x` (Ctrl-X), `\M-x` (Meta/Alt-X), `\e` (escape), literal characters.
- Conditional bindings via `$if mode=emacs` / `$if mode=vi`.

## 18.4 Bindable functions

Readline's full function catalogue.

- Movement: `forward-char`, `backward-char`, `forward-word`, `backward-word`, `beginning-of-line`, `end-of-line`.
- Editing: `delete-char`, `backward-delete-char`, `kill-word`, `backward-kill-word`, `kill-line`, `unix-line-discard`.
- History: `previous-history`, `next-history`, `reverse-search-history`, `forward-search-history`.
- Completion: `complete`, `possible-completions`, `menu-complete`.
- Macros: `start-kbd-macro`, `end-kbd-macro`, `call-last-kbd-macro`.
- See `bind -l` for the full list.

## 18.5 History

Bash maintains a history of commands.

- `HISTFILE` — file path (default `~/.bash_history`).
- `HISTSIZE` — number of commands in memory.
- `HISTFILESIZE` — number of lines in the file.
- `HISTCONTROL` — list: `ignoreboth`, `ignoredups`, `ignorespace`, `erasedups`.
- `HISTIGNORE` — colon-separated patterns to skip.
- `HISTTIMEFORMAT` — printf format for timestamps in `history` output.
- `HISTAPPEND` shopt — append on exit instead of overwrite.
- `cmdhist` shopt — store multi-line commands as one entry.
- Per-session vs persistent: in-memory list flushed to file on exit (or `history -a`).

## 18.6 The `history` builtin

Manipulate the history list.

- `history` — list all.
- `history N` — last N entries.
- `history -d N` — delete entry N.
- `history -d START-END` — delete range (Bash 5.0+).
- `history -c` — clear in-memory list.
- `history -a` — append in-memory to file.
- `history -w` — overwrite file with in-memory.
- `history -r` — read file into memory.
- `history -p ARG` — perform history expansion on ARG, print result.
- `history -s ARG` — add ARG to history without executing.

## 18.7 History expansion

`!` introduces history references on the command line.

- `!!` — last command.
- `!N` — command N (positive) or N back (negative).
- `!STRING` — most recent command starting with STRING.
- `!?STRING?` — most recent command containing STRING.
- `^old^new` — substitute old with new in last command.
- `!$` — last argument of last command.
- `!^` — first argument of last command.
- `!*` — all arguments of last command.
- `!:N` — N-th argument of last command.
- `!:s/old/new/` — substitution.
- Disable in scripts: `set +H` or non-interactive default.
- Pitfall: `"!"` in double quotes triggers expansion in interactive shells.

## 18.8 Programmable completion

Bash can complete arbitrary commands using user-defined functions.

- `complete -F funcname cmd` — call funcname when completing for cmd.
- The function inspects `COMP_WORDS`, `COMP_CWORD`, etc., and populates `COMPREPLY`.
- `complete -p` — list current completions.
- `complete -o option …` — completion options (default, bashdefault, dirnames, filenames, …).
- Stored in `/usr/share/bash-completion/completions/CMD` typically.
- `bash-completion` package provides defaults for many tools.

## 18.9 Compspec actions

Built-in completion sources.

- `complete -A action cmd` — use built-in action.
- Actions: `alias`, `arrayvar`, `binding`, `builtin`, `command`, `directory`, `disabled`, `enabled`, `export`, `file`, `function`, `group`, `helptopic`, `hostname`, `job`, `keyword`, `running`, `service`, `setopt`, `shopt`, `signal`, `stopped`, `user`, `variable`.
- `complete -W "list" cmd` — completion from a fixed word list.
- `complete -G 'pattern' cmd` — completion from a glob.

## 18.10 `_init_completion`

Helper from `bash-completion` for the standard completion boilerplate.

- Called at the start of a `_funcname` completion function.
- Sets `cur`, `prev`, `words`, `cword` variables.
- Returns 0 to continue, non-zero to short-circuit (e.g., for `--help`).
- `-n CHAR` — characters to treat as word breaks (e.g., `-n =:`).
- See `/usr/share/bash-completion/bash_completion` for source.

## 18.11 Dynamic completion functions

Patterns for writing completion functions.

```bash
_my_tool() {
  local cur prev words cword
  _init_completion || return
  case $prev in
    --file) _filedir; return ;;
    --user) COMPREPLY=($(compgen -u -- "$cur")); return ;;
  esac
  case $cur in
    --*) COMPREPLY=($(compgen -W '--help --version --file --user' -- "$cur")) ;;
  esac
}
complete -F _my_tool my_tool
```

- `compgen -W "list" -- "$cur"` — filter list by current prefix.
- `_filedir` — directories and files (from bash-completion).
- `_filedir 'sh'` — files matching extension.
- `_known_hosts_real` — hosts from various sources.
- Cache expensive operations.

## 18.12 `COMPREPLY` and `COMP_*` variables

The completion environment.

- `COMPREPLY` — array; each element is a candidate completion.
- `COMP_WORDS` — array of words on the current command line.
- `COMP_CWORD` — index into COMP_WORDS of the current word being completed.
- `COMP_LINE` — full current command line.
- `COMP_POINT` — cursor position within COMP_LINE.
- `COMP_TYPE` — completion-type indicator (TAB, ?, !, @, %).
- `COMP_KEY` — key that triggered completion.
- `COMP_WORDBREAKS` — characters that break words for completion (default `' \t\n"\''><=;|&(:'`).

## 18.13 Prompts

Bash uses several prompt variables for different contexts.

- `PS0` — printed after reading a command, before executing (Bash 4.4+).
- `PS1` — primary prompt (interactive).
- `PS2` — continuation prompt (multi-line input).
- `PS3` — `select` menu prompt.
- `PS4` — `set -x` trace prefix.
- Default `PS1`: `\u@\h:\w\$`.
- Default `PS4`: `+ `.

## 18.14 Prompt escapes

Special sequences expanded in prompts.

- `\u` — username.
- `\h` — hostname (short).
- `\H` — hostname (FQDN).
- `\w` — current working directory.
- `\W` — basename of CWD.
- `\$` — `#` if root, `$` otherwise.
- `\!` — history number.
- `\#` — command number.
- `\d` — date.
- `\t`, `\T`, `\@`, `\A` — time formats.
- `\e` — escape (for ANSI colours).
- `\[…\]` — non-printing sequence (essential for colour to avoid line-wrap miscalculation).
- `\j` — number of jobs.
- `\l` — basename of terminal device.

## 18.15 Coloured and multi-line prompts

Practical prompt customisation.

- Wrap colour escapes in `\[…\]` for accurate cursor positioning.
- Multi-line: include `\n` in `PS1`; bash handles the wrapping.
- Conditional content: `${VAR:+prefix$VAR}` for git-branch-style additions.
- `PROMPT_COMMAND` — runs before each prompt; useful for state inspection.
- Powerline-style prompts: `starship`, `oh-my-bash`, hand-rolled.

## 18.16 Terminal capability detection

Determining what the terminal supports.

- `tput colors` — number of colours.
- `tput cols`, `tput lines` — dimensions.
- `tput setaf N`, `tput setab N` — set foreground/background colour.
- `tput bold`, `tput sgr0` — bold, reset.
- `infocmp` — full terminfo entry.
- `$TERM` — terminal type (xterm, screen, tmux, dumb).
- `$COLORTERM` — modern: `truecolor` or `24bit` for 24-bit colour support.
- Always test before emitting colour: avoid breaking dumb terminals or pipes.

# Part XIX — Performance

*Bash is often blamed for being slow. Most "slow Bash" scripts are slow because they fork external commands in tight loops. This Part documents the cost model, the profiling tools, and the optimisations.*

---

---

## 19.1 The Bash cost model

Rough relative costs for common operations.

- Builtin (e.g., `[[`, `printf`, parameter expansion): nanoseconds. Effectively free.
- Variable assignment, arithmetic, string operations: nanoseconds.
- Subshell `$(…)`, `(…)`, pipeline element: ~1 millisecond.
- Fork+exec of an external command: ~1 millisecond (depends on binary size and OS caching).
- Disk I/O: variable (microseconds to milliseconds).
- Network I/O: variable (milliseconds).
- A single fork is cheap; 10,000 forks in a loop is 10 seconds.

## 19.2 Profiling tools

Measuring where time goes.

- `time cmd` — wall, user, sys time.
- `time { cmd1; cmd2; …; }` — time a sequence.
- `BASH_XTRACEFD=N` and `set -x` — trace each command (§19.4).
- `EPOCHREALTIME` for fine-grained timing.
- `strace -c -f cmd` — syscall counts and times.
- `perf stat cmd` — CPU performance counters.
- For hot loops, sample-based profilers don't work well on bash; instrument manually.

## 19.3 `time` builtin vs `time` external

Bash has a `time` reserved word and a `/usr/bin/time` external.

- Bash `time`: built into the shell, times pipelines and compound commands.
- External `time`: separate process; can't time builtins or shell constructs.
- `time -p` (POSIX format) and `TIMEFORMAT` variable for bash's `time`.
- `TIMEFORMAT='%R'` for just real seconds.
- `/usr/bin/time -v` for richer info (max RSS, page faults, context switches).

## 19.4 `BASH_XTRACEFD`

Redirect `set -x` output to a specific fd.

- `exec 3>>trace.log` then `BASH_XTRACEFD=3` — trace to file, not stderr.
- Keeps trace out of the script's user-facing output.
- Combine with `PS4` for rich context.
- Available since Bash 4.1.

## 19.5 `PS4` instrumentation

Customise `set -x` trace prefix.

- `PS4='+ ${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:-main}: '` — file, line, function.
- `PS4='+[$EPOCHREALTIME] '` — timestamp each traced command.
- `PS4='+ ${BASH_SUBSHELL}: '` — subshell depth.
- Combinations: `'+[$EPOCHREALTIME ${BASH_SOURCE##*/}:${LINENO}] '`.
- Pitfall: `PS4` itself is expanded; `\033[…m` colour codes work but the leading `+ ` is added by bash.

## 19.6 `EPOCHREALTIME` for sub-second timing

Bash 5.0+ exposes the system clock with microsecond precision.

- `EPOCHREALTIME` — string like `1716234567.123456`.
- `EPOCHSECONDS` — integer seconds.
- Compute deltas: `start=$EPOCHREALTIME; do_thing; end=$EPOCHREALTIME; printf '%.3f\n' "$(bc -l <<<"$end - $start")"`.
- Older bash: use `date +%s.%N` (forks!) or compile a custom loadable.

## 19.7 Common optimisations

Patterns that reliably speed up scripts.

- Replace external commands with builtins (§19.10).
- Replace pipes with redirection where possible (§19.9).
- Avoid `$(…)` in tight loops.
- Use parameter expansion instead of `sed`/`awk` for simple substitutions (§19.8).
- Batch external calls: one `awk` over many lines vs many `awk`s over one line each.
- Use arrays instead of repeated string parsing.
- Use `mapfile` instead of `while read` loops.

## 19.8 Parameter expansion vs external commands

Replace `sed`/`awk`/`cut` with bash builtins where possible.

| Task | External | Parameter expansion |
|------|----------|---------------------|
| Strip `.txt` suffix | `$(echo "$f" | sed 's/.txt$//')` | `${f%.txt}` |
| Strip directory | `$(dirname "$f")` | `${f%/*}` |
| Get extension | `$(echo "$f" | awk -F. '{print $NF}')` | `${f##*.}` |
| Lowercase | `$(echo "$s" | tr A-Z a-z)` | `${s,,}` |
| Replace all | `$(echo "$s" | sed 's/old/new/g')` | `${s//old/new}` |
| Substring | `$(echo "$s" | cut -c2-5)` | `${s:1:4}` |

- Each parameter-expansion replacement avoids one fork.
- 10,000 iterations × 1 fork × 1 ms = 10 seconds saved.
- Code is shorter and clearer too.

## 19.9 Pipes vs redirection

`cmd > out 2>&1` instead of `cmd 2>&1 | tee out` when no filtering needed.

- Pipes always involve a subshell.
- Redirection is fd manipulation in the same process.
- For "log everything to a file", redirection is direct.
- For "log AND show", `tee` (with the pipe) is the right tool.

## 19.10 Builtins vs externals

A short list of frequent external→builtin replacements.

- `cat file` → `< file` for redirection, `$(<file)` for capture.
- `echo "$var"` → `printf '%s\n' "$var"`.
- `[ ]` → `[[ ]]`.
- `expr` arithmetic → `(( ))` or `$(( ))`.
- `basename file` → `${file##*/}`.
- `dirname file` → `${file%/*}`.
- `tr A-Z a-z` → `${var,,}`.
- `wc -l <<<"$multi"` → use array and `${#arr[@]}`.
- `head -n 1 file` → `read -r line < file`.
- `sleep 0.1` → no builtin equivalent; use external (or `read -t 0.1` with a closed fd as a hack).

## 19.11 Bash 5.3 no-fork command substitution

`${ command; }` runs command in the current shell, no fork.

- Bash 5.3+ only.
- Same syntax as parameter expansion but with `cmd; }`.
- Captures stdout into the substitution result without spawning a subshell.
- Saves the ~1 ms subshell cost per call.
- Caveat: command runs in current shell, so variable changes persist (a feature for some uses, a bug for others).
- Not yet portable; use only if you can require Bash 5.3+.

## 19.12 Memory considerations

Bash uses memory for variables, arrays, and process state.

- Each variable: small fixed overhead plus value size.
- Large strings: bash duplicates on assignment (some optimisations apply).
- Arrays: O(N) for indexed; O(N) for associative with hash-table overhead.
- Subshell fork: copy-on-write; minimal cost until writes.
- `unset` releases memory; without it, lifetime is shell-lifetime.
- Reading a 100 MB file into a variable: avoid; stream instead.

## 19.13 When Bash is the wrong tool

Bash has limits. Recognise them.

- Numerical computation: use Python/Julia/Octave.
- Complex string parsing (JSON, XML, YAML): use `jq`/`yq`/`xmllint`.
- Tight loops with millions of iterations: use Python or compiled.
- True parallelism: use a real language or GNU parallel.
- Large data structures: use a real language.
- Long-running daemons with state: consider Go, Python, or systemd-managed.
- The "if this script is over 500 lines, consider rewriting it" heuristic.

# Part XX — Security

*Bash scripts run with the privileges of the invoking user — often root. This Part documents the threat model, the attack surface, and the defensive disciplines.*

---

---

## 20.1 Threat model

Different scripts face different threats; understand which apply.

- **User-input attacks:** untrusted data flows into command construction.
- **Path-based attacks:** unexpected `PATH` causes wrong binary to run.
- **TOCTOU races:** time-of-check vs time-of-use mismatches.
- **Symlink attacks:** attacker controls a path component.
- **Environment injection:** attacker controls environment variables.
- **Tempfile attacks:** predictable names; race in /tmp.
- **Privilege escalation:** SUID, sudo invocation, root-on-behalf scripts.

## 20.2 PATH hardening

Hard-code `PATH` early in privileged scripts.

```bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin
export PATH
```

- Prevents attacker-controlled PATH from changing which binary `cd`, `cp`, etc., resolves to.
- Order matters: place trusted directories first.
- Never include `.` (current directory) in PATH.
- For scripts running as root, this is mandatory; for user scripts, recommended.

## 20.3 IFS reset

Set IFS to known safe value at script start.

```bash
IFS=$' \t\n'
```

- Default IFS is space-tab-newline; explicit reset asserts this.
- Inherited IFS could split words unexpectedly.
- Save and restore around scoped changes.

## 20.4 `eval` avoidance

`eval` re-parses its argument as shell input. Almost always wrong.

- Safe only with literals you constructed yourself, never with input.
- Common misuse: `eval "var_$key=$value"` (use namerefs or associative arrays instead).
- Common misuse: `eval "$(getopt …)"` (use the hand-rolled parser instead).
- Each `eval` is an attack vector if any input flows in.
- Audit every `eval` in your codebase.

## 20.5 Command injection vectors

Where attacker-controlled data becomes attacker-executed code.

- `eval "$user_input"` — direct.
- `bash -c "$user_input"` — direct.
- `cmd $user_input` (unquoted) — word splitting allows shell metacharacters.
- `find . -exec sh -c "$user_input" {} \;` — direct.
- `system($user_input)` from PHP/Python embedded in shell — direct.
- Backtick or `$(…)` containing user input — direct.
- Make-style `$(shell …)` containing user input — direct.
- Quoting `"$user_input"` blocks word splitting but not all attacks.
- The only safe pattern: validate against an allow-list, then pass as a positional argument.

## 20.6 Input validation

Allow-list, never deny-list.

- Define what is allowed: `[[ $input =~ ^[a-zA-Z0-9_-]+$ ]] || die 22 "invalid input"`.
- Deny-list (rejecting `;`, `&`, etc.) misses combinations and encodings.
- Numeric: `[[ $input =~ ^[0-9]+$ ]]`.
- Filename (no traversal): reject `..`, leading `/`, embedded NULs.
- Length: `(( ${#input} <= 256 ))` or appropriate cap.
- Validate before use, not at point of use.

## 20.7 Quoting under `set -u`

Quoted unset variables expand to nothing; unquoted may error.

- `"$var"` — expands to empty string if unset (under `set -u`, errors).
- `"${var:-}"` — explicitly default to empty.
- For optional args: `"${1:-}"`.
- For arrays that may be empty: `"${arr[@]:-}"`.
- BCS pattern: declare every variable with `declare` to avoid `set -u` traps.

## 20.8 SUID restrictions

SUID on shell scripts is forbidden by Linux.

- Linux ignores SUID on interpreted scripts (sound design — the interpreter sees the script after the shebang race).
- macOS allows it (and users have shot themselves in the foot for decades).
- For privileged shell, use `sudo` (with `NOPASSWD` and a specific command in sudoers).
- Or: use a small SUID C wrapper that exec's the script with sanitised environment.
- Never set SUID on a bash script even if the OS allows it.

## 20.9 Secrets handling

Storing and passing credentials.

- Environment variables: visible in `/proc/PID/environ` to processes you own.
- Command-line arguments: visible in `ps` to all users by default.
- Files: mode 600, owner-only readable.
- `/dev/shm` files: RAM-backed, cleared on reboot.
- `gpg --batch --decrypt` for at-rest encryption.
- Secret-management services: HashiCorp Vault, AWS Secrets Manager, etc.
- Never echo secrets in `set -x` output: temporarily disable tracing around their use.

## 20.10 `noclobber`

`set -o noclobber` (or `set -C`) prevents `>` from overwriting existing files.

- `cmd > existing.txt` errors with noclobber.
- `cmd >| existing.txt` forces overwrite.
- Default off; turn on for safer scripts.
- Use for "exclusive create" semantics: `set -C; > LOCK || die 'lock exists'`.

## 20.11 Privilege drop

Running parts of a script with reduced privileges.

- `sudo -u USER cmd` to run as another user.
- `runuser -u USER -- cmd` (systemd).
- `setpriv` for finer control (capabilities, securebits).
- Drop privileges as early as possible.
- Re-acquire only when needed (and only via `sudo` or capability).
- Auditing: log every privilege boundary crossing.

## 20.12 Sanitising filenames

Filenames are bytes; bytes can be ugly.

- Normalise: remove leading dashes, control characters, embedded slashes.
- Reject `..` for traversal protection.
- Limit to ASCII printable for cross-system compatibility.
- Length cap: 255 for traditional FS, 4096 for path.
- Use `realpath --` to canonicalise.
- For user-supplied filenames, never trust; always sanitise.

## 20.13 Symlink races

Attacker substitutes a symlink between your check and your action.

- `[[ -f $f ]]; rm $f` — attacker swaps `$f` to symlink to `/etc/passwd` after the test.
- Mitigation: open with `O_NOFOLLOW` — not directly accessible from bash.
- `mktemp -d` creates with mode 700 inside, owned by you, no race.
- For `rm -rf` of a directory, `find $dir -depth -delete` is safer than `rm -rf $dir` if symlinks are in scope.
- For predictable paths in `/tmp`, use `mktemp` or your own tempdir under `/dev/shm` or `~/.cache/`.

## 20.14 Restricted shell mode

`bash -r` or `bash --restricted` runs in restricted mode.

- Cannot `cd`.
- Cannot set or unset `SHELL`, `PATH`, `ENV`, `BASH_ENV`.
- Cannot specify command names containing `/`.
- Cannot redirect output to files.
- Cannot use `exec` to replace shell with another program.
- Use case: chrooted environment for limited users; not a security boundary on its own.
- Easy to escape if the user can run any unrestricted shell from inside.

# Part XXI — Static Analysis, Formatting, and Testing

*Bash without ShellCheck is Python without a linter. This Part documents the tooling stack: static analysis, formatting, compliance checking, testing, and CI integration.*

---

---

## 21.1 ShellCheck warnings

ShellCheck is the de facto bash static analyser.

- Invocation: `shellcheck -x script.bash`.
- `-x` follows `source` directives.
- Severity levels: error, warning, info, style.
- Each warning has a code (`SC2086`, `SC2155`, etc.) and a wiki page.
- Most-cited warnings: SC2086 (unquoted variable), SC2155 (declare and assign separately), SC2068 (use `"$@"` not `$@`), SC2250 (use braces).
- Gates: `shellcheck --severity=warning` for stricter CI.
- All BCS-compliant scripts must be ShellCheck-clean.

## 21.2 ShellCheck directives

Inline pragmas to suppress specific warnings with a stated reason.

```bash
# shellcheck disable=SC2034 reason: read by sourced library
local -- callback="$1"
```

- `# shellcheck disable=SCNNNN` — suppress for next command.
- Multiple codes: comma-separated.
- Always include `reason:`; suppression without justification is a code smell.
- Source-level: `# shellcheck shell=bash` for files without shebang.
- `# shellcheck source=path` for non-default sourcing.
- `# shellcheck disable=SCNNNN # comment` — also acceptable.

## 21.3 Source-path management

Helping ShellCheck follow `source` statements.

- `# shellcheck source=lib/util.bash` — explicit relative path.
- `# shellcheck source-path=SCRIPTDIR source=util.bash` — relative to script directory.
- `# shellcheck source-path=/abs/path source=util.bash` — absolute.
- Required when path uses `$(dirname "$0")` or other dynamic resolution.
- Without it, ShellCheck reports SC1091 (file not following).

## 21.4 `shfmt`

A bash formatter, analogous to `gofmt`.

- Invocation: `shfmt -d script.bash` (diff mode).
- `-i 2` — 2-space indentation.
- `-ci` — switch case indented.
- `-s` — simplify (e.g., remove redundant `$()`).
- `-bn` — binary operator at start of next line.
- `shfmt -w` — write changes (after review).
- Pre-commit integration: reject any commit with shfmt diffs.

## 21.5 `bcscheck`

LLM-backed BCS compliance checker.

- Invocation: `bcscheck script.bash`.
- Calls into a configured LLM (Claude, Ollama, OpenAI, Google, etc.) per `bcs check`.
- Slow (minutes per script).
- Catches BCS-specific patterns ShellCheck doesn't (option terminator `--`, function organisation, error-code conventions).
- Configuration: `~/.config/bcs/bcs.conf`.
- JSON output mode for CI parsing: `bcscheck -j`.
- Inline suppression: `#bcscheck disable=BCSdddd`.

## 21.6 Pre-commit hooks

Run linters and formatters on every commit.

- `pre-commit` framework (Python-based) with bash-specific hooks.
- Hooks: shellcheck, shfmt, bcscheck.
- Configuration: `.pre-commit-config.yaml`.
- Install: `pre-commit install` in the repo.
- Bypass: `git commit --no-verify` (discouraged; use only in emergencies and document why).

## 21.7 CI integration

Running the tooling stack in CI.

- GitHub Actions: `shellcheck-py`, `shfmt-action`, custom job for `bcscheck`.
- GitLab CI: similar.
- Treat any warning as failure.
- Cache binaries to avoid re-downloading.
- Fail fast: stop on first failed step.
- Branch protection: require CI to pass before merge.

## 21.8 bats-core

The standard bash test framework.

- File extension: `.bats`.
- Test: `@test 'description' { commands; }`.
- `setup()` runs before each test; `teardown()` after.
- `setup_file()` runs once per file before any test; `teardown_file()` after all.
- `run cmd` — captures `$status`, `$output`, `$lines[]`.
- `run --separate-stderr cmd` — also captures `$stderr` (newer bats).
- Assertion library: `bats-assert`.
- Mocking: PATH injection (§21.11).

## 21.9 Bats setup and teardown

The lifecycle hooks.

- `setup_file` — once per file, before any test runs in that file.
- `setup` — before each test.
- `teardown` — after each test (even on failure).
- `teardown_file` — once per file, after all tests.
- Use `setup_file` for expensive shared state (database init, file generation).
- Use `setup` for per-test fixtures.
- Variables set in `setup` are visible in the test; cleared between tests.

## 21.10 Bats `run` and assertions

Capturing output and asserting on it.

- `run cmd` — captures stdout+stderr (or just stdout with `--separate-stderr`).
- `$status` — exit status.
- `$output` — full output as one string.
- `$lines` — output as array of lines.
- `$stderr`, `$stderr_lines` — with `--separate-stderr`.
- `assert_success`, `assert_failure`, `assert_equal`, `assert_output`, `refute_output`, `assert_line`, `assert_regex`, etc. (from `bats-assert`).
- Custom assertions: write a function, return non-zero with `echo` to fail with a message.

## 21.11 Mocking via PATH injection

Replacing external commands for tests.

```bash
setup() {
  MOCK_DIR=$(mktemp -d)
  PATH="$MOCK_DIR:$PATH"
  cat > "$MOCK_DIR/curl" <<'EOF'
#!/bin/bash
echo '{"result": "mocked"}'
EOF
  chmod +x "$MOCK_DIR/curl"
}

teardown() {
  rm -rf -- "$MOCK_DIR"
}
```

- Prepend a tempdir to PATH.
- Drop in mock binaries.
- Mock checks arguments and produces controlled output.
- Each test can have different mocks via `setup`.
- Persistent mocks (across tests) via `setup_file`.

## 21.12 shunit2

Older bash test framework, less popular than bats but still used.

- xUnit-style: `testFunctionName` named functions.
- `assertEquals`, `assertTrue`, `assertFalse`, `assertNotNull`.
- `setUp`, `tearDown`, `oneTimeSetUp`, `oneTimeTearDown`.
- Single file: `source shunit2`.
- Use case: shell-script-only environments where installing bats is heavy.

## 21.13 Coverage with kcov

Code coverage measurement for bash.

- `kcov OUTPUT_DIR ./script.bash args` — instruments and runs.
- Outputs HTML coverage report.
- Slow on large scripts.
- Misses some bash constructs (subshells, certain expansions).
- Use case: ensuring tests touch all branches of long functions.
- Combine with bats: `kcov OUTPUT_DIR bats tests/`.

# Part XXII — Idioms, Patterns, and Anti-Patterns

*A catalogue of patterns that appear repeatedly in well-written bash, and a catalogue of patterns that should not appear at all. This Part is essentially a cookbook for the BCS-aligned engineer.*

---

---

## 22.1 The strict-mode preamble

The opening every script must have.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- Shebang: `#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash` (the last for portability).
- `set -e` exit on error; `-u` unset variables; `-o pipefail` pipeline status.
- `inherit_errexit` propagate `-e` into command substitutions.
- `shift_verbose` warn on shift past end.
- `extglob` enable extended globs.
- `nullglob` empty glob expands to nothing.
- BCS canonical: declare these at the very top, before any logic.

## 22.2 Self-locating script directory

Find the script's own directory regardless of how it was invoked.

```bash
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
```

- `BASH_SOURCE[0]` is the script file (or library file when sourced).
- `realpath` resolves symlinks (BCS preferred over `readlink`).
- `--` terminates options.
- `SCRIPT_DIR` for finding sibling files (configs, libraries, data).
- `SCRIPT_NAME` for messages.

## 22.3 Argument-parsing skeleton

The full BCS-canonical hand-rolled parser. See §15.4 for the body.

- Initialise variables with defaults.
- Parse loop with `while`, `case`, `shift`.
- Handle long, short, bundled, equals, end-of-options.
- Validate after parse: required arguments present, mutually-exclusive options not combined.
- Make required-positional check explicit.

## 22.4 Default-value patterns

Setting defaults for variables.

- `: "${VAR:=default}"` — parameter expansion side effect (assigns).
- `VAR=${VAR:-default}` — explicit reassignment (does not affect environment).
- `declare -- VAR=${VAR:-default}` — explicit declaration with default.
- BCS: declare every variable with explicit type and default at top of script.

## 22.5 Lazy initialisation

Compute on first use.

```bash
get_config() {
  if [[ -z ${_CONFIG_LOADED:-} ]]; then
    source "$config_file"
    _CONFIG_LOADED=1
  fi
}
```

- Use a sentinel to track first invocation.
- Compute once, reuse.
- Watch for scope: `_CONFIG_LOADED` must be global.
- Use `declare -g` if setting from inside a function.

## 22.6 Memoisation

Cache function results.

```bash
declare -A _MEMO_CACHE

memoised_compute() {
  local key=$1
  if [[ -z ${_MEMO_CACHE[$key]+set} ]]; then
    _MEMO_CACHE[$key]=$(expensive_compute "$key")
  fi
  printf '%s\n' "${_MEMO_CACHE[$key]}"
}
```

- Associative array as cache.
- Test for key existence with `[[ -z ${arr[k]+set} ]]` to distinguish "unset" from "set to empty".
- Cache invalidation strategy: TTL, manual flush, or none.

## 22.7 Iterating an associative array deterministically

Bash hashtable iteration order is unspecified. Sort for reproducibility.

```bash
for key in $(printf '%s\n' "${!by_id[@]}" | sort); do
  printf '%s = %s\n' "$key" "${by_id[$key]}"
done
```

- `printf '%s\n' "${!by_id[@]}"` — one key per line.
- `sort` with appropriate flags (`-n` for numeric, `-V` for version, default lexical).
- For large maps, the sort cost is real; cache sorted keys if iterating repeatedly.

## 22.8 Building structured output

Emit CSV, TSV, or JSON from bash.

- TSV: `printf '%s\t%s\t%s\n' "$a" "$b" "$c"`.
- CSV: same but with comma; quote fields containing comma.
- JSON: use `jq -n --arg key "$value" '{"key": $key}'` to safely build.
- JSON from arrays: `jq -n --argjson arr "$(printf '%s\n' "${arr[@]}" | jq -R . | jq -s .)" '{"items": $arr}'`.
- Avoid hand-rolling JSON in bash; quoting is error-prone.

## 22.9 Reading config files safely

Sourcing arbitrary files is a code-execution risk. Parse instead.

```bash
read_conf() {
  local conf_file=$1 line key value
  while IFS='=' read -r key value; do
    [[ $key == \#* || -z $key ]] && continue
    key=${key// /}
    value=${value%\"}
    value=${value#\"}
    declare -g -- "${key^^}=$value"
  done < "$conf_file"
}
```

- Strict regex-based parsing.
- Reject lines that don't match expected format.
- Whitelist allowed keys.
- Never `source` a config file you don't fully trust.

## 22.10 Atomic file write

Write to a sibling tempfile, then rename. (See §12.15 for the full pattern.)

- `tmp=$(mktemp -- "${target}.XXXXXX")`.
- Write to `$tmp`.
- `mv -- "$tmp" "$target"` — atomic on the same filesystem.
- Cleanup on failure via trap.

## 22.11 Exclusive lock

`flock` on a dedicated lockfile. (See §12.14.)

- `exec 9>"$lockfile"`.
- `flock -n 9 || die 1 "already locked"`.
- Lock held for shell's lifetime.
- Cleanup automatic when shell exits.

## 22.12 Bounded retry with exponential backoff

Retry on transient failure with growing delay.

```bash
retry() {
  local max=$1 delay=1
  shift
  local attempt
  for ((attempt = 1; attempt <= max; attempt++)); do
    if "$@"; then return 0; fi
    if (( attempt < max )); then
      sleep "$delay"
      delay=$((delay * 2))
    fi
  done
  return 1
}
```

- Configurable max retries.
- Exponential delay (1, 2, 4, 8, …).
- Optional jitter to avoid thundering herd.
- Distinguish retryable from non-retryable errors (consider exit-code-based decision).

## 22.13 Tempdir lifecycle

`mktemp -d` plus EXIT trap. (See §12.13.)

- Create.
- Trap.
- Use.
- Trust EXIT to clean up — don't litter `rm -rf` mid-script.

## 22.14 Mock-friendly subprocess wrapper

Wrap external commands behind a function for testability.

```bash
git_cmd() { command git "$@"; }
```

- Tests can override `git_cmd` to a mock.
- Use `command` prefix to bypass any function shadowing.
- Use case: any external dep that touches network, filesystem, or system state.

## 22.15 Stack-trace error reporter

Rich error output via FUNCNAME/BASH_SOURCE/BASH_LINENO. (See §13.12.)

- Trap ERR.
- Walk the call stack.
- Format as filename:line: function.
- Optionally include `BASH_COMMAND` for the failing command.

## 22.16 Self-test mode (dual-purpose script)

A script that runs as a script when invoked directly and as a library when sourced.

```bash
if (( ${#BASH_SOURCE[@]} == 1 )); then
  main "$@"
fi
```

- Detects whether sourced (length > 1) or executed (length == 1).
- Run `main` only when executed directly.
- Allows the same file to be sourced for testing of its functions.
- Alternative: `[[ ${BASH_SOURCE[0]} == "$0" ]]` (less reliable in subtle cases).
- BCS template includes this pattern.

## 22.17 Anti-patterns catalogue

Patterns that appear in legacy code and should not be perpetuated.

- `[ $var = "x" ]` — unsafe; use `[[ $var == x ]]`.
- `for f in $(ls)` — breaks on filenames with spaces; use a glob or `find -print0 | mapfile`.
- `cmd > file 2>&1` vs `cmd 2>&1 > file` — order matters; the second is wrong if you intend both to go to the file.
- `((count++))` under `set -e` with `count=0` — the post-increment returns 0, triggering errexit; use `count+=1` or `((++count))`.
- `cmd | while read line; do …; done` — loop runs in subshell; outer scope unaffected; use `< <(cmd)` or `lastpipe`.
- `command -v cmd >/dev/null` — correct; `which cmd` — wrong, varies across systems and produces output even when not found.
- `eval "$user_input"` — direct injection; never.
- `` `cmd` `` (backticks) — deprecated; use `$(cmd)`.
- `[ a = "$b" ]` — unsafe if `$b` contains `-` or `=`; use `[[ ]]`.
- `read line` (no `-r`) — interprets backslash; use `read -r`.
- `IFS=… ; cmd ; IFS=…` — leaks if `cmd` exits early; scope IFS in a subshell or restore in trap.
- `if [ $? -eq 0 ]` — racy; use `if cmd; then …`.
- `local file=$(cmd)` — `local` is a builtin returning 0, masking `$(cmd)`'s exit; declare and assign separately.
- `echo -e "..."` — non-portable; use `printf '%b\n'` or `$'...'`.
- `cd $dir && cmd` — fails open if `cd` fails; use `cd "$dir" || die`.
- `cat file | wc -l` — useless cat; `wc -l < file` or `wc -l file`.
- `function name()` — redundant `function` keyword; just `name()`.
- `${1}` everywhere when `$1` would do — but `${var}foo` *does* need braces.
- `if grep -q pattern file; then` — fine, but `if [[ $(grep -c pattern file) -gt 0 ]]` — wasteful; the first form is right.

# Part XXIII — POSIX Conformance and Portability

*When and how to write code that runs on more than just Bash. Most production code does not need to be portable; some does. This Part documents the trade-offs.*

---

---

## 23.1 Bash vs POSIX sh

The features bash adds beyond POSIX 1003.2 / SUSv4.

- Arrays (indexed and associative).
- `[[ ]]` conditional command.
- `(( ))` arithmetic command.
- `=~` regex.
- `$(< file)` (not POSIX; `cat <file` is).
- `let` builtin.
- `local` (POSIX has no scoping).
- `declare` / `typeset` and attributes.
- `mapfile` / `readarray`.
- Process substitution `<(…)`, `>(…)`.
- Brace expansion `{1..10}`.
- `**` globstar.
- `+=` operator.
- `${var//pat/repl}` and other expansions beyond POSIX.
- ANSI-C `$'...'` quoting.

## 23.2 The bashisms list

Specific constructs that fail in `dash` / POSIX `sh`.

- `[[ ]]` — sh has only `[ ]`.
- `local` — sh has no scoping.
- Arrays — sh has none.
- `function` keyword — sh requires `name()`.
- `$'...'` — sh has only `'…'`.
- `<<<` — sh has only `<<`.
- `read -r ARRAY` — sh has no array.
- `==` in `[[`/`[` — sh prefers `=`.
- `&>` — sh requires `>file 2>&1`.
- `pipefail` — sh has none (POSIX 2024 adds it).
- `checkbashisms` tool from `devscripts` — Debian's auditor.

## 23.3 Bash vs dash

`dash` is Ubuntu/Debian's `/bin/sh` — POSIX-only, no bashisms.

- Smaller, faster start, fewer features.
- Used for `/etc/init.d` scripts and systemd `ExecStart` shell.
- A bash script with `#!/bin/bash` runs under bash even if `/bin/sh -> dash`.
- Be deliberate about the shebang.
- Test with `dash script.sh` if portability matters.

## 23.4 Bash vs ksh

Korn shell variants.

- `ksh88` — POSIX baseline, widely deployed historically.
- `ksh93` — feature-rich, ahead of bash on some features (associative arrays since 1993).
- `mksh` (MirBSD ksh) — pdksh successor; on Android, OpenBSD.
- ksh has discipline functions, type system, floating point — bash does not.
- Some idioms differ: `print` vs `printf`, `read -A` vs `read -a`.

## 23.5 Bash vs zsh

zsh is interactive-rich, scripting-divergent.

- Word splitting different by default (zsh does not split unquoted variables).
- Globbing more powerful (qualifiers, recursive globs without `globstar`).
- Arrays 1-indexed by default.
- `setopt KSH_ARRAYS` to use 0-indexed.
- Redirection differences.
- Many bash idioms break in zsh; many zsh idioms break in bash.
- For shared `~/.profile`, code carefully.

## 23.6 Bash 3.2 on macOS

Apple ships bash 3.2 (2007). Macs have used `zsh` as default since macOS Catalina.

- macOS `/bin/bash` is 3.2 — no associative arrays, no `mapfile`, no namerefs.
- Users install bash 5 via Homebrew: `/opt/homebrew/bin/bash` or `/usr/local/bin/bash`.
- Scripts that target Mac users need to choose: support 3.2, or require Homebrew bash.
- Most modern scripts require 4.0+ or 5.0+.

## 23.7 BSD `sh`

FreeBSD, OpenBSD, NetBSD use various `sh` implementations.

- FreeBSD: `ash` derivative.
- OpenBSD: `pdksh` (more capable; effectively ksh88).
- All POSIX-compliant; few extensions.
- For cross-BSD portability, restrict to POSIX.

## 23.8 `--posix` mode

Bash's POSIX-conformance mode.

- Activated by `bash --posix` or `set -o posix`.
- Disables many bash extensions.
- Used to test POSIX compliance.
- Not a deployment target — POSIX-mode bash is still bash, not `sh`.

## 23.9 `shopt` compatibility levels

Bash supports limited backward compatibility via `shopt -s compatNN`.

- `compat31`, `compat32`, … `compat51` — emulate that version's behaviour.
- Used for legacy scripts that depend on quirks.
- BCS recommends not using these — fix the script.
- Removed: bash 5.2+ may drop the oldest levels.

## 23.10 When to write portable sh

Cases where POSIX-only is the right choice.

- `/bin/sh` scripts in OS init / packaging.
- Build scripts that run before bash is available.
- Embedded systems with only ash/dash.
- Legacy Unix support.
- Most cases: write bash, require bash, document the requirement.

## 23.11 Forward-compatibility hygiene

Writing bash that won't break in future versions.

- Test with `BASH_COMPAT=` unset (modern semantics).
- Avoid relying on undocumented behaviour.
- Watch the bash release notes (NEWS file).
- Keep up with deprecations: backticks, `$[…]`, `expr`.
- Don't depend on `lastpipe` being on/off — set it explicitly.

## 23.12 Targeting multiple Bash versions

Supporting both old and new bash from one script.

- Detect: `(( BASH_VERSINFO[0] >= 4 ))` for 4.0+ features.
- Conditional: use namerefs only if available.
- Polyfill: write a function that simulates a missing feature (rarely worth it).
- Document the minimum: `# Requires bash 4.4+` in header.
- Reject older: at top of script, check version and `die` if too old.

# Part XXIV — Bash Internals

*How bash actually works. This Part is for advanced readers who want to understand semantics by understanding the implementation.*

---

---

## 24.1 The execution pipeline

The high-level path from input string to syscalls.

1. Tokeniser produces tokens from input characters.
2. Parser produces an AST from tokens (via bison grammar).
3. Word expansion: brace, tilde, parameter, arithmetic, command, process substitution.
4. Word splitting (on unquoted results).
5. Pathname expansion (on unquoted results).
6. Quote removal.
7. Redirection setup.
8. Execution dispatch: builtin, function, external (fork+exec).
9. Wait for completion (or background).
10. Trap delivery for any pending signals.

## 24.2 The bison grammar

Bash 5.2 rewrote the command-substitution parser using a recursive bison grammar.

- Pre-5.2: ad-hoc parsing in C; subtle bugs around nesting and quoting.
- Bash 5.2: full bison grammar; cleaner, more correct.
- Files in source tree: `parse.y`, `subst.c`.
- Reading the grammar: bison `parse.y` is the canonical reference.
- Implications: bash 5.2 accepts some constructs that older bash rejected, and vice versa.

## 24.3 Variable storage

Bash maintains variables in a hash table, scoped by call stack.

- One global variable table.
- Per-function local-variable tables.
- Lookup: walk from innermost scope outward.
- Hash table: open addressing, linear probing.
- Variable record: name, value, attributes (`-i`, `-a`, etc.), reference count.
- Performance: `O(1)` average; `O(N)` worst case under collision.

## 24.4 Function storage

Functions are stored similarly to variables, in their own table.

- One global function table; no scoped tables.
- A function defined inside a function is still global.
- `unset -f` removes by name.
- `declare -f` lists with bodies.
- Source location tracked when `extdebug` is enabled.

## 24.5 The job table

Per-shell table of jobs.

- Each entry: job number, PID(s), state (Running, Stopped, Done), command text.
- Built when job control is on.
- Subshells start with empty job table.
- Garbage-collected: entries removed once status is reported.

## 24.6 The trap table

Per-shell table mapping signals to handler strings.

- Indexed by signal number.
- Inherited at fork; reset (for caught signals) at exec.
- `trap` builtin reads/writes this table.
- Pseudo-signals (EXIT, ERR, DEBUG, RETURN) have separate slots.

## 24.7 The execution environment

The bundle of state that defines a command's runtime context.

- Variables.
- Functions.
- File descriptors.
- Traps.
- Working directory.
- Umask.
- Signal mask.
- Resource limits.
- Subshells inherit (almost) everything; some elements reset (caught signals, DEBUG/ERR/RETURN traps without `-T`/`-E`).

## 24.8 Subshell forking

What `fork()` copies, what it doesn't.

- Memory (copy-on-write): all variables, functions, internal state.
- Open file descriptors: inherited (same kernel objects).
- Signal handlers: inherited (caught signals reset on exec).
- Process group: depends on context.
- The parent's environment is the child's environment.
- Implication: subshell variable changes are local to the subshell; parent never sees them.

## 24.9 Builtin loadables

Bash supports loading additional builtins from shared objects at runtime.

- `enable -f /path/to/builtin.so name`.
- Compiled C code with bash's builtin interface.
- Examples in bash source: `examples/loadables/`.
- Use case: extending bash with one-off performance-critical operations.
- `--enable-loadable-builtins` configure-time option.

## 24.10 Reading the bash source

For deep understanding, the canonical resource is the bash source itself.

- Repository: `https://git.savannah.gnu.org/cgit/bash.git/`.
- Key files: `parse.y` (grammar), `subst.c` (expansion), `execute_cmd.c` (execution), `variables.c` (variable management), `jobs.c` (job control).
- Build from source: `./configure && make`.
- Comments are dense but informative.
- The bash maintainer (Chet Ramey) is responsive on the bug-bash mailing list.

# Part XXV — Bash 5.3 and the Future

*Bash continues to evolve. This Part documents Bash 5.3 (released 2025) and looks at upstream signals about future releases.*

---

---

## 25.1 No-fork command substitution `${ cmd; }`

The headline feature of Bash 5.3.

- Syntax: `${ command; }` — note the leading space and trailing semicolon.
- Runs command in current shell (no fork).
- Captures stdout into the substitution result.
- Saves ~1 ms per call versus `$(cmd)`.
- Side effect: variable changes persist (unlike `$(…)` which is in a subshell).
- Use cases: hot paths where the cost of forking dominates.
- Caveat: not portable; requires Bash 5.3+.

## 25.2 Other Bash 5.3 additions

Other notable changes.

- New shopt and set options (consult Bash 5.3 NEWS).
- Refinements to `coproc` for multiple coprocs.
- Improvements to `wait -n` semantics.
- Performance improvements to common builtins.
- Bug fixes for edge cases in 5.2's bison grammar.

## 25.3 Release cadence

Bash major releases are infrequent; minor releases more common.

- 4.0 (2009) → 5.0 (2019) — ten years.
- 5.0 → 5.1 (2020) → 5.2 (2022) → 5.3 (2025) — roughly two years between minors.
- Patch releases: as needed for security.
- Distribution lag: Ubuntu LTS may carry the version current at LTS release for years.

## 25.4 Roadmap signals

Where bash development is heading, based on mailing-list activity and upstream patches.

- Continued performance work on hot paths (no-fork patterns).
- Better handling of UTF-8 in pattern matching.
- More flexible `printf` / `read` options.
- Refinements to `coproc`, `wait`, completion.
- Slow but steady — bash is a stable language; revolutionary changes are unlikely.
- Watch the bug-bash mailing list (`https://lists.gnu.org/archive/html/bug-bash/`).

## 25.5 Forward-compatibility considerations

Writing bash that will benefit from future versions without breaking.

- Avoid relying on undocumented behaviour.
- Watch deprecation notices in NEWS.
- Use modern idioms (no backticks, no `[ ]`, no `expr`).
- Pin bash version requirements in script headers.
- Test against new bash versions when they ship.

---

# Appendices

## Appendix A — Builtin Reference (alphabetical)

Every builtin in alphabetical order, with one-line description and option summary. Cross-referenced to the relevant chapter.

- `:` — null command (§7.14).
- `.`, `source` — execute file in current shell (§10.1).
- `alias`, `unalias` — define/remove command aliases.
- `bg`, `fg`, `jobs` — job control (§11.9).
- `bind` — readline key binding (§18.3).
- `break`, `continue` — loop control (§7.11).
- `builtin` — invoke a builtin even if shadowed.
- `caller` — call-stack frame (§9.11).
- `cd` — change directory.
- `command` — invoke a command bypassing functions and aliases.
- `compgen`, `complete`, `compopt` — programmable completion (§18.8).
- `coproc` — start a coprocess (§17.1).
- `declare`, `typeset` — variable declaration with attributes (§4.5).
- `dirs`, `pushd`, `popd` — directory stack.
- `disown` — remove from job table (§11.9).
- `echo` — print arguments (avoid; use `printf`, §14.5).
- `enable` — enable/disable builtins.
- `eval` — re-evaluate as shell input (§20.4).
- `exec` — replace shell or modify fds (§6.12).
- `exit` — terminate shell (§7.13).
- `export` — mark variable for export (§4.8).
- `false` — return failure (§7.14).
- `getopts` — POSIX option parser (§15.2).
- `hash` — command path memoisation.
- `help` — built-in help.
- `history` — history operations (§18.6).
- `kill` — send signal (§11.10).
- `let` — arithmetic evaluation (§8.13).
- `local` — declare function-local variable (§4.6).
- `logout` — exit a login shell.
- `mapfile`, `readarray` — read into array (§14.3).
- `printf` — formatted output (§14.4).
- `pwd` — print working directory.
- `read` — read input (§14.2).
- `readonly` — mark variable readonly (§4.7).
- `return` — return from function or sourced script (§7.12).
- `select` — interactive menu (§7.7).
- `set` — set shell options (Appendix D).
- `shift` — shift positional parameters.
- `shopt` — shell option (Appendix E).
- `suspend` — suspend the shell.
- `test`, `[` — POSIX conditional (§8.14, deprecated).
- `times` — print accumulated CPU times.
- `trap` — register signal handler (§12.5).
- `true` — return success (§7.14).
- `type` — show command type.
- `ulimit` — resource limits.
- `umask` — file-creation mode mask.
- `unset` — remove variable or function (§4.14).
- `wait` — wait for child completion (§16.2).

## Appendix B — Special Parameters Reference

| Parameter | Meaning |
|-----------|---------|
| `$0` | Script name (or `BASH_ARGV0`) |
| `$1`–`${N}` | Positional parameters |
| `$#` | Number of positional parameters |
| `$@` | All positional, each a separate word when quoted |
| `$*` | All positional, joined by IFS[0] when quoted |
| `$?` | Exit status of last foreground command |
| `$$` | PID of script (fixed; not subshell PID) |
| `$!` | PID of last backgrounded process |
| `$_` | Last argument of previous command |
| `$-` | Current shell flags |

## Appendix C — Shell Variables Reference

Bash-defined variables (selection; see `man bash` for full list).

- `BASH` — path to bash binary.
- `BASH_VERSION`, `BASH_VERSINFO[]` — version.
- `BASH_SOURCE[]`, `BASH_LINENO[]`, `FUNCNAME[]` — call stack.
- `BASH_REMATCH[]` — last `=~` matches.
- `BASH_SUBSHELL`, `BASHPID` — process identity.
- `BASHOPTS`, `SHELLOPTS` — option state.
- `COMP_*` — completion context.
- `EPOCHREALTIME`, `EPOCHSECONDS`, `SECONDS` — clocks.
- `HISTFILE`, `HISTSIZE`, `HISTFILESIZE`, `HISTCONTROL`, `HISTIGNORE`, `HISTTIMEFORMAT` — history.
- `IFS` — internal field separator.
- `LANG`, `LC_*`, `LANGUAGE` — locale.
- `LINENO` — current line.
- `MAPFILE` — default array for `mapfile`.
- `OLDPWD`, `PWD` — directory.
- `OPTARG`, `OPTIND` — getopts state.
- `PATH` — command search.
- `PIPESTATUS[]` — last pipeline statuses.
- `PS0`, `PS1`, `PS2`, `PS3`, `PS4` — prompts.
- `RANDOM`, `SRANDOM` — random sources.
- `SHLVL` — shell-invocation depth.
- `UID`, `EUID`, `GROUPS[]` — user identity.

## Appendix D — `set` Options Reference

| Short | Long | Effect |
|-------|------|--------|
| `-a` | `allexport` | Export all newly-defined variables |
| `-b` | `notify` | Notify of background-job completion |
| `-e` | `errexit` | Exit on error (§13.2) |
| `-f` | `noglob` | Disable pathname expansion |
| `-h` | `hashall` | Hash command paths |
| `-k` | `keyword` | Keyword args anywhere on line |
| `-m` | `monitor` | Job control |
| `-n` | `noexec` | Read but don't execute |
| `-p` | `privileged` | Don't read profile/rc |
| `-t` | `onecmd` | Exit after one command |
| `-u` | `nounset` | Error on unset variable (§13.4) |
| `-v` | `verbose` | Print input lines |
| `-x` | `xtrace` | Print commands as executed |
| `-B` | `braceexpand` | Brace expansion (default on) |
| `-C` | `noclobber` | Don't overwrite with `>` (§20.10) |
| `-E` | `errtrace` | ERR trap inherited (§13.9) |
| `-H` | `histexpand` | History expansion (default on, interactive) |
| `-P` | `physical` | Don't follow symlinks for `cd` |
| `-T` | `functrace` | DEBUG/RETURN traps inherited |
| | `pipefail` | Pipeline status (§6.15) |
| | `posix` | POSIX mode |

## Appendix E — `shopt` Options Reference

Selected; full list via `shopt`.

- `autocd` — bare directory acts as `cd dir`.
- `cdable_vars` — `cd VAR` checks `$VAR`.
- `cdspell`, `dirspell` — autocorrect typos.
- `checkhash`, `checkjobs`, `checkwinsize` — interactive checks.
- `cmdhist`, `lithist` — multi-line history handling.
- `compat31`–`compat51` — backward-compat (§23.9).
- `complete_fullquote` — quote shell metas in completion.
- `direxpand` — expand path completions.
- `dotglob` — include dotfiles in `*` (§5.11).
- `execfail` — non-interactive shell continues on `exec` failure.
- `expand_aliases` — expand aliases in non-interactive shells.
- `extdebug` — additional debugging info.
- `extglob` — extended globs (§5.12).
- `failglob` — unmatched glob is an error.
- `globasciiranges` — `[a-z]` ASCII regardless of locale.
- `globskipdots` — exclude `.` and `..` from `*` (5.2+).
- `globstar` — `**` matches any number of directories.
- `gnu_errfmt` — GNU-style error format.
- `histappend`, `histreedit`, `histverify` — history behaviour.
- `huponexit` — SIGHUP background jobs on exit.
- `inherit_errexit` — propagate `-e` into command substitutions (§13.6).
- `interactive_comments` — `#` as comment in interactive mode.
- `lastpipe` — last pipeline command runs in current shell (§6.16).
- `localvar_inherit`, `localvar_unset` — local-variable behaviour.
- `mailwarn` — warn on mail-file changes.
- `no_empty_cmd_completion` — don't complete on empty line.
- `nocaseglob`, `nocasematch` — case-insensitive (§5.11).
- `nullglob` — empty glob expands to nothing.
- `progcomp`, `progcomp_alias` — programmable completion.
- `promptvars` — expand variables in prompt.
- `restricted_shell` — set when restricted.
- `shift_verbose` — warn on shift past end.
- `sourcepath` — `source` uses PATH search.
- `varredir_close` — close redirected fds when var goes out of scope (5.2+).
- `xpg_echo` — `echo` expands escapes by default.

## Appendix F — ANSI-C Escape Sequences

| Escape | Character |
|--------|-----------|
| `\a` | Alert (BEL, 0x07) |
| `\b` | Backspace (0x08) |
| `\e`, `\E` | Escape (0x1b) |
| `\f` | Form feed (0x0c) |
| `\n` | Newline (0x0a) |
| `\r` | Carriage return (0x0d) |
| `\t` | Horizontal tab (0x09) |
| `\v` | Vertical tab (0x0b) |
| `\\` | Backslash |
| `\'` | Single quote |
| `\"` | Double quote |
| `\?` | Question mark |
| `\nnn` | Octal value (1–3 digits) |
| `\xHH` | Hex value (1–2 digits) |
| `\uHHHH` | Unicode (4 hex) |
| `\UHHHHHHHH` | Unicode (8 hex) |
| `\cX` | Control-X |

## Appendix G — Glob and Extglob Patterns

| Pattern | Matches |
|---------|---------|
| `*` | Zero or more characters |
| `?` | Exactly one character |
| `[abc]` | Any of a, b, c |
| `[a-z]` | Any character in range |
| `[!abc]`, `[^abc]` | Any except a, b, c |
| `[[:class:]]` | POSIX character class |
| `**` | Zero or more directories (with `globstar`) |
| `?(pat\|pat)` | Zero or one occurrence (extglob) |
| `*(pat\|pat)` | Zero or more occurrences (extglob) |
| `+(pat\|pat)` | One or more occurrences (extglob) |
| `@(pat\|pat)` | Exactly one occurrence (extglob) |
| `!(pat\|pat)` | Anything except (extglob) |

POSIX character classes: `alnum`, `alpha`, `ascii`, `blank`, `cntrl`, `digit`, `graph`, `lower`, `print`, `punct`, `space`, `upper`, `word`, `xdigit`.

## Appendix H — Conditional Expression Operators

For use inside `[[ ]]`.

**File tests (single operand):**

| Operator | True if |
|----------|---------|
| `-e file` | exists |
| `-f file` | regular file |
| `-d file` | directory |
| `-L file`, `-h file` | symlink |
| `-b file` | block device |
| `-c file` | character device |
| `-p file` | FIFO |
| `-S file` | socket |
| `-r file` | readable |
| `-w file` | writable |
| `-x file` | executable |
| `-s file` | non-zero size |
| `-N file` | modified since last read |
| `-O file` | owned by EUID |
| `-G file` | group owned by EGID |
| `-k file` | sticky bit |
| `-u file` | SUID bit |
| `-g file` | SGID bit |
| `-t fd` | fd is a terminal |

**File comparisons:**

| Operator | True if |
|----------|---------|
| `f1 -nt f2` | f1 newer than f2 |
| `f1 -ot f2` | f1 older than f2 |
| `f1 -ef f2` | same inode |

**String tests:**

| Operator | True if |
|----------|---------|
| `-z str` | empty |
| `-n str` | non-empty |
| `-v var` | variable set |
| `-R name` | name is a nameref |
| `s1 = s2`, `s1 == s2` | strings equal |
| `s1 != s2` | strings not equal |
| `s1 < s2` | s1 lexically less |
| `s1 > s2` | s1 lexically greater |
| `s == pattern` | glob match |
| `s =~ regex` | ERE match |

## Appendix I — Parameter Expansion Cheat Sheet

| Form | Effect |
|------|--------|
| `$var`, `${var}` | Value |
| `${var:-default}` | Default if unset/empty |
| `${var-default}` | Default if unset only |
| `${var:=default}` | Assign default; same usage |
| `${var=default}` | Assign default if unset only |
| `${var:?msg}` | Error if unset/empty |
| `${var?msg}` | Error if unset only |
| `${var:+alt}` | alt if set/non-empty |
| `${var+alt}` | alt if set only |
| `${var:offset}` | Substring from offset |
| `${var:offset:length}` | Substring of length |
| `${#var}` | Length |
| `${var#prefix}` | Remove shortest prefix |
| `${var##prefix}` | Remove longest prefix |
| `${var%suffix}` | Remove shortest suffix |
| `${var%%suffix}` | Remove longest suffix |
| `${var/old/new}` | Replace first |
| `${var//old/new}` | Replace all |
| `${var/#old/new}` | Replace if at start |
| `${var/%old/new}` | Replace if at end |
| `${var^}` | Uppercase first |
| `${var^^}` | Uppercase all |
| `${var,}` | Lowercase first |
| `${var,,}` | Lowercase all |
| `${!var}` | Indirect |
| `${!prefix*}`, `${!prefix@}` | Names matching prefix |
| `${!arr[@]}` | Array indices |
| `${var@Q}` | Quoted form |
| `${var@E}` | Escape-interpreted |
| `${var@P}` | Prompt-expanded |
| `${var@A}` | Assignment form |
| `${var@a}` | Attributes |
| `${var@K}`, `${var@k}` | Assoc-array form (5.2+) |
| `${var@U}`, `${var@u}`, `${var@L}` | Case forms |

## Appendix J — Redirection Operators

| Operator | Effect |
|----------|--------|
| `< file` | Open file for reading on fd 0 |
| `n< file` | Open on fd n |
| `> file` | Open for writing on fd 1, truncate |
| `>> file` | Append on fd 1 |
| `>\| file` | Force overwrite (ignore noclobber) |
| `&> file` | `> file 2>&1` shorthand |
| `&>> file` | `>> file 2>&1` shorthand |
| `<&n`, `n<&m` | Duplicate fds for reading |
| `>&n`, `n>&m` | Duplicate fds for writing |
| `<&-`, `>&-` | Close fd 0, fd 1 |
| `n<&-`, `n>&-` | Close fd n |
| `n<&m-`, `n>&m-` | Move fd m to n (close m) |
| `<> file` | Open for read+write |
| `<<DELIM` | Here-document |
| `<<-DELIM` | Here-document, strip leading tabs |
| `<<<"str"` | Here-string |
| `\| cmd` | Pipe stdout to cmd |
| `\|& cmd` | Pipe stdout+stderr to cmd |
| `<(cmd)` | Process substitution (read) |
| `>(cmd)` | Process substitution (write) |

## Appendix K — Signal Numbers (Linux)

Standard signals on Linux x86-64. Use `kill -l` for the authoritative local list.

| # | Name | Default action |
|---|------|----------------|
| 1 | HUP | Terminate |
| 2 | INT | Terminate |
| 3 | QUIT | Core dump |
| 4 | ILL | Core dump |
| 5 | TRAP | Core dump |
| 6 | ABRT | Core dump |
| 7 | BUS | Core dump |
| 8 | FPE | Core dump |
| 9 | KILL | Terminate (uncatchable) |
| 10 | USR1 | Terminate |
| 11 | SEGV | Core dump |
| 12 | USR2 | Terminate |
| 13 | PIPE | Terminate |
| 14 | ALRM | Terminate |
| 15 | TERM | Terminate |
| 16 | STKFLT | Terminate |
| 17 | CHLD | Ignore |
| 18 | CONT | Continue |
| 19 | STOP | Stop (uncatchable) |
| 20 | TSTP | Stop |
| 21 | TTIN | Stop |
| 22 | TTOU | Stop |
| 23 | URG | Ignore |
| 24 | XCPU | Core dump |
| 25 | XFSZ | Core dump |
| 26 | VTALRM | Terminate |
| 27 | PROF | Terminate |
| 28 | WINCH | Ignore |
| 29 | IO/POLL | Terminate |
| 30 | PWR | Terminate |
| 31 | SYS | Core dump |
| 34–64 | RTMIN..RTMAX | Terminate |

## Appendix L — Exit Code Conventions

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage error |
| 3 | File not found |
| 5 | I/O error |
| 13 | Permission denied |
| 18 | Missing dependency |
| 22 | Invalid argument |
| 24 | Timeout |
| 64–113 | sysexits.h |
| 126 | Found but not executable |
| 127 | Command not found |
| 128 + N | Killed by signal N |

`sysexits.h`: 64=USAGE, 65=DATAERR, 66=NOINPUT, 67=NOUSER, 68=NOHOST, 69=UNAVAILABLE, 70=SOFTWARE, 71=OSERR, 72=OSFILE, 73=CANTCREAT, 74=IOERR, 75=TEMPFAIL, 76=PROTOCOL, 77=NOPERM, 78=CONFIG.

## Appendix M — Bash Version History

| Version | Year | Notable additions |
|---------|------|-------------------|
| 1.0 | 1989 | Initial release |
| 2.0 | 1996 | New parser; large rewrite |
| 3.0 | 2004 | `=~`, `+=`, multi-character `IFS` |
| 3.2 | 2006 | Bug fixes; macOS perpetual baseline |
| 4.0 | 2009 | Associative arrays, coprocesses, `mapfile`, `&>>`, `**`, `;&`/`;;&`, `read -i`, autocd |
| 4.1 | 2009 | `printf -v` for arrays, `BASH_XTRACEFD`, `&>` |
| 4.2 | 2011 | `declare -g`, `printf %(fmt)T`, `lastpipe` |
| 4.3 | 2014 | Namerefs (`declare -n`), `mapfile -d`, `wait -n` |
| 4.4 | 2016 | `${var@…}` transformations, `local -`, `inherit_errexit` |
| 5.0 | 2019 | `EPOCHSECONDS`, `EPOCHREALTIME`, `BASH_ARGV0`, history range delete |
| 5.1 | 2020 | `SRANDOM`, `wait -p`, `BASH_REMATCH` reset |
| 5.2 | 2022 | Recursive bison grammar for command substitution, `varredir_close`, `${var@k}`, `globskipdots`, `noexpand_translation` |
| 5.3 | 2025 | No-fork `${ cmd; }` command substitution, multi-coproc improvements |

## Appendix N — Glossary

- **alias** — string substitution at command position (vs function).
- **arithmetic context** — `(( ))` and `$(( ))`; integer-only.
- **array** — ordered (indexed) or keyed (associative) variable.
- **AND-OR list** — `cmd && cmd` or `cmd || cmd` short-circuit chain.
- **builtin** — command implemented inside bash, no fork.
- **brace expansion** — generative pattern `{a,b,c}` or `{1..N}`.
- **brace group** — `{ …; }` runs in current shell.
- **command substitution** — `$(cmd)` captures stdout.
- **compound command** — `if`, `case`, `while`, `for`, `select`, `(( ))`, `[[ ]]`, `( )`, `{ }`.
- **coproc** — process with bidirectional pipe to current shell.
- **dynamic scope** — function locals visible to callees (bash's model).
- **exec** — `execve(2)` or shell `exec` (replaces shell image).
- **expansion** — one of eight transformations bash applies to words.
- **fd** — file descriptor; integer index into kernel's open-files table.
- **FIFO** — named pipe; file-system-resident.
- **fork** — `fork(2)`; duplicates current process.
- **glob** — pathname expansion pattern.
- **here-document** — inline stdin via `<<DELIM`.
- **here-string** — inline stdin via `<<<`.
- **IFS** — internal field separator; controls word splitting.
- **inherit_errexit** — shopt that propagates `-e` into command substitutions.
- **job control** — bash's tracking of background jobs.
- **lastpipe** — shopt; runs last pipeline element in current shell.
- **list** — sequence of pipelines separated by `;`, `&`, `&&`, `||`, or newline.
- **local** — function-scoped variable; dynamic scope.
- **loadable** — externally-loadable builtin via `enable -f`.
- **nameref** — variable holding the name of another variable.
- **nullglob** — shopt; empty glob expands to nothing.
- **pipeline** — `cmd1 | cmd2`; kernel-allocated pipe between processes.
- **PID** — process identifier.
- **POSIX** — IEEE 1003.1 / SUSv4 specification.
- **process group** — set of processes that receive terminal signals together.
- **process substitution** — `<(cmd)` or `>(cmd)`; gives `/dev/fd/N` path.
- **PTY** — pseudo-terminal; master/slave pair for terminal emulation.
- **readline** — GNU library for command-line editing.
- **REPL** — read-eval-print loop; the interactive shell.
- **session** — collection of process groups sharing a controlling terminal.
- **shopt** — shell option (distinct from `set -o`).
- **simple command** — single command with arguments and redirections.
- **subshell** — forked child shell; variable changes do not propagate to parent.
- **trap** — handler for signals or pseudo-signals (EXIT, ERR, DEBUG, RETURN).
- **TTY** — terminal device.
- **word** — token after expansion; may be empty.
- **word splitting** — splitting unquoted expansions on IFS.

## Appendix O — Cross-Reference: Sections to BCS Sections

Map from this document's chapters to relevant BCS coding-standard sections.

| BCS Section | Title | Chapters |
|-------------|-------|----------|
| §01 | Script Structure & Layout | §22.1, §22.2, §2.4, §2.5 |
| §02 | Variables | Part IV (4.1–4.14) |
| §03 | Strings & Quoting | Part III (3.4–3.9), §5.4 |
| §04 | Functions | Part IX, Part X |
| §05 | Control Flow | Part VII, Part VIII |
| §06 | Error Handling | Part XIII |
| §07 | I/O & Messaging | Part VI, Part XIV |
| §08 | Command-Line Processing | Part XV |
| §09 | File Operations | §1.3, §6.x, §17.x |
| §10 | Security | Part XX |
| §11 | Concurrency | Part XVI, Part XVII |
| §12 | Style & Development | Part XXI |
| §13 | Environment | §1.5, §2.5–§2.6 |

## Appendix P — Cross-Reference: Sections to BCS-bash Files

Map from chapters to the strict-mode rewritten man-page reference.

| Chapter | BCS-bash File |
|---------|---------------|
| §1.x | (Unix model — not bash-specific) |
| §2.4–§2.7 | `06_INVOCATION.md`, `04_OPTIONS.md` |
| §3.4–§3.9 | `11_QUOTING.md` |
| §3.10 | `09_SHELL-GRAMMAR/` |
| §4.x | `12_PARAMETERS/` |
| §5.x | `13_EXPANSION/` |
| §6.x | `14_REDIRECTION/`, `09_SHELL-GRAMMAR/02_Pipelines.md` |
| §7.x | `09_SHELL-GRAMMAR/04_Compound-Commands.md` |
| §8.1–§8.8 | `18_CONDITIONAL-EXPRESSIONS.md` |
| §8.9–§8.13 | `17_ARITHMETIC-EVALUATION.md` |
| §9.x | `16_FUNCTIONS.md` |
| §10.x | `30_SHELL-BUILTIN-COMMANDS/02_dot-source.md` |
| §11.x | `25_JOB-CONTROL.md`, `21_COMMAND-EXECUTION-ENVIRONMENT.md` |
| §12.x | `24_SIGNALS.md`, `30_SHELL-BUILTIN-COMMANDS/48_trap.md` |
| §13.x | `23_EXIT-STATUS.md`, `30_SHELL-BUILTIN-COMMANDS/43_set.md` |
| §14.x | `30_SHELL-BUILTIN-COMMANDS/` (read, printf, mapfile) |
| §15.x | `30_SHELL-BUILTIN-COMMANDS/` (getopts) |
| §17.x | `09_SHELL-GRAMMAR/05_Coprocesses.md` |
| §18.x | `27_READLINE/`, `28_HISTORY.md`, `26_PROMPTING.md` |
| §22.x | `30_SHELL-BUILTIN-COMMANDS/` (various) |
| §23.x | (Cross-shell — not in BCS-bash) |
| §24.x | (Internals — see bash source) |
| §25.x | (Forward-looking — see Bash 5.3 NEWS) |

## Appendix Q — Further Reading

Authoritative resources for deeper study.

- **GNU Bash Reference Manual** — `https://www.gnu.org/software/bash/manual/`. The canonical authoritative source. Different organisation from `man bash`; tends to be more readable.
- **bash(1) man page** — local; the on-disk reference.
- **Greg's Wiki: BashFAQ, BashPitfalls, BashGuide** — `https://mywiki.wooledge.org/`. Greg Wooledge's site catalogues every wrong way to write Bash, with detailed explanations. BashFAQ and BashPitfalls are mandatory reading.
- **ShellCheck wiki** — `https://www.shellcheck.net/wiki/`. Every `SC####` warning has a page explaining the rule, the rationale, and the fix.
- **Bash Hackers Wiki** — `https://wiki.bash-hackers.org/`. Community reference; quality varies but the parameter-expansion and array pages are excellent.
- **bash-completion** — `https://github.com/scop/bash-completion`. Reference implementations of completion functions.
- **bats-core documentation** — `https://bats-core.readthedocs.io/`. The de facto bash test framework.
- **GNU coreutils manual** — `https://www.gnu.org/software/coreutils/manual/`. The external commands you'll compose. `info coreutils` is more thorough than the man pages.
- **POSIX 1003.1 Shell & Utilities** — `https://pubs.opengroup.org/onlinepubs/9699919799/`. The portable subset.
- **bash source repository** — `https://git.savannah.gnu.org/cgit/bash.git/`. The implementation truth.
- **bug-bash mailing list** — `https://lists.gnu.org/archive/html/bug-bash/`. Where bash development happens; Chet Ramey is responsive.
- **"Getting Serious about Bash"** — [`promo/getting-serious-about-bash.md`](promo/getting-serious-about-bash.md). Gary Dean's polemic on the state of professional Bash.
- **BCS coding standard** — [`../data/BASH-CODING-STANDARD.md`](../data/BASH-CODING-STANDARD.md). The actionable rules.
- **BCS-bash strict-mode reference** — [`BCS-bash/`](BCS-bash/). Bash 5.2 man page rewritten under strict-mode assumptions.

What to skip: TLDP "Advanced Bash-Scripting Guide" (last meaningful update 2014; teaches backticks); freeCodeCamp / W3Schools / GeeksforGeeks / TutorialsPoint Bash content (uniformly broken).

---

*End of reference.*

*This document is a structural reference guide — a comprehensive outline with briefing notes describing the intended content of each section. It identifies what an authoritative Bash 5.2+ reference must cover and how to organise it. Filling out each chapter into a fully written reference is the work that follows from this structure.*

#fin
