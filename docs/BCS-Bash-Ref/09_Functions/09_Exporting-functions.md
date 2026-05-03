<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 9.9 Exporting functions

Functions can be exported into the environment of child processes,
where bash subprocesses (and only bash subprocesses) will inherit
them as defined functions.

- `export -f funcname` — mark `funcname` for export.
- `declare -fx funcname` — equivalent.
- Encoded specially in the environment as
  `BASH_FUNC_funcname%%=() { body }`.
- Inherited only by bash children, not by other programs (which
  see the encoded variable as garbage).
- Security history: Shellshock (CVE-2014-6271, 2014) exploited the
  function-encoding parser of pre-patch bash; modern bash gates
  function decoding behind the strict `BASH_FUNC_NAME%%=()` prefix
  to prevent injection via attacker-controlled environment.
- Use sparingly; namespace pollution and the inability of non-bash
  programs to use the export are reasons to prefer arguments or
  files (BCS0404).

### Export-and-receive across a `bash -c`

The standard demonstration: a parent defines a function, exports
it, then a child bash invocation sees and uses it. Non-bash children
(`sh -c`, `dash -c`, `awk`) do *not*.

```bash
# scenario: export a helper to a child bash, observe non-bash cannot use it.
#!/usr/bin/env bash
set -euo pipefail

upper() {                                      # define
  local -- s="${1:?usage: upper STRING}"
  printf '%s' "${s^^}"
}
export -f upper                                # mark for export (BCS0404)

# CHILD #1 — bash inherits the function.
bash -c 'upper hello'                          # ⇒ HELLO

# CHILD #2 — sh (often dash) does NOT see it as a function.
sh -c 'upper hello' 2>&1 || true               # ⇒ sh: upper: command not found

# CHILD #3 — env shows the encoded form bash uses to ferry the body.
env | grep '^BASH_FUNC_upper' | head -1
# ⇒ BASH_FUNC_upper%%=() {  local -- s="${1:?usage: upper STRING}"; ...

# Always pair export -f with a clear note in the script header explaining
# why exporting the function is necessary (e.g. for use inside a `find -exec
# bash -c …` invocation). Otherwise prefer passing data via arguments.

#fin
```

The Shellshock context is worth keeping in mind: any unsanitised
environment from an external boundary (CGI, sudoers, su) used to be
able to inject arbitrary code through the function-export
mechanism. Modern bash hardened the parser, but the principle
remains — **never trust environment passed across a security
boundary, and prefer arguments to exported functions when control
flow has to cross such boundaries** (BCS1002, BCS1007).

**See also**: §9.1 definition syntax, §9.10 naming conventions
(why namespace prefixes matter for exported functions), §10.5
namespace prefixes, §20.x environment scrubbing before exec
(Shellshock-class hardening), BCS0404 (function export), BCS1002
(PATH security), BCS1007 (environment scrubbing before exec).

#fin
