## PARAMETERS

A parameter is an entity that stores values.  It can be a name, a number, or one of the special characters
listed below under Special Parameters.  A variable is a parameter denoted by a name.  A variable has a value
and zero or more attributes.  Attributes are assigned using the declare builtin command (see declare below in
SHELL BUILTIN COMMANDS).

A parameter is set if it has been assigned a value.  The null string is a valid value.  Once a variable is
set, it may be unset only by using the unset builtin command (see SHELL BUILTIN COMMANDS below).

A variable may be assigned to by a statement of the form

 name=[value]

If value is not given, the variable is assigned the null string. All values undergo tilde expansion,
parameter and variable expansion, command substitution, arithmetic expansion, and quote removal (see EXPANSION
below).  If the variable has its integer attribute set, then value is evaluated as an arithmetic expression
even if the $((...)) expansion is not used (see Arithmetic Expansion below).  Word splitting and pathname
expansion are not performed.  Assignment statements may also appear as arguments to the alias, declare,
typeset, export, readonly, and local builtin commands (declaration commands).  When in posix mode, these
builtins may appear in a command after one or more instances of the command builtin and retain these
assignment statement properties.

In the context where an assignment statement is assigning a value to a shell variable or array index, the +=
operator can be used to append to or add to the variable's previous value.  This includes arguments to builtin
commands such as declare that accept assignment statements (declaration commands).  When += is applied to a
variable for which the integer attribute has been set, value is evaluated as an arithmetic expression and
added to the variable's current value, which is also evaluated.  When += is applied to an array variable using
compound assignment (see Arrays below), the variable's value is not unset (as it is when using =), and new
values are appended to the array beginning at one greater than the array's maximum index (for indexed arrays)
or added as additional key-value pairs in an associative array.  When applied to a string-valued variable,
value is expanded and appended to the variable's value.

A variable can be assigned the nameref attribute using the -n option to the declare or local builtin commands
(see the descriptions of declare and local below) to create a nameref, or a reference to another variable.
This allows variables to be manipulated indirectly.  Whenever the nameref variable is referenced, assigned to,
unset, or has its attributes modified (other than using or changing the nameref attribute itself), the
operation is actually performed on the variable specified by the nameref variable's value.  A nameref is
commonly used within shell functions to refer to a variable whose name is passed as an argument to the
function.  For instance, if a variable name is passed to a shell function as its first argument, running
 declare -n ref=$1
inside the function creates a nameref variable ref whose value is the variable name passed as the first
argument.  References and assignments to ref, and changes to its attributes, are treated as references,
assignments, and attribute modifications to the variable whose name was passed as $1.  If the control variable
in a for loop has the nameref attribute, the list of words can be a list of shell variables, and a name
reference will be established for each word in the list, in turn, when the loop is executed.  Array variables
cannot be given the nameref attribute.  However, nameref variables can reference array variables and
subscripted array variables.  Namerefs can be unset using the -n option to the unset builtin.  Otherwise, if
unset is executed with the name of a nameref variable as an argument, the variable referenced by the nameref
variable will be unset.

---
- [Positional Parameters](01_Positional-Parameters.md)
- [Special Parameters](02_Special-Parameters.md)
- [Shell Variables](03_Shell-Variables.md)
- [Arrays](04_Arrays.md)
