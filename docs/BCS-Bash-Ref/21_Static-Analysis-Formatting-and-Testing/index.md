<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XXI — Static Analysis, Formatting, and Testing

*Bash without ShellCheck is Python without a linter. This Part documents the tooling stack: static analysis, formatting, compliance checking, testing, and CI integration.*

---

## Chapters

1. [21.1 ShellCheck warnings](01_ShellCheck-warnings.md) — ShellCheck is the de facto bash static analyser.
2. [21.2 ShellCheck directives](02_ShellCheck-directives.md) — Inline pragmas to suppress specific warnings with a stated reason.
3. [21.3 Source-path management](03_Source-path-management.md) — Helping ShellCheck follow `source` statements.
4. [21.4 `shfmt`](04_shfmt.md) — A bash formatter, analogous to `gofmt`.
5. [21.5 `bcscheck`](05_bcscheck.md) — LLM-backed BCS compliance checker.
6. [21.6 Pre-commit hooks](06_Pre-commit-hooks.md) — Run linters and formatters on every commit.
7. [21.7 CI integration](07_CI-integration.md) — Running the tooling stack in CI.
8. [21.8 bats-core](08_bats-core.md) — The standard bash test framework.
9. [21.9 Bats setup and teardown](09_Bats-setup-and-teardown.md) — The lifecycle hooks.
10. [21.10 Bats `run` and assertions](10_Bats-run-and-assertions.md) — Capturing output and asserting on it.
11. [21.11 Mocking via PATH injection](11_Mocking-via-PATH-injection.md) — Replacing external commands for tests.
12. [21.12 shunit2](12_shunit2.md) — Older bash test framework, less popular than bats but still used.
13. [21.13 Coverage with kcov](13_Coverage-with-kcov.md) — Code coverage measurement for bash.

---

← Previous: [Part XX — Security](../20_Security/index.md)

Next: [Part XXII — Idioms, Patterns, and Anti-Patterns](../22_Idioms-Patterns-and-Anti-Patterns/index.md) →

#fin
