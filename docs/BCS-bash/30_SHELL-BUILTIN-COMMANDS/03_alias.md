<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### alias
alias [-p] [name[=value] ...]

With no arguments or with -p, prints all aliases in the form alias name=value on standard output. When arguments are supplied, an alias is defined for each name whose value is given. A trailing space in value causes the next word to be checked for alias substitution when the alias is expanded. For each name with no value supplied, the name and value of the alias is printed.

Returns true unless a name is given for which no alias has been defined.
