### pushd
pushd [-n] [+n] [-n]
pushd [-n] [dir]
 Adds a directory to the top of the directory stack, or rotates the stack, making the new top of the
 stack the current working directory.  With no arguments, pushd exchanges the top two elements of the
 directory stack.  Arguments, if supplied, have the following meanings:
 -n Suppresses the normal change of directory when rotating or adding directories to the stack, so
  that only the stack is manipulated.
 +n Rotates the stack so that the nth directory (counting from the left of the list shown by dirs,
  starting with zero) is at the top.
 -n Rotates the stack so that the nth directory (counting from the right of the list shown by dirs,
  starting with zero) is at the top.
 dir  Adds dir to the directory stack at the top

 After the stack has been modified, if the -n option was not supplied, pushd uses the cd builtin to
 change to the directory at the top of the stack.  If the cd fails, pushd returns a non-zero value.

 Otherwise, if no arguments are supplied, pushd returns 0 unless the directory stack is empty.  When
 rotating the directory stack, pushd returns 0 unless the directory stack is empty or a non-existent
 directory stack element is specified.

 If the pushd command is successful, bash runs dirs to show the final contents of the directory stack.

