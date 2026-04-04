### Opening File Descriptors for Reading and Writing

The redirection operator

 [n]<>word

causes the file whose name is the expansion of word to be opened for both reading and writing on file descriptor n, or file descriptor 0 if n is not specified. If the file does not exist, it is created.
