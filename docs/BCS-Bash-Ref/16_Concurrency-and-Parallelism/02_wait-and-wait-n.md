<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.2 `wait` and `wait -n`

Synchronise the parent script with one or more background children
(BCS1103). The semantics differ in subtle but load-bearing ways
between bash versions.

### Form register

- `wait` — wait for *all* children; exit status is 0 (or 127 if there
  were no children).
- `wait $pid` — wait for a specific child; `$?` becomes that child's
  exit status.
- `wait -n` — wait for *any* child to exit (Bash 4.3+); `$?` is the
  exited child's status.
- `wait -n $pid1 $pid2 …` — wait for any of these specific children
  (Bash 5.1+).
- `wait -p VAR -n` — store the PID of the exited child in `VAR`
  (Bash 5.1+).
- `wait` with no living children: returns 127.

### Feature matrix

| Form | Bash 4.0–4.2 | Bash 4.3+ | Bash 5.1+ |
|------|:---:|:---:|:---:|
| `wait` | ✓ | ✓ | ✓ |
| `wait $pid` | ✓ | ✓ | ✓ |
| `wait -n` | ✗ | ✓ | ✓ |
| `wait -n $pid …` | ✗ | ✗ | ✓ |
| `wait -p VAR -n` | ✗ | ✗ | ✓ |

### `wait -n` loop

The Bash 5.1+ form is the cleanest way to drain a fixed number of
children one-at-a-time, e.g., to release a slot in a bounded fan-out:

```bash
# scenario: spawn 8 workers, react as each finishes (Bash 5.1+)
declare -a pids=()
for task in "${tasks[@]}"; do
  do_task "$task" &
  pids+=( $! )
done

declare -- done_pid rc
for ((i=0; i<${#pids[@]}; i+=1)); do
  wait -n -p done_pid; rc=$?
  printf 'pid %d finished with rc=%d\n' "$done_pid" "$rc"
done
```

`wait -n` blocks until any one of the script's children exits and
sets `$?` to that child's status. `-p done_pid` stores the PID so the
loop can reconcile it against the tracking array (see §16.5 for the
slot-management variant).

### Pre-5.1 fallback

Without `-p`, the script must scan its tracking array to discover
which child finished. The portable replacement is `wait` on a single
PID at a time, accepting head-of-line blocking:

```bash
# scenario: pre-5.1 — wait sequentially in spawn order
for pid in "${pids[@]}"; do
  wait "$pid"; rc=$?
  (( rc == 0 )) || warn "pid $pid failed (rc=$rc)"
done
```

This loses the "react as soon as any child finishes" property — a slow
first child blocks the loop until it completes — but is portable to
Bash 4.x and busybox-derived shells.

### Strict-mode interaction

`wait`'s exit status follows the child's exit status. Under
`set -e`, a non-zero from `wait` propagates and exits the script
unless the call appears in an exempt context (`||`, `if`, `while`).
Always capture: `wait "$pid" || rc=$?`.

### See also

- §16.3 — `wait $pid` for a specific child
- §16.5 — bounded fan-out using `wait -n -p`
- BCS1103 (wait patterns), BCS0601 (exit on error)

#fin
