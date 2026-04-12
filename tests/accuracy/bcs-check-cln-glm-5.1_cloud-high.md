bcs: ◉ Backend 'ollama' inferred from model 'glm-5.1:cloud'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'glm-5.1:cloud' --effort 'high' --strict 'off' '/ai/scripts/File/cln/cln'
Looking at this script against the BCS rules:

**BCS0806 Standard Options** - Line 169-170 uses `-p|-n|--prompt` where `-n` is aliased to `--prompt`, but BCS0806 defines `-n` as `--dry-run`. The script is a cleanup tool that doesn't have dry-run functionality, so it repurposes `-n`. This is a deviation from the standard option table, which is a WARNING.

**BCS0111 Configuration File Loading** - The script uses first-match-wins semantics (line 123: `return 0` after first config found) and a non-standard search path order. However, lines 68-73 in `show_help()` document the actual paths used, which satisfies the requirement: "provided the help text documents the actual paths used." This is acceptable.

**BCS0405 Production Optimization** - The script defines `die()` but never calls it. However, `die()` is a standard error-handling function that provides defensive capability. The script handles errors via `warn()` and `error()` but having `die()` available is reasonable defensive programming. This is borderline but acceptable.

Let me verify the inline suppression coverage:

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0806 | WARNING | 169-170 | Non-standard option: `-n` aliased to `--prompt` instead of standard `--dry-run`. BCS0806 defines `-n` for dry-run, but this cleanup script repurposes it for prompting. While documented in help and functional, it deviates from the standard option table. |
bcs: ◉ Tokens: in=22763 out=4196
bcs: ◉ Elapsed: 58s
