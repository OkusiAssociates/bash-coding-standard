# Functions

**Use `lowercase_with_underscores` naming; organize bottom-up (utilities→helpers→logic→`main`); scripts >200 lines require `main()` function.**

## Organization

1. Messaging functions first
2. Helper utilities
3. Business logic
4. `main()` last (calls previously defined functions)

## Key Patterns

- Export for libraries: `declare -fx function_name`
- Remove unused utility functions in production scripts

## Minimal Example

```bash
log_info() { printf '[INFO] %s\n' "$1"; }
validate_input() { [[ -n "$1" ]] || return 1; }
process_data() { validate_input "$1" && log_info "Processing: $1"; }
main() { process_data "$@"; }
main "$@"
```

## Anti-patterns

- `camelCase` or `PascalCase` naming → use `snake_case`
- Defining `main()` before helper functions → bottom-up order

**Ref:** BCS0400
