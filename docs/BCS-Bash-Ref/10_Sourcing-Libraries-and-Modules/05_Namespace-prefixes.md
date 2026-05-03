<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.5 Namespace prefixes

Bash function names accept `::` and several other punctuation
characters, enabling Java/C++-style namespacing without recourse to
hyphens or underscores alone.

- `mylib::function_name` is a valid function name.
- Avoids collision with other libraries that may define functions of
  the same short name (`init`, `setup`, `parse`).
- Convention: library prefix in lowercase, `::` separator, snake_case
  for the function-local name.
- Equivalent: prefix with `_libname_` if `::` looks awkward in your
  codebase or if the library targets a context where `::` is
  reserved.
- Variables: prefix with `MYLIB_` (uppercase) for globals.
- Local variables in functions need no namespacing — `local`
  scoping (§9.3) suffices.

### Full library skeleton with namespace discipline

The example below defines a small string-manipulation library using
the `mylib::` convention and shows it being invoked from a separate
script. The discipline is consistent across every public function and
every public variable.

```bash
# scenario: namespaced library — definition and use.
# ── /tmp/mylib.sh ─────────────────────────────────────────────
[[ -n ${MYLIB_LOADED:-} ]] && return           # idempotent guard (§10.4)
declare -gri MYLIB_LOADED=1
declare -gr  MYLIB_VERSION='1.0.0'             # public, namespaced (BCS0204)

# Public API — namespaced with `::`.
mylib::upper() {
  local -- s="${1:?usage: mylib::upper STRING}"
  printf '%s' "${s^^}"
}

mylib::lower() {
  local -- s="${1:?usage: mylib::lower STRING}"
  printf '%s' "${s,,}"
}

mylib::trim() {
  local -- s="${1:?usage: mylib::trim STRING}"
  s="${s#"${s%%[![:space:]]*}"}"               # strip leading WS
  s="${s%"${s##*[![:space:]]}"}"               # strip trailing WS
  printf '%s' "$s"
}

# Private helpers — leading underscore (§10.6).
_mylib_assert_nonempty() {
  [[ -n ${1:-} ]] || return 1
}
#fin

# ── /tmp/use_mylib.bash ───────────────────────────────────────
#!/usr/bin/env bash
set -euo pipefail
source /tmp/mylib.sh

printf 'lib version: %s\n' "$MYLIB_VERSION"    # ⇒ lib version: 1.0.0
mylib::upper 'hello'                           # ⇒ HELLO
mylib::lower 'WORLD'                           # ⇒ world
printf '[%s]\n' "$(mylib::trim '   spaced   ')"  # ⇒ [spaced] (BCS0407)
#fin
```

The library uses `mylib::` for *every* public function, `MYLIB_` for
public variables, and `_mylib_` for internal helpers. Discipline pays
off when two libraries collide on common names like `init`,
`validate`, `lookup`. Choice between `::` and `_` is project-wide;
mixing both in one library is the thing to avoid (BCS0203).

**See also**: §9.10 naming conventions, §10.4 idempotent sourcing
guards (sentinel-name convention), §10.6 public vs private
conventions, §9.1 definition syntax, §9.9 exporting functions
(namespacing matters more for exported functions), BCS0203 (naming
conventions), BCS0407 (library patterns).

#fin
