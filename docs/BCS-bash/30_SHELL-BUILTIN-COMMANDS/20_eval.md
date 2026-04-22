<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### eval
eval [arg ...]

The args are concatenated together into a single command, which is then read and executed by the shell. The exit status of that command is returned as the value of eval. If there are no args, or only null arguments, eval returns 0.
