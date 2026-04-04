### popd
popd [-n] [+n] [-n]

Remove entries from the directory stack. The elements are numbered from 0 starting at the first directory listed by dirs. With no arguments, popd removes the top directory from the stack and changes to the new top directory.

-n  Suppress the normal change of directory when removing directories from the stack, so that only the stack is manipulated.

+n  Remove the nth entry counting from the left of the list shown by dirs, starting with zero. For example: popd +0 removes the first directory, popd +1 the second.

-n  Remove the nth entry counting from the right of the list shown by dirs, starting with zero. For example: popd -0 removes the last directory, popd -1 the next to last.

If the top element of the directory stack is modified and the -n option was not supplied, popd uses cd to change to the directory at the top of the stack. If the cd fails, popd returns a non-zero value.

Otherwise, popd returns false if an invalid option is encountered, the directory stack is empty, or a non-existent directory stack entry is specified.

If the popd command is successful, bash runs dirs to show the final contents of the directory stack, and the return status is 0.
