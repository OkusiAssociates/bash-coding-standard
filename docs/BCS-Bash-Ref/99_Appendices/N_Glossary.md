<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
