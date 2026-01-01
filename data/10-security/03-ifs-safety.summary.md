## IFS Manipulation Safety

**Never trust or use inherited IFS values. Always protect IFS changes to prevent field splitting attacks and unexpected behavior.**

**Rationale:**
- **Security Vulnerability**: Attackers manipulate IFS in calling environment to exploit unprotected scripts
- **Field Splitting Exploits**: Malicious IFS causes word splitting at unexpected characters
- **Command Injection**: IFS manipulation with unquoted variables enables command execution
- **Global Side Effects**: Changing IFS without restoration breaks subsequent operations

**Understanding IFS:**

IFS (Internal Field Separator) controls word splitting during expansion. Default: `$' \t\n'` (space, tab, newline).

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
process_files() {
  local -- file_list=$1
  local -a files
  read -ra files <<< "$file_list"  # Vulnerable: IFS could be manipulated
  for file in "${files[@]}"; do
    rm -- "$file"
  done
}

# Attack: attacker sets IFS='/' before calling script
# With IFS='/', read -ra splits on '/' not spaces!
# "temp1.txt temp2.txt" becomes single filename, not two
```

**Safe Pattern 1: One-Line IFS Assignment (Preferred)**

```bash
# ✓ Correct - IFS change applies only to single command
IFS=',' read -ra fields <<< "$csv_data"
# IFS is automatically reset after the read command

IFS=':' read -ra path_dirs <<< "$PATH"
# Most concise and safe pattern for single operations
```

**Safe Pattern 2: Local IFS in Function**

```bash
# ✓ Correct - use local to scope IFS change
parse_csv() {
  local -- csv_data=$1
  local -a fields
  local -- IFS  # Make IFS local to this function

  IFS=','
  read -ra fields <<< "$csv_data"
  # IFS automatically restored when function returns
}
```

**Safe Pattern 3: Save and Restore IFS**

```bash
# ✓ Correct - save, modify, restore
parse_csv() {
  local -- csv_data=$1
  local -a fields
  local -- saved_ifs

  saved_ifs="$IFS"
  IFS=','
  read -ra fields <<< "$csv_data"
  IFS="$saved_ifs"  # Restore immediately
}
```

**Safe Pattern 4: Subshell Isolation**

```bash
# ✓ Correct - IFS change isolated to subshell
(
  IFS=','
  some_command || return 1  # Subshell ensures IFS is restored
)
```

**Safe Pattern 5: Explicitly Set IFS at Script Start**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Defend against inherited malicious IFS
IFS=$' \t\n'  # Space, tab, newline (standard default)
readonly IFS  # Prevent modification
export IFS
```

**Edge Cases:**

```bash
# IFS with read -d (null-delimited input from find -print0)
while IFS= read -r -d '' file; do
  process "$file"
done < <(find . -type f -print0)

# Empty IFS disables field splitting entirely
IFS=''
data="one two three"
read -ra words <<< "$data"
# Result: words=("one two three")  # NOT split!

# Preserve leading/trailing whitespace
IFS= read -r line < file.txt
```

**Anti-patterns:**

```bash
# ✗ Wrong - modifying IFS without save/restore
IFS=','
read -ra fields <<< "$csv_data"
# IFS is now ',' for the rest of the script - BROKEN!

# ✗ Wrong - trusting inherited IFS
#!/bin/bash
set -euo pipefail
# No IFS protection - vulnerable to manipulation!
read -ra parts <<< "$user_input"

# ✓ Correct - set IFS explicitly
IFS=$' \t\n'
readonly IFS

# ✗ Wrong - forgetting to restore IFS in error cases
saved_ifs="$IFS"
IFS=','
some_command || return 1  # IFS not restored on error!
IFS="$saved_ifs"

# ✓ Correct - use subshell for error safety
(
  IFS=','
  some_command || return 1
)

# ✗ Wrong - modifying IFS globally for loop
IFS=$'\n'
for line in $(cat file.txt); do
  process "$line"
done
# Now ALL subsequent operations use wrong IFS!

# ✓ Correct - isolate IFS change
while IFS= read -r line; do
  process "$line"
done < file.txt
```

**Complete Safe Example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

IFS=$' \t\n'
readonly IFS
export IFS

parse_csv_line() {
  local -- csv_line=$1
  local -a fields

  # IFS applies only to this read command
  IFS=',' read -ra fields <<< "$csv_line"

  for field in "${fields[@]}"; do
    info "Field: $field"
  done
}

main() {
  parse_csv_line 'apple,banana,orange'
}

main "$@"

#fin
```

**Testing IFS Safety:**

```bash
test_ifs_safety() {
  local -- original_ifs="$IFS"
  IFS='/'  # Set malicious IFS

  parse_csv_line "apple,banana,orange"

  if [[ "$IFS" == "$original_ifs" ]]; then
    success 'IFS properly protected'
  else
    error 'IFS leaked - security vulnerability!'
    return 1
  fi
}
```

**Summary:**
- **Set IFS explicitly** at script start: `IFS=$' \t\n'; readonly IFS`
- **Use one-line assignment** for single commands: `IFS=',' read -ra fields <<< "$data"`
- **Use local IFS** in functions: `local -- IFS; IFS=','`
- **Use subshells** for error-safe isolation
- **Always restore IFS** if modifying globally
- **Never trust inherited IFS**
