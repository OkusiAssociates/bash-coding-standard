<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.2 PATH hardening

Hard-code `PATH` early in privileged scripts (BCS1002).

```bash
declare -rx PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin'
```

- Prevents attacker-controlled PATH from changing which binary `cd`, `cp`, etc., resolves to.
- Order matters: place trusted directories first.
- Never include `.` (current directory) in PATH.
- For scripts running as root, this is mandatory; for user scripts, recommended.

`declare -rx` makes the value read-only **and** exported, so the hardened
PATH propagates to children and cannot be reassigned later in the script.
Combine with `IFS` reset (§20.3) — PATH parsing uses IFS in some legacy
constructs, and a tampered IFS can split a benign PATH into attacker-
controlled fragments.

```bash
# scenario: sudo inheritance — PATH is reset by secure_path, but not by sudo -E
sudo printenv PATH                  # ⇒ /usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin (secure_path)
sudo -E printenv PATH               # ⇒ inherits caller's PATH — DANGEROUS
sudo -i printenv PATH               # ⇒ login shell PATH from /root/.profile

# right — never trust inherited PATH; reset at the top of any privileged script
declare -rx PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/sbin:/usr/bin:/bin'
declare -rx IFS=$' \t\n'
```

The default `sudoers` `secure_path` line sanitises PATH for `sudo cmd`,
but `sudo -E` (preserve environment) and SUID binaries do not. Treat the
hardened-PATH assignment as mandatory boilerplate for any script that may
run with elevated privilege.

**See also**: §20.3 (IFS reset), §20.11 (privilege drop), BCS1002 (PATH security), BCS1003 (IFS).

#fin
