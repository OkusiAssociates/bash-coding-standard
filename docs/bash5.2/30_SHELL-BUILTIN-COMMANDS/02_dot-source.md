### dot-source
 .  filename [arguments]
source filename [arguments]
 Read and execute commands from filename in the current shell environment and return the exit status of
 the last command executed from filename.  If filename does not contain a slash, filenames in PATH are
 used to find the directory containing filename, but filename does not need to be executable.  The file
 searched for in PATH need not be executable.  When bash is not in posix mode, it searches the current
 directory if no file is found in PATH.  If the sourcepath option to the shopt builtin command is turned
 off, the PATH is not searched.  If any arguments are supplied, they become the positional parameters
 when filename is executed.  Otherwise the positional parameters are unchanged.  If the -T option is
 enabled, . inherits any trap on DEBUG; if it is not, any DEBUG trap string is saved and restored around
 the call to ., and . unsets the DEBUG trap while it executes.  If -T is not set, and the sourced file
 changes the DEBUG trap, the new value is retained when . completes.  The return status is the status of
 the last command exited within the script (0 if no commands are executed), and false if filename is not
 found or cannot be read.

