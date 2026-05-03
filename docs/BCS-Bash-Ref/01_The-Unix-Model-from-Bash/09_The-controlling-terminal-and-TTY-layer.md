<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 1.9 The controlling terminal and TTY layer

Interactive Bash is intimately bound up with the controlling terminal. Two distinct concerns live behind the single word "TTY": the **terminal device** (what character device represents the keyboard and screen) and the **line discipline** (the kernel state machine that translates raw bytes into editable lines and synthesises keyboard signals).

### Terminal devices

| Path | Meaning |
|------|---------|
| `/dev/tty` | Per-process alias for "my controlling terminal". |
| `/dev/pts/N` | Pseudo-terminal slave end (created by `xterm`, `ssh`, `tmux`, etc.). |
| `/dev/console` | Kernel console; usually only accessible to PID 1 / root. |
| `/dev/ttyN` | Linux virtual console (Ctrl-Alt-F1…). |

A pseudo-terminal (PTY) is a master/slave pair: a terminal emulator opens the master, the shell runs on the slave. From the shell's perspective the slave is indistinguishable from a real serial line. The controlling terminal is acquired by `setsid(2)` followed by `ioctl(fd, TIOCSCTTY)` (or implicitly when `O_NOCTTY` is **not** set on first open).

### Line discipline

The line-discipline layer sits between the raw bytes coming off the terminal and what `read(2)` delivers to the shell.

```
keyboard ──► TTY driver ──► line discipline ──► /dev/pts/N ──► read(2) ──► bash
                              │
   ┌──────────────────────────┼──────────────────────────┐
   │ cooked (canonical)       │ raw                      │ cbreak
   │ - line buffered          │ - byte at a time         │ - byte at a time
   │ - editing keys (^U ^H)   │ - no editing             │ - no editing
   │ - delivers on ENTER      │ - delivers immediately   │ - signals still active
   │ - ^C → SIGINT            │ - no signals             │
   │ - ^Z → SIGTSTP           │                          │
   └──────────────────────────┴──────────────────────────┘
```

**Cooked mode** is the default for an interactive shell: the kernel buffers a line, lets the user edit with backspace, and delivers it only when ENTER is pressed. Keyboard signals (`Ctrl-C → SIGINT`, `Ctrl-\ → SIGQUIT`, `Ctrl-Z → SIGTSTP`) are synthesised by the line discipline, not by Bash. **Raw mode** is what `vim`, `less`, and any TUI using `readline` switches to: each byte arrives instantly and editing characters lose their special meaning.

The foreground process group is the only one allowed to `read` from the terminal; background readers receive `SIGTTIN` and stop until brought to foreground. Window resize emits `SIGWINCH` to the foreground group; `$LINES` and `$COLUMNS` (interactive only) are updated by the shell's handler.

### Inspection

```bash
# scenario: inspect the controlling terminal and its discipline
tty                          # ⇒ /dev/pts/3   (or "not a tty")
[[ -t 0 ]] && echo 'stdin is a tty' || echo 'stdin redirected'
[[ -t 1 ]] || echo 'stdout is a pipe — disable colour'
stty -a | head -3            # current line-discipline settings
stty size                    # ⇒ rows cols
```

`stty -a` reveals the full discipline state: `icanon` (cooked vs raw), `echo`, `isig` (Ctrl-C synthesis), `intr = ^C`, `susp = ^Z`. `stty -icanon -echo` is what TUIs do programmatically via `tcsetattr(3)`.

### Practical use of `[[ -t N ]]`

A script that auto-disables colour when redirected respects pipelines and CI logs:

```bash
# scenario: only emit ANSI colour when stdout is a tty
declare -- RED=''
if [[ -t 1 ]]; then RED=$'\033[31m'; fi
echo "${RED}error${RED:+$'\033[0m'}"
```

**See also**: §1.8 (signal overview — terminal signals are a subset), §11.6 (process groups and foreground/background scheduling), §12 (trap handling), §22 (interactive shell), BCS0708 (terminal capabilities), BCS0707 (TUI basics).

#fin
