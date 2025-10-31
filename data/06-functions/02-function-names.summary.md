## Function Names
Use lowercase with underscores to match shell conventions and avoid conflicts with built-in commands.

```bash
#  Good - lowercase with underscores
my_function() {
  &
}

process_log_file() {
  &
}

#  Private functions use leading underscore
_my_private_function() {
  &
}

_validate_input() {
  &
}

#  Avoid - CamelCase or UPPER_CASE
MyFunction() {      # Don't do this
  &
}

PROCESS_FILE() {    # Don't do this
  &
}
```

**Rationale:**
- Lowercase with underscores matches standard Unix/Linux utility naming
- Avoid CamelCase (can confuse with variables/commands)
- Underscore prefix signals private/internal use
- All built-in bash commands are lowercase

**Anti-patterns:**
```bash
#  Don't override built-in commands without good reason
cd() {           # Dangerous - overrides built-in cd
  builtin cd "$@" && ls
}

#  If wrapping built-ins, use different name
change_dir() {
  builtin cd "$@" && ls
}

#  Don't use special characters
my-function() {  # Dash creates issues
  &
}
```
