## SUID/SGID

**Never use SUID/SGID bits on Bash scripts. Critical security prohibition with no exceptions.**

```bash
# ✗ NEVER do this
chmod u+s /usr/local/bin/myscript.sh  # SUID
chmod g+s /usr/local/bin/myscript.sh  # SGID

# ✓ Use sudo instead
sudo /usr/local/bin/myscript.sh
# In /etc/sudoers: username ALL=(ALL) NOPASSWD: /usr/local/bin/myscript.sh
```

**Rationale:**

- **IFS Exploitation**: Attacker controls word splitting with elevated privileges
- **PATH Manipulation**: Kernel uses caller's `PATH` to find interpreter, enabling trojan attacks
- **Library Injection**: `LD_PRELOAD`/`LD_LIBRARY_PATH` inject code before script execution
- **Shell Expansion**: Multiple expansion phases (brace, tilde, parameter, command, glob) exploitable
- **Race Conditions**: TOCTOU vulnerabilities in file operations
- **No Compilation**: Script source readable/modifiable, increasing attack surface

**Why dangerous:** SUID changes effective UID to file owner during execution. For scripts, kernel reads shebang, executes interpreter with script as argument—interpreter inherits privileges and processes expansions. This multi-step process creates attack vectors absent in compiled programs.

**Anti-Patterns:**

**1. PATH Attack (interpreter resolution):**
```bash
# SUID script sets secure PATH internally—irrelevant
#!/bin/bash
PATH=/usr/bin:/bin
tar -czf /backup/data.tar.gz /var/data
```
Attack:
```bash
mkdir /tmp/evil
cat > /tmp/evil/bash << 'EOT'
#!/bin/bash
cp -r /root/.ssh /tmp/stolen_keys
exec /bin/bash "$@"
EOT
chmod +x /tmp/evil/bash
export PATH=/tmp/evil:$PATH
/usr/local/bin/backup.sh
# Kernel uses CALLER's PATH—malicious bash runs as root BEFORE script's PATH is set
```

**2. Library Injection:**
```bash
# Attacker creates malicious shared library
cat > /tmp/evil.c << 'EOT'
void __attribute__((constructor)) init(void) {
    if (geteuid() == 0) system("cp /etc/shadow /tmp/shadow_copy");
}
EOT
gcc -shared -fPIC -o /tmp/evil.so /tmp/evil.c
LD_PRELOAD=/tmp/evil.so /usr/local/bin/report.sh
# Library runs with root privileges before script
```

**3. Symlink Race Condition:**
```bash
# SUID script checks file existence then writes
if [[ -f "$output_file" ]]; then die 1 "File exists"; fi
# Race window here!
echo "secret data" > "$output_file"
```
Attack: Loop creating symlink to /etc/passwd in race window—script writes to /etc/passwd.

**Safe Alternatives:**

**1. sudo with configured permissions:**
```bash
# /etc/sudoers.d/myapp
username ALL=(root) NOPASSWD: /usr/local/bin/myapp.sh
%admin ALL=(root) /usr/local/bin/backup.sh --backup-only
```

**2. Capabilities (compiled programs only):**
```bash
setcap cap_net_bind_service=+ep /usr/local/bin/myserver
# Grants specific privilege without full root
```

**3. Setuid wrapper (compiled C):**
```c
int main(int argc, char *argv[]) {
    setenv("PATH", "/usr/bin:/bin", 1);
    unsetenv("LD_PRELOAD");
    unsetenv("LD_LIBRARY_PATH");
    unsetenv("IFS");
    execl("/usr/local/bin/backup.sh", "backup.sh", argv[1], NULL);
    return 1;
}
```

**4. systemd service:**
```
[Service]
Type=oneshot
User=root
ExecStart=/usr/local/bin/myapp.sh
```

**Why sudo is safer:**
- Logging to /var/log/auth.log
- Credential timeout (15min)
- Granular control (commands, arguments, users)
- Environment sanitization (clears dangerous variables)
- Audit trail

**Detection:**
```bash
# Find SUID/SGID scripts (should return nothing)
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Edge Cases:**

1. **Modern Linux kernels ignore SUID on scripts by default**—don't rely on this; many Unix variants still honor them, legacy systems may be vulnerable
2. **Capabilities don't work on scripts**—only compiled programs; use sudo/wrapper for scripts

**Key principle:** If you think you need SUID on a shell script, you're solving the wrong problem. Redesign using sudo, PolicyKit, systemd services, or a compiled wrapper.
