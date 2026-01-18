## Function Names

**Use lowercase_underscores; prefix private functions with `_`.**

**Rationale:** Matches Unix conventions (`grep`, `sed`); avoids builtin conflicts; `_prefix` signals internal use.

```bash
process_log_file() { …; }     # ✓ Public
_validate_input() { …; }      # ✓ Private
MyFunction() { …; }           # ✗ CamelCase
```

**Anti-patterns:** Don't override builtins (`cd()`) → use `change_dir()`. Avoid dashes (`my-function`) → use underscores.

**Ref:** BCS0402
