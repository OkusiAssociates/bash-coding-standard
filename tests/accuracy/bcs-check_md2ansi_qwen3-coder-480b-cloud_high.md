bcs: ◉ Backend 'ollama' inferred from model 'qwen3-coder:480b-cloud'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/md2ansi' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'qwen3-coder:480b-cloud' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/examples/md2ansi'
[WARN] BCS0103 line 13: SCRIPT_NAME uses simplified derivation instead of realpath-based pattern, acceptable with suppression directive

[WARN] BCS0207 line 185: HAS_COLOR calculation uses inline IFS-like expression but is properly scoped to command substitution

[WARN] BCS0703 line 73: debug() function present but not referenced in script flow

[WARN] BCS0804 line 1266: parse_arguments placed outside main() but acceptable for small script

| BCS Code | Tier     | Severity | Line(s) | Description                                                                 |
|----------|----------|----------|---------|-----------------------------------------------------------------------------|
| BCS0103  | core     | WARN     | 13      | SCRIPT_NAME uses simplified derivation instead of realpath-based pattern    |
| BCS0207  | core     | WARN     | 185     | HAS_COLOR calculation uses inline IFS-like expression                       |
| BCS0703  | style    | WARN     | 73      | debug() function present but not referenced                                 |
| BCS0804  | recommended | WARN  | 1266    | parse_arguments placed outside main()                                       |
bcs: ◉ Tokens: in=42761 out=267
bcs: ◉ Elapsed: 48s
