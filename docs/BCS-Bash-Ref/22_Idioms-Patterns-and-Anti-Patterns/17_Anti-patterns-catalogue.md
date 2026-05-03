<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.17 Anti-patterns catalogue

Patterns that appear in legacy code and should not be perpetuated.

- `[ $var = "x" ]` — unsafe; use `[[ $var == x ]]`.
- `for f in $(ls)` — breaks on filenames with spaces; use a glob or `find -print0 | mapfile`.
- `cmd > file 2>&1` vs `cmd 2>&1 > file` — order matters; the second is wrong if you intend both to go to the file.
- `((count++))` under `set -e` with `count=0` — the post-increment returns 0, triggering errexit; use `count+=1` or `((++count))`.
- `cmd | while read line; do …; done` — loop runs in subshell; outer scope unaffected; use `< <(cmd)` or `lastpipe`.
- `command -v cmd >/dev/null` — correct; `which cmd` — wrong, varies across systems and produces output even when not found.
- `eval "$user_input"` — direct injection; never.
- `` `cmd` `` (backticks) — deprecated; use `$(cmd)`.
- `[ a = "$b" ]` — unsafe if `$b` contains `-` or `=`; use `[[ ]]`.
- `read line` (no `-r`) — interprets backslash; use `read -r`.
- `IFS=… ; cmd ; IFS=…` — leaks if `cmd` exits early; scope IFS in a subshell or restore in trap.
- `if [ $? -eq 0 ]` — racy; use `if cmd; then …`.
- `local file=$(cmd)` — `local` is a builtin returning 0, masking `$(cmd)`'s exit; declare and assign separately.
- `echo -e "..."` — non-portable; use `printf '%b\n'` or `$'...'`.
- `cd $dir && cmd` — fails open if `cd` fails; use `cd "$dir" || die`.
- `cat file | wc -l` — useless cat; `wc -l < file` or `wc -l file`.
- `function name()` — redundant `function` keyword; just `name()`.
- `${1}` everywhere when `$1` would do — but `${var}foo` *does* need braces.
- `if grep -q pattern file; then` — fine, but `if [[ $(grep -c pattern file) -gt 0 ]]` — wasteful; the first form is right.

#fin
