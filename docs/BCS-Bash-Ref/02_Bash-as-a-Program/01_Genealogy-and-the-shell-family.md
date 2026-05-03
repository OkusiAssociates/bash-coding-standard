<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 2.1 Genealogy and the shell family

Bash sits inside a family of shells with distinct ancestries. Knowing the relationships clarifies which features are universal, which are bash-specific, and what to expect when porting to a sibling. The lineage matters for portability claims (BCS0102 only sanctions a Bash shebang; targeting sh-style shells means writing different code, not the same code).

Two main branches descend from Bourne's original `sh` (Version 7 Unix, 1979):

The Bourne / POSIX line:

- **Bourne shell** (`sh`, 1977/1979) — Stephen Bourne at Bell Labs. The substrate of every modern Unix shell.
- **Korn shell** (`ksh88` 1988, `ksh93` 1993, `mksh` fork 2003) — David Korn's superset. First to add associative arrays, `[[`, `((`, and many features Bash later absorbed.
- **Almquist shell** (`ash` 1989, `dash` 2002) — minimal POSIX-compliant rewrite. `dash` is `/bin/sh` on Debian and Ubuntu, and is the canonical "is it really POSIX?" reality check.
- **BusyBox `sh`** — `ash`-derived; the embedded-systems default.
- **Bash** (1989) — Brian Fox's GNU clone of `sh` with `ksh` and `csh` features bolted on. Maintained by Chet Ramey since 1992.

The C-shell offshoot:

- **C shell** (`csh`, 1978) — Bill Joy at Berkeley. Different syntax (`if (cond) then`), now obsolete for scripting.
- **TENEX C shell** (`tcsh`) — interactive `csh` with line editing.

The reimaginings:

- **Z shell** (`zsh`, 1990) — Paul Falstad. Rich interactive shell with substantial `ksh`/`bash` compatibility but its own scripting idioms; macOS default login shell since 10.15 (2019).
- **macOS Bash 3.2** (2006) — the perpetual outlier. Apple froze at 3.2.57 over GPLv3 licensing concerns; modern Bash is available via Homebrew or MacPorts (see §23.6).

Standardisation: POSIX 1003.2 (1992) and SUS / IEEE 1003.1 (current revision: 2024) define the portable subset every serious shell aims at. Bash's `--posix` mode disables most extensions and conforms to that baseline.

**See also**: §2.2 (version landscape — what each Bash release added), §2.7 (`--posix` and other invocation modes), §23.6 (macOS Bash 3.2 mitigations), §23.3 (Bash vs `dash` portability gotchas).

#fin
