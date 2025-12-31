# Concurrency & Jobs - Rulets

## Background Job Management

- [BCS1101] Always track PIDs when starting background jobs: `command &; pid=$!` - never start jobs without capturing the PID for later management.
- [BCS1101] Use `kill -0 "$pid" 2>/dev/null` to check if a process is still running (signal 0 = existence check only).
- [BCS1101] Never use `$$` to reference background job PID; use `$!` which captures the last background process PID.
- [BCS1101] Implement cleanup traps for background jobs: `trap 'cleanup $?' SIGINT SIGTERM EXIT` and kill all tracked PIDs in the cleanup function.
- [BCS1101] Store background PIDs in an array for batch management: `declare -a pids=(); command &; pids+=($!)`.
- [BCS1101] Reset trap handlers inside cleanup to prevent recursion: `trap - SIGINT SIGTERM EXIT`.

## Parallel Execution

- [BCS1102] Capture parallel output to temp files for ordered display: write each job's output to `"$temp_dir/$id.out"`, wait for all, then cat in original order.
- [BCS1102] Limit concurrent jobs by checking array size before starting new ones: `while ((${#pids[@]} >= max_jobs)); do wait -n; done`.
- [BCS1102] Never modify variables inside background subshells expecting parent visibility; use temp files to aggregate results: `echo 1 >> "$temp_dir/count"`.
- [BCS1102] Remove completed PIDs from tracking array by testing each with `kill -0 "$pid" 2>/dev/null`.

## Wait Patterns

- [BCS1103] Always capture wait exit code: `wait "$pid"; exit_code=$?` - never ignore the return value.
- [BCS1103] Track failures when waiting for multiple jobs: `for pid in "${pids[@]}"; do wait "$pid" || ((errors+=1)); done`.
- [BCS1103] Use `wait -n` (Bash 4.3+) to process jobs as they complete rather than waiting for all in sequence.
- [BCS1103] Store exit codes in associative array keyed by task identifier for detailed failure reporting: `declare -A exit_codes=()`.
- [BCS1103] Handle wait errors gracefully: `wait "$pid" || die 1 'Command failed'`.

## Timeout Handling

- [BCS1104] Always use `timeout` for network operations: `timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'`.
- [BCS1104] Check for timeout exit code 124 specifically: `if ((exit_code == 124)); then warn 'Command timed out'; fi`.
- [BCS1104] Use `--kill-after` for stubborn processes: `timeout --signal=TERM --kill-after=10 60 command`.
- [BCS1104] Know timeout exit codes: 124=timed out, 125=timeout failed, 126=not executable, 127=not found, 137=SIGKILL.
- [BCS1104] Use `read -t` for user input timeouts: `read -r -t 10 -p 'Enter value: ' value || value='default'`.
- [BCS1104] Set SSH connection timeouts explicitly: `ssh -o ConnectTimeout=10 -o BatchMode=yes "$server"`.

## Exponential Backoff

- [BCS1105] Use exponential backoff for retries: `delay=$((2 ** attempt))` - never use fixed delays that can flood services.
- [BCS1105] Cap maximum delay to prevent excessive waits: `((delay > max_delay)) && delay=$max_delay`.
- [BCS1105] Add jitter to prevent thundering herd: `jitter=$((RANDOM % base_delay)); delay=$((base_delay + jitter))`.
- [BCS1105] Set a maximum attempt limit and fail explicitly: `((attempt > max_attempts)) && die 1 'Max retries exceeded'`.
- [BCS1105] Validate success conditions beyond exit code when appropriate: check for non-empty output with `[[ -s "$temp_file" ]]`.

## General Concurrency Principles

- [BCS1100] Always clean up background jobs and handle partial failures gracefully.
- [BCS1101,BCS1103] Combine PID tracking with proper wait handling: track all PIDs at start, wait for each with error capture at end.
- [BCS1104,BCS1105] Combine timeouts with backoff for robust network operations: timeout prevents hangs, backoff handles transient failures.
