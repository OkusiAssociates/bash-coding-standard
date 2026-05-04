<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 11.4 `BASH_SUBSHELL` depth tracking

Bash maintains a counter of subshell depth in the read-only variable
`BASH_SUBSHELL`. It is incremented every time the shell forks a subshell
(`( … )`, `$(…)`, the left-hand side of a pipeline, a backgrounded
command, etc. — see §11.3) and decremented when that subshell exits.
The top-level script always sees `BASH_SUBSHELL == 0`.

`BASH_SUBSHELL` is **not** the same as `SHLVL`. `SHLVL` counts shell
*invocations* (e.g. `bash` exec'd from inside another `bash`), so it
survives `exec` and is exported to children; `BASH_SUBSHELL` counts
*forks within the current shell* and is not exported.

```bash
# scenario: BASH_SUBSHELL contrast with SHLVL
echo "top: SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL"
( echo "in (..): SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL"
  ( echo "nested:  SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL" ) )
bash -c 'echo "exec:    SHLVL=$SHLVL BASH_SUBSHELL=$BASH_SUBSHELL"'
# ⇒ top: SHLVL=1 BASH_SUBSHELL=0
# ⇒ in (..): SHLVL=1 BASH_SUBSHELL=1
# ⇒ nested:  SHLVL=1 BASH_SUBSHELL=2
# ⇒ exec:    SHLVL=2 BASH_SUBSHELL=0
```

The `exec` line proves the distinction: a fresh `bash` invocation resets
`BASH_SUBSHELL` to 0 but bumps `SHLVL` to 2.

### Library-guard idiom

Code that must run only in the parent shell — e.g. a library that mutates
shell state the caller depends on, or a function that installs an EXIT
trap whose effect should not be duplicated in forks — uses
`BASH_SUBSHELL` to refuse to execute as a child:

```bash
# scenario: refuse to run as a forked child
init_session() {
  if (( BASH_SUBSHELL )); then
    error "init_session must run in the top-level shell, not a subshell"
    return 22
  fi
  trap 'cleanup_session' EXIT
  # … one-time setup that the parent shell needs to see …
}
```

This guard is cheaper than inspecting `$$` versus `$BASHPID` (§11.2) and
correctly identifies *every* subshell context, including command
substitution and pipeline LHS, where `$$` lies.

### Pipeline-component detection

Inside the LHS of a pipeline, `BASH_SUBSHELL` is non-zero, so the guard
above will trip if a library call lands there. With `shopt -s lastpipe`
(non-interactive) the rightmost component runs in the parent and
`BASH_SUBSHELL` remains 0 — see §11.3.

**See also**: §11.2 (`$$` vs `$BASHPID`), §11.3 (subshell origins),
§11.5 (foreground/background), Appendix C (`BASH_SUBSHELL`, `SHLVL`),
BCS0202 (variable scoping), BCS0407 (library patterns).

#fin
