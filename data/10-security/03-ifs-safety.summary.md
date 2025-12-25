## IFS Manipulation Safety

**Never trust or use inherited IFS values. Always protect IFS changes to prevent field splitting attacks and unexpected behavior.**

**Rationale:**

- **Security Vulnerability**: Attackers manipulate IFS in calling environment to exploit scripts without IFS protection
- **Field Splitting Exploits**: Malicious IFS values cause word splitting at unexpected characters, breaking argument parsing and enabling command injection
- **Global Side Effects**: Unrestored IFS changes break subsequent operations throughout the script
- **Environment Inheritance**: IFS inherited from parent processes may be attacker-controlled

**Understanding IFS:**

IFS (Internal Field Separator) controls how Bash splits words during expansion. Default is `$' \t\n'` (space, tab, newline).

```bash
# Default IFS behavior
IFS=$' \t\n'  # Space, tab, newline (default)
data="one two three"
read -ra words <<< "$data"
# Result: words=("one" "two" "three")

# Custom IFS for CSV parsing
IFS=','
data="apple,banana,orange"
read -ra fruits <<< "$data"
# Result: fruits=("apple" "banana" "orange")
```

**Attack Example: Field Splitting Exploitation**

```bash
# Vulnerable script - doesn't protect IFS
#!/bin/bash
set -euo pipefail

process_files() {
  local -- file_list="$1"
  local -a files
  read -ra files <<< "$file_list"  # Vulnerable to IFS manipulation

  for file in "${files[@]}"; do
    rm -- "$file"
  done
}

# Normal usage
process_files "temp1.txt temp2.txt temp3.txt"
```

**Attack:**
```bash
# Attacker sets IFS to slash
export IFS='/'
./vulnerable-script.sh

# With IFS='/', read -ra splits on '/' not spaces
# files=("temp1.txt temp2.txt")  # NOT split - treated as one filename

# Or bypass filtering:
export IFS=$'\n'
./vulnerable-script.sh "/etc/passwd
/root/.ssh/authorized_keys"
```

**Attack Example: Command Injection via IFS**

```bash
# Vulnerable script
#!/bin/bash
set -euo pipefail

user_input="$1"
read -ra cmd_parts <<< "$user_input"  # Splits on IFS
"${cmd_parts[@]}"
```

**Attack:**
```bash
# Attacker manipulates IFS
export IFS='X'
./vulnerable-script.sh "lsX-laX/etc/shadow"

# With IFS='X', splitting becomes:
# cmd_parts=("ls" "-la" "/etc/shadow")
# Bypasses input validation checking for spaces
```

**Safe Pattern 1: One-Line IFS Assignment (Preferred)**

```bash
#  Correct - IFS change applies only to single command
# VAR=value command applies VAR only to that command

# Parse CSV in one line
IFS=',' read -ra fields <<< "$csv_data"
# IFS automatically reset after read command

# Parse colon-separated PATH
IFS=':' read -ra path_dirs <<< "$PATH"

# Most concise and safe pattern for single operations
```

**Safe Pattern 2: Local IFS in Function**

