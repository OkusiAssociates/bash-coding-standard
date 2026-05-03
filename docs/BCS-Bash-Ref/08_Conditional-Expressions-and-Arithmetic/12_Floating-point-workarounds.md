<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.12 Floating-point — workarounds

Bash has no native floating-point type. The four common workarounds:

- **Scaled integers** — store amounts in cents instead of dollars,
  microseconds instead of seconds. The most reliable approach for
  fixed-precision domains (currency, time intervals).
- `bc -l` — `result=$(bc -l <<<"3.14 * 2")` for arbitrary precision.
- `awk` — `awk 'BEGIN { print 3.14 * 2 }'` for one-line arithmetic.
- `printf '%.2f\n' "$value"` — formatting only; bash still treats the
  value as a string.
- `python3 -c 'print(3.14 * 2)'` — when Python is available and a
  more complex expression is needed.

### Currency — the scaled-integer pattern

Currency is the canonical case where floating point introduces silent
rounding errors and integer cents introduce none. Store cents, do all
arithmetic in cents, and format only at the boundary.

```bash
# scenario: invoice totals in cents, formatted as dollars on output.
#!/usr/bin/env bash
set -euo pipefail

# Each line item: amount in CENTS (no decimals stored anywhere).
declare -ai items=(1995 4500 750 12999)        # $19.95, $45.00, $7.50, $129.99 (BCS0206)
declare -i  tax_bps=875                        # 8.75% as basis-points (1 bp = 0.01%)

declare -i subtotal=0
for cents in "${items[@]}"; do
  subtotal+=cents
done                                           # subtotal in cents (BCS0505)

# Tax: multiply first, then divide — keeps integer precision.
declare -i tax_cents=$(( subtotal * tax_bps / 10000 ))
declare -i total_cents=$(( subtotal + tax_cents ))

# Format only at the boundary.
fmt() { printf '$%d.%02d' $((${1} / 100)) $((${1} % 100)); }
printf 'subtotal: %s\n' "$(fmt "$subtotal")"     # ⇒ subtotal: $192.44
printf 'tax     : %s\n' "$(fmt "$tax_cents")"    # ⇒ tax     : $16.83
printf 'total   : %s\n' "$(fmt "$total_cents")"  # ⇒ total   : $209.27

#fin
```

The discipline: cents in, cents through, cents out — *until* the
final formatting step. Any intermediate float (`bc`, `awk`,
`python3`) reintroduces rounding error and breaks reconcileability
with downstream accounting systems that work in integer minor units
(BCS0506).

For one-shot arithmetic where precision is forgiving (display
purposes, ratios, percentages), `bc -l` and `awk` are fine; reserve
the scaled-integer pattern for anything that has to balance to the
penny.

**See also**: §8.10 arithmetic operators and precedence, §8.11
integer types and overflow, §5.5 arithmetic expansion, BCS0505
(arithmetic operations), BCS0506 (floating-point operations).

#fin
