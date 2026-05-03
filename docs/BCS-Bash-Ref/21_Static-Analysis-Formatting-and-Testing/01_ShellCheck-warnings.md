<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.1 ShellCheck warnings

ShellCheck is the de facto bash static analyser.

- Invocation: `shellcheck -x script.bash`.
- `-x` follows `source` directives.
- Severity levels: error, warning, info, style.
- Each warning has a code (`SC2086`, `SC2155`, etc.) and a wiki page.
- Most-cited warnings: SC2086 (unquoted variable), SC2155 (declare and assign separately), SC2068 (use `"$@"` not `$@`), SC2250 (use braces).
- Gates: `shellcheck --severity=warning` for stricter CI.
- All BCS-compliant scripts must be ShellCheck-clean (BCS1201 hooks here).

```json
{
  "comments": [
    {
      "file": "script.bash",
      "line": 12,
      "column": 8,
      "level": "warning",
      "code": 2086,
      "message": "Double quote to prevent globbing and word splitting.",
      "fix": {
        "replacements": [
          { "line": 12, "column": 8, "endLine": 12, "endColumn": 12,
            "precedence": 1, "insertionPoint": "beforeStart", "replacement": "\"" },
          { "line": 12, "column": 12, "endLine": 12, "endColumn": 12,
            "precedence": 2, "insertionPoint": "afterEnd", "replacement": "\"" }
        ]
      }
    }
  ]
}
```

The `--format=json1` schema above is what `bcscheck -j` mirrors (§21.5).
Each comment carries a stable `code`, machine-readable `level`, and an
optional `fix` block that auto-fixers (`shellcheck -f diff`, `shfmt`,
editor plugins) can apply.

```yaml
# scenario: CI gate — fail the build on any warning-or-higher
- name: ShellCheck
  run: |
    shellcheck --severity=warning --shell=bash --external-sources \
      bin/*.bash lib/*.bash
```

`--severity=warning` rejects `error` and `warning` levels but allows
`info` / `style`; `--shell=bash` prevents accidental POSIX-mode analysis
of scripts without a `#!/bin/bash` shebang; `--external-sources` (alias
`-x`) lets ShellCheck cross files.

**See also**: §21.2 (directives), §21.3 (source-path), §21.5 (`bcscheck`), BCS1201 (formatting).

#fin
