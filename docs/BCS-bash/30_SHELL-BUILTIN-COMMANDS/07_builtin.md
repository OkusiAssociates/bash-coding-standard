<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### builtin
builtin shell-builtin [arguments]

Execute the specified shell builtin, passing it arguments, and return its exit status. This is useful when a function has the same name as a builtin and needs to invoke the original builtin from within the function body. The cd builtin is commonly redefined this way.

Returns false if shell-builtin is not a shell builtin command.
