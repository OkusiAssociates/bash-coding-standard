<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.5 Arithmetic expansion

`$(( expr ))` evaluates *expr* as a Bash arithmetic expression
(§8.10) and substitutes the textual result. Phase 4 of the expansion
order (§5.1). Inside an arithmetic context, named variables are read
**without** the `$` prefix and are coerced to integers (zero if
non-numeric or unset). The expansion is the workhorse for index
arithmetic, counters, bitwise tests, and anything else that does not
need an external `expr`/`bc`.

### Form and basic behaviour

- `$(( expression ))` — produces the integer result as a string.
- Variables referenced **without** `$`: `$(( a + b ))` reads `a` and
  `b` directly. The `$` form `$(( $a + $b ))` works (parameter
  expansion runs first, phase 3) but is redundant and obscures
  precedence.
- Empty `$(( ))` evaluates to `0`.
- Nested `$(( $(( a )) + b ))` is unnecessary — `$(( a + b ))` suffices.
- The legacy form `$[ expression ]` is **deprecated**; do not use.
- Bash arithmetic is **64-bit signed integer**. Overflow wraps
  silently (BCS0506).

```bash
# scenario: minimum-viable arithmetic expansion
declare -i a=3 b=4
echo $(( a + b ))            # ⇒ 7
echo $(( a + b * 2 ))        # ⇒ 11    (precedence: * before +)
echo $(( (a + b) * 2 ))      # ⇒ 14
echo $(( 1 << 4 ))           # ⇒ 16    (bit-shift)
echo $(( a > b ? a : b ))    # ⇒ 4     (ternary, returns max)
echo $(( ))                  # ⇒ 0
echo $(( 0xff ))             # ⇒ 255   (hex prefix)
echo $(( 8#17 ))             # ⇒ 15    (base#digits — base 8)
echo $(( 2#1010 ))           # ⇒ 10    (binary)
```

### The `set -u` arithmetic inconsistency

`set -u` (`nounset`) terminates the script on reference to an unset
variable — except inside arithmetic, where unset variables are
silently treated as `0`. This is a long-standing wart that catches
authors who rely on `set -u` to catch typos in counter names:

```bash
# scenario: demonstrate the set -u arithmetic inconsistency
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Outside arithmetic — set -u fires:
echo "$undef"
# ⇒ bash: undef: unbound variable
# ⇒ (script terminates here under `set -e`)

# But inside arithmetic, the same name is silently zero:
echo $(( undef + 1 ))            # ⇒ 1     — no error
declare -i n=$(( undef * 99 ))   # ⇒ n=0   — no error

# Workaround: defensive default expansion (BCS0207)
echo $(( ${undef:-0} + 1 ))      # explicit zero, intent visible
```

Mitigation: when a counter or index *must* be defined, default it
explicitly with `${var:-0}` inside the arithmetic, or test
`[[ -v var ]]` (§8.4) before the arithmetic runs. BCS0203 / BCS0207
naming and defaulting discipline removes most occurrences in practice.

### Where the form lives in the Bash zoo

- `$(( … ))` — *arithmetic expansion*, substitutes a value, suitable
  in any word context.
- `(( … ))` — *arithmetic command*, no substitution; exit status 0
  iff result is non-zero. Used in `if`/`while` (BCS0501, BCS0505).
- `let 'a = b + 1'` — older form; avoid.
- `declare -i x=…` — assignment context auto-arithmetic; the right
  side is evaluated as `expr`. Re-evaluated on every reassignment.

### Number-base prefixes

Bash recognises:

- `0xN` / `0XN` — hexadecimal.
- `0N` — octal (a leading literal zero).
- `BASE#N` — base 2 through 64. Digits `0-9 a-z A-Z @ _`.

```bash
# scenario: base prefixes — including the 0-prefix octal trap
echo $(( 010 ))            # ⇒ 8     (literal-0 prefix is OCTAL)
echo $(( 09 ))             # ⇒ bash: 09: value too great for base
echo $(( 10#09 ))          # ⇒ 9     (force base 10)
```

The leading-zero octal trap matters when zero-padded numeric strings
arrive from `printf '%02d'` or external tools. Use `10#$str` to force
base 10 (BCS0505).

### BCS posture

- Use `(( expr ))` (the *command*) for conditionals, `$(( expr ))`
  (the *expansion*) only when the value is needed in word context.
- Declare integer-typed variables with `declare -i` so simple
  reassignment (`count=$((count + 1))`) does not require explicit
  arithmetic re-evaluation each time (BCS0201).
- Increment idiom: `count+=1` (NOT `((count++))`) — the post-increment
  form returns 0 when the prior value was 0, tripping `set -e`
  (BCS0505).
- Always `10#$x` when *x* may carry a leading zero (BCS0505).

**See also**: §5.4 (parameter expansion runs first), §8.10
(arithmetic operator precedence and primaries), §4.12 (integer
arithmetic semantics — overflow, base parsing), §13.3 (`set -e`
exemption matrix — `(( ))` and `let`).

#fin
