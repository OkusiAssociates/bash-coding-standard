<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### mapfile
mapfile [-d delim] [-n count] [-O origin] [-s count] [-t] [-u fd] [-C callback] [-c quantum] [array]
readarray [-d delim] [-n count] [-O origin] [-s count] [-t] [-u fd] [-C callback] [-c quantum] [array]

Read lines from standard input into the indexed array variable array, or from file descriptor fd if -u is supplied. The default array is MAPFILE.

-d  Use the first character of delim to terminate each input line, rather than newline. If delim is the empty string, mapfile terminates a line when it reads a NUL character.

-n  Copy at most count lines. If count is 0, all lines are copied.

-O  Begin assigning to array at index origin. The default index is 0.

-s  Discard the first count lines read.

-t  Remove a trailing delim (default newline) from each line read.

-u  Read lines from file descriptor fd instead of standard input.

-C  Evaluate callback each time quantum lines are read. The -c option specifies quantum.

-c  Specify the number of lines read between each call to callback.

If -C is specified without -c, the default quantum is 5000. When callback is evaluated, it is supplied the index of the next array element to be assigned and the line to be assigned to that element as additional arguments. callback is evaluated after the line is read but before the array element is assigned.

If not supplied with an explicit origin, mapfile clears array before assigning to it.

Returns successfully unless an invalid option or option argument is supplied, array is invalid or unassignable, or array is not an indexed array.
