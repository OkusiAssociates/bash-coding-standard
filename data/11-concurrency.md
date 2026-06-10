<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Section 11: Concurrency & Jobs

## BCS1100 Section Overview

Background job management, parallel execution, wait patterns, timeouts, and retry logic. Never leave background jobs unmanaged.

## BCS1101 Background Job Management

**Tier:** core

Always track PIDs when starting background jobs.

```bash
# correct
command &
pid=$!

# correct — multiple PIDs
declare -a pids=()
command1 &
pids+=($!)
command2 &
pids+=($!)

# correct — check if process is running
kill -0 "$pid" 2>/dev/null           # signal 0 = existence check

# correct — cleanup in trap
cleanup() {
  local -i exitcode=${1:-$?}
  trap - SIGINT SIGTERM EXIT
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null ||:
  done
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# wrong
command &                            # untracked background job
```

Use `$!` for the last background PID. Never use `$$` (that's the parent PID).

## BCS1102 Parallel Execution

**Tier:** recommended

For ordered output, write results to temp files then display in order.

```bash
# correct — parallel with ordered output
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
declare -a pids=()
declare -i errors=0

for server in "${servers[@]}"; do
  check_server "$server" &> "$temp_dir"/"$server".out &
  pids+=($!)
done

# Wait and display in order; accumulate failures (BCS1103)
for server in "${servers[@]}"; do
  wait "${pids[0]}" || errors+=1
  pids=("${pids[@]:1}")
  cat "$temp_dir"/"$server".out
done
((errors == 0)) || die 1 "$errors job(s) failed"
```

Implement concurrency limits by checking `${#pids[@]}` against `max_jobs` and using `wait -n` to wait for slots.

Never modify variables in background subshells expecting parent visibility — use temp files for results.

## BCS1103 Wait Patterns

**Tier:** core

Never discard the exit code of `wait`. Accumulate failures into a counter and fail the script once at the end if any background job failed. An unsuppressed `wait` under `set -e` terminates the script on the first failure -- losing information about other in-flight jobs.

```bash
# correct — accumulator pattern over a fixed list of pids
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || errors+=1
done
((errors == 0)) || die 1 "$errors job(s) failed"

# correct — process-as-completed (Bash 4.3+ wait -n)
declare -i errors=0
while ((${#pids[@]})); do
  wait -n || errors+=1
  pids=("${pids[@]:1}")
done
((errors == 0)) || die 1 "$errors job(s) failed"

# wrong — exit code discarded; failures silent
wait "$pid" ||:

# wrong — no accumulator; first failure kills script under set -e
for pid in "${pids[@]}"; do
  wait "$pid"
done
```

## BCS1104 Timeout Handling

**Tier:** core

Wrap network and remote operations (`ssh`, `curl`, `wget`, `nc`) with `timeout` or tool-native timeout flags. Bounding other operations that can block indefinitely — interactive `read` (use `read -t`), long-running local commands — is recommended but not required by this rule.

```bash
# correct
timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'
timeout --signal=TERM --kill-after=10 60 long_command

# correct — capture the exit code first; a bare command under set -e aborts
# before any `case $?` could run, so guard with `|| rc=$?`
declare -i rc=0
timeout 300 ssh -o ConnectTimeout=10 "$server" 'command' || rc=$?
case $rc in
  0)   success 'Command completed' ;;
  124) error 'Command timed out' ;;
  125) error 'Timeout itself failed' ;;
  *)   error 'Command failed' ;;
esac

# correct — user input timeout with default
read -r -t 10 -p 'Enter value: ' value || value='default'

# correct — SSH and curl timeouts
# ConnectTimeout bounds connection only — wrap in `timeout` to bound total runtime
timeout 300 ssh -o ConnectTimeout=10 -o BatchMode=yes "$host" 'command'
curl --connect-timeout 10 --max-time 60 "$url"
```

## BCS1105 Exponential Backoff

**Tier:** recommended

Use exponential backoff for retries. Never use fixed delays.

```bash
# correct
declare -i attempt=1 max_attempts=5 delay max_delay=60 jitter
out=$(mktemp)
trap 'rm -f "$out"' EXIT

while ((attempt <= max_attempts)); do
  # Success requires both exit code 0 and non-empty output
  if try_operation > "$out" && [[ -s "$out" ]]; then
    break
  fi

  delay=$((2 ** attempt))
  ((delay > max_delay)) && delay=$max_delay ||:

  # Add jitter to prevent thundering herd
  jitter=$((RANDOM % delay))
  sleep $((delay + jitter))

  attempt+=1
done
((attempt <= max_attempts)) || die 1 "operation failed after $max_attempts attempts"

# wrong — tight retry loop
while ! curl "$url"; do :; done      # floods failing services
```

Validate success conditions beyond exit code — the example treats empty output as failure via `[[ -s "$out" ]]`.
