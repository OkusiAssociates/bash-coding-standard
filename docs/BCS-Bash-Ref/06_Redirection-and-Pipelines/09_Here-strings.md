<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.9 Here-strings (`<<<`)

`<<<` is the single-line variant of a here-document: it supplies its
right-hand operand as stdin to the command, with one trailing newline
appended. It is faster, clearer, and avoids the subshell of an `echo |
cmd` pipeline — making it the preferred mechanism for short string
inputs to commands that read stdin.

### Forms

- `cmd <<<word` — *word* (undergoes the usual expansions) becomes
  stdin, with one `\n` appended.
- `cmd <<<"$var"` — quoted-expansion form; preserves embedded
  whitespace and special characters in *var*.
- `cmd <<<"$(producer)"` — command-substitution feed.

The right-hand side is a *word*, not a list of arguments — multi-line
content via `<<<` requires literal `$'\n'` escapes or a here-doc.

### Trailing-newline gotcha

Bash always appends one newline to the here-string contents. This is
why `read -r var <<<"$line"` works correctly — `read` needs a newline
to terminate the line — but it also means the byte count is
*one greater* than `${#line}`:

```bash
# scenario: trace the trailing-newline behaviour of `<<<` byte by byte
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- text='abc'
declare -i n
n=$(wc -c <<<"$text")
echo "wc -c counted: $n"        # ⇒ 4   (3 body + 1 appended \n)

# Compare to printf without %s\n — no trailing newline
n=$(printf %s "$text" | wc -c)
echo "printf %s counted: $n"    # ⇒ 3
```

Most tools (`grep`, `awk`, `sed`, `tr`) treat the trailing newline as a
record terminator and so behave identically with both. Tools that count
bytes precisely (`wc -c`, `md5sum`, `sha256sum`) do *not*; account for
the extra byte when computing checksums of variable contents.

### `read -r var <<<` idiom

The most common use of `<<<` is single-line `read`. The newline that
terminates the read is exactly the one bash appends — no `printf`,
`echo`, or pipe is needed:

```bash
# scenario: split a colon-delimited string into named fields with `read`
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- record='42:Biksu:admin:/home/biksu'
declare -- uid name role home

IFS=: read -r uid name role home <<<"$record"

printf 'uid=%s name=%s role=%s home=%s\n' "$uid" "$name" "$role" "$home"
# ⇒ uid=42 name=Biksu role=admin home=/home/biksu
```

This is faster and clearer than the `echo` pipe alternative
(`echo "$record" | IFS=: read …`) and avoids the lastpipe / subshell
trap that the pipe form falls into (§6.16).

### When `<<<` is wrong

- Multi-line content: use `<<EOF` or `<<-'EOF'` instead.
- Binary content: `<<<` will mangle anything that needs the trailing
  newline absent; pipe from `printf '%b'` or use process substitution.
- Very large strings: the implementation copies the entire word into a
  temp file or pipe; for hundreds of KB or more, prefer a real file.

**See also**: §6.8 (here-documents), §5.6 (command substitution
trailing-newline strip), §3.4 (BCS0304 here-doc quoting), §10.x
(`read -r` patterns).

#fin
