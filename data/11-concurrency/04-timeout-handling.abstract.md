### Timeout Handling

**Use `timeout` command to prevent hangs; exit code 124 = timed out.**

#### Rationale
- Prevents indefinite hangs on unresponsive commands
- Avoids resource exhaustion from stuck processes
- Exit 124=timeout, 137=SIGKILL (128+9)

#### Pattern

```bash
if timeout 30 long_command; then
  success 'Completed'
else
  local -i ec=$?
  ((ec == 124)) && warn 'Timed out' || error "Failed: $ec"
fi

# Graceful: SIGTERM then SIGKILL
timeout --signal=TERM --kill-after=10 60 command

# Read with timeout
read -r -t 10 -p 'Value: ' val || val='default'
```

#### Anti-Pattern

`ssh "$server" cmd` â†' `timeout 300 ssh -o ConnectTimeout=10 "$server" cmd`

**Ref:** BCS1104
