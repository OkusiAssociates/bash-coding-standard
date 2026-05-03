<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 3.6 Double quotes

Double quotes are the workhorse of safe shell programming. They
preserve most characters literally while allowing parameter
expansion, command substitution, and arithmetic expansion — and,
crucially, they suppress word splitting and pathname expansion on the
results. Read every `"$var"` in a Bash script as "this expansion is
exactly one argument, no matter what".

### What is preserved, what is allowed

Inside `"…"`:

- **Allowed to expand:** `$var`, `${var…}`, `$(…)`, `` `…` ``, `$(( ))`.
- **Backslash escapes only these:** `\$`, `` \` ``, `\"`, `\\`, and a
  literal newline (`\<newline>` is line continuation). Every other
  backslash is preserved literally — `"\n"` is a backslash followed
  by an `n`, not a newline. Use `$'\n'` (§3.7) or `printf` for that.
- **`!` is special only in interactive shells** (history expansion). In
  scripts under `set -o`, history is off and `!` is literal.
- **Word splitting and pathname expansion are *not* applied** to the
  expanded result. This is the entire reason for the `"$var"`
  discipline — it converts a multi-word, glob-prone expansion into a
  single, opaque argument.

### The cardinal `"$@"` versus `"$*"` distinction

Both expand to the positional parameters, but the two are not
interchangeable. In a quoted context:

| Form | Result | Use when |
|------|--------|----------|
| `"$@"` | Each positional becomes its own argument: `"$1" "$2" "$3" …` | Forwarding arguments verbatim — almost always. |
| `"$*"` | Positionals joined by the **first character of `IFS`** into one argument: `"$1c$2c$3"` (default `c=' '`). | Building a single display string. |

Unquoted `$@` and `$*` both word-split, so the contents of any
positional containing whitespace will fragment. Always use `"$@"`
unless you have a specific reason for the joined form.

### Worked example: `"$@"` versus `"$*"`

```bash
#!/usr/bin/env bash
# scenario: pass three arguments, one with spaces, and observe the difference.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

set -- 'one' 'two words' 'three'

printf '"$@" form:\n'
for x in "$@"; do printf '  [%s]\n' "$x"; done

printf '"$*" form:\n'
for x in "$*"; do printf '  [%s]\n' "$x"; done

# ⇒ "$@" form:
# ⇒   [one]
# ⇒   [two words]
# ⇒   [three]
# ⇒ "$*" form:
# ⇒   [one two words three]
```

`"$@"` produces three arguments to the loop; `"$*"` produces one.
Forward arguments to a wrapped command with `cmd "$@"`; build a log
line with `printf '%s\n' "args=$*"`.

### Worked example: backslash inside `"…"` is mostly literal

```bash
# scenario: show which backslash sequences the quoting honours.
printf '%s\n' "a\\b"     # ⇒ a\b   (\\ → \)
printf '%s\n' "a\nb"     # ⇒ a\nb  (\n is NOT a newline here)
printf '%s\n' "a\$b"     # ⇒ a$b   (\$ → $)
printf '%b\n' "a\nb"     # ⇒ a
                          #     b   (printf %b honours \n itself)
```

The interpretation of `\n` is `printf`'s job, not the quoting
mechanism's. Inside `"…"`, `\n` is two characters; pass it to
`printf '%b'`, or use `$'\n'` (§3.7) to embed an actual newline at
quote-parse time.

### Adjacency: concatenation without `+`

Bash has no string concatenation operator. Adjacent quoted and
unquoted runs are concatenated by lexical position:

```bash
declare -- name='alice' ext='log'
declare -- file="/var/log/$name"'.bak.'"$ext"
printf '%s\n' "$file"
# ⇒ /var/log/alice.bak.log
```

The quotes can switch back and forth on every character; the parser
treats the whole word as one token. This pattern is occasionally
useful when a literal `'` must sit beside an expansion: `"prefix"'…'"$x"`.

### `"$@"` in function forwarding

The most common use of `"$@"` is the wrapper-function pattern:

```bash
# scenario: forward all arguments to an inner command unchanged.
run_with_logging() {
  local -- log='/var/log/wrap.log'
  printf '[%s] %s\n' "$(date -Is)" "$*" >>"$log"
  command -- "$@"
}
```

`"$*"` is fine for the human-readable log line because it is one
joined string. `"$@"` is mandatory for the actual call so that an
argument like `'two words'` reaches the inner command as a single
parameter. Reversing them is silent breakage that only surfaces on
input the test cases never tried.

### Empty-array edge case

When the positional list is empty, `"$@"` expands to **zero**
arguments — not one empty string. This matters because a wrapper
that does `cmd "$@"` with no args calls `cmd` with no args, exactly
as the user invoked the wrapper. By contrast, an array `"${arr[@]}"`
behaves identically. This zero-argument behaviour is special-cased in
the standard and is one of the small set of POSIX-compliant
behaviours retained by Bash.

### Strict-mode note

Under `set -u`, expansions like `"${var:-}"` give a controlled empty
default and never trigger an unset error. Bare `"$var"` does, which
is usually what you want — quoting protects word boundaries; `:-`
protects against unset. They are orthogonal disciplines.

**See also**: §3.4 (quoting overview), §3.7 (ANSI-C quoting), §3.9
(backslash escapes), §5.7 (parameter expansion), BCS0301, BCS0303.

#fin
