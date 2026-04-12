bcs: ◉ Backend 'anthropic' inferred from model 'claude-sonnet-4-6'
bcs: ◉ Checking '/ai/scripts/File/cln/cln' against BCS (backend=anthropic)...
bcs: ◉ bcs check --model 'claude-sonnet-4-6' --effort 'high' --strict 'off' '/ai/scripts/File/cln/cln'
I'll analyze this script systematically against the BCS.

---

## Findings

---

**BCS0111 — WARNING — Lines 111–127**

The `read_conf()` function uses **first-match-wins** semantics (returns on first found file) rather than the BCS0111 cascade pattern (all matching files sourced in order, with later files overriding earlier ones). Additionally, the function uses `readarray` to parse lines rather than `source`-ing the file, meaning it only loads a list of patterns — not arbitrary key=value configuration. This is a documented intentional deviation (the help text lists paths and the comment says "first found wins"), so it is a WARNING rather than a VIOLATION. The search order is also reversed from the BCS0111 reference (user config is listed first instead of last, giving it highest priority rather than lowest — opposite of the cascade intent).

**Fix:** Either document explicitly that this is intentionally first-match-wins with user-first priority (add a comment), or restructure to cascade-source all matching files in system-first order. If the config format is intentionally a plain pattern list (not sourced shell), document that deviation.

---

**BCS0806 — WARNING — Lines 170–172**

The `#bcscheck disable=BCS0806` directive on line 169 covers the next statement, which is the `-p|-n|--prompt` case arm on line 170. However, the `-P|-N|--no-prompt` arm on lines 171–172 is a **separate case arm** and is not covered by the suppression directive. The use of `-n` for `--prompt` and `-N` for `--no-prompt` conflicts with the BCS0806 standard assignment of `-n` to `--dry-run`. The `-P` letter is also non-standard.

Since the suppression directive is present and intentional for the `-p|-n|--prompt` arm, that arm is suppressed. The `-P|-N|--no-prompt` arm on lines 171–172 is not covered by the directive and represents the same non-standard option letters.

**Fix:** Either extend the suppression to cover both arms (wrap in a brace block under a single `#bcscheck disable=BCS0806`), or add a second suppression directive before line 171.

---

**BCS0111 / BCS0704 — WARNING — Lines 68–74**

The config file search paths listed in `show_help()` (lines 68–74) do not match the order in `read_conf()` (lines 113–119). In `show_help`, XDG is listed first; in `read_conf`, XDG is also first in the array, which is consistent — but the help text label says "first found wins" implicitly by its ordering. The actual search path order in `read_conf` is:

1. `$XDG_CONFIG_HOME/cln/cln.conf`
2. `/etc/cln/cln.conf`
3. `/etc/cln.conf`
4. `/etc/default/cln`
5. `/usr/local/etc/cln/cln.conf`

The help text lists them in the same order but labels it "first found wins" — which is accurate to the implementation but the opposite of FHS-conventional cascade (user last, highest priority). This is a documentation/design consistency issue. The help text accurately reflects the implementation, so this is a WARNING about the non-standard priority order, not a documentation inaccuracy.

**Fix:** If user-config-first priority is intentional, add a comment in `read_conf()` stating this explicitly. If standard cascade priority (system first, user last, user wins) is desired, reverse both the array order and update the help text.

---

**BCS0503 — WARNING — Line 226**

```bash
((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0 ||:
```

This is a chained `&&` with `||:` at the end. Under BCS0606, `((cond)) && action ||:` is acceptable for flag-guarded actions. However, this is a two-condition chain `A && B && C ||:`. The `||:` only catches failure of the entire chain — if `[[ -z ${found_files[0]} ]]` is false (non-empty element), the chain short-circuits before `fnd=0`, and the false result of the `[[ ]]` test would trigger `||:`. This is actually safe as written because `||:` catches it. However, the logic is fragile and the intent (a conditional assignment) is better expressed as:

```bash
((fnd == 1)) && [[ -z ${found_files[0]} ]] && fnd=0 ||:
```

