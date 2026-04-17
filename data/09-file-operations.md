# Section 09: File Operations

## BCS0900 Section Overview

Safe file testing, wildcard expansion, process substitution, here documents, and input redirection patterns to prevent common shell scripting pitfalls.

## BCS0901 Safe File Testing

**Tier:** core

Use `[[ ]]` for all file tests. Always include filenames in error messages for debugging.

```bash
# correct
[[ -f $file ]] || die 3 "Not found ${file@Q}"
[[ -f $file && -r $file ]] || die 5 "Cannot read ${file@Q}"
[[ -d $dir ]] || mkdir -p "$dir" || die 1 "Cannot create ${dir@Q}"
[[ -s $logfile ]] || warn 'Log file is empty'
[[ $source -nt $destination ]] && cp "$source" "$destination" ||:

# wrong
[ -f "$file" ]                       # old test syntax
```

## BCS0902 Wildcard Expansion

**Tier:** core

Always use explicit path prefix to prevent filenames starting with `-` from being interpreted as flags.

```bash
# correct
rm -v ./*
for file in ./*.txt; do
  process "$file"
done

# wrong — dangerous
rm -v *                              # file named -rf would be catastrophic
for file in *.txt; do                # less safe
```

## BCS0903 Process Substitution

**Tier:** core

Use `< <(command)` with while loops to avoid subshell variable scope issues.

```bash
# correct — variables preserved in current shell
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep 'pattern' "$file")

# correct — populate arrays
readarray -t lines < <(find . -name '*.txt')

# correct — compare outputs without temp files
diff <(sort "$file1") <(sort "$file2")

# correct — null-delimited for special filenames
while IFS= read -r -d '' file; do
  process "$file"
done < <(find /data -type f -print0)

# correct — tee for parallel output
tee >(grep ERROR > errors.txt) >(grep WARN > warnings.txt) < logfile

# wrong — pipe loses variables
command | while read -r line; do count+=1; done
```

## BCS0904 Here Documents

**Tier:** recommended

```bash
# correct — no expansion (quoted delimiter)
cat <<'EOF'
Variables like $HOME are not expanded.
EOF

# correct — with expansion (unquoted delimiter)
cat <<EOF
Hello $USER, home is $HOME
EOF
```

## BCS0905 Input Redirection

**Tier:** style

Use `$(< file)` instead of `$(cat file)` — 107x faster (zero process fork).

```bash
# correct
content=$(< "$file")
grep pattern < "$file"

# wrong — unnecessary cat
content=$(cat "$file")
cat "$file" | grep pattern
```

Use `cat` only when concatenating multiple files or using cat-specific options (`-n`, `-A`, `-b`).

## BCS0906 find Subshell Pitfalls

**Tier:** recommended

Piping `find` into a loop (`find ... | while read`) creates a subshell -- any variable set in the loop body is invisible to the parent. Use process substitution when state must escape the loop; use `-exec ... +` or built-in actions when no state is needed.

**Stateful iteration -- process substitution + null-delimited input:**

```bash
# correct — state persists; filenames with spaces/newlines handled safely
declare -i count=0
declare -a paths=()
while IFS= read -r -d '' f; do
  count+=1
  paths+=("$f")
done < <(find . -type f -print0)
info "Found $count files"
```

**Stateless batching -- `-exec ... +`** (one fork for N matches):

```bash
# correct — batches arguments; efficient
find . -name '*.log' -exec gzip {} +
find /tmp -type f -mtime +7 -exec rm -- {} +
```

**Stateless built-in actions** (preferred over `-exec` when available):

```bash
find . -name '*.tmp' -delete
find . -type d -empty -delete
```

**Anti-patterns:**

```bash
# wrong — subshell loses count
declare -i count=0
find . -name '*.log' | while read -r f; do
  count+=1
done
echo "$count"                            # always 0

# wrong — filenames with spaces/newlines break plain read
find . -type f | while read f; do        # should be -print0 + read -r -d ''
  process "$f"
done

# wrong — -exec ... \; forks once per match (slow, cannot aggregate)
find . -name '*.log' -exec gzip {} \;    # use + instead of \; when possible
```

Always pair `find -print0` with `read -r -d ''` so filenames containing spaces, tabs, or newlines are handled correctly.

Cross-references: BCS0411 (subshell return patterns), BCS0504 (process substitution in while loops), BCS0903 (process substitution generally).
