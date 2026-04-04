### exec
exec [-cl] [-a name] [command [arguments]]
 If command is specified, it replaces the shell.  No new process is created.  The arguments become the
 arguments to command.  If the -l option is supplied, the shell places a dash at the beginning of the
 zeroth argument passed to command.  This is what login(1) does.  The -c option causes command to be
 executed with an empty environment.  If -a is supplied, the shell passes name as the zeroth argument to
 the executed command.  If command cannot be executed for some reason, a non-interactive shell exits,
 unless the execfail shell option is enabled.  In that case, it returns failure.  An interactive shell
 returns failure if the file cannot be executed.  A subshell exits unconditionally if exec fails.  If
 command is not specified, any redirections take effect in the current shell, and the return status is
 0.  If there is a redirection error, the return status is 1.

