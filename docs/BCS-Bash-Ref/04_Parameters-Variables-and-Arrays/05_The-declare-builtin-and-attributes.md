<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.5 The `declare` builtin and attributes

Every Bash variable carries a set of *attributes* — a small fixed bag
of flags that determine its type, scope, mutability, and export status.
`declare` (alias `typeset`) sets those attributes; `local`, `readonly`,
`export`, and `nameref` are conventional spellings of common
combinations. Attributes are the only static type system Bash has, and
the BCS rule is to use them everywhere a variable is introduced.

### Attribute reference

| Flag | Meaning | Mutual exclusion |
|------|---------|------------------|
| `--` | Terminate option processing; declare with no extra attribute (just a string) | — |
| `-i` | Integer; assignments are evaluated as arithmetic | excludes `-a`/`-A` value semantics on RHS |
| `-a` | Indexed array | mutually exclusive with `-A` |
| `-A` | Associative array | mutually exclusive with `-a` |
| `-r` | Readonly (immutable thereafter) | applies on top of any other attribute |
| `-x` | Export to the environment of children | applies on top of any other attribute |
| `-l` | Convert value to lowercase on assignment | mutually exclusive with `-u` |
| `-u` | Convert value to uppercase on assignment | mutually exclusive with `-l` |
| `-n` | Nameref — value is the *name* of another variable (§4.11) | replaces other type flags on the ref itself |
| `-t` | Function trace flag (only meaningful for functions) | — |
| `-g` | Declare a *global* from inside a function | combine with any type flag |
| `-p` | Print declarations (introspection only) | not a type flag |
| `-f`, `-F` | Operate on functions (`-f` body, `-F` name only) | not type flags for variables |

`declare +X` removes attribute `X`. The `+` form cannot remove `-r`:
once readonly, always readonly until process exit.

### Worked examples

```bash
# scenario: integer attribute makes RHS arithmetic
declare -i count=0
count='2 + 3'           # ⇒ count=5  (arithmetic context applied)
count=0xff              # ⇒ count=255
count='abc'             # ⇒ count=0  (non-numeric reduces to 0)

declare -p count        # ⇒ declare -i count="0"
```

The `-i` attribute makes assignments **silent arithmetic** — usually
desired for counters, occasionally surprising when a string sneaks
through. Pair with `set -u` and explicit defaults; never feed
user-controlled data into an `-i` variable without validation.

```bash
# scenario: indexed and associative arrays
declare -a words=(alpha beta gamma)
words+=(delta)
declare -p words
# ⇒ declare -a words=([0]="alpha" [1]="beta" [2]="gamma" [3]="delta")

declare -A by_id=([alice]=42 [bob]=17)
by_id[carol]=99
declare -p by_id
# ⇒ declare -A by_id=(
# (key order is hash-dependent; expect `[alice]="42" [bob]="17" [carol]="99"`
#  in some order, with each value double-quoted)
```

The associative array **must** be declared before first use — there is
no implicit conversion; assigning to an undeclared name creates an
indexed array with index `0`, silently masking the bug.

```bash
# scenario: combining attributes — the BCS idiom for a readonly array
declare -ar VALID_TIERS=(core recommended style disabled)

# scenario: nameref for output parameters
get_user() {
  local -n out=$1
  out='alice'
}
declare -- name=''
get_user name
printf '%s\n' "$name"   # ⇒ alice

# scenario: explicit export
declare -x PATH="/usr/local/bin:$PATH"
declare -rx FROZEN_VERSION='1.0.0'   # readonly + exported in one statement
```

### Combining attributes — order and precedence

- `-r` and `-x` *stack* on top of any type flag: `declare -ax CFG=(…)`
  exports an indexed array to children; `declare -ir N=42` is a
  readonly integer.
- `-l`/`-u` apply on assignment, after expansion. They affect the
  stored value, not just display.
- `-i` overrides RHS interpretation: `declare -i x='2+3'` stores `5`,
  not the string `2+3`.
