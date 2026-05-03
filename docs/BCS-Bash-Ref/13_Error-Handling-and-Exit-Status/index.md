<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XIII — Error Handling and Exit Status

*Bash's error-handling semantics are notoriously subtle. `set -e` does not mean "exit on any error" — it means "exit on any error in one of N specific contexts, with M specific exemptions". This Part documents the full semantics and the strict-mode discipline that makes them predictable.*

---

## Chapters

1. [13.1 Exit status fundamentals](01_Exit-status-fundamentals.md) — Every command produces an 8-bit exit status.
2. [13.2 `set -e` (errexit) — full semantics](02_set-e-errexit-full-semantics.md) — Exit on any non-zero command status, except in the exemption matrix (§13.3).
3. [13.3 The errexit exemption matrix](03_The-errexit-exemption-matrix.md) — Contexts in which `set -e` does *not* fire on failure.
4. [13.4 `set -u` (nounset)](04_set-u-nounset.md) — Treat references to unset variables as errors.
5. [13.5 `set -o pipefail`](05_set-o-pipefail.md) — Make a pipeline's exit status the rightmost non-zero status.
6. [13.6 `inherit_errexit`](06_inherit_errexit.md) — `shopt -s inherit_errexit` makes command substitutions inherit `errexit` from the parent.
7. [13.7 `||:` and `|| true` idioms](07_and-true-idioms.md) — Two equivalent idioms for "I expected this to potentially fail and I don't care".
8. [13.8 The `ERR` trap](08_The-ERR-trap.md) — Fires whenever a command would cause `set -e` to exit.
9. [13.9 `errtrace` and trap inheritance](09_errtrace-and-trap-inheritance.md) — `set -E` (alias `set -o errtrace`) propagates ERR trap to functions, command substitutions, and subshells.
10. [13.10 Exit code conventions](10_Exit-code-conventions.md) — Standardised exit codes that callers can interpret.
11. [13.11 Propagating exit codes](11_Propagating-exit-codes.md) — How to ensure a function's failure surfaces to the caller and how to capture it cleanly.
12. [13.12 Rich error output](12_Rich-error-output.md) — Producing diagnostics that help debugging.

---

← Previous: [Part XII — Signals and Traps](../12_Signals-and-Traps/index.md)

Next: [Part XIV — Input, Output, and Messaging](../14_Input-Output-and-Messaging/index.md) →

#fin
