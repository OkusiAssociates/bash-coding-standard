### Timeout Handling

**Rule: BCS1409**

Managing command timeouts and handling timeout conditions gracefully.

---

#### Rationale

Timeout handling prevents scripts hanging on unresponsive commands, resource exhaustion from stuck processes, poor user experience, and cascading failures in automated systems.

---

#### Basic Timeout

```bash
# Simple timeout (coreutils)
if timeout 30 long_running_command; then
  success 'Command completed'
else
  exit_code=$?
  if ((exit_code == 124)); then
    warn 'Command timed out'
  else
    error "Command failed with exit code $exit_code"
  fi
fi
```

#### Timeout with Signal Selection

```bash
# Send SIGTERM first, SIGKILL after grace period
timeout --signal=TERM --kill-after=10 60 command

# Exit codes: 124=timed out, 125=timeout failed, 126=not executable, 127=not found, 137=SIGKILL
```

#### Timeout with Variable Duration

```bash
declare -i TIMEOUT=${TIMEOUT:-30}

run_with_timeout() {
  local -i timeout_sec=$1; shift

  if ! timeout "${timeout_sec}s" "$@"; then
    local -i exit_code=$?
    case $exit_code in
      124) warn "Timed out after ${timeout_sec}s" ;;
      125) error 'Timeout command failed' ;;
      *)   error "Failed with exit code $exit_code" ;;
    esac
    return "$exit_code"
  fi
}

run_with_timeout "$TIMEOUT" ssh "$server" "$command"
```

#### Read with Timeout

```bash
if read -r -t 10 -p 'Enter value: ' value; then
  info "Got: $value"
else
  warn 'Input timed out, using default'
  value='default'
fi
```

#### Connection Timeout Pattern

```bash
ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$command"
curl --connect-timeout 10 --max-time 60 "$url"
```

---

#### Anti-Pattern

```bash
# ✗ Wrong - no timeout on network operations
ssh "$server" 'long_command'  # May hang forever

# ✓ Correct - always timeout network operations
timeout 300 ssh -o ConnectTimeout=10 "$server" 'long_command'
```

---

**See Also:** BCS1410 (Exponential Backoff)
