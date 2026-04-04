### Shell Function Definitions

A shell function is an object that is called like a simple command and executes a compound command with a new
set of positional parameters.  Shell functions are declared as follows:

fname () compound-command [redirection]
function fname [()] compound-command [redirection]
 This defines a function named fname.  The reserved word function is optional.  If the function reserved
 word is supplied, the parentheses are optional.  The body of the function is the compound command
 compound-command (see Compound Commands above).  That command is usually a list of commands between {
 and }, but may be any command listed under Compound Commands above.  If the function reserved word is
 used, but the parentheses are not supplied, the braces are recommended.  compound-command is executed
 whenever fname is specified as the name of a simple command.  When in posix mode, fname must be a valid
 shell name and may not be the name of one of the POSIX special builtins.  In default mode, a function
 name can be any unquoted shell word that does not contain $.  Any redirections (see REDIRECTION below)
 specified when a function is defined are performed when the function is executed. The exit status of a
 function definition is zero unless a syntax error occurs or a readonly function with the same name
 already exists.  When executed, the exit status of a function is the exit status of the last command
 executed in the body.  (See FUNCTIONS below.)

