## Arrays for Safe List Handling

**Use arrays to store lists of elements safelyarrays preserve element boundaries regardless of content (spaces, special chars, wildcards).**

**Rationale:**
- Arrays eliminate word splitting/glob expansion bugs inherent in string-based lists
- Safe command construction with arbitrary arguments containing spaces/special chars
- Each element processed exactly once during iteration

**Anti-pattern:** String lists fail with spaces:
```bash
#  files_str="file1.txt file with spaces.txt"
# for file in $files_str; do ... done  # 4 iterations, not 2!
```

**Core pattern:**
```bash
#  Array declaration and safe usage
declare -a files=(
  'file1.txt'
  'file with spaces.txt'
)

# Safe iteration
for file in "${files[@]}"; do
  process "$file"
done

# Safe command construction
declare -a cmd=('myapp' '--output' "$file")
((verbose)) && cmd+=('--verbose')
"${cmd[@]}"  # Executes with proper boundaries
```

**Key anti-patterns:**
- `files_str="a b c"; cmd $files_str` ’ Use `declare -a files=('a' 'b' 'c'); cmd "${files[@]}"`
- `cmd_args="-o file"; mycmd $cmd_args` ’ Use `declare -a args=('-o' 'file'); mycmd "${args[@]}"`
- `$(ls *.txt)` ’ Use `declare -a files=(*.txt)`
- `${array[@]}` unquoted ’ Always `"${array[@]}"`

**Summary:** Arrays are mandatory for all lists (files, arguments, options). String-based lists inevitably fail with edge cases. Always expand with `"${array[@]}"` (quoted).

**Ref:** BCS0502
