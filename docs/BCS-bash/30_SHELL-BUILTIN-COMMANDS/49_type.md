### type

type [-aftpP] name [name ...]

With no options, indicates how each name would be interpreted if used as a command name.

-t  Prints a single word: alias, keyword, function, builtin, or file, indicating what type of command name refers to. If name is not found, nothing is printed and the exit status is false.

-p  Returns the name of the disk file that would be executed if name were specified as a command, or nothing if -t would not return file for that name. If a command is hashed, prints the hashed value, which is not necessarily the file that appears first in PATH.

-P  Forces a PATH search for each name, even if -t would not return file. If a command is hashed, prints the hashed value rather than the first match in PATH.

-a  Prints all locations that contain an executable named name, including aliases and functions unless -p is also given. The hash table is not consulted.

-f  Suppresses shell function lookup, as with the command builtin.

Returns true if all arguments are found, false if any are not found.
