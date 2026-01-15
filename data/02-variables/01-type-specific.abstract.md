## Type-Specific Declarations

**Use explicit type declarations (`declare -i/-a/-A`, `declare --`, `local --`) to enforce type safety and document intent.**

**Rationale:** Integer declarations catch non-numeric assignments (become 0). Array declarations prevent scalar overwrites. `--` separator prevents option injection.

**Declaration types:**
- `-i` integers: counters, ports, exit codes â†' auto-arithmetic, type-checked
- `--` strings: paths, text, config â†' default for text data
- `-a` indexed arrays: lists, args â†' safe word-splitting
- `-A` associative arrays: key-value maps â†' fast lookups (Bash 4.0+)
- `-r` readonly: constants â†' immutable after init
- `local` in functions: ALL function variables â†' prevents global pollution

```bash
declare -i count=0 port=8080
declare -- filename=data.txt
declare -a files=()
declare -A config=([key]=value)
declare -r VERSION=1.0.0

process() {
  local -- input=$1
  local -i attempts=0
  local -a items=()
}
```

**Anti-patterns:**
```bash
count=0              # â†' declare -i count=0
files=file.txt       # â†' files=(file.txt) or files+=(file.txt)
local name=$1        # â†' local -- name=$1 (prevents -n injection)
declare CONFIG       # â†' declare -A CONFIG=() (for assoc array)
```

**Ref:** BCS0201
