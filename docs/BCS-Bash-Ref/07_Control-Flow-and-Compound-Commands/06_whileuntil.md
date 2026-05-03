<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.6 `while`/`until`

Loop while (or until) a condition holds. Like `if`, both forms test an
*exit status* — they are command dispatchers, not boolean predicates.
`while` runs the body as long as the condition list's last command
exits `0`; `until` is its inverse, running while the condition exits
non-zero.

### Syntax

```
while list; do list; done
until list; do list; done
```

The condition is the exit status of the *last command* in the
condition list, evaluated before each iteration. The condition list is
errexit-exempt (§13.3) — a non-zero status is the loop's termination
signal, not a fatal error.

Idiomatic infinite loops:

```bash
while :; do …; done                  # always-true via the null builtin
while true; do …; done               # equivalent; reads more naturally
for ((;;)); do …; done               # arithmetic equivalent (§7.5)
```

`:` is a builtin that always exits `0`; `true` is a separate builtin
with the same behaviour. The two are interchangeable in a loop
condition.

### The canonical `read -r` idiom

The `while read -r` loop is bash's primary line-oriented input
construct:

```bash
# scenario: read every line of a file, preserving whitespace and backslashes
while IFS= read -r line; do
  process_line "$line"
done < "$input_file"
```

The three pieces matter:

- `IFS=` (empty) — disables word splitting on the read so leading and
  trailing whitespace is preserved.
- `read -r` — disables backslash escaping; the line is taken
  verbatim. Without `-r`, `\<newline>` and `\<char>` are reinterpreted.
- `< "$input_file"` — redirection on `done`, attaching the file to the
  loop's stdin. The loop runs in the *current shell*; assignments and
  variables persist after the loop exits.

If `process_line` itself reads from stdin, redirect from `&3` to keep
your two streams separate (BCS0903): `while …; do process_line <&3;
done 3< "$input"`.

### The subshell pitfall — and the fix

Piping into a `while` loop runs the loop in a *subshell*, because
every component of a pipeline is a separate process. Variables set
inside the loop vanish when the loop ends:

```bash
# wrong — loop runs in a subshell; count is reset on exit
declare -i count=0
grep -c 'pattern' files/* | while IFS= read -r line; do
  count+=1                           # mutates the subshell's count
done
echo "count=$count"                  # ⇒ count=0 (parent never saw the increments)
```

The two standard fixes are *process substitution* (BCS0504, BCS0903)
and the *`lastpipe`* shopt:

```bash
# right — process substitution attaches a fd; loop runs in current shell
declare -i count=0
while IFS= read -r line; do
  count+=1
done < <(grep -c 'pattern' files/*)
echo "count=$count"                  # ⇒ count=N
```

```bash
# alternative — lastpipe runs the rightmost pipeline element in the current shell
shopt -s lastpipe
set +m                               # required: lastpipe needs job control off

declare -i count=0
grep -c 'pattern' files/* | while IFS= read -r line; do
  count+=1
done
echo "count=$count"                  # ⇒ count=N
```

Process substitution is the standard solution and works in any script;
`lastpipe` is a global flag with broader effects (every pipeline's
last stage runs in-shell), and it requires job control off, which is
default for non-interactive scripts but worth confirming. Both
mechanisms keep the loop's mutations visible to the surrounding scope.

### `until` — the inverse of `while`

`until cmd` is `while ! cmd`. It reads naturally for "wait for X to
become true" patterns:

```bash
# scenario: poll until the service responds
declare -i tries=0
until curl -fsSL "$url" > /dev/null 2>&1; do
  tries+=1
  ((tries >= 30)) && die 24 'service did not become ready'
  sleep 1
done
```

Most authors prefer `while ! cmd` for symmetry with the `while` family
and skip `until` entirely; both forms are acceptable.

**See also**: §7.4 (`for x in list`), §7.5 (C-style `for`), §7.11
(`break`/`continue`), §6.16 (`lastpipe`), §13.3 (errexit and
conditions), BCS0503, BCS0504, BCS0903.

#fin
