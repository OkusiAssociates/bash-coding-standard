## PATH Security

**Always secure the PATH variable to prevent command substitution attacks and trojan binary injection.**

**Rationale:**

- **Command Hijacking**: Attacker-controlled directories in PATH allow malicious binaries to replace system commands
- **Current Directory Risk**: `.` or empty elements cause commands to execute from the current directory
- **Privilege Escalation**: Scripts with elevated privileges can be tricked into executing attacker code
- **Search Order Matters**: Earlier directories are searched first, enabling priority-based attacks
- **Environment Inheritance**: PATH inherited from caller's environment may be malicious
- **Defense in Depth**: PATH security is critical even with other precautions

**Lock down PATH at script start:**

```bash
#!/bin/bash
set -euo pipefail

#  Correct - set secure PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH

# Rest of script uses locked-down PATH
command=$(which ls)  # Searches only trusted directories
```

**Alternative: Validate existing PATH:**

```bash
#!/bin/bash
set -euo pipefail

#  Correct - validate PATH contains no dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory'
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element'
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element'
[[ "$PATH" =~ :$  ]] && die 1 'PATH ends with empty element'
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp'
[[ "$PATH" =~ ^/home ]] && die 1 'PATH starts with user home directory'
```

**Attack Example: Current Directory in PATH**

```bash
# Attacker creates malicious 'ls' in /tmp
cat > /tmp/ls << 'EOF'
#!/bin/bash
cp /etc/shadow /tmp/stolen_shadow
chmod 644 /tmp/stolen_shadow
/bin/ls "$@"  # Execute real ls to appear normal
EOF
chmod +x /tmp/ls

# Attacker sets PATH with /tmp first
export PATH=/tmp:$PATH
cd /tmp
/usr/local/bin/backup.sh  # Executes /tmp/ls instead of /bin/ls
```

**Secure PATH patterns:**

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail

# Lock down PATH immediately
readonly PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH

tar -czf /backup/data.tar.gz /var/data
```

**Pattern 2: Full command paths (maximum security):**

```bash
#!/bin/bash
set -euo pipefail

# Don't rely on PATH at all - use absolute paths
/bin/tar -czf /backup/data.tar.gz /var/data
/usr/bin/systemctl restart nginx
/bin/rm -rf /tmp/workdir
```

**Pattern 3: PATH validation with fallback:**

```bash
#!/bin/bash
set -euo pipefail

validate_path() {
  if [[ "$PATH" =~ \.  ]] || \
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
#!/bin/bash
set -euo pipefail

verify_command() {
  local cmd=$1
  local expected_path=$2
  local actual_path

  actual_path=$(command -v "$cmd")

  if [[ "$actual_path" != "$expected_path" ]]; then
    die 1 "Security: $cmd is $actual_path, expected $expected_path"
  fi
}

# Verify before using critical commands
verify_command tar /bin/tar
verify_command rm /bin/rm

tar -czf backup.tar.gz data/
```

**Anti-patterns:**

```bash
#  Wrong - trusting inherited PATH
#!/bin/bash
set -euo pipefail
ls /etc  # Could execute trojan ls from caller's PATH

#  Wrong - PATH includes current directory
export PATH=.:$PATH

#  Wrong - PATH includes /tmp
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

#  Wrong - empty elements in PATH
export PATH=/usr/local/bin::/usr/bin:/bin  # :: is current directory
export PATH=:/usr/local/bin:/usr/bin:/bin  # Leading : is current directory

#  Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami  # Uses inherited PATH (dangerous!)
export PATH='/usr/bin:/bin'  # Too late!

#  Correct - set PATH at top
#!/bin/bash
set -euo pipefail
readonly PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Edge case: Scripts needing custom paths:**

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
[[ -d "$APP_PATH" ]] || die 1 "Application path does not exist: $APP_PATH"
[[ -w "$APP_PATH" ]] && die 1 "Application path is writable: $APP_PATH"
```

**Checking PATH security:**

```bash
check_path_security() {
  local -a issues=()

  [[ "$PATH" =~ \.  ]] && issues+=('contains current directory (.)')
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

  info 'PATH security check passed'
  return 0
}

check_path_security || die 1 'PATH security validation failed'
```

**Summary:**

- **Always set PATH** explicitly at start of security-critical scripts
- **Use `readonly PATH`** to prevent later modification
- **Never include** `.`, empty elements, `/tmp`, or user directories
- **Validate PATH** if using inherited environment
- **Use absolute paths** for critical commands as defense in depth
- **Place PATH setting early** - first few lines after `set -euo pipefail`
- **Check permissions** on PATH directories (none should be world-writable)

**Key principle:** An attacker who controls your PATH controls which code runs. Always secure it first.
