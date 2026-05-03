<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.12 Sanitising filenames

A POSIX filename is any byte sequence excluding `/` and NUL — which means
any byte sequence including ANSI escapes, RTL overrides, embedded
newlines, and characters that `ls` cannot print. User-supplied filenames
must be sanitised before they meet a shell command, a log, or a
filesystem (BCS1005).

Two complementary operations: a sanitiser that constrains the byte set,
and `realpath --` canonicalisation that resolves the path inside a
permitted root.

### Sanitiser function

The sanitiser below takes an untrusted name and emits a clean basename on
stdout, or fails with exit 22 (BCS0602 invalid argument) if the input is
beyond repair. It strips control characters, refuses traversal
components, refuses leading dashes (would be parsed as an option), and
caps length at 255 bytes (the traditional `NAME_MAX`).

```bash
sanitise_name() {
  local -- raw=${1-}
  (( $# == 1 )) || { error 'sanitise_name: exactly one argument'; return 22; }

  # reject empty, NUL-bearing, traversal, and absolute paths up-front
  [[ -n $raw ]]            || { error 'empty name';                 return 22; }
  [[ $raw != *$'\0'* ]]    || { error 'NUL in name';                return 22; }
  [[ $raw != /* ]]         || { error 'absolute path rejected';     return 22; }
  [[ $raw != *..* ]]       || { error 'traversal component';        return 22; }

  # strip control bytes (0x00-0x1F, 0x7F); keep printable + UTF-8 high-bit
  local -- clean=${raw//[[:cntrl:]]/}
  # collapse runs of whitespace, trim leading/trailing
  clean=${clean//+( )/ }
  clean=${clean# }; clean=${clean% }
  # refuse leading dash so consumers don't mis-parse as option
  [[ $clean != -* ]]       || { error 'leading dash';               return 22; }
  # length cap — typical NAME_MAX
  (( ${#clean} > 0 && ${#clean} <= 255 )) \
                           || { error 'length out of range';        return 22; }
  printf '%s\n' "$clean"
}
```

The `${raw//[[:cntrl:]]/}` substitution is BCS-correct (BCS0207); it
removes every control byte without iteration. `+( )` requires `extglob`,
which the BCS strict-mode preamble (BCS0101) enables.

### `realpath --` canonicalisation

The sanitiser produces a clean basename; `realpath --` resolves it to an
absolute path with symlinks resolved and `..` components flattened. The
final containment check proves the resolved path stays inside the
permitted root, blocking the case where a sanitised name reaches a
symlink that escapes.

```bash
# scenario: prove that user-named file resides inside ASSET_ROOT
declare -r ASSET_ROOT=/srv/assets
read -r raw_name
clean=$(sanitise_name "$raw_name")  || die 22 'invalid name'
abs=$(realpath -- "$ASSET_ROOT/$clean") \
                                    || die 3 'asset not found'
[[ $abs == "$ASSET_ROOT"/* ]] \
  || die 22 "asset escapes root: ${clean@Q} → ${abs@Q}"
process -- "$abs"
```

The leading `--` in `realpath --` is essential: a sanitised-but-still-
dash-leading name (which sanitise_name rejects, but defence-in-depth)
would otherwise be parsed as an option. The trailing pattern `"$ASSET_ROOT"/*`
requires the prefix *and* a `/`, blocking `ASSET_ROOT_evil/`.

For untrusted *paths* (not just basenames), apply the sanitiser to each
component after splitting on `/`, then re-join. Most scripts do not need
to accept paths; insist on basenames where possible.

**See also**: §20.6 input validation, §20.13 symlink races, BCS1005
input sanitization, BCS0207 parameter expansion.

#fin
