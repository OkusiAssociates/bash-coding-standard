## Process Substitution

**Use `<(command)` and `>(command)` to provide command output as file-like inputs or send data as if writing to files. Eliminates temp files, avoids subshell issues, enables parallel processing.**

**Rationale:**
- **No Temporary Files**: Eliminates temp file creation/cleanup overhead
- **Avoid Subshells**: Unlike pipes to while, preserves variable scope
- **Parallelism**: Multiple process substitutions run simultaneously
- **Resource Efficiency**: Data streams through FIFOs without disk I/O

**How it works:**

```bash
# <(command) - Input: creates /dev/fd/NN containing command's stdout
# >(command) - Output: creates /dev/fd/NN piping to command's stdin

diff <(sort file1) <(sort file2)
# Expands to: diff /dev/fd/63 /dev/fd/64
```

**Basic patterns:**

```bash
# Input process substitution <(command)
diff <(ls dir1) <(ls dir2)
cat <(echo "Header") <(cat data.txt) <(echo "Footer")
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)

# Output process substitution >(command)
command | tee >(wc -l) >(grep ERROR) > output.txt
echo "data" > >(base64)
```

**Critical use cases:**

**1. Reading into arrays (avoids subshell):**

```bash
# ✓ BEST - readarray with process substitution
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)

# ✓ Null-delimited for filenames with special chars
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**2. While loops preserving variables:**

```bash
# ✓ CORRECT - Process substitution (no subshell)
declare -i count=0
while IFS= read -r line; do
  ((count+=1))
done < <(cat file.txt)
echo "Count: $count"  # Correct value!
```

**3. Comparing command outputs:**

```bash
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
diff <(jq -S . file1.json) <(jq -S . file2.json)
```

**4. Parallel processing with tee:**

```bash
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
```

**5. Multiple simultaneous inputs:**

```bash
while IFS= read -r line1 <&3 && IFS= read -r line2 <&4; do
  echo "File1: ${line1@Q}  File2: ${line2@Q}"
done 3< <(cat file1.txt) 4< <(cat file2.txt)

sort -m <(sort file1) <(sort file2) <(sort file3)
```

**Complete example - Data merging:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION=1.0.0
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

merge_user_data() {
  local -- source1=$1 source2=$2
  local -a users1 users2 common only1 only2

  readarray -t users1 < <(cut -d: -f1 "$source1" | sort -u)
  readarray -t users2 < <(cut -d: -f1 "$source2" | sort -u)

  readarray -t common < <(comm -12 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only1 < <(comm -23 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only2 < <(comm -13 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))

  info "Common: ${#common[@]}, Only source1: ${#only1[@]}, Only source2: ${#only2[@]}"
}

main() { merge_user_data '/etc/passwd' '/backup/passwd'; }
main "$@"
#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - temp files instead of process substitution
temp1=$(mktemp); temp2=$(mktemp)
sort file1 > "$temp1"; sort file2 > "$temp2"
diff "$temp1" "$temp2"; rm "$temp1" "$temp2"
# ✓ Correct
diff <(sort file1) <(sort file2)

# ✗ Wrong - pipe to while (subshell, count stays 0)
declare -i count=0
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!
# ✓ Correct
while read -r line; do count+=1; done < <(cat file)

# ✗ Wrong - sequential file reads (3x I/O)
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt
# ✓ Correct - single read, parallel processing
cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) >(wc -l > count.txt) > /dev/null

# ✗ Wrong - unquoted variables
diff <(sort $file1) <(sort $file2)
# ✓ Correct
diff <(sort "$file1") <(sort "$file2")

# ✗ Wrong - no error handling
diff <(failing_command) file  # Empty input on failure
# ✓ Correct
if temp=$(failing_command); then diff <(echo "$temp") file; else die 1 'Failed'; fi
```

**Edge cases:**

**1. File descriptor assignment:**

```bash
exec 3< <(long_running_command)
while IFS= read -r line <&3; do echo "$line"; done
exec 3<&-  # Close when done
```

**2. NULL-delimited processing:**

```bash
while IFS= read -r -d '' file; do
  echo "Processing: $file"
done < <(find /data -type f -print0)
```

**3. Nested process substitution:**

```bash
diff <(sort <(grep pattern file1)) <(sort <(grep pattern file2))
```

**When NOT to use:**

```bash
# ✗ Overcomplicated - use command substitution
result=$(cat <(command))
# ✓ Simpler
result=$(command)

# ✗ Overcomplicated - use direct redirection
grep pattern < <(cat file)
# ✓ Simpler
grep pattern file

# ✗ Overcomplicated - use here-string for variables
command < <(echo "$variable")
# ✓ Simpler
command <<< "$variable"
```

**Key principle:** Process substitution treats command output as files—more efficient than temp files, safer than pipes (no subshell), enables powerful data processing. When creating temp files just to pass data between commands, process substitution is almost always better.
