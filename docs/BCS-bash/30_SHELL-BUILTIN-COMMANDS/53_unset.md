<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### unset

unset [-fv] [-n] [name ...]

Removes the corresponding variable or function for each name.

-v  Each name refers to a shell variable, and that variable is removed. Read-only variables may not be unset.

-f  Each name refers to a shell function, and the function definition is removed.

-n  If name has the nameref attribute, the name itself is unset rather than the variable it references. Has no effect when combined with -f.

If no options are supplied, each name refers to a variable; if no variable by that name exists, a function with that name is unset instead.

Each unset variable or function is removed from the environment passed to subsequent commands.

If any of BASH_ALIASES, BASH_ARGV0, BASH_CMDS, BASH_COMMAND, BASH_SUBSHELL, BASHPID, COMP_WORDBREAKS, DIRSTACK, EPOCHREALTIME, EPOCHSECONDS, FUNCNAME, GROUPS, HISTCMD, LINENO, RANDOM, SECONDS, or SRANDOM are unset, they lose their special properties, even if subsequently reset.

Returns true unless a name is readonly or may not be unset.
