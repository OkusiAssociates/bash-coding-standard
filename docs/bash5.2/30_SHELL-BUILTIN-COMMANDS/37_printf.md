### printf
printf [-v var] format [arguments]
 Write the formatted arguments to the standard output under the control of the format.  The -v option
 causes the output to be assigned to the variable var rather than being printed to the standard output.

 The format is a character string which contains three types of objects: plain characters, which are
 simply copied to standard output, character escape sequences, which are converted and copied to the
 standard output, and format specifications, each of which causes printing of the next successive
 argument. In addition to the standard printf(1) format specifications, printf interprets the following
 extensions:
 %b causes printf to expand backslash escape sequences in the corresponding argument in the same way
  as echo -e.
 %q causes printf to output the corresponding argument in a format that can be reused as shell
  input.
 %Q like %q, but applies any supplied precision to the argument before quoting it.
 %(datefmt)T
  causes printf to output the date-time string resulting from using datefmt as a format string for
  strftime(3).  The corresponding argument is an integer representing the number of seconds since
  the epoch. Two special argument values may be used: -1 represents the current time, and -2
  represents the time the shell was invoked. If no argument is specified, conversion behaves as
  if -1 had been given.  This is an exception to the usual printf behavior.

 The %b, %q, and %T directives all use the field width and precision arguments from the format
 specification and write that many bytes from (or use that wide a field for) the expanded argument,
 which usually contains more characters than the original.

 Arguments to non-string format specifiers are treated as C constants, except that a leading plus or
 minus sign is allowed, and if the leading character is a single or double quote, the value is the ASCII
 value of the following character.

 The format is reused as necessary to consume all of the arguments.  If the format requires more
 arguments than are supplied, the extra format specifications behave as if a zero value or null string,
 as appropriate, had been supplied.  The return value is zero on success, non-zero on failure.

