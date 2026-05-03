<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
