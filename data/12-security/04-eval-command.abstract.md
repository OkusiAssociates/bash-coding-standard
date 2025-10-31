## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely—safer alternatives exist for all use cases.**

**Rationale:**
- **Code injection** - Executes arbitrary commands with full script privileges
- **Double expansion** - Expands twice, enabling command substitution attacks
- **Bypasses validation** - Sanitized input still vulnerable to metacharacters

**Core danger:**
```bash
user_input="$1"
eval "$user_input"  # ✗ Executes: rm -rf / or worse
```

**Safe alternatives:**

```bash
# ✗ eval for command building
eval "find /data -name '$pattern'"

# ✓ Use arrays
cmd=(find /data -name "$pattern")
"${cmd[@]}"

# ✗ eval for indirection → ✓ Use ${!var}
eval "value=\$$var_name"  # ✗
value="${!var_name}"       # ✓

# ✗ eval for dynamic vars → ✓ Use associative arrays
eval "var_$i='value'"     # ✗
declare -A data; data["var_$i"]='value'  # ✓

# ✗ eval for dispatch → ✓ Use case/array
eval "${action}_func"     # ✗
case "$action" in
  start) start_func ;;
  stop)  stop_func ;;
  *)     die 22 "Invalid" ;;
esac
```

**Anti-patterns:**
- `eval "$input"` → Whitelist with case
- `eval "$var='$val'"` → `printf -v "$var" '%s' "$val"`
- `eval "source $file"` → `source "$file"`

**Key principle:** Use arrays, indirect expansion (`${!var}`), or associative arrays instead of `eval`.

**Ref:** BCS1204
