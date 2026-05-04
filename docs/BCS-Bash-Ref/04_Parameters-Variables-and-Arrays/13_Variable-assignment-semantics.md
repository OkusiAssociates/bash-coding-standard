<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.13 Variable assignment semantics

The exact sequence of operations that take place when Bash executes
`name=value`. This is not "how to assign a variable" — it is which
**expansions** apply, in which **order**, and how scalar versus
compound array assignment differ. Most surprises in Bash come from
the differences listed here.

### The scalar assignment pipeline

For `name=value` (scalar):

1. RHS is subject to **tilde expansion**, **parameter expansion**,
   **command substitution**, **arithmetic expansion**, and **process
   substitution**.
2. RHS is **NOT** subject to **word splitting** or **pathname
   expansion** (globbing).
3. The resulting single string is bound to `name`.

This is why `arr2=$1` works correctly even when `$1` contains spaces or
`*` — those characters are taken literally on the RHS of a scalar
assignment.

```bash
# scenario: scalar RHS — no splitting, no globbing
shopt -s nullglob
declare -- pattern='*.txt'

# Inside an assignment, '*' is a literal asterisk:
declare -- str=$pattern
printf '%s\n' "$str"            # ⇒ *.txt    (literal)

# But the same expression as a command argument *does* glob.
# Set up two matching files so the glob has something to expand to:
: > a.txt && : > b.txt
# shellcheck disable=SC2086  # demoing word-splitting/globbing on purpose
printf '%s\n' $pattern
# ⇒ a.txt
# ⇒ b.txt
# (without the demo files, nullglob would expand $pattern to nothing)
```

`declare name=value`, `local name=value`, `readonly name=value`, and
`export name=value` all follow the **same** scalar assignment pipeline:
no splitting, no globbing on the RHS.

### The compound array assignment pipeline

For `arr=( word1 word2 … )` (compound):

1. Each *word* between the parentheses is independently subject to
   **all** expansions, including **tilde**, **parameter**, **command
   substitution**, **arithmetic**, **process substitution**, **word
   splitting**, **AND pathname expansion**.
2. The resulting list of words populates the array, one element per
   resulting word.

The presence of word splitting and globbing is the load-bearing
difference: a value that's safe in a scalar assignment is *not*
necessarily safe in a compound assignment.

```bash
# scenario: scalar vs compound, side by side
shopt -s nullglob
declare -- a='one two three'
declare -- glob='*.md'

# Scalar: the entire RHS is one string
declare -- s1=$a
printf 'scalar: <%s>\n' "$s1"
# ⇒ scalar: <one two three>

# Compound, unquoted reference: word splitting happens
declare -a arr1=( $a )
printf 'arr1[%d]=<%s>\n' 0 "${arr1[0]}" 1 "${arr1[1]}" 2 "${arr1[2]}"
# ⇒ arr1[0]=<one>
# ⇒ arr1[1]=<two>
# ⇒ arr1[2]=<three>

# Compound, quoted reference: one element preserved
declare -a arr2=( "$a" )
printf 'arr2[%d]=<%s>\n' 0 "${arr2[0]}"
# ⇒ arr2[0]=<one two three>

# Compound, unquoted glob: PATHNAME EXPANSION happens
: > demo1.md && : > demo2.md
# shellcheck disable=SC2206  # word-splitting + globbing into array is the demo
declare -a arr3=( $glob )
declare -p arr3
# ⇒ declare -a arr3=
# (with the two demo files above, expect `[0]="demo1.md" [1]="demo2.md"`;
#  without matching files plus `nullglob`, the array stays empty)
```

The rule of thumb: inside `( … )`, treat each word exactly as you
would treat a command argument — quote whenever you would quote a
command argument.

### Append assignment `+=`

- **Scalar `+=`**: appends to the existing value.
  `s='hello, '; s+='world'` ⇒ `'hello, world'`.
- **Integer `-i` `+=`**: arithmetic addition.
  `declare -i n=5; n+=3` ⇒ `8`.
- **Indexed array `+=`**: appends elements at the next free index.
  `arr=(a b); arr+=(c d)` ⇒ `(a b c d)`.
- **Associative array `+=`**: same expansion rules as `=` for the new
  pairs.
- **Single element `arr[i]+=`**: appends to that one element's value.

`+=` preserves the variable's attributes; `=` also preserves them
(despite a persistent myth otherwise). The only way to remove an
attribute is `declare +X` or `unset`.

### Array subscripts are arithmetic

In `arr[i]=value`, the subscript `i` is evaluated in arithmetic
context. This is true for both indexed and associative arrays —
**except** that for an associative array, the *result* of arithmetic
evaluation is a string and is used as a key as-is.

```bash
declare -a a=()
declare -i offset=2
a[offset+1]='foo'         # → assigns to a[3] (subscript is arithmetic)
declare -p a              # ⇒ declare -a a=([3]="foo")

declare -A m=()
m[$((1+1))]='bar'         # key is the literal string "2"
declare -p m              # ⇒ declare -A m=
# (key "2", value "bar"; bash 5.2 prints `[2]="bar" )` with a trailing space)
```

### Multiple assignments on one line

```bash
a=1 b=2 c=3 cmd          # all in cmd's environment, NOT in current shell
a=1 b=2                  # all in CURRENT shell (no command follows)
```

The *presence of a command* changes the scope. With a command, the
assignments are temporary exports for that command's environment only
(see §4.8 for the assignment-prefix-command rule). Without a command,
the assignments persist in the current shell.

### `declare -i` and RHS arithmetic

A variable with the `-i` attribute interprets its RHS as an arithmetic
expression on every assignment:

```bash
declare -i x
x='2 + 3'                # ⇒ x=5
x=$(date +%s)            # date's output is a digit string ⇒ valid integer
x='hello'                # ⇒ x=0  (non-numeric reduces to 0; no error!)
```

The silent reduction of non-numeric strings to `0` is a known footgun
— validate input *before* assigning to an `-i` variable when the
source is untrusted.

### Read-only at assignment time

```bash
declare -r x=42
(x=43) 2>&1 || true      # → "bash: x: readonly variable" on stderr
# (the subshell isolates the failing assignment so the outer set -e
#  shell stays alive)
```

Readonly is enforced at assignment, not at declaration. There is no
mechanism to remove `-r` before script exit.

### See also

- §4.5 — `declare` and the attribute system
- §4.8 — assignment-prefixed commands and exports
- §4.9, §4.10 — array creation and indexing details
- §13 — full expansion rules (tilde, parameter, command, arithmetic, …)
- BCS0201 (type-specific declarations), BCS0301 (quoting fundamentals)

#fin
