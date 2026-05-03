<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 19.10 Builtins vs externals

A short list of frequent external→builtin replacements.

- `cat file` → `< file` for redirection, `$(<file)` for capture.
- `echo "$var"` → `printf '%s\n' "$var"`.
- `[ ]` → `[[ ]]`.
- `expr` arithmetic → `(( ))` or `$(( ))`.
- `basename file` → `${file##*/}`.
- `dirname file` → `${file%/*}`.
- `tr A-Z a-z` → `${var,,}`.
- `wc -l <<<"$multi"` → use array and `${#arr[@]}`.
- `head -n 1 file` → `read -r line < file`.
- `sleep 0.1` → no builtin equivalent; use external (or `read -t 0.1` with a closed fd as a hack).

#fin
