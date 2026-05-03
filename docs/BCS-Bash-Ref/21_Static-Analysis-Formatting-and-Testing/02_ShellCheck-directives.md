<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.2 ShellCheck directives

Inline pragmas to suppress specific warnings with a stated reason.

```bash
# shellcheck disable=SC2034 reason: read by sourced library
local -- callback="$1"
```

- `# shellcheck disable=SCNNNN` — suppress for next command.
- Multiple codes: comma-separated.
- Always include `reason:`; suppression without justification is a code smell.
- Source-level: `# shellcheck shell=bash` for files without shebang.
- `# shellcheck source=path` for non-default sourcing.
- `# shellcheck disable=SCNNNN # comment` — also acceptable.

### Top-8 ShellCheck rule codes (most-cited)

| Code   | Severity | Summary |
|--------|----------|---------|
| SC2086 | warning  | Double-quote to prevent globbing and word splitting (`"$var"` not `$var`). |
| SC2068 | error    | Use `"$@"` not `$@` to preserve argv quoting. |
| SC2155 | warning  | Declare and assign separately to avoid masking exit codes (`local x; x=$(cmd)`). |
| SC2162 | info     | `read` without `-r` mangles backslashes — almost always a bug. |
| SC2164 | warning  | `cd` without an exit-on-fail check (`cd dir || exit`). |
| SC1091 | info     | Source not following — fix with `source=path` or `source-path=SCRIPTDIR` (§21.3). |
| SC2178 | error    | Variable was used as an array but is now assigned a string. |
| SC2207 | warning  | Prefer `mapfile`/`readarray` over `arr=( $(cmd) )`; the latter word-splits and globs. |

These eight account for the bulk of real-world bash bugs flagged by
ShellCheck; every BCS rule under §03 (Strings/Quoting) and §02
(Variables) corresponds to at least one of them.

```bash
# scenario: multi-code disable with reason
# shellcheck disable=SC2034,SC2155 reason: callback exported to sourced lib; rc captured separately
declare -gx callback="$1"
declare -- workdir="$(get_workdir)"
```

```bash
#!/usr/bin/env false
# shellcheck shell=bash
# scenario: file-level shell directive for a sourced library with no shebang

lib_helper() {
  printf 'lib v1\n'
}

#fin
```

`# shellcheck shell=bash` at file head pins ShellCheck to bash semantics
even when the file lacks an executable shebang — essential for libraries
sourced via `source lib.bash`.

**See also**: §21.1 (warnings), §21.3 (source-path), §21.5 (`bcscheck`), BCS0307 (anti-patterns).

#fin
