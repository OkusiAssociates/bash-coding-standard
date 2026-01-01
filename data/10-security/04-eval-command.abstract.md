## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely—safer alternatives exist for all use cases.**

### Why It Matters
- Code injection: arbitrary command execution with full script privileges
- Bypasses all validation via metacharacters; impossible to audit
- Double expansion enables attacks: `eval "echo $var"` executes `$(whoami)` in `var`

### Safe Alternatives

| Need | Use Instead |
|------|-------------|
| Dynamic commands | Arrays: `cmd=(find -name "*.txt"); "${cmd[@]}"` |
| Variable indirection | `${!var_name}` or `printf -v "$var" '%s' "$val"` |
| Dynamic data | Associative arrays: `declare -A data; data[$key]=$val` |
| Function dispatch | Case or array lookup: `"${actions[$action]}"` |

### Core Pattern
```bash
# ✗ NEVER - eval with user input
eval "$user_cmd"

# ✓ Safe - array-based command construction
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"

# ✓ Safe - indirect expansion for variable access
echo "${!var_name}"
```

### Anti-Patterns
- `eval "$var_name='$value'"` �' use `printf -v "$var_name" '%s' "$value"`
- `eval "echo $$var_name"` �' use `echo "${!var_name}"`

**Ref:** BCS1004
