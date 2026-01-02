### Timeout Handling

**Rule: BCS1104**

Managing command timeouts and handling timeout conditions gracefully.

---

#### Rationale

Timeout handling prevents:
- Scripts hanging on unresponsive commands
- Resource exhaustion from stuck processes
- Poor user experience with indefinite waits
- Cascading failures in automated systems

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

# Common timeout exit codes:
# 124 - command timed out
# 125 - timeout command itself failed
# 126 - command found but not executable
# 127 - command not found
# 137 - killed by SIGKILL (128 + 9)
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
# User input with timeout
if read -r -t 10 -p 'Enter value: ' value; then
  info "Got: $value"
else
  warn 'Input timed out, using default'
  value='default'
fi
```

#### Connection Timeout Pattern

```bash
# SSH with connection timeout
ssh -o ConnectTimeout=10 -o BatchMode=yes "$server" "$command"

# curl with timeout
curl --connect-timeout 10 --max-time 60 "$url"
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - no timeout on network operations
ssh "$server" 'long_command'  # May hang forever

# ✓ Correct - always timeout network operations
timeout 300 ssh -o ConnectTimeout=10 "$server" 'long_command'
```

---

**See Also:** BCS1105 (Exponential Backoff)

**Full implementation:** See `examples/exemplar-code/oknav/oknav` line 676
