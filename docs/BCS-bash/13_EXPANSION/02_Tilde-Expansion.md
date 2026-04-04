### Tilde Expansion

If a word begins with an unquoted tilde character (~), all characters preceding the first unquoted slash (or all characters if there is no unquoted slash) are considered a tilde-prefix. If none of the characters in the tilde-prefix are quoted, the characters following the tilde are treated as a possible login name. If this login name is the null string, the tilde is replaced with the value of HOME. If HOME is unset, the home directory of the user executing the shell is substituted instead. Otherwise, the tilde-prefix is replaced with the home directory associated with the specified login name.

If the tilde-prefix is ~+, the value of PWD replaces the tilde-prefix. If the tilde-prefix is ~-, the value of OLDPWD, if set, is substituted. If the characters following the tilde consist of a number N, optionally prefixed by a + or -, the tilde-prefix is replaced with the corresponding element from the directory stack, as it would be displayed by the dirs builtin invoked with the tilde-prefix as an argument. If the characters following the tilde consist of a number without a leading + or -, + is assumed.

If the login name is invalid, or the tilde expansion fails, the word is unchanged.

Each variable assignment is checked for unquoted tilde-prefixes immediately following a : or the first =. In these cases, tilde expansion is also performed. Consequently, filenames with tildes may be used in assignments to PATH, MAILPATH, and CDPATH, and the shell assigns the expanded value.

Bash also performs tilde expansion on words satisfying the conditions of variable assignments (as described under PARAMETERS) when they appear as arguments to simple commands.
