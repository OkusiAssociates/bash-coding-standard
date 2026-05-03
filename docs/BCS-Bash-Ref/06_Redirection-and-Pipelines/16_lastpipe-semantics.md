<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 6.16 `lastpipe` semantics

`shopt -s lastpipe` runs the *last* command of a pipeline in the
current shell rather than a subshell, so variables it assigns remain
visible after the pipeline ends. It cures the long-standing
`cmd | while read … done` outer-scope problem without rewriting to a
process-substitution form. The catch is that it is effective only when
job control is off — non-interactive shells get it for free, but
interactive shells must `set +m` first.

### The default-subshell problem

By default every component of a pipeline runs in its own subshell,
including the last. Variable assignments inside the last component
mutate the subshell's environment and disappear when it exits:

```bash
# scenario: default behaviour — the while loop's count is lost
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob

declare -i count=0

# WRONG — without lastpipe the while runs in a subshell
seq 1 5 | while read -r _; do
  count+=1
done
echo "without lastpipe: count=$count"
# ⇒ without lastpipe: count=0   — assignments inside while were discarded
```

The fix has historically been process substitution (§6.10):

```bash
# scenario: process substitution keeps the consumer in the parent shell
declare -i count=0
while read -r _; do
  count+=1
done < <(seq 1 5)
echo "with proc-sub:    count=$count"
# ⇒ with proc-sub:    count=5
```

`lastpipe` offers a less-invasive alternative — keep the pipeline form
but enable parent-shell execution for the rightmost component.

### Enabling `lastpipe`

`lastpipe` requires Bash 4.2+ and is effective only when monitor mode
(job control) is off:

```bash
# scenario: lastpipe on, with the job-control caveat made explicit
#!/usr/bin/env bash
set -euo pipefail; shopt -s inherit_errexit shift_verbose extglob nullglob
shopt -s lastpipe

# Job control is off by default in non-interactive scripts, so the
# `set +m` line is documentation-only here. In interactive shells it is
# REQUIRED before lastpipe takes effect.
set +m

declare -i count=0
seq 1 5 | while read -r _; do
  count+=1
done
echo "with lastpipe:    count=$count"
# ⇒ with lastpipe:    count=5
```

In an interactive shell *without* `set +m`, the same pipeline reverts
to subshell semantics silently — `count` stays 0 and there is no
warning. The `set +m` qualifier is therefore load-bearing for any
example a reader might paste into an interactive REPL.

### What `lastpipe` does and does not change

- ✓ Last component runs in the parent; assignments persist.
- ✓ `PIPESTATUS[]` still holds every component's status.
- ✓ `pipefail` still applies; the strict-mode trio is unaffected.
- ✗ The first *N-1* components still run in subshells. Only the tail
  is special.
- ✗ `set -e` exemption rules are unchanged — a `cmd | while …` whose
  body has a non-zero command will exit if errexit is enabled and the
  body is not in an exempt context (§13.3).

### Pitfalls

- **Interactive paste-test silently fails.** The example above is
  correct in a script but appears broken when pasted into an
  interactive shell unless the reader has previously run `set +m`. Mark
  any `lastpipe` demonstration as a script, not a REPL fragment.
- **Errexit interaction.** `lastpipe` does not give the consumer body
  any new exemption — if the body runs `[[ -n $x ]]` and `$x` is empty,
  errexit fires inside the loop and aborts the script.
- **Composition with `read`.** The classic `while read -r` consumer is
  the canonical use case; combine with `IFS=` and `-r` per BCS0905 to
  preserve whitespace and backslashes.
- **Not a substitute for process substitution in all cases.** When the
  consumer must read from *more than one* producer, only process
  substitution composes; `lastpipe` is single-tail-only.

### Practical guidance

For new scripts, prefer `< <(producer)` process substitution — it
composes, it works in interactive shells without ceremony, and it makes
the parent-shell scope visually obvious. Reach for `lastpipe` when
modifying existing code that uses `producer | while read` form and
process-substitution refactoring is not warranted.

**See also**: §6.10 (process substitution as redirection), §6.13
(pipelines and subshell semantics), §6.15 (`pipefail`), §13.3 (errexit
exemption matrix), §9.5 (BCS0905 input redirection patterns), §9.6
(BCS0906 find subshell pitfalls), BCS0101.

#fin
