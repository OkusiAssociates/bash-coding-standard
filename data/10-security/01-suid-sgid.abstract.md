## SUID/SGID

**Never use SUID/SGID bits on Bash scripts—critical security prohibition, no exceptions.**

### Why Dangerous

Multi-step execution (kernel→interpreter→script) creates attack vectors:
- **PATH manipulation**: Kernel uses caller's PATH to find interpreter → trojan attacks
- **LD_PRELOAD/LD_LIBRARY_PATH**: Inject malicious code before script runs
- **IFS exploitation**: Control word splitting with elevated privileges

### Anti-Patterns

```bash
# ✗ NEVER
chmod u+s script.sh  # SUID
chmod g+s script.sh  # SGID
```

### Safe Alternatives

```bash
# ✓ Use sudo with sudoers config
sudo /usr/local/bin/myscript.sh

# /etc/sudoers.d/myapp:
# user ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh
```

Other options: PolicyKit (`pkexec`), systemd services, compiled C wrappers (sanitize env).

### Detection

```bash
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Key principle:** If you think you need SUID on a script, redesign using sudo/PolicyKit/systemd.

**Ref:** BCS1001
