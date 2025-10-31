## Array Expansions

**Always quote array expansions: `"${array[@]}"` for separate elements, `"${array[*]}"` for concatenated string.**

**Rationale:** Unquoted arrays undergo word splitting and glob expansion, breaking elements on whitespace/patterns. Quoted `[@]` preserves boundaries, empty elements, and special characters. Unquoted loses empty elements, splits on IFS, expands globs.

**Use `[@]` (separate):** Iteration, function/command args, array copying.
**Use `[*]` (single string):** Display, logging, CSV with custom IFS.

```bash
declare -a files=('file 1.txt' 'file 2.txt')

#  Iteration (3 elements preserved)
for file in "${files[@]}"; do
  echo "$file"
done

#  Unquoted splits on space (4 elements!)
for file in ${files[@]}; do echo "$file"; done
# Output: file, 1.txt, file, 2.txt

#  Concatenate with custom separator
IFS=','; csv="${files[*]}"  # file 1.txt,file 2.txt

#  Pass to function/command
process "${files[@]}"
grep pattern "${files[@]}"

#  Copy array
copy=("${files[@]}")
```

**Anti-patterns:**
- `${array[@]}` ’ word splitting/glob expansion
- `"${array[*]}"` in loops ’ single iteration
- Unquoted in assignments/function calls ’ lost boundaries

**Edge cases:** Empty arrays iterate zero times. Empty elements preserved only when quoted. Newlines/spaces in elements require quotes.

**Ref:** BCS0407
