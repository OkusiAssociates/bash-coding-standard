## Type-Specific Declarations

**Always use explicit type declarations (`declare -i`, `-a`, `-A`, `--`) for type safety, intent clarity, and bash's built-in type checking.**

**Rationale:** Type safety catches errors early; explicit types document intent; arrays prevent scalar assignment bugs.

**Declaration types:**
- `declare -i` — integers (counters, ports, exit codes)
- `declare --` — strings (paths, text); `--` prevents option injection
- `declare -a` — indexed arrays (lists)
- `declare -A` — associative arrays (key-value maps)
- `declare -r` — read-only constants
- `local --`/`local -i`/`local -a` — function-scoped variables

**Example:**
```bash
declare -i count=0 max_retries=3
declare -- config_path=/etc/app.conf
declare -a files=()
declare -A CONFIG=([timeout]='30' [retries]='3')

process() {
  local -- input=$1
  local -i attempts=0
  while ((attempts < max_retries)); do attempts+=1; done
}
```

**Anti-patterns:**
- `count=0` → `declare -i count=0` (unclear intent)
- `declare CONFIG` then `CONFIG[key]=val` → `declare -A CONFIG` (creates indexed, not associative)
- `local filename=$1` → `local -- filename=$1` (option injection risk if $1 is "-n")

**Ref:** BCS0201
