<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
