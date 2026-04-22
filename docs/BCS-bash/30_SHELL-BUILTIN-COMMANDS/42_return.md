<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### return

return [n]

Causes a function to stop executing and return the value n to its caller. If n is omitted, the return status is that of the last command executed in the function body.

If return is executed by a trap handler, the last command used to determine the status is the last command executed before the trap handler. If executed during a DEBUG trap, the last command used is the last command executed by the trap handler before return was invoked.

If return is used outside a function but during execution of a script via . (source), it causes the shell to stop executing that script and return either n or the exit status of the last command executed within the script.

If n is supplied, only its least significant 8 bits are used. The return status is non-zero if a non-numeric argument is given, or if return is used outside a function and not during execution of a script by . or source. Any command associated with the RETURN trap executes before execution resumes after the function or script.
