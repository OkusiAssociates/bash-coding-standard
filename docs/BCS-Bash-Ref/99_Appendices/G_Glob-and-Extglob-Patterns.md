<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix G — Glob and Extglob Patterns

| Pattern | Matches |
|---------|---------|
| `*` | Zero or more characters |
| `?` | Exactly one character |
| `[abc]` | Any of a, b, c |
| `[a-z]` | Any character in range |
| `[!abc]`, `[^abc]` | Any except a, b, c |
| `[[:class:]]` | POSIX character class |
| `**` | Zero or more directories (with `globstar`) |
| `?(pat\|pat)` | Zero or one occurrence (extglob) |
| `*(pat\|pat)` | Zero or more occurrences (extglob) |
| `+(pat\|pat)` | One or more occurrences (extglob) |
| `@(pat\|pat)` | Exactly one occurrence (extglob) |
| `!(pat\|pat)` | Anything except (extglob) |

POSIX character classes: `alnum`, `alpha`, `ascii`, `blank`, `cntrl`, `digit`, `graph`, `lower`, `print`, `punct`, `space`, `upper`, `word`, `xdigit`.

#fin
