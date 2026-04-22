<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Shell Function Definitions

A shell function is an object called like a simple command that executes a compound command with a new set of positional parameters. Shell functions are declared as follows:

fname () compound-command [redirection]
function fname [()] compound-command [redirection]

This defines a function named fname. The reserved word function is optional. If function is supplied, the parentheses are optional. The body of the function is compound-command (see Compound Commands), usually a list of commands between { and }, but any compound command form is permitted. If function is used without parentheses, braces are recommended.

A function name can be any unquoted shell word that does not contain $. Any redirections specified when a function is defined are performed when the function is executed. The exit status of a function definition is zero unless a syntax error occurs or a readonly function with the same name already exists. When executed, the exit status of a function is the exit status of the last command executed in the body (see FUNCTIONS).
