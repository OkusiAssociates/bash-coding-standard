## Eval Command

**Never use `eval` with untrusted input. Avoid entirely—safer alternatives exist for all common use cases.**

### Rationale
- **Code injection**: Executes arbitrary code with full script privileges—complete system compromise
- **Double expansion**: `eval "echo $var"` expands `$var` twice, executing embedded commands
- **Unauditable**: Dynamic code construction defeats security review

### Safe Alternatives

```bash
# ✗ eval for variable indirection
eval "value=\$$var_name"
# ✓ Indirect expansion
echo "${!var_name}"

# ✗ eval for dynamic commands
eval "$cmd"
# ✓ Array execution
declare -a cmd=(find /data -name "*.txt")
"${cmd[@]}"

# ✗ eval for variable assignment
eval "$var_name='$value'"
# ✓ printf -v
printf -v "$var_name" '%s' "$value"

# ✗ eval for function dispatch
eval "${action}_function"
# ✓ Associative array lookup
declare -A actions=([start]=start_fn [stop]=stop_fn)
[[ -v "actions[$action]" ]] && "${actions[$action]}"
```

### Anti-Patterns
- `eval "$user_input"` → Use `case` whitelist or array execution
- `eval "$var='$val'"` → Use `printf -v` or associative arrays

**Ref:** BCS1004
