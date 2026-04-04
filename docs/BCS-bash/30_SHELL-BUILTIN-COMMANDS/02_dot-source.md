### dot-source
 .  filename [arguments]
source filename [arguments]

Read and execute commands from filename in the current shell environment, returning the exit status of the last command executed. If filename does not contain a slash, PATH is searched for a directory containing filename, but filename does not need to be executable. If no file is found in PATH, the current directory is also searched. If the sourcepath option to shopt is turned off, PATH is not searched.

If any arguments are supplied, they become the positional parameters when filename is executed. Otherwise the positional parameters are unchanged.

If the -T option is enabled, . inherits any trap on DEBUG. If -T is not set, any DEBUG trap string is saved and restored around the call to ., and . unsets the DEBUG trap while it executes. If the sourced file changes the DEBUG trap while -T is not set, the new value is retained when . completes.

The return status is the exit status of the last command executed within the script (0 if no commands are executed), and false if filename is not found or cannot be read.
