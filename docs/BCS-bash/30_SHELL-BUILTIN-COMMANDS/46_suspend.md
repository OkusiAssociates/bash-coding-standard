<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### suspend
suspend [-f]

Suspend execution of this shell until it receives a SIGCONT signal. A login shell or a shell without job control enabled cannot be suspended; the -f option overrides this and forces the suspension.

Returns 0 unless the shell is a login shell or job control is not enabled and -f is not supplied.
