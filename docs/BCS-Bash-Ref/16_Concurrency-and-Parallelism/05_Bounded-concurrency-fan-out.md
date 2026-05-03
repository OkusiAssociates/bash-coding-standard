<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 16.5 Bounded-concurrency fan-out

Run N tasks in parallel with a cap on simultaneously-running jobs
(BCS1102). The pattern: spawn until the cap is reached, then wait
for one slot to free up before spawning the next.

### Bash 5.1+ canonical form

```bash
# scenario: 4-way fan-out across an array of tasks
declare -i max=4
declare -a pids=()
declare -- done_pid

for task in "${tasks[@]}"; do
  while (( ${#pids[@]} >= max )); do
    wait -n -p done_pid
    # remove the finished PID from the tracking array
    for i in "${!pids[@]}"; do
      if [[ ${pids[i]} == "$done_pid" ]]; then
        unset 'pids[i]'
        break
      fi
    done
  done
  do_task "$task" &
  pids+=( $! )
done
wait      # drain whatever survived the last slot
```

`unset 'pids[i]'` removes the element by index. The array is now
*sparse* — index `i` is gone but other indices remain valid. The
`while (( ${#pids[@]} >= max ))` test counts living elements
correctly; sparse arrays do not corrupt `${#arr[@]}`.

### The buggy "alternative" to avoid

A common-but-broken shortcut tries to remove the PID with parameter-
expansion replacement:

```bash
# wrong — replacement only mutates string content, not array membership
pids=( "${pids[@]/$done_pid/}" )
# result: PID becomes empty string, array length unchanged
# the bound check ${#pids[@]} >= max never decreases — deadlock
```

`${arr[@]/x/}` rewrites each element's string content; if an element
*equals* `done_pid`, it becomes the empty string but stays in the
array. The slot count never drops, the `while` loop spins, and after
the next `wait -n` the same `done_pid` is "removed" again with no
effect. The index-based `unset` is the only correct form.

### Pre-5.1 fallback

Without `wait -n -p`, the script must poll. The simplest fallback
uses `wait -n` (4.3+) and a per-iteration scan:

```bash
# scenario: 4.3+ form, no -p — scan jobs to find the dead one
declare -i max=4
declare -a pids=()

for task in "${tasks[@]}"; do
  while (( ${#pids[@]} >= max )); do
    wait -n         # blocks until any child exits
    for i in "${!pids[@]}"; do
      kill -0 "${pids[i]}" 2>/dev/null || unset 'pids[i]'
    done
  done
  do_task "$task" &
  pids+=( $! )
done
wait
```

`kill -0 PID` returns 0 if the PID exists (in any state) and non-zero
if it has been reaped. Iterating after `wait -n` finds and removes
exactly the dead entry. Less efficient than the 5.1+ form (one extra
syscall per tracked PID per cycle) but correct.

### External alternative: GNU `parallel`

```bash
parallel -j 4 do_task ::: "${tasks[@]}"
```

External dependency but battle-tested — see §16.8. Prefer for
production work where the bash version of the consumers is uncertain.

### See also

- §16.2 — `wait` and `wait -n` reference
- §16.7 — `xargs -P` for the simpler one-input/one-job case
- §16.8 — GNU parallel
- BCS1102 (parallel execution), BCS1103 (wait patterns)

#fin
