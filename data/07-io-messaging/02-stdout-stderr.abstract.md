## STDOUT vs STDERR

**All error messages must go to STDERR with `>&2` at command beginning.**

**Rationale:**
- Separates error output from normal output (enables piping/redirection)
- Leading `>&2` improves readability vs trailing

**Example:**
```bash
# Preferred - redirect at start
error() {
  >&2 echo "[$(date -Ins)]: $*"
}

# Acceptable - redirect at end
warn() {
  echo "Warning: $*" >&2
}
```

**Anti-patterns:**
- `echo "error"` ’ STDOUT (errors invisible when piped)
- Mixing error/normal output on same stream

**Ref:** BCS0902
