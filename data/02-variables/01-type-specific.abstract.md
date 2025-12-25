## Type-Specific Declarations

**Always use explicit type declarations to make intent clear and enable type-safe operations.**

**Rationale:** Type safety catches errors early; intent documentation aids readability; `--` separator prevents option injection.

### Declaration Types

| Type | Syntax | Use Case |
|------|--------|----------|
| Integer | `declare -i` | Counters, ports, flags |
| String | `declare --` | Paths, text, config |
| Indexed array | `declare -a` | Lists, sequences |
| Associative | `declare -A` | Key-value maps |
| Constant | `readonly --` | Immutable values |
| Function-local | `local --` | ALL function variables |

### Example

```bash
declare -i count=0 MAX=10
declare -- filename='data.txt'
declare -a files=()
declare -A config=([port]='8080')
readonly -- VERSION='1.0.0'

process() {
  local -- input="$1"
  local -i attempts=0
  ((attempts < MAX)) && files+=("$input")
}
```

### Anti-Patterns

```bash
# ✗ No type (intent unclear) �' ✓ declare -i count=0
count=0

# ✗ Missing -- separator �' ✓ declare -- name='-val'
declare name='-val'

# ✗ Missing -A (creates indexed!) �' ✓ declare -A cfg=()
declare cfg; cfg[key]='val'

# ✗ Global leak in function �' ✓ local -- temp="$1"
func() { temp="$1"; }
```

**Ref:** BCS0201
