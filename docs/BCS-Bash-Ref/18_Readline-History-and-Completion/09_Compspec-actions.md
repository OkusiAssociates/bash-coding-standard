<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.9 Compspec actions

Built-in completion sources.

- `complete -A action cmd` — use built-in action.
- Actions: `alias`, `arrayvar`, `binding`, `builtin`, `command`, `directory`, `disabled`, `enabled`, `export`, `file`, `function`, `group`, `helptopic`, `hostname`, `job`, `keyword`, `running`, `service`, `setopt`, `shopt`, `signal`, `stopped`, `user`, `variable`.
- `complete -W "list" cmd` — completion from a fixed word list.
- `complete -G 'pattern' cmd` — completion from a glob.

#fin
