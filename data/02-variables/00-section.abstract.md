# Variable Declarations & Constants

**Explicit declaration with type hints ensures predictable behavior and prevents common errors.**

## Core Rules

- **Type declarations**: `declare -i` (integer), `declare --` (string), `declare -a` (array), `declare -A` (hash)
- **Naming**: `UPPER_CASE` constants, `lower_case` variables
- **Scope**: `local` for function variables, global at script level
- **Constants**: `readonly` or grouped `readonly VAR1 VAR2`
- **Booleans**: Use integers (`flag=1`/`flag=0`) not strings

## Example

```bash
declare -i count=0
declare -- name="value"
readonly VERSION="1.0"
local -i result
```

## Anti-patterns

- `count=0` â†' `declare -i count=0` (type safety)
- `flag="true"` â†' `flag=1` (boolean as integer)

**Ref:** BCS0200
