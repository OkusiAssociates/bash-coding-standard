### readonly

readonly [-aAf] [-p] [name[=word] ...]

Mark the given names as readonly, preventing subsequent assignment. With -f, the named functions are marked readonly instead. The -a option restricts variables to indexed arrays; -A restricts to associative arrays. If both are supplied, -A takes precedence.

If no names are given, or if -p is supplied, all readonly names are printed. The other options may restrict the output to a subset. The -p option formats output so it can be reused as input. If a variable name is followed by =word, the variable is set to word before being made readonly.

Returns 0 unless an invalid option is given, a name is not a valid shell variable, or -f names something that is not a function.
