## Type-Specific Declarations

**Use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) for type safety and intent documentation.**

### Declaration Types

| Type | Syntax | Use For |
|------|--------|---------|
| Integer | `declare -i` | Counters, exit codes, ports |
| String | `declare --` | Paths, text, user input |
| Indexed array | `declare -a` | Lists, sequences |
| Associative | `declare -A` | Key-value maps |
| Constant | `readonly --` | Immutable values |
| Local | `local --` | Function-scoped vars |

**Rationale:** Type enforcement catches bugs early; integers auto-evaluate arithmetic; `--` prevents option injection.

### Core Pattern

```bash
declare -i count=0           # Integer
declare -- filename=''       # String (-- prevents option injection)
declare -a files=()          # Indexed array
declare -A config=()         # Associative array
readonly -- VERSION=1.0.0    # Immutable

process() {
  local -- input=$1          # Always use -- with local
  local -i attempts=0
  local -a results=()
}
```

### Anti-Patterns

```bash
# âœ— No type â†' intent unclear
count=0; files=()

# âœ— Missing -- â†' option injection risk
declare filename='-weird'

# âœ— Missing -A â†' creates indexed, not associative
declare CONFIG; CONFIG[key]='value'

# âœ— Global leak in function
process() { temp=$1; }       # â†' local -- temp=$1
```

**Ref:** BCS0201
