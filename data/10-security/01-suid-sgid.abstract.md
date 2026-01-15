## SUID/SGID

**Never use SUID/SGID bits on Bash scripts—critical security prohibition, no exceptions.**

### Why Dangerous

SUID/SGID changes effective UID/GID to file owner during execution. For scripts, kernel executes interpreter with elevated privileges, then interpreter processes script—creating attack vectors:

- **IFS/PATH manipulation**: Attacker controls word splitting or substitutes malicious interpreter before script's PATH is set
- **LD_PRELOAD injection**: Malicious code runs with root privileges before script executes
- **Race conditions**: TOCTOU vulnerabilities in file operations

### Correct Approach

```bash
# ✗ NEVER
chmod u+s /usr/local/bin/myscript.sh

# ✓ Use sudo with sudoers config
sudo /usr/local/bin/myscript.sh
# /etc/sudoers.d/myapp:
# username ALL=(root) NOPASSWD: /usr/local/bin/myscript.sh
```

### Anti-Patterns

| Wrong | Right |
|-------|-------|
| `chmod u+s script.sh` | Configure sudoers, use `sudo` |
| `chmod g+s script.sh` | Use PolicyKit, systemd service, or compiled wrapper |

### Detection

```bash
find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script
```

**Key principle:** If you need SUID on a script, redesign using sudo, PolicyKit, systemd, or compiled wrapper.

**Ref:** BCS1001
