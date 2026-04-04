### Duplicating File Descriptors

The redirection operator

 [n]<&word

duplicates input file descriptors. If word expands to one or more digits, file descriptor n is made a copy of that file descriptor. If the digits in word do not specify a file descriptor open for input, a redirection error occurs. If word evaluates to -, file descriptor n is closed. If n is not specified, standard input (file descriptor 0) is used.

The operator

 [n]>&word

duplicates output file descriptors similarly. If n is not specified, standard output (file descriptor 1) is used. If the digits in word do not specify a file descriptor open for output, a redirection error occurs. If word evaluates to -, file descriptor n is closed. As a special case, if n is omitted and word does not expand to one or more digits or -, standard output and standard error are redirected as described in Redirecting Standard Output and Standard Error.
