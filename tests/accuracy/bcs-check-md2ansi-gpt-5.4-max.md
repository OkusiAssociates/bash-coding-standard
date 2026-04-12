bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Markdown/md2ansi.bash/md2ansi' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/Markdown/md2ansi.bash/md2ansi'
Findings:

1. **BCS0203 — VIOLATION — line 8**  
   `PS4` is a shell built-in/special variable name, and BCS0203 says to avoid shell built-in names like `PATH`, `HOME`, `USER`. Re-declaring/exporting special shell variables as regular script globals violates the naming rule.  
   **How to fix:** Do not treat `PS4` as a normal global metadata/config variable. Set it only when actually enabling tracing, e.g. inside debug setup, or gate it behind `((DEBUG)) && set -x ||:` without declaring it as a script-global typed variable.

2. **BCS0203 — VIOLATION — lines 41, 73-78, 1277-1279**  
   Global variable `DEBUG` uses the name of a shell builtin command (`debug` is not a builtin, but `DEBUG` is the name of a special trap context in Bash and is too close to shell internals), and the script also defines a function named `debug`. Reusing the same semantic name for a global state variable and a function is confusing and breaks the spirit of BCS0203’s naming-safety guidance.  
   **How to fix:** Rename the flag to something unambiguous like `DEBUG_ENABLED` and update tests/usages accordingly:
   - `declare -i DEBUG_ENABLED=0`
   - `((DEBUG_ENABLED)) || return 0`
   - `-D|--debug) DEBUG_ENABLED=1 ;;`

3. **BCS1201 — WARNING — lines 39, 173-175, 270-272, 656-658, 962-964, 1205-1207**  
   Section separators use heavy banner/comment styles (`## ... ##`, `=====` blocks). BCS1204 says lightweight section comments should be used, and heavy box/banner styles are discouraged except for major divisions using 80-dash separators.  
   **How to fix:** Replace these with lightweight comments, e.g.:
   - `# Utility functions`
   - `# ANSI color definitions`
   - `# Rendering functions`

4. **BCS1202 — WARNING — line 153**  
   Comment includes a visual arrow marker (`# ← prevent recursion`). BCS1202 recommends comments explain why, not add decorative notation.  
   **How to fix:** Use a plain explanatory comment, e.g. `# Disable traps first to prevent cleanup recursion`.

5. **BCS0207 — WARNING — line 286**  
   Uses unnecessary braces for simple variable concatenation inside a double-quoted string: `${COLOR_CODEBLOCK}` and `${COLOR_TEXT}`. BCS0207 says braces should be used only when syntactically necessary.  
   **How to fix:** Prefer:
   ```bash
   result=$(sed -E "s/\`([^\`]+)\`/$COLOR_CODEBLOCK\1$ANSI_RESET$COLOR_TEXT/g" <<<"$result")
   ```

6. **BCS0207 — WARNING — lines 290, 295, 299, 302-303, 306, 310, 315, 319, 613, 632, 651**  
   Same issue: unnecessary braces around simple variable expansions in double-quoted sed replacement strings.  
   **How to fix:** Remove braces where not required, e.g. `$ANSI_BOLD`, `$ANSI_RESET`, `$COLOR_TEXT`, etc.

7. **BCS0401 — VIOLATION — lines 430-431**  
   `local -- line` is declared inside a loop section after executable statements in the same logical loop block. BCS0401 permits mid-body declarations, but explicitly says declarations must not appear inside loops.  
   **How to fix:** Move `local -- line` to the function’s declaration block near the top:
   ```bash
   local -- bullet_indent text_indent formatted_content line
   ```

8. **BCS0401 — VIOLATION — lines 464-465**  
   Same issue: `local -- line` declared inside loop section / after loop-related executable flow.  
   **How to fix:** Move `line` into the function’s initial local declarations.

9. **BCS0401 — VIOLATION — lines 504-505**  
   Same issue: `local -- line` declared inside loop section / after executable statements.  
   **How to fix:** Move `line` to the top local declaration group in `render_task_item()`.

10. **BCS0401 — VIOLATION — lines 528-529**  
    Same issue: `local -- line` declared immediately before a loop, after executable statements in the function body. BCS0401 prohibits declarations inside loops and expects locals grouped near the top when practical.  
    **How to fix:** Move `line` into the initial declarations in `render_blockquote()`.

11. **BCS0401 — VIOLATION — lines 864-865**  
    `local -- dashes` is declared mid-function after executable statements. BCS0401 allows some mid-body declarations, but here it is avoidable and should be grouped at the top with the other locals for clarity.  
    **How to fix:** Move `dashes` into the initial local declaration line:
    ```bash
    local -- horiz_line row cell_text aligned_cell dashes
    ```

