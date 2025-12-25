### Exponential Backoff

**Use exponential delay (`2^attempt`) for transient failure retries; add jitter to prevent thundering herd.**

#### Rationale
- Reduces load on failing services vs fixed delays
- Auto-recovery without manual intervention
- Jitter prevents synchronized retry storms

#### Pattern

```bash
retry_with_backoff() {
  local -i max=5 attempt=1
  while ((attempt <= max)); do
    "$@" && return 0
    sleep $((2 ** attempt))
    ((attempt+=1))
  done
  return 1
}
```

Add jitter: `delay=$((base + RANDOM % base))`

Cap maximum: `((delay > 60)) && delay=60`

#### Anti-Patterns

`while ! cmd; do sleep 5; done` â†' Fixed delay wastes time or floods service

`while ! curl "$url"; do :; done` â†' Immediate retry floods failing service

**Ref:** BCS1410