```bash
#  Correct - use local to scope IFS change
parse_csv() {
  local -- csv_data="$1"
  local -a fields
  local -- IFS  # Make IFS local to this function

  IFS=','
  read -ra fields <<< "$csv_data"

  # IFS automatically restored when function returns
  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 3: Save and Restore IFS**

```bash
#  Correct - save, modify, restore
parse_csv() {
  local -- csv_data="$1"
  local -a fields
  local -- saved_ifs

  saved_ifs="$IFS"
  IFS=','
  read -ra fields <<< "$csv_data"
  IFS="$saved_ifs"  # Restore immediately

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 4: Subshell Isolation**

```bash
#  Correct - IFS change isolated to subshell
parse_csv() {
  local -- csv_data="$1"
  local -a fields

  # IFS change automatically reverts when subshell exits
  fields=( $(
    IFS=','
    read -ra temp <<< "$csv_data"
    printf '%s\n' "${temp[@]}"
  ) )

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}
```

**Safe Pattern 5: Explicitly Set IFS at Script Start**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Explicitly set IFS to known-safe value
# Defends against inherited malicious IFS
IFS=$' \t\n'  # Space, tab, newline (standard default)
readonly IFS  # Prevent modification
export IFS

# Rest of script operates with trusted IFS
```

**Edge Cases:**

```bash
# IFS with read -d (delimiter) - IFS still matters for field splitting
while IFS= read -r -d '' file; do
  # IFS= prevents field splitting
  # -d '' sets null byte as delimiter
  process "$file"
done < <(find . -type f -print0)

# IFS affects word splitting, NOT pathname expansion (globbing)
IFS=':'
files=*.txt  # Glob expands normally
echo $files  # Splits on ':' - WRONG!
echo "$files"  # Safe - no splitting

# Empty IFS disables field splitting entirely
IFS=''
data="one two three"
read -ra words <<< "$data"
# Result: words=("one two three")  # NOT split

# Useful to preserve exact input
IFS= read -r line < file.txt  # Preserves leading/trailing whitespace
```

**Anti-patterns:**

```bash
#  Wrong - modifying IFS without save/restore
IFS=','
read -ra fields <<< "$csv_data"
# IFS is now ',' for rest of script - BROKEN!

#  Wrong - trusting inherited IFS
#!/bin/bash
set -euo pipefail
read -ra parts <<< "$user_input"  # Vulnerable to manipulation

#  Wrong - forgetting to restore IFS in error cases
saved_ifs="$IFS"
IFS=','
some_command || return 1  # IFS not restored on error!
IFS="$saved_ifs"

#  Correct - use trap or subshell
(
  IFS=','
  some_command || return 1  # Subshell ensures IFS restored
)

#  Wrong - modifying IFS globally
IFS=$'\n'
for line in $(cat file.txt); do
  process "$line"
done
# Now ALL subsequent operations use wrong IFS!

#  Correct - isolate IFS change
while IFS= read -r line; do
  process "$line"
done < file.txt

#  Wrong - using IFS for complex parsing
IFS=':' read -r user pass uid gid name home shell <<< "$passwd_line"
# Fragile - breaks if any field contains ':'

#  Correct - use cut or awk for structured data
user=$(cut -d: -f1 <<< "$passwd_line")
uid=$(cut -d: -f3 <<< "$passwd_line")
```

**Complete Safe Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Set IFS to known-safe value immediately
IFS=$' \t\n'
readonly IFS
export IFS

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Parse CSV data safely
parse_csv_file() {
  local -- csv_file="$1"

  while IFS= read -r line; do
    local -a fields
    IFS=',' read -ra fields <<< "$line"  # One-line pattern

    # Process fields with normal IFS
    info "Name: ${fields[0]}"
    info "Email: ${fields[1]}"
    info "Age: ${fields[2]}"
  done < "$csv_file"
}

main() {
  parse_csv_file 'data.csv'
}

main "$@"

#fin
```

**Testing IFS Safety:**

```bash
# Test script behavior with malicious IFS
test_ifs_safety() {
  local -- original_ifs="$IFS"

  IFS='/'  # Set malicious IFS
  parse_csv_line "apple,banana,orange"

  # Verify IFS was restored
  if [[ "$IFS" == "$original_ifs" ]]; then
    success 'IFS properly protected'
  else
    error 'IFS leaked - security vulnerability!'
    return 1
  fi
}

# Display current IFS (non-printable characters shown)
debug_ifs() {
  local -- ifs_visual
  ifs_visual=$(printf '%s' "$IFS" | cat -v)
  >&2 echo "DEBUG: Current IFS: [$ifs_visual]"
  >&2 echo "DEBUG: IFS length: ${#IFS}"
  >&2 printf 'DEBUG: IFS bytes: %s\n' "$(printf '%s' "$IFS" | od -An -tx1)"
}

# Verify IFS is default
verify_default_ifs() {
  local -- expected=$' \t\n'
  if [[ "$IFS" == "$expected" ]]; then
    info 'IFS is default (safe)'
  else
    warn 'IFS is non-standard'
    debug_ifs
  fi
}
```

**Summary:**

- **Set IFS explicitly** at script start: `IFS=$' \t\n'; readonly IFS`
- **Use one-line assignment** for single commands: `IFS=',' read -ra fields <<< "$data"`
- **Use local IFS** in functions to scope changes: `local -- IFS; IFS=','`
- **Use subshells** to isolate IFS changes: `( IFS=','; read -ra fields <<< "$data" )`
- **Always restore IFS** if modifying: `saved_ifs="$IFS"; IFS=','; ...; IFS="$saved_ifs"`
- **Never trust inherited IFS** - always set it yourself
- **Test IFS safety** as part of security validation

**Key principle:** IFS is a global variable affecting word splitting throughout your script. Treat it as security-critical and always protect changes with proper scoping or save/restore patterns.
