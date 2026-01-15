## PATH Security

**Lock down PATH at script start to prevent command hijacking and trojan injection.**

**Rationale:**
- Attacker-controlled directories allow malicious binaries to replace system commands
- Empty PATH elements (`:`, `::`, trailing `:`) resolve to current directory
- PATH inherited from caller's environment may be malicious

**Secure PATH pattern:**
```bash
#!/bin/bash
set -euo pipefail
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Validate PATH (if not resetting):**
```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|:::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Anti-patterns:**
- `# No PATH setting` â†' inherits untrusted environment
- `PATH=.:$PATH` â†' current directory searchable
- `PATH=/tmp:$PATH` â†' world-writable dir in PATH
- `PATH=::` or leading/trailing `:` â†' empty = current dir
- Setting PATH late â†' commands before it use inherited PATH

**Key:** Set `readonly PATH` immediately after `set -euo pipefail`. Use absolute paths (`/bin/tar`) for critical commands as defense in depth.

**Ref:** BCS1002
