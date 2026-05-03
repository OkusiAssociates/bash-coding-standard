<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.8 Word splitting and IFS

Word splitting is the step in bash's expansion pipeline (§5.1) where
the *unquoted* results of parameter, command, and arithmetic expansion
are broken into multiple words on the characters in the `IFS`
variable. It is the single largest source of subtle bugs in
production bash scripts: a filename containing a space, a tab in
captured output, or a stray `*` can transform a one-argument command
into many or none. This chapter is the canonical reference for the
rule, the safe-IFS idiom, and the cardinal discipline that keeps
scripts correct.

### The rule in one sentence

After expansion, every result that *was not* inside double quotes is
re-tokenised by splitting on `IFS`. Quoted expansions (`"$var"`,
`"${arr[@]}"`, `"$(cmd)"`) are exempt and survive as a single word
each.

That sentence is the entire model. The rest is detail.

### Default IFS and the IFS-whitespace rule

The default value of `IFS` is the three characters space, tab,
newline. These three are *IFS-whitespace*; any other character used as
`IFS` is *IFS-non-whitespace*. The two classes split differently:

- **IFS-whitespace**: leading and trailing runs are stripped; interior
  runs collapse to a single separator. `'  a  b  '` → `a` `b` (two
  fields).
- **IFS-non-whitespace**: every separator delimits a field, including
  adjacent ones. `'a::b'` (with `IFS=:`) → `a`, ``, `b` (three fields,
  middle one empty).

```bash
# scenario: IFS-whitespace collapses; IFS-non-whitespace does not
IFS=' ' read -ra w <<< '  a  b  '
declare -p w               # ⇒ declare -a w=([0]="a" [1]="b")

IFS=':' read -ra n <<< 'a::b'
declare -p n               # ⇒ declare -a n=([0]="a" [1]="" [2]="b")
```

This asymmetry is deliberate — whitespace runs are usually formatting,
whereas a `:` (in `PATH`, `LD_LIBRARY_PATH`) is a real separator and
empty fields carry meaning.

### The safe-IFS idiom — `IFS=$'\t\n'`

The default `IFS` includes a literal space, which means *any* unquoted
expansion containing a space is silently re-split. The defensive
posture is to remove space from `IFS` for the script body, leaving
only tab and newline as separators. This is the BCS1003-mandated
discipline:

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
IFS=$'\t\n'                         # safe-IFS — drop space; keep tab and newline

# Now any unquoted file path or output containing spaces will not be
# silently torn apart on its spaces. Tabs and newlines are still active
# separators because real-world line- and column-oriented data needs them.
```

Place this assignment immediately after the strict-mode preamble.
Every BCS-compliant script does so (see BCS0101, BCS1003). The result
is that *forgetting* to quote becomes far less catastrophic — a missed
quote on a filename like `My Documents/notes.txt` no longer splits
into two arguments.

### Quoted vs unquoted — side by side

```bash
# scenario: quoting controls whether splitting happens at all
declare -- spaced='one two three'
declare -a items=('alpha beta' 'gamma' 'delta epsilon')

# Quoted — single argument
printf '[%s]\n' "$spaced"
# ⇒ [one two three]

# Unquoted — split on IFS (default)
printf '[%s]\n' $spaced
# ⇒ [one]
#    [two]
#    [three]

# Quoted array expansion — preserves element boundaries
printf '[%s]\n' "${items[@]}"
# ⇒ [alpha beta]
#    [gamma]
#    [delta epsilon]

# Unquoted array expansion — re-splits each element
printf '[%s]\n' ${items[@]}
# ⇒ [alpha]
#    [beta]
#    [gamma]
#    [delta]
#    [epsilon]
```

The rule: `"${arr[@]}"` is the only correct way to iterate an array
where any element might contain whitespace (BCS0206). The unquoted
form is broken by design.

### Per-command IFS

`IFS` can be set for one command only by placing the assignment on the
same line as the command. The shell restores the previous value
after:

```bash
# scenario: parse a colon-separated record without disturbing global IFS
declare -- record='alice:42:engineer:active'
IFS=':' read -ra fields <<< "$record"
declare -p fields
# ⇒ declare -a fields=([0]="alice" [1]="42" [2]="engineer" [3]="active")

# IFS is back to its previous value here.
```

This is the idiomatic way to parse `/etc/passwd`-style records, key=value
pairs, and any column-oriented input. `read -ra` honours the
per-command IFS without leaking the change.

### Splitting newline-delimited captures

The classic problem: capture command output into an array, one line
per element, where lines may contain spaces.

```bash
# scenario: read a process listing into an array, one line per element
declare -a procs
IFS=$'\n' read -d '' -ra procs < <(ps -eo comm=)

# Or — strongly preferred — use readarray (mapfile), which doesn't need IFS at all:
declare -a procs2
readarray -t procs2 < <(ps -eo comm=)
```

`readarray -t` (alias `mapfile -t`) is the BCS-preferred replacement
for the IFS-fiddling form: it reads line-delimited input directly into
an array with no IFS interaction, and `-t` strips the trailing newline
on each element.

### Unsetting IFS

Unsetting `IFS` does *not* disable splitting — bash falls back to the
default `space tab newline`. To truly suppress splitting for a block,
quote the expansions or save and restore IFS:

```bash
# scenario: save/restore IFS around a block that needs a different value
declare -- _saved_IFS=$IFS
IFS=':'
# … code that needs colon-splitting …
IFS=$_saved_IFS
```

Most code never needs this — the per-command `IFS=value cmd` form
covers the common case.

### Glob expansion of unquoted results

After word splitting, each resulting word that contains unquoted glob
metacharacters is filename-expanded (§5.9). This compounds the
splitting hazard: an unquoted `$var` containing `*.log` will not just
re-split — it will then expand against the working directory's files.
A two-stage hazard avoided by the same single rule: quote.

### The cardinal rule

> Always double-quote variable expansions, command substitutions, and
> array expansions, except in the rare cases where you specifically
> want word splitting or pathname expansion.

The rule is unconditional. Every leading bash style guide states it,
ShellCheck's SC2086 enforces it, and BCS1003 codifies it. A script
that never violates it is effectively immune to the entire word-
splitting bug class.

**See also**: §5.1 (the order of expansions — splitting comes after
expansion, before pathname matching), §5.4 (parameter expansion
produces the values that splitting then divides), §5.9 (pathname
expansion of split words), §10.x (`read` and `readarray` for
line-oriented capture), BCS0301 (quoting fundamentals), BCS1003
(IFS safety), BCS0206 (array expansion idioms), ShellCheck SC2086,
SC2068, SC2206.

#fin
