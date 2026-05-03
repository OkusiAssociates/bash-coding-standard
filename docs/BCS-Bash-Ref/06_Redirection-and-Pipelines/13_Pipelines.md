<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.13 Pipelines

`a | b` connects `a`'s stdout to `b`'s stdin via a kernel pipe — a
fixed-capacity in-memory FIFO managed by `pipe()`. Each component runs
in its own process (typically a subshell, see §6.16 for the
`lastpipe` exception); they execute in parallel, with the kernel
synchronising on the pipe buffer's fill state. Bash adds no buffering
of its own — line-buffering vs block-buffering is the responsibility
of each component (most stdio-using programmes block-buffer when their
stdout is a pipe rather than a terminal).

### Forms

- `a | b` — single pipe; `a`'s fd 1 connects to `b`'s fd 0.
- `a |& b` — pipe stdout *and* stderr (§6.14); shorthand for
  `a 2>&1 | b`.
- `a | b | c | d` — multi-stage; three pipes, four processes, all
  running concurrently.
- `time a | b | c` — time the *whole* pipeline as one logical unit.
- `! a | b | c` — negate; pipeline status is logically inverted.

### Pipe semantics

- All components fork before any executes; they run in parallel.
- Each pipe has a kernel-side buffer (typically 64 KiB on Linux);
  writers block on full, readers block on empty.
- When the reader closes its fd, the writer receives SIGPIPE on the
  next write — default disposition is termination with exit status 141
  (= 128 + signal 13).
- The pipeline waits for the *rightmost* component (and, in modern
  bash, all components) before returning.

### Default exit status

Without `pipefail`, only the rightmost component's exit status becomes
`$?`. This is the standard pitfall: `producer | consumer` exits 0 if
*consumer* succeeds, even when *producer* failed catastrophically.
`pipefail` (§6.15) corrects this. The full status vector is always
available in `PIPESTATUS[]`:

```bash
# scenario: the PIPESTATUS array exposes every component's exit status
#!/usr/bin/env bash
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

# four-component pipeline with mixed success
true | (exit 3) | true | (exit 7)
echo "rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ rc=7 PIPESTATUS=0 3 0 7

# without pipefail the same pipeline returns just the last
set +o pipefail
true | (exit 3) | true | true
echo "rc=$? PIPESTATUS=${PIPESTATUS[*]}"
# ⇒ rc=0 PIPESTATUS=0 3 0 0   — failure of mid-component invisible in $?

# but PIPESTATUS preserves it
echo "second component status was: ${PIPESTATUS[1]}"
# ⇒ second component status was: 3
```

`PIPESTATUS[]` is overwritten by the *next* command — even a trivial
`[[ ]]` test reduces it to a one-element array holding `$?`. Snapshot
it immediately after the pipeline:

```bash
# scenario: capture PIPESTATUS before the next command clobbers it
set -uo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

curl -sf https://example.org/data.json | jq -e '.records[]' | head -50
declare -ai rcs=("${PIPESTATUS[@]}")    # snapshot now or lose it

if (( rcs[0] != 0 )); then
  echo "curl failed: rc=${rcs[0]}" >&2; exit 5
elif (( rcs[1] != 0 )); then
  echo "jq failed: rc=${rcs[1]}" >&2; exit 5
elif (( rcs[2] != 0 )); then
  # head closing early triggers SIGPIPE on jq → 141 expected and benign
  (( rcs[2] == 141 )) || { echo "head failed: rc=${rcs[2]}" >&2; exit 5; }
fi
```

### Subshell consequences

By default *every* component of a pipeline runs in a subshell — even
the rightmost — which means variables assigned inside a component are
not visible after the pipeline:

```bash
# WRONG — count stays 0
declare -i count=0
seq 1 5 | while read -r _; do count+=1; done
echo "count=$count"             # ⇒ count=0  (the while ran in a subshell)

# RIGHT — process substitution keeps the loop in the parent shell
declare -i count=0
while read -r _; do count+=1; done < <(seq 1 5)
echo "count=$count"             # ⇒ count=5

# RIGHT — lastpipe (§6.16) makes the LAST component run in the parent
shopt -s lastpipe
set +m                          # required when interactive
declare -i count=0
seq 1 5 | while read -r _; do count+=1; done
echo "count=$count"             # ⇒ count=5
```

Process substitution (§6.10) is the BCS-recommended fix; `lastpipe` is
the lighter-touch alternative when only the rightmost component needs
parent-shell scope.

### `time` and negation

`time a | b | c` times the whole pipeline as a single unit; the `time`
keyword binds at pipeline level. `! a | b | c` inverts the pipeline's
exit status (zero ↔ non-zero); useful for `if !` patterns guarding
against unexpected success.

**See also**: §6.14 (stderr pipelines `|&`), §6.15 (`pipefail`
semantics), §6.16 (`lastpipe`), §13.5 (`pipefail` + errexit), §9.3
(BCS0903 process substitution), §9.6 (BCS0906 find subshell pitfalls),
BCS0101 strict-mode trio.

#fin
