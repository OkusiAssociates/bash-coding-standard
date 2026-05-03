<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.7 `trap -p` and trap inspection

`trap -p` prints the current trap state in a form that can be re-eval'd.
It is the canonical "is my handler actually installed?" diagnostic and
the only built-in way to enumerate trap dispositions at runtime.

| Invocation | Output |
|------------|--------|
| `trap -p`              | every installed trap, one per line |
| `trap -p SIGNAL`       | just the named signal (empty if Default) |
| `trap -p SIG1 SIG2 …`  | each signal in turn |

`declare -p` does **not** report traps; only `trap -p` does. There is
also no `set -o` flag for traps and no `BASH_*` array exposing them.

```bash
# scenario: confirm traps after install
trap 'cleanup' EXIT
trap 'on_int $LINENO' INT
trap '' PIPE                                # ignored signal

trap -p
# ⇒ trap -- 'cleanup' EXIT
#   trap -- 'on_int $LINENO' INT
#   trap -- '' SIGPIPE

trap -p HUP
# ⇒ (empty — HUP is at its default disposition)
```

The output is in re-eval'able form: bash's own output is safe to feed
back through `eval` to restore traps after a section that disables them.

```bash
# scenario: snapshot and restore traps
saved_traps=$(trap -p)
trap - INT TERM                             # disable temporarily
risky_section
eval "$saved_traps"                         # restore exactly
```

Use `trap -p` to diagnose: "why didn't my trap fire?" (it may have
been reset by a later install), "which traps does this function
inherit?" (functions see whatever the shell has installed, regardless
of frame), and "is the EXIT trap the latest version?" (libraries that
own their cleanup re-install at entry and confirm via `trap -p EXIT`).

**See also**: §12.4 (signal disposition), §12.5 (the `trap` builtin),
§12.8 (trap inheritance), §12.9 (reset across exec), §12.12 (idempotent
cleanup), BCS-bash `30_48_trap.md`, BCS0603 (trap handling).

#fin
