### Layout Anti-Patterns

**Eight critical BCS0101 violations with corrections.**

---

**1. Missing strict mode** â†' silent failures
```bash
# âœ— set -euo pipefail missing
# âœ“ Add immediately after shebang
```

**2. Variables after use** â†' "unbound variable" with `set -u`
```bash
# âœ— main() uses VERBOSE before declaration
# âœ“ Declare all globals before functions
```

**3. Utilities after business logic** â†' harder to trace dependencies
```bash
# âœ— process_files() calls die() defined below
# âœ“ Define utilities first, business logic after
```

**4. No main() in large scripts** â†' no clear entry point, untestable
```bash
# âœ— Logic runs directly after functions
# âœ“ Use main() for scripts >40 lines
```

**5. Missing `#fin`** â†' can't detect truncated files

**6. Readonly before parsing** â†' can't modify via `--prefix`
```bash
# âœ— readonly -- PREFIX before arg parsing
# âœ“ readonly -- PREFIX after parsing complete
```

**7. Scattered declarations** â†' hard to see all state
```bash
# âœ— Globals interspersed with functions
# âœ“ All globals grouped together
```

**8. Unprotected sourcing** â†' runs main when sourced
```bash
# âœ“ Dual-purpose pattern:
[[ "${BASH_SOURCE[0]}" == "$0" ]] || return 0
set -euo pipefail  # Only when executed
```

**Ref:** BCS010102
