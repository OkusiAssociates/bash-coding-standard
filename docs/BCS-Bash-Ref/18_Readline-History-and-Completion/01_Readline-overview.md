<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.1 Readline overview

The GNU Readline library handles line editing in interactive bash.

- Provides command-line editing, history navigation, completion.
- Configured per-user via `~/.inputrc`; system-wide via `/etc/inputrc`.
- Bash binds default keys; `bind` builtin allows runtime customisation.
- Two editing modes: emacs (default) and vi.
- Active only when stdin is a terminal.
- Disabled with `bash --noediting` or `set +o emacs`.

#fin
