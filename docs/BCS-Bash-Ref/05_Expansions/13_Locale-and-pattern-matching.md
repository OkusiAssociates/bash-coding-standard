<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.13 Locale and pattern matching

Locale settings reach deep into Bash's text-handling: glob ranges,
`[[:class:]]` POSIX classes, regex matching, and `[[ ]]` string
comparison all consult the user's `LC_*` variables. The single
biggest surprise is that `[a-z]` is **not** the 26 ASCII lowercase
letters under most modern locales — it is the locale-collated *range*
between `a` and `z`, which interleaves uppercase, accented, and
combining characters. Parsing-heavy scripts must defend against this.

### The LC_* variables that matter

| Variable | Affects |
|----------|---------|
| `LC_COLLATE` | Sort/range order for `[a-z]`, `sort`, `[[ a < b ]]` |
| `LC_CTYPE`   | `[[:alpha:]]`, `[[:upper:]]`, character class membership |
| `LC_NUMERIC` | Decimal point: `1.5` vs `1,5` (rarely a Bash issue) |
| `LC_TIME`    | `printf '%(…)T'`, `date` formatting (§14.4) |
| `LC_MESSAGES`| Diagnostic strings (`bash: …: not found`) |
| `LC_ALL`     | **Overrides every** `LC_*` variable when set |
| `LANG`       | Fallback when an `LC_*` is unset |

`LC_ALL=C` (or `LC_ALL=POSIX`) collapses the entire locale to bytewise
ASCII semantics: `[a-z]` is exactly 26 characters, `[[:alpha:]]`
recognises ASCII letters only, and sort/range order is byte order.

### The `[a-z]` collation gotcha

```bash
# scenario: range glob behaviour under different locales
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# C locale — pure ASCII, predictable
LC_ALL=C
[[ A == [a-z] ]] && echo 'C: A in [a-z]' || echo 'C: A not in [a-z]'
# ⇒ C: A not in [a-z]

# en_US.UTF-8 — collation interleaves cases for "dictionary order"
LC_ALL=en_US.UTF-8
[[ A == [a-z] ]] && echo 'en_US: A in [a-z]' || echo 'en_US: A not in [a-z]'
# ⇒ en_US: A in [a-z]   (under most glibc UTF-8 locales)
# ⇒ (depends on libc; some return "not in")
```

The defence is **`shopt -s globasciiranges`** (default on since Bash
4.3, reaffirmed in 5.x) which forces `[a-z]` and `[A-Z]` in glob
*patterns* to ASCII C-locale ordering even when `LC_COLLATE` says
otherwise. The shopt does **not** affect `[[ str =~ re ]]` regex
matching — that is delegated to the C-library regex routines, which
read `LC_COLLATE` and `LC_CTYPE` directly.

```bash
# scenario: prefer named POSIX classes over [a-z] range
shopt -s globasciiranges            # confirm the default

# Ambiguous (depends on shopt + locale):
[[ name == [a-z]* ]]

# Unambiguous, locale-independent in the usual sense:
[[ name == [[:lower:]]* ]]          # locale-aware "lowercase"

# Bytewise ASCII, regardless of locale:
LC_ALL=C [[ name == [a-z]* ]]
```

### When to force `LC_ALL=C`

For *parsing* hashes, protocol fields, log lines, base64, hex,
filenames-with-bytes — anything where byte-exact matching is required
— set `LC_ALL=C` at the top of the script (or per-command):

```bash
# scenario: byte-safe parsing pipeline — the BCS pattern
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Pin locale once; affects every child too (BCS1003-adjacent — IFS-style)
export LC_ALL=C

# Now [[:xdigit:]] is exactly [0-9A-Fa-f], sort is bytewise, etc.
declare -- sha
sha=$(sha256sum < /etc/hostname)
[[ $sha =~ ^([[:xdigit:]]{64})\  ]] && printf 'hash=%s\n' "${BASH_REMATCH[1]}"

# Per-command override when only one fork needs C-locale semantics:
LC_ALL=C sort -u < /var/log/something | head -3
```

### Class compatibility

POSIX character classes inside `[[ ]]` and `[[:class:]]` glob
brackets are honoured under any locale; their *contents* vary by
`LC_CTYPE`:

- `[[:alpha:]]` — under C locale, `a-zA-Z`. Under UTF-8 locales,
  every Unicode letter.
- `[[:digit:]]` — under C locale, `0-9`. Under UTF-8, may include
  Devanagari, Thai, etc. digits.
- `[[:space:]]`, `[[:upper:]]`, `[[:lower:]]`, `[[:xdigit:]]` —
  similar locale-dependence.
- `[[:print:]]`, `[[:cntrl:]]` — also locale-dependent.

### BCS posture

- Set `export LC_ALL=C` near the top of any parsing-heavy script
  (BCS-strict invariant in practice). For UI scripts that must
  display localised messages, set only the categories you need.
- Prefer `[[:class:]]` over `[a-z]` ranges for portable patterns
  (BCS0501).
- Inside regex (`=~`), use explicit literal classes (`[a-zA-Z]` after
  setting `LC_ALL=C`, or `[[:alpha:]]` if locale-folded matching is
  intended).
- Document the locale assumption in a header comment when it differs
  from the rest of the script (BCS1202).

**See also**: §5.9 (pathname expansion — globs), §5.11 (`shopt`
options including `globasciiranges`), §5.12 (extglob), §8.4
(`[[ ]]` string comparison), §14.4 (`printf '%(…)T'` and locale).

#fin
