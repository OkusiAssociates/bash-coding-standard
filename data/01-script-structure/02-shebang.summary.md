## Shebang and Initial Setup

First lines must include shebang, optional shellcheck directives, brief description, and `set -euo pipefail` as first command.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**

1. `#!/bin/bash` - Most portable for Linux systems
2. `#!/usr/bin/bash` - BSD systems where bash is in /usr/bin
3. `#!/usr/bin/env bash` - Maximum portability; searches PATH for bash

**Rationale:** First command must be `set -euo pipefail` for strict error handling before any other commands execute.
