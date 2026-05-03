<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 18.15 Coloured and multi-line prompts

Practical prompt customisation.

- Wrap colour escapes in `\[…\]` for accurate cursor positioning.
- Multi-line: include `\n` in `PS1`; bash handles the wrapping.
- Conditional content: `${VAR:+prefix$VAR}` for git-branch-style additions.
- `PROMPT_COMMAND` — runs before each prompt; useful for state inspection.
- Powerline-style prompts: `starship`, `oh-my-bash`, hand-rolled.

```bash
# scenario: two-line prompt, green user@host, branch suffix
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\w${BRANCH:+ \[\e[33m\](${BRANCH})\[\e[0m\]}\n\$ '
```

The `\[ … \]` markers tell readline that the bytes inside emit no visible
columns; without them, line wrap and cursor recall break after the first
right-edge overflow. Bare `\e[…m` outside `\[…\]` is the most frequent
prompt bug. `${BRANCH:+…}` only emits the parenthesised group when `BRANCH`
is non-empty — populate it from `PROMPT_COMMAND` (e.g., `git symbolic-ref`).

**See also**: §18.13 (prompts), §18.14 (prompt escapes), §18.16 (capability detection).

#fin
