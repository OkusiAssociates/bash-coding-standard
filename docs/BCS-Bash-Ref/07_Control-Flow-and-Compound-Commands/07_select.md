<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.7 `select`

Generate a numbered menu and read a choice. `select` is bash's only
built-in interactive menu primitive; it is rare in production scripts
but ideal for ad-hoc admin tools, single-user scaffolding, and
demo-quality code where a TUI library would be overkill.

### Syntax

```
select var in word1 word2 …; do list; done
```

Bash prints the words as a numbered list to stderr, prints `PS3` as
the prompt, and reads a line from stdin. If the line is the index of a
valid item, `var` is set to that item; otherwise `var` is empty. The
loop continues until the body executes `break` or stdin reaches EOF
(typically Ctrl-D). An empty input line redisplays the menu.

### `PS3` and `REPLY`

Two built-in variables drive the interaction:

- `PS3` — the prompt string. Default is `#?`. Set it to something
  meaningful; the default is opaque and hostile.
- `REPLY` — set to the user's *literal* input, regardless of whether
  it is a valid index. Useful for accepting commands like `q` or
  `quit` alongside numeric choices.

```bash
# scenario: simple interactive menu with a quit option
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- PS3='Choose an action: '
declare -ar actions=(start stop restart 'show status' quit)

select choice in "${actions[@]}"; do
  case $choice in
    start)         systemctl start "$svc" ;;
    stop)          systemctl stop  "$svc" ;;
    restart)       systemctl restart "$svc" ;;
    'show status') systemctl status "$svc" ;;
    quit)          break ;;
    *)             # invalid input: choice is empty, REPLY holds the text
                   warn "Unknown selection: ${REPLY@Q}" ;;
  esac
done
```

Note the case `*)` clause: when the user enters something that is not
a valid index, `select` sets `var` to empty *and* leaves `REPLY` set
to the raw input — handle the empty case in the body, refer to
`REPLY` for diagnostics. The `${REPLY@Q}` expansion (BCS0306) renders
the input safely-quoted for the message.

### Mixing numeric indices and command names

Because `REPLY` is independent of `var`, a `select` loop can accept
both menu numbers and word commands:

```bash
# scenario: menu accepts numeric choice or "q" / "quit" as text
declare -- PS3='> '
declare -ar items=(alpha beta gamma)

select item in "${items[@]}"; do
  case ${item:-$REPLY} in
    alpha|beta|gamma) echo "picked: $item" ;;
    q|quit|exit)      break ;;                   # match REPLY when item is empty
    '')               continue ;;                # blank line: redisplay menu
    *)                echo "no such option: $REPLY" ;;
  esac
done
```

The `${item:-$REPLY}` expansion is the idiom: dispatch on `item` if
the user gave a valid index, else fall back to `REPLY` for textual
commands.

### Limits and alternatives

`select` is not interruptible by SIGINT in the way a regular `read` is
— Ctrl-C kills the script unless trapped (§12). It also lacks any
notion of a default selection, multi-select, search, or scrolling; for
anything beyond a handful of options, reach for a real TUI. For
non-interactive driving (testing the menu, scripting through it), pipe
input on stdin: `printf '2\nq\n' | ./tool` selects item 2 then
exits.

`select` is uncommon in modern scripts, but for a five-line interactive
prompt embedded in a larger tool it remains the path of least
resistance.

**See also**: §7.3 (`case` for dispatch on the choice), §7.6
(`while`/`until` and `read`), §12 (signal handling and Ctrl-C),
BCS0306.

#fin
