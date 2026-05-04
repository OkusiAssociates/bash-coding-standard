<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.10 Process substitution as redirection

Process substitution (§5.7) is a redirection mechanism in disguise.
`<(cmd)` and `>(cmd)` resolve at parse time to a `/dev/fd/N` filename
that bash hands to the surrounding command, while spawning *cmd* as a
child process whose stdout (or stdin) is connected to that fd. The
calling command sees a path; the kernel sees a pipe. This dual
character makes process substitution the answer to several problems
that pipes cannot solve and that temp files solve only with explicit
cleanup.

### Forms

- `<(cmd)` — *cmd*'s stdout is delivered as a readable file
  (`/dev/fd/N`); the surrounding command opens it for input.
- `>(cmd)` — *cmd*'s stdin is delivered as a writable file; the
  surrounding command opens it for output.
- Multiple substitutions in one command line: each gets its own
  `/dev/fd/N` and its own background child.
- Lifetime: each child lives until the surrounding command finishes
  reading or writing and closes the fd.

### Multi-input commands — the `diff` idiom

Process substitution shines where a tool wants two file arguments and
the contents are computed, not stored. The classic case is comparing
the sorted output of two pipelines:

```bash
# scenario: compare sorted directory listings without intermediate temp files
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Set up two demo directory listings as input fixtures:
mkdir -p _enabled _available
: > _enabled/site-a.conf && : > _enabled/site-b.conf
: > _available/site-a.conf && : > _available/site-c.conf

diff <(ls -1 _enabled | sort) <(ls -1 _available | sort) || true
# ⇒ < site-b.conf
# ⇒ > site-c.conf
# (each sub-pipeline runs in parallel; fds are /dev/fd/63 and /dev/fd/62)
```

Without `<()`, the same effect requires two temp files, two `mktemp`
calls, and a trap to clean them up. Process substitution does it with
zero file system state.

### Tee-split-stdout-and-stderr — the canonical idiom

`>()` lets a command split its output streams to multiple sinks while
still appearing on the terminal. Combined with `tee`, this is the
standard "log everything" pattern for build scripts:

```bash
# scenario: capture stdout and stderr to separate logs while keeping both visible
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

build_step() {
  echo 'progress: phase 1'
  echo 'warning: deprecated flag' >&2
  echo 'progress: phase 2'
  return 0
}

build_step \
  > >(tee build.out)    \
  2> >(tee build.err >&2)
wait                          # let the tee children flush before we read
# ⇒ progress: phase 1
# ⇒ progress: phase 2
# (build.out holds the two progress lines; build.err holds the warning,
#  which also re-appears on terminal stderr via the inner `tee … >&2`)
```

The `>&2` inside the second `tee` re-routes its stdout (which is
`tee`'s copy of the original stderr) back to the script's stderr,
preserving the visible-on-terminal property. Without it, the warning
would land on stdout from `tee`'s perspective, mingling streams.

### Exit-status nuance

The exit status of a process substitution is *not* propagated to `$?`:
the surrounding command's status is `$?`, while the substituted child's
status is invisible. Process substitution is therefore unsafe for
detecting failure of the substituted command. The standard
work-arounds:

```bash
# scenario: detect failure inside <( ) — which is otherwise silent
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# Pattern: write child's status into a sentinel file
declare -- sentinel; sentinel=$(mktemp)
trap 'rm -f "$sentinel"' EXIT

while read -r line; do
  echo "consumed: $line"
done < <(producer; printf '%s' "$?" >"$sentinel")

declare -i child_rc; child_rc=$(<"$sentinel")
((child_rc == 0)) || die 5 "producer failed: rc=$child_rc"
```

If `lastpipe` is enabled (§6.16), the simpler `producer | while read`
form delivers the producer's status directly via `PIPESTATUS[]` —
process substitution is necessary only when the consumer cannot run in
the pipeline tail (e.g. it must mutate enclosing scope variables in a
non-pipeline context).

### Lifetime and cleanup nuances

- The child of `<(cmd)` is reaped when the surrounding command closes
  its read fd. If the surrounding command never reads, the child is
  orphaned until script exit.
- `>(cmd)` similarly: the child waits on EOF on its stdin. A
  surrounding command that exits before flushing all its output to the
  `>()` substitute can lose late writes.
- Process substitution does *not* set `$!` — there is no PID variable
  exposed for the substituted child. To wait on it, you must `wait`
  for all background children or arrange a sentinel.
- Under `set -e`, a failed substituted child does not abort the script
  unless its status reaches `$?` via some other mechanism (e.g. the
  sentinel pattern above). This is the single biggest gotcha: a
  silently-failing `<(producer)` can deliver an empty stream, the
  consumer reports "no data", and the script proceeds as if all is
  well.

### Platform notes

Process substitution requires `/dev/fd` (Linux, macOS, BSD). On
systems without `/dev/fd`, bash falls back to FIFOs in `/tmp`, which
may interact poorly with restrictive `noexec`/`nodev` mount options.
Within the BCS-targeted Linux environment, `/dev/fd/N` is always
available. For containerised environments, verify `/dev/fd` is mounted
in the runtime image — the symptom of its absence is a parse-time
"redirection error: cannot create temp file" diagnostic.

**See also**: §5.7 (process substitution as expansion), §6.13
(pipelines), §6.16 (`lastpipe`), §13.5 (`pipefail` and PIPESTATUS),
§9.3 (BCS0903 process substitution patterns), §9.6 (BCS0906 find
subshell pitfalls).

#fin
