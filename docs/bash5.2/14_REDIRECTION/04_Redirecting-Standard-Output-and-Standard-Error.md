### Redirecting Standard Output and Standard Error

This construct allows both the standard output (file descriptor 1) and the standard error output (file
descriptor 2) to be redirected to the file whose name is the expansion of word.

There are two formats for redirecting standard output and standard error:

 &>word
and
 >&word

Of the two forms, the first is preferred.  This is semantically equivalent to

 >word 2>&1

When using the second form, word may not expand to a number or -.  If it does, other redirection operators
apply (see Duplicating File Descriptors below) for compatibility reasons.

