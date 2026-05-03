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

#fin
