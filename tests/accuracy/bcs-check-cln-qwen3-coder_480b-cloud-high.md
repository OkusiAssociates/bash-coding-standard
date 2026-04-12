bcs: ◉ Backend 'ollama' inferred from model 'qwen3-coder:480b-cloud'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'qwen3-coder:480b-cloud' --effort 'high' --strict 'off' '/ai/scripts/File/cln/cln'

After thorough analysis of the script against the BCS rules, I found the script to be largely compliant. However, there is one minor style deviation:

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0111 | WARNING | 113-119 | Configuration search path order deviates from BCS reference pattern. The help text (lines 68-73) documents the actual paths used, which per BCS0111 makes this an acceptable documented deviation. The script prioritizes user config (XDG) first for override semantics, which is functionally appropriate for this utility. |

No VIOLATIONS were found. The script correctly:
- Uses `set -euo pipefail` with required shopt options
- Defines proper metadata (VERSION, SCRIPT_PATH, SCRIPT_NAME)
- Organizes functions bottom-up (messaging → helpers → main)
- Uses integer flags and proper quoting throughout
- Implements correct argument parsing with bundling support
- Uses process substitution correctly to avoid subshell variable scope issues
- Separates stdout/stderr appropriately
- Includes proper end marker (`#fin`)

The search path order in `read_conf()` is the only deviation, but it's documented in the help text as required by BCS0111 for such deviations.
bcs: ◉ Tokens: in=22763 out=6157
bcs: ◉ Elapsed: 76s
