## RESTRICTED SHELL

If bash is started with the name rbash, or the -r option is supplied at invocation, the shell becomes restricted. A restricted shell sets up an environment more controlled than the standard shell. It behaves identically to bash with the exception that the following are disallowed or not performed:

- changing directories with cd

- setting or unsetting the values of SHELL, PATH, HISTFILE, ENV, or BASH_ENV

- specifying command names containing /

- specifying a filename containing a / as an argument to the . builtin command

- specifying a filename containing a slash as an argument to the history builtin

- specifying a filename containing a slash as an argument to the -p option to the hash builtin

- importing function definitions from the shell environment at startup

- parsing the value of SHELLOPTS from the shell environment at startup

- redirecting output using the >, >|, <>, >&, &>, and >> redirection operators

- using the exec builtin to replace the shell with another command

- adding or deleting builtin commands with the -f and -d options to the enable builtin

- using the enable builtin to enable disabled shell builtins

- specifying the -p option to the command builtin

- turning off restricted mode with set +r or shopt -u restricted_shell

These restrictions are enforced after any startup files are read.

When a command that is found to be a shell script is executed (see COMMAND EXECUTION), rbash turns off any restrictions in the shell spawned to execute the script.

