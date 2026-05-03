<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.3 Source-path management

Helping ShellCheck follow `source` statements.

- `# shellcheck source=lib/util.bash` — explicit relative path.
- `# shellcheck source-path=SCRIPTDIR source=util.bash` — relative to script directory.
- `# shellcheck source-path=/abs/path source=util.bash` — absolute.
- Required when path uses `$(dirname "$0")` or other dynamic resolution.
- Without it, ShellCheck reports SC1091 (file not following).

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit extglob nullglob

# --- Script metadata (BCS0103 canonical pattern) ---
declare -r SCRIPT_PATH="$(realpath -- "$0")"
declare -r SCRIPT_DIR="${SCRIPT_PATH%/*}"
declare -r SCRIPT_NAME="${SCRIPT_PATH##*/}"

# scenario: source a sibling library; tell ShellCheck to follow it
# shellcheck source-path=SCRIPTDIR source=lib/messaging.bash
source "$SCRIPT_DIR/lib/messaging.bash"

# shellcheck source-path=SCRIPTDIR source=lib/config.bash
source "$SCRIPT_DIR/lib/config.bash"

main() {
  info 'started'
}

main "$@"

#fin
```

`source-path=SCRIPTDIR` is the magic token: ShellCheck resolves the
sibling path relative to the script's own directory, matching the
runtime semantics of the `$SCRIPT_DIR/lib/…` pattern. The directive
lives on the line directly above each `source` statement and is scoped
to that one statement.

**See also**: §21.1 (warnings), §21.2 (directives), §10 (sourcing libraries), BCS0103 (script metadata).

#fin
