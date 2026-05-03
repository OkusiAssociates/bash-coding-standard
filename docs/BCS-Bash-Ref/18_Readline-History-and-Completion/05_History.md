<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.5 History

Bash maintains a history of commands.

- `HISTFILE` — file path (default `~/.bash_history`).
- `HISTSIZE` — number of commands in memory.
- `HISTFILESIZE` — number of lines in the file.
- `HISTCONTROL` — list: `ignoreboth`, `ignoredups`, `ignorespace`, `erasedups`.
- `HISTIGNORE` — colon-separated patterns to skip.
- `HISTTIMEFORMAT` — printf format for timestamps in `history` output.
- `HISTAPPEND` shopt — append on exit instead of overwrite.
- `cmdhist` shopt — store multi-line commands as one entry.
- Per-session vs persistent: in-memory list flushed to file on exit (or `history -a`).

#fin
