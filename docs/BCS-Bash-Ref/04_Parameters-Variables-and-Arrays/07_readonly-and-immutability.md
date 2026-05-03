<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 4.7 `readonly` and immutability

A variable marked `readonly` (equivalently `declare -r`) cannot be
reassigned, unset, or have any attribute revoked. Bash enforces this
in the parser/runtime: an attempt to write to a readonly name fails
with a diagnostic and exits non-zero — under `set -e` the whole script
terminates. The attribute is **one-way**: once set, the only way to
clear it is to leave the shell.

### Surface area

- `readonly name=value` and `declare -r name=value` are equivalent.
- `readonly -p` lists all readonly variables in re-source-able form.
- `readonly -f funcname` marks a function definition immutable; it
  cannot be redefined or `unset -f`.
- Combined attributes are common: `declare -ir COUNT=0` (integer +
  readonly), `declare -ar PARTS=(a b c)` (indexed array + readonly),
  `declare -Ar MAP=([k]=v)` (assoc + readonly).
- The order of attributes matters only at *assignment* — once the
  readonly bit is set, no further `declare`/`local` can change other
  attributes either.

### Script metadata — the canonical use case

Every BCS-compliant script declares its identity as readonly at the
top, immediately after strict-mode setup (BCS0103):

```bash
# scenario: BCS metadata block — every script begins this way
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

declare -r  VERSION='1.2.3'
declare -r  SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r  SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r  SCRIPT_NAME=${SCRIPT_PATH##*/}
declare -r  PREFIX=${SCRIPT_DIR%/bin}

# Trying to reassign trips the immutability guard:
SCRIPT_NAME='oops'
# ⇒ bash: SCRIPT_NAME: readonly variable
# ⇒ (under `set -e`, script terminates with non-zero status)
```

`realpath` (not `readlink`) is the canonical resolver for BCS scripts
(BCS0103). The `${...%/*}` / `${...##*/}` trims avoid forking
`dirname`/`basename` (§5.4).

### Read-only functions

`readonly -f` freezes a function's definition for the lifetime of the
shell. Useful for libraries that supply utility functions which
callers must not silently shadow:

```bash
# scenario: lock down a library helper so a downstream caller cannot redefine it
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

die() {
  printf '%s: %s\n' "${0##*/}" "$*" >&2
  exit 1
}
readonly -f die

# A later (mistaken) redefinition is rejected:
die() { echo 'pwned'; }
# ⇒ bash: die: readonly function
```

### Pitfalls

- **In-function readonly persists after return**. `readonly` always
  affects the global slot unless used together with `local -r` (which
  itself implies the local scope but the readonly bit is still
  irrevocable for the duration of the function and its callees).
  Library functions that mark a global as readonly can subtly poison
  every later script that sources them.
- **Re-sourcing a script that declares readonly globals fails**: the
  second source attempts to reassign already-frozen names. Idempotent
  libraries gate the declarations behind a guard (§10.4).
- **`unset` on a readonly variable errors**. There is no `--force`.
  Restart the shell.
- **Arrays**: an `-ar` array allows neither element addition nor
  removal — `arr+=(x)` and `unset 'arr[0]'` both fail.

### BCS posture

- All script metadata is `declare -r` (BCS0103, BCS0205).
- Constants the script relies on for behaviour (paths, defaults that
  must not change) are `declare -r` (BCS0204).
- `readonly -f` for any library function whose contract callers must
  not redefine.
- Avoid marking *configuration* readonly until config-file sourcing
  has completed (BCS0111) — you cannot revoke immutability later.

**See also**: §4.5 (`declare` and attributes), §4.6 (`local --`),
§4.14 (`unset` and the readonly bar), §10.4 (idempotent sourcing).

#fin
