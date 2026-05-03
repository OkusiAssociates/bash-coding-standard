<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 23.3 Bash vs dash

`dash` is the **D**ebian **A**lmquist **SH**ell, used as `/bin/sh` on
Debian, Ubuntu, and most of their derivatives. It is deliberately small,
deliberately POSIX-only, and deliberately fast — typically 5–10× faster
to start than bash. The tradeoff is that nearly every modern bash
convenience is missing: no arrays, no `[[ ]]`, no `local` declarations
beyond the single keyword, no `$'...'`, no process substitution, no
brace expansion of lists.

A bash script with `#!/bin/bash` always runs under bash regardless of
what `/bin/sh` points at, so the dash-vs-bash question is only ever
relevant when:

- writing a script with `#!/bin/sh` (init scripts, systemd `ExecStart=`
  shell snippets, container entry-points, `postinst` hooks);
- sourcing a config file (e.g. `/etc/default/foo`) from a sh-style
  context;
- distributing a script that must run on minimal images (Alpine
  defaults `/bin/sh` to BusyBox ash, similarly POSIX-only).

For everything else, write bash. The dash-portable subset is a
deliberate constraint, not an accidental one.

### checkbashisms — the Debian auditor

The `checkbashisms` script (Debian package `devscripts`) scans a script
for constructs that work in bash but fail in dash. It is the standard
test for "is this `#!/bin/sh` script actually portable?"

```bash
# scenario: audit an /etc/init.d script before shipping
$ checkbashisms /etc/init.d/myservice
possible bashism in /etc/init.d/myservice line 14 (echo -e):
  echo -e "starting myservice\n"
possible bashism in /etc/init.d/myservice line 22 ([[ )):
  if [[ -f /var/run/myservice.pid ]]; then
possible bashism in /etc/init.d/myservice line 31 ($' ):
  printf $'\t%s\n' "$pid"
```

`checkbashisms -p` is stricter (flags POSIX-undefined behaviour even
where it happens to work in dash); `-x` follows `.` (dot) sources.

### A worked dash-vs-bash failure

The classic case is `[[`: bash users instinctively reach for it; dash
treats `[[` as a syntax error because there is no such builtin.

```bash
# script.sh
#!/bin/sh
file=/etc/passwd
if [[ -f "$file" ]]; then
  echo found
fi

$ bash script.sh
found

$ dash script.sh
script.sh: 3: [[: not found
```

Other common dashisms-by-accident: `local var=value` works (one keyword,
one assignment) but `local -i n=0` does not (dash has no `-i`); `read -r
-a arr` fails because dash has no arrays; `${var,,}` lowercase expansion
is a syntax error; `function name() { ... }` parses but only with the
`name()` form, not the `function` keyword.

The simplest defensive measure is to declare intent in the shebang.
`#!/bin/sh` means "I claim this is portable" and invites
`checkbashisms`. `#!/bin/bash` (or `#!/usr/bin/env bash`) means "I'm
using bash features deliberately" and exempts the script from the
portable subset.

**See also**: §23.1 (Bash vs POSIX sh) for the underlying spec; §23.2
(bashisms list) for the catalogue checkbashisms is checking against;
BCS0102 (shebang) for the BCS shebang convention.

#fin
