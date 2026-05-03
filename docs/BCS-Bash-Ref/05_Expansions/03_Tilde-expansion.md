<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 5.3 Tilde expansion

Expands an unquoted `~` (or `~user`) at the **start of a word**, or
immediately after `:` / `=` in an *assignment context*, to the
appropriate home directory. Phase 2 of the expansion order (§5.1).
The trap is that quoting suppresses tilde expansion entirely — and so
does an interior tilde (mid-word) outside of assignments.

### Forms

- `~` (bare) — `$HOME`.
- `~+` — `$PWD`.
- `~-` — `$OLDPWD`.
- `~user` — `user`'s home from `/etc/passwd` (or NSS).
- `~+/path`, `~-/path`, `~user/path` — concatenation; the prefix is
  expanded, the rest is appended verbatim.
- In assignments only: `PATH=~/bin:~/lib:$PATH` — every `~` after `=`
  or `:` expands. This is the *only* mid-word context where tilde
  expansion happens.

### Quoted versus unquoted

```bash
# scenario: tilde expands only when unquoted, at the start of a word
#!/usr/bin/env bash
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

# unquoted at start of word — expanded
echo ~/bin                          # ⇒ /home/u/bin

# quoted — NOT expanded (literal tilde)
echo "~/bin"                        # ⇒ ~/bin
echo '~/bin'                        # ⇒ ~/bin

# mid-word in a *command* argument — NOT expanded
echo /opt/~/bin                     # ⇒ /opt/~/bin

# mid-word in an *assignment* (after `=` or `:`) — expanded
PATH=~/bin:~/local/bin:$PATH        # both `~/`s expand

# Within ${var:-default} the default is subject to tilde expansion
echo "${UNSET:-~/fallback}"         # ⇒ /home/u/fallback   (unquoted in default)

# Inside a *variable's value*, tilde is literal — no re-expansion
declare -- p='~/bin'
echo "$p"                           # ⇒ ~/bin   (no expansion — phase already past)
cd "$p" 2>&1 || echo 'no such directory'
# ⇒ no such directory   (the literal "~/bin" does not exist)
```

The last case is the most-encountered footgun: a config-file value of
`~/bin` is read as the four literal characters and is **not** expanded
when later used as an argument. Use `${p/#~/$HOME}` (§5.4) or
`HOME=$HOME envsubst` to expand explicitly when reading user input.

### Assignment-context tilde

Tilde expansion in assignments is what makes `PATH=~/bin:$PATH` work:

```bash
# scenario: PATH-style colon-list assignments
declare -x PATH=~/bin:~/local/bin:/usr/local/bin:/usr/bin:/bin
echo "$PATH"
# ⇒ /home/u/bin:/home/u/local/bin:/usr/local/bin:/usr/bin:/bin

# Same applies to other colon-separated path variables:
declare -x MANPATH=~/share/man:/usr/share/man
declare -x LIBRARY_PATH=~/lib:/usr/local/lib
```

The expansion fires after `=` and after every `:`. It does **not** fire
in a `cmd VAR=~user/x` *command-prefix* assignment unless `VAR` is in
Bash's list of "tilde-expanding" assignment builtins
(`declare`/`local`/`export`/`readonly`/`typeset`/`alias`).

### `~+` and `~-` — current and previous directory

`~+` is just `$PWD`; `~-` is `$OLDPWD` (set by every successful `cd`):

```bash
cd /var/log
cd /etc
echo ~+        # ⇒ /etc          (current = $PWD)
echo ~-        # ⇒ /var/log      (previous = $OLDPWD)
cd ~-          # toggles back
```

Useful when scripting a "do work in dir B, return to dir A" pattern
without saving a variable. In BCS scripts the explicit `pushd`/`popd`
or `( cd "$dir"; … )` subshell forms are clearer (§7.x).

### BCS posture

- Never quote the leading `~` you intend to expand (BCS0301).
- Treat `~` in user-supplied input as a literal — expand it explicitly
  via `${p/#~/$HOME}` (BCS1005, §5.4) before use.
- Prefer `$HOME` over `~` in non-trivial scripts: `$HOME/.config/bcs`
  is unambiguous; `~/.config/bcs` works but eye-tracks worse and is
  fragile under indirect expansion.
- For `cd` paired with a return, prefer `(cd "$dir"; …)` subshells
  over `~+`/`~-` global state.

**See also**: §5.1 (expansion order), §5.4 (`${var/#~/$HOME}` rewrite
form), §4.4 (`HOME`, `PWD`, `OLDPWD`), §7.x (`pushd`/`popd`).

#fin
