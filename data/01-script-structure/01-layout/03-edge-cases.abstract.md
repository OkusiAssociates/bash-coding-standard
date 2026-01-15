### Edge Cases and Variations

**Standard 13-step layout may be simplified/extended for specific scenarios.**

#### Skip `main()` (<200 lines)
```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
for file in "$@"; do [[ ! -f "$file" ]] || ((count++)); done
#fin
```

#### Libraries (sourced files)
Skip `set -e` (affects caller), skip `main()`, define functions only.

#### Extensions
- **Config sourcing**: After metadata, before `readonly`
- **Platform detection**: After globals, use `case $(uname -s)`
- **Cleanup traps**: After function defs, before temp file creation: `trap 'cleanup $?' SIGINT SIGTERM EXIT`

#### Key Principles
1. `set -euo pipefail` still first (unless library)
2. Dependencies before usage
3. Document deviations

#### Anti-patterns
`set -e` after functions â†' **Wrong**: safety must come first
Globals scattered between functions â†' **Wrong**: group declarations

**Ref:** BCS010103
