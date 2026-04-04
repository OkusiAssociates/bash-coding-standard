### enable
enable [-a] [-dnp] [-f filename] [name ...]

Enable and disable builtin shell commands. Disabling a builtin allows a disk command with the same name to be executed without specifying a full pathname, even though the shell normally searches for builtins before disk commands. If -n is used, each name is disabled; otherwise, names are enabled. For example, to use the echo binary found via PATH instead of the shell builtin version, run enable -n echo.

The -f option loads a new builtin command name from the shared object filename, on systems that support dynamic loading. Bash uses BASH_LOADABLES_PATH as a colon-separated list of directories to search for filename. The default is system-dependent. The -d option deletes a builtin previously loaded with -f.

If no name arguments are given, or if the -p option is supplied, a list of shell builtins is printed. With no other option arguments, the list consists of all enabled shell builtins. If -n is supplied, only disabled builtins are printed. If -a is supplied, the list includes all builtins, with an indication of whether each is enabled.

If no options are supplied and a name is not a shell builtin, enable attempts to load name from a shared object named name, as if the command were enable -f name name.

Returns 0 unless a name is not a shell builtin or there is an error loading a new builtin from a shared object.
