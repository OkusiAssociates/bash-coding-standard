### Timeout Handling

**Use `timeout` command to prevent hanging on unresponsive commands; exit 124 = timeout.**

#### Rationale
- Prevents script hangs and resource exhaustion
- Critical for network operations and automated systems

#### Pattern

```bash
if timeout 30 long_running_command; then
  success 'Completed'
else
  ((exit_code=$?))
  ((exit_code == 124)) && warn 'Timed out' || error "Exit $exit_code"
fi

# Graceful kill: TERM first, KILL after grace period
timeout --signal=TERM --kill-after=10 60 command
```

**Exit codes:** 124=timeout, 125=timeout failed, 137=SIGKILL

#### Built-in Timeouts

```bash
read -r -t 10 -p 'Input: ' val          # read timeout
ssh -o ConnectTimeout=10 "$srv" cmd     # SSH timeout
curl --connect-timeout 10 --max-time 60 "$url"
```

#### Anti-Pattern

`ssh "$srv" cmd` â†' `timeout 300 ssh -o ConnectTimeout=10 "$srv" cmd`

**Ref:** BCS1104
