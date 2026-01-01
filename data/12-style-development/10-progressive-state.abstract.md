## Progressive State Management

**Manage state via boolean flags modified by runtime conditions; separate decisions from execution.**

### Pattern

1. Declare flags at top with defaults
2. Parse args â†' set flags from user input
3. Progressively adjust based on: dependencies, failures, overrides
4. Execute actions from final flag state

```bash
declare -i INSTALL_FEAT=0 FEAT_REQUESTED=0 SKIP_FEAT=0

# Parse phase
case $1 in --feat) INSTALL_FEAT=1; FEAT_REQUESTED=1 ;; esac

# Validation phase - progressively disable
((SKIP_FEAT)) && INSTALL_FEAT=0
check_deps || { ((FEAT_REQUESTED)) && try_install || INSTALL_FEAT=0; }
((INSTALL_FEAT)) && ! build_feat && INSTALL_FEAT=0

# Execution phase - act on final state
((INSTALL_FEAT)) && install_feat
```

### Key Points

- Separate intent flag (`FEAT_REQUESTED`) from state flag (`INSTALL_FEAT`)
- Never modify flags during execution phase
- State changes in order: parse â†' validate â†' execute

### Anti-Patterns

- `if ((INSTALL_FEAT)); then install_feat; INSTALL_FEAT=0; fi` â†' modifying flags during execution
- Single flag for both user intent and runtime state â†' loses why vs. what distinction

**Ref:** BCS1210
