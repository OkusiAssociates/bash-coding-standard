<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### help
help [-dms] [pattern]

Display information about builtin commands. If pattern is specified, help gives detailed help on all commands matching pattern; otherwise help for all builtins and shell control structures is printed.

-d  Display a short description of each pattern.

-m  Display the description of each pattern in a manpage-like format.

-s  Display only a short usage synopsis for each pattern.

Returns 0 unless no command matches pattern.
