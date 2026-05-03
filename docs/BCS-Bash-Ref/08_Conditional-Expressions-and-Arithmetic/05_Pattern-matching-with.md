<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.5 Pattern matching with `==`

Inside `[[ ]]`, the right-hand side of `==` (or its synonym `=`) and `!=` is a *glob pattern* unless quoted. Quoting any portion of the RHS demotes that portion to a literal — partial quoting is legal and semantically meaningful: `[[ $f == prefix.* ]]` and `[[ $f == "prefix".* ]]` both match files whose name starts with `prefix.` and continues with anything; `[[ $f == "prefix.*" ]]` matches the eight-character string `prefix.*` only.

### Pattern syntax

The pattern grammar is identical to pathname expansion (§5.9):

- `*` — zero or more of any character
- `?` — exactly one of any character
- `[abc]` — one character from the set; `[a-z]` for ranges
- `[!abc]` or `[^abc]` — one character *not* in the set

`shopt -s nocasematch` makes pattern matching case-insensitive — useful for command-line argument parsing where users may type `Yes`, `YES`, or `yes`.

### Extended globs

Extended-glob patterns (§5.12) become available when `shopt -s extglob` is active:

- `?(p)` — zero or one occurrence of `p`
- `*(p)` — zero or more occurrences of `p`
- `+(p)` — one or more occurrences of `p`
- `@(p)` — exactly one occurrence of `p`
- `!(p)` — anything *except* `p`

The shopt is required at *parse time* of the surrounding script, not just at evaluation time. Set it once near the top of every script that uses extglob inside `[[ ]]`.

### Examples

```bash
# scenario: glob vs literal — quoting flips the meaning.
declare -- name='*.sh'
[[ $name == *.sh ]]   && echo 'glob: any .sh name'    # ⇒ glob: any .sh name
[[ $name == "*.sh" ]] && echo 'literal: that string'  # ⇒ literal: that string
```

The first test asks "does the value end in `.sh`?" — true for `script.sh`, `build.sh`, and the literal string `*.sh` itself. The second asks "is the value the literal `*.sh`?" — true only for that exact eight-character string.

```bash
# scenario: extglob alternation for cheap dispatch (replaces a 3-arm case).
shopt -s extglob
declare -- mode='maybe'
[[ $mode == @(yes|no|maybe) ]]  && echo 'recognised'  # ⇒ recognised
[[ $mode == !(yes|no|maybe) ]]  || echo 'in-set'      # ⇒ in-set
[[ $mode == ?(y|n)es ]]         || echo 'not yes/nes' # ⇒ not yes/nes
```

Without `shopt -s extglob`, `@(yes|no|maybe)` is parsed as a plain glob — the `@` matches a literal `@`, the parentheses become subshell tokens (or syntax errors, depending on context), and the test silently fails. Extglob is invisible in error output, so the missing shopt is one of the more frustrating bugs to diagnose.

For static-string comparison, prefer plain `==` with a quoted RHS or no metacharacters at all: `[[ $mode == 'production' ]]`. Reserve glob patterns for the cases where they earn their keep — file-extension dispatch, prefix/suffix tests, character-class validation.

**See also**: §5.9 (pathname expansion), §5.12 (extglob), §7.4 (`case`), §8.6 (regex alternative), BCS0303, BCS0502.

#fin
