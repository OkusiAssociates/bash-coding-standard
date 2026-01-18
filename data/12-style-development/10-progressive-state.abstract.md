## Progressive State Management

**Manage script state via boolean flags modified by runtime conditions; separate decision logic from execution.**

**Structure:** 1) Declare flags with defaults → 2) Parse args → 3) Adjust by runtime conditions → 4) Execute on final state

```bash
declare -i INSTALL_BUILTIN=0 BUILTIN_REQUESTED=0 SKIP_BUILTIN=0

# Parse: set flags from user input
[[ $1 == --builtin ]] && { INSTALL_BUILTIN=1; BUILTIN_REQUESTED=1; }

# Validate: adjust based on conditions
((SKIP_BUILTIN)) && INSTALL_BUILTIN=0
check_builtin_support || INSTALL_BUILTIN=0

# Execute: act on final state only
((INSTALL_BUILTIN)) && install_builtin
```

**Key principles:**
- Separate user intent flag (`REQUESTED`) from runtime state (`INSTALL`)
- Never modify flags during execution phase
- State changes in logical order: parse → validate → execute

**Anti-patterns:**
- Mixing state decisions with execution → unmaintainable control flow
- Single flag for both intent and state → loses "why" information

**Ref:** BCS1210
