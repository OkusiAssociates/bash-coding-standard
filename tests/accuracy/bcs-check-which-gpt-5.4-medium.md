bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'medium' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
**Findings**

1. **BCS0201 / BCS0202 — VIOLATION — line 11**
   - **What is wrong:** `target`, `path`, `full_path`, and `resolved` are declared with `local` but without an explicit type marker. BCS requires all variables to have explicit type declarations; for strings that means `local -- ...`.
   - **How to fix:** Declare them as string-typed locals, e.g.:
     ```bash
     local -- target path full_path resolved
     ```

2. **BCS0802 — WARNING — line 35**
   - **What is wrong:** Version output is `which 2.0`, hardcoded directly, rather than using the standard `scriptname X.Y.Z` pattern driven by metadata variables. While the output format itself matches the rule’s wording, the script does not follow the standard metadata/version pattern expected by BCS for executable script mode.
   - **How to fix:** Declare a version metadata variable in script mode and print it consistently, e.g.:
     ```bash
     declare -r VERSION=2.0
     printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
     ```
     If keeping the dual-purpose structure, place metadata in the executable section only, after the source fence.

3. **BCS0702 — WARNING — line 40**
   - **What is wrong:** stderr redirection is placed mid-command: `printf ...` is preceded by `>&2` only after the case arm begins. BCS recommends placing `>&2` at the beginning of the command for visibility and consistency.
   - **How to fix:** Rewrite as:
     ```bash
     -*) >&2 printf 'Illegal option %s\n' "${1@Q}"; return 2 ;;
     ```
     Actually this line already uses that preferred form.  
     **No finding should be reported here.**

4. **BCS0103 — WARNING — lines 104-109**
   - **What is wrong:** In executable mode, the script omits standard metadata declarations such as `SCRIPT_NAME` and `VERSION`. BCS says these standard metavars belong immediately after strict mode/shopt, though not all scripts need all four.
   - **How to fix:** If executable-mode metadata is needed, add only the ones actually used, e.g.:
     ```bash
     declare -r VERSION=2.0
     #shellcheck disable=SC2155
     declare -r SCRIPT_PATH=$(realpath -- "$0")
     declare -r SCRIPT_NAME=${SCRIPT_PATH##*/}
     ```
     Since this script does not currently use them, omission is acceptable.  
     **No finding should be reported here.**

5. **BCS0109 — VIOLATION — line 111**
   - **What is wrong:** The script ends with `#end` instead of the mandatory final marker `#fin`.
   - **How to fix:** Change the last line to:
     ```bash
     #fin
     ```

### Summary

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0201 / BCS0202 | VIOLATION | 11 | Local string variables are declared without explicit type marker `--`. |
| BCS0109 | VIOLATION | 111 | Final end marker uses `#end` instead of `#fin`. |
bcs: ◉ Tokens: in=21006 out=719
bcs: ◉ Elapsed: 13s
