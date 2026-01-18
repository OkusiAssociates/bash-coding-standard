## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` (non-executable); PATH commands: no extension.**

### Rationale
- No extension for PATH commands prevents implementation leakage (`myutil` not `myutil.sh`)
- `.sh` on libraries signals they're meant for sourcing, not direct execution

### Pattern
```bash
# Executable script (local use)
myscript.sh

# Library (source only, chmod 644)
lib_utils.sh

# PATH command (no extension)
/usr/local/bin/myutil
```

### Anti-patterns
- `myutil.sh` in PATH → exposes implementation detail
- Executable library → `source lib.sh` should be only invocation method

**Ref:** BCS0106
