<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
