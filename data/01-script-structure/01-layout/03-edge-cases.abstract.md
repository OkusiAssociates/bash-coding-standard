### Edge Cases and Variations

**Special scenarios where BCS0101's 13-step layout is modified for specific use cases.**

#### Small Scripts (<200 lines)
Skip `main()` and run directly. **Rationale:** Overhead unjustified for trivial scripts.

```bash
#!/usr/bin/env bash
set -euo pipefail
declare -i count=0
for file in "$@"; do
  [[ ! -f "$file" ]] || count+=1
done
echo "Found $count files"
#fin
```

#### Sourced Libraries
Skip `set -e`, `main()`, execution—no environment modification. Export functions only.

```bash
#!/usr/bin/env bash
is_integer() { [[ "$1" =~ ^-?[0-9]+$ ]]; }
#fin
```

#### External Configuration
Source config after metadata, **then** make variables readonly.

```bash
declare -- CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/myapp/config.sh"
[[ -r "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
readonly -- CONFIG_FILE
```

#### Platform Detection
Add platform-specific globals after standard globals using case statements.

#### Cleanup Traps
Set trap **after** cleanup function defined, **before** temp file creation.

```bash
cleanup() { rm -f "${TEMP_FILES[@]}"; }
trap 'cleanup' EXIT SIGINT SIGTERM
```

**Anti-patterns:**
- `→` Functions before `set -e` (unsafe)
- `→` Globals scattered arbitrarily
- `→` Deviation without documented reason

**Key principles when deviating:**
1. Safety first (`set -e` comes first unless library)
2. Dependencies before usage (bottom-up)
3. Deviate only when necessary

**Ref:** BCS010103
