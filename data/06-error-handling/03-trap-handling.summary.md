## Trap Handling

**Standard cleanup pattern:**

```bash
cleanup() {
  local -i exitcode=${1:-0}

  # Disable trap during cleanup to prevent recursion
  trap - SIGINT SIGTERM EXIT

  # Cleanup operations
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile" ||:

  # Log cleanup completion
  ((exitcode == 0)) && info 'Cleanup completed successfully' || warn "Cleanup after error (exit $exitcode)"

  exit "$exitcode"
}

# Install trap
trap 'cleanup $?' SIGINT SIGTERM EXIT
```

**Rationale:** Ensures temp files, locks, processes are cleaned up on errors/signals. Captures exit status via `$?`. Handles SIGINT (Ctrl+C), SIGTERM (kill), and EXIT (always runs).

**Trap signals:**

| Signal | When Triggered |
|--------|----------------|
| `EXIT` | Always on script exit |
| `SIGINT` | Ctrl+C |
| `SIGTERM` | `kill` command |
| `ERR` | Command fails (with `set -e`) |

**Common patterns:**

```bash
# Temp file cleanup
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

# Temp directory cleanup
temp_dir=$(mktemp -d) || die 1 'Failed to create temp directory'
trap 'rm -rf "$temp_dir"' EXIT

# Lockfile cleanup
lockfile=/var/lock/myapp.lock
acquire_lock() {
  if [[ -f "$lockfile" ]]; then
    die 1 "Already running (lock file exists ${lockfile@Q})"
  fi
  echo $$ > "$lockfile" || die 1 "Failed to create lock file ${lockfile@Q}"
  trap 'rm -f "$lockfile"' EXIT
}

# Background process cleanup
long_running_command &
bg_pid=$!
trap 'kill $bg_pid 2>/dev/null' EXIT
```

**Comprehensive cleanup example:**

```bash
#!/usr/bin/env bash
set -euo pipefail

declare -- temp_dir='' lockfile=''
declare -i bg_pid=0

cleanup() {
  local -i exitcode=${1:-0}
  trap - SIGINT SIGTERM EXIT

  ((bg_pid)) && kill "$bg_pid" 2>/dev/null ||:
  [[ -n "$temp_dir" && -d "$temp_dir" ]] && rm -rf "$temp_dir" ||:
  [[ -n "$lockfile" && -f "$lockfile" ]] && rm -f "$lockfile" ||:

  ((exitcode == 0)) && info 'Script completed successfully' || error "Script exited with error code: $exitcode"
  exit "$exitcode"
}

# Install trap EARLY (before creating resources)
trap 'cleanup $?' SIGINT SIGTERM EXIT

temp_dir=$(mktemp -d)
lockfile=/var/lock/myapp-"$$".lock
echo $$ > "$lockfile"

monitor_process &
bg_pid=$!

main "$@"
```

**Multiple trap handlers:**

```bash
# ✗ Second trap REPLACES the first!
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT

# ✓ Combine in one trap or use function
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT
trap 'cleanup' EXIT
```

**Trap execution order:** On Ctrl+C: SIGINT handler runs, then EXIT handler runs, then script exits.

**Disabling traps:**

```bash
trap - EXIT                    # Disable specific trap
trap - SIGINT                  # Ignore Ctrl+C during critical section
perform_critical_operation
trap 'cleanup $?' SIGINT       # Re-enable
```

**Anti-patterns:**

```bash
# ✗ Not preserving exit code
trap 'rm -f "$temp_file"; exit 0' EXIT

# ✓ Preserve exit code
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

# ✗ Double quotes expand variables at trap definition time
temp_file=/tmp/foo
trap "rm -f $temp_file" EXIT  # Expands NOW to /tmp/foo
temp_file=/tmp/bar            # Trap still removes /tmp/foo!

# ✓ Single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

# ✗ Resource created before trap installed
temp_file=$(mktemp)
trap 'cleanup $?' EXIT        # Leak if script exits between these lines!

# ✓ Set trap BEFORE creating resources
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

# ✗ Complex cleanup inline
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

# ✓ Use cleanup function
cleanup() { rm -f "$file1" "$file2"; kill "$pid" 2>/dev/null; rm -rf "$dir"; }
trap 'cleanup' EXIT
```

**Best practices:**
- Always use cleanup function for non-trivial cleanup
- Disable trap inside cleanup to prevent recursion
- Set trap early before creating resources
- Preserve exit code with `trap 'cleanup $?' EXIT`
- Use single quotes to delay variable expansion
