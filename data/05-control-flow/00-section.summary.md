# Control Flow

Patterns for conditionals, loops, case statements, and arithmetic. Use `[[ ]]` over `[ ]` for tests, `(())` for arithmetic conditionals. Prefer process substitution (`< <(command)`) over pipes to while loops to avoid subshell variable persistence issues. Safe arithmetic: use `i+=1` instead of `((i+=1))`, or `((i++))` which returns original value and fails with `set -e` when i=0.
