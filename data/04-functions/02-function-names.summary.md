## Function Names
Use lowercase with underscores; prefix private functions with underscore.

```bash
# ✓ Good - lowercase with underscores
my_function() {
  …
}

process_log_file() {
  …
}

# ✓ Private functions use leading underscore
_validate_input() {
  …
}

# ✗ Avoid - CamelCase or UPPER_CASE
MyFunction() {      # Don't do this
  …
}

PROCESS_FILE() {    # Don't do this
  …
}
```

**Rationale:** Matches Unix conventions and built-in commands (all lowercase). Underscore prefix signals internal-use functions.

**Anti-patterns:**
```bash
# ✗ Don't override built-in commands
cd() {           # Dangerous - overrides built-in cd
  builtin cd "$@" && ls
}

# ✓ Wrap built-ins with different name
change_dir() {
  builtin cd "$@" && ls
}

# ✗ Don't use special characters
my-function() {  # Dash creates issues
  …
}
```
