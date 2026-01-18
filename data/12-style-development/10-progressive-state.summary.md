## Progressive State Management

Manage script state by modifying boolean flags based on runtime conditions, separating decision logic from execution.

```bash
# Initial flag declarations
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0
declare -i SKIP_BUILTIN=0

main() {
  while (($#)); do
    case $1 in
      --builtin)    INSTALL_BUILTIN=1
                    BUILTIN_REQUESTED=1
                    ;;
      --no-builtin) SKIP_BUILTIN=1
                    ;;
    esac
    shift
  done

  # Progressive state management: adjust flags based on runtime conditions
  ((SKIP_BUILTIN)) && INSTALL_BUILTIN=0 ||:

  if ! check_builtin_support; then
    if ((BUILTIN_REQUESTED)); then
      warn 'bash-builtins package not found, attempting to install...'
      install_bash_builtins || {
        error 'Failed to install bash-builtins package'
        INSTALL_BUILTIN=0
      }
    else
      info 'bash-builtins not found, skipping builtin installation'
      INSTALL_BUILTIN=0
    fi
  fi

  # Build phase: disable on failure
  ((INSTALL_BUILTIN)) && ! build_builtin && INSTALL_BUILTIN=0

  # Execution phase: actions based on final flag state
  install_standalone
  ((INSTALL_BUILTIN)) && install_builtin ||:
  show_completion_message
}
```

**Pattern structure:**
1. Declare boolean flags at top with initial values
2. Parse arguments, set flags based on user input
3. Progressively adjust flags based on runtime conditions (dependency checks, build failures, user overrides)
4. Execute actions based on final flag state

**Benefits:**
- Clean separation between decision logic and action
- Easy to trace flag changes throughout execution
- Fail-safe behavior (disable features when prerequisites fail)
- User intent preserved via separate tracking flag
- Idempotent execution

**Guidelines:**
- Group related flags (`INSTALL_*`, `SKIP_*`)
- Use separate flags for user intent vs. runtime state
- Apply state changes in logical order (parse → validate → execute)
- Never modify flags during execution phase

**Rationale:** Allows scripts to adapt to runtime conditions while maintaining clarity about decisions. Especially useful for installation scripts where features may need disabling based on system capabilities or build failures.
