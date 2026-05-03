<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 10.3 Self-locating library pattern

The canonical pattern by which a library determines its own
installation directory at runtime.

```bash
lib_dir=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")
data_dir=$lib_dir/data
```

- Use `realpath` (not `readlink`) — see BCS-bash conventions.
- `dirname` on `${BASH_SOURCE[0]}` gives the library's directory.
- Resolves symlinks — important when installed via symlink.
- Must run at sourcing time (not call time) so it captures the
  library's *source* location, not the caller's location.
- Pitfall: running this inside a function captures the file the
  function was *defined in* — same answer either way for a single-
  file library, but matters for multi-file installations.

### Symlink resolution

The `realpath --` step is the load-bearing piece. Without it, a
library installed via symlink (the common case for system-wide
installs in `/usr/local/bin/` that point at versioned files in
`/usr/local/share/<project>/`) would compute its `data_dir`
relative to the *symlink directory*, not the actual install prefix.

```bash
# scenario: confirm self-location works through one or more symlinks.
#!/usr/bin/env bash
set -euo pipefail

# Layout used by the demo:
#   /opt/myapp-1.2/lib/strings.sh                 ← real file
#   /opt/myapp-1.2/data/messages.txt              ← data alongside the lib
#   /usr/local/lib/myapp/strings.sh -> ../../...  ← versioned symlink
#   /home/user/strings.sh           -> /usr/...   ← user-level alias

# /opt/myapp-1.2/lib/strings.sh
strings::self_locate() {
  local -- here
  here=$(realpath -- "$(dirname -- "${BASH_SOURCE[0]}")")
  printf '%s' "$here"                          # always /opt/myapp-1.2/lib (BCS0407)
}

# Sourced through any of the three paths:
source /opt/myapp-1.2/lib/strings.sh
strings::self_locate                           # ⇒ /opt/myapp-1.2/lib

source /usr/local/lib/myapp/strings.sh         # via symlink
strings::self_locate                           # ⇒ /opt/myapp-1.2/lib

source /home/user/strings.sh                   # via symlink-to-symlink
strings::self_locate                           # ⇒ /opt/myapp-1.2/lib

#fin
```

Without `realpath --`, the third invocation would return
`/home/user`, the second would return `/usr/local/lib/myapp`, and
the library's `data_dir` lookup would fail because the data tree
lives next to the *real* file, not next to the alias.

The `--` is BCS practice (BCS0307): it stops a path beginning with
`-` (rare for libraries but possible if `${BASH_SOURCE[0]}` happens
to point through a `-`-prefixed directory) from being interpreted
as an option. The `bash -c "source -someweird/lib.sh"` case is a
real-world hardening concern when input from configuration files is
involved.

**See also**: §9.11 self-locating with `BASH_SOURCE` (the same
idiom from the function-defining angle), §10.2 the `BASH_SOURCE`
array, §10.4 idempotent sourcing guards (often used immediately
after self-location), BCS0104 (FHS compliance), BCS0407 (library
patterns), BCS0307 (anti-patterns: `--` end-of-options discipline).

#fin
