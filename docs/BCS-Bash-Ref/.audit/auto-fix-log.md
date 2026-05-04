<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Auto-fix log

Mechanical fixes applied during the 2026-05-03 audit. Each entry records
file, issue class, before/after, and originating audit pass.

Format per entry:

```
### path/to/file.md
- **Class**: dangling-xref | wrong-section-number | typo | missing-fin | trailing-whitespace
- **Pass**: preflight | content-audit-PartNN
- **Before**: ...
- **After**: ...
- **Justification**: ...
```

---

### docs/BCS-Bash-Ref/02_Bash-as-a-Program/08_Exit-and-shell-session-lifecycle.md
- **Class**: incorrect-EXIT-trap-inheritance-claim
- **Pass**: phase-A-mechanical
- **Before**: `Subshell exit — does not run parent's EXIT trap unless set -E and parent's trap is inheritable (it isn't, by design).`
- **After**: `Subshell exit — subshells never inherit the EXIT trap. set -E (errtrace) governs ERR/DEBUG/RETURN inheritance only; it does not propagate EXIT. Demonstrate: ( trap 'echo X' EXIT; true ) prints nothing from the subshell.`
- **Justification**: Original sentence implied set -E might propagate EXIT; corrected to state EXIT is never inherited by subshells and that errtrace covers ERR/DEBUG/RETURN only, with a runnable demonstration.

### docs/BCS-Bash-Ref/07_Control-Flow-and-Compound-Commands/01_Compound-command-overview.md
- **Class**: arithmetic-mismatch
- **Pass**: phase-A-mechanical
- **Before**: `A compound command is one of seven forms: brace group, subshell, if, case, while, until, for, select, (( )), [[ ]].`
- **After**: `A compound command is one of ten forms: brace group, subshell, if, case, while, until, for, select, (( )), [[ ]].`
- **Justification**: Enumerated list contains 10 forms, not 7; replaced the count to match the enumeration.

### docs/BCS-Bash-Ref/13_Error-Handling-and-Exit-Status/09_errtrace-and-trap-inheritance.md
- **Class**: strict-mode-preamble-drift
- **Pass**: phase-A-mechanical
- **Before**: `Strict-mode scripts often use set -eET -o pipefail plus inherit_errexit.`
- **After**: `Strict-mode scripts use the canonical contract: set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob. Add set -E (or set -eET) when ERR traps must fire inside functions, command substitutions, and subshells.`
- **Justification**: Expanded the partial preamble to the full canonical strict-mode contract while keeping the section's errtrace focus.

### docs/BCS-Bash-Ref/16_Concurrency-and-Parallelism/05_Bounded-concurrency-fan-out.md
- **Class**: buggy-array-removal-idiom
- **Pass**: phase-A-mechanical
- **Before**: `pids=("${pids[@]/$done_pid}")`
- **After**: `for i in "${!pids[@]}"; do if [[ ${pids[i]} == "$done_pid" ]]; then unset 'pids[i]'; break; fi; done` (with comment noting `${array[@]/value}` only mutates strings, not array membership)
- **Justification**: `${array[@]/value}` performs string substitution on each element and never removes membership; replaced with proper unset-by-index loop.

### docs/BCS-Bash-Ref/12_Signals-and-Traps/14_Lockfile-pattern.md
- **Class**: missing-dependency-note
- **Pass**: phase-A-mechanical
- **Before**: `flock builtin (in util-linux) takes an fd and an exclusion mode.`
- **After**: Added intro sentence "`flock(1)` is an external command from the `util-linux` package, not a Bash builtin." and corrected the bullet to "`flock` (external, from `util-linux`) ...".
- **Justification**: `flock` was incorrectly described as a builtin; clarified it is an external command from util-linux at first mention.

### docs/BCS-Bash-Ref/19_Performance/06_EPOCHREALTIME-for-sub-second-timing.md
- **Class**: external-command-dependency-in-timing-demo
- **Pass**: phase-A-mechanical
- **Before**: `printf '%.3f\n' "$(bc -l <<<"$end - $start")"`
- **After**: `delta=$(( ${end/./} - ${start/./} )); printf '%d.%06d\n' $((delta/1000000)) $((delta%1000000))`
- **Justification**: Forking `bc -l` to compute a microsecond delta defeats the purpose of microsecond timing; replaced with builtin-only integer arithmetic that strips the dot from EPOCHREALTIME and reformats microseconds.

### docs/BCS-Bash-Ref/05_Expansions/06_Command-substitution.md
- **Class**: mislabelled-idiom
- **Pass**: phase-A-mechanical
- **Before**: `Pitfall: $(<file) — reads file into variable, faster than $(cat file).`
- **After**: `Idiom: $(<file) — preferred fast file-read; reads the file into a variable in the current shell without forking cat. Trailing newlines are stripped per command-substitution rules.`
- **Justification**: `$(<file)` is the recommended fast read form, not a pitfall; relabelled and clarified semantics.

