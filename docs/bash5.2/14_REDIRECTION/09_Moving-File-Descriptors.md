### Moving File Descriptors

The redirection operator

 [n]<&digit-

moves the file descriptor digit to file descriptor n, or the standard input (file descriptor 0) if n is not
specified.  digit is closed after being duplicated to n.

Similarly, the redirection operator

 [n]>&digit-

moves the file descriptor digit to file descriptor n, or the standard output (file descriptor 1) if n is not
specified.

