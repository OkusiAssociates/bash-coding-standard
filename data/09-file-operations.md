# Section 09: File Operations

## BCS0900 Section Overview

Safe file testing, wildcard expansion, process substitution, here documents, and input redirection patterns to prevent common shell scripting pitfalls.

## BCS0901 Safe File Testing

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
