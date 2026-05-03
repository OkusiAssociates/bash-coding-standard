<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.12 Memory considerations

Bash uses memory for variables, arrays, and process state.

- Each variable: small fixed overhead plus value size.
- Large strings: bash duplicates on assignment (some optimisations apply).
- Arrays: O(N) for indexed; O(N) for associative with hash-table overhead.
- Subshell fork: copy-on-write; minimal cost until writes.
- `unset` releases memory; without it, lifetime is shell-lifetime.
- Reading a 100 MB file into a variable: avoid; stream instead.

Bash internals — variables live in a global hash table (`variables.c`),
arrays in `array.c`, copy-on-write applies to forked subshells via the
kernel's standard fork semantics. Slurping a file uses RAM proportional
to file size; streaming uses RAM proportional to one line.

```bash
# wrong — slurp: RAM grows with file size; bash duplicates on assignment
data=$(<huge.log)
while IFS= read -r line; do process "$line"; done <<< "$data"

# right — stream: O(1) memory regardless of file size
while IFS= read -r line; do process "$line"; done < huge.log
```

The `<huge.log` redirect feeds the loop one line at a time; the loop body
sees `line` and nothing else holds the file in memory. For multi-pass
processing, prefer two streams over one slurp; for indexed random access,
use `mapfile -O start -n count` to load slices, not the whole file.

**See also**: §19.1 (cost model), §19.7 (common optimisations), §06.05 (input redirection).

#fin
