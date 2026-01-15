## Process Substitution

**Use `<(command)` and `>(command)` to provide command output as file-like inputs or send data to commands as files. Eliminates temp files, avoids subshell issues with pipes, enables parallel processing.**

**Rationale:**
- No temp files - data streams through FIFOs/file descriptors without disk I/O
- Avoids subshells - unlike pipes to while, preserves variable scope
- Multiple inputs run in parallel; clean syntax vs complex piping

**How it works:**

```bash
# <(command) - Input: creates /dev/fd/N, reads from command's stdout
# >(command) - Output: creates /dev/fd/N, writes to command's stdin

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

**Common use cases:**

**1. Comparing outputs:**
```bash
diff <(ls -1 /dir1 | sort) <(ls -1 /dir2 | sort)
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
```

**2. Reading into array (avoids subshell):**
```bash
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)

# Null-delimited for safe filenames
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. While loop without subshell:**
```bash
declare -i count=0
while IFS= read -r line; do
  ((count+=1))
done < <(cat file.txt)
echo "Count: $count"  # Correct value!
```

**4. Multiple simultaneous inputs:**
```bash
while IFS= read -r line1 <&3 && IFS= read -r line2 <&4; do
  echo "File1: ${line1@Q}"
  echo "File2: ${line2@Q}"
done 3< <(cat file1.txt) 4< <(cat file2.txt)

sort -m <(sort file1) <(sort file2) <(sort file3)
```

**5. Parallel processing with tee:**
```bash
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
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
  local -- source1=$1
  local -- source2=$2

  local -a users1 users2
  readarray -t users1 < <(cut -d: -f1 "$source1" | sort -u)
  readarray -t users2 < <(cut -d: -f1 "$source2" | sort -u)

  # Find users in both, only in source1, only in source2
  local -a common only_source1 only_source2
  readarray -t common < <(comm -12 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only_source1 < <(comm -23 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))
  readarray -t only_source2 < <(comm -13 <(printf '%s\n' "${users1[@]}") <(printf '%s\n' "${users2[@]}"))

  info "Common: ${#common[@]}, Only src1: ${#only_source1[@]}, Only src2: ${#only_source2[@]}"
}

main() {
  merge_user_data '/etc/passwd' '/backup/passwd'
}

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

# ✗ Wrong - pipe creates subshell, count stays 0
declare -i count=0
cat file | while read -r line; do count+=1; done
echo "$count"  # Still 0!

# ✓ Correct - process substitution preserves scope
declare -i count=0
while read -r line; do count+=1; done < <(cat file)
echo "$count"  # Correct value!

# ✗ Wrong - reads file 3 times sequentially
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt

# ✓ Correct - reads once, processes in parallel
cat log | tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) >(wc -l > count.txt) > /dev/null

# ✗ Wrong - unquoted variables
diff <(sort $file1) <(sort $file2)

# ✓ Correct
diff <(sort "$file1") <(sort "$file2")
```

**Edge cases:**

**1. File descriptor assignment:**
```bash
exec 3< <(long_running_command)
while IFS= read -r line <&3; do echo "$line"; done
exec 3<&-
```

**2. NULL-delimited with process substitution:**
```bash
while IFS= read -r -d '' file; do
  echo "Processing ${file@Q}"
done < <(find /data -type f -print0)
```

**3. Nested process substitution:**
```bash
diff <(sort <(grep pattern file1)) <(sort <(grep pattern file2))
```

**When NOT to use:**

```bash
# Simple command output - command substitution is clearer
result=$(command)  # Not: result=$(cat <(command))

# Single file input - direct redirection is clearer
grep pattern file  # Not: grep pattern < <(cat file)

# Variable expansion - use here-string
command <<< "$variable"  # Not: command < <(echo "$variable")
```

**Key principle:** Process substitution treats command output as a file. More efficient than temp files, safer than pipes (no subshell), enables powerful data processing. When creating temp files to pass data between commands, process substitution is almost always better.
