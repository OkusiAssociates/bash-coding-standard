<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.11 Integer types, overflow, base prefixes

Bash arithmetic uses the host C compiler's signed `intmax_t` —
typically 64-bit on modern Linux.

- Range: −2^63 to 2^63 − 1 on 64-bit Linux.
- Overflow wraps silently — no exception, no diagnostic, no errexit
  trip even under strict mode.
- Bases: decimal default; **leading `0`** for octal; `0x`/`0X` for
  hex; `BASE#NUM` for any base from 2 to 64.
- Base 64 uses `0-9 a-z A-Z @ _` for digit values 0–63.
- Examples: `0755` = 493, `0xff` = 255, `2#1010` = 10, `36#zz` = 1295.
- Octal-leading-zero gotcha: `0755` in arithmetic context is *octal*,
  yielding 493 — a frequent surprise when copying file modes into
  `(( ))` for arithmetic.

### Overflow demonstration

Silent wrap-around is the single failure mode that turns a working
script into one that returns mysterious negative numbers. Either
constrain the range, validate before computation, or use `bc -l` /
`awk` for arbitrary precision (§8.12).

```bash
# scenario: 64-bit integer overflow wraps to a large negative number.
#!/usr/bin/env bash
set -euo pipefail

declare -i max=9223372036854775807            # 2^63 - 1
echo "$max"                                    # ⇒ 9223372036854775807

# add 1: silent overflow, wraps to INT_MIN.
declare -i wrapped=$((max + 1))
echo "$wrapped"                                # ⇒ -9223372036854775808 (BCS0505)

# scenario: octal trap when reading a file mode.
mode=0755                                      # the user "knows" this is rwxr-xr-x
declare -i decimal=$((mode))
echo "$decimal"                                # ⇒ 493  (octal!) — surprise

# right: when you mean decimal, write decimal.
declare -i seven_five_five=755
echo "$seven_five_five"                        # ⇒ 755

# right: when you mean octal AND want bash to know, use 8#.
declare -i mode_octal=$((8#755))
echo "$mode_octal"                             # ⇒ 493 (explicit) (BCS0505)

#fin
```

The lesson: a leading zero in *any* arithmetic context (`(( ))`,
`$(( ))`, `let`, `declare -i x=...`) means base-8. If the value is
not actually intended as octal — for example a zero-padded request
ID like `0042` — it must be sanitised first (`${var#0}` or
`${var##+(0)}` after `shopt -s extglob`) before arithmetic touches
it.

**See also**: §8.10 arithmetic operators and precedence, §8.12
floating-point workarounds, §8.13 `let` builtin, §5.5 arithmetic
expansion, BCS0505 (arithmetic operations), BCS0201 (type-specific
declarations).

#fin
