### Coprocesses

A coprocess is a shell command preceded by the coproc reserved word.  A coprocess is executed asynchronously
in a subshell, as if the command had been terminated with the & control operator, with a two-way pipe
established between the executing shell and the coprocess.

The syntax for a coprocess is:

 coproc [NAME] command [redirections]

This creates a coprocess named NAME.  command may be either a simple command or a compound command (see
above).  NAME is a shell variable name.  If NAME is not supplied, the default name is COPROC.

The recommended form to use for a coprocess is

 coproc NAME { command [redirections]; }

This form is recommended because simple commands result in the coprocess always being named COPROC, and it is
simpler to use and more complete than the other compound commands.

If command is a compound command, NAME is optional. The word following coproc determines whether that word is
interpreted as a variable name: it is interpreted as NAME if it is not a reserved word that introduces a
compound command.  If command is a simple command, NAME is not allowed; this is to avoid confusion between
NAME and the first word of the simple command.

When the coprocess is executed, the shell creates an array variable (see Arrays below) named NAME in the
context of the executing shell.  The standard output of command is connected via a pipe to a file descriptor
in the executing shell, and that file descriptor is assigned to NAME[0]. The standard input of command is
connected via a pipe to a file descriptor in the executing shell, and that file descriptor is assigned to
NAME[1]. This pipe is established before any redirections specified by the command (see REDIRECTION below).
The file descriptors can be utilized as arguments to shell commands and redirections using standard word
expansions.  Other than those created to execute command and process substitutions, the file descriptors are
not available in subshells.

The process ID of the shell spawned to execute the coprocess is available as the value of the variable
NAME_PID.  The wait builtin command may be used to wait for the coprocess to terminate.

Since the coprocess is created as an asynchronous command, the coproc command always returns success.  The
return status of a coprocess is the exit status of command.

