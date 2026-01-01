## Shebang and Initial Setup

First lines require: shebang, optional shellcheck directives, brief description, then `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**
1. `#!/bin/bash` - Most portable for Linux
2. `#!/usr/bin/bash` - BSD systems
3. `#!/usr/bin/env bash` - Maximum portability (searches PATH)

**Rationale:** `set -euo pipefail` must be first command to enable strict error handling before any other commands execute.
