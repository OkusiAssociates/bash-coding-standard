bcs: ◉ Backend 'ollama' inferred from model 'minimax-m2.7:cloud'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'minimax-m2.7:cloud' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
Looking at this script, I need to check each line against the BCS rules.

## Analysis

**Script Purpose**: This is a dual-purpose script that can be sourced (providing the `which` function) or executed directly.

### Key Observations:

1. **Lines 8-99**: The `which` function is defined. This shadows the system `/usr/bin/which` command.

2. **Line 101**: `declare -fx which` exports the function, making it available to subshells.

3. **Lines 104-109**: This is the source fence pattern - when sourced, it returns early; when executed, it sets strict mode and calls the function.

4. **Line 106**: `set -euo pipefail` is placed inside the execution block, not at script top.

Let me check for actual violations:

| Check | Result |
|-------|--------|
| BCS0101 (Strict mode placement) | Valid - dual-purpose scripts apply strict mode only on execution |
| BCS0106 (Dual-purpose pattern) | Valid - function defined before fence, strict mode after fence |
| BCS0407 (Library pattern) | Valid - rejects direct execution |
| BCS0403 (Main function) | N/A - script uses function pattern, not main() |
| BCS0405 (Production optimization) | N/A - all defined functions are used |
| BCS0806 (Standard options) | Valid - includes -V and -h |
| BCS1004 (Eval avoidance) | Valid - no eval used |
| BCS0711 (Combined redirection) | Valid - uses `>&2` correctly |

### Findings

The script is well-structured and follows most BCS rules. Let me verify the source fence and execution pattern more carefully:

- **Line 104**: `return 0 2>/dev/null || { ... }` - When sourced, `return 0` succeeds and the block is skipped. When executed directly, `return 0` fails (not in a function context), and the block executes. This is a valid pattern.

- **Line 108**: `which "$@"` - Calls the function defined at lines 8-99.

The script appears to have **no violations**. It is a properly structured dual-purpose script with:
- Function definitions before source fence
- Strict mode applied only on direct execution (not when sourced)
- Proper argument parsing
- Proper messaging (errors to stderr)
- Clean exit codes

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| — | — | — | No violations found |
bcs: ◉ Tokens: in=20779 out=1765
bcs: ◉ Elapsed: 30s
