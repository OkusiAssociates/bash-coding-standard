## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) to make variable intent clear and enable type-safe operations.**

**Rationale:** Type declarations prevent bugs through automatic type checking, serve as inline documentation, and enable bash's built-in type enforcement.

**Declaration types:**

**1. Integers (`declare -i`)** - Counters, exit codes, ports:
```bash
declare -i count=0
count='5 + 3'  # Evaluates to 8
```

**2. Strings (`declare --`)** - Paths, text (use `--` to prevent option injection):
```bash
declare -- filename='data.txt'
```

**3. Indexed arrays (`declare -a`)** - Ordered lists:
```bash
declare -a files=('one' 'two')
for f in "${files[@]}"; do process "$f"; done
```

**4. Associative arrays (`declare -A`)** - Key-value maps:
```bash
declare -A config=([key]='value')
```

**5. Constants (`readonly --`)** - Immutable after init:
```bash
readonly -- VERSION='1.0.0'
```

**6. Function locals (`local`)** - Always use for ALL function variables:
```bash
func() {
  local -i count=0
  local -- text="$1"
}
```

**Anti-patterns:**
```bash
# ✗ Wrong - no declaration
count=0
# ✓ Correct
declare -i count=0

# ✗ Wrong - missing -A
declare CONFIG; CONFIG[key]='val'  # Creates indexed array!
# ✓ Correct
declare -A CONFIG=(); CONFIG[key]='val'

# ✗ Wrong - global leak
func() { temp="$1"; }
# ✓ Correct
func() { local -- temp="$1"; }
```

**Ref:** BCS0201
