# Section 10: Security

## BCS1000 Section Overview

Five essential security areas: SUID/SGID prohibition, PATH security, IFS safety, eval avoidance, and input sanitization. These prevent privilege escalation, command injection, and path traversal attacks.

## BCS1001 SUID/SGID Prohibition

Never use SUID or SGID bits on Bash scripts. No exceptions.

```bash
# wrong — catastrophically dangerous
chmod u+s script.sh

# correct — use sudo instead
sudo /usr/local/bin/myscript.sh
# or configure /etc/sudoers.d/myapp for specific commands
```

For elevated privileges, use sudo, capabilities (`setcap`), compiled wrappers, PolicyKit, or systemd services.

## BCS1002 PATH Security

Secure PATH at script start to prevent command hijacking.

```bash
# correct
declare -rx PATH=~/.local/bin:/usr/local/bin:/usr/bin:/bin

# correct — for production/security-critical scripts
declare -rx PATH=/usr/local/bin:/usr/bin:/bin

# wrong — includes dangerous elements
PATH=.:$PATH                         # current directory
PATH="/tmp:$PATH"                    # world-writable directory
```

Never include `.`, empty elements (`::`, leading/trailing `:`), `/tmp`, or user home directories in PATH. Place PATH setting early, before any commands that depend on it.

## BCS1003 IFS Safety

Never trust inherited IFS values.

```bash
# correct — one-line IFS for single command
IFS=',' read -ar fields <<< "$csv_data"

# correct — subshell isolation
( IFS=','; read -ar fields <<< "$data" )

# correct — local scoping in functions
parse_csv() {
  local -- IFS=','
  read -ar fields <<< "$1"
}

# correct — null-delimited input
while IFS= read -r -d '' file; do
  process "$file"
done < <(find . -print0)

# wrong — modifying global IFS without restore
IFS=','
```

## BCS1004 Eval Avoidance

Never use `eval` with untrusted input. Almost every use case has a safer alternative.

```bash
# correct — arrays for dynamic commands
local -a cmd=(find "$path" -name "$pattern")
"${cmd[@]}"

# correct — indirect expansion
echo "${!var_name}"

# correct — printf -v for dynamic assignment
printf -v "$var_name" '%s' "$value"

# correct — associative arrays for dynamic data
declare -A data
data["$key"]="$value"

# correct — case for dispatch
case "$action" in
  start) start_fn ;;
  stop)  stop_fn ;;
esac

# wrong
eval "echo \$$var_name"
eval "$var_name='$value'"
eval "${action}_function"
```

## BCS1005 Input Sanitization

Validate and sanitize all user input. Use whitelist over blacklist.

```bash
# correct — validate integer
[[ $input =~ ^-?[0-9]+$ ]] || die 22 "Invalid integer: ${input@Q}"

# correct — validate path within allowed directory
real_path=$(realpath -e -- "$path")
[[ $real_path == "$allowed_dir"* ]] || die 13 'Path traversal blocked'

# correct — sanitize filename
[[ $name =~ ^[a-zA-Z0-9._-]+$ ]] || die 22 "Invalid filename ${name@Q}"

# correct — always use -- before file arguments
rm -- "$user_file"
cp -- "$source" "$dest"
```

Validate early, fail securely with clear errors, run with minimum necessary permissions.

## BCS1006 Temporary File Handling

Always use `mktemp`. Never hardcode temp file paths.

```bash
# correct
temp_file=$(mktemp) || die 1 'Failed to create temp file'
trap 'rm -f "$temp_file"' EXIT

temp_dir=$(mktemp -d) || die 1 'Failed to create temp dir'
trap 'rm -rf "$temp_dir"' EXIT

# correct — custom template
mktemp /tmp/"$SCRIPT_NAME".XXXXXX

# wrong
echo data > /tmp/myapp_temp.txt      # predictable path
echo data > "/tmp/app_$$"            # PID-based (predictable)
```

Default `mktemp` permissions are secure (0600 files, 0700 directories). Multiple trap statements for the same signal overwrite each other — use a single cleanup function.
