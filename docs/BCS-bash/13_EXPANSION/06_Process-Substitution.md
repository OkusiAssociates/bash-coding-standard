<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Process Substitution

Process substitution allows referring to a process's input or output using a filename. It takes the form <(list) or >(list). The process list runs asynchronously, and its input or output appears as a filename passed as an argument to the current command.

If the >(list) form is used, writing to the file provides input for list. If the <(list) form is used, reading the file obtains the output of list.

Process substitution is supported on systems that support named pipes (FIFOs) or the /dev/fd method of naming open files.

When available, process substitution is performed simultaneously with parameter and variable expansion, command substitution, and arithmetic expansion.
