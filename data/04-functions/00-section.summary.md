# Functions

Function definition patterns, naming (lowercase_with_underscores), and organization. Scripts >200 lines require `main()` for structure/testability. Use `declare -fx` for exported functions in sourceable libraries. Remove unused utility functions in production.

**Organization (bottom-up):** messaging functions → helpers → business logic → `main()` last. Each function can safely call previously defined functions; readers understand primitives before composition.
