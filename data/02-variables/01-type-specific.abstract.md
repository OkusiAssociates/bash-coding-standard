## Type-Specific Declarations

**Use explicit type declarations (`declare -i`, `declare --`, `-a`, `-A`) for type safety, intent documentation, and error prevention.**

### Declaration Types

| Type | Purpose | Example |
|------|---------|---------|
| `-i` | Integers | `declare -i count=0` |
| `--` | Strings | `declare -- path=/tmp` |
| `-a` | Indexed arrays | `declare -a files=()` |
| `-A` | Associative arrays | `declare -A config=()` |
| `readonly` | Constants | `readonly -- VERSION=1.0` |
| `local` | Function scope | `local -- file=$1` |

### Core Rules

- **Always use `--` separator** with `declare`, `local`, `readonly` â†' prevents option injection
- **Integer vars** auto-evaluate: `count='5+3'` â†' 8
- **Combine modifiers**: `local -i`, `local -a`, `readonly -A`

### Example

```bash
declare -i count=0
declare -- config_path=/etc/app.conf
declare -a files=()
declare -A status=()

process() {
  local -- file=$1
  local -i lines
  lines=$(wc -l < "$file")
}
```

### Anti-Patterns

```bash
# âœ— No type (intent unclear)     â†' âœ“ declare -i count=0
count=0

# âœ— Missing -- separator         â†' âœ“ local -- file=$1
local file=$1

# âœ— Scalar to array              â†' âœ“ files=(file.txt)
files=file.txt
```

**Ref:** BCS0201
