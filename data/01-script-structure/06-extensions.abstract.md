## File Extensions

**Executables use `.sh` or no extension; libraries require `.sh` and must not be executable; PATH-accessible commands use no extension.**

**Rationale:** Extension-free executables in PATH appear as native commands (`deploy` vs `deploy.sh`). Libraries need `.sh` for immediate identification as sourceable code, preventing accidental execution.

**Example:**
```bash
# ✓ PATH executable (no extension)
/usr/local/bin/backup

# ✓ Library (not executable)
-rw-r--r-- lib-auth.sh

# ✗ Library without extension
lib-auth

# ✗ PATH executable with extension
/usr/local/bin/backup.sh
```

**Anti-patterns:**
- Libraries without `.sh` extension ’ ambiguous purpose
- PATH executables with `.sh` ’ unprofessional appearance

**Ref:** BCS0106
