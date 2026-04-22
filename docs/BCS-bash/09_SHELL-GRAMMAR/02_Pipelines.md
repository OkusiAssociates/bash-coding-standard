<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Pipelines

A pipeline is one or more commands separated by | or |&:

 [time [-p]] [ ! ] command1 [ [|||&] command2 ... ]

The standard output of command1 is connected via a pipe to the standard input of command2. This connection is performed before any redirections specified by command1 (see REDIRECTION). If |& is used, command1's standard error is also connected to command2's standard input through the pipe; it is shorthand for 2>&1 |. This implicit redirection of standard error to standard output is performed after any redirections specified by command1.

The return status of a pipeline is the exit status of the last command, unless the pipefail option is enabled. With pipefail, the return status is the value of the last (rightmost) command to exit with a non-zero status, or zero if all commands exit successfully. If ! precedes a pipeline, the exit status is logically negated. The shell waits for all commands in the pipeline to terminate before returning a value.

If the time reserved word precedes a pipeline, the elapsed, user, and system time consumed by its execution are reported when the pipeline terminates. The -p option changes the output format. The TIMEFORMAT variable controls how timing information is displayed (see Shell Variables).

Each command in a multi-command pipeline is executed in a subshell (a separate process). See COMMAND EXECUTION ENVIRONMENT for a description of subshells. If the lastpipe option is enabled using shopt, the last element of a pipeline may run in the current shell process when job control is not active.
