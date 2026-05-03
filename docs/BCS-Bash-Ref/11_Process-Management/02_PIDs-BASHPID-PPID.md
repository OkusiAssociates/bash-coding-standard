<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.2 PIDs: `$$`, `$BASHPID`, `$PPID`

Three variables, three different meanings, and one of the most-misread
trios in Bash. Pick the wrong one for a lockfile and concurrent
subshells will all claim the same PID; pick the wrong one for a
per-worker tempdir and they will all collide.

### The contract

| Variable | Value | Mutable in subshell? |
|----------|-------|----------------------|
| `$$` | PID of the **original** shell that started the script | no — frozen for the script's lifetime |
| `BASHPID` | PID of the **currently executing** shell | yes — updates inside every subshell |
| `$PPID` | PID of the parent of the original shell | no |

`$$` is sometimes called "the script's PID" and that is fair, provided
you understand that it never changes when Bash forks a `( … )`, `$(…)`,
`<(…)`, or `cmd &` child. `BASHPID` does change. `$PPID` is whatever
process invoked the script — usually a shell or `init`-style supervisor.

### Worked example: divergence under a subshell

```bash
#!/usr/bin/env bash
# scenario: prove $$ stays constant while BASHPID tracks the current fork.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

printf 'parent  $$=%d  BASHPID=%d  PPID=%d\n' "$$" "$BASHPID" "$PPID"

(
  printf 'subshell $$=%d  BASHPID=%d  PPID=%d\n' "$$" "$BASHPID" "$PPID"
  (
    printf 'nested  $$=%d  BASHPID=%d  PPID=%d\n' "$$" "$BASHPID" "$PPID"
  )
)
# ⇒ parent   $$=4711  BASHPID=4711  PPID=4123
# ⇒ subshell $$=4711  BASHPID=4712  PPID=4711
# ⇒ nested   $$=4711  BASHPID=4713  PPID=4712
```

`$$` is identical at all three depths; `BASHPID` advances with each fork
and `$PPID` of the inner subshell points at its real parent
(`BASHPID` of the outer subshell), not at the script's `$PPID`.

### Footgun: lockfiles in parallel sub-jobs

```bash
# wrong — every worker writes the same PID into its own lockfile
for i in 1 2 3; do
  ( echo "$$" > "/tmp/worker.$i.pid"; sleep 1 ) &
done

# right — each worker's lockfile carries its real PID
for i in 1 2 3; do
  ( echo "$BASHPID" > "/tmp/worker.$i.pid"; sleep 1 ) &
done
```

The wrong form will appear to work until you try to `kill` a single
worker by reading its pidfile — every file holds the parent PID.

### Footgun: per-subshell temp paths

`mktemp` itself is unique enough, but if you compose a path manually
under `BCS1006`, derive it from `BASHPID`:

```bash
# right — collision-free temp per subshell child
declare -- tmp; tmp=$(mktemp -d -t "worker.${BASHPID}.XXXXXX")
trap 'rm -rf -- "$tmp"' EXIT
```

### When `$$` is exactly what you want

- Top-level script lockfile (`/run/myscript.pid`) — the supervisor wants
  to signal the **whole** script, not a transient subshell.
- Log line prefixes that should remain stable across the run.
- Reporting in `--version`/diagnostics output.
- A `mkdir /tmp/build.$$` scratch directory is fine for the script's
  duration because the script itself is the only writer.

### When `BASHPID` is exactly what you want

- Lockfiles or pidfiles written **by a child** of the script (workers,
  per-host loops, parallel CI shards).
- Per-fork tempfiles inside `$(…)` or `( … )` blocks.
- Diagnostic logging that needs to identify *which* fork emitted a
  line (compose with `$$` for the script identity, `$BASHPID` for the
  fork identity).

### When `$PPID` matters

- Detecting whether the script was launched by a known supervisor
  (compare `$(ps -o comm= -p "$PPID")` to expected names).
- Honouring `SIGHUP` from a parent that just exited (the orphaning
  rules of §11.6 hinge on the original `$PPID`).

### Strict-mode note

None of `$$`, `BASHPID`, `$PPID` triggers `set -u` because all are set
unconditionally by the shell. They are safe to expand without the
`${var:-}` guard pattern shown elsewhere. They are also safe inside
`$(…)` because `inherit_errexit` (BCS0101) sees them as pure variable
expansions — no command, no failure path.

### Quick reference

| Need | Use |
|------|-----|
| "Is the script still running?" lockfile | `$$` |
| Per-fork tempfile / pidfile | `BASHPID` |
| Diagnostic prefix on every log line | `$$:$BASHPID` |
| Detecting unexpected re-parenting | `$PPID` snapshot at start, compare later |
| Killing the entire process group | `kill -TERM "-$$"` (negative PID, see §11.6) |

**See also**: §11.1 (process tree), §11.3 (subshell origins),
§11.4 (`BASH_SUBSHELL`), §11.7 (job table), BCS0101, BCS1006.

#fin
