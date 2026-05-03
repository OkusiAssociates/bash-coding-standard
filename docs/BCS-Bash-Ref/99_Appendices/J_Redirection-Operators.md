<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix J — Redirection Operators

| Operator | Effect |
|----------|--------|
| `< file` | Open file for reading on fd 0 |
| `n< file` | Open on fd n |
| `> file` | Open for writing on fd 1, truncate |
| `>> file` | Append on fd 1 |
| `>\| file` | Force overwrite (ignore noclobber) |
| `&> file` | `> file 2>&1` shorthand |
| `&>> file` | `>> file 2>&1` shorthand |
| `<&n`, `n<&m` | Duplicate fds for reading |
| `>&n`, `n>&m` | Duplicate fds for writing |
| `<&-`, `>&-` | Close fd 0, fd 1 |
| `n<&-`, `n>&-` | Close fd n |
| `n<&m-`, `n>&m-` | Move fd m to n (close m) |
| `<> file` | Open for read+write |
| `<<DELIM` | Here-document |
| `<<-DELIM` | Here-document, strip leading tabs |
| `<<<"str"` | Here-string |
| `\| cmd` | Pipe stdout to cmd |
| `\|& cmd` | Pipe stdout+stderr to cmd |
| `<(cmd)` | Process substitution (read) |
| `>(cmd)` | Process substitution (write) |

#fin
