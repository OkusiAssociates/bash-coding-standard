## PATH Security

**Lock down PATH at script start to prevent command hijacking and trojan injection.**

### Why

- Attacker-controlled PATH directories execute malicious binaries instead of system commands
- Empty elements (`::`, leading/trailing `:`) and `.` resolve to current directory
- Inherited PATH from caller's environment may be compromised

### Pattern

```bash
#!/bin/bash
set -euo pipefail

# Set immediately after shebang/strict mode
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

### Validation (if must use inherited PATH)

```bash
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains .'
[[ "$PATH" =~ ^:|::|:$ ]] && die 1 'PATH has empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

### Anti-Patterns

```bash
# ✗ No PATH set → inherits potentially malicious environment
#!/bin/bash
ls /etc

# ✗ Current dir in PATH → trojans in cwd execute
export PATH=.:$PATH

# ✗ World-writable dir → attackers place trojans
export PATH=/tmp:$PATH

# ✗ Set too late → commands before this use inherited PATH
whoami
export PATH='/usr/bin:/bin'
```

### Custom Paths

```bash
readonly -- BASE_PATH='/usr/local/bin:/usr/bin:/bin'
export PATH="$BASE_PATH:/opt/myapp/bin"
readonly -- PATH
```

**Ref:** BCS1002
