### Exponential Backoff

**Rule: BCS1105** — Implement retry logic with exponential delay for transient failures.

#### Rationale
- Reduces load on failing services (prevents thundering herd)
- Enables automatic recovery without manual intervention

#### Pattern

```bash
retry_with_backoff() {
  local -i max=5 attempt=1 delay
  while ((attempt <= max)); do
    "$@" && return 0
    delay=$((2 ** attempt))
    sleep "$delay"
    attempt+=1
  done
  return 1
}
```

**Jitter:** Add `jitter=$((RANDOM % delay))` to prevent synchronized retries.

**Cap:** Use `((delay > 60)) && delay=60 ||:` to limit maximum delay.

#### Anti-Patterns

`while ! cmd; do sleep 5; done` → Fixed delay doesn't reduce pressure

`while ! curl "$url"; do :; done` → Immediate retry floods service

**See Also:** BCS1104 (Timeout), BCS1101 (Background Jobs)

**Ref:** BCS1105
