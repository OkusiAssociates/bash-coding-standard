<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### jobs
jobs [-lnprs] [jobspec ...]
jobs -x command [args ...]

The first form lists the active jobs.

-l  List process IDs in addition to the normal information.

-n  Display information only about jobs that have changed status since the user was last notified.

-p  List only the process ID of the job's process group leader.

-r  Display only running jobs.

-s  Display only stopped jobs.

If jobspec is given, output is restricted to information about that job. Returns 0 unless an invalid option or invalid jobspec is supplied.

If -x is supplied, jobs replaces any jobspec found in command or args with the corresponding process group ID, and executes command passing it args, returning its exit status.
