## Shebang and Initial Setup

**All scripts must start with shebang, optional shellcheck directives, brief description, then `set -euo pipefail` as first command.**

**Allowable shebangs:**
- `#!/bin/bash` → Most portable (standard Linux)
- `#!/usr/bin/bash` → FreeBSD/BSD systems
- `#!/usr/bin/env bash` → Maximum portability (searches PATH)

**Rationale:** Strict error handling must activate before any commands execute.

**Example:**
```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Anti-pattern:** `set -euo pipefail` after variable declarations → errors undetected during initialization.

**Ref:** BCS0102
