### Lists

A list is a sequence of one or more pipelines separated by one of the operators ;, &, &&, or ||, and
optionally terminated by one of ;, &, or <newline>.

Of these list operators, && and || have equal precedence, followed by ; and &, which have equal precedence.

A sequence of one or more newlines may appear in a list instead of a semicolon to delimit commands.

If a command is terminated by the control operator &, the shell executes the command in the background in a
subshell.  The shell does not wait for the command to finish, and the return status is 0.  These are referred
to as asynchronous commands.  Commands separated by a ; are executed sequentially; the shell waits for each
command to terminate in turn.  The return status is the exit status of the last command executed.

AND and OR lists are sequences of one or more pipelines separated by the && and || control operators,
respectively.  AND and OR lists are executed with left associativity.  An AND list has the form

 command1 && command2

command2 is executed if, and only if, command1 returns an exit status of zero (success).

An OR list has the form

 command1 || command2

command2 is executed if, and only if, command1 returns a non-zero exit status.  The return status of AND and
OR lists is the exit status of the last command executed in the list.

