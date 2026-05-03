<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.9 Pathname expansion (globbing)

After word splitting (§5.8), each word that contains unquoted glob
metacharacters is treated as a *pattern* and matched against
filenames in the working directory (or the directory implied by the
pattern's path component). The matched filenames replace the pattern.
Globbing is what makes `rm *.bak` work; it is also what makes a
mistyped command catastrophic when a filename happens to start with
`-`. This chapter is the structural reference; behavioural toggles
live in §5.11 and extended-glob operators in §5.12.

### Metacharacters

| Pattern | Matches |
|---------|---------|
| `*` | any string, including the empty string |
| `?` | exactly one character |
| `[abc]` | one character from the set |
| `[!abc]` or `[^abc]` | one character *not* in the set |
| `[a-z]` | one character in the range (locale-dependent — see §5.13) |
| `[[:class:]]` | one character of the named POSIX class (table below) |

The metacharacters are special only when *unquoted*. `'*.log'` is the
literal three characters; `*.log` is a pattern.

### POSIX character classes

Bracket expressions accept POSIX-named character classes, written as
`[[:class:]]` *inside* a bracket expression — the outer brackets are
the bracket expression, the inner `[:class:]` is the class.

| Class | Members |
|-------|---------|
| `[:alpha:]` | letters (A–Z, a–z under C locale; locale-extended otherwise) |
| `[:upper:]` | upper-case letters |
| `[:lower:]` | lower-case letters |
| `[:digit:]` | decimal digits 0–9 |
| `[:xdigit:]` | hexadecimal digits 0–9 a–f A–F |
| `[:alnum:]` | `[:alpha:]` + `[:digit:]` |
| `[:space:]` | whitespace (space, tab, newline, vertical tab, form feed, carriage return) |
| `[:blank:]` | space and tab only |
| `[:cntrl:]` | control characters |
| `[:print:]` | printable characters (including space) |
| `[:graph:]` | printable characters excluding space |
| `[:punct:]` | punctuation |

Use these in preference to ad-hoc ranges: `[[:alpha:]]` is correct
under any locale, whereas `[a-z]` may include accented characters under
some locales and miss them under others (§5.13 covers the locale
trap).

### Dotfile rule

By default, `*` and `?` do *not* match a leading `.` — dotfiles are
hidden from globs unless the pattern *itself* begins with `.`. This is
inherited from Unix shell tradition; it protects `rm *` from removing
`.bashrc`. The `dotglob` shopt overrides it (§5.11):

```bash
# scenario: dotglob behaviour, default vs enabled
ls -a /tmp/demo
# ⇒ . .. .hidden visible.txt

cd /tmp/demo
printf '[%s]\n' *           # ⇒ [visible.txt]   — dotfiles excluded
printf '[%s]\n' .*          # ⇒ [.] [..] [.hidden]   — explicit dot

shopt -s dotglob
printf '[%s]\n' *           # ⇒ [.hidden] [visible.txt]   — dotfiles included
                            #   but `.` and `..` still excluded (Bash 5.2+)
shopt -u dotglob
```

Bash 5.2 introduces `globskipdots` (on by default in many distros),
which excludes `.` and `..` from `*`/`?` matches even with `dotglob`
enabled. See §5.11 for the full toggle inventory.

### No-match behaviour

By default, when a glob matches no files, *the pattern itself is
passed through* unchanged — `for f in *.notexist` then iterates with
`f='*.notexist'`. This is almost always wrong. The fix is `nullglob`:

```bash
# scenario: nullglob makes empty matches yield zero arguments
shopt -s nullglob
declare -a logs=( /tmp/no-such-pattern-*.log )
echo "${#logs[@]}"          # ⇒ 0   — empty array

# Without nullglob:
shopt -u nullglob
declare -a logs2=( /tmp/no-such-pattern-*.log )
echo "${#logs2[@]}"         # ⇒ 1
echo "${logs2[0]}"          # ⇒ /tmp/no-such-pattern-*.log   — literal pattern
```

`nullglob` is the BCS-preferred behaviour (BCS0902, BCS0101 strict-mode
preamble enables it). For "this glob *must* match" semantics, use
`failglob` instead — it errors out on no-match (§5.11).

### Sort order

Matched filenames are sorted by `LC_COLLATE`. Under a UTF-8 locale,
this is *not* byte-order; under `C`/`POSIX`, it is. Scripts that
depend on a stable, predictable sort should set `LC_ALL=C` or sort
explicitly:

```bash
# scenario: stable sort regardless of user locale
LC_ALL=C
declare -a files=( *.txt )      # files now sorted by byte value
```

See §5.13 for the locale-collation pitfall in detail.

### Pattern matching outside pathname expansion

The same glob syntax is used in `[[ word == pattern ]]` (§8 conditional
expressions), `case` statements (§7.5), and the parameter-expansion
operators `#`, `##`, `%`, `%%`, `/`, `//` (§5.4). In those contexts the
pattern is *not* matched against filenames — it is matched against the
string. Pathname expansion does not occur there.

```bash
# scenario: glob-as-pattern in case and [[
declare -- name='report.tar.gz'
case "$name" in
  *.tar.gz|*.tgz) info 'gzip-tar archive' ;;
  *.zip)          info 'zip archive' ;;
  *)              info 'unknown' ;;
esac

[[ $name == *.tar.* ]] && info 'compressed tar'
```

The same `*.tar.gz` is used in three different contexts: as a filename
glob, as a `case` pattern, and as a `[[` operand. Behaviour is
identical *except* for filesystem matching.

**See also**: §5.8 (word splitting precedes pathname expansion), §5.11
(behavioural toggles — `nullglob`, `dotglob`, `failglob`, `globstar`),
§5.12 (extended-glob operators), §5.13 (locale and collation), §7.5
(`case` patterns), §8 (`[[ == ]]` pattern operands), BCS0902
(wildcard expansion safety), BCS0101 (strict-mode shopt set).

#fin
