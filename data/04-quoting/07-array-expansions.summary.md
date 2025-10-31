## Array Expansions

**Always quote array expansions with double quotes to preserve element boundaries and prevent word splitting. Use `"${array[@]}"` for separate elements and `"${array[*]}"` for concatenated strings.**

**Rationale:**

- `"${array[@]}"` preserves each element as separate word regardless of content
- Unquoted arrays undergo word splitting on whitespace and glob expansion
- Quoted arrays preserve empty elements; unquoted arrays lose them
- Quoting ensures consistent behavior across different array contents

**Basic forms:**

**1. `[@]` - Separate words:**

```bash
declare -a files=('file1.txt' 'file 2.txt' 'file3.txt')

#  Correct - quoted (3 elements)
for file in "${files[@]}"; do
  echo "$file"
done

#  Wrong - unquoted (4 elements due to word splitting!)
for file in ${files[@]}; do
  echo "$file"
done
```

**2. `[*]` - Single string:**

```bash
declare -a words=('hello' 'world' 'foo' 'bar')

#  Single space-separated string
combined="${words[*]}"
echo "$combined"  # hello world foo bar

# Custom IFS
IFS=','
combined="${words[*]}"  # hello,world,foo,bar
```

**Use `[@]` for:**

```bash
# Iteration
for item in "${array[@]}"; do
  process "$item"
done

# Function/command arguments
my_function "${array[@]}"
grep pattern "${files[@]}"

# Building arrays
new_array=("${old_array[@]}" "additional" "elements")

# Copying
copy=("${original[@]}")
```

**Use `[*]` for:**

```bash
# Concatenating for output
echo "Items: ${array[*]}"

# Custom separator
IFS=','
csv="${array[*]}"

# String comparison
[[ "${array[*]}" == "one two three" ]]

# Logging
log "Processing: ${files[*]}"
```

**Complete examples:**

**1. Safe iteration:**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r VERSION='1.0.0'
#shellcheck disable=SC2155
declare -r SCRIPT_PATH=$(realpath -- "$0")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}

process_files() {
  local -a files=('document 1.txt' 'report (final).pdf' 'data-2024.csv')
  local -- file
  local -i count=0

  #  Quoted expansion
  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      ((count+=1))
    fi
  done
}

process_items() {
  local -a items=("$@")
  local -- item

  for item in "${items[@]}"; do
    info "Item: $item"
  done
}

main() {
  declare -a my_items=('item one' 'item two')
  process_items "${my_items[@]}"
}

main "$@"
#fin
```

**2. Array with custom IFS:**

```bash
create_csv() {
  local -a data=("$@")
  local -- csv old_ifs="$IFS"

  IFS=','
  csv="${data[*]}"
  IFS="$old_ifs"

  echo "$csv"
}

declare -a fields=('name' 'age' 'email')
csv_line=$(create_csv "${fields[@]}")
```

**3. Combining arrays:**

```bash
declare -a fruits=('apple' 'banana')
declare -a vegetables=('carrot' 'potato')

#  Combine arrays
declare -a all_items=("${fruits[@]}" "${vegetables[@]}")

# Add prefix
declare -a files=('report.txt' 'data.csv')
declare -a prefixed=()

for file in "${files[@]}"; do
  prefixed+=("/backup/$file")
done
```

**4. Array in commands:**

```bash
declare -a search_paths=('/usr/local/bin' '/usr/bin')

#  Each path is separate argument
find "${search_paths[@]}" -type f -name 'myapp'

# Multiple patterns
declare -a patterns=('error' 'warning' 'critical')
local -- pattern
local -a grep_args=()
for pattern in "${patterns[@]}"; do
  grep_args+=(-e "$pattern")
done

grep "${grep_args[@]}" logfile.txt
```

**5. Array contains check:**

```bash
array_contains() {
  local -- needle="$1"
  shift
  local -a haystack=("$@")
  local -- item

  for item in "${haystack[@]}"; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

declare -a allowed=('alice' 'bob')
array_contains 'bob' "${allowed[@]}" && info 'Authorized'
```

**Anti-patterns:**

```bash
#  Unquoted [@] - word splitting
declare -a files=('file 1.txt' 'file 2.txt')
for file in ${files[@]}; do  # Splits to: file, 1.txt, file, 2.txt
  echo "$file"
done

#  Correct
for file in "${files[@]}"; do
  echo "$file"
done

#  Unquoted in assignment - word splitting
copy=(${source[@]})

#  Correct
copy=("${source[@]}")

#  Using [*] for iteration - single loop!
for item in "${array[*]}"; do  # One iteration with all elements
  echo "$item"
done

#  Using [@] for iteration
for item in "${array[@]}"; do  # Separate iteration per element
  echo "$item"
done

#  Unquoted with globs - pathname expansion
declare -a patterns=('*.txt' '*.md')
for pattern in ${patterns[@]}; do  # Glob expands!
  echo "$pattern"
done

#  Quoted preserves literals
for pattern in "${patterns[@]}"; do
  echo "$pattern"
done
```

**Edge cases:**

**1. Empty arrays:**

```bash
declare -a empty=()

#  Safe (zero iterations)
for item in "${empty[@]}"; do
  echo "$item"  # Never executes
done

echo "${#empty[@]}"  # 0
```

**2. Arrays with empty elements:**

```bash
declare -a mixed=('first' '' 'third')

#  Quoted - preserves empty (3 iterations)
for item in "${mixed[@]}"; do
  echo "[$item]"  # [first], [], [third]
done

#  Unquoted - loses empty (2 iterations)
for item in ${mixed[@]}; do
  echo "[$item]"  # [first], [third]
done
```

**3. Arrays with newlines:**

```bash
declare -a data=('line one' $'line two\nline three' 'line four')

#  Quoted preserves newline
for item in "${data[@]}"; do
  echo "Item: $item"
done
```

**4. Associative arrays:**

```bash
declare -A config=([name]='myapp' [version]='1.0.0')

#  Iterate keys
for key in "${!config[@]}"; do
  echo "$key = ${config[$key]}"
done

#  Iterate values
for value in "${config[@]}"; do
  echo "$value"
done
```

**5. Array slicing:**

```bash
declare -a numbers=(0 1 2 3 4 5 6 7 8 9)

#  Quoted slice
subset=("${numbers[@]:2:4}")  # Elements 2-5
echo "${subset[@]}"  # 2 3 4 5

tail=("${numbers[@]:5}")
echo "${tail[@]}"  # 5 6 7 8 9
```

**6. Parameter expansion:**

```bash
declare -a paths=('/usr/bin' '/usr/local/bin')

# Remove prefix from all
basenames=("${paths[@]##*/}")  # bin bin

# Add suffix to all
declare -a configs=('app' 'db' 'cache')
config_files=("${configs[@]/%/.conf}")  # app.conf db.conf cache.conf
```

**Summary:**

- Always quote: `"${array[@]}"` or `"${array[*]}"`
- Use `[@]` for separate elements (iteration, functions, commands)
- Use `[*]` for concatenated string (display, logging, CSV)
- Unquoted arrays undergo word splitting and glob expansion
- Empty elements preserved only with quoted expansion
- `"${array[@]}"` is the standard safe form

**Key principle:** Array quoting is non-negotiable. `"${array[@]}"` maintains element boundaries. Any unquoted expansion introduces word splitting and glob bugs. Use `"${array[*]}"` only when explicitly needing a single concatenated string.
