bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'medium' --strict 'off' '/ai/scripts/File/cln/cln'
**Findings**

1. **BCS0111 — WARNING — lines 110–126**  
   **What is wrong:** `read_conf()` is documented as “BCS0111 search order”, but the implemented search path is reversed from the BCS cascade order and uses **first found wins** semantics (`return 0` on the first readable file) instead of the BCS reference cascade-source behavior. This is an intentional alternative pattern, but it deviates from the standard reference and the help text should clearly document the actual behavior if departing from cascade loading.  
   **How to fix:** Either:
   - implement the standard cascade `source`-based loading order from BCS0111, or
   - keep first-match behavior but document it explicitly as a deliberate deviation in the function/help text, and avoid claiming it is “BCS0111 search order”.

2. **BCS0702 — VIOLATION — line 48**  
   **What is wrong:** `echo >&2` places the redirection at the end. BCS0702 requires stderr redirection to be placed at the **beginning** for messaging/output to stderr.  
   **How to fix:** Change:
   ```bash
   echo >&2
   ```
   to:
   ```bash
   >&2 echo
   ```

3. **BCS0301 — WARNING — lines 165, 213, 230, 234, 236, 239**  
   **What is wrong:** These use double-quoted static strings where double quotes are only needed because of embedded expansions, but the static literal portions are not quoted separately. BCS recommends single quotes for literal text and double quotes only where shell expansion is needed. This is a style issue, not a correctness problem.  
   **How to fix:** Split literal and expanded portions more clearly, for example:
   ```bash
   die 22 'Option -m|--depth requires a numeric argument, got '"${1@Q}"
   info 'Searching directory '"${path@Q}"', depth '"$max_depth"
   warn 'Found '"$fnd"' file$(s "$fnd") to remove:'
   yn 'Remove '"$fnd"' file$(s "$fnd")'?'
   info 'Removing '"$fnd"' file$(s "$fnd")'...'
   info 'No matching files found in '"${path@Q}"
   ```

4. **BCS0401 — WARNING — line 207**  
   **What is wrong:** `local -- file` is declared mid-function after executable logic has begun. BCS0401 permits mid-body declarations, but says declarations should be grouped near the top when practical. This is a minor style deviation.  
   **How to fix:** Move `local -- file` up into the initial local declaration block near lines 134–145.

5. **BCS0705 — WARNING — line 176**  
   **What is wrong:** Version output uses `echo`, which is acceptable, but BCS0801’s reference parsing pattern uses `exit 0` for exit options. Here `main()` returns instead. This is functionally fine in a non-sourced script, but it deviates from the reference invocation pattern.  
   **How to fix:** Prefer:
   ```bash
   -V|--version) printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"; exit 0 ;;
   ```
   and similarly for help if you want to follow the reference pattern exactly.

---

**Summary**

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0111 | WARNING | 110–126 | `read_conf()` uses first-match-wins in reversed order, deviating from BCS cascade loading reference |
| BCS0702 | VIOLATION | 48 | Stderr redirection placed at end instead of beginning |
| BCS0301 | WARNING | 165, 213, 230, 234, 236, 239 | Literal text and expansions mixed in double-quoted strings; style deviates from quote semantics guidance |
| BCS0401 | WARNING | 207 | Local declaration appears mid-function instead of in the main declaration block |
| BCS0705 | WARNING | 176 | Version option returns from `main()` rather than using the reference `exit 0` pattern |
bcs: ◉ Tokens: in=22950 out=915
bcs: ◉ Elapsed: 15s
