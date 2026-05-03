<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.7 Iterating an associative array deterministically

Bash hashtable iteration order is unspecified. Sort for reproducibility.

```bash
for key in $(printf '%s\n' "${!by_id[@]}" | sort); do
  printf '%s = %s\n' "$key" "${by_id[$key]}"
done
```

- `printf '%s\n' "${!by_id[@]}"` — one key per line.
- `sort` with appropriate flags (`-n` for numeric, `-V` for version, default lexical).
- For large maps, the sort cost is real; cache sorted keys if iterating repeatedly.

#fin
