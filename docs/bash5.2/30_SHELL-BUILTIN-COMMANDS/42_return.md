### return
return [n]
 Causes a function to stop executing and return the value specified by n to its caller.  If n is
 omitted, the return status is that of the last command executed in the function body.  If return is
 executed by a trap handler, the last command used to determine the status is the last command executed
 before the trap handler.  If return is executed during a DEBUG trap, the last command used to determine
 the status is the last command executed by the trap handler before return was invoked.  If return is
 used outside a function, but during execution of a script by the .  (source) command, it causes the
 shell to stop executing that script and return either n or the exit status of the last command executed
 within the script as the exit status of the script.  If n is supplied, the return value is its least
 significant 8 bits.  The return status is non-zero if return is supplied a non-numeric argument, or is
 used outside a function and not during execution of a script by . or source.  Any command associated
 with the RETURN trap is executed before execution resumes after the function or script.

