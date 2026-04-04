### unset
unset [-fv] [-n] [name ...]
 For each name, remove the corresponding variable or function.  If the -v option is given, each name
 refers to a shell variable, and that variable is removed. Read-only variables may not be unset.  If -f
 is specified, each name refers to a shell function, and the function definition is removed.  If the -n
 option is supplied, and name is a variable with the nameref attribute, name will be unset rather than
 the variable it references.  -n has no effect if the -f option is supplied.  If no options are
 supplied, each name refers to a variable; if there is no variable by that name, a function with that
 name, if any, is unset.  Each unset variable or function is removed from the environment passed to
 subsequent commands.  If any of BASH_ALIASES, BASH_ARGV0, BASH_CMDS, BASH_COMMAND, BASH_SUBSHELL,
 BASHPID, COMP_WORDBREAKS, DIRSTACK, EPOCHREALTIME, EPOCHSECONDS, FUNCNAME, GROUPS, HISTCMD, LINENO,
 RANDOM, SECONDS, or SRANDOM are unset, they lose their special properties, even if they are
 subsequently reset.  The exit status is true unless a name is readonly or may not be unset.

