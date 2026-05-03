<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 25.1 No-fork command substitution `${ cmd; }`

The headline feature of Bash 5.3. The traditional `$(cmd)` form runs
`cmd` in a subshell — `fork(2)`, then run, then collect stdout. The
new `${ cmd; }` form runs `cmd` *in the current shell* and captures
its stdout as the value of the substitution. No fork, ~1 ms saved per
call on a modern Linux host, and — because there is no subshell —
variable assignments and other side effects persist into the parent.

The syntax requires:

- a **leading space** after `${` (distinguishing it from `${var…}`);
- a **trailing semicolon or newline** before the closing `}`;
- the body is parsed and executed as if it were a `{ … ; }` group.

### A worked side-effect-persistence demo

The clearest illustration is to run the same body under `$(…)` and
`${ …; }` and watch what happens to the parent's variables:

```bash
#!/usr/bin/env bash
# Requires bash 5.3+.
set -euo pipefail
shopt -s inherit_errexit shift_verbose extglob nullglob

if (( BASH_VERSINFO[0] < 5 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] < 3) )); then
  printf 'requires bash 5.3+\n' >&2; exit 18
fi

x=outer

# Traditional $() — runs in a subshell, side effects are discarded.
out1=$(x=inner; echo "$x")
printf 'after $(): out1=%s, x=%s\n' "$out1" "$x"
# ⇒ after $(): out1=inner, x=outer

# New ${ ; } — runs in the current shell, side effects persist.
out2=${ x=inner; echo "$x"; }
printf 'after ${ }: out2=%s, x=%s\n' "$out2" "$x"
# ⇒ after ${ }: out2=inner, x=inner
#fin
```

Both forms produce the same captured value (`inner`); the difference
is in the parent's `x`. Under `$(…)`, the parent never sees the inner
assignment — that is the whole point of subshell isolation. Under
`${ …; }`, the assignment lands in the parent's variable table,
because there is no subshell to isolate it.

### When to use it

The honest answer is: in 99% of scripts, **don't bother**. The 1 ms
saved per call is invisible against any real workload, and the
side-effect-persistence semantics is a footgun: a function that you
mentally model as "captures stdout, has no other effect" can suddenly
mutate the calling scope. `$(…)` is the safer default precisely
because of its isolation.

The exceptions worth the upgrade:

1. **Hot loops.** A polling loop that calls a tiny helper 10 000 times
   per minute is ~10 s of pure fork overhead with `$(…)`; ~0 with
   `${ …; }`. Build, deployment, and CI scripts with thousands of
   trivial substitutions are the canonical wins.
2. **Functions whose entire purpose is to return a value via stdout
   AND set a variable in the caller.** `${ …; }` lets you do both at
   once, which `$(…)` cannot.
3. **Scripts that already commit to bash 5.3+.** If the floor is 5.3,
   reach for the new form; if it is anything older, the
   forward-compatibility cost is not worth the per-call savings.

### Caveats

- **Not portable.** Requires bash 5.3 or later. The form is a *syntax
  error* on bash 5.2 and below — it cannot be feature-detected at
  runtime in the same script.
- **Side-effect persistence is the feature, not a bug.** Code that
  treats `${ …; }` as a drop-in replacement for `$(…)` will produce
  parent-scope mutations the author did not intend.
- **Whitespace is significant.** `${cmd;}` (no leading space) is still
  parameter expansion; `${ cmd;}` requires the space; the trailing
  `;` or newline before `}` is mandatory.

```bash
# wrong — no leading space; bash treats this as ${cmd;}
result=${cmd; echo hi; }
# ⇒ syntax error or attempt to expand a parameter named "cmd; echo hi; "

# right — leading space, trailing semicolon
result=${ cmd; echo hi; }
```

**See also**: §13.4 (command substitution — the `$(…)` form); §24.8
(subshell forking — what `$(…)` is doing under the covers); §25.5
(forward-compatibility considerations); Appendix M (bash version
history) for the 5.3 release notes.

#fin
