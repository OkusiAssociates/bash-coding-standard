# Concurrency & Jobs - Rulets
## Background Job Management
- [BCS1101] Start background jobs with `&` and immediately capture PID: `command & pid=$!`; never leave background processes untracked.
- [BCS1101] Track multiple background PIDs in an array: `pids+=($!)` after each background command.
- [BCS1101] Check if a process is running using signal 0: `kill -0 "$pid" 2>/dev/null`.
- [BCS1101] Always set up cleanup trap for background jobs: `trap 'cleanup $?' SIGINT SIGTERM EXIT` to kill remaining processes on script exit.
- [BCS1101] Never use `$$` to reference background job PID; use `$!` which captures the last background process ID.
- [BCS1101] Prevent trap recursion by resetting traps at start of cleanup: `trap - SIGINT SIGTERM EXIT`.
## Parallel Execution
- [BCS1102] Capture parallel output to temp files then display in order: write each job's output to `"$temp_dir/$identifier.out"`, wait for all, then cat in sequence.
- [BCS1102] Implement concurrency limits by checking `${#pids[@]} >= max_jobs` and calling `wait -n` before spawning new jobs.
- [BCS1102] Never modify parent variables from background subshells; use temp files to collect results: `echo 1 >> "$temp_dir"/count` then `wc -l < "$temp_dir"/count`.
- [BCS1102] Clean up temp directories with EXIT trap: `trap 'rm -rf "$temp_dir"' EXIT`.
## Wait Patterns
- [BCS1103] Always capture wait exit code: `wait "$pid"; exit_code=$?`; never ignore the return value.
- [BCS1103] Track errors when waiting for multiple jobs: `for pid in "${pids[@]}"; do wait "$pid" || ((errors+=1)); done`.
- [BCS1103] Use `wait -n` (Bash 4.3+) to process jobs as they complete rather than waiting for all.
- [BCS1103] Update active PID list after `wait -n` by checking which PIDs still respond to `kill -0`.
- [BCS1103] Collect exit codes in associative array for per-job error reporting: `exit_codes[$server]=$?`.
## Timeout Handling
- [BCS1104] Always use `timeout` for network operations and potentially hanging commands: `timeout 30 long_running_command`.
- [BCS1104] Handle timeout exit code 124 specifically: `((exit_code == 124))` indicates the command timed out.
- [BCS1104] Use `--kill-after` for graceful shutdown: `timeout --signal=TERM --kill-after=10 60 command` sends SIGTERM first, SIGKILL after grace period.
- [BCS1104] Know timeout exit codes: 124=timed out, 125=timeout failed, 126=not executable, 127=not found, 137=killed by SIGKILL.
- [BCS1104] Use `read -t` for user input timeouts: `read -r -t 10 -p 'Prompt: ' var || var='default'`.
- [BCS1104] Set SSH connection timeouts: `ssh -o ConnectTimeout=10 -o BatchMode=yes "$server"`.
## Exponential Backoff
- [BCS1105] Implement exponential delay between retries: `delay=$((2 ** attempt))` doubles wait time each attempt.
- [BCS1105] Cap maximum delay to prevent excessive waits: `((delay > max_delay)) && delay=$max_delay`.
- [BCS1105] Add jitter to prevent thundering herd: `jitter=$((RANDOM % base_delay)); delay=$((base_delay + jitter))`.
- [BCS1105] Never use fixed-delay retry loops; always increase delay exponentially to reduce load on failing services.
- [BCS1105] Set maximum retry attempts and fail explicitly: `((attempt > max_attempts)) && die 1 'Max retries exceeded'`.
- [BCS1105,BCS1104] Combine timeout with backoff for robust network operations: wrap timed commands in retry loops with exponential delays.
