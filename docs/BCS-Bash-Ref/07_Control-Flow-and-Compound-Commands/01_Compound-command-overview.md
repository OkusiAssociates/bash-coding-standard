<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.1 Compound command overview

A *compound command* is a single syntactic unit assembled from one or
more lower-level commands; bash defines exactly **ten** forms. Each
form has its own keywords, body, and exit-status rule, but all ten
share the property that the entire construct can be redirected,
piped, backgrounded, or used as the body of a function as if it were
a single simple command.

The ten forms are:

1. brace group — `{ list; }` (current shell, §7.9)
2. subshell — `( list )` (forked child, §7.8)
3. `if … then … [elif …] [else …] fi` (§7.2)
4. `case … in … esac` (§7.3)
5. `while list; do …; done` (§7.6)
6. `until list; do …; done` (§7.6)
7. `for name in words; do …; done` (§7.4)
8. `for (( init; cond; update )); do …; done` (§7.5)
9. `select name in words; do …; done` (§7.7)
10. arithmetic command `(( expr ))` (§7.5, §8.9)

Plus the *test* compound `[[ expr ]]` which is a reserved-word
construct rather than a compound command in the grammar's strict
sense, but which behaves like one and is grouped here for ease of
reference (§8.1).

### Properties shared by every form

```bash
# scenario: compound commands accept redirections, can be piped,
#           can be backgrounded, and can be a function body.
{ echo first; echo second; } > out.txt          # redirect the whole group (BCS0301)
for f in *.log; do gzip "$f"; done | wc -l      # pipe a for-loop's stdout
( cd /tmp && tar cf - . ) | ssh ok1 'cat > /backup/tmp.tar' &  # backgrounded subshell
process_dir() { for f in "$1"/*; do printf '%s\n' "$f"; done; }
```

Every compound command also carries an exit status:

- brace group, subshell, `if`/`else`, `for`, `while`, `until`,
  `select` → status of the **last** simple command executed
  inside the body (or 0 if the body was empty).
- `case` → status of the matched branch's last command, or 0 if no
  pattern matched.
- `(( expr ))` → 0 if `expr` is non-zero, 1 if `expr` is zero.
- `[[ expr ]]` → 0 if `expr` is true, 1 if false (2 on syntax error).

### Backreference: error-handling implications

The exit-status rule above interacts directly with `set -e`. A
compound command that ends in a deliberately failing test (e.g. a
`while` loop whose condition becomes false) yields a non-zero status
when used as a stand-alone statement, which under strict mode kills
the script. The standard fix is to terminate with `:`:

```bash
# scenario: prevent a while-read loop from tripping set -e
while read -r line; do
  printf '%s\n' "$line"
done < input.txt
:                                              # ⇒ status 0; loop exit value discarded (BCS0601)
```

**See also**: §7.2 `if`, §7.3 `case`, §7.4 `for x in list`, §7.5
C-style `for` and `(( ))`, §7.6 `while`/`until`, §7.7 `select`, §7.8
subshell grouping, §7.9 brace grouping, §7.10 `&&`/`||`
short-circuits, §7.11 `break`/`continue`, §7.13 `exit`, §8.1 `[[ ]]`
overview, §13.3 `errexit` exemption matrix, BCS0101 (strict mode),
BCS0501 (conditionals), BCS0503 (loops).

#fin
