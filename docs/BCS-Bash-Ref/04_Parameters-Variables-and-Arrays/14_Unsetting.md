<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.14 Unsetting

`unset` removes a variable or a function from the shell's symbol
tables. Three flag forms disambiguate the target, and a quoting rule
applies when an array element is the target. The operation is the
mirror of `declare`: both create and destroy storage, both honour the
readonly bar.

### Surface area

- `unset name` — variable, falling back to function if no variable
  with that name exists. Ambiguous; prefer the explicit forms.
- `unset -v name` — variable only.
- `unset -f name` — function only.
- `unset -n name` — when `name` is a nameref, remove the *nameref*
  (not the target it points at). Without `-n`, `unset name` on a
  nameref unsets the **target**.
- `unset 'arr[i]'` — remove a single array element. The single-quotes
  are mandatory to suppress pathname expansion of `[`/`]`.
- `unset arr` — remove the entire array.
- Readonly variables cannot be unset (§4.7).
- Unsetting an exported variable removes it from `environ` as well as
  from the shell.

### Quoting `unset 'arr[i]'`

The `[` and `]` brackets are pathname-expansion metacharacters. With
`shopt -s nullglob` (BCS-default per §5.11) and a glob pattern matching
no files, an unquoted `unset arr[0]` becomes `unset` with no arguments
— silent no-op. Without `nullglob`, an unrelated file named literally
`arr[0]` could be matched. The single-quotes prevent both surprises:

```bash
# scenario: array-element unset must be quoted
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -a arr=(zero one two three)
printf '%s\n' "${arr[@]}"           # ⇒ zero one two three

# wrong — at the very least relies on glob luck:
# unset arr[1]                      # may glob, may silently no-op

# right — explicit single-quotes
unset 'arr[1]'
printf '%s\n' "${!arr[@]}"          # ⇒ 0 2 3   (sparse: index 1 gone)
printf '%s\n' "${arr[@]}"           # ⇒ zero two three

# Note: indices do **not** renumber. To compact:
arr=("${arr[@]}")
printf '%s\n' "${!arr[@]}"          # ⇒ 0 1 2
```

### Nameref unset — `-n` is the loaded form

For a regular variable, `unset name` removes the variable. For a
nameref, `unset name` follows the indirection and unsets the **target**
— almost never what the author intends. `unset -n name` removes the
nameref binding itself and leaves the target alone:

```bash
# scenario: -n distinguishes "remove the alias" from "remove the value"
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- target='hello'
declare -n alias_=target           # nameref → target

printf 'before:   target=%s alias_=%s\n' "$target" "$alias_"
# ⇒ before:   target=hello alias_=hello

# unset alias_   would unset target — usually wrong
unset -n alias_
printf 'after -n: target=%s alias_=%s\n' "$target" "${alias_:-<unbound>}"
# ⇒ after -n: target=hello alias_=<unbound>
```

### Pitfalls

- **`unset BASH_REMATCH`** after `[[ str =~ re ]]` silently undoes the
  match groups. Capture them into a local array first.
- **Sparse indices after element-unset** — see the example above. The
  `arr=("${arr[@]}")` re-indexing idiom is the canonical compaction
  (BCS0206, §4.9).
- **`unset` of a `local`** while inside the defining function deletes
  the function-scope binding and re-exposes any outer-scope variable
  with the same name (dynamic scope, §4.6).
- **Readonly cannot be unset** (§4.7); `unset` errors and, under
  `set -e`, terminates the script.
- **`unset name` of a function variable removes the variable**, not
  any same-named function. `unset -f name` is the function-only form.

### BCS posture

- Always quote array-element targets: `unset 'arr[i]'` (BCS0301).
- Always prefer the explicit flag — `unset -v` for variables,
  `unset -f` for functions — to avoid the fallback ambiguity.
- Use `-n` whenever a nameref binding is the intended target; the
  unflagged form is almost always wrong with namerefs (BCS0202).
- After deleting an exported variable, remember it is also gone from
  child environments — re-export if children spawned later still need
  it (BCS0204).

**See also**: §4.5 (`declare`/attributes), §4.6 (`local --` and
dynamic scope), §4.7 (readonly bar), §4.9 (indexed arrays and
sparseness), §4.11 (namerefs).

#fin
