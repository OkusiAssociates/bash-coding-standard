## Production Script Optimization
Once mature and production-ready:
- Remove unused utility functions (e.g., `yn()`, `decp()`, `trim()`, `s()`)
- Remove unused global variables (e.g., `PROMPT`, `DEBUG`)
- Remove unused messaging functions
- Keep only what script actually needs
- Reduces size, improves clarity, eliminates maintenance burden

Example: Simple script may only need `error()` and `die()`, not full messaging suite.
