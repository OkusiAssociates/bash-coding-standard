<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.8 Parameter expansion vs external commands

Replace `sed`/`awk`/`cut` with bash builtins where possible.

| Task | External | Parameter expansion |
|------|----------|---------------------|
| Strip `.txt` suffix | `$(echo "$f" | sed 's/.txt$//')` | `${f%.txt}` |
| Strip directory | `$(dirname "$f")` | `${f%/*}` |
| Get extension | `$(echo "$f" | awk -F. '{print $NF}')` | `${f##*.}` |
| Lowercase | `$(echo "$s" | tr A-Z a-z)` | `${s,,}` |
| Replace all | `$(echo "$s" | sed 's/old/new/g')` | `${s//old/new}` |
| Substring | `$(echo "$s" | cut -c2-5)` | `${s:1:4}` |

- Each parameter-expansion replacement avoids one fork.
- 10,000 iterations × 1 fork × 1 ms = 10 seconds saved.
- Code is shorter and clearer too.

#fin
