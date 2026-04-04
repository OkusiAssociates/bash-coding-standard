### umask

umask [-p] [-S] [mode]

Sets the user file-creation mask to mode. If mode begins with a digit, it is interpreted as an octal number; otherwise it is interpreted as a symbolic mode mask similar to that accepted by chmod(1).

If mode is omitted, the current value of the mask is printed.

-S  Print the mask in symbolic form. The default output is an octal number.

-p  When mode is omitted, print the output in a form that may be reused as input.

Returns 0 if the mode was successfully changed or if no mode argument was supplied, and false otherwise.
