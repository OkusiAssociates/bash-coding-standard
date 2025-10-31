## Arrays for Safe List Handling

**Use arrays to store lists of elements safely, especially for command arguments, file lists, and any collection where elements may contain spaces, special characters, or wildcards. Arrays provide proper element boundaries and eliminate word splitting and glob expansion issues.**

**Rationale:**

- **Element Preservation**: Arrays maintain element boundaries regardless of content (spaces, newlines, special chars)
- **No Word Splitting**: Array elements don't undergo word splitting when expanded with `"${array[@]}"`
- **Glob Safety**: Array elements containing wildcards are preserved literally
- **Safe Command Construction**: Build commands with arbitrary arguments safely
- **Iteration Safety**: Each element processed exactly once
- **Dynamic Lists**: Grow, shrink, and modify without quoting complications

**Problem with string lists vs arrays:**

```bash
# ✗ DANGEROUS - String-based list
files_str="file1.txt file with spaces.txt file3.txt"
for file in $files_str; do echo "$file"; done
# Output: file1.txt / file / with / spaces.txt / file3.txt (5 iterations instead of 3!)
cmd $files_str  # Passes 5 arguments instead of 3!

# ✓ SAFE - Array-based list
declare -a files=('file1.txt' 'file with spaces.txt' 'file3.txt')
for file in "${files[@]}"; do echo "$file"; done
# Output: file1.txt / file with spaces.txt / file3.txt (3 iterations - correct!)
cmd "${files[@]}"  # Passes exactly 3 arguments
```

**Safe command construction with conditional arguments:**

```bash
# ✓ Build commands with dynamic options
build_command() {
  local -- output_file="$1"
  local -i verbose="$2"

  local -a cmd=('myapp' '--config' '/etc/myapp/config.conf' '--output' "$output_file")
  ((verbose)) && cmd+=('--verbose')
  "${cmd[@]}"
}

# ✓ Find command with conditional pattern
search_files() {
  local -- search_dir="$1"
  local -- pattern="$2"

  local -a find_args=("$search_dir" '-type' 'f')
  [[ -n "$pattern" ]] && find_args+=('-name' "$pattern")
  find_args+=('-mtime' '-7' '-size' '+1M')
  find "${find_args[@]}"
}

# ✓ SSH with conditional key authentication
ssh_connect() {
  local -- host="$1"
  local -i use_key="$2"
  local -- key_file="$3"

  local -a ssh_args=('-o' 'StrictHostKeyChecking=no' '-o' 'UserKnownHostsFile=/dev/null')
  ((use_key)) && [[ -f "$key_file" ]] && ssh_args+=('-i' "$key_file")
  ssh_args+=("$host")
  ssh "${ssh_args[@]}"
}
```

**Safe file list handling:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

# Process predefined file list
process_files() {
  local -a files=(
    "$SCRIPT_DIR/data/file 1.txt"
    "$SCRIPT_DIR/data/report (final).pdf"
    "$SCRIPT_DIR/data/config.conf"
  )
  local -- file
  local -i processed=0
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      info "Processing: $file"
      ((processed+=1))
    else
      warn "File not found: $file"
    fi
  done
  info "Processed $processed files"
}

