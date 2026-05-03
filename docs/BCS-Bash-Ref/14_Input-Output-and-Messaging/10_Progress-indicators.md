<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 14.10 Progress indicators

Long-running tasks benefit from progress feedback on stderr (§14.1).
The two canonical forms — spinner and bar — both rely on `\r` (carriage
return without newline) and on the script being able to detect a TTY.

### TTY guard

Progress output to a non-TTY destination corrupts logs and pipelines.
Always gate with `[[ -t 2 ]]`:

```bash
# scenario: enable progress output only when stderr is a real terminal
declare -i SHOW_PROGRESS=0
[[ -t 2 ]] && SHOW_PROGRESS=1

# also disable under -q (BCS verbosity discipline)
((VERBOSE)) || SHOW_PROGRESS=0
```

Production pipelines run with stderr captured; the guard keeps log
files free of `\r`-spam.

### Spinner

```bash
# scenario: spin while a background job runs, clear when done
spin() {
  local -- frames='|/-\' i=0
  while kill -0 "$1" 2>/dev/null; do
    printf '\r%s' "${frames:i++%4:1}" >&2
    sleep 0.1
  done
  printf '\r \r' >&2          # clear the spinner cell
}

long_task &
((SHOW_PROGRESS)) && spin "$!"
wait "$!"
```

`kill -0 PID` tests whether the PID is alive without delivering a
signal (BCS1101). The `\r \r` epilogue overwrites the last frame and
returns the cursor to column 0 so the next message starts cleanly.

### Bar

```bash
# scenario: draw a 40-column bar from a percentage
draw_bar() {
  local -i pct=$1 width=40 filled
  filled=$(( pct * width / 100 ))
  printf '\r[%-*s] %3d%%' "$width" "$(printf '#%.0s' $(seq 1 "$filled"))" "$pct" >&2
}

declare -i total=$(( $(wc -l < input) + 0 ))
declare -i seen=0
while IFS= read -r _; do
  seen+=1
  ((SHOW_PROGRESS)) && draw_bar $(( seen * 100 / total ))
done < input
((SHOW_PROGRESS)) && printf '\n' >&2
```

`printf '#%.0s' $(seq 1 N)` is the BCS-idiomatic "repeat a string N
times" pattern: the format `%.0s` consumes the argument and prints
the literal `#`. Always end with a newline once the loop finishes;
otherwise the next message is overwritten by terminal scrollback.

### Library fallbacks

- `pv` — pipe-based progress, byte-aware: `tar c . | pv -s "$bytes" > out.tar`.
- `dialog` / `whiptail` — full-screen TUI; reach for these when a
  spinner is no longer enough.
- `rsync --info=progress2` — rsync's own bar; saves writing one.

### See also

- §14.1 — stdout/stderr discipline
- §14.9 — colour and `TERM` detection (spinner colours)
- BCS0707 (TUI basics), BCS0708 (terminal capabilities)

#fin
