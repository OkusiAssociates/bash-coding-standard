<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.4 Parameter and variable expansion

Parameter expansion is the workhorse of bash scripting — the construct
that turns `${var}` into a value, and the only expansion rich enough to
substitute defaults, slice substrings, edit text, change case, and
reflect on attributes without spawning an external process. This
chapter documents the full operator catalogue with one or two-line
examples per group, in the order an experienced reader is most likely
to need them.

The general form is `${parameter}` or `${parameter operator argument}`.
Braces are required for every operator and for any reference where the
following character could be confused for part of the name (digits,
letters, underscore). Bare `$name` works only for simple references
followed by a non-name character.

### Bare reference and length

```bash
# scenario: simplest references and length operator
declare -- name='hello'
echo "$name"        # ⇒ hello
echo "${name}"      # ⇒ hello
echo "${#name}"     # ⇒ 5    — string length in characters

declare -a a=(one two three)
echo "${#a[@]}"     # ⇒ 3    — element count
echo "${#a[0]}"     # ⇒ 3    — length of element zero
```

`${#var}` counts characters, not bytes; multibyte characters under a
UTF-8 locale count as one. Cross-reference §5.13 for locale effects.

### Default, alternative, assign, error (the `:` family)

Each of these tests whether `var` is *unset or empty* (with the
colon) versus *unset only* (without). This colon distinction is the
single most-mis-remembered detail in parameter expansion.

| Operator | Test | Effect |
|----------|------|--------|
| `${var:-default}` | unset or empty | yield `default`; do not assign |
| `${var-default}`  | unset only     | yield `default`; do not assign |
| `${var:=default}` | unset or empty | assign `default` to `var`, yield it |
| `${var=default}`  | unset only     | assign `default`, yield it |
| `${var:?msg}`     | unset or empty | print `msg` to stderr, exit non-zero |
| `${var?msg}`      | unset only     | as above |
| `${var:+alt}`     | unset or empty | yield empty; otherwise yield `alt` |
| `${var+alt}`      | unset only     | yield empty; otherwise yield `alt` |

```bash
# scenario: defaults, assignment, and the unset-only distinction
declare -- empty=''
declare -- set='value'

echo "${unset:-fallback}"   # ⇒ fallback   — unset
echo "${empty:-fallback}"   # ⇒ fallback   — empty triggers `:`
echo "${empty-fallback}"    # ⇒            — empty does not trigger non-`:`
echo "${set:-fallback}"     # ⇒ value      — set, no fallback
echo "${set:+yes}"          # ⇒ yes        — set, alt yields
echo "${empty:+yes}"        # ⇒            — empty, alt yields nothing
```

Under `set -u` (BCS0601), `${var-default}` is the safe form for
"reference without erroring out": the `:-` and `-` forms are explicitly
exempt from `nounset` because they exist precisely to handle the unset
case.

### Substring extraction

```bash
# scenario: offset and length slicing
declare -- s='abcdefghij'
echo "${s:0:3}"     # ⇒ abc
echo "${s:3}"       # ⇒ defghij     — to end
echo "${s:3:2}"     # ⇒ de
echo "${s: -2}"     # ⇒ ij          — leading space mandatory for negative offset
echo "${s:0:-2}"    # ⇒ abcdefgh    — negative length means "stop N chars from end"
```

Negative offsets and negative lengths require a *space or paren* before
the minus sign — `${s:-2}` is the default operator from the previous
section, not a substring. Either `${s: -2}` or `${s:(-2)}` works.

For positional parameters, `${@:offset:length}` and `${*:offset:length}`
slice the argument list. For arrays, `${arr[@]:offset:length}` slices.

### Pattern removal (`#`, `##`, `%`, `%%`)

These strip a glob-matched prefix or suffix. Single is shortest match;
double is greediest.

```bash
# scenario: path manipulation without basename/dirname
declare -- path='/etc/cron.d/run-parts.sh'
echo "${path##*/}"   # ⇒ run-parts.sh   — greedy prefix removal: basename
echo "${path%/*}"    # ⇒ /etc/cron.d    — shortest suffix removal: dirname
echo "${path%.*}"    # ⇒ /etc/cron.d/run-parts   — strip last extension
echo "${path##*.}"   # ⇒ sh             — extension only
```

These operators avoid the fork cost of `basename`/`dirname` and are the
idiomatic bash form (BCS0207). The pattern is a glob, not a regex —
see §5.9 for syntax.

### Pattern substitution (`/`, `//`, `/#`, `/%`)

```bash
# scenario: replace, replace-all, anchored replacement
declare -- s='one two two three'
echo "${s/two/TWO}"     # ⇒ one TWO two three     — first match
echo "${s//two/TWO}"    # ⇒ one TWO TWO three     — all matches
echo "${s/#one/ONE}"    # ⇒ ONE two two three     — anchored to start
echo "${s/%three/THREE}"# ⇒ one two two THREE     — anchored to end

# Delete by replacing with empty
declare -- noisy='abc123def456'
echo "${noisy//[0-9]/}" # ⇒ abcdef                — delete all digits
```

