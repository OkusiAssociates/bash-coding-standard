<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.1 Order of expansions

The canonical sequence Bash performs between reading a command and
calling `execve`. Memorise this order — the rest of Part V is one
chapter per phase, in this order, and almost every expansion bug
reduces to "I expected phase *N* to run before phase *M*".

### The eight phases (plus quote removal)

1. **Brace expansion** (§5.2) — purely textual; cannot see variables.
2. **Tilde expansion** (§5.3) — `~` / `~user` to home directories.
3. **Parameter and variable expansion** (§5.4) — `${var}`, all
   default/slice/edit operators.
4. **Arithmetic expansion** (§5.5) — `$(( expr ))`.
5. **Command substitution** (§5.6) — `$(cmd)`.
6. **Process substitution** (§5.7) — `<(cmd)`, `>(cmd)`. (Bash extends
   the POSIX list with this phase.)
7. **Word splitting** (§5.8) — splits *unquoted* results on `IFS`.
8. **Pathname expansion** (§5.9) — globbing of *unquoted* results.

Plus the implicit final step:

9. **Quote removal** (§5.10) — strips user-supplied quote characters.

Phases 3 and 4 (and 5 and 6) overlap in practice: parameter, command,
and arithmetic expansion are interleaved in left-to-right order on a
single token. The orders given here are the *categories*; within a
single token Bash applies them in the order they appear.

### Worked walkthrough — one command, all phases

Trace `cp ~/{src,dst}/file_$i_*.txt /tmp/$out` after the user has run
`i=2; out='b u'; touch /tmp/file_2_a.txt /tmp/file_2_b.txt`:

```bash
# scenario: trace a single command through every expansion phase
declare -i i=2
declare -- out='b u'
mkdir -p ~/src ~/dst
touch ~/src/file_2_a.txt ~/src/file_2_b.txt

set -x   # show what bash actually executes (§19.5)
cp ~/{src,dst}/file_${i}_*.txt /tmp/$out
set +x
```

Phase-by-phase rewrite of the single argument list:

| Phase                      | Token after this phase |
|----------------------------|------------------------|
| 0. literal                 | `cp ~/{src,dst}/file_${i}_*.txt /tmp/$out` |
| 1. brace                   | `cp ~/src/file_${i}_*.txt ~/dst/file_${i}_*.txt /tmp/$out` |
| 2. tilde                   | `cp /home/u/src/file_${i}_*.txt /home/u/dst/file_${i}_*.txt /tmp/$out` |
| 3. parameter               | `cp /home/u/src/file_2_*.txt /home/u/dst/file_2_*.txt /tmp/b u` |
| 4–6. arith / cmd / proc    | (no operators present here)                          |
| 7. word splitting          | `cp /home/u/src/file_2_*.txt /home/u/dst/file_2_*.txt /tmp/b u` (the `b u` token splits into `b` and `u`) |
| 8. pathname                | `cp /home/u/src/file_2_a.txt /home/u/src/file_2_b.txt /home/u/dst/file_2_*.txt /tmp/b u` (left side globs; right side has no matches and stays literal under default `nullglob`-off, becomes empty under `nullglob`) |
| 9. quote removal           | (none — nothing was quoted by the user)            |

The command then runs with five separate arguments — *not* the four
the author may have intended. Two issues fall out:

- The trailing `$out` containing a space splits at phase 7. Quoting
  (`"/tmp/$out"`) suppresses splitting and pathname expansion both —
  this is the BCS rule (BCS0301).
- The `~/dst/...` glob found no matches. Default behaviour leaves the
  unmatched pattern literal; with `shopt -s nullglob` it disappears,
  changing the argument count again (§5.9, §5.11).

### What quoting suppresses, and from which phase

Quoting (`"…"` or `'…'`) is the *only* mechanism that disables phases
**7 (word splitting)** and **8 (pathname expansion)** for a token.
Single-quotes additionally disable phases 3–6. Quoting does not
disable phase 1 (brace) — `"{a,b}"` is two literal characters and a
literal comma. Quoting also does not affect phase 2 (tilde) at the
*start* of a token in assignment or default-expansion context, but
does suppress it everywhere else.

### BCS posture

- Quote every parameter expansion in a word context (BCS0301).
- Use `shopt -s nullglob` so an unmatched glob produces zero
  arguments, not the literal pattern (BCS0101, §5.11).
- Avoid building filenames by interpolating untrusted strings into a
  glob pattern — IFS and pathname expansion will do unexpected things
  (BCS1003, BCS1005).

**See also**: §5.2–§5.13 (each phase in order), §5.4 (parameter
expansion), §5.8 (word splitting and IFS), §5.11 (`nullglob`,
`failglob`), §19.5 (`set -x`).

#fin
