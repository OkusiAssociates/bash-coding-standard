bcs: ◉ Backend 'ollama' inferred from model 'qwen3-coder:480b-cloud'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/cln' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'qwen3-coder:480b-cloud' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/cln'
[WARN] BCS0111 line 122: Config file loading via `read_conf` should use `source` to cascade settings from multiple files, rather than replacing `DELETE_FILES` outright with the contents of a single file.

[WARN] BCS0806 line 170: The `-p` and `-n` options both set `PROMPT=1`, but according to BCS0806, `-n` should be `--dry-run` for preview without changes. This appears to be an inconsistency with the standard option meanings.

| BCS Code | Tier      | Severity | Line(s) | Description                                                                 |
|----------|-----------|----------|---------|-----------------------------------------------------------------------------|
| BCS0111  | recommended | WARN     | 122     | Config loading replaces instead of cascading                                |
| BCS0806  | recommended | WARN     | 170     | Option `-n` deviates from standard meaning (`--dry-run`)                    |
bcs: ◉ Tokens: in=27634 out=216
bcs: ◉ Elapsed: 21s
