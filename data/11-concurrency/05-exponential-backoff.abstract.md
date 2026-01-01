### Exponential Backoff

**Implement retry logic with exponential delay (`2^attempt`) for transient failures; add jitter to prevent thundering herd.**

#### Rationale
- Reduces load on failing services vs fixed-delay retry
- Automatic recovery without manual intervention

#### Pattern

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5} attempt=1
  shift
  while ((attempt <= max_attempts)); do
    "$@" && return 0
    sleep $((2 ** attempt))
    attempt+=1
  done
  return 1
}
```

**With jitter:** `delay=$((base_delay + RANDOM % base_delay))`

**With cap:** `((delay > max_delay)) && delay=$max_delay`

#### Anti-Patterns

```bash
# âœ— Fixed delay â†' same load pressure
while ! cmd; do sleep 5; done

# âœ“ Exponential backoff
retry_with_backoff 5 curl -f "$url"
```

`while ! curl "$url"; do :; done` â†' Immediate retry floods service

**Ref:** BCS1105
