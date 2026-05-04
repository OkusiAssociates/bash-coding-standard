<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.10 Associative arrays

Hash maps from string keys to string values, available since Bash 4.0.
The complement of indexed arrays: subscripts are arbitrary strings,
iteration order is **not** insertion order, and the type **must** be
declared before first use.

### Declaration

```bash
# scenario: every legitimate way to create an associative array
declare -A by_id                      # empty
declare -A by_id=()                   # empty, explicit
declare -A by_id=([alice]=42 [bob]=17)
declare -Ar STATIC=([a]=1 [b]=2)      # readonly + associative

# Function-scoped form (`local -A`) must appear inside a function:
demo() { local -A counts=(); declare -p counts | head -c 22; echo; }
demo                                  # ⇒ declare -A counts=()
```

The crucial rule: **declare with `-A` before any subscripted assignment.**
Bash does *not* infer associative-array intent from the use of string
subscripts.

### The undeclared-pitfall

```bash
# scenario: assigning a string subscript without -A
m[alice]=42
declare -p m
# ⇒ declare -a m=([0]="42")
```

Without `declare -A`, the subscript `alice` is *evaluated as
arithmetic*. An undefined name evaluates to `0` under arithmetic
evaluation (an exception to `set -u`'s usual behaviour, see §4.12), so
`m[alice]=42` becomes `m[0]=42` in a freshly-created indexed array.
Every subsequent string subscript also evaluates to `0`, silently
overwriting the same slot. This is one of Bash's nastier silent bugs;
the cure is unconditional discipline:

```bash
# right
declare -A m=()
m[alice]=42
m[bob]=17
```

### Reading and writing

```bash
declare -A by_id=([alice]=42 [bob]=17)

printf '%s\n' "${by_id[alice]}"   # ⇒ 42

by_id[alice]+=' (admin)'          # append-to-existing
printf '%s\n' "${by_id[alice]}"   # ⇒ 42 (admin)

by_id[carol]=99                   # new key
unset 'by_id[bob]'                # delete one key (quote!)
```

| Expression | Returns |
|------------|---------|
| `${by_id[k]}` | value for key `k`, or empty if absent |
| `"${by_id[@]}"` | all values, as separate words |
| `"${!by_id[@]}"` | all keys (in hash order — **not** sorted) |
| `${#by_id[@]}` | number of populated keys |
| `${#by_id[k]}` | byte length of value at key `k` |

### Membership testing

`${by_id[k]}` returns the empty string both when the key is missing
and when the value *is* the empty string. To distinguish, use `[[ -v
… ]]`:

```bash
# scenario: distinguishing absent key from empty value
declare -A m=([alice]=42 [bob]='')

[[ -v m[alice] ]] && printf 'alice: present (%s)\n' "${m[alice]}"
[[ -v m[bob]   ]] && printf 'bob:   present (%s)\n' "${m[bob]}"
[[ -v m[carol] ]] || printf 'carol: absent\n'
# ⇒ alice: present (42)
# ⇒ bob:   present ()
# ⇒ carol: absent
```

The `-v` test on `m[k]` is the only correct membership predicate for
associative arrays. Comparing `${m[k]:-}` to a sentinel value works
only if you can guarantee no legitimate value is the sentinel.

### Deterministic iteration

Hash-table order is not stable across Bash builds, across versions, or
across runs of the same script with different insertion orders. **Any
output that needs to be reproducible must explicitly sort the keys.**

```bash
# scenario: deterministic iteration via key sort
declare -A by_id=([carol]=99 [alice]=42 [bob]=17)

# Hash order — non-deterministic
for k in "${!by_id[@]}"; do
  printf '%-6s = %s\n' "$k" "${by_id[$k]}"
done
# (the three `key = value` lines come out in some hash-dependent order)

# Deterministic — sort keys explicitly
declare -a sorted=()
mapfile -t sorted < <(printf '%s\n' "${!by_id[@]}" | LC_ALL=C sort)
for k in "${sorted[@]}"; do
  printf '%-6s = %s\n' "$k" "${by_id[$k]}"
done
# ⇒ alice  = 42
# ⇒ bob    = 17
# ⇒ carol  = 99
```

The `LC_ALL=C` prefix forces byte-wise sort and avoids locale-dependent
collation surprises (German *ß*, Turkish *İ*, etc.). For numeric-string
keys, add `-n`; for case-insensitive sort, `-f`. See §22.7 for the
broader pattern.

### Operations summary

- **Add or replace**: `m[k]=v`
- **Append to value**: `m[k]+=more`
- **Delete one key**: `unset 'm[k]'` (quoting required)
- **Delete the array**: `unset m`
- **Empty without removing**: `m=()`
- **Copy**: no built-in deep copy; iterate keys.

```bash
# scenario: copying an associative array
declare -A copy=()
for k in "${!src[@]}"; do copy[$k]=${src[$k]}; done
```

### Pitfalls

- **Forgetting `declare -A`** — silently creates an indexed array (see
  above).
- **`unset m[k]`** without quotes — globbing risk if `m` happens to
  match a file pattern.
- **Iteration assumed ordered** — sort if order matters.
- **Numeric-looking string keys**: `m[1]` and `m['1']` and `m[$((0+1))]`
  all refer to the *same* key in an associative array (the key is the
  string `"1"`), but in an *indexed* array they refer to slot `1`.
  Discipline: declare type up front so the contract is unambiguous.

### See also

- §4.5 — `declare -A` and the attribute system
- §4.9 — indexed arrays (the integer-keyed sibling)
- §4.12 — arithmetic context and the `set -u`/zero edge case
- §4.14 — `unset` semantics and quoting requirements
- §22.7 — sorted iteration patterns
- BCS0201, BCS0206 (array declaration discipline)

#fin
