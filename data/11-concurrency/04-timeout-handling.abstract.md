### Timeout Handling

**Prevent hangs: wrap commands with `timeout`, check exit 124 for timeout condition.**

Exit codes: 124=timed out, 125=timeout failed, 137=SIGKILL (128+9)

#### Pattern

```bash
if timeout 30 long_command; then
  echo 'Done'
elif (($? == 124)); then
  echo 'Timed out'
fi

# Graceful: TERM first, KILL after 10s
timeout --signal=TERM --kill-after=10 60 cmd
```

#### Built-in Timeouts

- `read -t 10` → input timeout
- `ssh -o ConnectTimeout=10` → connection timeout
- `curl --connect-timeout 10 --max-time 60` → request timeout

#### Anti-Pattern

`ssh "$server" 'cmd'` → hangs forever. Use: `timeout 300 ssh -o ConnectTimeout=10 "$server" 'cmd'`

**See Also:** BCS1105 (Exponential Backoff)

**Ref:** BCS1104
