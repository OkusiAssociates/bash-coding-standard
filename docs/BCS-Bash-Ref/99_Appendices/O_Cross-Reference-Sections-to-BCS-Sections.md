<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## Appendix O — Cross-Reference: Sections to BCS Sections

Map from this document's chapters to the relevant BCS coding-standard
sections, resolved where possible to specific `BCS####` codes.

The left-hand BCS section is the standard's Section number (Section 01
= "Script Structure"); the right-hand BCS#### codes are individual
rules within that section. Codes were verified against the
`./bcs codes` listing for bash-coding-standard 5.2-aligned BCS.

| BCS Section | Title | Reference chapters | Key BCS codes |
|-------------|-------|-------------------|---------------|
| §01 | Script Structure & Layout | §22.1, §22.2, §22.16, parts of §2 | BCS0101 (strict mode), BCS0102 (shebang), BCS0103 (script metadata), BCS0104 (FHS compliance), BCS0105 (global variables), BCS0106 (file extensions), BCS0107 (function organisation), BCS0108 (main function), BCS0109 (`#fin` end marker), BCS0110 (cleanup and traps), BCS0111 (config file loading) |
| §02 | Variables | Part IV (chapters 4.1–4.14) | BCS0201 (type-specific declarations), BCS0202 (variable scoping), BCS0203 (naming conventions), BCS0204 (constants and environment), BCS0205 (readonly patterns), BCS0206 (arrays), BCS0207 (parameter expansion), BCS0208 (boolean flags), BCS0209 (derived variables) |
| §03 | Strings & Quoting | Part III (3.4–3.9), §5.4 | BCS0301 (quoting fundamentals), BCS0302 (command substitution), BCS0303 (quoting in conditionals), BCS0304 (here documents), BCS0305 (printf patterns), BCS0306 (`@Q` parameter quoting), BCS0307 (anti-patterns) |
| §04 | Functions | Part IX, Part X | BCS0401 (function definition), BCS0402 (function names), BCS0403 (main function), BCS0404 (function export), BCS0405 (production optimisation), BCS0406 (dual-purpose scripts), BCS0407 (library patterns), BCS0408 (dependency management), BCS0409 (bash version detection), BCS0410 (recursive function state), BCS0411 (subshell return-value patterns) |
| §05 | Control Flow | Part VII, Part VIII | BCS0501 (conditionals), BCS0502 (case statements), BCS0503 (loops), BCS0504 (process substitution), BCS0505 (arithmetic operations), BCS0506 (floating-point) |
| §06 | Error Handling | Part XIII | BCS0601 (exit on error), BCS0602 (exit codes), BCS0603 (trap handling), BCS0604 (checking return values), BCS0605 (error suppression), BCS0606 (conditional declarations) |
| §07 | I/O & Messaging | Part VI, Part XIV | BCS0701 (message control flags), BCS0702 (stdout vs stderr), BCS0703 (core messaging system), BCS0704 (usage documentation), BCS0705 (echo vs messaging functions), BCS0706 (color definitions), BCS0707 (TUI basics), BCS0708 (terminal capabilities), BCS0709 (yes/no prompt), BCS0710 (standard icons), BCS0711 (combined redirection) |
| §08 | Command-Line Processing | Part XV, §22.3 | BCS0801 (standard parsing pattern), BCS0802 (version output), BCS0803 (argument validation), BCS0804 (parsing location), BCS0805 (short option bundling), BCS0806 (standard options) |
| §09 | File Operations | §1.3, §6.x, §17.x, §22.10, §22.13 | BCS0901 (safe file testing), BCS0902 (wildcard expansion), BCS0903 (process substitution), BCS0904 (here documents), BCS0905 (input redirection), BCS0906 (`find` subshell pitfalls) |
| §10 | Security | Part XX, §22.9, §22.13 | BCS1001 (SUID/SGID prohibition), BCS1002 (PATH security), BCS1003 (IFS safety), BCS1004 (eval avoidance), BCS1005 (input sanitisation), BCS1006 (temporary file handling), BCS1007 (environment scrubbing before exec) |
| §11 | Concurrency | Part XVI, Part XVII, §22.11, §22.12 | BCS1101 (background job management), BCS1102 (parallel execution), BCS1103 (wait patterns), BCS1104 (timeout handling), BCS1105 (exponential backoff) |
| §12 | Style & Development | Part XXI, §22.16, §22.17 | BCS1201 (code formatting), BCS1202 (comments), BCS1203 (blank lines), BCS1204 (section comments), BCS1205 (language best practices), BCS1206 (static analysis directives), BCS1207 (debugging), BCS1208 (dry-run pattern), BCS1209 (testing support), BCS1210 (progressive state management), BCS1211 (utility functions), BCS1212 (Makefile installation), BCS1213 (date and time formatting) |
| §13 | Environment | §1.5, §2.5–§2.6, §22.9 | Section 13 is the environment-configuration reference (BCS configuration variables, backend model overrides, credentials, runtime behaviour). It is reference-form rather than rule-coded; consult `data/13-environment.md` for the per-variable definitions. |

### Reading the cross-reference

A chapter may legitimately resolve to multiple BCS sections (the
strict-mode preamble, §22.1, hooks both BCS0101 and BCS0102; the
argument-parsing skeleton in §22.3 hooks the entire §08 family). When
in doubt, the canonical recipe lives in the reference chapter; the
*rule* stating that the recipe is mandatory lives in the BCS code.

The Section-98 reserved namespace (codes `BCS98xx`) is set aside for
user-supplied rules (see CLAUDE.md → "User Rule Extensions") and is
not cross-referenced here — by design, those rules are organisation-
specific and outside the upstream reference.

**See also**: Appendix P (Cross-Reference: Sections to BCS-bash files)
for the parallel mapping into the bash-5.2 reference; `data/BASH-CODING-STANDARD.md`
for the full text of every BCS rule cited above; `./bcs codes -T core`
for the subset of rules whose violations are reported as `[ERROR]`.

#fin
