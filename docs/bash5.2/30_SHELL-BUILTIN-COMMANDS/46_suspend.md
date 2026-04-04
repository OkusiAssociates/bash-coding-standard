### suspend
suspend [-f]
 Suspend the execution of this shell until it receives a SIGCONT signal.  A login shell, or a shell
 without job control enabled, cannot be suspended; the -f option can be used to override this and force
 the suspension.  The return status is 0 unless the shell is a login shell or job control is not enabled
 and -f is not supplied.

