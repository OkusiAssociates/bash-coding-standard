<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.7 Version negotiation

Libraries should declare a version; callers should check it. The
contract is one-way (caller refuses to load incompatible libraries),
not handshake-style — bash has no machinery for runtime negotiation.

```bash
# In library
declare -r MYLIB_VERSION_MAJOR=2
declare -r MYLIB_VERSION_MINOR=1
declare -r MYLIB_VERSION=2.1.0

# In caller
if (( MYLIB_VERSION_MAJOR != 2 )); then
  die 1 "mylib version 2.x required, got $MYLIB_VERSION"
fi
```

- Semantic versioning recommended (MAJOR.MINOR.PATCH).
- Major version incompatibility → caller errors out cleanly.
- Minor version: backward-compatible additions; a caller may check
  for a minimum minor version when it needs a recent feature.
- Use sentinel variables (not function-existence tests) for the
  version check itself — the variable is cheap, the function probe
  is fragile.

### Semver feature detection — variant pattern

For libraries that grow features additively, the caller may want to
say "I need at least version 2.3" rather than pinning an exact major.
The pattern is the same idea, with a min-version comparator.

```bash
# scenario: caller requires at least mylib 2.3.
#!/usr/bin/env bash
set -euo pipefail
source /usr/local/lib/myapp/strings.sh         # provides MYLIB_VERSION_*

require_min_version() {
  local -i need_major="$1" need_minor="$2"
  if (( MYLIB_VERSION_MAJOR > need_major )); then
    return 0                                   # newer major → assumed compatible if we said so
  fi
  if (( MYLIB_VERSION_MAJOR == need_major && MYLIB_VERSION_MINOR >= need_minor )); then
    return 0                                   # ⇒ 2.3, 2.4, … all pass
  fi
  >&2 printf 'mylib >= %d.%d required, got %s\n' \
    "$need_major" "$need_minor" "$MYLIB_VERSION"
  return 1                                     # (BCS0602)
}

require_min_version 2 3 || exit 1

# Optional fallback: feature-detect when version is unknown
# (e.g. third-party library without semver discipline).
if declare -F mylib::trim_unicode >/dev/null; then
  result=$(mylib::trim_unicode "$input")        # use the new function
else
  result=$(mylib::trim "$input")                # fall back to the old
fi

#fin
```

Two policy notes. **`> need_major` accepts newer majors** — only
correct when your project's policy is "we support all newer
majors". The opposite policy (pin to one major) replaces the first
`if` with `(( MYLIB_VERSION_MAJOR != need_major ))`. **Function-
existence checks** via `declare -F` are a useful *secondary*
mechanism for libraries that lack version discipline, but should
not replace the version variable check for libraries that have it
(BCS0204, BCS0407).

**See also**: §10.4 idempotent sourcing guards (the sentinel often
encodes the major version: `_MYLIB_V2_LOADED`), §10.6 public vs
private conventions (the version constant is part of the public
API), §10.10 API design, §9.8 listing and inspecting functions
(`declare -F` for feature detection), BCS0204 (constants and
environment variables), BCS0407 (library patterns).

#fin
