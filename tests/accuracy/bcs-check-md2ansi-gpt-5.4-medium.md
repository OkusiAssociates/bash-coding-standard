bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'medium' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
BCS0503 — WARNING — lines 1413-1415  
What is wrong: Arithmetic spacing/style deviates from the standard pattern. The script uses `if ((${#INPUT_FILES[@]}>1)); then` instead of the spaced arithmetic form shown throughout BCS examples. This is readable but is a style deviation.  
How to fix: Add spaces inside the arithmetic expression:
```bash
if ((${#INPUT_FILES[@]} > 1)); then
```

BCS0801 — WARNING — line 1318  
What is wrong: The arithmetic test in the `--` handler is written as `(($#==0))` rather than the standard spaced form. This is not incorrect, but it deviates from the preferred style.  
How to fix: Rewrite with spaces:
```bash
(($# == 0)) || INPUT_FILES+=("$@")
```

BCS1204 — WARNING — lines 173-175, 270-272, 656-658, 962-964, 1205-1207  
What is wrong: The script uses heavy box/separator section comments made of `=====` rather than the lightweight section comments recommended by BCS.  
How to fix: Replace these with simple section comments, for example:
```bash
# ANSI color definitions
# Rendering functions
# Table rendering functions
# Markdown parser functions
# Main script functions
```

Summary table:

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0503 | WARNING | 1413-1415 | Arithmetic conditional formatting deviates from preferred spaced style |
| BCS0801 | WARNING | 1318 | Arithmetic test formatting in argument parsing deviates from preferred spaced style |
| BCS1204 | WARNING | 173-175, 270-272, 656-658, 962-964, 1205-1207 | Heavy section comment style used instead of lightweight section comments |
bcs: ◉ Tokens: in=35548 out=414
bcs: ◉ Elapsed: 10s
