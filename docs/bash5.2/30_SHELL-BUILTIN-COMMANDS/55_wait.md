### wait
wait [-fn] [-p varname] [id ...]
 Wait for each specified child process and return its termination status.  Each id may be a process ID
 or a job specification; if a job spec is given, all processes in that job's pipeline are waited for.
 If id is not given, wait waits for all running background jobs and the last-executed process
 substitution, if its process id is the same as $!, and the return status is zero. If the -n option is
 supplied, wait waits for a single job from the list of ids or, if no ids are supplied, any job, to
 complete and returns its exit status.  If none of the supplied arguments is a child of the shell, or if
 no arguments are supplied and the shell has no unwaited-for children, the exit status is 127.  If the
 -p option is supplied, the process or job identifier of the job for which the exit status is returned
 is assigned to the variable varname named by the option argument. The variable will be unset
 initially, before any assignment. This is useful only when the -n option is supplied.  Supplying the
 -f option, when job control is enabled, forces wait to wait for id to terminate before returning its
 status, instead of returning when it changes status.  If id specifies a non-existent process or job,
 the return status is 127. If wait is interrupted by a signal, the return status will be greater than
 128, as described under SIGNALS above.  Otherwise, the return status is the exit status of the last
 process or job waited for.

