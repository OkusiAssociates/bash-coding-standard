bcs: ◉ Backend 'ollama' inferred from model 'qwen3-coder:480b-cloud'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=ollama)...
bcs: ◉ bcs check --model 'qwen3-coder:480b-cloud' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
[WARN] BCS0102 line 1: Shebang is `#!/bin/bash` — prefer `#!/usr/bin/bash` for consistency.  
[WARN] BCS0105 line 11: Global variables `BASH_SCRIPTS`, `script`, `scriptname`, `scriptdir` are not explicitly typed with `declare -a` or `declare --`.  
[WARN] BCS0105 line 15: Global variable `LLM_MODELS` is not explicitly typed with `declare -a`.  
[WARN] BCS0105 line 27: Global variable `EFFORTS` is not explicitly typed with `declare -a`.  
[WARN] BCS0105 line 33: Global variables `model`, `effort`, `modelname` are not explicitly typed with `declare --`.  
[WARN] BCS0201 line 11: Array `BASH_SCRIPTS` declared without explicit `-a` type.  
[WARN] BCS0201 line 15: Array `LLM_MODELS` declared without explicit `-a` type.  
[WARN] BCS0201 line 27: Array `EFFORTS` declared without explicit `-a` type.  
[WARN] BCS0201 line 33: Variables `model`, `effort`, `modelname` declared without explicit `--` separator.  
[WARN] BCS0402 line 72: Variable `script` reassigned without `local` in loop — potential scope leak (though acceptable here due to outer declaration).  
[WARN] BCS0801 line 36: Uses `@()` extglob pattern without validating `extglob` is enabled via `shopt -s extglob`. Although set globally, parser may miss localized requirement.  
[WARN] BCS1202 line 14: Comment "# Models to exercise" paraphrases next line and adds no new information.  

| BCS Code | Tier      | Severity | Line(s)        | Description                                                                 |
|----------|-----------|----------|----------------|-----------------------------------------------------------------------------|
| BCS0102  | style     | WARN     | 1              | Shebang uses `/bin/bash`; prefer `/usr/bin/bash`                            |
| BCS0105  | style     | WARN     | 11,15,27,33    | Global variables not explicitly typed                                       |
| BCS0201  | style     | WARN     | 11,15,27,33    | Missing explicit type declarations (`-a`, `--`)                             |
| BCS0402  | style     | WARN     | 72             | Reassignment of outer-scoped variable in loop                              |
| BCS0801  | core      | WARN     | 36             | Extglob pattern used without confirming `shopt -s extglob` locally          |
| BCS1202  | style     | WARN     | 14             | Paraphrasing comment violates informative-comment rule                      |
bcs: ◉ Tokens: in=25167 out=667
bcs: ◉ Elapsed: 142s
