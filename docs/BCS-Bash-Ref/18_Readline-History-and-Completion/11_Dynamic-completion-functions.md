<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.11 Dynamic completion functions

Patterns for writing completion functions.

```bash
_my_tool() {
  local cur prev words cword
  _init_completion || return
  case $prev in
    --file) _filedir; return ;;
    --user) COMPREPLY=($(compgen -u -- "$cur")); return ;;
  esac
  case $cur in
    --*) COMPREPLY=($(compgen -W '--help --version --file --user' -- "$cur")) ;;
  esac
}
complete -F _my_tool my_tool
```

- `compgen -W "list" -- "$cur"` — filter list by current prefix.
- `_filedir` — directories and files (from bash-completion).
- `_filedir 'sh'` — files matching extension.
- `_known_hosts_real` — hosts from various sources.
- Cache expensive operations.

#fin
