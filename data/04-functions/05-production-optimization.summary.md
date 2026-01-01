## Production Script Optimization

For mature production scripts:
- Remove unused utility functions (`yn()`, `decp()`, `trim()`, `s()`)
- Remove unused globals (`SCRIPT_DIR`, `PROMPT`, `DEBUG`)
- Remove unused messaging functions
- Keep only what's actually needed

**Rationale:** Reduces size, improves clarity, eliminates maintenance burden.

**Example:** Simple scripts may only need `error()` and `die()`, not the full messaging suite.