Per BCS0606, the inverted form would be cleaner:

```bash
((fnd != 1)) || [[ -n ${found_files[0]} ]] || fnd=0
```

This is a style WARNING — the `||:` is present so there is no VIOLATION.

---

**BCS0503 — WARNING — Line 201**

```bash
find_expr+=(-name "$spec" -o)
```

followed by:

```bash
unset 'find_expr[-1]'
```

This build-then-trim pattern works but is fragile — `unset 'find_expr[-1]'` removes the last element, which assumes the loop runs at least once. If `all_specs` were empty (guarded by the `die` on line 197), this would never be reached, so it is safe in context. However, this is a non-idiomatic approach to building a `find` OR-expression. This is a minor style note — not a BCS violation — and is omitted from the summary.

---

**BCS0503 — VIOLATION — Line 173**

```bash
-v|--verbose)   ((VERBOSE < 3)) && VERBOSE+=1 ||:  ;;
```

Per BCS0606, `((cond)) && action ||:` is acceptable. This is **not** a violation — the `||:` is present. *(Retracted — omitted.)*

---

**BCS0201 — WARNING — Line 136**

```bash
local -- path
```

This declares `path` with no initializer, then it is assigned in the `for` loop on line 208. This is acceptable — BCS0401 permits declarations before use. However, `path` is declared before `paths` (line 137) and `file` is declared mid-body at line 207, inside the function but after the argument-parsing block. BCS0401 states declarations "may appear mid-body... between logical sections, but must not appear inside loops." Line 207 (`local -- file`) appears between the argument-parsing block and the for loop — this is compliant.

*(No violation — omitted.)*

---

**BCS0103 — WARNING — Line 15**

`SCRIPT_DIR` is not declared. Per BCS0103, `SCRIPT_DIR` is a standard metadata variable. However, BCS0103 also states "Not all scripts will require all Script Metadata variables." Since `SCRIPT_DIR` is never referenced in this script, omitting it is correct per BCS0405. *(No violation — omitted.)*

---

**BCS0704 — WARNING — Line 176–177**

```bash
-V|--version)   echo "$SCRIPT_NAME $VERSION"; return 0 ;;
-h|--help)      show_help; return 0 ;;
```

These use `return 0` instead of `exit 0`. Since parsing occurs inside `main()` and the script is not dual-purpose (no source fence), `return 0` from `main()` propagates back to line 244 (`main "$@"`) and the script exits normally with code 0. This is functionally equivalent for a non-sourced script. This is a WARNING (style deviation) rather than a VIOLATION.

**Fix:** Use `exit 0` for clarity and explicitness, or document that `return 0` from `main()` is intentional.

---

## Summary Table

| BCS Code | Severity | Line(s) | Description |
|----------|----------|---------|-------------|
| BCS0111 | WARNING | 111–127 | `read_conf()` uses first-match-wins with user-config-first priority instead of BCS cascade (all files sourced, system-first). Also uses `readarray` parse instead of `source`. Intentional but undocumented deviation. |
| BCS0806 | WARNING | 171–172 | `-P`/`-N`/`--no-prompt` case arm uses non-standard option letters not covered by the `#bcscheck disable=BCS0806` directive on line 169 (which only covers line 170). |
| BCS0111 | WARNING | 68–74 | Help text search-path order reflects user-first priority (opposite of FHS cascade convention). Accurate to implementation but non-standard priority; should be explicitly documented as intentional. |
| BCS0503 | WARNING | 226 | Double-chained `&&` with `||:` (`A && B && C ||:`) is safe but less clear than the inverted `||` form recommended by BCS0606 for conditional assignments. |
| BCS0704 | WARNING | 176–177 | `return 0` used instead of `exit 0` for `--version` and `--help` inside `main()`. Functionally equivalent for non-sourced scripts but deviates from the explicit-exit convention. |
bcs: ◉ Tokens: in=26318 out=2268
bcs: ◉ Elapsed: 41s
