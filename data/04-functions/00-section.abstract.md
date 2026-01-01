# Functions

**Function definition patterns, naming (`lowercase_with_underscores`), organization, export (`declare -fx`), and production optimization.**

## Core Requirements

- `main()` required for scripts >200 lines â†' improves testability
- Bottom-up organization: messaging â†' helpers â†' business logic â†' `main()`
- Remove unused utility functions in production scripts

## Export Pattern

```bash
my_lib_func() { :; }
declare -fx my_lib_func
```

## Anti-patterns

- `main()` missing in large scripts â†' poor structure, untestable
- Top-down organization â†' forward reference issues

**Ref:** BCS0400
