<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### wait

wait [-fn] [-p varname] [id ...]

Waits for each specified child process and returns its termination status. Each id may be a process ID or a job specification; if a job spec is given, all processes in that job's pipeline are waited for.

If id is not given, waits for all running background jobs and the last-executed process substitution (if its process id is the same as $!), and returns zero.

-n  Wait for a single job from the list of ids (or, if no ids are supplied, any job) to complete and return its exit status. If none of the supplied arguments is a child of the shell, or if no arguments are supplied and the shell has no unwaited-for children, the exit status is 127.

-p varname  Assign the process or job identifier of the completed job to varname. The variable is unset initially, before any assignment. Only useful with -n.

-f  When job control is enabled, forces wait to wait for id to terminate before returning its status, instead of returning when it changes status.

If id specifies a non-existent process or job, the return status is 127. If wait is interrupted by a signal, the return status is greater than 128. Otherwise, the return status is the exit status of the last process or job waited for.
