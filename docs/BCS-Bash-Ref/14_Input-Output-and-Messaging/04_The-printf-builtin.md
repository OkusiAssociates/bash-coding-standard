<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
