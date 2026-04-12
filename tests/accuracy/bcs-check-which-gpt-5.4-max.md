bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/Okusi/BCS/examples/which' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'max' --strict 'off' '/ai/scripts/Okusi/BCS/examples/which'
**Findings**

1. **BCS0201 — VIOLATION — line 11**  
   `local target path full_path resolved` declares local variables without explicit type markers.  
   BCS requires all variables to use explicit declaration forms; for strings that means `local -- ...`.

   **Fix:**  
   Change line 11 to:
   ```bash
   local -- target path full_path resolved
   ```

2. **BCS0202 — VIOLATION — line 49**  
   `_path` is assigned without `local`, which creates/modifies a global variable from inside the function.  
   Function-local variables must be declared with `local`.

   **Fix:**  
   Change line 49 to:
   ```bash
   local -- _path=${PATH:-}
   ```

3. **BCS1002 — VIOLATION — line 49**  
   The function trusts inherited `PATH` directly via `${PATH:-}` and does not secure `PATH` before command lookup.  
   BCS requires securing `PATH` early to prevent command hijacking.

   **Fix:**  
   Set a safe `PATH` before using command lookup behavior, e.g. in script mode before calling `which`, or otherwise document and constrain it:
   ```bash
   declare -rx PATH=/usr/local/bin:/usr/bin:/bin
   ```
   If preserving user PATH semantics is intentional for a `which` implementation, avoid relying on inherited `PATH` for external helper commands or clearly separate search-path input from execution-path security.

4. **BCS0802 — WARNING — line 35**  
   Version output is `which 2.0`, but the script does not define/use a `VERSION` metadata variable and hardcodes the version string inline.  
   BCS recommends standard metadata and version output using script metadata variables.

   **Fix:**  
   Declare metadata and use it consistently, e.g.:
   ```bash
   declare -r VERSION=2.0
   ```
   then:
   ```bash
   printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
   ```

5. **BCS0103 — WARNING — lines 106-108**  
   Script metadata variables (`VERSION`, `SCRIPT_PATH`, `SCRIPT_NAME`, optionally `SCRIPT_DIR`) are not declared in script mode after strict mode/shopt.  
   BCS recommends metadata immediately after strict mode for executable script mode.

   **Fix:**  
   Add metadata below line 107, for example:
   ```bash
   declare -r VERSION=2.0
   #shellcheck disable=SC2155
   declare -r SCRIPT_PATH=$(realpath -- "$0")
   declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
   ```

6. **BCS0602 — WARNING — line 40**  
   The function emits an error and returns `2` directly instead of using a standard `die()` helper.  
   BCS defines `die()` as the standard exit/error function; direct return is functional here but deviates from the standard pattern.

   **Fix:**  
   If you want full BCS messaging/error handling consistency, add a minimal `die()`/`error()` helper and use it.  
   For a sourceable function, an equivalent function-local pattern is acceptable, e.g.:
   ```bash
   >&2 printf '%s\n' "which: Illegal option ${1@Q}"
   return 2
   ```
   If kept as-is, this is only a style deviation.

7. **BCS0109 — WARNING — line 111**  
   The file ends with `#end`, which is allowed, but the standard prefers `#fin` as the canonical marker.  
   This is a stylistic deviation only.

   **Fix:**  
   Replace:
   ```bash
   #end
   ```
   with:
   ```bash
   #fin
   ```

---

### Summary

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0201 | VIOLATION | 11 | Local string variables declared without explicit type marker `--` |
| BCS0202 | VIOLATION | 49 | `_path` assigned without `local`, leaking into global scope |
| BCS1002 | VIOLATION | 49 | Inherited `PATH` is trusted directly; secure PATH handling is required |
| BCS0802 | WARNING | 35 | Version string hardcoded inline instead of using standard metadata variables |
| BCS0103 | WARNING | 106-108 | Script-mode metadata variables are not declared after strict mode |
| BCS0602 | WARNING | 40 | Direct error/return pattern used instead of standard `die()` helper |
| BCS0109 | WARNING | 111 | Uses `#end` instead of preferred canonical end marker `#fin` |
bcs: ◉ Tokens: in=21008 out=1028
bcs: ◉ Elapsed: 17s
