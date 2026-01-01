## SUID/SGID

**Never use SUID/SGID bits on Bash scripts—no exceptions.**

```bash
# ✗ NEVER
chmod u+s script.sh  # SUID
chmod g+s script.sh  # SGID

# ✓ Use sudo instead
sudo /usr/local/bin/script.sh
```

**Why prohibited:**
- **IFS exploitation**: Attacker controls word splitting with elevated privileges
- **PATH attack**: Kernel uses caller's PATH to find interpreter—trojan injection before script's PATH is set
- **LD_PRELOAD**: Malicious libraries execute with root privileges before script runs
- **Race conditions**: TOCTOU vulnerabilities in file operations

**Safe alternatives:**
- `sudo` with `/etc/sudoers.d/` granular permissions
- Compiled C wrapper that sanitizes environment
- systemd service with `User=root`
- Linux capabilities for compiled binaries

**Anti-patterns:**
- `chmod 4755 script.sh` �' catastrophic security hole
- Assuming modern kernels ignore SUID on scripts �' many Unix variants honor it

**Audit:** `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script`

**Ref:** BCS1001