# Gather files with globbing
gather_files() {
  local -- pattern="$1"
  local -a matching_files=("$SCRIPT_DIR"/$pattern)
  [[ ${#matching_files[@]} -eq 0 ]] && { error "No files matching: $pattern"; return 1; }
  info "Found ${#matching_files[@]} files"
  for file in "${matching_files[@]}"; do info "File: $file"; done
}

# Build list dynamically from find
collect_log_files() {
  local -- log_dir="$1"
  local -i max_age="$2"
  local -a log_files=()
  local -- file
  while IFS= read -r -d '' file; do
    log_files+=("$file")
  done < <(find "$log_dir" -name '*.log' -mtime "-$max_age" -print0)
  info "Collected ${#log_files[@]} log files"
  for file in "${log_files[@]}"; do process_log "$file"; done
}

main() {
  process_files
  gather_files '*.txt'
}

main "$@"

#fin
```

**Pass arrays to functions:**

```bash
# ✓ Function receives array elements as separate arguments
process_items() {
  local -a items=("$@")
  for item in "${items[@]}"; do info "Item: $item"; done
}

declare -a my_items=('item one' 'item with "quotes"' 'item with $special chars')
process_items "${my_items[@]}"
```

**Conditional array building:**

```bash
# Build compiler flags conditionally
build_compiler_flags() {
  local -i debug="$1" optimize="$2"
  local -a flags=('-Wall' '-Werror')
  ((debug)) && flags+=('-g' '-DDEBUG')
  if ((optimize)); then flags+=('-O2' '-DNDEBUG'); else flags+=('-O0'); fi
  printf '%s\n' "${flags[@]}"
}

declare -a compiler_flags
readarray -t compiler_flags < <(build_compiler_flags 1 0)
gcc "${compiler_flags[@]}" -o myapp myapp.c
```

**Complete example:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

declare -i VERBOSE=0 DRY_RUN=0

create_backup() {
  local -- source_dir="$1" backup_dir="$2"

  local -a tar_args=(
    '-czf' "$backup_dir/backup-$(date +%Y%m%d).tar.gz"
    '-C' "${source_dir%/*}" "${source_dir##*/}"
  )
  ((VERBOSE)) && tar_args+=('-v')

  local -a exclude_patterns=('*.tmp' '*.log' '.git')
  for pattern in "${exclude_patterns[@]}"; do
    tar_args+=('--exclude' "$pattern")
  done

  if ((DRY_RUN)); then
    info '[DRY-RUN] Would execute:'
    printf '  %s\n' "${tar_args[@]}"
  else
    info 'Creating backup...'
    tar "${tar_args[@]}"
  fi
}

process_directories() {
  local -a directories=("$HOME/Documents" "$HOME/Projects/my project" "$HOME/.config")
  local -- dir
  local -i count=0

  for dir in "${directories[@]}"; do
    if [[ -d "$dir" ]]; then
      create_backup "$dir" '/backup'
      ((count+=1))
    else
      warn "Directory not found: $dir"
    fi
  done

  success "Backed up $count directories"
}

sync_files() {
  local -- source="$1" destination="$2"

  local -a rsync_args=('-av' '--progress' '--exclude' '.git/' '--exclude' '*.tmp')
  ((DRY_RUN)) && rsync_args+=('--dry-run')
  rsync_args+=("$source" "$destination")

  info 'Syncing files...'
  rsync "${rsync_args[@]}"
}

main() {
  while (($#)); do case $1 in
    -v|--verbose) VERBOSE=1 ;;
    -n|--dry-run) DRY_RUN=1 ;;
    *) die 22 "Invalid option: $1" ;;
  esac; shift; done

  readonly -- VERBOSE DRY_RUN

  process_directories
  sync_files "$HOME/data" '/backup/data'
}

main "$@"

#fin
```

**Anti-patterns:**

```bash
# ✗ Wrong - string list with word splitting / string concatenation for commands
files_str="file1.txt file2.txt file with spaces.txt"
for file in $files_str; do process "$file"; done
cmd_args="-o output.txt --verbose"
mycmd $cmd_args  # Word splitting issues

# ✓ Correct - array
declare -a files=('file1.txt' 'file2.txt' 'file with spaces.txt')
for file in "${files[@]}"; do process "$file"; done
declare -a cmd_args=('-o' 'output.txt' '--verbose')
mycmd "${cmd_args[@]}"

# ✗ Wrong - eval with string building
cmd="find $dir -name $pattern"
eval "$cmd"  # Dangerous!

# ✓ Correct - array construction
declare -a find_args=("$dir" '-name' "$pattern")
find "${find_args[@]}"

# ✗ Wrong - IFS manipulation / parsing ls output
IFS=','; for item in $csv_string; do echo "$item"; done; IFS=' '
files=$(ls *.txt); for file in $files; do process "$file"; done

# ✓ Correct - array from IFS split / glob into array
IFS=',' read -ra items <<< "$csv_string"
for item in "${items[@]}"; do echo "$item"; done
declare -a files=(*.txt)
for file in "${files[@]}"; do process "$file"; done

# ✗ Wrong - passing list as single string / unquoted array expansion
files="file1 file2 file3"
process_files "$files"
declare -a items=('a' 'b' 'c')
cmd ${items[@]}  # Word splitting!

# ✓ Correct - array elements as separate arguments / quoted expansion
declare -a files=('file1' 'file2' 'file3')
process_files "${files[@]}"
cmd "${items[@]}"
```

**Edge cases:**

```bash
# 1. Empty arrays - safe, zero iterations
declare -a empty=()
for item in "${empty[@]}"; do echo "$item"; done  # Never executes
process_items "${empty[@]}"  # Receives zero arguments

# 2. Arrays with special characters - all preserved
declare -a special=(
  'file with spaces.txt'
  'file"with"quotes.txt'
  'file$with$dollars.txt'
  'file*with*wildcards.txt'
  $'file\nwith\nnewlines.txt'
)
for file in "${special[@]}"; do echo "File: $file"; done

# 3. Merging arrays
declare -a arr1=('a' 'b') arr2=('c' 'd')
declare -a combined=("${arr1[@]}" "${arr2[@]}")
echo "Combined: ${#combined[@]} elements"  # 4 elements

# 4. Array slicing
declare -a numbers=(0 1 2 3 4 5 6 7 8 9)
declare -a subset=("${numbers[@]:2:4}")  # Elements 2-5
echo "${subset[@]}"  # Output: 2 3 4 5

# 5. Remove duplicates
remove_duplicates() {
  local -a input=("$@") output=()
  local -A seen=()
  local -- item

  for item in "${input[@]}"; do
    [[ ! -v seen[$item] ]] && { output+=("$item"); seen[$item]=1; }
  done

  printf '%s\n' "${output[@]}"
}

declare -a with_dupes=('a' 'b' 'a' 'c' 'b' 'd')
declare -a unique
readarray -t unique < <(remove_duplicates "${with_dupes[@]}")
echo "${unique[@]}"  # Output: a b c d
```

**Summary:**

- **Use arrays for all lists** - files, arguments, options, any collection
- **Arrays preserve element boundaries** - no word splitting or glob expansion
- **Safe command construction** - build in arrays, expand with `"${array[@]}"`
- **Dynamic building** - conditionally build and modify safely
- **Function arguments** - pass with `"${array[@]}"`, receive with `local -a arr=("$@")`
- **Never use string lists** - break with spaces, quotes, special characters
- **Always quote** - `"${array[@]}"` not `${array[@]}`

**Key principle:** Arrays are the safe way to handle lists in Bash. String-based lists inevitably fail with edge cases. Every list should be stored in an array and expanded with `"${array[@]}"`. This eliminates entire categories of bugs.
