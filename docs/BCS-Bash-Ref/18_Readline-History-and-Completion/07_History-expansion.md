<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.7 History expansion

`!` introduces history references on the command line.

- `!!` — last command.
- `!N` — command N (positive) or N back (negative).
- `!STRING` — most recent command starting with STRING.
- `!?STRING?` — most recent command containing STRING.
- `^old^new` — substitute old with new in last command.
- `!$` — last argument of last command.
- `!^` — first argument of last command.
- `!*` — all arguments of last command.
- `!:N` — N-th argument of last command.
- `!:s/old/new/` — substitution.
- Disable in scripts: `set +H` or non-interactive default.
- Pitfall: `"!"` in double quotes triggers expansion in interactive shells.

#fin
