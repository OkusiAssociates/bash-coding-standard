<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.3 Build configuration and feature detection

Bash is configurable at compile time. Distributions disable some features; some versions add features behind `--enable-` flags. A script that needs `extglob`, loadable builtins, or restricted-mode awareness must detect those at runtime rather than trust the platform — the version number alone is not enough (BCS0409).

What is inspectable at runtime:

- `bash --version` — printable version string for humans.
- `BASH_VERSION` — the same string in-process.
- `BASH_VERSINFO[0..5]` — programmatic tuple: major, minor, patch, build, release, machtype.
- `${BASH_VERSINFO[5]}` — `machtype` (e.g. `x86_64-pc-linux-gnu`); reflects the configure-time triplet.
- `shopt` — runtime feature flags; `shopt -p name` prints the assignable form.
- `enable -p` (enabled builtins), `enable -a` (all known, including disabled), `enable -f file.so name` (loadable builtins, only if `--enable-loadable-builtins`).
- `compgen -b` — builtin enumeration as completion candidates.
- `declare -n ref=var 2>/dev/null` — namerefs only work from 4.3 onwards.

```bash
# scenario: probe for the features a script depends on
require_feature() {
  local -- name="$1"
  if ! shopt -q "$name" 2>/dev/null && ! shopt -s "$name" 2>/dev/null; then
    printf 'shopt: %s unavailable in this Bash\n' "$name" >&2
    return 1
  fi
}
require_feature extglob
require_feature globstar
require_feature inherit_errexit          # BCS0101
```

```bash
# scenario: detect a loadable builtin without crashing on stripped builds
if enable -f /usr/lib/bash/realpath realpath 2>/dev/null; then
  : 'realpath builtin loaded — no fork per call'
else
  : 'fall back to /bin/realpath'
fi
# scenario: enumerate currently enabled builtins
enable -p | head -3
# ⇒ enable .
# ⇒ enable :
# ⇒ enable [
```

Runtime feature detection beats compile-time speculation: probe what you need, fall back gracefully, and announce the diagnosis (BCS0701 messaging discipline).

**See also**: §2.2 (release feature additions), §2.7 (`-O`/`+O` to set `shopt` from the command line), §3 (lexical features whose availability depends on `extglob`/`globstar`), §10.4 (loadable-builtin patterns), §20.14 (restricted-shell detection).

#fin
