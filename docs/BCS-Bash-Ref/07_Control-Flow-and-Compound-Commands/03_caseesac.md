<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 7.3 `case`/`esac`

Pattern-based dispatch. Patterns are *globs*, not literals or regular
expressions. `case` is the right tool for any 3+ branch decision and
for option parsing; the `if/elif` cascade equivalent is harder to read
and slower (BCS0502, BCS0801).

### Syntax

```
case word in
  pattern1 [| pattern2 …]) list ;;
  pattern3) list ;;
  *) list ;;
esac
```

- Patterns are matched left-to-right; *first match wins*.
- `*)` as a final clause is the conventional default branch.
- Patterns are subject to glob expansion: `*`, `?`, `[…]`, plus the
  full extended-glob vocabulary if `extglob` is set.
- `nocasematch` shopt makes matches case-insensitive (a useful tool for
  `y|Y|yes|YES` reductions, BCS0502).

### Quoting on the pattern

Quoting is what distinguishes a pattern from a literal:

```bash
# scenario: matching a value literally vs as a pattern
case $x in
  $y)   echo 'matched: $y as a pattern' ;;        # ⇒ globs y's contents
  "$y") echo 'matched: $y as literal text' ;;     # ⇒ exact-string match
esac
```

This is rarely what users want for the pattern half of `case`; the
literal-quoted form is the standard for "match this exact value." The
discriminator (the `word` after `case`) does not need quoting in the
common case — `case` does not perform word splitting on it — but
quoting it never hurts.

### Branch terminators: `;;`, `;&`, `;;&`

Bash supports three branch terminators, two of them post-Bash-4.0
extensions to POSIX `case`:

| Terminator | Effect |
|------------|--------|
| `;;` | Exit `case` after this branch (the default). |
| `;&` | Fall through to the *next* branch unconditionally. The next branch's body runs without re-testing. |
| `;;&` | Fall through *and* re-evaluate: continue testing patterns from the next branch onward. |

The Bash-4.0 fall-through forms are useful but rare; most authors do
not encounter them and most code does not need them. Demonstrate:

```bash
# scenario: ;& runs the next body without re-matching
case $x in
  alpha) echo 'a' ;&                   # falls through unconditionally
  beta)  echo 'b' ;;
  gamma) echo 'g' ;;
esac
# x=alpha   ⇒ prints "a" then "b"
# x=beta    ⇒ prints "b"
# x=gamma   ⇒ prints "g"
```

```bash
# scenario: ;;& re-tests subsequent patterns
case $file in
  *.tar.gz) echo 'tarball' ;;&         # also try gzip pattern
  *.gz)     echo 'gzipped' ;;
esac
# file=foo.tar.gz   ⇒ prints "tarball" then "gzipped"
# file=foo.gz       ⇒ prints "gzipped"
```

Reach for `;;&` when categories overlap (a `*.tar.gz` is both a
tarball and a gzipped file). Reach for `;&` when one branch's logic is
genuinely a superset of the next; the more common refactor is to
extract a helper function and call it from each branch.

### Extended-glob patterns

With `shopt -s extglob` (BCS-bash §13.8), `case` patterns gain
alternation, negation, and grouping operators that make complex
matches readable:

```bash
# scenario: extglob alternation in case patterns
shopt -s extglob

case $arg in
  -h|--help)         show_help; exit 0 ;;
  -V|--version)      show_version; exit 0 ;;
  +([0-9]))          process_id "$arg" ;;     # one-or-more digits
  !(*.bak))          process_file "$arg" ;;   # any non-.bak filename
  *)                 die 22 "Unknown: $arg" ;;
esac
```

The `+(pat)`, `!(pat)`, `?(pat)`, `*(pat)`, `@(pat)` operators are
strict-mode bash's pattern primitives; they replace ad-hoc regex calls
to `[[ =~ ]]` for filename-shaped matching. The standard CLI parsing
pattern (BCS0801) is built almost entirely on this idiom plus
short-option bundling.

### Errexit interaction

`case` itself is not an errexit-exempt context. The bodies of branches
run with full errexit semantics; a branch that runs a command that
exits non-zero will terminate the script unless the branch wraps the
call (`cmd || true`, BCS0605). The discriminator is a parameter
expansion, not a command, so errexit does not apply to the matching
phase.

A `case` with no matching pattern exits `0`, not non-zero. There is no
"unmatched case" error and no implicit failure — silence is the
default. Always include an explicit `*)` clause whenever a missed
match would be a bug, with `die` or `warn` as appropriate. The
omitted-default `case` is one of the more common silent-failure modes
in bash scripts:

```bash
# wrong — no default; an unrecognised mode is silently ignored
case $mode in
  fast)     run_fast ;;
  thorough) run_thorough ;;
esac
# mode=anything-else: case exits 0, script continues with no work done

# right — unmatched value is fatal
case $mode in
  fast|f)         run_fast ;;
  thorough|t)     run_thorough ;;
  *)              die 22 "Unknown mode: ${mode@Q}" ;;
esac
```

**See also**: §7.2 (`if/elif/else/fi` for two-branch dispatch), §7.10
(AND-OR short-circuits), §15 (command-line processing and option
parsing), BCS0502, BCS0801.

#fin
