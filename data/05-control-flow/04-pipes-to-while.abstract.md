## Pipes to While Loops

**Never pipe to `while` loopspipes create subshells where variable changes are lost. Use `< <(command)` or `readarray` instead.**

**Rationale:** Pipes create subshells; variables modified inside don't persist outsidecounters stay 0, arrays stay empty, no errors shown.

**Pattern:**

```bash
#  Wrong - variables lost
count=0
echo -e "a\nb\nc" | while read -r x; do ((count+=1)); done
echo "$count"  # 0 (lost!)

#  Correct - process substitution
count=0
while read -r x; do ((count+=1)); done < <(echo -e "a\nb\nc")
echo "$count"  # 3

#  Correct - readarray for line collection
readarray -t lines < <(echo -e "a\nb\nc")
echo "${#lines[@]}"  # 3
```

**Examples:**

```bash
# Counter accumulation
while read -r line; do ((count+=1)); done < <(grep ERROR log)

# Array building
while read -r file; do files+=("$file"); done < <(find /data -type f)

# Readarray (simpler)
readarray -t users < <(cut -d: -f1 /etc/passwd)

# Null-delimited (safe for filenames)
readarray -d '' -t files < <(find /data -print0)
```

**Anti-pattern:**

```bash
#  All variable changes lost in subshell
cat file | while read -r line; do
  ((count+=1))
  array+=("$line")
done
# count=0, array=() - both lost!
```

**Ref:** BCS0704
