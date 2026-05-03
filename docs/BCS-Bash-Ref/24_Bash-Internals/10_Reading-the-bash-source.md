<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.10 Reading the bash source

For deep understanding, the canonical resource is the bash source itself.

- Repository: `https://git.savannah.gnu.org/cgit/bash.git/`.
- Key files: `parse.y` (grammar), `subst.c` (expansion), `execute_cmd.c` (execution), `variables.c` (variable management), `jobs.c` (job control).
- Build from source: `./configure && make`.
- Comments are dense but informative.
- The bash maintainer (Chet Ramey) is responsive on the bug-bash mailing list.

#fin
