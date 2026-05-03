<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part II — Bash as a Program

*Bash is a specific program with a specific history, a specific build configuration, and specific invocation modes. This Part documents what bash actually is — distinct from "the shell" generically — so the reader can reason about which version they have, how it was built, and how it was invoked.*

---

## Chapters

1. [2.1 Genealogy and the shell family](01_Genealogy-and-the-shell-family.md) — Bash sits inside a family of shells with distinct ancestries.
2. [2.2 Bash version landscape](02_Bash-version-landscape.md) — Bash's feature set has grown substantially since 4.0 (2009).
3. [2.3 Build configuration and feature detection](03_Build-configuration-and-feature-detection.md) — Bash is configurable at build time.
4. [2.4 Invocation modes](04_Invocation-modes.md) — Bash behaves differently depending on how it was invoked.
5. [2.5 Startup file chains](05_Startup-file-chains.md) — Each invocation mode reads a different chain of startup files.
6. [2.6 `BASH_ENV` and `ENV`](06_BASH_ENV-and-ENV.md) — Two specific environment variables that control startup file sourcing for non-interactive shells.
7. [2.7 Command-line options to bash itself](07_Command-line-options-to-bash-itself.md) — The bash binary accepts a long list of single-character and `--`-prefixed long options.
8. [2.8 Exit and shell session lifecycle](08_Exit-and-shell-session-lifecycle.md) — How and when bash terminates, what runs at exit, and the difference between exiting the shell and exiting the script.

---

← Previous: [Part I — The Unix Model from Bash](../01_The-Unix-Model-from-Bash/index.md)

Next: [Part III — Lexical Structure and Shell Grammar](../03_Lexical-Structure-and-Shell-Grammar/index.md) →

#fin
