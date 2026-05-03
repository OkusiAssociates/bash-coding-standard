<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 12.4 Signal disposition

Each signal has one of four dispositions per process at any given time:

| Disposition | Meaning |
|-------------|---------|
| **Default** | the kernel's default action (see Appendix K) — terminate, ignore, stop, or continue, depending on the signal |
| **Ignored** | the signal is discarded by the kernel; no handler runs and the process continues |
| **Caught**  | a user-space handler runs in response — for bash, the body of a `trap` |
| **Blocked** | held in a pending mask until unblocked; bash does not expose the block mask directly (`trap` is the only interface) |

The bash `trap` builtin is the only way to mutate disposition from a
script. Its three forms map to the three changeable states (Default,
Ignored, Caught); Blocked is not user-controllable from bash:

```bash
trap 'handler args' SIGNAL    # → Caught
trap '' SIGNAL                # → Ignored (empty handler)
trap - SIGNAL                 # → Default (reset)
```

### Inheritance across `fork` and `exec`

The kernel rules (POSIX): on `fork(2)` a child inherits its parent's
disposition mask exactly. On `execve(2)` the rules differ for caught
vs ignored signals:

- **Caught** signals reset to Default — the new program image cannot
  execute the old handler, so the kernel discards it.
- **Ignored** signals stay Ignored — the kernel preserves these because
  the child program cannot tell from the binary that the parent had set
  `SIG_IGN`.

This asymmetry is the source of one of the more subtle bash bugs.

```bash
# scenario: ignored vs caught signals across exec
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

trap '' PIPE                              # SIGPIPE → Ignored
trap 'echo HUP caught' HUP                # SIGHUP  → Caught

# Show inherited dispositions in a child shell — note PIPE survives,
# HUP does not.
bash -c 'trap -p HUP PIPE'
# ⇒ trap -- '' SIGPIPE
#   (no entry for SIGHUP — reset to Default by exec)
```

The lesson: **install ignores in the parent if the child must inherit
them; install handlers in each shell that needs them**. A common
mistake is to set `trap '' INT` in a wrapper script expecting child
processes to inherit the immunity — they do, but only because empty
traps are "ignored", not "caught".

### `trap` does not block

There is no "blocked" form in `trap`. To approximate atomicity around a
critical section, set the trap to a flag-and-defer handler (§12.11) and
inspect the flag at safe points. True signal blocking requires
`sigprocmask(2)`, which bash does not expose.

**See also**: §12.3 (uncatchable signals), §12.5 (`trap` builtin),
§12.7 (`trap -p` inspection), §12.8 (trap inheritance), §12.9 (reset
across exec), §12.11 (signal-safe code), BCS-bash `24_SIGNALS.md`,
BCS0603 (trap handling).

#fin
