<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### ulimit

ulimit [-HS] -a
ulimit [-HS] [-bcdefiklmnpqrstuvxPRT [limit]]

Controls the resources available to the shell and processes it starts, on systems that support resource limits.

-H sets the hard limit for a resource. A hard limit cannot be increased by a non-root user once set.

-S sets the soft limit. A soft limit may be increased up to the hard limit value.

If neither -H nor -S is given, both limits are set. The value of limit can be a number in the unit specified for the resource, or one of the special values hard, soft, or unlimited (current hard limit, current soft limit, and no limit, respectively). If limit is omitted, the current soft limit is printed, unless -H is given. When multiple resources are specified, the limit name and unit are printed before each value.

Resource options:

-a  Report all current limits; no limits are set

-b  Maximum socket buffer size

-c  Maximum size of core files created

-d  Maximum size of a process's data segment

-e  Maximum scheduling priority (nice)

-f  Maximum size of files written by the shell and its children

-i  Maximum number of pending signals

-k  Maximum number of kqueues that may be allocated

-l  Maximum size that may be locked into memory

-m  Maximum resident set size (many systems do not honor this limit)

-n  Maximum number of open file descriptors (most systems do not allow this to be set)

-p  Pipe size in 512-byte blocks (may not be set)

-q  Maximum number of bytes in POSIX message queues

-r  Maximum real-time scheduling priority

-s  Maximum stack size

-t  Maximum CPU time in seconds

-u  Maximum number of processes available to a single user

-v  Maximum amount of virtual memory available to the shell and, on some systems, its children

-x  Maximum number of file locks

-P  Maximum number of pseudoterminals

-R  Maximum time a real-time process can run before blocking, in microseconds

-T  Maximum number of threads

If limit is given without -a, it becomes the new value for the specified resource. If no option is given, -f is assumed. Values are in 1024-byte increments, except for -t (seconds), -R (microseconds), -p (512-byte blocks), and -P, -T, -b, -k, -n, -u (unscaled values).

Returns 0 unless an invalid option or argument is supplied, or an error occurs while setting a new limit.
