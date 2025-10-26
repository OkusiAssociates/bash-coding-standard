## Checking Return Values

**Always check return values of commands and functions; `set -e` alone is insufficient for pipelines, command substitution, and conditionals.**

**Rationale:** `set -e` doesn't catch: pipeline failures (except last), commands in conditionals, command substitution in assignments, or commands with `||`. Explicit checks provide contextual error messages and controlled recovery.

**Patterns:**

```bash
# Explicit if check (informative)
if ! mv "$source" "$dest/"; then
  error "Failed to move $source to $dest"
  exit 1
fi

# || with die (concise)
mv "$source" "$dest/" || die 1 "Failed to move $source"

# || with cleanup
mv "$temp" "$final" || {
  error "Move failed: $temp ’ $final"
  rm -f "$temp"
  exit 1
}

# Capture return code
command_that_might_fail
if (($? != 0)); then
  error "Command failed with exit code $?"
  return 1
fi

# Pipelines: use pipefail
set -o pipefail
cat file | grep pattern  # Exits if cat fails

# Command substitution
output=$(cmd) || die 1 "cmd failed"

# With inherit_errexit
shopt -s inherit_errexit
output=$(failing_cmd)  # Exits with set -e
```

**Anti-patterns:**

```bash
#  Ignoring return
mv "$file" "$dest"  # No check!

#  Checking $? too late
command1
command2
if (($? != 0)); then  # Checks command2!

#  Generic error
mv "$file" "$dest" || die 1 "Move failed"

#  Specific context
mv "$file" "$dest" || die 1 "Failed to move $file to $dest"
```

**Ref:** BCS0804
