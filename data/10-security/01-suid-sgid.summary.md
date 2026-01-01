## SUID/SGID

**Never use SUID or SGID bits on Bash scripts. This is a critical security prohibition with no exceptions.**

```bash
# ✗ NEVER do this - catastrophically dangerous
chmod u+s /usr/local/bin/myscript.sh  # SUID
chmod g+s /usr/local/bin/myscript.sh  # SGID

# ✓ Correct - use sudo for elevated privileges
sudo /usr/local/bin/myscript.sh

# ✓ Correct - configure sudoers for specific commands
# In /etc/sudoers:
# username ALL=(ALL) NOPASSWD: /usr/local/bin/myscript.sh
```

**Rationale:**

- **IFS Exploitation**: Attacker can set `IFS` to control word splitting with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter, allowing trojan attacks
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject malicious code before script execution
- **Shell Expansion**: Multiple Bash expansions (brace, tilde, parameter, command, glob) can be exploited
- **Race Conditions**: TOCTOU vulnerabilities in file operations
- **Interpreter Vulnerabilities**: Bash bugs exploitable when running with elevated privileges
- **No Compilation**: Script source readable and modifiable, increasing attack surface

**Why dangerous:** For shell scripts, the kernel executes the interpreter with SUID/SGID privileges, then the interpreter processes the script—this multi-step process creates attack vectors that don't exist for compiled programs.

**Attack Examples:**

**1. PATH Attack (interpreter resolution):**

```bash
# SUID script: /usr/local/bin/backup.sh (owned by root)
#!/bin/bash
set -euo pipefail
PATH=/usr/bin:/bin  # Script sets secure PATH
tar -czf /backup/data.tar.gz /var/data
```

Attack:
```bash
# Attacker creates malicious bash
mkdir /tmp/evil
cat > /tmp/evil/bash << 'EOF'
#!/bin/bash
cp -r /root/.ssh /tmp/stolen_keys  # Malicious action
exec /bin/bash "$@"                # Then execute real script
EOF
chmod +x /tmp/evil/bash

export PATH=/tmp/evil:$PATH
/usr/local/bin/backup.sh
# Kernel uses caller's PATH - attacker's code runs as root BEFORE script's PATH is set
```

**2. Library Injection Attack:**

```bash
# Attacker creates malicious shared library
cat > /tmp/evil.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void __attribute__((constructor)) init(void) {
    if (geteuid() == 0) {
        system("cp /etc/shadow /tmp/shadow_copy");
        system("chmod 644 /tmp/shadow_copy");
    }
}
EOF

gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
LD_PRELOAD=/tmp/evil.so /usr/local/bin/report.sh
# Malicious library runs with root privileges before the script
```

**3. Symlink Race Condition:**

```bash
# Vulnerable SUID script
#!/bin/bash
set -euo pipefail
output_file=$1

if [[ -f "$output_file" ]]; then
  die 1 "File ${output_file@Q} already exists'
fi
# Race condition window here!
echo "secret data" > "$output_file"
```

Attack: Attacker creates symlink to `/etc/passwd` between check and write.

**Safe Alternatives:**

**1. Use sudo with configured permissions:**
```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/myapp.sh
%admin ALL=(root) /usr/local/bin/backup.sh --backup-only
```

**2. Use capabilities (compiled programs only):**
```bash
setcap cap_net_bind_service=+ep /usr/local/bin/myserver
```

**3. Use a setuid wrapper (compiled C):**
```bash
int main(int argc, char *argv[]) {
    if (argc != 2) return 1;
    setenv("PATH", "/usr/bin:/bin", 1);
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    unsetenv("IFS");
    execl("/usr/local/bin/backup.sh", "backup.sh", argv[1], NULL);
    return 1;
}
```

**4. Use systemd service:**
```bash
# /etc/systemd/system/myapp.service
[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh
```

**Detection:**

```bash
# Find SUID/SGID scripts (should return nothing!)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script

# In deployment, explicitly ensure no SUID:
install -m 755 myscript.sh /usr/local/bin/
```

**Why sudo is safer:** Provides logging, timeout, granular control, environment sanitization, and audit trail.

**Key principle:** If you think you need SUID on a shell script, you're solving the wrong problem. Redesign using sudo, PolicyKit, systemd services, or a compiled wrapper.
