## REDIRECTION

Before a command is executed, its input and output may be redirected using a special notation interpreted by
the shell.  Redirection allows commands' file handles to be duplicated, opened, closed, made to refer to
different files, and can change the files the command reads from and writes to.  Redirection may also be used
to modify file handles in the current shell execution environment.  The following redirection operators may
precede or appear anywhere within a simple command or may follow a command.  Redirections are processed in the
order they appear, from left to right.

Each redirection that may be preceded by a file descriptor number may instead be preceded by a word of the
form {varname}.  In this case, for each redirection operator except >&- and <&-, the shell will allocate a
file descriptor greater than or equal to 10 and assign it to varname.  If >&- or <&- is preceded by {varname},
the value of varname defines the file descriptor to close.  If {varname} is supplied, the redirection persists
beyond the scope of the command, allowing the shell programmer to manage the file descriptor's lifetime
manually.  The varredir_close shell option manages this behavior.

In the following descriptions, if the file descriptor number is omitted, and the first character of the
redirection operator is <, the redirection refers to the standard input (file descriptor 0).  If the first
character of the redirection operator is >, the redirection refers to the standard output (file descriptor 1).

The word following the redirection operator in the following descriptions, unless otherwise noted, is
subjected to brace expansion, tilde expansion, parameter and variable expansion, command substitution,
arithmetic expansion, quote removal, pathname expansion, and word splitting.  If it expands to more than one
word, bash reports an error.

Note that the order of redirections is significant.  For example, the command

 ls > dirlist 2>&1

directs both standard output and standard error to the file dirlist, while the command

 ls 2>&1 > dirlist

directs only the standard output to file dirlist, because the standard error was duplicated from the standard
output before the standard output was redirected to dirlist.

Bash handles several filenames specially when they are used in redirections, as described in the following
table.  If the operating system on which bash is running provides these special files, bash will use them;
otherwise it will emulate them internally with the behavior described below.

 /dev/fd/fd
  If fd is a valid integer, file descriptor fd is duplicated.
 /dev/stdin
  File descriptor 0 is duplicated.
 /dev/stdout
  File descriptor 1 is duplicated.
 /dev/stderr
  File descriptor 2 is duplicated.
 /dev/tcp/host/port
  If host is a valid hostname or Internet address, and port is an integer port number or service
  name, bash attempts to open the corresponding TCP socket.
 /dev/udp/host/port
  If host is a valid hostname or Internet address, and port is an integer port number or service
  name, bash attempts to open the corresponding UDP socket.

A failure to open or create a file causes the redirection to fail.

Redirections using file descriptors greater than 9 should be used with care, as they may conflict with file
descriptors the shell uses internally.

Note that the exec builtin command can make redirections take effect in the current shell.

---
- [Redirecting Input](01_Redirecting-Input.md)
- [Redirecting Output](02_Redirecting-Output.md)
- [Appending Redirected Output](03_Appending-Redirected-Output.md)
- [Redirecting Standard Output and Standard Error](04_Redirecting-Standard-Output-and-Standard-Error.md)
- [Appending Standard Output and Standard Error](05_Appending-Standard-Output-and-Standard-Error.md)
- [Here Documents](06_Here-Documents.md)
- [Here Strings](07_Here-Strings.md)
- [Duplicating File Descriptors](08_Duplicating-File-Descriptors.md)
- [Moving File Descriptors](09_Moving-File-Descriptors.md)
- [Opening File Descriptors for Reading and Writing](10_Opening-File-Descriptors-for-Reading-and-Writing.md)
