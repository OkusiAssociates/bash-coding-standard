### Appending Standard Output and Standard Error

This construct allows both the standard output (file descriptor 1) and the standard error output (file
descriptor 2) to be appended to the file whose name is the expansion of word.

The format for appending standard output and standard error is:

 &>>word

This is semantically equivalent to

 >>word 2>&1

(see Duplicating File Descriptors below).

