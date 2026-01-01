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

**Rationale:** Ensures temp files, locks, and processes are cleaned up on errors or signals. Preserves exit code via `$?`. Prevents partial state regardless of exit path.

**Signal reference:**

| Signal | When Triggered |
|--------|----------------|
| `EXIT` | Always on script exit (normal or error) |
| `SIGINT` | User presses Ctrl+C |
| `SIGTERM` | `kill` command (default signal) |
| `ERR` | Command fails (with `set -e`) |

**Common patterns:**

**Temp file/directory:**
```bash
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT
```

**Lockfile:**
```bash
lockfile=/var/lock/myapp.lock

acquire_lock() {
  if [[ -f "$lockfile" ]]; then
    die 1 "Already running (lock file exists ${lockfile@Q})"
  fi
  echo $$ > "$lockfile" || die 1 "Failed to create lock file ${lockfile@Q}"
  trap 'rm -f "$lockfile"' EXIT
}
```

**Background process:**
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

  ((bg_pid)) && kill "$bg_pid" 2>/dev/null

  if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
    rm -rf "$temp_dir" || warn "Failed to remove temp directory: $temp_dir"
  fi

  if [[ -n "$lockfile" && -f "$lockfile" ]]; then
    rm -f "$lockfile" || warn "Failed to remove lockfile: $lockfile"
  fi

  if ((exitcode == 0)); then
    info 'Script completed successfully'
  else
    error "Script exited with error code: $exitcode"
  fi

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

**Multiple traps:**
```bash
# ✗ This REPLACES the previous trap!
trap 'echo "Exiting..."' EXIT
trap 'rm -f "$temp_file"' EXIT

# ✓ Combine in one trap or use cleanup function
trap 'echo "Exiting..."; rm -f "$temp_file"' EXIT
```

**Execution order:** On Ctrl+C: SIGINT handler runs �' EXIT handler runs �' script exits.

**Disabling traps:**
```bash
trap - EXIT                    # Disable specific trap
trap - SIGINT                  # Ignore Ctrl+C during critical operation
perform_critical_operation
trap 'cleanup $?' SIGINT       # Re-enable
```

**Critical best practices:**

1. **Recursion prevention:** Disable trap first inside cleanup function
2. **Preserve exit code:** Use `trap 'cleanup $?' EXIT` - captures `$?` immediately
3. **Single quotes:** Delays variable expansion until trap fires
4. **Set trap early:** Before creating any resources

**Anti-patterns:**

```bash
# ✗ Wrong - not preserving exit code
trap 'rm -f "$temp_file"; exit 0' EXIT

# ✓ Correct
trap 'exitcode=$?; rm -f "$temp_file"; exit $exitcode' EXIT

# ✗ Wrong - double quotes expand now, not on trap
temp_file=/tmp/foo
trap "rm -f $temp_file" EXIT  # Expands immediately!
temp_file=/tmp/bar            # Trap still removes /tmp/foo!

# ✓ Correct - single quotes delay expansion
trap 'rm -f "$temp_file"' EXIT

# ✗ Wrong - resource before trap
temp_file=$(mktemp)
trap 'cleanup $?' EXIT  # Resource leaks if exit between lines!

# ✓ Correct - trap before resource
trap 'cleanup $?' EXIT
temp_file=$(mktemp)

# ✗ Wrong - complex logic inline
trap 'rm "$file1"; rm "$file2"; kill $pid; rm -rf "$dir"' EXIT

# ✓ Correct - use cleanup function
trap 'cleanup' EXIT
```

**Edge cases:**
- If cleanup fails, disabled trap prevents recursion - script still exits cleanly
- Trap fires for both error exits and normal exits with `EXIT` signal
- Test handlers with normal exit, `false` command, and Ctrl+C
