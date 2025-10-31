## Exception: One-Word Literals

**One-word literals (alphanumeric, `_`, `-`, `.`, `/` only) may be left unquoted in assignments/conditionals, but quoting is safer and recommended.**

**Rationale:** Acknowledges common practice while encouraging defensive programming - unquoted values risk bugs if changed.

**Qualifies:** No spaces/special chars (`*?[]{}$`"'\;&|<>()!#`), shouldn't start with `-`.

**Examples:**
```bash
#  Acceptable (but quoting better)
LEVEL=INFO
PATH=/usr/local
[[ "$status" == success ]]

#  Better - always quote
LEVEL='INFO'
PATH='/usr/local'
[[ "$status" == 'success' ]]
```

**Mandatory quoting:**
```bash
#  Must quote
MESSAGE='Hello world'    # spaces
PATTERN='*.txt'          # wildcards
EMAIL='user@domain.com'  # special chars
VALUE=''                 # empty
```

**Anti-pattern:**
```bash
#  Wrong - unquoted special/multi-word
EMAIL=admin@example.com  # @ is special
MESSAGE=File not found   # syntax error
```

**Best practice:** Quote everything except trivial cases. When in doubt, quote. Consistency eliminates mental overhead and prevents bugs.

**Ref:** BCS0402
