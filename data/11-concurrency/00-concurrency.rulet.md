# Concurrency & Jobs - Rulets
## Background Job Management
- [BCS1101] Always track PIDs when starting background jobs: `command &; pid=$!` — never leave background jobs unmanaged.
- [BCS1101] Use `$!` to capture the last background PID; never use `$$` which returns the parent PID.
- [BCS1101] Store multiple background PIDs in an array: `declare -a pids=(); command &; pids+=($!)`.
- [BCS1101] Check if a process is running with `kill -0 "$pid" 2>/dev/null` (signal 0 is existence check only).
- [BCS1101] Use `wait -n` (Bash 4.3+) to wait for any single job to complete rather than all jobs.
- [BCS1101] Implement cleanup traps for background jobs: `trap 'cleanup $?' SIGINT SIGTERM EXIT` with trap reset inside cleanup to prevent recursion.
- [BCS1101] In cleanup functions, kill remaining PIDs with `kill "$pid" 2>/dev/null || true` to suppress errors for already-terminated processes.
## Parallel Execution Patterns
- [BCS1102] For parallel execution with ordered output, write results to temp files (`"$temp_dir/$server.out"`) then display in original order after all jobs complete.
- [BCS1102] Implement concurrency limits by checking `${#pids[@]}` against `max_jobs` and using `wait -n` to wait for slots.
- [BCS1102] Update active PID lists by testing each PID with `kill -0 "$pid" 2>/dev/null` and rebuilding the array.
- [BCS1102] Never modify variables in background subshells expecting parent visibility; use temp files for results: `echo 1 >> "$temp_dir"/count`.
- [BCS1102] Clean up temp directories with `trap 'rm -rf "$temp_dir"' EXIT` when using parallel output capture.
## Wait Patterns
- [BCS1103] Always capture wait exit codes: `wait "$pid"; exit_code=$?` — never discard return values.
- [BCS1103] Track errors across multiple waits: `declare -i errors=0; for pid in "${pids[@]}"; do wait "$pid" || errors+=1; done`.
- [BCS1103] Use `wait -n` in a loop with PID existence checks to process jobs as they complete rather than in start order.
- [BCS1103] For per-server error tracking, use associative arrays: `declare -A exit_codes=()` storing PID then replacing with actual exit code after wait.
- [BCS1103] Never ignore wait return values; use `wait $! || die 1 'Command failed'` to handle failures.
## Timeout Handling
- [BCS1104] Always wrap network operations with timeout: `timeout 300 ssh -o ConnectTimeout=10 "$server" 'command'`.
- [BCS1104] Handle timeout exit code 124 specially: command timed out; 125 means timeout itself failed; 137 means killed by SIGKILL.
- [BCS1104] Use `--signal=TERM --kill-after=10` to send SIGTERM first with SIGKILL fallback after grace period.
- [BCS1104] For user input timeouts, use `read -r -t 10 -p 'prompt: ' var` and provide defaults on timeout.
- [BCS1104] Set SSH connection timeouts: `ssh -o ConnectTimeout=10 -o BatchMode=yes` and curl timeouts: `curl --connect-timeout 10 --max-time 60`.
- [BCS1104] Create reusable timeout wrapper functions that handle exit codes via case statement: 124 (timeout), 125 (timeout failed), default (command failed).
## Exponential Backoff
- [BCS1105] Use exponential backoff `sleep $((2 ** attempt))` for retries; never use fixed delays which fail to reduce load on struggling services.
- [BCS1105] Cap maximum delay to prevent excessive waits: `((delay > max_delay)) && delay=$max_delay ||:`.
- [BCS1105] Add jitter to prevent thundering herd: `jitter=$((RANDOM % base_delay)); delay=$((base_delay + jitter))`.
- [BCS1105] Structure retry loops with attempt counter and max_attempts check: `while ((attempt <= max_attempts)); do ... attempt+=1; done`.
- [BCS1105] Validate success conditions beyond just exit code; check output validity: `[[ -s "$temp_file" ]]` for non-empty results.
- [BCS1105] Never retry immediately in a tight loop (`while ! curl "$url"; do :; done`); this floods failing services.
