### Exponential Backoff

**Use exponential delay (`2^attempt`) for retry logic to handle transient failures without overwhelming services.**

#### Rationale
- Prevents thundering herd on failing services
- Enables automatic recovery from transient errors
- Configurable max attempts and delay caps

#### Pattern

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5} attempt=1
  shift
  while ((attempt <= max_attempts)); do
    "$@" && return 0
    sleep $((2 ** attempt))
    ((++attempt))
  done
  return 1
}
```

**Enhancements:** Add `max_delay` cap; add jitter (`RANDOM % base_delay`) to prevent synchronized retries.

#### Anti-Patterns

`sleep 5` in loop â†' `sleep $((2 ** attempt))` (fixed delay floods service)

`while ! cmd; do :; done` â†' `retry_with_backoff 5 cmd` (immediate retry = DoS)

**Ref:** BCS1105
