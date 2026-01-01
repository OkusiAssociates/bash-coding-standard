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
_my_private_function() {
  …
}

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

**Rationale:** Matches Unix naming conventions; avoids confusion with variables; underscore prefix signals internal-only use.

**Anti-patterns:**
```bash
# ✗ Don't override built-in commands without good reason
cd() {           # Dangerous - overrides built-in cd
  builtin cd "$@" && ls
}

# ✓ If you must wrap built-ins, use a different name
change_dir() {
  builtin cd "$@" && ls
}

# ✗ Don't use special characters
my-function() {  # Dash creates issues in some contexts
  …
}
```
