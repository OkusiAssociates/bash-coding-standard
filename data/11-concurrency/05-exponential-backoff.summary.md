### Exponential Backoff

**Rule: BCS1105**

Retry logic with exponential delay for transient failures.

---

#### Rationale

- Graceful transient failure handling with automatic recovery
- Reduced load on failing services; configurable retry behavior

---

#### Basic Exponential Backoff

```bash
retry_with_backoff() {
  local -i max_attempts=${1:-5}
  local -i attempt=1
  shift

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    local -i delay=$((2 ** attempt))
    warn "Attempt $attempt failed, retrying in ${delay}s..."
    sleep "$delay"
    attempt+=1
  done

  error "Failed after $max_attempts attempts"
  return 1
}

retry_with_backoff 5 curl -f "$url"
```

#### With Maximum Delay Cap

```bash
retry_with_backoff() {
  local -i max_attempts=5
  local -i max_delay=60
  local -i attempt=1

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    local -i delay=$((2 ** attempt))
    ((delay > max_delay)) && delay=$max_delay ||:

    ((VERBOSE)) && info "Retry $attempt in ${delay}s..." ||:
    sleep "$delay"
    attempt+=1
  done

  return 1
}
```

#### With Jitter (Randomization)

```bash
# Add randomization to prevent thundering herd
retry_with_jitter() {
  local -i max_attempts=5
  local -i attempt=1

  while ((attempt <= max_attempts)); do
    if "$@"; then
      return 0
    fi

    local -i base_delay=$((2 ** attempt))
    local -i jitter=$((RANDOM % base_delay))
    local -i delay=$((base_delay + jitter))

    sleep "$delay"
    attempt+=1
  done

  return 1
}
```

---

#### Anti-Patterns

```bash
# ✗ Wrong - fixed delay
while ! command; do
  sleep 5  # Same delay every time
done

# ✓ Correct - exponential backoff
declare -i attempt=1
while ! command; do
  sleep $((2 ** attempt))
  attempt+=1
  ((attempt > 5)) && break
done
```

```bash
# ✗ Wrong - immediate retry floods service
while ! curl "$url"; do :; done

# ✓ Correct - backoff prevents flooding
retry_with_backoff 5 curl -f "$url"
```

---

**See Also:** BCS1104 (Timeout Handling), BCS1101 (Background Jobs)
