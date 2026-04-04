### Pipelines

A pipeline is a sequence of one or more commands separated by one of the control operators | or |&.  The
format for a pipeline is:

 [time [-p]] [ ! ] command1 [ [|⎪|&] command2 ... ]

The standard output of command1 is connected via a pipe to the standard input of command2.  This connection is
performed before any redirections specified by the command1(see REDIRECTION below).  If |& is used, command1's
standard error, in addition to its standard output, is connected to command2's standard input through the
pipe; it is shorthand for 2>&1 |.  This implicit redirection of the standard error to the standard output is
performed after any redirections specified by command1.

The return status of a pipeline is the exit status of the last command, unless the pipefail option is enabled.
If pipefail is enabled, the pipeline's return status is the value of the last (rightmost) command to exit with
a non-zero status, or zero if all commands exit successfully.  If the reserved word !  precedes a pipeline,
the exit status of that pipeline is the logical negation of the exit status as described above.  The shell
waits for all commands in the pipeline to terminate before returning a value.

If the time reserved word precedes a pipeline, the elapsed as well as user and system time consumed by its
execution are reported when the pipeline terminates.  The -p option changes the output format to that
specified by POSIX.  When the shell is in posix mode, it does not recognize time as a reserved word if the
next token begins with a `-'.  The TIMEFORMAT variable may be set to a format string that specifies how the
timing information should be displayed; see the description of TIMEFORMAT under Shell Variables below.

When the shell is in posix mode, time may be followed by a newline.  In this case, the shell displays the
total user and system time consumed by the shell and its children.  The TIMEFORMAT variable may be used to
specify the format of the time information.

Each command in a multi-command pipeline, where pipes are created, is executed in a subshell, which is a
separate process.  See COMMAND EXECUTION ENVIRONMENT for a description of subshells and a subshell
environment.  If the lastpipe option is enabled using the shopt builtin (see the description of shopt below),
the last element of a pipeline may be run by the shell process when job control is not active.

