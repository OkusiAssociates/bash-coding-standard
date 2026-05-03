<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.4 Capturing per-child exit status

`wait` only reports a single child's status at a time. To aggregate
results across a fan-out, hold the PIDs in one array and the statuses in
a parallel array indexed identically. The pattern below is the canonical
shape for a fan-out that must report each failure individually rather
than collapsing to "something failed" (BCS1103).

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# scenario: dispatch one worker per input, aggregate per-child status
declare -a inputs=(host1 host2 host3 host4)
declare -a pids=() statuses=()
declare -i i=0 rc=0

for host in "${inputs[@]}"; do
  worker "$host" &
  pids[i]=$!
  ((i+=1))
done

# wait on each PID positionally; statuses[i] aligns with pids[i]
for i in "${!pids[@]}"; do
  if wait "${pids[i]}"; then
    statuses[i]=0
  else
    statuses[i]=$?
    rc=1
  fi
done
```

Aggregation logic must read both arrays together so the message names
the failing input, not just an index:

```bash
# scenario: human-readable failure report
for i in "${!pids[@]}"; do
  if (( statuses[i] != 0 )); then
    printf '%s failed (rc=%d, pid=%d)\n' \
      "${inputs[i]}" "${statuses[i]}" "${pids[i]}" >&2
  fi
done
exit "$rc"
# ⇒ exits 1 if any worker failed; stderr names each failed host
```

Notes:

- `wait "$pid"` returns the child's exit code; `set -e` would abort the
  loop on the first non-zero, so the explicit `if` is required. Trapping
  with `||` is equally valid: `wait "${pids[i]}" || statuses[i]=$?`.
- For a fixed-size pool, capture status inside the slot-recycling loop
  (see §16.5) rather than after a single `wait` barrier.
- `wait -n` (Bash 5.1+) reports the *next* child to exit but loses the
  per-PID mapping unless you also pass `-p var` to capture which PID it
  was; see §16.2.
- Per-child timeouts belong on the child, not the parent: wrap the
  worker in `timeout 30 worker "$host"` so the timeout exit code (124)
  propagates as a normal child status into `statuses[i]`.

### Aggregation policies

The shape above records every status; how the script *acts* on them
depends on policy. Three policies cover almost every real case:

```bash
# policy A — fail-fast: exit on the first non-zero, after killing siblings
for i in "${!pids[@]}"; do
  if ! wait "${pids[i]}"; then
    statuses[i]=$?
    kill -TERM "${pids[@]}" 2>/dev/null || true
    exit "${statuses[i]}"
  fi
done

# policy B — collect-all: run every child to completion, return worst rc
declare -i worst=0
for i in "${!pids[@]}"; do
  wait "${pids[i]}" || statuses[i]=$?
  (( statuses[i] > worst )) && worst=${statuses[i]}
done
exit "$worst"

# policy C — best-effort: tolerate failures, exit 0 unless all failed
declare -i ok=0
for i in "${!pids[@]}"; do
  wait "${pids[i]}" && ((ok+=1)) || statuses[i]=$?
done
(( ok > 0 )) || exit 1
```

Pick the policy that matches the caller's contract. A backup script
usually wants policy B; a deployment fan-out usually wants A; a
notification dispatcher usually wants C.

**See also**: §16.2 (`wait`/`wait -n`), §16.3 (single-child wait),
§16.5 (bounded fan-out), §16.11 (signal handling).

#fin
