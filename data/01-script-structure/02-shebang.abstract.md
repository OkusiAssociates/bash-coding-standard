## Shebang and Initial Setup

**Every script starts: shebang → optional shellcheck → description → `set -euo pipefail`.**

**Shebangs:** `#!/bin/bash` (standard) | `#!/usr/bin/bash` (BSD) | `#!/usr/bin/env bash` (portable PATH search)

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Brief script description
set -euo pipefail
```

**Key:** `set -euo pipefail` must be first command—enables strict error handling before any execution.

**Ref:** BCS0102
