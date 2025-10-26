## Logging Best Practices

**Structured logging for production scripts using consistent format and level filtering.**

```bash
readonly LOG_FILE="${LOG_FILE:-/var/log/${SCRIPT_NAME}.log}"
readonly LOG_LEVEL="${LOG_LEVEL:-INFO}"

log() {
  local -- level="$1" message="${*:2}"
  printf '[%s] [%s] [%-5s] %s\n' "$(date -Ins)" "$SCRIPT_NAME" "$level" "$message" >> "$LOG_FILE"
}
```

**Rationale:** ISO8601 timestamps enable chronological sorting/filtering; structured format (`[timestamp] [script] [level] message`) supports grep/awk analysis; readonly LOG_FILE/LOG_LEVEL prevent runtime modification.

**Anti-patterns:** `echo "error" >> log.txt` (unstructured, no timestamp) ’ use `log ERROR "description"`; hardcoded log paths ’ use `${LOG_FILE:-default}` for environment override.

**Ref:** BCS1407
