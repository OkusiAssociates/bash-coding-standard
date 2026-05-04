<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
