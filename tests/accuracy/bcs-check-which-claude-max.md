bcs: ◉ Backend 'ollama' inferred from model 'claude'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'claude' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
Looking at this script, I need to check it against the BCS rules systematically.

**Key observations:**
1. This is a dual-purpose script (can be sourced or executed)
2. The `which` function overrides the system `which` command
3. It has strict mode only in the direct execution path (lines 106-107)
4. Uses arithmetic conditionals in several places

Let me analyze each potential issue:

**BCS0606 Analysis - Arithmetic conditionals:**
Lines 60, 63, 66, 70, 82, 85, 88, 91, 95 all use patterns like `((silent)) ||` or `((found)) ||`. Under `set -e`, when the arithmetic expression evaluates to 0 (false), it returns exit code 1, which triggers `set -e` to exit the script before the `||` handler runs.

However, line 104 shows: `return 0 2>/dev/null || { ... }` - the `|| { ... }` means this script runs in direct execution mode when sourced. Let me verify:

When sourced: `return 0` succeeds (no prior return), the block is skipped - `which "$@"` is never called.
When executed: `return 0` fails (in script context), `|| { ... }` runs, executing `which "$@"`.

So strict mode IS active when `which "$@"` is called. This means the arithmetic conditional issue is a real violation.

**BCS0109 End Marker:**
Line 111 has `#end` which is acceptable per BCS0109.

Let me verify each problematic line:

```bash
((silent)) || printf '%s\n' "$resolved"   # line 60 - silent=0 → exit before printf
((silent)) || >&2 printf '...'             # line 63 - same
((silent)) || printf '%s\n' "$target"     # line 66 - same
((found)) || allret=1                      # line 70 - found=0 → exit before assignment
((silent)) || printf '%s\n' "$resolved"   # line 82 - same as 60
((silent)) || >&2 printf '...'            # line 85 - same as 63
((silent)) || printf '%s\n' "$full_path"  # line 88 - same as 66
((allmatches)) || break                    # line 91 - allmatches=0 → exit before break
((found)) || allret=1                      # line 95 - same as 70
```

All these need `||:` to be safe under `set -e`.

**BCS0602 - Exit codes in help:**
The help says "Exit: 0=found, 1=not found, 2=bad option" but line 40 returns 2 for illegal options. This is actually correct in the code - but I need to verify if the documentation matches. Looking at the help text:
- Line 26: "Exit: 0=found, 1=not found, 2=bad option"
- Line 40: returns 2 for illegal option

This is correct! No issue there.

Now checking other potential issues:

**BCS0402 - Overriding built-in:**
The script defines a `which` function that shadows the system command. BCS0402 says "Never override built-in commands without good reason." This appears intentional - the script IS implementing `which` functionality. This is acceptable.

**BCS0106 - Source fence:**
Lines 103-109 use `return 0 2>/dev/null || { ... }` pattern. This is acceptable per BCS0106.

**BCS0103 - Script metadata:**
No VERSION, SCRIPT_PATH, SCRIPT_DIR, SCRIPT_NAME declared. This is a library/function script that can be sourced, so it's understandable. However, the help text references "which 2.0" - having metadata would be better.

Actually, looking more carefully at line 104: `return 0 2>/dev/null || {` - in a sourced context, `return 0` succeeds immediately (no prior function call), so the block is NOT executed. In direct execution, `return 0` fails and the block executes.

So strict mode IS active when which "$@" runs.

Let me compile the findings:

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0606 | VIOLATION | 60, 63, 66, 70, 82, 85, 88, 91, 95 | Arithmetic conditionals without `||:` under `set -e` - will cause script to exit unexpectedly when condition evaluates to 0. Add `||:` after each `((expr)) ||` pattern. |
| BCS0103 | WARNING | - | No script metadata declared (VERSION, SCRIPT_PATH, etc.). While acceptable for library-style scripts, would improve traceability. |
bcs: ◉ Tokens: in=20779 out=2456
bcs: ◉ Elapsed: 39s
