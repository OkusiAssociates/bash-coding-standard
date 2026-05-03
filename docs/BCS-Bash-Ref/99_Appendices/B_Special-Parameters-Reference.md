<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix B — Special Parameters Reference

| Parameter | Meaning |
|-----------|---------|
| `$0` | Script name (or `BASH_ARGV0`) |
| `$1`–`${N}` | Positional parameters |
| `$#` | Number of positional parameters |
| `$@` | All positional, each a separate word when quoted |
| `$*` | All positional, joined by IFS[0] when quoted |
| `$?` | Exit status of last foreground command |
| `$$` | PID of script (fixed; not subshell PID) |
| `$!` | PID of last backgrounded process |
| `$_` | Last argument of previous command |
| `$-` | Current shell flags |

#fin
