<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Redirecting Output

Redirection of output causes the file whose name results from the expansion of word to be opened for writing on file descriptor n, or standard output (file descriptor 1) if n is not specified. If the file does not exist it is created; if it does exist it is truncated to zero size.

The general format for redirecting output is:

 [n]>word

If the redirection operator is > and the noclobber option to set has been enabled, the redirection fails if the file whose name results from the expansion of word exists and is a regular file. If the redirection operator is >|, or the redirection operator is > and the noclobber option is not enabled, the redirection is attempted even if the file named by word exists.
