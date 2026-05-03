<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
