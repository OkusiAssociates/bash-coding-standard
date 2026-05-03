<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.1 Threat model

Bash scripts run with the privileges of their invoker, frequently root, and
inherit a process environment they did not choose. Before reaching for
mitigations, classify the threats that actually apply to the script in front
of you; the remaining chapters of Part 20 address each class concretely.

The threat classes below are not mutually exclusive — a single CVE often
chains two or three. Each class is illustrated by one minimal vector that
captures the essence of the attack; the deeper treatment is cross-referenced.

**User-input attacks** — untrusted data flows into command construction. The
classic shell footgun: a string the script believes to be a filename is in
fact a fragment of shell. See §20.5 for the full catalogue and §20.6 for the
allow-list response.

```bash
# scenario: log filename arrives from an HTTP query parameter
read -r logfile        # attacker supplies: x; rm -rf "$HOME"
cat $logfile           # ⇒ unquoted expansion executes the trailing command
```

**Path-based attacks** — `PATH` resolves a bare command name to a binary the
script did not intend (BCS1002). A writable directory early in `PATH` is
sufficient.

```bash
# scenario: PATH=/tmp:/usr/bin and /tmp/ls exists
ls /var          # ⇒ runs /tmp/ls, not /usr/bin/ls
```

**TOCTOU races** — time-of-check vs time-of-use. The window between a test
and the operation it guards is exploitable; see §20.13.

```bash
# scenario: between -w test and >> append, attacker swaps the file
[[ -w $f ]] && echo "$payload" >> "$f"   # ⇒ append lands in the substituted target
```

**Symlink attacks** — a special case of TOCTOU, distinct enough to merit its
own chapter (§20.13). Attacker controls a path component, typically inside a
shared directory such as `/tmp`.

```bash
# scenario: predictable temp path
echo "$secret" > /tmp/myscript.$$    # ⇒ symlink to /etc/passwd, root truncates passwd
```

**Environment injection** — attacker controls environment variables that the
script reads or that bash itself consumes (`IFS`, `BASH_ENV`, `LD_PRELOAD`,
`PATH`). See §20.3 (IFS), §20.2 (PATH), and §20.1.7 below for the env-scrub
mandate (BCS1007).

```bash
# scenario: attacker exports IFS before invoking the script
IFS=$'\n,' ./script.bash          # ⇒ word splitting now treats commas as separators
```

**Tempfile attacks** — predictable filenames, races in world-writable
directories, leftovers retaining secrets. The canonical remedy is `mktemp`
(BCS1006) plus a cleanup trap; full pattern in §20.13.

```bash
# scenario: predictable filename in /tmp
out=/tmp/report.$$                 # ⇒ guessable, hijackable
```

**Privilege escalation** — SUID on scripts (Linux refuses; §20.8), sudo
invocations that trust caller-controlled data, and "root-on-behalf" wrappers
that fail to validate their caller's intent. The remedies are early
privilege drop (§20.11) and minimal sudoers entries (§20.8).

```bash
# scenario: sudo wrapper trusts $1 as a path
sudo cp -- "$1" /etc/important.conf   # ⇒ caller passes /etc/shadow, gets root copy
```

**Resource-exhaustion attacks** — fork bombs, log-floods, runaway recursion.
Often dismissed as DoS-only, but in privileged contexts they enable race
windows that other attacks ride on.

```bash
# scenario: untrusted input drives a recursive descent
find "$user_dir" -exec process {} \;   # ⇒ deep symlink loop exhausts inodes
```

For each class, ask three questions before writing a mitigation:
1. What untrusted boundary does data cross to reach this script?
2. What privileges does this script hold that the data's source does not?
3. Which BCS rule (BCS1001–BCS1007) names the discipline I am about to apply?

If you cannot answer all three, the mitigation is premature.

**See also**: §20.4 eval avoidance, §20.5 command-injection vectors, §20.6
input validation, §20.13 symlink races, BCS1001–BCS1007.

#fin
