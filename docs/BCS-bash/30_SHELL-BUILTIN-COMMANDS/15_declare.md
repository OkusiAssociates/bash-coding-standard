<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### declare
declare [-aAfFgiIlnrtux] [-p] [name[=value] ...]
typeset [-aAfFgiIlnrtux] [-p] [name[=value] ...]

Declare variables and give them attributes. If no names are given, display variable values. The -p option displays the attributes and values of each name. When -p is used with name arguments, additional options other than -f and -F are ignored. When -p is supplied without name arguments, it displays the attributes and values of all variables having the attributes specified by the additional options. If no other options are supplied with -p, declare displays the attributes and values of all shell variables.

The -f option restricts the display to shell functions. The -F option inhibits the display of function definitions; only the function name and attributes are printed. If the extdebug shell option is enabled using shopt, the source file name and line number where each name is defined are also displayed. -F implies -f.

The -g option forces variables to be created or modified at the global scope, even when declare is executed in a shell function. It is ignored in all other cases. The -I option causes local variables to inherit the attributes (except the nameref attribute) and value of any existing variable with the same name at a surrounding scope. If there is no existing variable, the local variable is initially unset.

The following options restrict output to variables with the specified attribute or assign attributes to variables:

-a  Each name is an indexed array variable.

-A  Each name is an associative array variable.

-f  Use function names only.

-i  The variable is treated as an integer; arithmetic evaluation is performed when the variable is assigned a value.

-l  When the variable is assigned a value, all upper-case characters are converted to lower-case. The upper-case attribute is disabled.

-n  Give each name the nameref attribute, making it a name reference to another variable. That other variable is defined by the value of name. All references, assignments, and attribute modifications to name, except those using or changing the -n attribute itself, are performed on the variable referenced by name's value. The nameref attribute cannot be applied to array variables.

-r  Make names readonly. These names cannot then be assigned values by subsequent assignment statements or unset.

-t  Give each name the trace attribute. Traced functions inherit the DEBUG and RETURN traps from the calling shell. The trace attribute has no special meaning for variables.

-u  When the variable is assigned a value, all lower-case characters are converted to upper-case. The lower-case attribute is disabled.

-x  Mark names for export to subsequent commands via the environment.

Using + instead of - turns off the attribute, with the exceptions that +a and +A may not be used to destroy array variables and +r will not remove the readonly attribute. When used in a function, declare and typeset make each name local, as with the local command, unless the -g option is supplied. If a variable name is followed by =value, the value of the variable is set to value. When using -a or -A and the compound assignment syntax to create array variables, additional attributes do not take effect until subsequent assignments.

Returns 0 unless an invalid option is encountered, an attempt is made to define a function using -f foo=bar, an attempt is made to assign a value to a readonly variable, an attempt is made to assign a value to an array variable without using the compound assignment syntax, one of the names is not a valid shell variable name, an attempt is made to turn off readonly status for a readonly variable, an attempt is made to turn off array status for an array variable, or an attempt is made to display a non-existent function with -f.
