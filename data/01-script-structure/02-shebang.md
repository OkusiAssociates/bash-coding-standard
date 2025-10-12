### Shebang and Initial Setup
First lines of all scripts must include a `#!shebang`, global `#shellcheck` definitions (optional), a brief description of the script, and first command `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

Allowable shebangs are `#!/bin/bash`, `#!/usr/bin/bash` and `#!/usr/bin/env bash`.
