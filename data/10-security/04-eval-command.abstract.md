## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely—safer alternatives exist for all common use cases.**

### Rationale
- **Code injection**: `eval` executes arbitrary code with full script privileges—complete system compromise
- **Bypasses validation**: Even sanitized input can contain metacharacters enabling injection
- **Better alternatives**: Arrays, indirect expansion, associative arrays handle all use cases safely

### Safe Alternatives

```bash
# ✗ eval for variable indirection
eval "value=\$$var_name"
# ✓ Indirect expansion
echo "${!var_name}"

# ✗ eval for dynamic assignment
eval "$var_name='$value'"
# ✓ printf -v
printf -v "$var_name" '%s' "$value"

# ✗ eval for command building
eval "$cmd"
# ✓ Array execution
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"

# ✗ eval for function dispatch
eval "${action}_function"
# ✓ Associative array lookup
declare -A actions=([start]=start_fn [stop]=stop_fn)
[[ -v "actions[$action]" ]] && "${actions[$action]}"
```

### Anti-Patterns

```bash
# ✗ eval with user input �' `case` whitelist
eval "$user_command"

# ✗ eval in loop �' associative array dispatch
for f in *.txt; do eval "process_${f%.txt}"; done
```

**Key principle:** If you think you need `eval`, use arrays, indirect expansion `${!var}`, or associative arrays instead.

**Ref:** BCS1004
