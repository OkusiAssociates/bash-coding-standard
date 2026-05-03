<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XX — Security

*Bash scripts run with the privileges of the invoking user — often root. This Part documents the threat model, the attack surface, and the defensive disciplines.*

---

## Chapters

1. [20.1 Threat model](01_Threat-model.md) — Different scripts face different threats; understand which apply.
2. [20.2 PATH hardening](02_PATH-hardening.md) — Hard-code `PATH` early in privileged scripts.
3. [20.3 IFS reset](03_IFS-reset.md) — Set IFS to known safe value at script start.
4. [20.4 `eval` avoidance](04_eval-avoidance.md) — `eval` re-parses its argument as shell input.
5. [20.5 Command injection vectors](05_Command-injection-vectors.md) — Where attacker-controlled data becomes attacker-executed code.
6. [20.6 Input validation](06_Input-validation.md) — Allow-list, never deny-list.
7. [20.7 Quoting under `set -u`](07_Quoting-under-set-u.md) — Quoted unset variables expand to nothing; unquoted may error.
8. [20.8 SUID restrictions](08_SUID-restrictions.md) — SUID on shell scripts is forbidden by Linux.
9. [20.9 Secrets handling](09_Secrets-handling.md) — Storing and passing credentials.
10. [20.10 `noclobber`](10_noclobber.md) — `set -o noclobber` (or `set -C`) prevents `>` from overwriting existing files.
11. [20.11 Privilege drop](11_Privilege-drop.md) — Running parts of a script with reduced privileges.
12. [20.12 Sanitising filenames](12_Sanitising-filenames.md) — Filenames are bytes; bytes can be ugly.
13. [20.13 Symlink races](13_Symlink-races.md) — Attacker substitutes a symlink between your check and your action.
14. [20.14 Restricted shell mode](14_Restricted-shell-mode.md) — `bash -r` or `bash --restricted` runs in restricted mode.

---

← Previous: [Part XIX — Performance](../19_Performance/index.md)

Next: [Part XXI — Static Analysis, Formatting, and Testing](../21_Static-Analysis-Formatting-and-Testing/index.md) →

#fin
