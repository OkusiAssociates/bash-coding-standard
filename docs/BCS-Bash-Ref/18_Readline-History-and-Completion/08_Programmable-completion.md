<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.8 Programmable completion

Bash can complete arbitrary commands using user-defined functions.

- `complete -F funcname cmd` — call funcname when completing for cmd.
- The function inspects `COMP_WORDS`, `COMP_CWORD`, etc., and populates `COMPREPLY` (see §18.12).
- `complete -p` — list current completions.
- `complete -o option …` — completion options (default, bashdefault, dirnames, filenames, …).
- Stored in `/usr/share/bash-completion/completions/CMD` typically.
- `bash-completion` package provides defaults for many tools.

```bash
# scenario: complete `mytool start|stop|status`
_mytool() {
  local cur
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=()
  if ((COMP_CWORD == 1)); then
    mapfile -t COMPREPLY < <(compgen -W 'start stop status' -- "$cur")
  fi
}
complete -F _mytool mytool
```

`compgen -W` filters the wordlist by the current prefix; `mapfile` populates
the array without word-splitting surprises. Drop the file under
`~/.local/share/bash-completion/completions/mytool` for autoload.

**See also**: §18.9 (compspec actions), §18.10 (`_init_completion`), §18.11 (dynamic completion).

#fin
