<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.2 Self-locating script directory

Find the script's own directory regardless of how it was invoked.

```bash
declare -r SCRIPT_PATH=$(realpath -- "${BASH_SOURCE[0]}")
declare -r SCRIPT_DIR=${SCRIPT_PATH%/*}
declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
```

- `BASH_SOURCE[0]` is the script file (or library file when sourced).
- `realpath` resolves symlinks (BCS preferred over `readlink`).
- `--` terminates options.
- `SCRIPT_DIR` for finding sibling files (configs, libraries, data).
- `SCRIPT_NAME` for messages.

#fin
