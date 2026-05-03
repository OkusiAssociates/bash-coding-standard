<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.6 `EPOCHREALTIME` for sub-second timing

Bash 5.0+ exposes the system clock with microsecond precision.

- `EPOCHREALTIME` — string like `1716234567.123456`.
- `EPOCHSECONDS` — integer seconds.
- Older bash: use `date +%s.%N` (forks!) or compile a custom loadable.

```bash
# scenario: fork-free microsecond delta
start="$EPOCHREALTIME"
do_thing
end="$EPOCHREALTIME"

# strip the dot, treat the timestamp as integer microseconds
delta=$(( ${end/./} - ${start/./} ))

printf '%d.%06d s\n' $((delta / 1000000)) $((delta % 1000000))
# ⇒ 0.001234 s
```

`${end/./}` deletes the decimal point so the value becomes a 16-digit
integer suitable for `(( ))` arithmetic — no `bc` fork (which would itself
cost ~1 ms and defeat the timing). The two-`printf` formula reconstructs
seconds-and-microseconds from the integer microsecond delta.

```bash
# wrong — forks bc each iteration; the fork itself dominates the delta
delta=$(echo "$end - $start" | bc -l)
```

**See also**: §19.1 (cost model), §19.2 (profiling), §19.5 (PS4 with `$EPOCHREALTIME`).

#fin
