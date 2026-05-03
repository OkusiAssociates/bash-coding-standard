<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.10 `_init_completion`

Helper from `bash-completion` for the standard completion boilerplate.

- Called at the start of a `_funcname` completion function.
- Sets `cur`, `prev`, `words`, `cword` variables.
- Returns 0 to continue, non-zero to short-circuit (e.g., for `--help`).
- `-n CHAR` — characters to treat as word breaks (e.g., `-n =:`).
- See `/usr/share/bash-completion/bash_completion` for source.

```bash
# scenario: skeleton using the helper
_mytool() {
  local cur prev words cword
  _init_completion -n =: || return
  case "$prev" in
    --config) _filedir conf ;;
    *)        mapfile -t COMPREPLY < <(compgen -W '--help --config' -- "$cur") ;;
  esac
}
complete -F _mytool mytool
```

`_init_completion` populates the four locals declared above; the `-n =:`
treats `=` and `:` as word-break characters so `--config=foo` splits cleanly.
Companion helpers from the same library: `_filedir`, `_known_hosts_real`,
`_pids`, `_pgids`.

**See also**: §18.8 (programmable completion), §18.11 (dynamic completion functions), §18.12 (`COMPREPLY`).

#fin
