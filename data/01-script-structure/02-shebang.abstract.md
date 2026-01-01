## Shebang and Initial Setup

**First lines: shebang â†' optional shellcheck â†' description â†' `set -euo pipefail`**

**Allowed shebangs:** `#!/bin/bash` (Linux) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (portable)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Key points:**
- `set -euo pipefail` MUST be first executable command
- Strict mode before any other code executes

**Anti-patterns:** `#!/bin/sh` â†' not Bash | Missing `set -euo pipefail` â†' silent failures

**Ref:** BCS0102
