bcs: ◉ Backend 'openai' inferred from model 'gpt-5.4'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=openai)...
bcs: ◉ bcs check --model 'gpt-5.4' --effort 'high' --strict 'off' '/ai/scripts/File/cln/cln'
**Findings**

1. **BCS0103 — WARNING — lines 14-15**  
   **What is wrong:** Script metadata is incomplete/inconsistently declared. BCS0103 defines the standard metadata set as `VERSION`, `SCRIPT_PATH`, `SCRIPT_DIR`, `SCRIPT_NAME`, with `SCRIPT_DIR` typically derived alongside `SCRIPT_NAME`. Here `SCRIPT_DIR` is omitted even though metadata is being declared.  
   **How to fix:** If you want to follow the standard metadata pattern, derive both together:
   ```bash
   #shellcheck disable=SC2155
   declare -r SCRIPT_PATH=$(realpath -- "$0")
   declare -r SCRIPT_DIR=${SCRIPT_PATH%/*} SCRIPT_NAME=${SCRIPT_PATH##*/}
   ```
   If `SCRIPT_DIR` is truly unused, this is only a style warning, not a correctness issue.

2. **BCS0111 — WARNING — lines 110-126**  
   **What is wrong:** `read_conf()` deviates from the BCS reference behavior in two ways:
   - It uses **first-found wins** semantics (`return 0` after the first readable file), while the BCS reference defines **cascade sourcing**.
   - Its search path order is reversed from the reference example and differs from the help text wording of “first found wins”.  
   This is allowed if intentional and documented, but it is a deviation from the standard reference pattern.  
   **How to fix:** Either:
   - switch to cascade sourcing per BCS0111, or
   - clearly document the intentional deviation in comments/help text as first-match behavior and actual search order used.

3. **BCS0111 — WARNING — lines 121-123**  
   **What is wrong:** `read_conf()` does not use the BCS standard config-loading pattern of sourcing Bash config files. Instead, it parses non-comment lines into `DELETE_FILES`. This is a legitimate alternative approach, but it is a deviation from the standard `source`-based reference implementation.  
   **How to fix:** If you want strict alignment with BCS0111, source trusted config files in cascade order. If this restricted parsing is intentional for safety/simplicity, document that the config format is line-based patterns rather than Bash.

4. **BCS0405 — VIOLATION — lines 52-53**  
   **What is wrong:** Unused utility functions are present:
   - `noarg()` is used.
   - `decp()` is used.
   - `s()` is used.
   No issue there.  
   However, line 53 defines `decp()` with an external `sed` pipeline specifically for help/debug display, and it is only used once for verbose debugging-style output. This is not itself a violation. The actual BCS0405 issue is elsewhere? No—on re-check, all defined helpers are used.  
   **Omit this finding.**

5. **BCS0301 — WARNING — lines 165, 230, 236, 239**  
   **What is wrong:** Static string portions are put in double quotes where single quotes are preferred by BCS0301. Examples:
   - line 165: `"Option '-m|--depth' requires ..."`
   - lines 230, 236, 239 mix static text and expansion in one double-quoted string  
   This is stylistic, not unsafe.  
   **How to fix:** Use single-quoted literals with separately quoted variable expansions where practical, for example:
   ```bash
   die 22 'Option -m|--depth requires a numeric argument, got '"${1@Q}"
   info 'Removing '"$fnd"' file$(s '"$fnd"')...'
   ```

6. **BCS0705 — WARNING — line 176**  
   **What is wrong:** Version output uses `echo`. BCS allows version output via `echo`, but the preferred/standardized output pattern in argument parsing examples is `printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"`. This is a minor style deviation at most.  
   **How to fix:** Prefer:
   ```bash
   printf '%s %s\n' "$SCRIPT_NAME" "$VERSION"
   ```

7. **BCS0806 — WARNING — lines 86-87, 169-172**  
   **What is wrong:** Standard option letters are intentionally reassigned:
   - `-n` is used for `--prompt`
   - `-N` is used for `--no-prompt`
   
   BCS0806 recommends `-n`/`-N` for dry-run toggles. The inline suppression on line 169 suppresses reporting `BCS0806` for the next command/block only. It covers the prompt option block at lines 170-172, so those parser cases should **not** be reported.  
   However, the help text on lines 86-87 still documents the non-standard reassignment, and suppression does not apply there.  
   **How to fix:** Prefer standard meanings for `-n`/`-N`, or if intentionally deviating, keep the suppression for parser code and document the deviation clearly.

8. **BCS1202 — WARNING — lines 20-21**  
   **What is wrong:** The comments mostly describe **what** the messaging system does (`_msg: base formatter; vecho/warn/error...`) rather than **why**. BCS1202 prefers comments that explain non-obvious decisions.  
   **How to fix:** Rewrite comments to explain the rationale, e.g.:
   ```bash
   # Keep all status output on stderr so stdout remains pipe-safe for data output.
   ```

9. **BCS1202 — WARNING — lines 110, 130, 133, 188, 195, 199, 203, 206, 215, 225, 227**  
   **What is wrong:** Several comments restate obvious code actions rather than documenting rationale. Examples:
   - `# Load config file if exists`
   - `# Default configurations`
   - `# Set default path if not provided`
   - `# Build find criteria`
   These are style deviations under BCS1202.  
   **How to fix:** Remove obvious comments or replace them with rationale-focused comments only where the reason is non-obvious.

10. **BCS1205 — WARNING — line 53**  
    **What is wrong:** `decp()` uses external `sed` for formatting `declare -p` output. BCS1205 prefers builtins over external commands when practical.  
    **How to fix:** If you keep this helper, consider using pure Bash parameter expansion or omit the helper unless it provides enough value to justify the external call.

---

## Summary

| BCS Code | Severity | Line(s) | Description |
|---|---|---:|---|
| BCS0103 | WARNING | 14-15 | Metadata declaration omits `SCRIPT_DIR` from the standard metadata pattern |
| BCS0111 | WARNING | 110-126 | `read_conf()` uses first-found-wins instead of cascade sourcing |
| BCS0111 | WARNING | 121-123 | Config loader uses line parsing instead of the standard source-based config pattern |
| BCS0301 | WARNING | 165, 230, 236, 239 | Double quotes used for strings where single-quote/literal separation is preferred |
| BCS0705 | WARNING | 176 | Version output uses `echo` instead of preferred `printf` pattern |
| BCS0806 | WARNING | 86-87 | Help text documents non-standard reassignment of `-n`/`-N` to prompt toggles |
| BCS1202 | WARNING | 20-21 | Comment explains what the messaging system does rather than why |
| BCS1202 | WARNING | 110, 130, 133, 188, 195, 199, 203, 206, 215, 225, 227 | Multiple comments restate obvious code instead of rationale |
| BCS1205 | WARNING | 53 | External `sed` used in helper where builtins are preferred |
bcs: ◉ Tokens: in=22953 out=1722
bcs: ◉ Elapsed: 27s
