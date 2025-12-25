## SUID/SGID

**Never use SUID/SGID bits on Bash scripts - catastrophically dangerous with no exceptions.**

```bash
# ✗ NEVER
chmod u+s script.sh  # SUID
chmod g+s script.sh  # SGID

# ✓ Use sudo
sudo script.sh
# Or configure: username ALL=(root) NOPASSWD: /path/script.sh
```

**Rationale:** Kernel executes interpreter with elevated privileges before script runs, creating attack vectors: IFS exploitation splits words maliciously; caller's PATH finds trojan interpreter before script's PATH sets; `LD_PRELOAD` injects code; race conditions on file operations; shell expansions exploitable; no compilation means readable/modifiable source.

**Attack example:**
```bash
# Attacker's trojan in /tmp/evil/bash runs as root BEFORE script's PATH setting
export PATH=/tmp/evil:$PATH
./suid-script.sh  # Kernel finds /tmp/evil/bash via caller's PATH
```

**Safe alternatives:** sudo with `/etc/sudoers.d/` config; capabilities on compiled programs (`setcap`); compiled C wrapper that sanitizes environment then `execl()` script; PolicyKit; systemd service.

**Detection:** `find / -type f \( -perm -4000 -o -perm -2000 \) -exec file {} \; | grep -i script` should return nothing.

**Modern Linux ignores SUID on scripts but don't rely on it - many Unix variants honor it.**

**Ref:** BCS1201
