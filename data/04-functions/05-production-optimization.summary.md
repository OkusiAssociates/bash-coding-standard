## Production Script Optimization

Once a script is mature and ready for production:
- Remove unused utility functions (e.g., `yn()`, `decp()`, `trim()`, `s()`)
- Remove unused global variables (e.g., `SCRIPT_DIR`, `PROMPT`, `DEBUG`)
- Remove unused messaging functions not called by your script
- Keep only the functions and variables your script actually needs

**Rationale:** Reduces script size, improves clarity, eliminates maintenance burden.

**Example:** A simple script may only need `error()` and `die()`, not the full messaging suite.
