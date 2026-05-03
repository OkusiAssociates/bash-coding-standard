<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.3 Key bindings

`bind` builtin and `~/.inputrc` configure key bindings.

- `bind '"\C-l": clear-screen'` — bind Ctrl-L.
- `bind -p` — list current bindings.
- `bind -P` — list with descriptions.
- `bind -l` — list available functions (also see §18.4).
- `bind -f FILE` — load bindings from file (typically `~/.inputrc`).
- `~/.inputrc` syntax: `"keysequence": function-name` or `"keysequence": "string"`.
- Keysequences: `\C-x` (Ctrl-X), `\M-x` (Meta/Alt-X), `\e` (escape), literal characters.
- Conditional blocks via `$if mode=emacs` / `$if mode=vi` / `$if Bash` / `$endif`.

```text
# ~/.inputrc — minimal anchor
$include /etc/inputrc

set show-all-if-ambiguous on
set completion-ignore-case on

$if mode=emacs
  "\C-l": clear-screen
  "\e[A": history-search-backward
  "\e[B": history-search-forward
$endif
```

The `$include` line picks up the system default; the `set` directives toggle
readline variables (see `bind -V` for the full list); the `$if` block scopes
emacs-mode-only key bindings.

**See also**: §18.2 (editing modes), §18.4 (bindable functions), §18.5 (history).

#fin
