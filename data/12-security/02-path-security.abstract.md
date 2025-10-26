## PATH Security

**Lock down PATH immediately to prevent command hijacking and trojan binary injection.**

**Rationale:**
- Attacker-controlled directories allow malicious binaries to replace system commands
- `.` or empty elements (`:` `::`) cause execution from current directory
- Earlier directories searched first, enabling priority-based attacks

**Secure PATH patterns:**

```bash
#!/bin/bash
set -euo pipefail

# Pattern 1: Complete lockdown (recommended)
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH

# Pattern 2: Full paths (maximum security)
/bin/tar -czf backup.tar.gz data/
/usr/bin/systemctl restart nginx
```

**Validation approach:**

```bash
# Check for dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Critical anti-patterns:**

```bash
#  Trusting inherited PATH
#!/bin/bash
# No PATH setting - uses caller's environment

#  Current directory in PATH
export PATH=.:$PATH

#  Empty elements (:: = current dir)
export PATH=/usr/local/bin::/usr/bin:/bin
```

**Key principle:** Set PATH in first few lines after `set -euo pipefail`. Use `readonly PATH` to prevent modification. Never include `.`, empty elements, `/tmp`, or user directories.

**Ref:** BCS1202
