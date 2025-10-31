## SUID/SGID

**Never use SUID (Set User ID) or SGID (Set Group ID) bits on Bash scripts. This is a critical security prohibition with no exceptions.**

```bash
#  NEVER do this - catastrophically dangerous
chmod u+s /usr/local/bin/myscript.sh  # SUID
chmod g+s /usr/local/bin/myscript.sh  # SGID

#  Correct - use sudo for elevated privileges
sudo /usr/local/bin/myscript.sh

#  Correct - configure sudoers for specific commands
# In /etc/sudoers:
# username ALL=(ALL) NOPASSWD: /usr/local/bin/myscript.sh
```

**Rationale:**

- **IFS Exploitation**: Attacker manipulates `IFS` to control word splitting and execute commands with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter, enabling trojan attacks even when script sets secure `PATH`
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject malicious code before script execution
- **Shell Expansion**: Brace, tilde, parameter, command substitution, and glob expansions create attack vectors
- **Race Conditions**: TOCTOU vulnerabilities in file operations
- **Interpreter Vulnerabilities**: Bash bugs exploitable when running with elevated privileges
- **No Compilation**: Readable, modifiable source increases attack surface

**Why SUID/SGID bits are dangerous on shell scripts:**

For compiled binaries, the kernel loads machine code directly. For shell scripts, the kernel: (1) reads shebang, (2) executes interpreter with SUID/SGID privileges, (3) interpreter processes script performing expansions. This multi-step process creates attack vectors absent in compiled programs.

**Attack Examples:**

**1. IFS Exploitation:**

```bash
# Vulnerable SUID script (owned by root)
#!/bin/bash
# /usr/local/bin/vulnerable.sh (SUID root)
set -euo pipefail

service_name="$1"
status=$(systemctl status "$service_name")
echo "$status"
```

**Attack:**
```bash
export IFS='/'
./vulnerable.sh "../../etc/shadow"
# With IFS='/', path splits into words, potentially exposing sensitive files
```

**2. PATH Attack (interpreter resolution):**

```bash
# SUID script: /usr/local/bin/backup.sh (owned by root)
#!/bin/bash
set -euo pipefail
PATH=/usr/bin:/bin  # Script sets secure PATH

tar -czf /backup/data.tar.gz /var/data
```

**Attack:**
```bash
# Attacker creates malicious bash
mkdir /tmp/evil
cat > /tmp/evil/bash << 'EOF'
#!/bin/bash
cp -r /root/.ssh /tmp/stolen_keys
exec /bin/bash "$@"
EOF
chmod +x /tmp/evil/bash

export PATH=/tmp/evil:$PATH
/usr/local/bin/backup.sh
# Kernel uses caller's PATH to find interpreter - attacker's code runs as root BEFORE script's PATH is set
```

**3. Library Injection Attack:**

```bash
# SUID script: /usr/local/bin/report.sh
#!/bin/bash
set -euo pipefail

echo "System Report" > /root/report.txt
df -h >> /root/report.txt
```

**Attack:**
```bash
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
# Malicious library runs with root privileges before script
```

**4. Command Injection via Unquoted Variables:**

```bash
# Vulnerable SUID script
#!/bin/bash
# /usr/local/bin/cleaner.sh (SUID root)

directory="$1"
find "$directory" -type f -mtime +30 -delete
```

**Attack:**
```bash
/usr/local/bin/cleaner.sh "/tmp -o -name 'shadow' -exec cat /etc/shadow > /tmp/shadow_copy \;"
# Injected find command exfiltrates /etc/shadow
```

**5. Symlink Race Condition:**

```bash
# Vulnerable SUID script
#!/bin/bash
# /usr/local/bin/secure_write.sh (SUID root)
set -euo pipefail

output_file="$1"

if [[ -f "$output_file" ]]; then
  die 1 'File already exists'
fi

# Race condition window here!
echo "secret data" > "$output_file"
```

**Attack:**
```bash
# Terminal 1: Run script repeatedly
while true; do
  /usr/local/bin/secure_write.sh /tmp/output 2>/dev/null && break
done

# Terminal 2: Create symlink in race window
while true; do
  rm -f /tmp/output
  ln -s /etc/passwd /tmp/output
done
# Script writes to /etc/passwd if timing is right
```

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
# Allows binding to ports < 1024 without full root
```

**3. Use setuid wrapper (compiled C program):**

```bash
# /usr/local/bin/backup_wrapper.c (compiled and SUID)
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

**4. Use PolicyKit (pkexec):**

```bash
pkexec /usr/local/bin/system-config.sh
```

**5. Use systemd service:**

```bash
# /etc/systemd/system/myapp.service
[Unit]
Description=My Application Service

[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh
RemainAfterExit=no

# User triggers: systemctl start myapp.service
```

**Detection and Prevention:**

```bash
# Find SUID/SGID shell scripts (should return nothing)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script

# List all SUID files
find / -type f -perm -4000 -ls 2>/dev/null

# Prevent accidental SUID
install -m 755 myscript.sh /usr/local/bin/
# Never use -m 4755 or chmod u+s on shell scripts
```

**Why sudo is safer:**

Sudo provides: (1) logging to /var/log/auth.log, (2) credential timeout, (3) granular control, (4) environment sanitization, (5) audit trail.

```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/backup.sh
# Logged: "username : TTY=pts/0 ; PWD=/home/username ; USER=root ; COMMAND=/usr/local/bin/backup.sh"
```

**Summary:**

- **Never** use SUID or SGID on shell scripts under any circumstances
- Shell scripts have too many attack vectors to be safe with elevated privileges
- Use `sudo` with carefully configured permissions
- For compiled programs needing specific privileges, use capabilities
- Use setuid wrappers (compiled C) if absolutely necessary to execute script with privileges
- Audit systems regularly: `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \;`
- Modern Linux (since ~2005) ignores SUID on scripts by default, but many Unix variants still honor them

**Key principle:** If you think you need SUID on a shell script, you're solving the wrong problem. Redesign using sudo, PolicyKit, systemd services, or a compiled wrapper.