The replacement may reference the matched text by `&` (Bash 5.2+) or
`\\&`; the `,` flag (Bash 5.2+) lower-cases each match: `${s//[A-Z]/,&}`.

### Case conversion

```bash
# scenario: title-case and full-case toggles
declare -- title='hello world'
echo "${title^}"        # ⇒ Hello world           — first char up
echo "${title^^}"       # ⇒ HELLO WORLD           — all up
echo "${title^^[hw]}"   # ⇒ Hello World           — pattern-restricted
declare -- shout='HELLO WORLD'
echo "${shout,}"        # ⇒ hELLO WORLD           — first char down
echo "${shout,,}"       # ⇒ hello world           — all down
```

These operators replace `tr [:upper:] [:lower:]` for ASCII strings
without forking. Locale-sensitive case folding is correct under a
UTF-8 locale (§5.13).

### Indirect references and prefix lists

```bash
# scenario: dereference a name held in another variable
declare -- target='HOME'
echo "${!target}"           # ⇒ /home/sysadmin     — value of $HOME

# Names matching a prefix (useful for env-var families)
declare -- BCS_MODEL='balanced' BCS_EFFORT='low' BCS_VERBOSE=1
printf '%s\n' "${!BCS_@}"   # ⇒ BCS_EFFORT BCS_MODEL BCS_VERBOSE
```

For arrays, `${!arr[@]}` yields *indices*, not values — essential for
sparse indexed arrays and all associative arrays:

```bash
declare -A by_name=([alice]=42 [bob]=17)
for k in "${!by_name[@]}"; do
  printf '%s=%s\n' "$k" "${by_name[$k]}"
done
# ⇒ alice=42
# ⇒ bob=17    (key order is unspecified for assoc arrays)
```

For nameref-based indirection (Bash 4.3+), prefer `declare -n` —
namerefs are safer and more readable than `${!var}` for write access.
See §4.11.

### Transformation operators (`@`)

The `@` family inspects or transforms the parameter without changing
its value. Each operator is a single character.

| Operator | Yields |
|----------|--------|
| `${var@Q}` | value re-quoted as a shell-parseable literal |
| `${var@E}` | value with backslash escapes interpreted (`\n`, `\t`, …) |
| `${var@P}` | value expanded as a `PS1`-style prompt |
| `${var@A}` | a `declare`/`typeset` assignment statement that reproduces `var` |
| `${var@a}` | the attribute flags (`a`, `A`, `i`, `r`, `x`, `n`, …) as a string |
| `${var@K}` | associative-array form with quoted keys (Bash 5.2+) |
| `${var@k}` | associative-array form, unquoted keys (Bash 5.2+) |
| `${var@U}` | upper-cased (entire string) |
| `${var@u}` | upper-cased (first character only) |
| `${var@L}` | lower-cased (entire string) |

```bash
# scenario: @Q for safe re-emission, @A for round-trip dumps, @a for attrs
declare -ai counts=([0]=10 [3]=42 [7]=99)
echo "${counts[@]@Q}"    # ⇒ '10' '42' '99'      — each element shell-quoted
echo "${counts@A}"       # ⇒ declare -ai counts=([0]="10" [3]="42" [7]="99")
declare -ir CONST=7
echo "${CONST@a}"        # ⇒ ir                   — integer + readonly

# @P for prompt-style escapes (current dir, time, etc.)
declare -- p='\u@\h:\w\$ '
echo "${p@P}"            # ⇒ sysadmin@host:/path$
```

`${var@Q}` is the canonical way to *log* or *re-emit* a variable's
value without quoting bugs (BCS0306) — its output is guaranteed
parseable when piped back into bash.

### Quoting rules around expansion

Always quote unless splitting is the intent. `"${arr[@]}"` preserves
each element as a separate word; `${arr[@]}` (unquoted) re-splits each
element on `IFS` (§5.8). The same applies to `"$var"` versus `$var`.

```bash
# scenario: quoted vs unquoted expansion of an element with spaces
declare -a files=('one two' 'three')
printf '[%s]\n' "${files[@]}"   # ⇒ [one two] [three]
# wrong — unquoted array expansion re-splits on IFS; demonstration only
#shellcheck disable=SC2068
printf '[%s]\n' ${files[@]}     # ⇒ [one] [two] [three]   — splitting bug
```

The unquoted form is the single most common cause of Bash bugs in
production scripts (§5.8). Quote unconditionally.

**See also**: §5.5 (arithmetic expansion shares variable-reference
syntax), §5.8 (word splitting after expansion), §5.9 (glob patterns
used by `#`, `%`, `/`), §5.13 (locale effects on case operators),
§4.11 (namerefs as an alternative to `${!var}`), BCS0207 (parameter
expansion idioms), BCS0306 (`@Q` for safe quoting), BCS0601 (`set -u`
and the `${var-default}` exemption).

#fin
