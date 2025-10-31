# Variable Declarations & Constants

**Use explicit type declarations (`declare -i`, `declare --`, `declare -a`, `declare -A`) for clarity and safety.** Apply proper scoping (global vs local), naming conventions (UPPER_CASE for constants/environment, lower_case for variables), readonly patterns (individual or group), boolean flags as integers, and derived variables computed from other variables.

**Rationale:** Type hints prevent errors, explicit declarations make intent clear, proper scoping avoids conflicts.

**Example:**
```bash
declare -i count=0                    # Integer
declare -- name="example"             # String
declare -a files=()                   # Indexed array
declare -A config=([key]="value")     # Associative array
readonly VERSION='1.0.0' AUTHOR='name'
```

**Anti-patterns:** Untyped variables `count=0`, missing `readonly` for constants, using strings for booleans.

**Ref:** BCS02
