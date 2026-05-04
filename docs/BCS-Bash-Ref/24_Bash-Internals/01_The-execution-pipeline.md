<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 24.1 The execution pipeline

The high-level path from input string to syscalls inside the bash
interpreter. Every command bash runs walks through these ten stages,
in order; understanding the order explains why a bug at one stage
cannot be papered over at another.

1. **Tokeniser** — produces tokens from input characters. Reserved
   words (`if`, `for`), operators (`||`, `<<`), and word boundaries are
   recognised here.
2. **Parser** — produces an AST from tokens via the bison grammar in
   `parse.y`. Syntax errors surface here, before any expansion.
3. **Word expansion** — brace, tilde, parameter, arithmetic, command,
   and process substitution, in that left-to-right order.
4. **Word splitting** — applies on unquoted results of step 3, using
   `IFS`. Quoted expansions skip this stage.
5. **Pathname expansion** — globbing (`*`, `?`, `[…]`, `**`) on
   unquoted results.
6. **Quote removal** — strips the quotes that survived steps 3–5.
7. **Redirection setup** — `<`, `>`, `>>`, `<<<`, `<()` connect file
   descriptors before the command runs.
8. **Execution dispatch** — picks one of: builtin, function, alias
   (interactive only), keyword, or external command (fork+exec).
9. **Wait for completion** — synchronous unless backgrounded with `&`.
10. **Trap delivery** — pending signals delivered between commands;
    DEBUG/RETURN/ERR pseudo-traps fire at the appropriate boundary.

### A worked xtrace transcript

`set -x` shows a snapshot of stages 6–7 (after expansion and quote
removal, before dispatch). Reading an xtrace line backwards through the
pipeline anchors each stage to something concrete:

```bash
$ bash -c 'set -x; x=hello; echo "$x" $(date +%Y) /etc/host*'
+ x=hello                        # step 8: builtin assignment
+ date +%Y                       # step 3 (command sub): inner command
+ echo hello 2026 /etc/hostname /etc/hosts
#                ^^^^                 ^step 5: pathname expansion of /etc/host*
#           ^step 3: command-sub result substituted
#      ^step 6: "$x" → hello (quotes removed after expansion)
# ^step 8: echo dispatched as a builtin
```

Every word visible in the `+ echo …` line has already passed through
expansion (3), splitting (4), pathname expansion (5), and quote removal
(6). What you see in xtrace is the input to dispatch — which is why
debugging by `set -x` only shows you problems at stage 8 onward and is
useless for diagnosing brace-expansion bugs at stage 3.

`set -v` is the complement: it prints each line *before* expansion, so
the two together (`set -xv`) bracket the pipeline. The classic
diagnostic for "is this a quoting bug or a dispatch bug?" is to enable
both and watch the same line appear twice — first verbatim from `-v`,
then post-expansion from `-x`.

```text
$ bash -c 'set -xv; for f in *.txt; do echo "$f"; done' 2>&1 | sed 's/^/| /'
| + set -xv
| for f in *.txt; do echo "$f"; done    # -v: pre-expansion
| + for f in a.txt b.txt                # -x: post-expansion (stage 5)
| + echo a.txt
| a.txt
| + echo b.txt
| b.txt
```

### Why the order matters

A subtlety that catches people: word splitting (stage 4) happens *after*
expansion (stage 3). So `arr=(1 2 3); echo $arr[@]` does not iterate the
array — bash expands `$arr` to "1" first, then sees the literal `[@]`.
Quoting rescues nothing; the bug is upstream. The fix is `${arr[@]}` so
the expansion in stage 3 picks up the array.

Another: pathname expansion (stage 5) does *not* happen inside `[[ … ]]`
(it is a keyword, parsed at stage 2 with its own evaluation rules) but
*does* happen inside `[ … ]` (a builtin, evaluated at stage 8 with stage
3–6 word processing applied to its arguments). This is one of the
several reasons `[[ … ]]` is preferred under BCS.

**See also**: §24.2 (the bison grammar — stage 2 details); §13.x (the
expansion family — stages 3–5); BCS0207 (parameter expansion) for the
practical guidance that follows from the pipeline order.

#fin
