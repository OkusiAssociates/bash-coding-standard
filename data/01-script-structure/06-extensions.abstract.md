## File Extensions

**Use `.sh` for libraries, no extension for PATH executables.**

| Type | Extension | Executable bit |
|------|-----------|----------------|
| Library | `.sh` | No |
| Script (local) | `.sh` or none | Yes |
| Script (PATH) | None | Yes |

`â†'` Adding `.sh` to PATH commands creates awkward invocations (`myscript.sh` vs `myscript`)

**Ref:** BCS0106
