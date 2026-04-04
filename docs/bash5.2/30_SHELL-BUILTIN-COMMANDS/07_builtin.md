### builtin
builtin shell-builtin [arguments]
 Execute the specified shell builtin, passing it arguments, and return its exit status.  This is useful
 when defining a function whose name is the same as a shell builtin, retaining the functionality of the
 builtin within the function.  The cd builtin is commonly redefined this way.  The return status is
 false if shell-builtin is not a shell builtin command.

