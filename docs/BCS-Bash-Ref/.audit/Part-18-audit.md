<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
# Part XVIII — Readline, History, and Completion — Audit

Date: 2026-05-03
Priority: P3 (specialist)
Files audited: 17 (16 chapters + index)

## Summary

Part XVIII is largely a configuration-and-cheatsheet domain: `bind` builtin,
`~/.inputrc`, completion specs, prompt escapes, history-expansion designators,
`COMP_*` variables. The skeleton is the strongest in this shard: most chapters
are short by design and complete enough to function as cheat-cards. As the
audit briefing anticipates, many chapters legitimately KEEP.

Disposition tally: KEEP 11 / ENRICH 6 / PROMOTE 0. This is the closest
shard match to the README's expected envelope and reflects the
"cheatsheet-shaped" nature of the topic.

## Top-5 findings

1. **[major] §18.11 Dynamic completion functions is the only chapter with a
   non-trivial example; it deserves to be referenced from §18.8 and §18.10
   but is not.** Add bidirectional xrefs.
2. **[minor] §18.3 Key bindings enumerates `~/.inputrc` syntax in bullets
   but never shows a full inputrc fragment.** A 6-line `$if mode=emacs` /
   `$endif` block would anchor the bullets. ENRICH.
3. **[minor] §18.10 `_init_completion` mentions the helper without a
   call-site demo.** A 3-line `_funcname() { local cur prev words cword;
   _init_completion || return; ... }` snippet would make the bullets
   self-contained.
4. **[minor] §18.15 multi-line/coloured prompts mentions the `\[…\]` wrap
   discipline as essential but provides no PS1 example demonstrating it.**
   This is the most frequent prompt bug. ENRICH with one example.
5. **[fixable] §18.16 Terminal-capability-detection cheatsheet uses `tput`
   throughout; consider a single `if [[ -t 1 && $(tput colors) -ge 8 ]]`
   guard example to anchor the "always test before emitting colour"
   advisory.** ENRICH.

## Per-leaf table

| File | Disposition | Notes |
|------|-------------|-------|
| index.md | KEEP | Complete chapter index |
| 01_Readline-overview.md | KEEP | Terse but accurate orientation |
| 02_Editing-modes.md | KEEP | Adequate cheatsheet |
| 03_Key-bindings.md | ENRICH | Add `~/.inputrc` fragment |
| 04_Bindable-functions.md | KEEP | `bind -l` is the canonical lookup |
| 05_History.md | KEEP | HIST* enumeration complete |
| 06_The-history-builtin.md | KEEP | Subcommand cheat-card sufficient |
| 07_History-expansion.md | KEEP | Designator/modifier reference complete |
| 08_Programmable-completion.md | ENRICH | Add `complete -F` skeleton |
| 09_Compspec-actions.md | KEEP | Action enumeration is reference |
| 10__init_completion.md | ENRICH | Add tiny call-site demo |
| 11_Dynamic-completion-functions.md | KEEP | Idiomatic example present |
| 12_COMPREPLY-and-COMP_-variables.md | KEEP | Variable enumeration complete |
| 13_Prompts.md | KEEP | PS0–PS4 enumeration adequate |
| 14_Prompt-escapes.md | KEEP | Escape table is complete cheat-card |
| 15_Coloured-and-multi-line-prompts.md | ENRICH | Need one PS1 colour example |
| 16_Terminal-capability-detection.md | ENRICH | Add `tput colors` guard demo |

## Cross-reference issues

- §18.7 History expansion's "Disable in scripts: `set +H`" should xref
  §13/14 Error handling (history expansion in scripts is a footgun); not
  present.
- §18.8 Programmable completion does not back-link to §18.11 dynamic
  completion functions where the actual pattern lives.
- §18.13 Prompts mentions `PS4` and §19.5 PS4-instrumentation covers the
  same variable from a tracing perspective; **add reciprocal xrefs**.
- §18.15 mentions `starship` / `oh-my-bash`; these are external tools and
  should be marked as such (and xref §17.8 external IPC tools' style of
  call-out).

## Self-containment risks

- "BCS pattern" is implicit in §18.7 ("Disable in scripts") but no rule
  cited. RAG retrieval will not surface a relevant standard.
- §18.10 references `/usr/share/bash-completion/bash_completion`; a RAG
  agent in a non-Linux/non-Debian context will not find this file. Mark
  the path as Linux-typical.
- §18.16 uses `tput` without naming the `ncurses-bin` package
  prerequisite; some minimal containers lack it.

## Code-gap recommendations

ENRICH chapters need one inline code block each:

| Chapter | Required example |
|---------|------------------|
| §18.3 | Six-line `~/.inputrc` fragment with `$if mode=emacs` |
| §18.8 | Three-line `complete -F` skeleton |
| §18.10 | Tiny `_funcname() { _init_completion \|\| return; ...; }` demo |
| §18.15 | One coloured PS1 with `\[\e[…m\]` wraps |
| §18.16 | `[[ -t 1 ]] && (( $(tput colors) >= 8 ))` guard |

Total estimated code-block delta for Part XVIII: ~5 small blocks. Lowest
expansion burden in the shard.

#fin
