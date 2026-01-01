## PATH Security

**Always secure the PATH variable to prevent command substitution attacks and trojan binary injection.**

**Rationale:**
- Command hijacking: Attacker-controlled directories allow malicious binaries to replace system commands
- Current directory risk: `.` or empty elements execute from current directory
- Privilege escalation: Scripts with elevated privileges execute attacker code
- Environment inheritance: PATH inherited from caller may be malicious

**Lock down PATH at script start:**

```bash
#!/bin/bash
set -euo pipefail

# ✓ Correct - set secure PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Alternative: Validate existing PATH:**

```bash
# ✓ Correct - validate PATH contains no dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ :$  ]] && die 1 'PATH ends with empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
```

**Attack Example: Current Directory in PATH**

```bash
# Attacker creates malicious 'ls' in /tmp
cat > /tmp/ls << 'EOF'
#!/bin/bash
cp /etc/shadow /tmp/stolen_shadow
chmod 644 /tmp/stolen_shadow
/bin/ls "$@"
EOF
chmod +x /tmp/ls

# Attacker sets PATH with /tmp first
export PATH=/tmp:$PATH
# Script executes /tmp/ls instead of /bin/ls
```

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# Lock down PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH
```

**Pattern 2: Full command paths (maximum security):**

```bash
# Don't rely on PATH at all - use absolute paths
/bin/tar -czf /backup/data.tar.gz /var/data
/usr/bin/systemctl restart nginx
/bin/rm -rf /tmp/workdir
```

**Pattern 3: PATH validation with fallback:**

```bash
validate_path() {
  if [[ "$PATH" =~ \\.  ]] || \
     [[ "$PATH" =~ ^:  ]] || \
     [[ "$PATH" =~ ::  ]] || \
     [[ "$PATH" =~ :$  ]] || \
     [[ "$PATH" =~ /tmp ]]; then
    export PATH='/usr/local/bin:/usr/bin:/bin'
    readonly PATH
    warn 'Suspicious PATH detected, reset to safe default'
  fi
}

validate_path
```

**Pattern 4: Command verification:**

```bash
verify_command() {
  local cmd=$1
  local expected_path=$2
  local actual_path

  actual_path=$(command -v "$cmd")

  if [[ "$actual_path" != "$expected_path" ]]; then
    die 1 "Security: $cmd is $actual_path, expected $expected_path"
  fi
}

verify_command tar /bin/tar
verify_command rm /bin/rm
```

**Anti-patterns:**

```bash
# ✗ Wrong - trusting inherited PATH
#!/bin/bash
set -euo pipefail
# No PATH setting - inherits from environment
ls /etc  # Could execute trojan ls

# ✗ Wrong - PATH includes current directory
export PATH=.:$PATH

# ✗ Wrong - PATH includes /tmp
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

# ✗ Wrong - empty elements in PATH
export PATH=/usr/local/bin::/usr/bin:/bin  # :: is current directory
export PATH=:/usr/local/bin:/usr/bin:/bin  # Leading : is current directory
export PATH=/usr/local/bin:/usr/bin:/bin:  # Trailing : is current directory

# ✗ Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami   # Uses inherited PATH (dangerous!)
hostname
export PATH='/usr/bin:/bin'  # Too late!

# ✓ Correct - set PATH at top of script
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Edge case: Scripts that need custom paths:**

```bash
#!/bin/bash
set -euo pipefail

# Start with secure base PATH
readonly BASE_PATH='/usr/local/bin:/usr/bin:/bin'
readonly APP_PATH='/opt/myapp/bin'

# Combine with secure base first
export PATH="$BASE_PATH:$APP_PATH"
readonly PATH

# Validate application path exists and is not world-writable
[[ -d "$APP_PATH" ]] || die 1 "Application path does not exist ${APP_PATH@Q}"
[[ -w "$APP_PATH" ]] && die 1 "Application path is writable ${APP_PATH@Q}"
```

**Special consideration: Sudo and PATH:**

```bash
# When using sudo, PATH is reset by default via secure_path
# /etc/sudoers: Defaults secure_path="/usr/local/sbin:..."

# ✓ Safe - sudo uses secure_path
sudo /usr/local/bin/backup.sh

# ✗ Don't configure: Defaults env_keep += "PATH"

# ✓ Correct - script sets its own PATH regardless
# Even if sudo preserves PATH, script overwrites it
```

**PATH security check function:**

```bash
check_path_security() {
  local -a issues=()

  [[ "$PATH" =~ \\.  ]] && issues+=('contains current directory (.)')
  [[ "$PATH" =~ ^:  ]] && issues+=('starts with empty element')
  [[ "$PATH" =~ ::  ]] && issues+=('contains empty element (::)')
  [[ "$PATH" =~ :$  ]] && issues+=('ends with empty element')
  [[ "$PATH" =~ /tmp ]] && issues+=('contains /tmp')

  if ((${#issues[@]} > 0)); then
    error 'PATH security issues detected:'
    local issue
    for issue in "${issues[@]}"; do
      error "  - $issue"
    done
    return 1
  fi

  return 0
}

check_path_security || die 1 'PATH security validation failed'
```

**Summary:**
- **Always set PATH** explicitly at script start
- **Use `readonly PATH`** to prevent later modification
- **Never include** `.`, empty elements, `/tmp`, or user directories
- **Use absolute paths** for critical commands as defense in depth
- **Place PATH setting early** - first lines after `set -euo pipefail`

**Key principle:** PATH is trusted implicitly by command execution. An attacker who controls your PATH controls which code runs.
