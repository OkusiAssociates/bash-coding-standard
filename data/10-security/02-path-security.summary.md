## PATH Security

**Always secure PATH to prevent command substitution attacks and trojan binary injection.**

**Rationale:**
- Command Hijacking: Attacker-controlled directories allow malicious binaries to replace system commands
- Current Directory Risk: `.` or empty elements cause execution from current directory
- Privilege Escalation: Scripts with elevated privileges can execute attacker code
- Search Order: Earlier PATH directories searched first, enabling priority attacks
- Environment Inheritance: PATH inherited from potentially malicious caller environment

**Lock down PATH at script start:**

```bash
#!/bin/bash
set -euo pipefail

# ✓ Correct - set secure PATH immediately
readonly -- PATH='/usr/local/bin:/usr/bin:/bin'
export PATH
```

**Alternative: Validate existing PATH:**

```bash
# ✓ Correct - validate PATH contains no dangerous elements
[[ "$PATH" =~ \.  ]] && die 1 'PATH contains current directory' ||:
[[ "$PATH" =~ ^:  ]] && die 1 'PATH starts with empty element' ||:
[[ "$PATH" =~ ::  ]] && die 1 'PATH contains empty element' ||:
[[ "$PATH" =~ :$  ]] && die 1 'PATH ends with empty element' ||:
[[ "$PATH" =~ /tmp ]] && die 1 'PATH contains /tmp' ||:
```

**Attack Example: Current Directory in PATH**

```bash
# Attacker creates malicious 'ls' in /tmp
cat > /tmp/ls << 'EOT'
#!/bin/bash
cp /etc/shadow /tmp/stolen_shadow
chmod 644 /tmp/stolen_shadow
/bin/ls "$@"
EOT
chmod +x /tmp/ls

# Attacker sets PATH with /tmp first
export PATH=/tmp:$PATH
# Script executes /tmp/ls instead of /bin/ls
```

**Secure PATH Patterns:**

**Pattern 1: Complete lockdown (recommended):**

```bash
#!/bin/bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

readonly -- PATH='/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'
export PATH
```

**Pattern 2: Full command paths (maximum security):**

```bash
# Don't rely on PATH - use absolute paths
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
    readonly -- PATH
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
ls /etc  # Could execute trojan from caller's PATH

# ✗ Wrong - PATH includes current directory
export PATH=.:$PATH

# ✗ Wrong - PATH includes /tmp (world-writable)
export PATH=/tmp:/usr/local/bin:/usr/bin:/bin

# ✗ Wrong - PATH includes user home directories
export PATH=/home/user/bin:$PATH

# ✗ Wrong - empty elements in PATH (all equal current directory)
export PATH=/usr/local/bin::/usr/bin:/bin
export PATH=:/usr/local/bin:/usr/bin:/bin
export PATH=/usr/local/bin:/usr/bin:/bin:

# ✗ Wrong - setting PATH late in script
#!/bin/bash
set -euo pipefail
whoami  # Uses inherited PATH (dangerous!)
hostname
export PATH='/usr/bin:/bin'  # Too late!
```

**Edge case: Scripts needing custom paths:**

```bash
#!/bin/bash
set -euo pipefail

readonly -- BASE_PATH='/usr/local/bin:/usr/bin:/bin'
readonly -- APP_PATH='/opt/myapp/bin'
export PATH="$BASE_PATH:$APP_PATH"
readonly -- PATH

# Validate application path
[[ -d "$APP_PATH" ]] || die 1 "Application path does not exist ${APP_PATH@Q}"
[[ -w "$APP_PATH" ]] && die 1 "Application path is writable ${APP_PATH@Q}"
```

**Sudo and PATH:**

```bash
# sudo uses secure_path by default (/etc/sudoers)
# Defaults secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# ✓ Safe - script sets own PATH regardless
sudo /usr/local/bin/backup.sh
# Script overwrites PATH: readonly -- PATH='/usr/local/bin:/usr/bin:/bin'

# ✗ Don't configure: Defaults env_keep += "PATH"
```

**PATH security check function:**

```bash
check_path_security() {
  local -a issues=()
  [[ "$PATH" =~ \\.  ]] && issues+=('contains current directory (.)') ||:
  [[ "$PATH" =~ ^:  ]] && issues+=('starts with empty element') ||:
  [[ "$PATH" =~ ::  ]] && issues+=('contains empty element (::)') ||:
  [[ "$PATH" =~ :$  ]] && issues+=('ends with empty element') ||:
  [[ "$PATH" =~ /tmp ]] && issues+=('contains /tmp') ||:

  if ((${#issues[@]} > 0)); then
    error 'PATH security issues detected:'
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
- Set PATH explicitly at script start, use `readonly PATH` to prevent modification
- Never include `.`, empty elements, `/tmp`, or user directories
- Use absolute paths for critical commands as defense in depth
- Check permissions on PATH directories (none should be world-writable)

**Key principle:** PATH is trusted implicitly by command execution. An attacker who controls your PATH controls which code runs.
