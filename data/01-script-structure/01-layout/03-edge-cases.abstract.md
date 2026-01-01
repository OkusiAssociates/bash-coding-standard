### Edge Cases and Variations

**Standard 13-step layout modifications for specific use cases: small scripts, libraries, external config, platform detection, cleanup traps.**

---

## Legitimate Simplifications

- **<200 lines** â†' skip `main()`, run directly
- **Library files** â†' skip `set -e`, `main()`, execution (avoid affecting caller)
- **One-off utilities** â†' may skip colors, verbose messaging

## Legitimate Extensions

- **External config** â†' source between metadata and business logic; `readonly` after sourcing
- **Platform detection** â†' add platform globals after standard globals
- **Cleanup traps** â†' after utility functions, before business logic
- **Lock files** â†' acquisition/release around main execution

## Core Example â€” Library Pattern

```bash
#!/usr/bin/env bash
# Library - meant to be sourced, not executed
# No set -e (affects caller), no readonly (caller may modify)

is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
# No main(), no execution
#fin
```

## Anti-Pattern

```bash
# âœ— Functions before set -e
validate() { : ... }
set -euo pipefail  # Too late!
VERSION=1.0.0
check() { : ... }
declare -- PREFIX=/usr  # Globals scattered
```

## Invariant Principles

Even when deviating:
1. **Safety first** â€” `set -euo pipefail` still comes first (unless library)
2. **Dependencies before usage** â€” bottom-up organization applies
3. **Document reasons** â€” comment why deviating

**Ref:** BCS010103
