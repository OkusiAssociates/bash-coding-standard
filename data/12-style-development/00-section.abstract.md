# Style & Development

**Consistent formatting and documentation for maintainable scripts.**

## Rules (10)

| ID | Rule | Core Requirement |
|----|------|------------------|
| BCS1201 | Code Formatting | 4-space indent, 80-char lines, structured blocks |
| BCS1202 | Comments | `#` with space, explain why not what |
| BCS1203 | Blank Lines | Single between logical blocks, two before functions |
| BCS1204 | Section Markers | `#--- SECTION ---#` delimiters for major sections |
| BCS1205 | Language Practices | Use `[[`, `(())`, prefer builtins over externals |
| BCS1206 | Development Practices | Version control, incremental testing, shellcheck |
| BCS1207 | Debugging | `DEBUG` flag gates trace output |
| BCS1208 | Dry-Run Mode | `DRY_RUN` prevents destructive ops, shows intent |
| BCS1209 | Testing | Assertions, edge cases, exit code verification |
| BCS1210 | Progressive State | Track multi-stage operations with state variables |

## Essential Pattern

```bash
#--- CONFIGURATION ---#
readonly DEBUG="${DEBUG:-false}"
readonly DRY_RUN="${DRY_RUN:-false}"

#--- MAIN ---#
main() {
    [[ "$DEBUG" == "true" ]] && set -x
    [[ "$DRY_RUN" == "true" ]] && echo "[DRY-RUN] Would execute"
}
```

## Anti-patterns

- `#no space` → `# with space`
- Mixing tabs/spaces → consistent 4-space indent
- No section markers in 100+ line scripts

**Ref:** BCS1200
