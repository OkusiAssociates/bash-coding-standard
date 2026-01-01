# Functions

Function definition patterns, naming (lowercase_with_underscores), and organization. Mandates `main()` for scripts >200 lines for structure/testability. Use `declare -fx` for sourceable library exports. Remove unused utilities in production. Organize bottom-up: messaging â†' helpers â†' business logic â†' `main()` (ensures safe call ordering and reader comprehension).