- `-n` is **special**: it makes the variable a reference. Combining
  `-n` with `-i` or `-a` is meaningless — the type comes from the
  *target*. Always declare the nameref alone: `local -n ref=$1`.

### `-g` — declaring a global from inside a function

By default a `declare` inside a function creates a *local*. The `-g`
flag forces a global declaration with the given attributes — useful
for one-time initialisation routines.

```bash
init_cache() {
  declare -gA CACHE=()        # global associative array
  declare -gi CACHE_HITS=0    # global integer counter
}
init_cache
CACHE[key]=value              # accessible at script scope
```

### Pitfalls

- **Assigning to an undeclared associative array** silently creates an
  *indexed* array.
  ```bash
  # wrong
  m[alice]=42                 # creates indexed array; 'alice' evaluates to 0
  # right
  declare -A m=([alice]=42)
  ```
- **Removing attributes** with `+`: `declare +i x` removes `-i` but
  cannot remove `-r`. There is no `+r`.
- **`declare` inside a function without `-g`** is local even when the
  variable name was previously a global — you have shadowed the
  global.
- **Spaces are forbidden** around `=` in any declaration:
  `declare x = 1` is parsed as the command `declare` with three
  operands.
- **Attribute persistence on append**: `arr+=( … )` preserves
  attributes; `arr=( … )` does **not** clear them. Once an array is
  associative, it stays associative until `unset`.

### Introspection: `declare -p`

`declare -p name` prints a re-loadable declaration of `name`, including
its attributes. `declare -p` with no name lists every variable.
Combining with `grep`/`compgen` is the standard debugging technique
when a value is "wrong" — print the declaration to see the attribute
set.

```bash
# scenario: introspecting attributes during debugging
declare -ir MAX=100
declare -ax PATHS=(/usr/bin /bin)
declare -A MAP=([a]=1 [b]=2)

declare -p MAX PATHS MAP
# ⇒ declare -ir MAX="100"
# ⇒ declare -ax PATHS=([0]="/usr/bin" [1]="/bin")
# ⇒ declare -A MAP=
# (associative-array key order is hash-dependent; both `[a]="1"` and
#  `[b]="2"` will appear, in some order)

# Filter all readonly variables visible to the script:
declare -p | grep -E '^declare -[^ ]*r '
```

`declare -F` lists *all* defined function names; `declare -F name`
prints just one; `declare -f name` prints the function body. Together
with `compgen -A function` they cover every common discovery use.

### Explicit attributes on `local`

Always declare locals with their intended attribute. Bare `local name`
behaviour around attribute inheritance has shifted across bash
versions; the explicit forms below remove that ambiguity entirely:

```bash
# scenario: explicit -i locals vs string-typed locals
declare -i counter=0          # integer at script scope

increment_int() {
  local -i counter            # explicit integer attribute
  counter='2 + 3'             # → arithmetic context: 5
  printf '%d\n' "$counter"    # ⇒ 5
}

increment_string() {
  local -- counter            # explicit string; arithmetic does not apply
  counter='2 + 3'
  printf '%s\n' "$counter"    # ⇒ 2 + 3
}

increment_int       # ⇒ 5
increment_string    # ⇒ 2 + 3
```

In bash 5.2, a bare `local name` (no attribute flag) does *not* reliably
inherit attributes from a same-named global; explicit `local --` for
strings and `local -i`/`local -a`/`local -A` for typed locals is the
unambiguous form that survives both attribute-inheritance changes
between bash versions and the BCS option-termination rule. See
BCS0202.

The `local --`/`local -i`/`local -a` forms are the BCS standard
precisely because they sever any attribute-inheritance dependency on
the global namespace.

### See also

- §4.6 — `local` (a function-scoped `declare`)
- §4.7 — `readonly` (the `-r` attribute alone)
- §4.8 — `export` (the `-x` attribute alone)
- §4.9, §4.10 — array creation and indexing details
- §4.11 — namerefs and the `-n` attribute in depth
- BCS0201 (type-specific declarations), BCS0202 (variable scoping)

#fin
