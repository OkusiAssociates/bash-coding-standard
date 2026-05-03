<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.6 Input validation

Validate every piece of untrusted data on entry, against an allow-list, and
exit non-zero on any failure (BCS1005). Deny-lists fail to anticipate
encoding tricks (`%2e%2e`, NUL bytes, RTL overrides) and metacharacter
combinations; allow-lists name the safe subset and refuse the rest.

### Validator-function template

A single parameterised validator covers most cases. It takes a *kind* and a
*value*, returns 0 if the value satisfies that kind's rule, non-zero
otherwise. The caller decides how to fail (warn, retry, exit):

```bash
# scenario: parameterised validator over named input kinds
validate_kind() {
  local -- kind=$1 value=${2-}
  case $kind in
    id)        [[ $value =~ ^[1-9][0-9]{0,8}$ ]]                ;;
    username)  [[ $value =~ ^[a-z_][a-z0-9_-]{0,31}$ ]]         ;;
    filename)  [[ $value != *$'\0'* ]] \
                && [[ $value != /* ]] \
                && [[ $value != -* ]] \
                && [[ $value != *..* ]] \
                && [[ $value =~ ^[[:print:]]+$ ]] \
                && (( ${#value} <= 255 ))                       ;;
    hex)       [[ $value =~ ^[0-9a-f]+$ ]] && (( ${#value} <= 128 )) ;;
    iso_date)  [[ $value =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]     ;;
    *)         error "validate_kind: unknown kind: ${kind@Q}"
               return 2 ;;
  esac
}
```

Key points: the `filename` arm rejects four hazardous shapes — embedded
NUL, leading `/` (absolute path), leading `-` (would be parsed as an
option), and any `..` component (traversal) — before applying the
character-class regex. NUL must be checked first because regex matching of
strings containing NUL is implementation-defined. Length is capped after
content checks because `${#value}` on a long pathological input is cheap
but the regex is not.

The caller wires the validator to the script's exit-on-bad-input policy:

```bash
# scenario: CLI parser rejects bad input with BCS exit code 22
cmd_archive() {
  local -- target=${1:?target required}
  validate_kind filename "$target" \
    || die 22 "archive: invalid filename: ${target@Q}"
  process -- "$target"
}
```

### Filename traversal — worked rejection

Path traversal is the highest-impact filename attack: `../../etc/passwd`
escapes the intended directory. The `filename` arm above rejects any
`..` *component*, not just a leading `..`; this is necessary because
`a/../b` reaches `b` from outside `a`'s subtree. Combined with `realpath`
canonicalisation (§20.12) and a final containment check, the script can
prove the resolved path stays inside the permitted root:

```bash
# scenario: confirm sanitised filename resolves inside $ASSET_ROOT
validate_kind filename "$name" \
  || die 22 "invalid filename: ${name@Q}"
abs=$(realpath -- "$ASSET_ROOT/$name")
[[ $abs == "$ASSET_ROOT"/* ]] \
  || die 22 "path escapes asset root: ${name@Q}"
```

Validate at the trust boundary (typically the CLI parser or RPC entry
point), not at point of use — by the time data reaches `cp` or `curl`, it
has usually been concatenated with other strings and the original boundary
has been lost.

### Length caps before content checks

Length capping comes *before* expensive validation when the input crosses
an untrusted boundary. A 100 MB "filename" is itself an attack: regex
engines run in O(n) on the input, and even cheap operations like
`${#value}` allocate the full string. A two-line guard at the top of any
public entry point neutralises this:

```bash
# scenario: cap input length before any other validation
(( ${#raw} <= 4096 )) \
  || die 22 "input too long: ${#raw} bytes"
```

The 4096 cap is `PATH_MAX` on Linux; choose a smaller cap when the value
is a name rather than a path.

### Numeric ranges, not just numeric type

Numeric validation needs both a type-and-shape check and a range check.
A "user ID" matching `^[0-9]+$` still admits values that overflow
`uid_t`:

```bash
# scenario: validated numeric with an explicit range
[[ $uid =~ ^[1-9][0-9]{0,9}$ ]] && (( uid >= 1000 && uid <= 65533 )) \
  || die 22 "uid out of range: ${uid@Q}"
```

The two-stage check matters: the regex pre-flight prevents `((uid))` from
choking on non-numeric input under `set -e`, and the range check enforces
the actual policy.

**See also**: §20.5 command-injection vectors, §20.12 sanitising filenames,
BCS1005 input sanitization, BCS0602 exit codes.

#fin
