<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.9 Indexed arrays

The default array type in Bash. **Indexed** because subscripts are
integers; **sparse** because the indices need not be contiguous. An
indexed array stores zero or more string elements at arbitrary
non-negative integer positions, with no fixed length and no fixed
capacity.

### Creation and assignment

```bash
# scenario: every legitimate way to create an indexed array
declare -a a                    # empty, declared
declare -a b=()                 # empty, declared explicitly
declare -a c=(alpha beta gamma) # populated literal
declare -a d=([5]=x [10]=y)     # sparse literal

# Implicit creation by subscripted assignment
e[0]=first                      # creates e as indexed array

# Append (preserves existing elements; new ones go at end)
c+=(delta epsilon)
declare -p c
# ⇒ declare -a c=([0]="alpha" [1]="beta" [2]="gamma" [3]="delta" [4]="epsilon")
```

Always declare with `-a` (or `-ar` for readonly) at the point of
introduction — implicit creation works but obscures intent. See
BCS0201 and BCS0206.

### Reading elements and metadata

| Expression | Returns |
|------------|---------|
| `${arr[i]}` | element at index `i` (subscript is arithmetic) |
| `${arr[@]}` or `${arr[*]}` | all elements |
| `"${arr[@]}"` | all elements **as separate words** |
| `"${arr[*]}"` | all elements **joined by `IFS[0]`** |
| `${#arr[@]}` | element count (sparse: count of *populated* slots) |
| `${#arr[i]}` | byte-length of element `i` |
| `${!arr[@]}` | populated indices, ascending |
| `"${arr[@]:offset:length}"` | slice of `length` elements starting at *position* (not index) |
| `"${arr[i]:offset:length}"` | substring slice of element `i` |

The `[@]` versus `[*]` distinction is the same load-bearing rule as for
positional parameters (§4.2): `"${arr[@]}"` preserves word boundaries;
`"${arr[*]}"` collapses to one word.

### Sparse arrays

Bash arrays are sparse. Unset elements simply have no index; they do
not exist as "empty slots". `${#arr[@]}` counts *populated* indices,
not the maximum index.

```bash
# scenario: sparse-array semantics
declare -a arr=(a b c)
arr[10]=x
arr[20]=y
unset 'arr[1]'

printf 'count: %d\n' "${#arr[@]}"
# ⇒ count: 4   (indices 0, 2, 10, 20)

printf 'indices: %s\n' "${!arr[*]}"
# ⇒ indices: 0 2 10 20

# Iterating values gives elements only, in index order:
for v in "${arr[@]}"; do printf '<%s>\n' "$v"; done
# ⇒ <a> <c> <x> <y>

# To know which index each value lives at, iterate "${!arr[@]}":
for i in "${!arr[@]}"; do
  printf '[%d]=%s\n' "$i" "${arr[i]}"
done
```

### The copy pitfall

`new=("${old[@]}")` produces a **re-indexed** copy: indices `0, 2, 10,
20` collapse to `0, 1, 2, 3`. This is almost always what you want, but
it loses the sparse structure. To preserve indices verbatim, copy
through the populated-index list.

```bash
# scenario: re-indexing copy versus index-preserving copy
declare -a old=([0]=a [2]=c [10]=x [20]=y)

# Re-indexing copy — sparseness lost
declare -a flat=("${old[@]}")
declare -p flat
# ⇒ declare -a flat=([0]="a" [1]="c" [2]="x" [3]="y")

# Index-preserving copy
declare -a same=()
for i in "${!old[@]}"; do same[i]=${old[i]}; done
declare -p same
# ⇒ declare -a same=([0]="a" [2]="c" [10]="x" [20]="y")
```

The re-indexing copy is sometimes *intended* — for example, when
collapsing a logical "list" that happened to have holes. State the
intent explicitly with a comment if it matters.

### Iteration

The two correct iteration idioms — pick whichever fits.

