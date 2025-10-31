## STDOUT vs STDERR

**Rule**: All error messages must go to STDERR. Place `>&2` at the beginning of commands for clarity.

```bash
# Preferred format
somefunc() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Also acceptable
somefunc() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}
```

**Rationale**: Beginning placement improves readability by immediately signaling the redirection intent.
