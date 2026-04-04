### Duplicating File Descriptors

The redirection operator

 [n]<&word

is used to duplicate input file descriptors.  If word expands to one or more digits, the file descriptor
denoted by n is made to be a copy of that file descriptor.  If the digits in word do not specify a file
descriptor open for input, a redirection error occurs.  If word evaluates to -, file descriptor n is closed.
If n is not specified, the standard input (file descriptor 0) is used.

The operator

 [n]>&word

is used similarly to duplicate output file descriptors.  If n is not specified, the standard output (file
descriptor 1) is used.  If the digits in word do not specify a file descriptor open for output, a redirection
error occurs.  If word evaluates to -, file descriptor n is closed.  As a special case, if n is omitted, and
word does not expand to one or more digits or -, the standard output and standard error are redirected as
described previously.

