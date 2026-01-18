# Variable Declarations & Constants

**Explicit `declare` with type hints ensures predictable behavior and prevents common shell errors.**

## Core Rules

- **Types**: `declare -i` (int), `declare --` (string), `declare -a` (array), `declare -A` (assoc)
- **Naming**: `UPPER_CASE` constants, `lower_case` variables
- **Scope**: `local` in functions; globals at script top only
- **Constants**: `declare -r` or `readonly` for immutables

## Rationale

1. Type declarations catch arithmetic errors at assignment vs runtime
2. Explicit scoping prevents accidental global state pollution
3. Readonly prevents silent overwrites of critical values

## Example

```bash
declare -r VERSION="1.0.0"
declare -i count=0
declare -- name="value"

func() {
    local -i result=0
    ((result = count + 1))
}
```

## Anti-patterns

- `count=0` → `declare -i count=0` (untyped allows string assignment)
- Global vars inside functions → use `local`

**Ref:** BCS0200
