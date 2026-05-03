<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
