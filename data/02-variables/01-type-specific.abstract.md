## Type-Specific Declarations

**Use explicit type declarations (`declare -i/-a/-A/--`) to document intent and enable type checking.**

**Rationale:** Type safety prevents bugs, explicit types document usage, type-specific operations are faster.

**Types:**

```bash
declare -i count=0              # Integer (auto-arithmetic)
declare -- path='/etc/app'      # String (-- prevents option injection)
declare -a files=()             # Indexed array
declare -A config=()            # Associative array (requires -A)
readonly -- VERSION='1.0.0'     # Immutable
local -- temp="$1"              # Function-scoped
```

**Integer auto-evaluation:**
```bash
declare -i num=0
num=num+1          # No $(()) needed
num='5 + 3'        # Evaluates to 8
```

**Combine modifiers:** `local -i count=0`, `readonly -a LIST=(...)`, `local -A map=()`

**Anti-patterns:**
```bash
# ✗ No type
count=0

# ✓ Explicit
declare -i count=0

# ✗ Missing -A
declare CONFIG
CONFIG[key]='val'  # Creates indexed array!

# ✓ Explicit -A
declare -A CONFIG=()

# ✗ Global leak
func() { temp="$1"; }

# ✓ Local
func() { local -- temp="$1"; }

# ✗ No --
declare var='-weird'  # Treated as option!

# ✓ Use --
declare -- var='-weird'
```

**Use:** `-i` (counters/ports), `--` (paths/text), `-a` (lists), `-A` (key-value), `readonly` (constants), `local` (all function vars).

**Ref:** BCS0201
