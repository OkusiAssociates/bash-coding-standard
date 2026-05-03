<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix M — Bash Version History

| Version | Year | Notable additions |
|---------|------|-------------------|
| 1.0 | 1989 | Initial release |
| 2.0 | 1996 | New parser; large rewrite |
| 3.0 | 2004 | `=~`, `+=`, multi-character `IFS` |
| 3.2 | 2006 | Bug fixes; macOS perpetual baseline |
| 4.0 | 2009 | Associative arrays, coprocesses, `mapfile`, `&>>`, `**`, `;&`/`;;&`, `read -i`, autocd |
| 4.1 | 2009 | `printf -v` for arrays, `BASH_XTRACEFD`, `&>` |
| 4.2 | 2011 | `declare -g`, `printf %(fmt)T`, `lastpipe` |
| 4.3 | 2014 | Namerefs (`declare -n`), `mapfile -d`, `wait -n` |
| 4.4 | 2016 | `${var@…}` transformations, `local -`, `inherit_errexit` |
| 5.0 | 2019 | `EPOCHSECONDS`, `EPOCHREALTIME`, `BASH_ARGV0`, history range delete |
| 5.1 | 2020 | `SRANDOM`, `wait -p`, `BASH_REMATCH` reset |
| 5.2 | 2022 | Recursive bison grammar for command substitution, `varredir_close`, `${var@k}`, `globskipdots`, `noexpand_translation` |
| 5.3 | 2025 | No-fork `${ cmd; }` command substitution, multi-coproc improvements |

#fin
