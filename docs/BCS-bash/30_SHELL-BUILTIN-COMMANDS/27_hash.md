<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### hash
hash [-lr] [-p filename] [-dt] [name]

Each time hash is invoked, the full pathname of the command name is determined by searching the directories in $PATH and remembered. Any previously-remembered pathname is discarded.

-p  Use filename as the full filename of the command; no path search is performed.

-r  Forget all remembered locations.

-d  Forget the remembered location of each name.

-t  Print the full pathname to which each name corresponds. If multiple name arguments are supplied with -t, the name is printed before the hashed full pathname.

-l  Display output in a format that may be reused as input.

If no arguments are given, or if only -l is supplied, information about remembered commands is printed. Returns true unless a name is not found or an invalid option is supplied.
