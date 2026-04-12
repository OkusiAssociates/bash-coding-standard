bcs: ◉ Backend 'ollama' inferred from model 'qwen3-coder:480b-cloud'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'qwen3-coder:480b-cloud' --effort 'medium' --strict 'off' '/ai/scripts/File/cln/cln'
Looking at the script against the BCS rules, I need to check for violations:

1. **Strict mode** (BCS0101): ✓ Present at line 7-8
2. **Script metadata** (BCS0103): ✓ Present with VERSION, SCRIPT_PATH, SCRIPT_NAME
3. **Function organization** (BCS0107): ✓ Bottom-up order
4. **End marker** (BCS0109): ✓ Present at line 245
5. **Variable types** (BCS0201): ✓ Appropriate types used
6. **Boolean flags** (BCS0208): ✓ Using integers 0/1
7. **Conditionals** (BCS0501): ✓ Using [[ ]] and (())
8. **Arithmetic** (BCS0505): ✓ No ++ used
9. **Exit codes** (BCS0602): ✓ Using die() appropriately
10. **Conditional declarations** (BCS0606): ✓ All `&&...` chains have `||:`

**Finding a VIOLATION:**

BCS0806 explicitly states: "Avoid reassigning a standard letter to a different purpose" and provides the standard options table:

| Short | Long | Variable | Default | Purpose |
|-------|------|----------|---------|---------|
| `-n` | `--dry-run` | `DRY_RUN` | 0 or 1 | Preview without changes |
| `-N` | `--not-dry-run` | `DRY_RUN` | 0 | Execute changes |

The script uses:
- Line 170: `-p|-n|--prompt` — reassigns `-n` to prompt instead of dry-run
- Line 181: Includes `n` in the bundling pattern

This is a **VIOLATION** of BCS0806 — standard option letters `-n` and `-N` are reassigned from their standard dry-run purpose to a prompt-related purpose.

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0806 | VIOLATION | 170, 181 | Standard option `-n` reassigned from `--dry-run` to `--prompt`. Also affects `-N` which should be `--not-dry-run`. Use separate `-n`/`--dry-run` and `-N`/`--not-dry-run` per BCS0806 table. |
bcs: ◉ Tokens: in=22760 out=3390
bcs: ◉ Elapsed: 41s
