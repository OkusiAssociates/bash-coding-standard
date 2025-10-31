## General Layouts for Standard Script

**Mandatory 13-step structural layout for all Bash scripts.**

### The 13 Steps

1. **Shebang**: `#!/bin/bash` (or `#!/usr/bin/bash`, `#!/usr/bin/env bash`)
2. **ShellCheck directives** (if needed): `#shellcheck disable=SCxxxx` with comments
3. **Brief description**: One-line purpose comment
4. **Error handling**: `set -euo pipefail` (MANDATORY before commands)
5. **Shell options**: `shopt -s inherit_errexit shift_verbose extglob nullglob`
6. **Metadata**: `declare -r VERSION SCRIPT_PATH SCRIPT_DIR SCRIPT_NAME` (readonly together)
7. **Global variables**: Explicit types - `declare -i`, `declare --`, `declare -a`, `declare -A`
8. **Color definitions** (if terminal output): Conditional with readonly
9. **Utility functions**: `_msg()`, `vecho()`, `info()`, `warn()`, `error()`, `die()` - lowest level
10. **Business logic**: Core functions organized bottom-up
11. **main()**: Required >100 lines; includes argument parsing; readonly after parsing
12. **Invocation**: `main "$@"` (always quote)
13. **End marker**: `#fin` or `#end` (MANDATORY)

**Rationale**: Guarantees safe initialization, prevents undefined references, enables testing.

**Anti-pattern**: Missing `set -euo pipefail`, variables before declaration, logic before utilities, no `main()` in large scripts.

**Ref:** BCS0101
