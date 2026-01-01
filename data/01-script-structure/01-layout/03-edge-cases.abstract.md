### Edge Cases and Variations

**Standard 13-step layout allows specific deviations for tiny scripts, libraries, external config, platform detection, and cleanup traps.**

---

## Legitimate Simplifications

**Tiny scripts (<200 lines):** Skip `main()`, run directly after `set -euo pipefail`

**Library files:** Skip `set -e` (affects caller), skip `main()`, skip executionâ€”define functions only:
```bash
#!/usr/bin/env bash
# Library - sourced only
is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
#fin
```

## Legitimate Extensions

**Config sourcing:** Source between metadata and business logic, `readonly` after:
```bash
[[ -r "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
readonly -- CONFIG_FILE
```

**Cleanup traps:** Define cleanup function first, set trap before temp file creation:
```bash
cleanup() { rm -f "${TEMP_FILES[@]}"; }
trap 'cleanup $?' EXIT
```

**Platform detection:** Add platform-specific globals after standard globals

## Key Principles (Even When Deviating)

1. `set -euo pipefail` first (unless library)
2. Bottom-up organization maintained
3. Dependencies before usage
4. Document deviation reasons

**Anti-pattern:** Functions before `set -e` â†' `set -euo pipefail` too late, errors not caught

**Ref:** BCS010103
