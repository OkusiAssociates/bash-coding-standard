bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/tests/accuracy/bcs-check-accuracy.sh'
Findings:

1. **BCS0602 — WARNING — line 60**  
   **What is wrong:** The script uses exit code `1` for an invalid argument: `exit 1`. Under BCS0602, invalid arguments should use exit code `22`, and usage/argument errors generally use `2`.  
   **How to fix:** Replace line 60 with an appropriate BCS exit code, e.g.:
   ```bash
   exit 22
   ```
   or use a `die` helper if desired:
   ```bash
   die 22 "Invalid argument ${1@Q}"
   ```

2. **BCS0702 — VIOLATION — lines 80, 82**  
   **What is wrong:** Status messages are sent to stderr using `echo`, but the redirection operator is placed at the end-equivalent position (`>&2 echo ...`) incorrectly? Actually BCS0702 requires `>&2` at the beginning, and here it is at the beginning, so no issue there.  
   **How to fix:** No finding should be reported.  
   *(Omitted per instruction; not included.)*

2. **BCS0301 — WARNING — lines 80, 82**  
   **What is wrong:** Static strings are written with double quotes where single quotes are preferred.  
   - line 80: `>&2 echo "bcs check --model ..."`  
   - line 82: `>&2 echo "    ${output_to@Q} already exists; skipping"`  
   Double quotes are needed on line 80 because variables expand, so only line 82 is partially static but still includes expansion. This is therefore not a reportable issue.  
   *(Omitted per instruction; not included.)*

2. **BCS0703 — WARNING — lines 59, 80, 82**  
   **What is wrong:** The script prints status/error messages directly instead of using messaging functions. BCS0703 provides core message functions as the reference pattern.  
   **How to fix:** Define and use `error()`/`info()` helpers.  
   **Note:** This is a style deviation from the reference pattern, not necessarily mandatory, but still reportable as warning.

3. **BCS0801 — WARNING — lines 35–63**  
   **What is wrong:** Argument parsing does not use the standard `while (($#)); do case $1 in ... esac; shift; done` pattern. It instead handles only a single optional argument with nested `if`/`elif`.  
   **How to fix:** Rewrite argument parsing using the standard BCS `while/case` parser, for example:
   ```bash
   while (($#)); do case $1 in
     -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
     -h|--help)    show_help; exit 0 ;;
     -*)           exit 22 ;;
     *)            exit 22 ;;
   esac; shift; done
   ```

4. **BCS1202 — WARNING — line 26**  
   **What is wrong:** Comment contains a spelling mistake: `ommitted` should be `omitted`. While BCS1202 is about comment quality, this is still a style issue in script comments.  
   **How to fix:** Change line 26 to:
   ```bash
   # Efforts; low omitted because of consistent poor quality with current models
   ```

5. **BCS0705 — WARNING — lines 80, 82**  
   **What is wrong:** Status output uses `echo` directly to stderr instead of a messaging function. BCS0705 says messaging functions should be used for status, while `echo` is for data/help output.  
   **How to fix:** Replace with `info`/`warn` style helpers, e.g.:
   ```bash
   info "bcs check --model $model --effort $effort ${script@Q} &>${output_to@Q}"
   warn "${output_to@Q} already exists; skipping"
   ```

Summary table:

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0602 | WARNING | 60 | Invalid argument exits with code 1 instead of a standard BCS invalid-argument code such as 22 |
| BCS0703 | WARNING | 59, 80, 82 | Direct stderr status/error output used instead of messaging helper functions |
| BCS0801 | WARNING | 35–63 | Argument parsing does not follow the standard `while/case/shift` BCS pattern |
| BCS1202 | WARNING | 26 | Comment quality issue: spelling error in comment text |
| BCS0705 | WARNING | 80, 82 | Status messages use `echo` directly instead of messaging functions |
bcs: ◉ Tokens: in=20712 out=1034
bcs: ◉ Elapsed: 14s
