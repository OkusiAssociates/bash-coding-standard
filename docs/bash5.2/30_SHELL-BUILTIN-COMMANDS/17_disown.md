### disown
disown [-ar] [-h] [jobspec ... | pid ... ]
 Without options, remove each jobspec from the table of active jobs.  If jobspec is not present, and
 neither the -a nor the -r option is supplied, the current job is used.  If the -h option is given, each
 jobspec is not removed from the table, but is marked so that SIGHUP is not sent to the job if the shell
 receives a SIGHUP.  If no jobspec is supplied, the -a option means to remove or mark all jobs; the -r
 option without a jobspec argument restricts operation to running jobs.  The return value is 0 unless a
 jobspec does not specify a valid job.

