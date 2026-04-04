### export
export [-fn] [name[=word]] ...
export -p

The supplied names are marked for automatic export to the environment of subsequently executed commands. If -f is given, the names refer to functions. If no names are given, or if -p is supplied, a list of all exported variable names is printed. The -n option removes the export property from each name. If a variable name is followed by =word, the value of the variable is set to word.

Returns 0 unless an invalid option is encountered, a name is not a valid shell variable name, or -f is supplied with a name that is not a function.
