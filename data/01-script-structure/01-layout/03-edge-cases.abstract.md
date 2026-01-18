### Edge Cases and Variations

**Standard 13-step layout may be modified for: tiny scripts (<200 lines), sourced libraries, external config, platform detection, cleanup traps.**

#### When to Simplify
- **<200 lines**: Skip `main()`, run directly
- **Libraries**: Skip `set -e` (affects caller), skip `main()`, no execution block
- **One-off utilities**: May skip color/verbose features

#### When to Extend
- **External config**: Source between metadata and logic; make readonly *after* sourcing
- **Platform detection**: Add platform-specific globals after standard globals
- **Cleanup traps**: Set trap after cleanup function, before temp file creation

#### Core Example (Library)
```bash
#!/usr/bin/env bash
# Library - meant to be sourced, not executed
# No set -e (affects caller), no main()

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
#fin
```

#### Anti-Patterns
- `set -euo pipefail` after functions → error handling fails
- Globals scattered between functions → unpredictable state
- Arbitrary reordering without documented reason

#### Key Principles (Even When Deviating)
1. Safety first (`set -euo pipefail` unless library)
2. Dependencies before usage
3. Document *why* deviating

**Ref:** BCS010103
