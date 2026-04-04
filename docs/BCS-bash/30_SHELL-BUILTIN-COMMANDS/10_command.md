### command
command [-pVv] command [arg ...]

Run command with args, suppressing the normal shell function lookup. Only builtin commands or commands found in PATH are executed.

-p  Search for command using a default value for PATH that is guaranteed to find all standard utilities.

-v  Display a single word indicating the command or filename used to invoke command.

-V  Produce a more verbose description of command.

If -V or -v is supplied, the exit status is 0 if command was found, and 1 if not. If neither option is supplied and an error occurred or command cannot be found, the exit status is 127. Otherwise, the exit status of the command builtin is the exit status of command.
