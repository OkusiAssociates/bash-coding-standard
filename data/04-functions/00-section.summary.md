# Functions

Function definition patterns, naming (lowercase_with_underscores), and organization. Use `main()` for scripts >200 lines for structure/testability. Export functions for sourceable libraries with `declare -fx`. Remove unused utility functions in production.

**Organization (bottom-up)**: messaging functions â†' helpers â†' business logic â†' `main()` last. Each function can safely call previously defined functions; readers understand primitives before composition.
