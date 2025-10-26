## Shebang and Initial Setup

First lines must include: `#!shebang`, global `#shellcheck` directives (optional), brief script description, then `set -euo pipefail`.

```bash
#!/bin/bash
#shellcheck disable=SC1090,SC1091
# Get directory sizes and report usage statistics
set -euo pipefail
```

**Allowable shebangs:**

1. `#!/bin/bash` - Most portable for Linux systems (bash in standard location)
2. `#!/usr/bin/bash` - FreeBSD/BSD systems (bash in /usr/bin)
3. `#!/usr/bin/env bash` - Maximum portability (searches PATH, works across diverse environments)

**Rationale:** These three shebangs cover all common scenarios. First command must be `set -euo pipefail` to enable strict error handling immediately before any other commands execute.