```bash
declare -a paths=("/etc/passwd" "/var/log/app.log" "name with space")

# Idiom 1: iterate values directly (most common)
for p in "${paths[@]}"; do
  [[ -f $p ]] || continue
  printf 'exists: %s\n' "$p"
done
# ⇒ exists: /etc/passwd
# ⇒ (other paths skipped if absent)

# Idiom 2: iterate indices (when you need the index)
for i in "${!paths[@]}"; do
  printf '[%d] %s\n' "$i" "${paths[i]}"
done
# ⇒ [0] /etc/passwd
# ⇒ [1] /var/log/app.log
# ⇒ [2] name with space
```

Always quote `"${arr[@]}"` — otherwise each element is re-split on
`IFS` and subjected to pathname expansion. See BCS0301 and BCS0206.

### Common operations

- **Append**: `arr+=(x y z)` — add elements at the next free index.
- **Element append**: `arr[3]+='more'` — append to a single element.
- **Delete one element**: `unset 'arr[2]'` — quoting required to
  prevent globbing of `arr[2]` against files in `cwd` when `[`/`]` are
  active glob characters.
- **Delete the array**: `unset arr` — gone, attribute and all.
- **Read a file as lines**: `mapfile -t arr < file` — see §14.3.
- **Length**: `${#arr[@]}` (count) versus `${#arr[i]}` (byte length of
  element `i`).

### Slicing and substring operations

```bash
# scenario: array slicing and per-element substring
declare -a a=(zero one two three four five)

# Slice: position-based, not index-based
printf '%s\n' "${a[@]:1:3}"
# ⇒ one
# ⇒ two
# ⇒ three

# Slice from the end: ${a[@]: -2} (the leading space is required)
printf '%s\n' "${a[@]: -2}"
# ⇒ four
# ⇒ five

# Substring of one element
printf '%s\n' "${a[2]:1:2}"   # element 2 = "two", chars 1-2 = "wo"
# ⇒ wo
```

The slice `${arr[@]:offset:length}` indexes by *position* in the
populated-elements list, not by raw index value. For a sparse array
this is rarely what you want; iterate `"${!arr[@]}"` instead and
filter explicitly.

### Common operations

- **Append**: `arr+=(x y z)` — add elements at the next free index.
- **Element append**: `arr[3]+='more'` — append to a single element.
- **Delete one element**: `unset 'arr[2]'` — quoting required to
  prevent globbing of `arr[2]` against files in `cwd` when `[`/`]` are
  active glob characters.
- **Delete the array**: `unset arr` — gone, attribute and all.
- **Empty without removing**: `arr=()`.
- **Read a file as lines**: `mapfile -t arr < file` — see §14.3.
- **Length**: `${#arr[@]}` (count) versus `${#arr[i]}` (byte length of
  element `i`).
- **Reverse**: no built-in; iterate indices in descending order.
- **Sort**: no built-in; pipe to `sort` and `mapfile -t` back.

```bash
# scenario: sorting an array (LC_ALL=C for byte-wise stability)
declare -a names=(carol alice bob)
mapfile -t names < <(printf '%s\n' "${names[@]}" | LC_ALL=C sort)
declare -p names
# ⇒ declare -a names=([0]="alice" [1]="bob" [2]="carol")
```

### Pitfalls in one place

- **Unquoted expansion**: `for x in ${arr[@]}` re-splits and globs.
  Always `"${arr[@]}"`.
- **`unset arr[i]` without quoting**: a literal file named `arr2` in
  the cwd will be matched and remove the wrong thing. Always
  `unset 'arr[i]'`.
- **`${arr}` with no subscript** is `${arr[0]}` — a frequent silent
  bug when the array is meant to expand to all elements.
- **Comparing two arrays for equality** is not built in — iterate both
  via `${!arr[@]}` and compare element-by-element.
- **Slice offsets are position-based on sparse arrays**. Element 0 in
  the slice is the first *populated* element, not the element at
  index 0.

### See also

- §4.2 — positional parameters (also a sparse word array)
- §4.10 — associative arrays
- §4.13 — compound array assignment expansion rules
- §4.14 — `unset` semantics and quoting
- §14.3 — `mapfile`/`readarray` for line-oriented input
- BCS0201, BCS0206 (array declaration and discipline)

#fin
