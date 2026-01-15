## Progressive State Management

**Manage script state via boolean flags modified by runtime conditions; separate decision logic from execution.**

### Pattern Structure
1. Declare flags with defaults â†' 2. Parse args â†' 3. Adjust by conditions â†' 4. Execute on final state

### Example
```bash
declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0

# Parse args: --builtin sets both flags, --no-builtin sets SKIP
# Runtime adjustments:
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0 ||:
check_builtin_support || { ((BUILTIN_REQUESTED)) && install_bash_builtins || INSTALL_BUILTIN=0; }
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0
# Execute on final state
((INSTALL_BUILTIN)) && install_builtin
```

### Key Benefits
- Separation of decision/action logic; easy state tracing
- Fail-safe: disable features when prerequisites fail
- User intent preserved (`*_REQUESTED` vs runtime state)

### Anti-patterns
- Modifying flags during execution phase â†' only in setup/validation
- Single flag for both intent and state â†' use separate flags

### Guidelines
- Group related flags (`INSTALL_*`, `SKIP_*`); document transitions
- State changes in order: parse â†' validate â†' execute

**Ref:** BCS1210
