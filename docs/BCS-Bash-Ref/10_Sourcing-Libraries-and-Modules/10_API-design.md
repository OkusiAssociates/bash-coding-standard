<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.10 API design

Designing a library API that other people will use. The rules below
are not bash-specific — they are general API hygiene — but each is
encoded in the BCS library template (BCS0407) and worth restating
because bash's looseness makes them easy to violate by accident.

- Small public surface; large private substrate.
- Consistent naming across functions in the library.
- Standard parameter order — for example, source before destination,
  or vice versa, but consistent.
- Use namerefs for output parameters; avoid mutating globals from
  the public API.
- Document side effects (variables touched, files written, traps
  installed).
- Versioned: bump major on breaking changes.
- Idempotent: sourcing twice has the same effect as once.
- Fail predictably: clear error messages, consistent exit codes
  (BCS0602).

### Canonical small-library skeleton

The skeleton below combines every preceding chapter's guidance into
one minimum-viable library. It is BCS-compliant out of the box;
real libraries grow by adding more functions, never by relaxing the
structure.

```bash
# scenario: BCS-compliant minimum-viable library skeleton.
# ── /usr/local/lib/myapp/path_utils.sh ────────────────────────
#!/usr/bin/env bash
# path_utils.sh — path normalisation utilities for myapp.
#
# Public API:
#   path_utils::canonical PATH        Print canonical absolute path on stdout.
#   path_utils::is_subdir PARENT KID  Status 0 if KID is under PARENT.
#   PATH_UTILS_VERSION                Version constant.
#
# Internal:
#   _path_utils_resolve PATH
#
# License: CC-BY-SA-4.0
# Version: 1.0.0

# §10.9 — refuse non-bash hosts.
[[ -n ${BASH_VERSION:-} ]] || {
  echo 'path_utils: requires bash' >&2
  return 1 2>/dev/null || exit 1
}

# §10.4 — idempotent guard.
[[ -n ${PATH_UTILS_LOADED:-} ]] && return
declare -gri PATH_UTILS_LOADED=1
declare -gr  PATH_UTILS_VERSION='1.0.0'        # §10.7 (BCS0204)

# Public: print canonical absolute path on stdout.
# Returns: 0 on success; 1 if PATH does not resolve.
# Side effects: none.
path_utils::canonical() {
  local -- p="${1:?usage: path_utils::canonical PATH}"
  local -- canon
  canon=$(realpath -- "$p" 2>/dev/null) || return 1
  printf '%s' "$canon"                         # output via stdout (BCS0411)
}

# Public: status 0 if KID is at or under PARENT (after canonicalisation).
path_utils::is_subdir() {
  local -- parent="${1:?usage: path_utils::is_subdir PARENT KID}"
  local -- kid="${2:?usage: path_utils::is_subdir PARENT KID}"
  local -- pcan kcan
  pcan=$(path_utils::canonical "$parent") || return 2
  kcan=$(path_utils::canonical "$kid")    || return 2
  [[ $kcan == "$pcan" || $kcan == "$pcan"/* ]]
}

# Internal helper (no public guarantee).
_path_utils_resolve() {
  realpath -- "${1:?}" 2>/dev/null
}

#fin
```

The skeleton in 30 lines covers: shebang and metadata header
(BCS0103), refuse-to-load guard (§10.9), idempotent guard (§10.4),
public version constant (§10.7), namespaced public functions
(§10.5), internal helper with leading-underscore convention (§10.6),
parameter validation via `${1:?}` enforcement, output via stdout,
status-code conventions (0 success, 1 documented failure, 2 invalid
input), and `#fin` terminator. A real library extends this by
adding more public functions; the structure is invariant.

**See also**: every preceding chapter of Part X, plus §9.12 calling-
convention discipline (the function-level analogue of these rules),
§10.11 distribution and installation, BCS0407 (library patterns),
BCS0103 (script metadata), BCS0411 (subshell return-value patterns),
BCS0602 (exit codes).

#fin
