<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
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

#fin
