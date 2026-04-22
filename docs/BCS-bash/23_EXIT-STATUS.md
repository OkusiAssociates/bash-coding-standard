<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
## EXIT STATUS

The exit status of an executed command is the value returned by the waitpid system call or equivalent function. Exit statuses fall between 0 and 255, though the shell may use values above 125 specially. Exit statuses from shell builtins and compound commands are also limited to this range. Under certain circumstances, the shell uses special values to indicate specific failure modes.

A command which exits with a zero exit status has succeeded. A non-zero exit status indicates failure. When a command terminates on a fatal signal N, bash uses the value of 128+N as the exit status.

If a command is not found, the child process created to execute it returns a status of 127. If a command is found but is not executable, the return status is 126.

If a command fails because of an error during expansion or redirection, the exit status is greater than zero.

Shell builtins return a status of 0 (true) if successful, and non-zero (false) if an error occurs while they execute. All builtins return an exit status of 2 to indicate incorrect usage, generally invalid options or missing arguments.

The exit status of the last command is available in the special parameter $?.

Bash itself returns the exit status of the last command executed, unless a syntax error occurs, in which case it exits with a non-zero value. See also the exit builtin.

