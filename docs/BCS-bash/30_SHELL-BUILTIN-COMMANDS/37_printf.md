<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### printf
printf [-v var] format [arguments]

Write formatted arguments to standard output under the control of format. The -v option assigns the output to variable var instead of printing it.

The format string contains three types of objects: plain characters, copied directly to standard output; character escape sequences, converted and copied to standard output; and format specifications, each causing printing of the next successive argument. In addition to standard printf(1) format specifications, printf interprets these extensions:

%b  Expands backslash escape sequences in the corresponding argument in the same way as echo -e.

%q  Outputs the corresponding argument in a format that can be reused as shell input.

%Q  Like %q, but applies any supplied precision to the argument before quoting it.

%(datefmt)T  Outputs the date-time string resulting from using datefmt as a format string for strftime(3). The corresponding argument is an integer representing the number of seconds since the epoch. Two special argument values may be used: -1 represents the current time, and -2 represents the time the shell was invoked. If no argument is specified, conversion behaves as if -1 had been given.

The %b, %q, and %T directives all use the field width and precision arguments from the format specification and write that many bytes from (or use that wide a field for) the expanded argument, which usually contains more characters than the original.

Arguments to non-string format specifiers are treated as C constants, except that a leading plus or minus sign is allowed, and if the leading character is a single or double quote, the value is the ASCII value of the following character.

The format is reused as necessary to consume all arguments. If the format requires more arguments than are supplied, the extra format specifications behave as if a zero value or null string had been supplied. Returns zero on success, non-zero on failure.
