<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 22.1 The strict-mode preamble

The opening every script must have.

```bash
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob
```

- Shebang: `#!/bin/bash`, `#!/usr/bin/bash`, or `#!/usr/bin/env bash` (the last for portability).
- `set -e` exit on error; `-u` unset variables; `-o pipefail` pipeline status.
- `inherit_errexit` propagate `-e` into command substitutions.
- `shift_verbose` warn on shift past end.
- `extglob` enable extended globs.
- `nullglob` empty glob expands to nothing.
- BCS canonical: declare these at the very top, before any logic.

#fin
