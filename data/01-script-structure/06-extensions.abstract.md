## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` required; global PATH tools: no extension.**

**Rationale:** No-extension executables appear as commands (`deploy` not `deploy.sh`). Libraries need `.sh` for identification and must be non-executable to prevent accidental execution.

**Example:**
```bash
# Executable (global)
/usr/local/bin/backup          # No extension

# Executable (local)
./scripts/build.sh             # .sh extension

# Library (non-executable)
lib-common.sh                  # .sh extension, chmod 644
```

**Anti-patterns:** `chmod +x lib-*.sh` ' libraries must not be executable | `/usr/bin/tool.sh` ' omit extension for PATH executables.

**Ref:** BCS0106
