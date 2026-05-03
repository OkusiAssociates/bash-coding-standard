<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.12 Bounded retry with exponential backoff

Retry on transient failure with growing delay.

```bash
retry() {
  local max=$1 delay=1
  shift
  local attempt
  for ((attempt = 1; attempt <= max; attempt++)); do
    if "$@"; then return 0; fi
    if (( attempt < max )); then
      sleep "$delay"
      delay=$((delay * 2))
    fi
  done
  return 1
}
```

- Configurable max retries.
- Exponential delay (1, 2, 4, 8, …).
- Optional jitter to avoid thundering herd.
- Distinguish retryable from non-retryable errors (consider exit-code-based decision).

#fin
