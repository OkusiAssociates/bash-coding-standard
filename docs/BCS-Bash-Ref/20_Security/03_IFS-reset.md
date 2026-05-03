<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 20.3 IFS reset

Set IFS to known safe value at script start (BCS1003).

```bash
declare -rx IFS=$' \t\n'
```

- Default IFS is space-tab-newline; explicit reset asserts this.
- Inherited IFS could split words unexpectedly.
- Save and restore around scoped changes.

```bash
# scenario: IFS-injection demo — caller exports a malicious IFS
export IFS=':'                       # attacker sets this in environment

# vulnerable script reads PATH-like data and word-splits it
input='alpha beta gamma'
for word in $input; do echo "<$word>"; done
# ⇒ <alpha beta gamma>             (no split — IFS no longer contains space)

# right — reset IFS at script entry
declare -rx IFS=$' \t\n'
for word in $input; do echo "<$word>"; done
# ⇒ <alpha>
# ⇒ <beta>
# ⇒ <gamma>
```

For scoped changes (e.g., to read CSV), save and restore explicitly:

```bash
# scenario: temporary IFS change with restore
parse_csv() {
  local -- saved_ifs="$IFS"
  IFS=','
  read -r -a fields <<<"$1"
  IFS="$saved_ifs"
  printf '%s\n' "${fields[@]}"
}
```

Or — preferred — use a `local IFS=…` inside the function so the change is
automatically scoped to the function body:

```bash
parse_csv() {
  local -- IFS=','
  local -a fields
  read -r -a fields <<<"$1"
  printf '%s\n' "${fields[@]}"
}
```

`local IFS` shadows the global; on function return the original is
restored automatically — no manual save/restore needed.

**See also**: §20.2 (PATH hardening), §05.07 (word splitting), BCS1003 (IFS safety).

#fin
