<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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
# ⇒ loaded N lines   (N depends on the host's /etc/hosts)
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

#fin
