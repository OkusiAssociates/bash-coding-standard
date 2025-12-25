## Progressive State Management

**Modify boolean flags based on runtime conditions, separating decision logic from execution.**

**Pattern:**
1. Declare flags with initial values (`declare -i INSTALL_BUILTIN=0`)
2. Parse arguments, set flags from user input
3. Adjust flags: dependency checks → build failures → user overrides
4. Execute based on final flag state

**Example:**
```bash
# Initial state
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0

# Parse: user requested --builtin
INSTALL_BUILTIN=1
BUILTIN_REQUESTED=1

# Validate: check prerequisites
if ! check_builtin_support; then
  ((BUILTIN_REQUESTED)) && install_bash_builtins || INSTALL_BUILTIN=0
fi

# Build: disable on failure
((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0

# Execute: only if still enabled
((INSTALL_BUILTIN)) && install_builtin
```

**Benefits:** Decision/action separation, traceable flag changes, fail-safe behavior, preserves user intent.

**Guidelines:**
- Separate flags for user intent (`*_REQUESTED`) vs. runtime state (`INSTALL_*`)
- Apply state changes in order: parse → validate → execute
- Never modify flags during execution phase
- Document state transitions

**Anti-patterns:**
- `[[ "$FLAG" == "yes" ]]` → Use `((FLAG))` for booleans
- Changing flags inside action functions → Disable before actions
- Single flag for request and state → Separate concerns

**Ref:** BCS1410
