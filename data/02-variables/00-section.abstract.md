# Variable Declarations & Constants

**Explicit declaration with type hints for safety and clarity.**

Core practices: `declare -i` (integers), `declare --` (strings), `declare -a` (arrays), `declare -A` (associative). Scoping: globals at script level, `local --` in functions. Naming: `UPPER_CASE` constants, `lower_case` variables. Use `readonly --` for immutables. Boolean flags as integers (`declare -i FLAG=0`). Derived variables compute from others.

**Ref:** BCS0200
