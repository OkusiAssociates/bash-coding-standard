## File Extensions

**Executables: `.sh` or no extension; libraries: `.sh` only (non-executable); PATH-available commands: no extension.**

### Quick Rules
- Executable scripts â†' `.sh` or extensionless
- Libraries (sourced) â†' `.sh`, chmod 644
- Global commands (in PATH) â†' no extension

### Anti-Pattern
`mylib` (no extension, executable library) â†' `mylib.sh` (chmod 644)

**Ref:** BCS0106
