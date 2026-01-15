## Progressive State Management

Manage script state by modifying boolean flags based on runtime conditions, separating decision logic from execution.

```bash
# Initial flag declarations
declare -i INSTALL_BUILTIN=0
declare -i BUILTIN_REQUESTED=0
declare -i SKIP_BUILTIN=0

# Parse command-line arguments
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

  # If user explicitly requested to skip, disable installation
  if ((SKIP_BUILTIN)); then
    INSTALL_BUILTIN=0
  fi

  # Check if prerequisites are met, adjust flags accordingly
  if ! check_builtin_support; then
    # If user explicitly requested builtins, try to install dependencies
    if ((BUILTIN_REQUESTED)); then
      warn 'bash-builtins package not found, attempting to install...'
      install_bash_builtins || {
        error 'Failed to install bash-builtins package'
        INSTALL_BUILTIN=0  # Disable builtin installation
      }
    else
      # User didn't explicitly request, just skip
      info 'bash-builtins not found, skipping builtin installation'
      INSTALL_BUILTIN=0
    fi
  fi

  # Build phase: disable on failure
  if ((INSTALL_BUILTIN)); then
    if ! build_builtin; then
      error 'Builtin build failed, disabling builtin installation'
      INSTALL_BUILTIN=0
    fi
  fi

  # Execution phase: actions based on final flag state
  install_standalone
  ((INSTALL_BUILTIN)) && install_builtin ||: # Only runs if still enabled

  show_completion_message
}
```

**Pattern structure:**
1. Declare all boolean flags at top with initial values
2. Parse arguments, setting flags based on user input
3. Progressively adjust flags based on runtime conditions (dependency checks, build failures, user preferences)
4. Execute actions based on final flag state

**Benefits:**
- Clean separation between decision logic and action
- Traceable flag changes throughout execution
- Fail-safe behavior (disable features when prerequisites fail)
- User intent preserved (`BUILTIN_REQUESTED` tracks original request)
- Idempotent (same input â†' same state â†' same output)

**Guidelines:**
- Group related flags (`INSTALL_*`, `SKIP_*`)
- Use separate flags for user intent vs. runtime state
- Document state transitions with comments
- Apply state changes in order: parse â†' validate â†' execute
- Never modify flags during execution phase

**Rationale:** Scripts adapt to runtime conditions while maintaining clarity about decisions. Useful for installation scripts where features may need disabling based on system capabilities or build failures.
