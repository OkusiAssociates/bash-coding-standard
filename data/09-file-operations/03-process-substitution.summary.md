## Process Substitution

**Use process substitution `<(command)` and `>(command)` to provide command output as file-like inputs or send data to commands as if writing to files. Eliminates temp files, avoids subshell issues, enables parallel processing.**

**Rationale:**

- **No Temporary Files**: Eliminates creating, managing, cleaning up temp files
- **Avoid Subshells**: Unlike pipes to while, preserves variable scope
- **Multiple Inputs**: Commands read from multiple process substitutions simultaneously
- **Parallelism**: Multiple process substitutions run in parallel
- **Resource Efficiency**: Data streams through FIFOs/file descriptors without disk I/O

**How it works:**

Process substitution creates temporary FIFO (named pipe) or file descriptor connecting command output to another command's input.

```bash
# <(command) - Input redirection: creates /dev/fd/63 (or similar)
# Data read from this comes from command's stdout

# >(command) - Output redirection: creates /dev/fd/63 (or similar)
# Data written to this goes to command's stdin

# Example:
diff <(sort file1) <(sort file2)
# Expands to: diff /dev/fd/63 /dev/fd/64
```

**Basic patterns:**

```bash
# Input process substitution
diff <(ls dir1) <(ls dir2)
cat <(echo "Header") <(cat data.txt) <(echo "Footer")
grep pattern <(find /data -name '*.log')
paste <(cut -d: -f1 /etc/passwd) <(cut -d: -f3 /etc/passwd)

# Output process substitution
command | tee >(wc -l) >(grep ERROR) > output.txt
generate_data | tee >(process_type1) >(process_type2) > /dev/null
echo "data" > >(base64)
```

**Common use cases:**

**1. Comparing command outputs:**

```bash
diff <(ls -1 /dir1 | sort) <(ls -1 /dir2 | sort)
diff <(sha256sum /backup/file) <(sha256sum /original/file)
diff <(ssh host1 cat /etc/config) <(ssh host2 cat /etc/config)
```

**2. Reading command output into array:**

```bash
#  BEST - readarray with process substitution
declare -a users
readarray -t users < <(getent passwd | cut -d: -f1)
echo "Users: ${#users[@]}"

#  ALSO GOOD - null-delimited
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. Avoiding subshell in while loops:**

```bash
#  CORRECT - Process substitution (no subshell)
declare -i count=0

while IFS= read -r line; do
  echo "$line"
  ((count+=1))
done < <(cat file.txt)

echo "Count: $count"  # Correct value!
```

**4. Multiple simultaneous inputs:**

```bash
# Read from multiple sources
while IFS= read -r line1 <&3 && IFS= read -r line2 <&4; do
  echo "File1: $line1"
  echo "File2: $line2"
done 3< <(cat file1.txt) 4< <(cat file2.txt)

# Merge sorted files
sort -m <(sort file1) <(sort file2) <(sort file3)
```

**5. Parallel processing with tee:**

```bash
# Process log file multiple ways simultaneously
cat logfile.txt | tee \
  >(grep ERROR > errors.log) \
  >(grep WARN > warnings.log) \
  >(wc -l > line_count.txt) \
  > all_output.log
```

**Complete example - Log analysis with parallel processing:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

analyze_log() {
  local -- log_file="$1"
  local -- output_dir="${2:-.}"

  info "Analyzing $log_file..."

  # Process log file multiple ways simultaneously
  cat "$log_file" | tee \
    >(grep 'ERROR' | sort -u > "$output_dir/errors.txt") \
    >(grep 'WARN' | sort -u > "$output_dir/warnings.txt") \
    >(awk '{print $1}' | sort -u > "$output_dir/unique_timestamps.txt") \
    >(wc -l > "$output_dir/line_count.txt") \
    > "$output_dir/full_log.txt"

  wait  # Wait for all background processes

  # Report results
  local -i error_count warn_count total_lines

  error_count=$(wc -l < "$output_dir/errors.txt")
  warn_count=$(wc -l < "$output_dir/warnings.txt")
  total_lines=$(cat "$output_dir/line_count.txt")

  info "Analysis complete:"
  info "  Total lines: $total_lines"
  info "  Unique errors: $error_count"
  info "  Unique warnings: $warn_count"
}

main() {
  local -- log_file="${1:-/var/log/app.log}"
  analyze_log "$log_file"
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
#  Wrong - using temp files
temp1=$(mktemp)
temp2=$(mktemp)
sort file1 > "$temp1"
sort file2 > "$temp2"
diff "$temp1" "$temp2"
rm "$temp1" "$temp2"

#  Correct - process substitution (no temp files)
diff <(sort file1) <(sort file2)

#  Wrong - pipe to while (subshell issue)
count=0
cat file | while read -r line; do
  ((count+=1))
done
echo "$count"  # Still 0!

#  Correct - process substitution (no subshell)
count=0
while read -r line; do
  ((count+=1))
done < <(cat file)
echo "$count"  # Correct value!

#  Wrong - sequential processing (reads file 3 times)
cat log | grep ERROR > errors.txt
cat log | grep WARN > warnings.txt
cat log | wc -l > count.txt

#  Correct - parallel with tee (reads once)
cat log | tee \
  >(grep ERROR > errors.txt) \
  >(grep WARN > warnings.txt) \
  >(wc -l > count.txt) \
  > /dev/null

#  Wrong - not quoting variables
diff <(sort $file1) <(sort $file2)  # Word splitting!

#  Correct - quote variables
diff <(sort "$file1") <(sort "$file2")
```

**Edge cases:**

**1. File descriptor assignment:**

```bash
# Assign process substitution to file descriptor
exec 3< <(long_running_command)

# Read from it later
while IFS= read -r line <&3; do
  echo "$line"
done

# Close when done
exec 3<&-
```

**2. NULL-delimited with process substitution:**

```bash
# Handle filenames with spaces/newlines
while IFS= read -r -d '' file; do
  echo "Processing: $file"
done < <(find /data -type f -print0)

# With readarray
declare -a files
readarray -d '' -t files < <(find /data -type f -print0)
```

**3. Nested process substitution:**

```bash
# Complex data processing
diff \
  <(sort <(grep pattern file1)) \
  <(sort <(grep pattern file2))

# Process chains
cat <(echo "header") <(sort <(grep -v '^#' data.txt)) <(echo "footer")
```

**When NOT to use:**

```bash
# Simple command output - command substitution is clearer
#  Overcomplicated
result=$(cat <(command))
#  Simpler
result=$(command)

# Single file input - direct redirection is clearer
#  Overcomplicated
grep pattern < <(cat file)
#  Simpler
grep pattern file

# Variable expansion - use here-string
#  Overcomplicated
command < <(echo "$variable")
#  Simpler
command <<< "$variable"
```

**Key principle:** Process substitution is Bash's answer to "I need this command's output to look like a file." More efficient than temp files, safer than pipes (no subshell), enables powerful parallel data processing. Use `<(command)` for input, `>(command)` for output, combine with `tee` for parallel processing.
