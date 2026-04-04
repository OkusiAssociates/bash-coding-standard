## ARGUMENTS

If arguments remain after option processing, and neither -c nor -s has been supplied, the first argument is assumed to be the name of a file containing shell commands. If bash is invoked this way, $0 is set to the name of the file and the positional parameters are set to the remaining arguments. Bash reads and executes commands from this file, then exits. The exit status is that of the last command executed in the script. If no commands are executed, the exit status is 0. An attempt is first made to open the file in the current directory; if no file is found, the shell searches the directories in PATH for the script.

