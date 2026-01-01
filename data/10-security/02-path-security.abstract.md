## PATH Security

**Lock PATH immediately after `set -euo pipefail` to prevent command hijacking attacks.**

**Why:** Attacker-controlled directories allow trojan binaries; `.`, `::`, or `/tmp` in PATH enable current-directory/world-writable attacks; inherited PATH may be malicious.

**Correct pattern:**

```bash
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Validation if inherited PATH needed:**

```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Anti-patterns:**

- `# No PATH setting` â†' inherits unsafe environment
- `PATH=.:$PATH` â†' current directory hijacking
- `PATH=/tmp:$PATH` â†' world-writable directory
- `PATH=/home/user/bin:$PATH` â†' user-controlled
- `PATH=/usr/bin::/bin` â†' `::` equals current dir
- Setting PATH late â†' commands before it are unsafe

**Critical:** Use `readonly PATH` to prevent modification. For maximum security, use absolute paths: `/bin/tar`, `/bin/rm`.

**Ref:** BCS1002
