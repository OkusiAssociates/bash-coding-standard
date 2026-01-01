## Function Names

**Use lowercase_with_underscores; prefix private functions with `_`.**

### Core Pattern

```bash
process_log_file() { … }     # ✓ Public
_validate_input() { … }      # ✓ Private (internal)
```

### Why

- Matches Unix conventions (`grep`, `sed`)
- Avoids conflicts with built-ins (all lowercase)
- `_prefix` signals internal-only use

### Anti-Patterns

```bash
MyFunction() { … }           # ✗ CamelCase
PROCESS_FILE() { … }         # ✗ UPPER_CASE
my-function() { … }          # ✗ Dashes cause issues
cd() { builtin cd "$@"; }    # ✗ Overriding built-in
```

�' Wrap built-ins with different name: `change_dir()` not `cd()`

**Ref:** BCS0402
