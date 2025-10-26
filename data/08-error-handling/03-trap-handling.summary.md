## Trap Handling

**Standard cleanup pattern:**

```bash
cleanup() {
  local -i exitcode=${1:-0}

  # Disable trap during cleanup to prevent recursion
  trap - SIGINT SIGTERM EXIT

  # Cleanup operations
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir"
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile"

  # Log cleanup completion
  ((exitcode == 0)) && info 'Cleanup completed successfully' || warn "Cleanup after error (exit $exitcode)"

  exit "$exitcode"
}

# Install trap
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Rationale:** Ensures resources (temp files, locks, processes) are cleaned regardless of exit path (normal, error, Ctrl+C, kill). Preserves original exit code. Prevents partial state corruption.

**Trap signals:**

| Signal | Triggered By |
|--------|--------------|
| `EXIT` | Any script exit (normal or error) |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |
| `ERR` | Command failure with `set -e` |

**Common patterns:**

**Temp file cleanup:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
echo "data" > "$temp_file"
# Cleanup automatic on exit
```

**Temp directory cleanup:**
```bash
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT
extract_archive "$archive" "$temp_dir"
```

**Lockfile cleanup:**
```bash
lockfile="/var/lock/myapp.lock"

acquire_lock() {
  if [[ -f "$lockfile" ]]; then
    die 1 "Already running (lock file exists: $lockfile)"
  fi
  echo $$ > "$lockfile" || die 1 'Failed to create lock file'
  trap 'rm -f "$lockfile"' EXIT
}

acquire_lock
```

**Process cleanup:**
```bash
long_running_command &
bg_pid=$!
trap 'kill $bg_pid 2>/dev/null' EXIT
```

**Comprehensive cleanup:**
```bash
#!/usr/bin/env bash
set -euo pipefail

declare -- temp_dir=''
declare -- lockfile=''
declare -i bg_pid=0

cleanup() {
  local -i exitcode=${1:-0}

  trap - SIGINT SIGTERM EXIT

  ((bg_pid > 0)) && kill "$bg_pid" 2>/dev/null

  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir" || warn "Failed to remove temp directory: $temp_dir"
  fi

  if [[ -n "$lockfile" && -f "$lockfile" ]]; then
    rm -f "$lockfile" || warn "Failed to remove lockfile: $lockfile"
  fi

  ((exitcode == 0)) && info 'Script completed successfully' || error "Script exited with error code: $exitcode"

  exit "$exitcode"
}

# Install trap EARLY (before creating resources)
trap 'cleanup $?' SIGINT SIGTERM EXIT

temp_dir=$(mktemp -d)
lockfile="/var/lock/myapp-$$.lock"
echo $$ > "$lockfile"

monitor_process &
bg_pid=$!

main "$@"
```

**Multiple trap handlers:**
```bash
#  Wrong - second trap REPLACES first
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT

#  Correct - combine in one trap
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT

#  Or use cleanup function
trap 'cleanup' EXIT
```

**Execution order:** On Ctrl+C: SIGINT handler runs, then EXIT handler runs, then script exits.

**Disabling traps:**
```bash
trap - EXIT
trap - SIGINT SIGTERM

# Disable during critical section
trap - SIGINT
perform_critical_operation
trap 'cleanup $?' SIGINT
```

**Critical best practices:**

**1. Prevent recursion:**
```bash
cleanup() {
  #  Disable trap first - prevents infinite recursion if cleanup fails
  trap - SIGINT SIGTERM EXIT
  rm -rf "$temp_dir"
  exit "$exitcode"
}
```

**2. Preserve exit code:**
```bash
#  Correct - capture $? immediately
trap 'cleanup $?' EXIT

#  Wrong - $? may change between trigger and handler
trap 'cleanup' EXIT
```

**3. Quote trap commands:**
```bash
#  Correct - single quotes delay variable expansion
trap 'rm -f "$temp_file"' EXIT

#  Wrong - double quotes expand now, not on trap execution
temp_file="/tmp/foo"
trap "rm -f $temp_file" EXIT  # Expands to: trap 'rm -f /tmp/foo' EXIT
temp_file="/tmp/bar"  # Trap still removes /tmp/foo!
```

**4. Set trap early:**
```bash
#  Correct - trap before resource creation
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

#  Wrong - resource leak if script exits between lines
temp_file=$(mktemp)
trap 'cleanup $?' EXIT
```

**Anti-patterns:**

```bash
#  Wrong - loses exit code
trap 'rm -f "$temp_file"; exit 0' EXIT

#  Correct
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

#  Wrong - missing function call syntax
trap cleanup EXIT

#  Correct
trap 'cleanup $?' EXIT

#  Wrong - complex inline logic
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

#  Correct - use function
cleanup() {
  rm -f "$file1" "$file2"
  kill "$pid" 2>/dev/null
  rm -rf "$dir"
}
trap 'cleanup' EXIT
```

**Testing:**
```bash
#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  echo "Cleanup called with exit code: ${1:-?}"
  trap - EXIT
  exit "${1:-0}"
}

trap 'cleanup $?' EXIT

echo "Normal operation..."
# Test: Ctrl+C, error (false), normal exit
```

**Summary:** Always use cleanup function for non-trivial cleanup. Disable trap inside cleanup to prevent recursion. Set trap early before creating resources. Preserve exit code with `trap 'cleanup $?' EXIT`. Use single quotes to delay expansion. Test with normal exit, errors, and signals.
