<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.7 The job table

When job control is enabled, bash maintains a per-shell *job table* that
records every pipeline started asynchronously (with `&`) or stopped via
SIGTSTP. Each entry has a job number (`%1`, `%2`, …), a process group id,
a status (`Running`, `Stopped`, `Done`, `Killed`, …), and the original
command line. The table is consulted by `jobs`, `fg`, `bg`, `disown`,
`wait`, and the `%spec` job-spec syntax (§11.8).

- One pipeline = one job, regardless of how many commands the pipeline
  contains.
- Each job is its own process group (see §11.6); the pgid is the leader's
  PID.
- Job numbers are recycled as completed jobs are reaped.
- The table is per-shell — subshells start with an empty job table even
  though they inherit the parent's running children at the kernel level.
- `set -m` toggles job control; `set +m` disables it.

### Interactive default vs non-interactive caveat

Job control is **on** by default in interactive shells and **off** in
non-interactive shells (the usual case for scripts). When off:

- `jobs` still works, but background commands run in the *same* process
  group as the script — they are not isolated.
- `%spec` job-control commands (`fg`, `bg`) error out.
- SIGINT delivered to the foreground pgid hits the script and every
  child simultaneously.

A script that needs to manage its children as separate process groups
must opt in explicitly:

```bash
# scenario: enabling job control in a non-interactive script
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
set -m                                    # turn job control ON
sleep 30 &                                # gets its own pgid
job_pid=$!
jobs -l                                   # ⇒ [1]+ <pid> Running    sleep 30
kill -INT -"$job_pid"                     # signal the whole group (§11.10)
wait "$job_pid" || true                   # reap; ignore non-zero
```

Without the `set -m` line, `kill -INT -"$job_pid"` would target the
script's own pgid — usually fatal. With it, the negative-PID form
delivers SIGINT only to the child's group.

### Inspecting the table

`jobs` lists current entries; flags filter the view:

| Flag | Purpose |
|------|---------|
| `-l` | include PID column |
| `-p` | print PIDs only (one per line) |
| `-r` | running jobs only |
| `-s` | stopped jobs only |
| `-n` | only jobs whose status changed since last `jobs` |

The `-n` form is the canonical way for a polling loop to react to child
state changes without re-listing the full table.

**See also**: §11.5 (foreground vs background), §11.6 (process groups),
§11.8 (job specifications), §11.9 (job-control builtins), §11.10 (kill),
§16 (concurrency), BCS-bash `25_JOB-CONTROL.md`, BCS1101 (background job
management).

#fin
