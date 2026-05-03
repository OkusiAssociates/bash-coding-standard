<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.8 Here-documents

A here-document synthesises stdin from inline text. The form is
`cmd <<DELIM`, followed by lines of body text, terminated by a line
containing exactly *DELIM* with no leading or trailing whitespace
(unless `<<-` is used). Whether the body undergoes expansion depends
entirely on the *quoting of the delimiter*; this is the rule most often
mis-remembered.

### Forms

- `<<DELIM` — body undergoes parameter, command, and arithmetic
  expansion before being delivered to *cmd*.
- `<<'DELIM'`, `<<"DELIM"`, `<<\DELIM` — body is delivered *literally*,
  no expansions performed. Single quotes, double quotes, and a
  backslash-escaped delimiter are all equivalent here-doc-quoting forms.
- `<<-DELIM` — *leading tab characters* (and only tabs, not spaces) are
  stripped from each body line and from the closing delimiter line. The
  hyphen lets the body be indented within an `if` / function block
  without the indentation appearing in the synthesised input.
- `<<-'DELIM'` — combine: tab-strip *and* no expansion.

### Quoted vs unquoted delimiter — the most-missed rule

Trace the same here-doc body through both quoting forms:

```bash
# scenario: same body, different delimiter quoting → very different output
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -- name='Biksu'

cat <<UNQUOTED
Hello, $name. Today is $(date +%Y-%m-%d).
UNQUOTED
# ⇒ Hello, Biksu. Today is 2026-05-03.

cat <<'QUOTED'
Hello, $name. Today is $(date +%Y-%m-%d).
QUOTED
# ⇒ Hello, $name. Today is $(date +%Y-%m-%d).
```

The single-quoted form is essential for embedding scripts, SQL, awk
programs, or anything containing literal `$` or backslashes. Forget it
and a stray `$path` in the body becomes the empty string at the worst
possible moment (BCS0304).

### `<<-` and the tab-strip rule

`<<-` strips *only tabs*, not spaces. Mixed indentation defeats it
silently — the tabs are stripped, the spaces remain, and the input has
ragged left-margin whitespace that breaks tools expecting fixed
formatting (Python, indent-sensitive YAML, …):

```bash
# scenario: indented heredoc inside a function — `<<-` strips leading tabs
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

emit_config() {
        # NOTE: leading whitespace on body lines must be TABS, not spaces
        cat <<-'EOF'
	[server]
	host = localhost
	port = 8080
	EOF
}

emit_config
# ⇒ [server]
# ⇒ host = localhost
# ⇒ port = 8080
```

Editor configuration matters: many "soften tabs to spaces" settings
silently break `<<-`. The bash convention is to leave heredoc bodies
flush against column 1 in source, accepting the reduced visual nesting,
*unless* the script's editorconfig pins tab characters specifically.

### Multiple here-docs in one pipeline

Each component of a pipeline may have its own here-doc; they are queued
left-to-right and dispatched to the matching command:

```bash
# scenario: two here-docs, one per pipeline component
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

cat <<EOF1 | tr a-z A-Z | cat <<EOF2 - <<EOF3
first heredoc, lowered
EOF1
prologue
EOF2
epilogue
EOF3
# ⇒ prologue
# ⇒ FIRST HEREDOC, LOWERED
# ⇒ epilogue
```

The middle component's `cat <<EOF2 - <<EOF3` reads `EOF2`, then stdin
(`-`, the upstream pipe), then `EOF3`. This pattern is rare in practice
but is the only way to splice fixed prologue/epilogue around piped
input without `printf`/`echo` boilerplate.

### Implementation note

Bash buffers the here-doc body, then on `exec` either writes it to a
temp file and opens that file as fd 0, or — for short bodies on modern
Linux — feeds it through an anonymous pipe. The size threshold is
implementation-defined; scripts should not depend on either path.

### Common sinks

Here-docs are the standard mechanism for feeding inline scripts to
secondary interpreters. The quoted-delimiter form is essential for any
sink that has its own `$` syntax — the entire point is that bash
*should not* expand the body:

- `cat <<'EOF' >script.py … EOF` — write a literal Python script.
- `mysql -uroot <<'SQL' … SQL` — feed a SQL batch unchanged.
- `awk -f /dev/stdin <<-'AWK' … AWK` — inline an awk programme.
- `ssh host bash <<'REMOTE' … REMOTE` — run a literal bash script on
  the remote host with no client-side expansion.

Conversely, the *unquoted* form is right when the script genuinely
wants bash-side substitution — e.g. injecting the value of a local
`$config_path` into an emitted config file before delivering to a
non-shell consumer. Choose deliberately; mistakes here are the
single most common heredoc bug.

**See also**: §6.9 (here-strings — single-line variant), §3.4 (BCS0304
heredoc quoting rules), §11.x (process exec semantics), §10.x
(redirection in functions).

#fin
