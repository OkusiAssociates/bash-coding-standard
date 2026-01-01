## Shebang and Initial Setup

**First lines must include shebang, optional shellcheck directives, description comment, then `set -euo pipefail` as first command.**

**Shebangs:** `#!/bin/bash` (Linux) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (max portability)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Rationale:** Strict mode (`set -euo pipefail`) must execute before any other commands to catch errors immediately.

**Anti-patterns:** Missing `set -euo pipefail` â†' silent failures; shebang without path (`#!bash`) â†' won't execute.

**Ref:** BCS0102
