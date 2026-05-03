<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXII — Idioms, Patterns, and Anti-Patterns

*A catalogue of patterns that appear repeatedly in well-written bash, and a catalogue of patterns that should not appear at all. This Part is essentially a cookbook for the BCS-aligned engineer.*

---

## Chapters

1. [22.1 The strict-mode preamble](01_The-strict-mode-preamble.md) — The opening every script must have.
2. [22.2 Self-locating script directory](02_Self-locating-script-directory.md) — Find the script's own directory regardless of how it was invoked.
3. [22.3 Argument-parsing skeleton](03_Argument-parsing-skeleton.md) — The full BCS-canonical hand-rolled parser.
4. [22.4 Default-value patterns](04_Default-value-patterns.md) — Setting defaults for variables.
5. [22.5 Lazy initialisation](05_Lazy-initialisation.md) — Compute on first use.
6. [22.6 Memoisation](06_Memoisation.md) — Cache function results.
7. [22.7 Iterating an associative array deterministically](07_Iterating-an-associative-array-deterministically.md) — Bash hashtable iteration order is unspecified.
8. [22.8 Building structured output](08_Building-structured-output.md) — Emit CSV, TSV, or JSON from bash.
9. [22.9 Reading config files safely](09_Reading-config-files-safely.md) — Sourcing arbitrary files is a code-execution risk.
10. [22.10 Atomic file write](10_Atomic-file-write.md) — Write to a sibling tempfile, then rename.
11. [22.11 Exclusive lock](11_Exclusive-lock.md) — `flock` on a dedicated lockfile.
12. [22.12 Bounded retry with exponential backoff](12_Bounded-retry-with-exponential-backoff.md) — Retry on transient failure with growing delay.
13. [22.13 Tempdir lifecycle](13_Tempdir-lifecycle.md) — `mktemp -d` plus EXIT trap.
14. [22.14 Mock-friendly subprocess wrapper](14_Mock-friendly-subprocess-wrapper.md) — Wrap external commands behind a function for testability.
15. [22.15 Stack-trace error reporter](15_Stack-trace-error-reporter.md) — Rich error output via FUNCNAME/BASH_SOURCE/BASH_LINENO.
16. [22.16 Self-test mode (dual-purpose script)](16_Self-test-mode-dual-purpose-script.md) — A script that runs as a script when invoked directly and as a library when sourced.
17. [22.17 Anti-patterns catalogue](17_Anti-patterns-catalogue.md) — Patterns that appear in legacy code and should not be perpetuated.

---

← Previous: [Part XXI — Static Analysis, Formatting, and Testing](../21_Static-Analysis-Formatting-and-Testing/index.md)

Next: [Part XXIII — POSIX Conformance and Portability](../23_POSIX-Conformance-and-Portability/index.md) →

#fin
