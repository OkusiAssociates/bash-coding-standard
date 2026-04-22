<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Compliance Checking Reference

This section summarises key rules that are frequently misapplied during automated compliance checking. It does not introduce new rules — it reinforces existing ones.

## Severity

- **VIOLATION**: Code is incorrect, unsafe, or clearly breaks a mandatory (MUST/SHALL) rule.
- **WARNING**: Style deviation, SHOULD/RECOMMENDED level, or intentional design choice that deviates from a reference pattern.

When a rule says "prefer X over Y", using Y is a WARNING at most — not a VIOLATION.

## Production Optimization Takes Precedence (BCS0405)

Reference implementations in BCS0703, BCS0706, and BCS0701 show the full messaging suite, color set, and flag set. These are templates — not mandatory checklists. Per BCS0405:

- Do NOT flag missing functions (`success()`, `debug()`, `vecho()`) the script never calls
- Do NOT flag missing colors (`GREEN`) the script never references
- Do NOT flag missing flags (`DEBUG`) the script never tests
- Do NOT add unused code to satisfy a template

A script that defines only the functions, colors, and flags it actually uses is **more** compliant than one that carries dead code from a template.

## Conditional Safety — `||:` Present Means Safe (BCS0606)

```bash
# acceptable — ||: catches failure from the ENTIRE chain
((VERBOSE)) && echo 'verbose' ||:
((cond)) && action1 && action2 ||:
```

Missing `||:` on a `&&` chain under `set -e` is a VIOLATION. Using `&&...||:` instead of the inverted `||` form is a style preference — both are correct.

## Suppression Directives

`#bcscheck disable=BCSxxxx` follows ShellCheck conventions — it suppresses the **next command**, which may be a single line or a brace/block group. A suppressed finding is not a finding. Do not report it, discuss it, or note it "for completeness."

## Reference Patterns Are Not Mandates

Rules like BCS0709 (`yn()`), BCS0111 (`read_conf()`), and BCS1211 (utility functions) show reference implementations. Functionally equivalent alternatives are acceptable. Intentional deviations documented in comments or help text are not violations.

## Inline IFS Is Already Scoped

```bash
# correct — IFS is scoped to this single read command (no global side-effect)
IFS=',' read -ra fields <<< "$csv_data"
IFS='|' read -ra cells <<< "$line"
IFS=$'\037' read -ra parts <<< "$row"
```

The `IFS=value command` form modifies IFS only for the duration of that command. This is NOT an unlocalized IFS modification and does NOT require `local -- IFS` or subshell isolation. Do not flag this pattern as a violation.

## Common Non-Issues

- `SCRIPT_DIR` omitted when unused (BCS0103 note: "Not all scripts will require all Script Metadata variables")
- `return 0` from `main()` instead of `exit 0` — functionally equivalent for non-sourced scripts (WARNING at most, not VIOLATION)
- Config search paths adjusted from the BCS0111 reference order — acceptable when documented in help text
- `local` declarations between logical sections within a function — permitted by BCS0401 ("Declarations may appear mid-body... between logical sections"), only prohibited inside loops
- Option bundling includes arg-taking options — BCS0805 documents that the user must place arg-taking options last in a bundle; this is the user's responsibility, not a script defect
