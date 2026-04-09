# Section 11: Concurrency & Jobs

## BCS1100 Section Overview

Background job management, parallel execution, wait patterns, timeouts, and retry logic. Never leave background jobs unmanaged.

## BCS1101 Background Job Management

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
    kill "$pid" 2>/dev/null || true
  done
  exit "$exitcode"
}
trap 'cleanup $?' SIGINT SIGTERM EXIT

# wrong
command &                            # untracked background job
```

Use `$!` for the last background PID. Never use `$$` (that's the parent PID).

## BCS1102 Parallel Execution

For ordered output, write results to temp files then display in order.

```bash
# correct — parallel with ordered output
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"' EXIT
declare -a pids=()

for server in "${servers[@]}"; do
  check_server "$server" > "$temp_dir"/"$server".out 2>&1 &
  pids+=($!)
done

# Wait and display in order
for server in "${servers[@]}"; do
  wait "${pids[0]}" ||:
  pids=("${pids[@]:1}")
  cat "$temp_dir"/$server".out
done
```

Implement concurrency limits by checking `${#pids[@]}` against `max_jobs` and using `wait -n` to wait for slots.

Never modify variables in background subshells expecting parent visibility — use temp files for results.

## BCS1103 Wait Patterns

Always capture wait exit codes.

```bash
# correct — track errors across waits
declare -i errors=0
for pid in "${pids[@]}"; do
  wait "$pid" || errors+=1
done
((errors == 0)) || die 1 "$errors job(s) failed"

# correct — process as completed (Bash 4.3+)
while ((${#pids[@]})); do
  wait -n || errors+=1
done

# wrong — ignoring return value
wait $!
```

## BCS1104 Timeout Handling

Wrap network operations with timeout.

```bash
# correct
timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'
timeout --signal=TERM --kill-after=10 60 long_command

# correct — handle timeout exit code
case $? in
  0)   success 'Command completed' ;;
  124) error 'Command timed out' ;;
  125) error 'Timeout itself failed' ;;
  *)   error 'Command failed' ;;
esac

# correct — user input timeout with default
read -r -t 10 -p 'Enter value: ' value || value='default'

# correct — SSH and curl timeouts
ssh -o ConnectTimeout=10 -o BatchMode=yes "$host" 'command'
curl --connect-timeout 10 --max-time 60 "$url"
```

## BCS1105 Exponential Backoff

Use exponential backoff for retries. Never use fixed delays.

```bash
# correct
declare -i attempt=1 max_attempts=5 delay max_delay=60 jitter

while ((attempt <= max_attempts)); do
  if try_operation; then
    break
  fi

  delay=$((2 ** attempt))
  ((delay > max_delay)) && delay=$max_delay ||:

  # Add jitter to prevent thundering herd
  jitter=$((RANDOM % delay))
  sleep $((delay + jitter))

  attempt+=1
done

# wrong — tight retry loop
while ! curl "$url"; do :; done      # floods failing services
```

Validate success conditions beyond exit code — check output validity: `[[ -s "$temp_file" ]]`.
