<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### disown
disown [-ar] [-h] [jobspec ... | pid ...]

Without options, remove each jobspec from the table of active jobs. If jobspec is not present and neither -a nor -r is supplied, the current job is used.

If -h is given, each jobspec is not removed from the table but is marked so that SIGHUP is not sent to the job if the shell receives a SIGHUP.

If no jobspec is supplied, -a removes or marks all jobs; -r restricts operation to running jobs.

Returns 0 unless a jobspec does not specify a valid job.
