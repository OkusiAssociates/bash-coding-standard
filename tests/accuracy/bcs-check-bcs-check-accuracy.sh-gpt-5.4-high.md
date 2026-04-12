bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'high' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
Findings:

1. **BCS0301 — WARNING — line 80**  
   **What is wrong:** Static text is wrapped in double quotes:  
   `>&2 echo "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"`  
   Under BCS0301, double quotes should be used only when shell expansion is needed; static parts should be single-quoted or separated from expanded parts for clarity.  
   **How to fix:** Quote literal text separately from variables, e.g.:
   ```bash
   >&2 echo 'bcs check --model '"$model"' --effort '"$effort"' '"${script@Q}"' &>'"${output_to@Q}"
   ```
   or better, use `printf`:
   ```bash
   >&2 printf 'bcs check --model %s --effort %s %s &>%s\n' "$model" "$effort" "${script@Q}" "${output_to@Q}"
   ```

2. **BCS0301 — WARNING — line 82**  
   **What is wrong:** Static text is wrapped in double quotes:  
   `>&2 echo "    ${output_to@Q} already exists; skipping"`  
   This is a style deviation from BCS0301.  
   **How to fix:** Separate literal and expanded parts, e.g.:
   ```bash
   >&2 echo '    '"${output_to@Q}"' already exists; skipping'
   ```
   or:
   ```bash
   >&2 printf '    %s already exists; skipping\n' "${output_to@Q}"
   ```

3. **BCS0705 — WARNING — lines 80, 82**  
   **What is wrong:** Status/progress messages are emitted with raw `echo` to stderr instead of messaging functions. BCS0705 recommends using messaging functions for status output (`info`, `warn`, `error`) rather than ad hoc `echo`.  
   **How to fix:** Add only the messaging functions actually used, then replace these with them, e.g.:
   ```bash
   info() { >&2 printf '%s: %s\n' "$SCRIPT_NAME" "$1"; }
   info "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"
   info "${output_to@Q} already exists; skipping"
   ```
   If keeping the current minimal approach intentionally, this is only a style warning.

4. **BCS1202 — WARNING — line 26**  
   **What is wrong:** Comment contains a spelling error: `ommitted` instead of `omitted`. While not a functional defect, comments should remain clear and polished.  
   **How to fix:** Change to:
   ```bash
   # Efforts; low omitted because of consistent poor quality with current models
   ```

Summary table:

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0301 | WARNING | 80 | Double quotes used around mixed static/expanded status string instead of clearer literal/variable separation |
| BCS0301 | WARNING | 82 | Double quotes used around mixed static/expanded status string instead of clearer literal/variable separation |
| BCS0705 | WARNING | 80, 82 | Status messages sent via raw `echo` to stderr instead of messaging functions |
| BCS1202 | WARNING | 26 | Comment typo reduces clarity (`ommitted` → `omitted`) |
bcs: ◉ Tokens: in=20713 out=755
bcs: ◉ Elapsed: 11s
