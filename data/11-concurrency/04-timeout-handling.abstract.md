### Timeout Handling

**Use `timeout` command for all potentially-blocking operations; check exit code 124 for timeout detection.**

#### Key Exit Codes
- **124**: timed out | **125**: timeout failed | **137**: SIGKILL (128+9)

#### Pattern
```bash
declare -i TIMEOUT=${TIMEOUT:-30}
if ! timeout --signal=TERM --kill-after=10 "$TIMEOUT" "$@"; then
  ((($? == 124))) && warn 'Timed out'
fi
```

#### Read Timeout
```bash
read -r -t 10 -p 'Value: ' val || val='default'
```

#### Network Operations
```bash
# Always timeout network ops
timeout 300 ssh -o ConnectTimeout=10 "$server" 'cmd'
curl --connect-timeout 10 --max-time 60 "$url"
```

#### Anti-Pattern
`ssh "$server" 'cmd'` â†' hangs forever; use `timeout` wrapper

**Ref:** BCS1104
