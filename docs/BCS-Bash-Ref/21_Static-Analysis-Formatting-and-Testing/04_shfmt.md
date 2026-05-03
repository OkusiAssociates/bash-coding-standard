<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 21.4 `shfmt`

A bash formatter, analogous to `gofmt`.

- Invocation: `shfmt -d script.bash` (diff mode).
- `-i 2` — 2-space indentation (BCS1201).
- `-ci` — switch case indented.
- `-s` — simplify (e.g., remove redundant `$()`).
- `-bn` — binary operator at start of next line.
- `shfmt -w` — write changes (after review).
- Pre-commit integration: reject any commit with shfmt diffs.

```ini
# .editorconfig — flags for editor + shfmt invocation
[*.bash]
indent_style = space
indent_size = 2
end_of_line = lf
trim_trailing_whitespace = true
insert_final_newline = true

# Equivalent shfmt invocation (BCS canonical):
#   shfmt -i 2 -ci -bn -s -d script.bash
```

```yaml
# scenario: pre-commit hook rejecting unformatted bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/scop/pre-commit-shfmt
    rev: v3.7.0
    hooks:
      - id: shfmt
        args: ['-i', '2', '-ci', '-bn', '-s', '-d']
```

Run `pre-commit install` once; thereafter every `git commit` runs
`shfmt -d` and rejects on non-zero diff. Combine with the §21.6
shellcheck hook for full lint+format gating.

**See also**: §21.6 (pre-commit hooks), §21.7 (CI integration), BCS1201 (formatting).

#fin