### docs/BCS-Bash-Ref/05_Expansions/13_Locale-and-pattern-matching.md
- **Class**: vague-claim
- **Pass**: phase-A-mechanical
- **Before**: `Bash 5.2 introduces stricter UTF-8 handling in some areas.`
- **After**: `globasciiranges (shopt, default on since bash 4.3) forces bracket-range globs like [a-z] to use ASCII C-locale ordering regardless of LC_COLLATE, sidestepping locale-dependent range surprises. Without it, LC_COLLATE decides whether [a-z] includes accented letters or interleaves upper/lowercase.`
- **Justification**: Replaced unsupported "stricter UTF-8" claim with a precise, citable statement about `globasciiranges` and its interaction with `LC_COLLATE`.

### docs/BCS-Bash-Ref/13_Error-Handling-and-Exit-Status/01_Exit-status-fundamentals.md (block #1)
- **Class**: lint-noise-suppression + idiom-substitution
- **Pass**: phase-12-Part-13
- **Before**: `$(exit 257); echo "$?"` (5 lines, no shellcheck disable)
- **After**: `(exit 257); echo "$?"` (subshell form, no SC2091; entire group wrapped in `{ … }` under `# shellcheck disable=SC2242` so out-of-range codes don't lint-pollute the demo).
- **Justification**: Demo shows 8-bit truncation and negative-wrap behaviour. `(exit N)` has identical semantics to `$(exit N)` for setting `$?`. Brace-block scope of the disable directive covers all 5 demo lines.

### docs/BCS-Bash-Ref/13_Error-Handling-and-Exit-Status/03_The-errexit-exemption-matrix.md (block #2)
- **Class**: infinite-loop-in-sandbox
- **Pass**: phase-12-Part-13
- **Before**: `while ! mountpoint -q /mnt; do sleep 1; done` — looped forever in sandbox where /mnt is not a mountpoint.
- **After**: `if ! mountpoint -q /mnt 2>/dev/null; then …; fi` — one-shot demo of the same `! cmd` exemption from errexit; added explicit `# ⇒` annotations for grep/mountpoint/echo lines.
- **Justification**: Original was a TIMEOUT in batch (no mounting happens). The exemption is about `! cmd` in a test position; one `if ! mountpoint` makes the same point without the polling loop.

### docs/BCS-Bash-Ref/13_Error-Handling-and-Exit-Status/04_set-u-nounset.md (block #2)
- **Class**: errexit-aborts-demo + prose-annotation
- **Pass**: phase-12-Part-13
- **Before**: First loop `for x in "${results[@]}"; do …` aborted under `set -u`; the "Fix" sections never executed.
- **After**: Replaced the broken first loop with a comment-only illustration of the error message; kept the two working fixes (default-expand and length-gate) and added literal `# ⇒` annotations.
- **Justification**: The whole block was crashing on its first command, so the fix demos were unobservable. The didactic point is preserved by spelling out the error in a comment and keeping the runnable fix paths.

### docs/BCS-Bash-Ref/13_Error-Handling-and-Exit-Status/07_and-true-idioms.md (block #2)
- **Class**: too-terse-annotation
- **Pass**: phase-12-Part-13
- **Before**: `echo 'we get here despite cmd_a failing' # ⇒ printed`
- **After**: `echo 'we get here despite cmd_a failing' # ⇒ we get here despite cmd_a failing`
- **Justification**: Annotation must match captured stdout literally. "printed" was a meta-comment, not the captured text.

### docs/BCS-Bash-Ref/20_Security/04_eval-avoidance.md (block #6)
- **Class**: rc-1-on-empty-result
- **Pass**: phase-12-Part-20
- **Before**: `grep -rnE '\beval\b' --include='*.bash' --include='*.sh' .` — sandbox CWD has no .bash/.sh files; grep returns 1; block CRASHes.
- **After**: Append `|| true` and a clarifying comment that rc=1 just means "no eval call sites".
- **Justification**: The block teaches the audit-sweep idiom; whether the sweep finds anything is environment-dependent.

### docs/BCS-Bash-Ref/20_Security/05_Command-injection-vectors.md (block #4)
- **Class**: prose-annotation + missing-fixtures
- **Pass**: phase-12-Part-20
- **Before**: `find . -type f -exec sh -c '…' sh {} +` plus `# ⇒ {} are passed as "$@", never re-parsed` (descriptive, never matches stdout).
- **After**: Set up two fixture files under a relative `_demo/` dir, `printf` inside the inner sh-c body, and add literal `# ⇒ processed: _demo/a.txt` / `b.txt` annotations.
- **Justification**: The block now both demonstrates the positional-pass-through pattern *and* produces deterministic output that the matcher can verify.

### docs/BCS-Bash-Ref/20_Security/09_Secrets-handling.md (block #4)
- **Class**: fictional-tool
- **Pass**: phase-12-Part-20
- **Before**: `{ set +x; api_call --secret-from-env; set -x; } 2>/dev/null` — `api_call` does not exist; rc=127.
- **After**: Add `api_call() { :; }` placeholder ahead of the brace group. The pattern (set +x / call / set -x in a redirected group) is what the demo teaches.
- **Justification**: The trace-disable pattern is what matters; the inner call is a stand-in for whatever real client the reader uses.

### docs/BCS-Bash-Ref/.audit/tools/run-blocks.bash (matcher hardening)
- **Class**: matcher-em-dash-clarifier
- **Pass**: phase-12-matcher
- **Before**: extract_expected only stripped trailing `(parenthetical)` clarifiers; the corpus convention `# ⇒ literal — explanatory prose` (em-dash separator with 1+ space) caused MISMATCH on all such annotations.
- **After**: Strip trailing `[[:space:]]+—[[:space:]].*$` from each annotation. Drop annotations that begin with an em-dash entirely (pure prose).
- **Justification**: Resolved ~14 spurious MISMATCHes across Parts 04, 05, 12 in one fix; legitimate em-dashes in stdout are vanishingly rare in shell output.

### docs/BCS-Bash-Ref/.audit/tools/triage.bash (lint code sweep)
- **Class**: lint-classification-coverage
- **Pass**: phase-12-triage
- **Before**: classify_lint() had cases for ~13 SC codes; everything else fell through to REVIEW LOW.
- **After**: Added ADD_SUPPRESSION cases for SC2088, SC2080, SC2050, SC2125, SC2194, SC2206, SC2128, SC2053, SC2066, SC2064, SC2069/75/76, plus parser-confusion sweep (SC1010/1020/1035/1054/1055/1056/1072/1073/1083/1087/1133/1141) and fragment-context sweep (SC2104/2152/2188/2216/2220/2254/2259/2261). FIX_BLOCK MEDIUM for SC2207 (mapfile preferred over $() into array). SC2242 promoted from REVIEW to ADD_SUPPRESSION (truncation/negative-code demos are pedagogical).
- **Justification**: Cleared the lint REVIEW pile (106 → 0) so manual triage focuses on runtime corpus issues.

### docs/BCS-Bash-Ref/04_Parameters-Variables-and-Arrays/* (Part-04 sweep)
- **Class**: annotation-and-block-corrections
- **Pass**: phase-12-Part-04
- Resolved 18 entries across leaves 01, 02, 04, 05, 06, 08, 09, 10, 11, 13, 14:
  - 01_Parameter-taxonomy.md #2: dropped `…` from PID/version annotations.
  - 02_Positional-parameters.md #3: pre-set `$@` so the getopts loop has args; per-line `# ⇒` annotations.
  - 04_Shell-variables.md #1: capture trace via `outer 2>&1`; clean up annotations.
  - 05_The-declare #2/#5: hash-order non-determinism — drop the literal element-list expectation.
  - 05_The-declare #6: the doc claimed `local foo` inherits `-i`; bash 5.2 does not. Switched demo to `local -i counter` (explicit) and rewrote the surrounding prose.
  - 06_local-and-dynamic-scope.md #1: rewrote the `local --help` parse-trap demo so it actually triggers (previous form was a misconception); added a runnable invocation.
  - 08_export-and-the-environment.md #3: simplified the BASH_FUNC_ annotation prefix.
  - 09_Indexed-arrays.md #2 + 14_Unsetting.md #1: split single-line `# ⇒` joins into per-line annotations matching `printf '%s\n'` output (or used `printf '%s '; echo` where one-line was the point).
  - 10_Associative-arrays.md #1/#6: moved the `local -A` sub-demo into a function; switched `local -a sorted` to `declare -a sorted` at script scope; relaxed hash-order annotation.
  - 11_Namerefs-n.md #5: piped warning to `head -1`, then ran the right-side demo for verifiable output.
  - 13_Variable-assignment-semantics.md #1/#2: created two `.txt` and two `.md` fixtures so the glob expansions actually have something to match.
  - 13_Variable-assignment-semantics.md #6: wrap readonly-violation in a subshell `(x=43) 2>&1 || true` so set -e in the outer shell doesn't propagate the failure.
- **Justification**: All 18 REVIEW entries cleared; remaining CRASHes in Part-04 are auto-classified as EXPECTED_CRASH (anti-pattern demos).

### docs/BCS-Bash-Ref/03_Lexical-Structure-and-Shell-Grammar/* (Part-03 sweep)
- **Class**: annotation-and-block-corrections
- **Pass**: phase-12-Part-03
- Resolved 5 entries across leaves 03, 07, 09:
  - 03_Comments.md #1: added `echo "$url"` and `echo "$result"` so the assignment-only lines have visible output.
  - 07_ANSI-C-quoting.md #1: replaced spaced-out `tab     here    end` annotation with prose noting the literal TABs; flagged the precomposed-é vs combining-acute byte difference.
  - 07_ANSI-C-quoting.md #3: replaced spaced-out `hello   world` annotations with `→` prose noting the literal TAB.
  - 09_Backslash-escapes.md #1: same TAB/LF prose substitution for the ANSI-C demo.
  - 09_Backslash-escapes.md #2: added explicit `echo "$msg"` so the line-continuation demo produces matchable output.
- **Justification**: All 5 REVIEW entries cleared.

#fin
