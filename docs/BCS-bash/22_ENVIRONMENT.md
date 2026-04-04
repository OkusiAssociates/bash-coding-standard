## ENVIRONMENT

When a program is invoked it is given an array of strings called the environment. This is a list of name-value pairs, of the form name=value.

The shell provides several ways to manipulate the environment. On invocation, the shell scans its own environment and creates a parameter for each name found, automatically marking it for export to child processes. Executed commands inherit the environment. The export and declare -x commands allow parameters and functions to be added to and deleted from the environment. If the value of a parameter in the environment is modified, the new value becomes part of the environment, replacing the old. The environment inherited by any executed command consists of the shell's initial environment, whose values may be modified in the shell, less any pairs removed by unset, plus any additions via export and declare -x.

The environment for any simple command or function may be augmented temporarily by prefixing it with parameter assignments, as described in PARAMETERS. These assignment statements affect only the environment seen by that command.

If the -k option is set (see the set builtin), all parameter assignments are placed in the environment for a command, not just those that precede the command name.

When bash invokes an external command, the variable _ is set to the full filename of the command and passed to that command in its environment.

