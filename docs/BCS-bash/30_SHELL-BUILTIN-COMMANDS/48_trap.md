<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### trap

trap [-lp] [[arg] sigspec ...]

The command arg is read and executed when the shell receives the signal(s) sigspec.

If arg is absent (and there is a single sigspec) or -, each specified signal is reset to its original disposition (the value it had upon entrance to the shell). If arg is the null string, the signal specified by each sigspec is ignored by the shell and by the commands it invokes.

If arg is not present and -p has been supplied, the trap commands associated with each sigspec are displayed. If no arguments are supplied or if only -p is given, trap prints the list of commands associated with each signal. The -l option prints a list of signal names and their corresponding numbers.

Each sigspec is either a signal name defined in signal.h or a signal number. Signal names are case insensitive and the SIG prefix is optional.

If a sigspec is EXIT (0), arg is executed on exit from the shell.

If a sigspec is DEBUG, arg is executed before every simple command, for command, case command, select command, every arithmetic for command, and before the first command executes in a shell function. The extdebug shell option affects DEBUG trap behavior.

If a sigspec is RETURN, arg is executed each time a shell function or a script executed with . or source finishes executing.

If a sigspec is ERR, arg is executed whenever a pipeline (which may consist of a single simple command), a list, or a compound command returns a non-zero exit status, subject to these conditions: the ERR trap does not execute if the failed command is part of the command list immediately following while or until, part of the test in an if statement, part of a command executed in a && or || list except the command following the final && or ||, any command in a pipeline but the last, or if the command's return value is being inverted with !. These are the same conditions obeyed by the errexit (-e) option.

Signals ignored upon entry to the shell cannot be trapped or reset. Trapped signals that are not being ignored are reset to their original values in a subshell or subshell environment when one is created.

Returns false if any sigspec is invalid; otherwise returns true.
