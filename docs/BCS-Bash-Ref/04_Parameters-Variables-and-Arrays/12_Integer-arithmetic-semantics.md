<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.12 Integer arithmetic semantics

Bash arithmetic is **signed 64-bit integer** on every modern Linux
build. There is no built-in floating point, no big-integer library,
and no exception on overflow. This chapter pins down the type system
and its sharp edges before §17 covers operators in full.

### Integer width and overflow

- **Width**: signed 64-bit on LP64 Linux (the universal modern case).
  On 32-bit i386 builds, signed 32-bit. The width is determined at
  compile time of the Bash binary, not at runtime; check
  `${BASH_VERSINFO[5]}` (machine-arch tuple) if you must.
- **Overflow wraps silently** — no exception, no diagnostic, no exit
  code. `2**63` overflows to a negative number; `2**64` to zero.
- **Underflow** wraps the same way: `-(2**63) - 1` becomes the
  maximum positive value.
- **Division rounds toward zero**: `(-7)/2 == -3`, not `-4`.
- **Modulo follows the sign of the dividend**: `(-7) % 3 == -1`.

```bash
# scenario: overflow, base prefixes, division semantics
declare -i x

x=$((2**62))            # 4611686018427387904 — fine
printf 'half-max:  %d\n' "$x"

x=$((2**63))            # overflow: wraps to a negative
printf 'overflow:  %d\n' "$x"
# ⇒ overflow:  -9223372036854775808

x=0xff                  # hex prefix
printf 'hex 0xff:  %d\n' "$x"          # ⇒ 255

x=0755                  # leading-zero prefix means OCTAL
printf 'oct 0755: %d\n' "$x"           # ⇒ 493 — not 755 the decimal!

x=$((16#deadbeef))      # explicit base#digits
printf 'hex DEADBEEF: %d\n' "$x"       # ⇒ 3735928559

x=$((-7 / 2))
printf 'trunc div:  %d\n' "$x"         # ⇒ -3   (toward zero)

x=$((-7 % 2))
printf 'modulo:     %d\n' "$x"         # ⇒ -1   (sign follows dividend)
```

The **leading-zero-is-octal** rule is one of Bash's most common
silent-bug traps. Filenames with date stamps, port numbers with
leading zeros, version strings — all of these can innocently land in
arithmetic context and produce wrong answers. Strip leading zeros
explicitly with `${var#0}` or use the `10#` base prefix:
`$((10#$value))` forces decimal.

### Base prefixes

| Prefix | Meaning |
|--------|---------|
| `0` (literal zero) | Octal — digits 0-7 |
| `0x` or `0X` | Hexadecimal — digits 0-9, a-f, A-F |
| `BASE#NUM` | Arbitrary base, 2 ≤ BASE ≤ 64 |

Bases 11–36 use letters case-insensitively (`16#FF == 16#ff == 255`).
Bases 37–64 are case-sensitive: lowercase first, then uppercase, then
`@` and `_`. Worth knowing only because base 64 occasionally appears in
encoding scripts.

### `set -u` and the arithmetic-context exception

`set -u` (`-o nounset`) treats reading an unset variable as a fatal
error in *most* contexts. Arithmetic context is the conspicuous
exception:

```bash
# scenario: set -u inconsistency in arithmetic context
set -u

unset MAYBE
printf '%s\n' "$MAYBE"
# ⇒ bash: MAYBE: unbound variable          (script aborts)

set -u
unset MAYBE
printf '%d\n' "$((MAYBE + 1))"
# ⇒ 1                                       (no error; MAYBE evaluates to 0)
```

Inside `(( … ))`, `$(( … ))`, `let`, array subscripts, and `for ((…))`,
an undefined name **silently evaluates to zero**. This is intentional
historical behaviour from `ksh` but it interacts badly with `set -u`'s
guarantees: a typo in a variable name does not abort, it produces zero
and continues. Defensive coding: gate arithmetic on names you trust to
be initialised, or use the explicit-default form `${MAYBE:-0}` to make
the default visible.

### No floating point

There is no `float` or `double` in Bash. For:

- **Money / fixed-point**: scale to integer cents (or microunits) and
  format with `printf '%d.%02d'`.
- **Real arithmetic**: shell out to `bc -l`, `awk`, `python3 -c`, or
  `dc`. Pick whichever is least surprising for the project.
- **Comparisons of decimal strings**: convert to integer scaled
  representation; never use Bash arithmetic on `"3.14"` (it's a syntax
  error inside `(( ))`).

```bash
# scenario: scaled fixed-point for currency
declare -i cents=12345
printf '%d.%02d\n' "$((cents / 100))" "$((cents % 100))"
# ⇒ 123.45
```

### Arithmetic contexts — where evaluation happens

Arithmetic evaluation is automatic inside:

- `(( expr ))` — pure evaluation, exit 0 if non-zero, 1 if zero.
- `$(( expr ))` — value-yielding expansion.
- `let expr [...]` — legacy form, equivalent to `(( ))` per argument.
  Avoid in new code; `(( ))` is clearer and quotes nothing weirdly.
- `arr[expr]=…` — subscripts in array assignment.
- `${arr[expr]}` — subscripts in array reference.
- `for ((init; test; step))` — C-style loop heads.
- `${var:offset:length}`, `${var: -N}` — substring/slice operands.

Outside these contexts, an arithmetic-looking expression is **string
data**: `x=2+3` stores the literal three-character string `2+3`.

### Pitfalls in one place

- **Leading-zero octal**: `$((08))` is a syntax error; `$((010))` is
  `8` not `10`. Strip leading zeros first.
- **Pre/post increment with `set -e`**: `((count++))` returns the *old*
  value; if it was zero, the `(( ))` exits non-zero, and `set -e`
  aborts. The BCS form is `count+=1` (BCS0505).
- **Quoting inside `(( ))`**: not needed and not helpful — quotes
  inside arithmetic context are themselves part of the expression.
- **Comparing strings as numbers**: `[[ "$a" -lt "$b" ]]` works because
  `[[ ]]` evaluates `-lt` arguments as arithmetic; `[[ "$a" < "$b" ]]`
  is *lexical* comparison. Use `(( a < b ))` when intent is numeric.

### See also

- §4.13 — assignment semantics, including `declare -i` evaluation
- §13 — arithmetic expansion in full
- §17 — arithmetic operators, precedence, and edge cases
- BCS0505 (arithmetic operations)

#fin