12. **BCS0301 — WARNING — lines 599, 605, 625, 644**  
    Double quotes are used for static strings with variable interpolation only at the outer edges; these are fine syntactically, but the content is effectively simple concatenation where `printf` would be clearer and more consistent with BCS messaging/output style.  
    **How to fix:** Prefer `printf` for formatted output, e.g.:
    ```bash
    printf '%s%s%s\n' "$COLOR_COMMENT" "$code" "$COLOR_CODEBLOCK"
    ```

13. **BCS0801 — WARNING — line 1268**  
    Argument parsing uses a multi-line `while (($#)); do` followed by `case`, instead of the canonical compact BCS pattern `while (($#)); do case $1 in ... esac; shift; done`. This is functionally fine but deviates from the standard reference style.  
    **How to fix:** Rewrite using the canonical one-construct form if strict stylistic compliance is desired.

14. **BCS0803 — VIOLATION — lines 166-169, 1270-1273**  
    `noarg()` rejects any next token beginning with `-`, which is stricter than the BCS reference and incorrectly forbids legitimate option arguments that begin with a dash. The standard rule is to validate that an argument exists, not to prohibit dash-prefixed values generically.  
    **How to fix:** Use the standard helper:
    ```bash
    noarg() { (($# > 1)) || die 22 "Option ${1@Q} requires an argument"; }
    ```
    Then perform value-specific validation separately in the option handler.

15. **BCS1205 — WARNING — line 1401**  
    Uses external `sed` in `debug "Options: $(declare -p OPTIONS | sed 's/declare -A //')"` where builtin/string operations would be preferable when practical. BCS1205 prefers builtins over external commands.  
    **How to fix:** Avoid the subshell+sed in debug output, or use `declare -p OPTIONS` directly if acceptable.

16. **BCS0702 — WARNING — lines 1404, 1423**  
    Terminal-reset/status-like control output is sent to stdout. BCS0702 requires only data output on stdout; status/control messaging belongs on stderr. These reset emissions are not markdown data.  
    **How to fix:** Send terminal reset control sequences to stderr if they are operational/status side effects:
    ```bash
    >&2 printf '%s' "$ANSI_RESET"
    ```

17. **BCS0602 — WARNING — line 1425**  
    `main()` ends with `return 0` instead of exiting from script mode. The compliance reference says this is functionally equivalent for non-sourced scripts and at most a warning.  
    **How to fix:** Prefer script termination via `exit 0` from mainline, or simply let `main "$@"` be the final command and omit explicit `return 0` if not needed.

Summary table:

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0203 | VIOLATION | 8 | Uses special shell variable name `PS4` as a declared global |
| BCS0203 | VIOLATION | 41, 73-78, 1277-1279 | Confusing/reused `DEBUG` naming for global state and debug facility |
| BCS1201 | WARNING | 39, 173-175, 270-272, 656-658, 962-964, 1205-1207 | Heavy banner/section comment style |
| BCS1202 | WARNING | 153 | Decorative/non-standard inline comment style |
| BCS0207 | WARNING | 286 | Unnecessary braces in simple variable expansions |
| BCS0207 | WARNING | 290, 295, 299, 302-303, 306, 310, 315, 319, 613, 632, 651 | Repeated unnecessary braces in simple variable expansions |
| BCS0401 | VIOLATION | 430-431 | Local declaration appears in loop section instead of top declaration block |
| BCS0401 | VIOLATION | 464-465 | Local declaration appears in loop section instead of top declaration block |
| BCS0401 | VIOLATION | 504-505 | Local declaration appears in loop section instead of top declaration block |
| BCS0401 | VIOLATION | 528-529 | Local declaration appears late, immediately before loop |
| BCS0401 | VIOLATION | 864-865 | Avoidable mid-body local declaration instead of grouped top declarations |
| BCS0301 | WARNING | 599, 605, 625, 644 | Prefer `printf` over simple quoted `echo`-style concatenation output |
| BCS0801 | WARNING | 1268 | Argument parsing deviates from canonical compact BCS pattern |
| BCS0803 | VIOLATION | 166-169, 1270-1273 | `noarg()` incorrectly rejects dash-prefixed option arguments |
| BCS1205 | WARNING | 1401 | External `sed` used where builtin-oriented approach is preferred |
| BCS0702 | WARNING | 1404, 1423 | Terminal control/reset output sent to stdout instead of stderr |
| BCS0602 | WARNING | 1425 | `main()` returns 0 instead of preferred script-mode exit/fallthrough |
bcs: ◉ Tokens: in=35550 out=2304
bcs: ◉ Elapsed: 35s
