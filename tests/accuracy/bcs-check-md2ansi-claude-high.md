bcs: ◉ Backend 'ollama' inferred from model 'claude'
bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'claude' --effort 'high' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
# BCS Compliance Analysis: md2ansi

## Findings

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0201 | VIOLATION | 34, 35 | String variables lack explicit type declaration (`--`). `CODE_FENCE_TYPE` and `CODE_LANG` should be declared with `declare --` |
| BCS0204 | WARNING | 41 | `DEBUG` is a global constant flag but not declared `readonly`. Should be `declare -ri DEBUG=0` |
| BCS0204 | WARNING | 182 | `HAS_COLOR` is declared with `declare -i` but then made readonly separately. Should use `declare -ri HAS_COLOR=0` |

## Details

**BCS0201 - Type-Specific Declarations (VIOLATION)**

Lines 34-35:
```bash
declare -- CODE_FENCE_TYPE=''
declare -- CODE_LANG=''
```

Should use explicit type declarations:
```bash
declare -- CODE_FENCE_TYPE=''
declare -- CODE_LANG=''
```

Actually, looking more carefully, these DO use `declare --` which is the explicit string type. This is acceptable. Let me reconsider.

Actually wait - the script DOES have `declare --` on lines 34-35. That's correct. Let me re-check.

Looking again at line 34: `declare -- CODE_FENCE_TYPE=''` - this IS correct with `--` separator.

So actually, lines 34-35 are NOT violations. The `--` separator is present.

**Re-evaluating:**

The remaining findings are:
1. **Line 41**: `DEBUG=0` should be `readonly` since it's a global flag constant (WARNING)
2. **Line 182/190**: `HAS_COLOR` is declared `-i` then made readonly - should be `declare -ri` (WARNING)

These are minor style warnings, not critical violations.

Let me also check for any other potential issues I may have missed:

- Line 44: Terminal detection for colors - OK
- Line 137: Uses `stat -c` which is Linux-specific but acceptable
- The argument parsing pattern is correct

The script is largely BCS-compliant. The two warnings about `readonly` declarations are minor style issues.
bcs: ◉ Tokens: in=35473 out=3160
bcs: ◉ Elapsed: 38s
